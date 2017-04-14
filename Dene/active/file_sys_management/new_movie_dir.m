function new_movie_dir(source_dir,dest_base,sepBool,maxBool,...
    segBool,scriptsBool,combinedBool,multi_settingsBool,colors_cherry,...
    figsBool,scripts_dir,rm_all_tog_bool,...
    adaptMaxBool,PIVBool,showPIVelon,...
    visualize_PIV,super_smplBool,aniso_smthBool,...
    denoisingBool,transf_origs,rot_ang)

% 1. source_dir = dir with originals
% 2. dest_base = dir where new files go
% 3. sepBool = separate y/n
% 4. maxBool = max proj y/n
% 5. segBool = seg fold y/n
% 6. scriptsBool = script folder y/n
% 7. combinedBool = combo folder y/n
% 8. multi_settingsBool = make multi channel settings file y/n
% 9. colors_cherry = red is cherry y/n
% 10. figsBool = figures folder y/n
% 11. scripts_dir = where polarity analysis scripts are
% 12. rm_all_tog_bool = remove the tif stacks after duplicating separtes
% y/n
% 13. adaptMaxBool = run adaptive max proj (necessary for PIV)
% 14. PIVBool = run PIV
% 15. showPIVelon = get elon info from PIV
% 16. visualize_PIV = show PIV working as it's calculated
% 17. super_smplBool = supersample originals in z dim
% 18. aniso_smthBool = apply anisotropic smoothing to super sampled set
% 19. denoisingBool = apply denoising to whichever  images are most
% processed (origs < supersmpl < smthd)
% 20. transf_origs = transfer originals -> set to zero if you are not
% transfering files, but using this function for something else

old_dir = pwd;
out_z_for_proj = 9999;

P = mfilename('fullpath');
reversestr = fliplr(P);
[justfile, justdirpath] = strtok(reversestr,filesep);
justfile = fliplr(justfile);
base_dir = fliplr(justdirpath);

SRC_base_dir = [base_dir,filesep,'..',filesep,'..',filesep,'..',filesep];
display(['SRC_base_dir: ',SRC_base_dir]);


%%% Set Options %%%
if nargin < 21 || isempty(rot_ang)
    rot_bool = false;
    rot_ang = 0;
end

if nargin < 20 || isempty(transf_origs)
    transf_origs = true;
end

