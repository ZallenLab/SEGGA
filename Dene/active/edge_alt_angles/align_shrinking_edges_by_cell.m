function [aligned_ang_by_cell] = ...
    align_shrinking_edges_by_cell(seq, misc, data, edges_list, time_of_death)
% This function aligns edges info and is to be used with shrinkage_velocity
% as follows:
% [shrink_times len_thresh_times reborn edges_global_ind, ...
% cells_sel_times_sh] = shrinkage_velocity(data, misc, t_start, t_end);
% [aligned_len_sh aligned_ang_sh aligned_sel_sh] = ...
% align_shrinking_edges(data, edges_global_ind, shrink_times, cells_sel_times_sh);
sel = data.edges.selected(:, edges_list);
aligned_ang_by_cell = nan(size(sel));




if isempty(edges_list)
    return
end


ang_by_cell = edge_ang_by_cells(edges_list, seq, misc);

for i = 1:length(edges_list)
    first_sel = find(sel(:, i), 1);
    
    aligned_ang_by_cell(1:(time_of_death(i) - first_sel + 1), i) = ang_by_cell((time_of_death(i)):-1:first_sel, i);
    
end
