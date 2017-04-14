
function analyze_dir_new(directory,SEGGA_call) 

load('timestep')
num_frms_for_anal = max(round(1200/timestep),80);
time_window = max(round(150/timestep),8);
time_window2 = max(round(300/timestep),16);
min_edge_length = 8;
min_edge_length2 = 5; %clusters whose shrinking edges are never longer 
                      %than min_edge_length2 are removed.

if nargin < 1 || isempty(directory)
    directory = pwd;
end

if nargin < 2 || isempty(SEGGA_call)
    SEGGA_call = false;
end

cd(directory);
seq = load_dir(directory);

    seq.t = seq.frames(1).t;
    seq.z = seq.frames(1).z;
    seq.img_num = seq.frames_num(seq.t, seq.z);
    [seq.frames.cells] = deal([]);
    [seq.frames.edges] = deal([]);
% load('analysis', 'seq')
% seq= update_seq_dir(seq);


%     seq = load_dir(pwd);
%     
    for iii = 1:length(seq.frames)
        temp_geom_check = seq.frames(iii).cellgeom.edgecellmap;
        temp_geom_class = whos('temp_geom_check');
        temp_geom_class = temp_geom_class.class;
        if all(strcmp(temp_geom_class,'int')) || all(strcmp(temp_geom_class,'int16'))
            display('fixing geoms for this dir');
            fix_geoms_dir
            display('geoms fixed.');
            seq = load_dir(pwd);
        end
    end

t_start = 1;
t_end = length(seq.frames);
if length(dir('time_points_to_anal'))
    load('time_points_to_anal');
end
    
load('poly_seq');
disp('data')
data = seq2data(seq);
data.edges.angles((data.edges.len(:) == 0)) = nan;
disp('misc')
misc = find_clusters_by_edges_init_vars(seq, data, [], time_window, min_edge_length);
disp('clusters')
clusters = find_clusters_by_edges(seq, data, time_window, min_edge_length2, misc);
clusters = keep_clusters_with_selected_dying_edges(clusters, data, misc);
clusters = remove_clusters_with_faulty_cells(clusters, data);
clusters = remove_clusters_with_only_short_edges(clusters, data, misc, min_edge_length, min_edge_length2);
clusters = clusters_life_times(clusters, data, misc, time_window);
clusters = clusters([clusters.s] < [clusters.e]);
% time_thresh = 40;
%clusters = keep_only_clusters_selected_for_a_long_time(clusters, data, time_thresh);
disp('clusters_backwards');
clusters_backwards = create_reverse_clusters(time_window, min_edge_length,min_edge_length2);

disp('vertical linkage')
v_linkage = v_linkage_over_time(seq, data, misc.all_links, 15, 0);
save('v_link', 'v_linkage');

disp('saving: ''seq'', ''data'', ''misc'', ''clusters'', ''clusters_backwards''');
save('analysis', 'seq', 'data', 'misc', 'clusters','clusters_backwards');
disp('measurements')
load('shift_info');


if length(dir('cells_for_elon.mat'))
    load('cells_for_elon');
    cells_to_analyze = cells;
    [hor ver num_cells L1 L2 angle] = calc_embryo_elon(seq, data, [], [], cells_to_analyze);
    L1_to_L2_ratio = L1./L2;
    hor_to_ver_ratio = hor./ver;
    
    save('elon', 'hor', 'ver', 'num_cells', 'L1','L2', 'angle','L1_to_L2_ratio','hor_to_ver_ratio');
    
else
    [hor ver num_cells L1 L2 angle] = calc_embryo_elon(seq, data, shift_info, num_frms_for_anal);
    L1_to_L2_ratio = L1./L2;
    hor_to_ver_ratio = hor./ver;
    save('elon', 'hor', 'ver', 'num_cells',  'L1','L2', 'angle','L1_to_L2_ratio','hor_to_ver_ratio');

end

avrgs = seq2averages(seq, data, any(data.cells.selected), shift_info, num_frms_for_anal);
save('avrgs', 'avrgs');

