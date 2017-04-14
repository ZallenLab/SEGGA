 function SEGGA_node_res(input_settings)

% the use of 'all_dirs_separated'
% which gives full paths for each directory 
% makes it possible to use any set of directories,
% not just some set under the same path base dir

cntrl_ind = input_settings.control_ind;
leg_txt = {input_settings.groups(:).label};
% old home dir: [input_settings.movie_base_dir,filesep]                   
all_dirs_separated = give_structured_dir_list(filesep,input_settings.fullpath_dirnames,input_settings.groups);               




savedir = [input_settings.save_base_dir,filesep,'node_res',filesep];
if ~isdir(savedir)
    mkdir(savedir);
end
if ~isdir(savedir)
    errordlg('could not create save dir');
    return
end


    start_dir = pwd;
    clear list
for ii = 1:length(all_dirs_separated)
    noderes_list(ii).res_time = [];
    noderes_list(ii).all_possible = [];
    noderes_list(ii).unresolved_dead_finals = [];
    noderes_list(ii).unresolved_time_existed = [];
    noderes_list(ii).ind_aligned = [];
    noderes_list(ii).ind_ros = [];
	noderes_list(ii).ind_clusters = [];
    
    noderes_list(ii).res_means = [];
	noderes_list(ii).res_mean_of_means = [];
    
    noderes_list(ii).res_std_across_dirs = [];
    noderes_list(ii).res_ste_across_dirs = [];
    
    noderes_list(ii).res_std_all_points = [];
    noderes_list(ii).res_ste_all_points = [];
    
    for i = 1:length(all_dirs_separated{ii})
        cd(all_dirs_separated{ii}{i});
        display(['working on dir ',pwd])
%         analyze_dir;
%     analyze_dir_new;
%     linked_shrinking_edges_avgs(all_dirs_separated{ii}{i})
   if isempty(dir('node_res_data.mat'))
       display('running ''node_analysis_script_alignment''');
%         node_analysis_script;
%         noderes_list(ii) = node_analysis_script_alignment(noderes_list(ii));
        node_analysis_script_alignment
   end
        load('node_res_data')
        noderes_list(ii).res_time = [noderes_list(ii).res_time,res_time];
        noderes_list(ii).all_possible = sum([noderes_list(ii).all_possible,all_possible]);
        noderes_list(ii).unresolved_dead_finals = [noderes_list(ii).unresolved_dead_finals, unresolved_dead_finals];
        noderes_list(ii).unresolved_time_existed = [noderes_list(ii).unresolved_time_existed, unresolved_time_existed];
        noderes_list(ii).ind_aligned = [noderes_list(ii).ind_aligned, ind_aligned];
        noderes_list(ii).ind_ros = [noderes_list(ii).ind_ros, ind_ros];
        noderes_list(ii).ind_clusters = [noderes_list(ii).ind_clusters, ind_clusters];
        noderes_list(ii).res_means = [noderes_list(ii).res_means, mean(res_time)];
        
        if any(res_time<0)
            display('something wrong!')
        end
    end
    
    noderes_list(ii).res_mean_of_means = mean(noderes_list(ii).res_means);
    noderes_list(ii).res_std_across_dirs = std(noderes_list(ii).res_means);
    noderes_list(ii).res_ste_across_dirs = std(noderes_list(ii).res_means)/sqrt(length(noderes_list(ii).res_means));
    noderes_list(ii).res_std_all_points = std(noderes_list(ii).res_time);
    noderes_list(ii).res_ste_all_points = std(noderes_list(ii).res_time)/sqrt(length(noderes_list(ii).res_time));
end


    dirinfolist.all_dirs_separated = all_dirs_separated;
    dirinfolist.leg_txt = leg_txt;
    
    cd(start_dir);
    ftypes = input_settings.output_filetypes;
    display_noderes(noderes_list, dirinfolist, savedir, cntrl_ind, ftypes);

