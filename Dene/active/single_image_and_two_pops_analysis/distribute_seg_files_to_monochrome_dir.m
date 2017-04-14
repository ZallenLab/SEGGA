function distribute_seg_files_to_monochrome_dir(source_seg_dir, dest_color_dir, color_str)
startdir = pwd;


cd(source_seg_dir);

matfiles_temp = dir('*.mat');

cd(dest_color_dir);
exclude_list = {'avrgs.mat',...
               'cells_for_two_pops_from_colors.mat',...
               'cells_for_two_pops_global.mat',...
               'full_metrics.mat',...
               'images_projection_info.mat',...
               'measurements.mat',...
               'v_link.mat'...
               };
           
for i = 1:length(matfiles_temp)
    if any(strcmp(matfiles_temp(i).name,exclude_list))
        continue
    end
    source_file = [source_seg_dir,filesep,matfiles_temp(i).name];
    dest_file = [dest_color_dir,filesep,matfiles_temp(i).name];
    copyfile(source_file,dest_file);
    
    [~,dest_file_short] = fileparts(dest_file);
    [z_num_seg, t_num_seg] = get_file_nums_dlf(dest_file_short, 1);
    
    if isempty(z_num_seg)
        continue
    end
    
%     search for img file
% only for seg files
% if its the wrong seg file then remove it
% just a complicated clean up system

    if ~isempty(strfind(matfiles_temp(i).name,'seg'))

        all_img_files = dir('*.tif');
        img_match_found = 0;
        search_ind = 0;
        while ~img_match_found && search_ind < length(all_img_files)
            search_ind = search_ind + 1;
            [z_num_img, t_num_img] = get_file_nums_dlf(all_img_files(search_ind).name, 1);
            if ~isempty(t_num_img) && t_num_img == t_num_seg
                img_match_found = 1;
                match_seg_to_new_img(dest_file,all_img_files(search_ind).name);

                delete(dest_file);
            end

            if search_ind == length(all_img_files)
%                 display('no img match found for seg file: error (maybe)');
%                 return;
            end

        end
        
    end
    
    
end

cd(startdir);

function match_seg_to_new_img(seg_file,img_file)

    load(seg_file);
    filenames = {img_file};

    tag_ind = strfind(img_file, '.tif');
    img_name_main = img_file(1:(tag_ind-1));
    new_seg_name = [img_name_main,'.mat'];

    save(new_seg_name,'casename','cellgeom','filenames');
        



