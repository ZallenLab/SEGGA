function clusters = clusters_life_times(clusters, data, misc, ...
    time_window, min_duration, threshold)
if nargin < 5 || ismepty(min_duration)
    min_duration = 15;
end
if nargin < 6 || ismepty(threshold)
    threshold = 0.15; %minimum slope for find_start_of_decrease
end

for i = 1:length(clusters)
    time_0 = mid_timepoint_of_clusters(clusters(i), misc, ...
        length(data.edges.len(:, 1)));
    s = start_time_of_cluster(clusters(i), data, misc, ...
        threshold, time_0, min_duration);
    e = end_time_of_cluster(clusters(i), data, misc, threshold, ...
        time_0, min_duration, time_window);
    f = formation_of_cluster(clusters(i), misc);
    clusters(i).e = e;
    clusters(i).s = s;
    clusters(i).time_0 = time_0;
    clusters(i).f = f;
end

function f = formation_of_cluster(cl, misc)
f = mean(nonzeros([misc.dead_init(cl.edges) misc.dead_final(cl.edges)]));
 

function time_0 = mid_timepoint_of_clusters(cl, misc, num_frames)
e = nonzeros(misc.edge_breakup_init(cl.edges));
e = e(~isinf(e));
if isempty(e)
    e = length(num_frames);
end
time_0 = (mean(nonzeros(misc.dead_init(cl.edges))) + mean(e))/2; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = end_time_of_cluster(cl, data, misc, threshold, ...
    t0, min_duration, time_window)
sep_edges = nonzeros(misc.sep_edges(cl.edges));
edges_ind = find(misc.sep_edges(cl.edges));
% dead_list = find(misc.dead_init);
% inv_dead_list(dead_list) = 1:length(dead_list);
% sep_touching = misc.sep_edge_touching_cells_of_edge(:, inv_dead_list(cl.edges(find(sep_edges))));

len = data.edges.len(:, sep_edges);

t = [];

if any(sep_edges)
    
    breakup_times = misc.edge_breakup_final(cl.edges(edges_ind));
    breakup_times(isinf(breakup_times)) = length(len(:, 1));
    breakup_times(breakup_times == 0) = 1;
    for i = 1:length(breakup_times)
        len(1:breakup_times(i), i) = 0;
    end
%invert time in len and reuse find_start_of_increase;
    len = len(end:-1:1, :);


    ts = find_start_of_decrease(len, misc.dead_init(cl.edges(edges_ind)), threshold);
    [ts, ts_ind] = min(nonzeros(ts)) ;

    %re-invert time;
    t = length(len(:, 1)) - ts + 1;
    last_time_sel = find(data.edges.selected(:, sep_edges(ts_ind)), 1, 'last');
    
%     %make sure end time is before the edge get out the field of view
%     t = min(t, last_time_sel);
end
if isempty(t);
    ts = all(data.cells.selected(:, cl.cells) >0, 2);
    t = find(ts, 1, 'last');
end
linked_t = linked_are_alive_final(cl, data, misc, time_window);
% t = min(t, linked_t);
t = linked_t;

%make sure the end time is at least min_duration away from t0;
t = max(t, t0 + min_duration);
t = round(t);

%make sure all cells are in view
ts = find(all(data.cells.area(:, cl.cells) > 0, 2), 1, 'last');
if ~isempty(ts)
    t = min(t, ts);
else
    t = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = linked_are_alive_final(cl, data, misc, time_window)
le = faster_setdiff(cl.all_edges, cl.edges, length(data.edges.len(1, :)));
le = only_spurring_edges(le, cl.all_edges, misc);
res_time = max(misc.dead_init(cl.edges));
le_alive_after = le(any(data.edges.len(res_time:end, le) > 0));
ts = all(data.edges.len(res_time:end, le_alive_after), 2);
ts(1) = 0;
pos = find_begining_of_block_in_vec(~ts, time_window);
t = find(~all(data.edges.len((res_time+pos-1):end, le_alive_after), 2), 1);
if isempty(t)
    t = inf;
else
    t = t + res_time + pos - 2;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = edges_linked_for_good_time(edge1, edge2, misc, data)
t_on = false(size(data.edges.len(:, 1)));
t_on = t_on | linked_times_two_edges(misc.linked1, edge1, edge2);
t_on = t_on | linked_times_two_edges(misc.linked2, edge1, edge2);
t_on = t_on | linked_times_two_edges(misc.linked1, edge2, edge1);
t_on = t_on | linked_times_two_edges(misc.linked2, edge2, edge1);

