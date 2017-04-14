function [aligned_len aligned_ang aligned_sel aligned_add] = ...
    align_shrinking_edges(data, edges_list, time_of_death, ...
                          cells_sel_times, additional_data)
% This function aligns edges info and is to be used with shrinkage_velocity
% as follows:
% [shrink_times len_thresh_times reborn edges_global_ind, ...
% cells_sel_times_sh] = shrinkage_velocity(data, misc, t_start, t_end);
% [aligned_len_sh aligned_ang_sh aligned_sel_sh] = ...
% align_shrinking_edges(data, edges_global_ind, shrink_times, cells_sel_times_sh);
sel = data.edges.selected(:, edges_list);
aligned_len = nan(size(sel));
aligned_ang = nan(size(sel));
aligned_sel = nan(size(sel));

if nargin > 4 && ~isempty(additional_data)
    if iscell(additional_data)
        for j = 1:length(additional_data)
            aligned_add{j} = nan(size(sel));
        end
    else
        aligned_add = nan(size(sel));
    end
end
    

if isempty(edges_list)
    return
end
len = (data.edges.len(:, edges_list));
len(len == 0) = nan;
len = smoothen(len);
len(isnan(len) & cells_sel_times) = 0;
ang = data.edges.angles(:, edges_list);
for i = 1:length(edges_list)
    first_sel = find(sel(:, i), 1);
    aligned_len(1:(time_of_death(i) - first_sel + 1), i) = len((time_of_death(i)):-1:first_sel, i);
    aligned_ang(1:(time_of_death(i) - first_sel + 1), i) = ang((time_of_death(i)):-1:first_sel, i);
    aligned_sel(1:(time_of_death(i) - first_sel + 1), i) = cells_sel_times((time_of_death(i)):-1:first_sel, i);
    if nargin > 4 && ~isempty(additional_data)
        if iscell(additional_data)
            for j = 1:length(additional_data)
                aligned_add{j}(1:(time_of_death(i) - first_sel + 1), i) = ...
                    additional_data{j}((time_of_death(i)):-1:first_sel, i);
            end
        else
            aligned_add(1:(time_of_death(i) - first_sel + 1), i) = ...
                additional_data((time_of_death(i)):-1:first_sel, i);
        end
    end
end
