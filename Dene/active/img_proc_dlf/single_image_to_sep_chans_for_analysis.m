function color_dirs_found = single_image_to_sep_chans_for_analysis(in_dir, keep_originals_bool)

if nargin < 2 || isempty(keep_originals_bool)
    keep_originals_bool = false;
end

if isempty(in_dir) || nargin<1
in_dir = pwd;
end

num_imgs_to_make = 1;
start_dir = pwd;


[imgname_full img_name_main] = single_image_base_and_full_name(in_dir);

imgtemp = imread(imgname_full);

build_folders_and_create_monochromes_for_split_channels(imgtemp, img_name_main,...
                                                        num_imgs_to_make, keep_originals_bool);

color_dirs_found = get_color_dirs(pwd);

% colorsexist = ismember({'red','green','blue'}, color_dirs_found);
% max(imgtemp(:,:,~colorsexist));
% make seg image
seg_img_general = max(imgtemp(:,:,1:2), [], 3);

if size(imgtemp,3)>3
    seg_img_general = max(imgtemp(:,:,1:2),[],3);
end
% seg_img_general = double(seg_img_general);

make_seg_folder_and_imgs(seg_img_general, img_name_main, ...
                         num_imgs_to_make, keep_originals_bool);

% which channels to include
channels_to_use = [1 1 1];
make_tracking_opts(channels_to_use);

P = mfilename('fullpath');
[~, base_dir] = get_filename_from_fullpath(P);
base_dir = [base_dir,filesep,'..',filesep];

cd(start_dir);




function [imgname_full, img_name_main] = single_image_base_and_full_name(imgdir)


    cd(imgdir)

    curr_img_files = dir('*.tif');

    if isempty(curr_img_files)
        curr_img_files = dir('*.TIF');
    end

    if isempty(curr_img_files)
        display('no mage files found! ending program.');
        return
    end

    if length(curr_img_files) > 1 
        display('more than one image file found. ending program.');
        return
    end


    imgname = curr_img_files(:).name;
    [z_num, t_num, t_ind] = get_file_nums_dlf(curr_img_files(:).name, 1);
    if ~isempty(t_ind)
        img_name_main = imgname(1:(t_ind-1));
    else
        tag_ind = strfind(imgname, '.tif');
        img_name_main = imgname(1:(tag_ind-1));
    end

    imgname_full = imgname;


function build_folders_and_create_monochromes_for_split_channels(rgb_img,...
        img_name_main, num_t_for_img, keep_originals_bool)
    
    if nargin<4 || isempty(keep_originals_bool)
        keep_originals_bool = false;
    end

    if size(rgb_img,3)<2
        display('need image in RGB format');
%         return
    end
    
    if any(any(rgb_img(:,:,1)~=0))
        % f = figure('visible','off');
        hred = figure('visible','off');
        imshow(rgb_img(:,:,1), 'Border', 'tight');
        mkdir('red');
        saveas(hred,[pwd,filesep,'red',filesep,img_name_main],'tif');
        close(hred);
        
        actn_dir = [pwd,filesep,'red'];
        
        make_mult_t_imgs_and_conv_size(actn_dir, rgb_img(:,:,1),...
            img_name_main, num_t_for_img, 'red', keep_originals_bool);
        if isempty(dir('./red'))
            rmdir('./red');
        end
    end

	if size(rgb_img,3)<2
        display('need image in RGB format');
        return
	end
    
    

    if any(any(rgb_img(:,:,2)))
        % f = figure('visible','off');
        hgreen = figure('visible','off');
        imshow(rgb_img(:,:,2), 'Border', 'tight');
        mkdir('green');
        saveas(hgreen,[pwd,filesep,'green',filesep,img_name_main],'tif');
        close(hgreen);
        
        
        actn_dir = [pwd,filesep,'green'];
        
        make_mult_t_imgs_and_conv_size(actn_dir, rgb_img(:,:,2),...
            img_name_main, num_t_for_img, 'green', keep_originals_bool);
        if isempty(dir('./green'))
            rmdir('./green');
        end
    end

    
    if any(any(rgb_img(:,:,3)))
        % f = figure('visible','off');
        hblue = figure('visible','off');
        imshow(rgb_img(:,:,3), 'Border', 'tight');
        mkdir('blue');
        saveas(hblue,[pwd,filesep,'blue',filesep,img_name_main],'tif');
        close(hblue);
        
        
        actn_dir = [pwd,filesep,'blue'];
        
        make_mult_t_imgs_and_conv_size(actn_dir, rgb_img(:,:,3),...
            img_name_main, num_t_for_img, 'blue', keep_originals_bool);
        if isempty(dir('./blue'))
            rmdir('./blue');
        end
    end
    


    


function color_dirs = get_color_dirs(search_dir)
    % get colors existing
    d = dir(search_dir);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    allpossible_colors = {'red','green','blue'};
    color_dirs = intersect(nameFolds,allpossible_colors, 'legacy');
    
function make_seg_folder_and_imgs(img_data_for_seg, img_name_main,...
                                  num_t_for_img, keep_originals_bool)
        
        if nargin < 4 || isempty(keep_originals_bool)
            keep_originals_bool = false;
        end
        
        startdir = pwd;
        mkdir('seg');
        cd('seg');
        hseg = figure('visible','off');
        imshow(img_data_for_seg, 'Border', 'tight');
        
        
        seg_img_base_name = [pwd,filesep,img_name_main];
        

 
    temp_z = 1;
    for temp_t = 1:num_t_for_img
        tz_seg_specific_name = add_img_nums(seg_img_base_name,temp_t,temp_z,'.tif');
        saveas(hseg,tz_seg_specific_name,'tif');
