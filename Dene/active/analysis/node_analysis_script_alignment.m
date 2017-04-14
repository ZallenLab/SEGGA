function outlist = node_analysis_script_alignment(list)
% This is for compiling lists of node resolution times
%  input list must take this form
% list.restime  these are the resolution times
% list.all_possible these are all possible that could have resolved


if nargin < 1 || isempty(list)
    outlist.res_time = [];
    outlist.all_possible = [];
    outlist.unresolved_dead_finals = [];
    outlist.unresolved_time_existed = [];
    outlist.ind_aligned = [];
end
    
    load('analysis', 'misc', 'seq', 'clusters','data');
    seq = update_seq_dir(seq);
    data = seq2data(seq);
    load('shrinking_edges_info_new', 'edges_global_ind', 'shrink_times', 'reborn');
    load('aligned_edges_info_linkage','v_linked')
    load('timestep');
    load('shift_info');
    
    [res_time followed] = node_analysis(seq, data, misc, timestep);
    temp_ind = false(size(followed));
    temp_ind(edges_global_ind) = true;
    temp_times = inf(size(temp_ind));
    temp_times(edges_global_ind) = shrink_times;
%     temp_times(edges_global_ind) = misc.dead_final(edges_global_ind);
    ind = temp_ind & followed;
    temp_times = temp_times(ind);
    res_time = res_time(ind);
    if any(res_time < 0)
        display('node res time is less than zero!!!!!!');
    end
    ind_linear = find(ind);
    
    res_time((res_time - temp_times) <0) = inf;
    
    
    display('checking which edges are aligned');
    %%%%%% Finding the indices of Aligned Edges
    scope = 20;  %number of frames to look back
    aligned_time_thresh = 0.2; %number of frames that must be aligned
    
    ind_aligned = zeros(1,length(ind_linear));
    for i = 1:length(ind_linear)
        
%             max(1, res_time(i) - scope -1):(res_time(i)-1)
            ind_aligned(i)  = sum(v_linked(:,ind_linear(i)))/sum(data.edges.selected(:,ind_linear(i)))>aligned_time_thresh;
    end
    
    
	display('checking which edges are in clusters data set');
    ind_clusters = zeros(1,length(ind_linear));
    
    for i = 1:length(ind_linear);
        ind_clusters(i) = any([clusters(:).edges]==ind_linear(i));
    end
    
    display('checking which edges are in rosettes');
    ind_ros = zeros(1,length(ind_linear));
	%%%%%% Finding the indices of rosette Edges
	
    for i = 1:length(ind_linear)
        if ind_clusters(i) == 1
            clusterind = 0;
            searchind = 1;
            while clusterind == 0
                if any(clusters(searchind).edges==ind_linear(i))
                    clusterind = searchind;
                end

                if searchind >= length(clusters) && clusterind == 0
                    display(['did not find cluster for shrinking edge (',num2str(ind_linear(i)),')']);
                    return
                end
                searchind = searchind + 1;
            end
            if length(clusters(clusterind).cells) > 4
                    ind_ros(i) = 1;
            end
        end
    end
    
    
    
    
    
    
    
    unresolved_ind_aligned = ind_aligned(isinf(res_time));
    unresolved_times = temp_times(isinf(res_time));
    unresolved_dead_finals = (unresolved_times+shift_info)* timestep / 60;
    unresolved_time_existed = (length(seq.frames(:))-unresolved_times)* timestep / 60;
    
    ind_aligned = ind_aligned(~isinf(res_time));
    ind_clusters = ind_clusters(~isinf(res_time));
    ind_ros = logical(ind_ros(~isinf(res_time)));
    temp_times = temp_times(~isinf(res_time));
    res_time = res_time(~isinf(res_time));
    res_time = (res_time - temp_times)* timestep / 60; %in minutes
    
    if any(res_time < 0)
        display('node res time is less than zero!!!!!!');
        display('...fixing');
        res_time = res_time(res_time > 0);
    end
    

    
    frac_resolved = length(res_time) / nnz(ind); 
    all_possible = nnz(ind);
    mean_res_time = mean(res_time);
    median_res_time = median(res_time);
    std_res_time = std(res_time);
    num_followed = nnz(ind);
    [res_time_hist] = hist(res_time, 0:0.25:40);
    res_time_hist = res_time_hist / sum(res_time_hist);
    
    t1_res_times = res_time(~ind_ros);
    ros_res_times = res_time(ind_ros);
    
	if any(res_time < 0)
        display('node res time is still less than zero --- need to fix !!');
    end
    
    save('node_res_data', 'frac_resolved', 'mean_res_time', ...
        'median_res_time', 'std_res_time', 'num_followed',...
        'res_time_hist','res_time','all_possible',...
        'unresolved_dead_finals','unresolved_time_existed',...
        'ind_aligned','unresolved_ind_aligned',...
        'ind_ros','ind_clusters','t1_res_times','ros_res_times');
    
    
if nargin > 0 && ~isempty(list)
    outlist.res_time = [list.res_time,res_time];
    outlist.all_possible = sum(nonzeros([list.all_possible,all_possible]));
    outlist.unresolved_dead_finals = [list.unresolved_dead_finals, unresolved_dead_finals];
    outlist.unresolved_time_existed = [list.unresolved_time_existed, unresolved_time_existed];
    outlist.ind_aligned = [list.ind_aligned, ind_aligned];
end