get_area_deriv(seq,data);

[binned_hists bins] = edge_length_vs_angle(data);
save('angle_hists', 'binned_hists', 'bins')

[avg_diff fns] = diff_indi_start_to_end(seq, data, -shift_info);
save('corrs_over_time', 'avg_diff', 'fns')


measurements = odds_and_ends(data, seq, [], [], time_window);
save('measurements', 'measurements');


% shrinkage_velocity(data, misc, ...
%     t_start, t_end, len_thresh,...
%     time_thresh, dead_num_points_criteria, regrow_len_thresh)

[shrink_times len_thresh_times reborn edges_global_ind cells_sel_times_sh] = ...
    shrinkage_velocity(data, misc, t_start, t_end, 8, time_window2, [], 6);

[aligned_len_sh aligned_ang_sh aligned_sel_sh] = ...
    align_shrinking_edges(data, edges_global_ind, shrink_times, cells_sel_times_sh);

[aligned_ang_by_cell_sh] = ...
    align_shrinking_edges_by_cell(seq, misc, data, edges_global_ind, shrink_times);

data = invert_data_time(data);
[growth_times len_thresh_times_growing reshrink edges_global_ind_growing cells_sel_times_gr] = ...
    shrinkage_velocity(data, misc, length(seq.frames) - t_end + 1, ...
    length(seq.frames) - t_start + 1, 5, time_window2, [], 8);

[aligned_len_gr aligned_ang_gr aligned_sel_gr] = ...
    align_shrinking_edges(data, edges_global_ind_growing, growth_times, cells_sel_times_gr);


[aligned_ang_by_cell_gr] = ...
    align_shrinking_edges_by_cell(seq, misc, data, edges_global_ind_growing, growth_times);

growth_times = length(seq.frames) - growth_times + 1;

len_thresh_times_growing = length(seq.frames) - len_thresh_times_growing + 1;

save('shrinking_edges_info_new', ...
    'shrink_times', 'len_thresh_times', 'reborn', 'edges_global_ind', 'cells_sel_times_sh', ...
    'aligned_len_sh', 'aligned_ang_sh', 'aligned_ang_by_cell_sh','aligned_sel_sh', ...
    'growth_times', 'len_thresh_times_growing', 'reshrink', 'edges_global_ind_growing', 'cells_sel_times_gr', ...
    'aligned_len_gr', 'aligned_ang_gr', 'aligned_ang_by_cell_gr','aligned_sel_gr');

data = invert_data_time(data);


aligned_ang_sh = mod(aligned_ang_sh, 180);
aligned_ang_sh = 90 - abs(90 - aligned_ang_sh);    
aligned_ang_gr = mod(aligned_ang_gr, 180);
aligned_ang_gr = 90 - abs(90 - aligned_ang_gr);
len_sh_mean = nan(size(aligned_len_sh, 1), 1);
len_sh_std = len_sh_mean;
ang_sh_mean = len_sh_mean;
ang_sh_std = len_sh_mean;

len_gr_mean = len_sh_mean;
len_gr_std = len_gr_mean;
ang_gr_mean = len_gr_mean;
ang_gr_std = len_gr_mean;
    for i = 1:size(aligned_len_sh, 1)
        sel = aligned_sel_sh(i, :) > 0;
        if nnz(sel) > time_window %Isn't nnz(sel) the number of selected edges at 
%             the aligned timepoint i, rather then the number of selecetd frames?
            len_sh_mean(i) = mean(aligned_len_sh(i, sel));
            len_sh_std(i) = std(aligned_len_sh(i, sel));
            ang_temp = aligned_ang_sh(i, sel);
            ang_temp = ang_temp(~isnan(ang_temp));
            ang_sh_mean(i) = mean(ang_temp);
            ang_sh_std(i) = std(ang_temp);
        end
        sel = aligned_sel_gr(i, :) > 0;
        if nnz(sel) > time_window 
            len_gr_mean(i) = mean(aligned_len_gr(i, sel));
            len_gr_std(i) = std(aligned_len_gr(i, sel));
            ang_temp = aligned_ang_gr(i, sel);
            ang_temp = ang_temp(~isnan(ang_temp));
            ang_gr_mean(i) = mean(ang_temp);
            ang_gr_std(i) = std(ang_temp);
        end
    end