%         copyfile(curr_img_files(:).name,add_img_nums(img_name_main,temp_t,temp_z))
    end
    
        close(hseg);

        convert_images_to_usual_size(pwd,'_seg');
        
        
        org_img_dir = 'original_imgs';
        str_to_find = 'converted';
        move_original_tifs_to_subfolder(org_img_dir, str_to_find, keep_originals_bool);
        
        
        cd(startdir);
        
        
        
function make_mult_t_imgs_and_conv_size(action_dir, img_data,...
                                        img_base_name, num_t_for_img,...
                                        extra_str, keep_originals_bool)

if nargin < 6 || isempty(keep_originals_bool)
    keep_originals_bool = false;
end
    startdir = pwd;
    cd(action_dir);
    hseg = figure('visible','off');
    imshow(img_data, 'Border', 'tight');
    img_base_name = [pwd,filesep,img_base_name];
        
    if keep_originals_bool  
        org_img_dir = 'original_imgs';
        mkdir(org_img_dir);
    end

    
    temp_z = 1;
    for temp_t = 1:num_t_for_img
        tz_specific_name = add_img_nums(img_base_name,temp_t,temp_z, '.tif');
        saveas(hseg,tz_specific_name,'tif');
%         copyfile(curr_img_files(:).name,add_img_nums(img_name_main,temp_t,temp_z))
    end
    
        close(hseg);
        convert_images_to_usual_size(pwd,['_',extra_str]);
       
%        move the bigger tifs to a separate folder.
        alltifsindir = dir('*.tif');
        
        for i = 1:length(alltifsindir)
           
            t_num_temp = get_file_nums_dlf(alltifsindir(i).name,1);
            str_to_find = 'converted';
            strpos = strfind(alltifsindir(i).name,str_to_find);
            
            if isempty(t_num_temp) || isempty(strpos)
                sourcefile = [pwd,filesep,alltifsindir(i).name];
                if keep_originals_bool                    
                    destfile = [pwd,filesep,org_img_dir,filesep,alltifsindir(i).name];
                    movefile(sourcefile,destfile);
                else
                    delete(sourcefile)
                end
            end
            
            
            
        end
        
        
        cd(startdir);
        
                

    
    function make_script_dir(script_to_copy_filename, script_to_copy_fullname, in_dir)
        
        startdir = pwd;
        if ~isdir('scripts')
            mkdir('scripts');
        end
        cd('scripts');
        script_finders = dir(script_to_copy_filename);
        if isempty(script_finders)
            
            dest_script = [pwd,filesep,script_to_copy_filename];
%             copyfile(script_to_copy_fullname,dest_script);
           
            fid = fopen(dest_script, 'w+');
            fseek(fid,0,'bof')
%             ftell(fid); 
            txt_to_add = ['base_dir = ''',in_dir,'''',';','%'];
            fwrite(fid,txt_to_add);
            fprintf(fid,'\n');
            fprintf(fid,'\n');
            
            fid2 = fopen(script_to_copy_fullname);
            tline = fgetl(fid2);
            while ischar(tline)
                fwrite(fid,tline);
                fprintf(fid,'\n');
                tline = fgetl(fid2);
            end

            fclose(fid);
            fclose(fid2);
       
        end
        cd(startdir);
        
        
        
        
    function move_original_tifs_to_subfolder(org_img_dir, str_to_find, keep_originals_bool)
        if nargin < 3 || isempty(keep_originals_bool)
            keep_originals_bool = false;
        end
        
        startdir = pwd;
        org_img_dir = 'original_imgs';
        if keep_originals_bool
            mkdir(org_img_dir);  
        end
        
%         move the bigger tifs to a separate folder.
        alltifsindir = dir('*.tif');
        
        for i = 1:length(alltifsindir)           
            t_num_temp = get_file_nums_dlf(alltifsindir(i).name,1);
            str_to_find = 'converted';
            strpos = strfind(alltifsindir(i).name,str_to_find);
            
            if isempty(t_num_temp) || isempty(strpos)
                sourcefile = [pwd,filesep,alltifsindir(i).name];
                if keep_originals_bool
                    destfile = [pwd,filesep,org_img_dir,filesep,alltifsindir(i).name];
                    movefile(sourcefile,destfile);
                else
                    delete(sourcefile);
                end
            end            
        end
        
        cd(startdir);
        
        
        
        function make_tracking_opts(channels_to_use)
        
        startdir = pwd;
        cd('seg');
        dest_name = [pwd,filesep,'tracking_options.txt'];
            
        fid = fopen(dest_name, 'w+');
        fseek(fid,0,'bof')
%             ftell(fid); 
        
        channel1txt = ['..',filesep,'red',filesep,'convertedsize_red_T0001_Z0001.tif'];
        channel2txt = ['..',filesep,'green',filesep,'convertedsize_green_T0001_Z0001.tif'];
        channel3txt = ['..',filesep,'blue',filesep,'convertedsize_blue_T0001_Z0001.tif'];
        channel3txtalt = ['..',filesep,'seg',filesep,'convertedsize_seg_T0001_Z0001.tif'];

        if channels_to_use(1)
            txt_to_add = ['channel1 = ''',channel1txt,'''',';'];
            fwrite(fid,txt_to_add);
            fprintf(fid,'\n');
            fprintf(fid,'\n');
        end
        
        if channels_to_use(2)
            txt_to_add = ['channel2 = ''',channel2txt,'''',';'];
            fwrite(fid,txt_to_add);
            fprintf(fid,'\n');
            fprintf(fid,'\n');
        end
        
        if channels_to_use(3)
            txt_to_add = ['channel3 = ''',channel3txt,'''',';'];
            fwrite(fid,txt_to_add);
            fprintf(fid,'\n');
            fprintf(fid,'\n');
        end
        
        fclose(fid);
           

        cd(startdir);
    
        
        

