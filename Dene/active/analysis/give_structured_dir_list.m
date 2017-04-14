% % % % % %  One Place to keep the dirs for all analyses
function structdirs = give_structured_dir_list(home_dir,genotype_dirs,groups)

% expecting a dir location and a list: {genotype1,genotype2,etc}


% need location of base
if isempty(home_dir)
    home_dir = uigetdir(pwd,'select base location of segmentation directories');
end
cd(home_dir);

% check that all dirs exist
for i = 1:length(genotype_dirs)
    currdir = genotype_dirs{i};
    display(length(currdir));
    
    if isdir([home_dir,filesep,currdir]);
        continue
    else
        display(['is not a dir ----  ',home_dir,currdir,' ---  is not a dir']);
        return
    end
    
end

% prime list for output
outdirs = cell(length(genotype_dirs),1);

dir_ind = false(length(genotype_dirs));
    
% make the list    
for i = 1:length(genotype_dirs)
    currfulldirs = {};
    currdir_type = genotype_dirs{i};
    currsub_end = getsubdirs(home_dir,currdir_type);
    for ii = 1:length(currsub_end)
        currfulldirs = [currfulldirs,{formfulldir(home_dir,currdir_type,currsub_end{ii})}];
    end
    outdirs{i} = currfulldirs;
end  

[dir_ind movie_dirs movie_dirs_full] = get_dir_ind(...
    home_dir, genotype_dirs)


grouped_dir_ind = false(length(groups), length(dir_ind(1, :)));
for j = 1:length(groups)
    for k = 1:length(groups(j).dirs)
        grouped_dir_ind(j, :) = grouped_dir_ind(j, :) | dir_ind(groups(j).dirs(k), :);
        
    end
end



for i = 1:length(groups);
    structdirs{i} = {movie_dirs_full{grouped_dir_ind(i, :)}};
end


return

end

    
        
    function nameFolds = getsubdirs(home_dir,sub_base)
        
        all_endsubdirs = dir([home_dir,sub_base]);
        isub = [all_endsubdirs(:).isdir]; 
        nameFolds = {all_endsubdirs(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'}, 'legacy')) = [];
    end


        
    function fullsegdir = formfulldir(big_base,sub_base,end_subdir)
       fullsegdir = [big_base,filesep,sub_base,filesep,end_subdir,filesep,'seg'];
    end
        
    
    
    function [dir_ind movie_dirs movie_dirs_full] = get_dir_ind(...
    home_dir, root_dir_names)
        dir_ind = false(length(root_dir_names));
        cnt = 0;
        for i = 1:length(root_dir_names)
            cd(root_dir_names{i});
            sub_dir = pwd;
            dir_names = dir;
            for j = 3:length(dir_names)
                if dir_names(j).isdir
                    cd(sub_dir);
                    cd(dir_names(j).name)
                    if ~isdir('seg')
                        continue
                    end
                    cd('seg')
                    if ~length(dir('shift_info.mat'))
                        continue
                    end
                    if ~length(dir('timestep.mat'))
                        disp(['timestep.mat not found in ' pwd])
                        continue
                    end

                    load('shift_info');
                    load('timestep');


                    cnt = cnt + 1;
                    movie_dirs{cnt} = dir_names(j).name;
                    movie_dirs_full{cnt} = pwd;
                    dir_ind(i, cnt) = true; 
                    shifts_returned(cnt) = shift_info;
                    time_step_ret(cnt) = timestep;

                end    
            end
            cd(home_dir);
        end
    end
    