if transf_origs && (nargin < 1 || isempty(source_dir))
    
    h = msgbox('NEXT: Select a File from the Source Directory.');
    uiwait(h);
    pause(0.5);
    
   [filename, source_dir] = uigetfile( ...
   {'*.TIF','Tagged Image File (*.TIF)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Select a Representative File', ...
   'MultiSelect', 'on');
    

    if (source_dir==0)
        error('No Source Directory Selected!');
    end
end

if ~isdir(source_dir) && transf_origs
    error('The directory %s does not exist', source_dir);
    return
end


if nargin < 2 || isempty(dest_base)    
    
    h = msgbox('NEXT: Select the Destination Directory.');
    uiwait(h);
    pause(0.5);

    dest_base = uigetdir(pwd,'Select Base Destination Directory');
    if (dest_base==0)
        error('No Destination Directory Selected!');
    else
    if ~isdir(dest_base)
    error('The directory %s does not exist', dest_base);
    return
    end
    dest_base = [dest_base,filesep,curr_folder];
    end
end




if nargin < 3 || isempty(sepBool)
    sepBool = 1;
end

if nargin < 4 || isempty(maxBool)
    maxBool = 1;
end

if nargin < 5 || isempty(segBool)
    segBool = 1;
end

if nargin < 6 || isempty(scriptsBool)
    scriptsBool = 1;
end
% if nargin < 7 || isempty(combinedBool)   % this is specified later.
%     combinedBool = 0;
% end

if nargin < 8 || isempty(multi_settingsBool)
    multi_settingsBool = 0;
end

if nargin < 9 || isempty(colors_cherry)
    colors_cherry = 1;
end

if colors_cherry
    color_list = {'unknown_color','gfp','cherry'};
else
    color_list = {'unknown_color','gfp','rfp'};
end

if nargin < 10 || isempty(figsBool)
    figsBool = 0;
end

if nargin < 11 || isempty(scripts_dir)
    scripts_dir = [SRC_base_dir,filesep,'/Dene/active/edge_info_polarities/default_scripts'];
end

% 12. rm_all_tog_bool = remove the tif stacks after duplicating separtes
% y/n
% 13. adaptMaxBool = run adaptive max proj (necessary for PIV)
% 14. PIVBool = run PIV
% 15. showPIVelon = get elon info from PIV

if nargin < 12 || isempty(rm_all_tog_bool)
    rm_all_tog_bool = true;
end

if nargin < 13 || isempty(adaptMaxBool)
    adaptMaxBool = false;
end

if nargin < 14 || isempty(PIVBool)
    PIVBool = false;
end

if nargin < 15 || isempty(showPIVelon)
    showPIVelon = false;
end

if nargin < 16 || isempty(visualize_PIV)
    visualize_PIV = false;
end

if nargin < 17 || isempty(super_smplBool)
    super_smplBool = false;
end

if nargin < 18 || isempty(aniso_smthBool)
    aniso_smthBool = false;
end

if nargin < 19 || isempty(denoisingBool)
    denoisingBool = false;
end

if nargin < 20 || isempty(transf_origs)
    transf_origs = false;
end

%%% switch to appropriate starting directory
if transf_origs
    cd(source_dir);
    inds = (strfind(source_dir,filesep));
    curr_folder = source_dir(inds(end-1)+1:end);
else
    cd(dest_base);
end

%%% check which wavelengths are present %%%
if transf_origs
    new_names = dir('*.TIF');

    if isempty(new_names)
        new_names = dir('*.tif');
    end

    type_index = zeros(1,length(new_names));

    for i = 1:length(new_names) 
        just_names{i,:} = new_names(i).name; 
    end
end

display(sprintf ( '\n \n') ); 
display('Preview:')
if transf_origs
    display(['  source directory: ',source_dir]);
    display(['  destination directory: ', dest_base]);
else
    display(['  working (in place) on directory: ', dest_base]);
end

%%%% None of this is necesary if starting from manually transferred and
%%%% grouped files
if transf_origs
    display(sprintf ( '\n---------------------'));
    display('Here we go...');
    display([num2str(length(new_names)),' files found in source directory with a TIF extension.']);

    % check for '488nm' or 'w1488' --- (wavelength of green laser - gfp folder)
    % check for '568nm' or 'w2568' --- (wavelength of cherry - cherry folder)
    for i = 1:length(new_names)
        if any_gfp_Bool(i,just_names)
            if ~any_cherry_Bool(i,just_names)
            type_index(i) = 1;

            else if any(findstr('488nm',just_names{i,:})) || any(findstr('w1488',just_names{i,:}))...
                        || any(findstr('w2488',just_names{i,:})) || any(findstr('_GFP_',just_names{i,:}))

                    type_index(i) = 1;
                else if any(findstr('568nm',just_names{i,:})) || any(findstr('w2568',just_names{i,:}))...
                            || any(findstr('w1568',just_names{i,:})) || any(findstr('_RFP_',just_names{i,:}))

                        type_index(i) = 2;
                    end
                end
            end
        else if any_cherry_Bool(i,just_names)
                type_index(i) = 2;
            end
        end

    %     set thumbs to nans
        if any(findstr('thumb',just_names{i,:}))
            type_index(i) = nan;
        end
    end

    display(' ');

    %%% nan = thumbnail file (do not copy)
    %%% 0 = unknown_color
    %%% 1 = gfp
    %%% 2 = cherry

    unknownBool = (nnz(type_index==0))>0;
    gfpBool = (nnz(type_index==1))>0;
    cherryBool = (nnz(type_index==2))>0;





    display(' ');
    display('Found:')
    display(['      ',num2str(sum(isnan(type_index))),' thumbnails (will not be copied).']);
    display(['      ',num2str(sum(type_index==0)),' files of unknown color.']);
    display(['      ',num2str(sum(type_index==1)),' gfp files.']);
    display(['      ',num2str(sum(type_index==2)),' cherry files.']);
    display(' ');



    % check which channels exist, for making automatic multichannel settings
    if sum(double([unknownBool,gfpBool,cherryBool])) > 1
        display('+++++  multiple channels found  +++++');
        if cherryBool    
            channel1_dir = [dest_base,color_list{3},filesep,'all_layers_sep'];
            if gfpBool
                channel2_dir = [dest_base,color_list{2},filesep,'all_layers_sep'];
                if unknownBool
                    channel3_dir = [dest_base,color_list{1},filesep,'all_layers_sep'];
                    msgbox('Apparently there are three different channels.');
                else channel3_dir = [];
                end
            else
                if unknownBool
                    channel2_dir = [dest_base,color_list{1},filesep,'all_layers_sep'];
                    channel3_dir = [];
                else error('something wrong with boolean rep. of channel colors');
                end
            end

        else if unknownBool
                channel1_dir = [dest_base,color_list{1},filesep,'all_layers_sep'];
                if gfpBool
                    channel2_dir = [dest_base,color_list{2},filesep,'all_layers_sep'];
                    channel3_dir = [];
                else error('something wrong with boolean rep. of channel colors');  
                end
            else error('something wrong with boolean rep. of channel colors');
            end
        end    
    end
end % (if transf_origs)
    

if transf_origs
    % % %%% Make Directories %%%
    if unknownBool
        make_movie_sub_dirs(source_dir,dest_base,color_list{1},type_index==0,...
                            just_names,sepBool,maxBool,out_z_for_proj,...
                            adaptMaxBool,PIVBool,showPIVelon,...
                            visualize_PIV,super_smplBool,aniso_smthBool,...
                            denoisingBool, transf_origs,rot_ang);
    end

    if gfpBool
        make_movie_sub_dirs(source_dir,dest_base,color_list{2},type_index==1,...
                            just_names,sepBool,maxBool,out_z_for_proj,...
                            adaptMaxBool,PIVBool,showPIVelon,...
                            visualize_PIV,super_smplBool,aniso_smthBool,...
                            denoisingBool, transf_origs,rot_ang);
    end

    if cherryBool
        make_movie_sub_dirs(source_dir,dest_base,color_list{3},type_index==2,...
                            just_names,sepBool,maxBool,out_z_for_proj,...
                            adaptMaxBool,PIVBool,showPIVelon,...
                            visualize_PIV,super_smplBool,aniso_smthBool,...
                            denoisingBool, transf_origs,rot_ang);
    end


    if unknownBool
        if sum(double([unknownBool,gfpBool,cherryBool])) > 1 && multi_settingsBool
              type_index_temp = 1;
              make_auto_multi_files(type_index_temp,color_list,channel1_dir,channel2_dir,channel3_dir,dest_base);
        end
    end

    if gfpBool
        if sum(double([unknownBool,gfpBool,cherryBool])) > 1 && multi_settingsBool
              type_index_temp = 2;
              make_auto_multi_files(type_index_temp,color_list,channel1_dir,channel2_dir,channel3_dir,dest_base);
        end
    end

    if cherryBool
        if sum(double([unknownBool,gfpBool,cherryBool])) > 1 && multi_settingsBool
              type_index_temp = 3;
              make_auto_multi_files(type_index_temp,color_list,channel1_dir,channel2_dir,channel3_dir,dest_base);
        end
    end

else %(if transf_origs)
    %%% split tifs after a manual transfer
    split_base_dir = dest_base;
    split_stacks_all_subfolds(split_base_dir,rm_all_tog_bool);    
end %(if transf_origs)



display('Making empty dirs: seg, scripts, figs, multi_chan_files, combined');
if segBool
    mkdir(dest_base,'seg')
end

if scriptsBool  && ~isempty(scripts_dir)
    mkdir(dest_base,'scripts')
%     if sum(double([unknownBool,gfpBool,cherryBool])) > 1
%         scripts_files = dir(scripts_dir);
%         scripts_files = {scripts_files(:).name};
        scripts_files_origin = {'script_for_values_along_edges_cell_back_def.m',...
                         'script_for_values_along_edges_def.m'};
        scripts_files_clone = {'values_along_edges_basic.m',...
                               'values_along_edges_extra.m'};

        for i = 1:length(scripts_files_origin)
            copyfile([scripts_dir,filesep,scripts_files_origin{i}],...
                [dest_base,'scripts',filesep,scripts_files_clone{i}],'f');
        end
end

if figsBool
    mkdir(dest_base,'figs')
end

if nargin < 7 || isempty(combinedBool)
    if gfpBool && cherryBool
        mkdir(dest_base,'combined');
    end
else if combinedBool
        mkdir(dest_base,'combined');
        mkdir([dest_base,'combined'],'for_segmentation');
        mkdir([dest_base,'combined'],'for_user_correction');
        mkdir([dest_base,'combined'],'for_edge_optimiztn');
    end
end


% % %%% Remove Excess Directories %%%
display('');
if transf_origs
    if rm_all_tog_bool
        display('removing all_together files')
        if unknownBool
            rmdir([dest_base,'unknown_color',filesep,'all_layers_together'],'s');
        end
        if gfpBool
            rmdir([dest_base,'gfp',filesep,'all_layers_together'],'s');
        end
        if cherryBool
            rmdir([dest_base,color_list{3},filesep,'all_layers_together'],'s');
        end
        display('done removing all_together files');
    end
end



% % %%% Finishing Up %%%
display(' ');
display('Changing back to the directory I started from.');
display('new_movie_dir complete! Check directories to confirm success.');
display(' ');
display('Review:')
display(['  source directory: ',source_dir]);
display(['  destination directory: ', dest_base]);
display('---------------------');

cd(old_dir);

function out_bool = any_gfp_Bool(i,just_names)
out_bool = any(findstr('488nm',just_names{i,:})) || any(findstr('w1488',just_names{i,:}))...
            || any(findstr('gfp',just_names{i,:})) || any(findstr('GFP',just_names{i,:}))...
            || any(findstr('w2488',just_names{i,:}));
        
function out_bool = any_cherry_Bool(i,just_names)
out_bool = any(findstr('568nm',just_names{i,:})) || any(findstr('w2568',just_names{i,:}))...
        || any(findstr('cherry',just_names{i,:})) || any(findstr('Cherry',just_names{i,:}))...
        || any(findstr('RFP',just_names{i,:})) || any(findstr('w1568',just_names{i,:}));
        

function make_movie_sub_dirs(source_dir,dest_base,color_name,type_index,...
                            just_names,sepBool,maxBool,out_z_for_proj,...
                            adaptMaxBool,PIVBool,showPIVelon,...
                            visualize_PIV,super_smplBool,aniso_smthBool,...
                            denoisingBool, transf_origs,rot_ang)
                        
    not_thumbs = find(type_index);
    to_check_zs = not_thumbs(1);

    max_z = length(imfinfo([source_dir,char(just_names(to_check_zs))]));
    display(['Working on ', color_name, ' files:']);
    display(['  ',num2str(sum(type_index)),' files found that are ',...
        color_name, '  -------- last filename: ',just_names{max(find(type_index))}]);

    
    mkdir(dest_base,color_name);
    mkdir([dest_base,color_name,filesep,'all_layers_together']);
    
    if transf_origs
        display('  Copying compound TIF files (all_layers)');
        %%% Move Files into new Directory
        tic;
        tocs_list = zeros(length(just_names),1);
        last_reset = 1;
        for i = 1:length(just_names)
            tocs_list(i) = toc; 
            if tocs_list(i) - tocs_list(last_reset) > 120
                display(['      ',num2str(sum(type_index(1:i))),' files copied. ', num2str(sum(type_index(i:end))), ' to be copied.']);
                display(['      ',num2str(tocs_list(i)),' seconds elapsed.']);
                last_reset = i;
            end
            if type_index(i)
                take = [source_dir,char(just_names(i))];
                give = [dest_base,color_name,filesep,'all_layers_together'];
                [status msg msgid] = copyfile(take,give,'f');
    %             ! cp take give
            end
        end
        display(['  Transfer of compound files complete (Time = ',num2str(tocs_list(end)),').']);
    end %end of transf_origs
    
    if sepBool
        display(['  Dividing compound files for different z-layers. This will take some time... (~',...
            num2str(tocs_list(end)*3),' by copy time * 3 -- or ~',num2str(0.27*max_z*sum(type_index)),' by num layers * 0.27 sec)']);
        display(['  There are ',num2str(max_z),' z-layers and ',num2str(sum(type_index)),' compound files.']);
        tic;
        mkdir([dest_base,color_name,filesep,'all_layers_sep']);
        convert_exp_images_dir_dlf([dest_base,color_name,filesep,'all_layers_together'],...
            [dest_base,color_name,filesep,'all_layers_sep']);
        time_elapsed = toc;
        display(['  Separation of compound files complete (Time = ',num2str(time_elapsed),').']);
        display(['  (',num2str(time_elapsed/(max_z*sum(type_index))),' seconds per separated image.)']);
    
        %%% Rotation
        if rot_ang ~= 0
            display(['rotating all images by ',num2str(rot_ang),' degrees']);
            tmpstartdir = pwd;
            cd([dest_base,color_name,filesep,'all_layers_sep']);
            rot_img_dir(rot_ang);
            cd(tmpstartdir);
        end
    
    end
    
    temp_old_dir = pwd;
    all_lyr_dir = [dest_base,color_name,filesep,'all_layers_together'];
    
    
    max_proj_dir = [dest_base,color_name,filesep,'max_proj_all'];
    if maxBool
        display('  Making a max projection from all layers available.');
        tic;
        if ~isdir(max_proj_dir)
            mkdir(max_proj_dir);
        end
        convert_and_project_exp_images_dir(all_lyr_dir,...
            max_proj_dir,[],[],out_z_for_proj);
        cd(max_proj_dir);
        channel_image_options_function;
        cd(temp_old_dir);
        time_elapsed = toc;
        display(['  Projection complete (Time = ',num2str(time_elapsed),').']);
        display(' ');
    end
    
    adpt_proj_dir = [dest_base,color_name,filesep,'max_proj_adaptive'];
    if adaptMaxBool
        display('creating adaptive max projection');
        if ~isdir(adpt_proj_dir)
            mkdir(adpt_proj_dir);
        end
        convert_and_project_exp_images_dir_adaptive(all_lyr_dir,...
        adpt_proj_dir,[],[],out_z_for_proj);
        cd(adpt_proj_dir);
        channel_image_options_function;
        cd(temp_old_dir);
    end

    if PIVBool
        display('running PIV');
        if ~isdir(adpt_proj_dir)
            display('adaptive max proj doesnt exist, trying regular max proj');
            if ~isdir(max_proj_dir)
                display('regular max proj doesnt exist cannot run PIV');
                return
            else
                cd(max_proj_dir);
                PIVlab_script_t_fun(max_proj_dir,visualize_PIV);
                process_piv_data;
                
            end
        else
            cd(adpt_proj_dir);
            PIVlab_script_t_fun(adpt_proj_dir,visualize_PIV);
            process_piv_data;
            
        end
        PIVdir = pwd;
        
        cd(temp_old_dir);
        save('PIVdir','PIVdir');
    end

    
    if showPIVelon
        figsdir = [dest_base,'figs',filesep];
        if ~isdir(figsdir)
            mkdir(figsdir)
        end
        display('calculating elongation from PIV');
        
        if ~isempty(dir('PIVdir.mat'))
            load('PIVdir','PIVdir');
        end
        
        cd(PIVdir);
        load('piv_procd_data','rel_elon_mean');
    	pivfig = figure;
        plot(rel_elon_mean);
        xlabel('frame number')
        ylabel('relative horizontal elongation');
        title('elongation from PIV');
        saveas(gcf,[figsdir,'piv-elon.pdf']);
        close(pivfig);
        cd(temp_old_dir);
        
    end

    imgproc_Bool = false; %whether any image processing happened           
%    figure out what kind of img processing we want to do
    if super_smplBool && ~aniso_smthBool
        img_proc_dir = [dest_base,color_name,filesep,'supersampled'];
    else if ~super_smplBool && aniso_smthBool
            img_proc_dir = [dest_base,color_name,filesep,'smoothed',filesep];
        else if super_smplBool && aniso_smthBool
                img_proc_dir = [dest_base,color_name,filesep,'sampled2_smthd',filesep];
            else
                img_proc_dir = [];
                imgproc_Bool = false;
                display('not making any extra img proc dirs based on advanced settings');
            end
        end
    end
    
%     do that image processing
    if super_smplBool || aniso_smthBool
        if ~isdir(img_proc_dir)
            mkdir(img_proc_dir)
        end
        display('super sampling in z dim');
        interp3d_img_doublesample(all_lyr_dir,img_proc_dir,super_smplBool,aniso_smthBool);
        imgproc_Bool = true;
        cd(temp_old_dir);
    end
    
%     run denoising on either originals, or on porcessed images       
if denoisingBool
    max_t_denoise = inf;
    denoisedir = [dest_base,color_name,filesep,'denoised'];
	if ~isdir(denoisedir)
        mkdir(denoisedir)
	end
    if imgproc_Bool
        liu_denoise_3d_fun_v02(img_proc_dir,denoisedir,max_t_denoise);
    else
        liu_denoise_3d_fun_v02(all_lyr_dir,denoisedir,max_t_denoise);
    end
end
        


    
    function make_auto_multi_files(type_index,color_list,channel1_dir,channel2_dir,channel3_dir,dest_base)
%         type_index: 1-unknown,2-gfp,3-cherry
%         color_list: matches a color to each type.

        source = [dest_base,color_list{type_index},filesep,'all_layers_together'];
        dest   = [dest_base,color_list{type_index},filesep,'all_layers_sep'];
        multi_chan_dir = [dest_base,color_list{type_index},filesep,'multi_chan_files'];
        mkdir(multi_chan_dir);
        
        old_dir = pwd;
        cd(source);
        channel_image_options_function;
        copyfile([source,filesep,'channel_image_settings.txt'],[dest,filesep,'channel_image_settings.txt']);
        
        cd(multi_chan_dir);
        make_play_movie_channels(channel1_dir,channel2_dir,channel3_dir);
        cd(old_dir);

        
        