t_on(any(data.edges.len(:, [edge1 edge2]) == 0, 2)) = 1;

if ~any(t_on(:))
    t = 0;
    return
end
    
t = find(t_on(1:min(misc.dead_final([edge1 edge2]))) == 0, 1, 'last');
if isempty(t)
    t = 1;
end

function t = linked_times_two_edges(links, edge1, edge2)
ind = links(edge1).edges == edge2;
if any(ind)
    t = links(edge1).on(:, ind);
else
    t = false(size(links(edge1).on(:, 1)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = edges_form_a_chain_time(edges, misc, data)
%Find the last time point in which more than two edges are connected to at
%most one other edge. I shold check if this is actually faster than
%computing the connected components and findnig the time point when there 
%is only one component.
frms = 1:max(misc.dead_final(edges));
num_linked = zeros(frms(end), length(edges));
for cnt_i = 1:length(edges)
    i = edges(cnt_i);
    ind = ismember(misc.all_links(i).edges, edges, 'legacy');
    num_linked(:, cnt_i) = sum(misc.all_links(i).on(frms, ind), 2);
    num_linked(data.edges.len(frms, i) == 0, cnt_i) = 2; %when edges are dead, 
    %don't take them into considerations when counting links.
end
ts = sum(num_linked < 2, 2);
t = find(ts > 2, 1, 'last');
if isempty(t)
    t = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = start_time_of_cluster(cl, data, misc, threshold, t0, min_duration)

ts = find_start_of_decrease(data.edges.len(:, cl.edges), ...
    misc.dead_init(cl.edges), threshold);
t = mean(nonzeros(ts));

linked_t = linked_are_alive_init(cl, data, misc);
t = max(t, linked_t);

%Make sure the start time is at least min_duration frames before t0
t = min(t, t0 - min_duration);

t = round(t);
%make sure the shrinking edges are touching
if length(cl.edges) == 2
    linked_t = edges_linked_for_good_time(cl.edges(1), cl.edges(2), misc, data);
    t = max(t, linked_t);
end
if length(cl.edges) > 2
    linked_t = edges_form_a_chain_time(cl.edges, misc, data);
    t = max(t, linked_t);
end

%make sure all cells are in view
ts = find(all(data.cells.area(:, cl.cells) > 0, 2), 1);
if ~isempty(ts)
    t = max(t, ts);
else
    t = inf;
end


function u = faster_setdiff(a, b, max_val)
u = false(1, max_val);
u(a) = true;
u(b) = false;
u = find(u);

function le = only_spurring_edges(le, all_edges, misc)
%remove from le edges that are connected on both sides to edges from
%all_edges
ind = true(size(le));
for cnt_i = 1:length(le)
    i = le(cnt_i);
    if any(ismember(misc.linked1(i).edges, all_edges, 'legacy')) && ...
            any(ismember(misc.linked2(i).edges, all_edges, 'legacy'))
        ind(cnt_i) = false;
    end
end
le = le(ind);

function t = linked_are_alive_init(cl, data, misc)
%finds and returns t, the time point when (relevant) edges in the clusters are
%all alive for the first time.
le = faster_setdiff(cl.all_edges, cl.edges, length(data.edges.len(1, :)));
%take into account only edges that on one end are not connected to the
%cluster in any way.
le = only_spurring_edges(le, cl.all_edges, misc);
res_time = max(misc.dead_init(cl.edges));
le_alive_before = le(any(data.edges.len(1:res_time, le) > 0));
t = find(all(data.edges.len(:, le_alive_before), 2), 1);
if isempty(t)
    t = 0;
end
for i = le_alive_before
    ts = first_connection(i, cl.edges, misc);
    if ~isempty(ts)
        t = max(ts, t);
    end
end

function t = first_connection(e, edges, misc)
ind = ismember(misc.all_links(e).edges, edges, 'legacy');
if ~any(ind)
    t = inf;
    for j = edges
        ind = misc.all_links(j).edges == e;
        ts = find(misc.all_links(j).on(:, ind), 1);
        if ~isempty(ts)
            t = min(t, ts);
        end
    end
    if isinf(t)
        t = 0;
    end
else
    t = find(any(misc.all_links(e).on(:, ind)), 1);
end

function times = find_start_of_decrease(len, dead_init, threshold)

signum = -sign(threshold + deriv(len));
signum(len==0) = 0;
for i = 1:length(dead_init)
    cs = cumsum(signum(dead_init(i):-1:1, i));
    cs = cs(end:-1:1);
    cs(end+1:length(len)) = cs(end);
    [max_val times(i)] = max(cs + len(:, i));
end
