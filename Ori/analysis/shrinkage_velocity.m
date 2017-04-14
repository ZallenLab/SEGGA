function [t_shrink t_long reborn edges_list cells_sel] = shrinkage_velocity(data, misc, ...
    t_start, t_end, len_thresh, time_thresh, dead_num_points_criteria, regrow_len_thresh)
%edges_list = list of edges found to shrink and reported about
%t_shrink(i) = time of death or edge(edges_list(i)) .
%t_long(i) = last timepoint in which edge(edges_list(i)) was longer than len_thresh

% shrinkage_velocity(data, misc, t_start, t_end, 8, time_window2, [], 6);


if nargin < 3 || isempty(t_start)
    t_start = 1;
end
if nargin < 4 || isempty(t_end)
    t_end = size(data.edges.len, 1);
end
if nargin < 5 || isempty(len_thresh)
    len_thresh = 12;
end
if nargin < 6 || isempty(time_thresh)
    time_thresh = 20;
end


%For how may timepoints an edge must be gone to be considered dead
if nargin < 7 || isempty(dead_num_points_criteria)
    dead_num_points_criteria = 5;
end
if nargin < 8 || isempty(regrow_len_thresh)
    regrow_len_thresh = 8;
end
short_len_thresh = 2;

%find edges that are:
%   1. longer than len_thresh at least once while selected
ind = any(data.edges.len > len_thresh & data.edges.selected);
%   2. selected for at least time_thresh time point
ind = ind & (sum(data.edges.selected) > time_thresh);

%   3. do not exist after being longer than len_thresh while the cells they separate are still selected
% len = smoothen(data.edges.len(:, ind));

% DLF Edit
% debug
% removed smoothening
len = data.edges.len(:, ind);

% len(~data.edges.selected(:, ind)) = nan;
ind2 = find(ind);
edges_found = false(size(ind2));
reborn = edges_found;
t_long = zeros(size(edges_found));
t_shrink = t_long;
cells_sel = false(size(data.edges.len, 1), length(ind2));
for i = 1:length(ind2)
    cells = misc.edges_by_cells(ind2(i), :);
    cells_sel_times = all(data.cells.selected(:, cells), 2);
    cells_exist_times = all(data.cells.area(:, cells) > 0, 2);
    
    time_span = t_start:t_end;
    t_first_life_as_long = find(len(time_span, i) > len_thresh & cells_exist_times(time_span), 1);
    t_first_life_as_long = t_first_life_as_long + time_span(1) - 1;

    ed_ex = find(len(time_span, i), time_thresh);
    ed_ex = ed_ex + time_span(1) - 1;
    t_first_life_as_long = max(t_first_life_as_long, ed_ex(time_thresh));
    if isempty(t_first_life_as_long)
        continue
    end
    
    time_span = t_first_life_as_long:t_end;
    t_dead = find(len(time_span, i) == 0 & cells_exist_times(time_span));
    t_dead = t_dead + time_span(1) - 1;
    t_very_short = find(len(time_span, i) < short_len_thresh & cells_exist_times(time_span));
    t_very_short = t_very_short + time_span(1) - 1;
    
    if isempty(t_dead)
        continue
    end
    
    time_span = t_start:t_dead(1);
    t_last_life_as_long = find(len(time_span, i) > len_thresh & cells_exist_times(time_span), 1, 'last');
    t_last_life_as_long = t_last_life_as_long + time_span(1) - 1;
    
    if length(t_dead) < dead_num_points_criteria
        continue
    end
    
    edges_found(i) = true;
    
    time_span = t_last_life_as_long:t_end;
    t_last_life = find(len(time_span, i) > 0 & cells_exist_times(time_span), 1, 'last');
    t_last_life = t_last_life + time_span(1) - 1;
    if t_last_life > t_dead(dead_num_points_criteria)
        t_shrink(i) = t_dead(2);
        if max(len(t_shrink(i):t_last_life, i)) > regrow_len_thresh
            reborn(i) = true;
        end
    else
        t_shrink(i) = t_last_life + 1;
    end
    t_long(i) = t_last_life_as_long;
    if length(t_very_short) > 5
        t_shrink(i) = min(t_shrink(i), t_very_short(6));
    end
    if ~all(cells_sel_times(max(t_start, t_shrink(i) - 10):min(t_end, t_shrink(i)+1)))
        edges_found(i) = false;
    end
    cells_sel(:, i) = cells_sel_times;
end
edges_found(t_shrink - t_long < 3) = false;

edges_list = ind2(edges_found);
t_long = t_long(edges_found);
t_shrink = t_shrink(edges_found);
reborn = reborn(edges_found);
cells_sel = cells_sel(:, edges_found);