save('aligned_edges_info', ...
    'len_sh_mean', 'len_sh_std', 'ang_sh_mean', 'ang_sh_std', ...
    'len_gr_mean', 'len_gr_std', 'ang_gr_mean', 'ang_gr_std')



%%%%%%%%%%%%%%%% new topological measurements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    load('cells_for_t1_ros')
    both = intersect(edges_global_ind, edges_global_ind_growing, 'legacy');
    edges_global_ind = setdiff(edges_global_ind, both, 'legacy');
    edges_global_ind_growing = setdiff(edges_global_ind_growing, both, 'legacy');

    if exist('only_internal_t1_ros_cells') && only_internal_t1_ros_cells
        new_map = new_edgecellmap(seq.frames(1).cellgeom);
        new_map = new_map(all(~isnan(new_map), 2), :);
        nmap = false(length(seq.frames(1).cellgeom.circles(:,1)));
        nmap(sub2ind(size(nmap), new_map(:, 1), new_map(:, 2))) = 1;
        nmap = nmap | nmap';
        other_cells = true(1, size(seq.frames(1).cellgeom.circles, 1));
        other_cells(find(cells)) = false;
        other_cells = find(other_cells);
        cells(sum(nmap(other_cells, :)) > 1) = false;
    end

    cells_to_anal = cells;
    
    bins = 0:10;
    cells_ros_hist = zeros(size(seq.cells_map)); %from clusters
    cells_t1_hist = cells_ros_hist; %from clusters
    cells_gain_hist = cells_ros_hist; %from clusters
    cells_rotate_start_hist = cells_ros_hist; %from rotation info
	cells_rotate_end_hist = cells_ros_hist; %from rotation info
    
    cells_direct_total_hist = cells_ros_hist; %from shrinking/growing edges
    cells_direct_gain_hist = cells_ros_hist; %from shrinking/growing edges
    
    ang_bin_step = 15;
    ang_bins = 0:ang_bin_step:(90-ang_bin_step);
    edges_ang_hist = zeros(length(ang_bins), size(cells_ros_hist, 2));
    edges_ang_hist_with_time = zeros(length(ang_bins), size(cells_ros_hist,1),size(cells_ros_hist,2));
    
    % These are total number of events per cell (no time)
    node_mult_bins = 1:10;
    node_mult_hist = zeros(length(node_mult_bins), size(cells_ros_hist, 2));
    node_mult_hist_passive_included = node_mult_hist;
    
    % These are the node multiplicities of events per cell per time
	node_mult_bins = 1:10;
    node_mult_hist_3D = zeros([size(cells_ros_hist),length(node_mult_bins)]);
    node_mult_hist_passive_included_3D = node_mult_hist_3D; 
    
    for i = 1:length(edges_global_ind)
        time_0 = shrink_times(i);
        cells = global_edges2cells(seq, edges_global_ind(i));
        frames = time_0:length(seq.frames);
        cells_direct_total_hist(frames, cells) = ...
            cells_direct_total_hist(frames, cells) + 1;
    end
    
    for i = 1:length(edges_global_ind_growing)
        time_0 = growth_times(i);
        cells = global_edges2cells(seq, edges_global_ind_growing(i));
        frames = time_0:length(seq.frames);
        cells_direct_gain_hist(frames, cells) = ...
            cells_direct_gain_hist(frames, cells) + 1;
    end
    
    %%%NEW EDGES / NGBRS GAINED
    for i = 1:length(clusters_backwards)
        time_0 = max(1, min(length(seq.frames), round(clusters_backwards(i).f)));
        time_0 = length(seq.frames)-time_0;
        cells = global_edges2cells(seq, clusters_backwards(i).edges);
        
        %check that all cells are in the poly
        poly_check_frames = [max((time_0-1),1):min((time_0+1),length(seq.frames))];
        in_poly_bool = all(data.cells.selected(poly_check_frames,cells));
        if ~in_poly_bool
            display('NGAINED: cluster disregarded due to it being outside of ROI at resolution')
            continue % disregard cluster
        end
            
        
        frames = time_0:length(seq.frames);
        for cell_cnt = 1:length(cells(:))
            cells_gain_hist(frames, cells(cell_cnt)) = ...
                    cells_gain_hist(frames, cells(cell_cnt)) + 1;     
        end
    end
    
    %%%NLOST EVENTS
    for i = 1:length(clusters)
        time_0 = max(1, min(length(seq.frames), round(clusters(i).f)));
        cells = global_edges2cells(seq, clusters(i).edges);
        
        %check that all cells are in the poly
        poly_check_frames = [max((time_0-1),1):min((time_0+1),length(seq.frames))];
        in_poly_bool = all(data.cells.selected(poly_check_frames,cells));
        if ~in_poly_bool
            display('NLOST: cluster disregarded due to it being outside of ROI at formation')
            continue % disregard cluster
        end
        
        frames = time_0:length(seq.frames);
        for cell_cnt = 1:length(cells(:))
            if length(clusters(i).cells) > 4
                cells_ros_hist(frames, cells(cell_cnt)) = ...
                    cells_ros_hist(frames, cells(cell_cnt)) + 1;
            else
                cells_t1_hist(frames, cells(cell_cnt)) = ...
                    cells_t1_hist(frames, cells(cell_cnt)) + 1;
            end
            
        end
        
        

        cells_passive_included = clusters(i).cells;
        
        %node_mult_hist shows [dims: node multiplicity, cells] how many
        %times a cell was actively involved in a cluster of a given
        %multiplicity
        for cell_cnt = 1:length(cells(:))
            ind_place = length(clusters(i).cells);
            node_mult_hist(ind_place, cells(cell_cnt)) = ...
                 node_mult_hist(ind_place, cells(cell_cnt)) + 1;
        end

            %node_mult_hist_passive shows [dims: node multiplicity, cells] how many
            %times a cell was actively OR passively involved in a cluster of a given
            %multiplicity
        for cell_cnt = 1:length(cells_passive_included)
            node_mult_hist_passive_included(ind_place, cells_passive_included(cell_cnt)) = ...
                 node_mult_hist(ind_place, cells_passive_included(cell_cnt)) + 1;
        end

            %node_mult_hist_3D shows [dims: frame,cells,node multiplicity] how many
            %times a cell was actively involved in a cluster of a given
            %multiplicity, keeping the time dimension
        for cell_cnt = 1:length(cells(:))
            node_mult_hist_3D(frames,cells(cell_cnt),ind_place) = ...
                 node_mult_hist_3D(frames,cells(cell_cnt),ind_place) + 1;
        end

            %node_mult_hist_passive_3D shows [dims: frame,cells,node multiplicity] how many
            %times a cell was actively OR passively involved in a cluster of a given
            %multiplicity, keeping the time dimension
        for cell_cnt = 1:length(cells_passive_included)
            node_mult_hist_passive_included_3D(frames,cells_passive_included(cell_cnt), ind_place) = ...
                 node_mult_hist_3D(frames,cells_passive_included(cell_cnt), ind_place) + 1;
        end
        
        for j = clusters(i).edges
            cells = global_edges2cells(seq, j);
            time_of_death = misc.dead_init(j);
            time_ind = time_of_death - (floor(3*60/timestep):ceil(5*60/timestep));
            time_ind = time_ind(time_ind>0);
            if isempty(time_ind)
                time_ind = 1;
            end
            time_ind = time_ind(data.edges.selected(time_ind, j));
            if isempty(time_ind)
                continue
            end
            edge_ang = data.edges.angles(time_ind, j);
            edge_ang = mod(edge_ang, 180);
            edge_ang = 90 - abs(90 - edge_ang); 
            edge_ang = mean(edge_ang);
            if edge_ang == 90
                edge_ang = length(ang_bins);
            else
                edge_ang = floor(edge_ang/ang_bin_step) + 1;
            end
            
            for cell_cnt = 1:length(cells(:))
                edges_ang_hist(edge_ang, cells(cell_cnt)) = ...
                    edges_ang_hist(edge_ang, cells(cell_cnt)) + 1;

                edges_ang_hist_with_time(edge_ang, frames, cells(cell_cnt))=...
                    edges_ang_hist_with_time(edge_ang, frames, cells(cell_cnt)) + 1;
            end

        end
    end
    
    
    %%%ROTATE EVENTS
    rotating_edge_analysis_v03;
    load rotating_edge_info
    for i = 1:length(dv_to_ap)
        cells = global_edges2cells(seq, dv_to_ap(i));
        time_0 = dv_to_ap_times.last45_going_ap(i);
        time_f = dv_to_ap_times.first_aps(i);
        frames_start = time_0:length(seq.frames);
        frames_end = time_f:length(seq.frames);
        for cell_cnt = 1:length(cells(:))
            cells_rotate_start_hist(frames_start, cells(cell_cnt)) =...
                cells_rotate_start_hist(frames_start, cells(cell_cnt))+ 1;
            cells_rotate_end_hist(frames_end, cells(cell_cnt)) =...
                cells_rotate_end_hist(frames_end, cells(cell_cnt))+ 1;
        end
    end
    
    cells_ros_hist = cells_ros_hist(:, cells_to_anal);
    cells_t1_hist = cells_t1_hist(:, cells_to_anal);
    cells_gain_hist = cells_gain_hist(:, cells_to_anal);
    
    cells_rotate_start_hist = cells_rotate_start_hist(:, cells_to_anal);
	cells_rotate_end_hist = cells_rotate_end_hist(:, cells_to_anal);
    
    cells_direct_gain_hist = cells_direct_gain_hist(:, cells_to_anal);
    cells_direct_total_hist = cells_direct_total_hist(:, cells_to_anal);
    
    edges_ang_hist = edges_ang_hist(:, cells_to_anal);
    edges_ang_hist_with_time = edges_ang_hist_with_time(:, :, cells_to_anal);
    node_mult_hist = node_mult_hist(:, cells_to_anal);
    node_mult_hist_passive_included = node_mult_hist_passive_included(:, cells_to_anal);
    
    
    num_cells = nnz(cells_to_anal);
    n_ros = hist(cells_ros_hist', bins)/num_cells;
    n_t1 = hist(cells_t1_hist', bins)/num_cells;
    n_total = hist(cells_t1_hist' + cells_ros_hist', bins)/num_cells;
    n_gained = hist(cells_gain_hist', bins)/num_cells;
    
    n_rot_start = hist(cells_rotate_start_hist', bins)/num_cells;
    n_rot_end = hist(cells_rotate_end_hist', bins)/num_cells;
    
    n_direct_total = hist(cells_direct_total_hist', bins)/num_cells;    
    n_gained_direct = hist(cells_direct_gain_hist', bins)/num_cells;
    
    n_edges_ang = sum(edges_ang_hist')/num_cells;
    
    n_edges_ang_with_time = sum(edges_ang_hist_with_time,3)/num_cells;
    
     %node_mult_hist shows [dims: node multiplicity, cells] how many
        %times a cell was actively involved in a cluster of a given
        %multiplicity
    n_node_mult = sum(node_mult_hist')/num_cells;
    n_node_mult_passive_included = sum(node_mult_hist_passive_included')/num_cells;
    
    node_mult_hist_3D = node_mult_hist_3D(:,cells_to_anal,:);
    node_mult_hist_passive_included_3D = node_mult_hist_passive_included_3D(:,cells_to_anal,:);
    S = squeeze(sum(node_mult_hist_3D,2));
    n_node_mult_3D = S/num_cells;
    S = squeeze(sum(node_mult_hist_passive_included_3D,2));
    n_node_mult_passive_included_3D = S/num_cells;
    
    perc_node_mult_3D_oneplus = squeeze(sum(node_mult_hist_3D>0,2))/num_cells;
    perc_node_mult_passive_included_3D_oneplus = squeeze(sum(node_mult_hist_passive_included_3D>0,2))/num_cells;
    
	perc_node_mult_3D_twoplus = squeeze(sum(node_mult_hist_3D>1,2))/num_cells;
    perc_node_mult_passive_included_3D_twoplus = squeeze(sum(node_mult_hist_passive_included_3D>1,2))/num_cells;
 

    n_ros = n_ros';
    n_t1 = n_t1';
    n_total = n_total';
    n_gained = n_gained';
    n_rot_start = n_rot_start';
    n_rot_end = n_rot_end';
    n_direct_total = n_direct_total';    
    n_gained_direct = n_gained_direct';
    n_edges_ang = n_edges_ang';
    

    if all(isnan(n_ros))        
        display('missing selected cells for top event analysis');
        return
    end
    num_ros_per_cell = n_ros * bins';
    num_t1_per_cell = n_t1 * bins';
    n_direct_total_per_cell = n_direct_total * bins';
    n_gained_per_cell = n_gained * bins';
    n_gained_direct_per_cell = n_gained_direct * bins';
    n_lost_per_cell = num_ros_per_cell + num_t1_per_cell;
    n_rot_start_per_cell = n_rot_start * bins';
    n_rot_end_per_cell = n_rot_end * bins';

    % *bins is the last step in obtaining the average. We want a
    % distribution, not an avearge for the shrinking edges by angles.
    %     edges_ang_per_cell = n_edges_ang * ang_bins; 
    
    cells_lost_hist = cells_ros_hist + cells_t1_hist;
    lost_gain_cell_mat = accumarray(...
        [cells_gain_hist(end, :); cells_lost_hist(end, :)]' + 1, 1, [11 11]);
    lost_gain_cell_mat = lost_gain_cell_mat/sum(lost_gain_cell_mat(:));
    
    t1_to_ros_ratio = num_t1_per_cell./num_ros_per_cell.*(num_ros_per_cell>0);
    

    save('topological_events_per_cell', 'n_t1', 'n_ros', 'n_total', ...
        'n_direct_total', 'n_gained', 'n_gained_direct',...
        'num_t1_per_cell', 'num_ros_per_cell', 'n_lost_per_cell','n_gained_per_cell',...
        'n_rot_start_per_cell','n_rot_end_per_cell',...
        'n_direct_total_per_cell','n_gained_direct_per_cell',...        
        'bins', 'cells_lost_hist', 'cells_t1_hist', 'cells_ros_hist', ...
        'cells_gain_hist', 'cells_direct_gain_hist',...
        'lost_gain_cell_mat', 'n_edges_ang', 'ang_bins',...
        'n_edges_ang_with_time', 'n_node_mult', 'n_node_mult_passive_included',...
        'node_mult_hist','node_mult_hist_passive_included',...
        't1_to_ros_ratio', 'cells_to_anal');
    
    save('topological_events_per_cell_extras', 'n_node_mult', 'n_node_mult_passive_included',...
         'node_mult_hist_3D','node_mult_hist_passive_included_3D',...
         'n_node_mult_3D','n_node_mult_passive_included_3D',...
         'perc_node_mult_3D_oneplus','perc_node_mult_passive_included_3D_oneplus',...
         'perc_node_mult_3D_twoplus','perc_node_mult_passive_included_3D_twoplus');
         
    
    addon_topo_measurements();
    linked_shrinking_edges_avgs;
    where_shrinks_go;
    shrinking_edge_angles_new;
%     node_analysis_script;
    node_analysis_script_alignment;

   
    
    display('finished');
    
    
