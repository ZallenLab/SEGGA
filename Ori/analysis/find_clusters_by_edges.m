function clusters = find_clusters_by_edges(seq, data, time_window, min_edge_length, misc)
if ~isempty(misc)
    fn = fieldnames(misc);
    for i = 1:length(fn)
        eval([fn{i} ' = misc.' fn{i} ';']);
    end
end
    
num_frms = length(seq.frames);

clusters = [];
edges_done = false(size(dead_init));

shrinking_e = find(dead_init > 0);
[dummy sort_ind] = sort(sep_times(shrinking_e));
shrinking_e = shrinking_e(sort_ind);
for i = shrinking_e
    if edges_done(i)
        continue
    end
    edges_touched = [];
    cluster_breakup = inf;
    [new_cluster_edges edges_touched edges_done] = ...
        add_edge_to_cluster_depth_first(i, data, time_window, min_edge_length, ...
        dead_init, dead_final, edge_breakup_init, edge_breakup_final, ...
        num_frms, linked1, linked2, all_links, sep_times, ...
        cells_of_edge_touching, sep_edges, born_init, cluster_breakup,...
        edges_done, edges_touched, []);

    if isempty(new_cluster_edges)
        continue
    end
    
    if ~isempty(clusters)
        clusters(end+1).edges = new_cluster_edges;
    else
        clusters(1).edges = new_cluster_edges;
    end
    cells_temp = false(1, length(data.cells.area(1, :)));
    all_cells = edges_by_cells(clusters(end).edges, :);
    cells_temp(nonzeros(all_cells(:))) = true;
    clusters(end).internal_cells = find(cells_temp);

    clusters(end).all_edges = faster_unique(edges_touched, length(data.edges.len(1, :)));
    all_cells = edges_by_cells(edges_touched, :);
    %The nonzeros is used around all_cells in cells_temp because 
    %some linked edges were not listed in edges and therefore don't have a
    %edges_by_cells entry (as currently defined in global_edges2linked_edges).
    cells_temp(nonzeros(all_cells(:))) = true;
    clusters(end).cells = find(cells_temp);
    clusters(end).begin_time = min(dead_init(clusters(end).edges));
    clusters(end).end_time = max(dead_final(clusters(end).edges));

end

clusters = combine_overlapping_clusters(clusters, seq, linked1, linked2, ...
    time_window, dead_init, dead_final, edge_breakup_init, ...
    edge_breakup_final, sep_times);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = are_clusters_the_same(a, b)
flag = false;
if length(a.cells) == length(b.cells) && isequal(a.cells, b.cells)
    flag = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = are_clusters_the_contained(a, b)
flag = false;
c = intersect(a.cells, b.cells, 'legacy');
if length(a.cells) == length(c) || length(b.cells) == length(c)
    flag = true;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clusters = combine_overlapping_clusters(clusters, seq, linked1, linked2, ...
    time_window, dead_init, dead_final, edge_breakup_init, edge_breakup_final, sep_times)
mapmap = false(length(clusters));
for i = 1:(length(clusters)-1)
    for j = (i+1):length(clusters)
%         if are_clusters_connected(clusters(i), clusters(j), linked1, linked2, ...
%                 time_window, dead_init, dead_final, edge_breakup_init, edge_breakup_final, sep_times)
        if are_clusters_the_contained(clusters(i), clusters(j))
            mapmap(i, j) = true;
        end
    end
end

mapmap = mapmap | mapmap';
mapmap(eye(size(mapmap)) > 0) = true;
c = components_of_nghbrs_matrix(mapmap);

touched_clusters = false(1, length(mapmap));
new_clusters = [];
for i = 1:length(c)
    if length(c(i).items) > 1
        if isempty(new_clusters)
            new_clusters = combine_clusters(clusters(c(i).items), seq);
        else
            new_clusters(end+1) = combine_clusters(clusters(c(i).items), seq);
        end
        touched_clusters(c(i).items) = true;
    end
end

clusters = clusters(~touched_clusters);
if ~isempty(new_clusters)
    clusters(end+ (1:length(new_clusters))) = new_clusters;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_cluster = combine_clusters(clusters, seq)
%seq is not essential, can be rewritten without it. It's only used to know
%the size number of edges and cells
new_cluster = clusters(1);
new_cluster.edges = faster_unique([clusters.edges], length(seq.edges_map(1, :)));
new_cluster.all_edges = faster_unique([clusters.all_edges], length(seq.edges_map(1, :)));
new_cluster.internal_cells = faster_unique([clusters.internal_cells], length(seq.cells_map(1, :)));
new_cluster.cells = faster_unique([clusters.cells], length(seq.cells_map(1, :)));
new_cluster.begin_time = min([clusters.begin_time]);
new_cluster.end_time = max([clusters.end_time]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag found_edges new_links_times]= are_edges_really_linked(...
    edge1, edge2, dead_init, dead_final, cluster_breakup_time,...
    all_links, linked1, linked2, time_window, num_frms, data, ...
    edge_breakup_init, edge_breakup_final, sep_times)
%given edge1 and edge2 that are connected to each other, are any of the edges at
%the other end of each edge connected come toghether (ie, do the two edges
%shrink to the same point). Additional criteria in double_exchange.m

found_edges = [];
new_links_times = [];

flag = false;
if dead_final(edge1) == 0 || dead_final(edge2) == 0
    return
end

time_pos = max(1, min(dead_init([edge1 edge2])) - time_window);
time_pos2 = min(dead_final([edge1 edge2]));

%edges_to_check1 are the edges connected to edge1 at the other end to which
%edge2 is connected through to edge1.
edges_to_check1 = find_which_edges_to_check(edge1, edge2, ...
    linked1, linked2, all_links, time_pos, time_pos2);

%edges_to_check2 are the edges connected to edge2 at the other end to which
%edge1 is connected through to edge2.
edges_to_check2 = find_which_edges_to_check(edge2, edge1, ...
    linked1, linked2, all_links, time_pos, time_pos2);

% time_pos2 = max(dead_final(edge1), dead_final(edge2));
% time_pos2 = min(num_frms, time_pos2 + time_window);
% time_pos22 = num_frms;


time_pos = min([dead_final([edge1 edge2]) ...
                edge_breakup_init([edge1 edge2])]);

%time_pos2 defines the time before which edges at opposing ends must meet.
%We define time_pos2 to be the time at which one of the edges breaks up or
%if the breakup time is not well defined for both edges, we take the latest
%dead_final time.
time_pos2 = min(edge_breakup_final([edge1 edge2])); %DEBUG maybe use %(min(edge_breakup_final, sep_times)) and set sep_times to ...????
time_pos2 = max([time_pos2, edge_breakup_init([edge1 edge2])]);
%time_pos2 = min(time_pos2, max(dead_final([edge1 edge2])));
time_pos2 = min(time_pos2, min(nonzeros(sep_times([edge1 edge2]))));
time_pos2 = min(time_pos2, cluster_breakup_time);

if time_pos2 == inf
    time_pos2 = min([max(dead_final([edge1 edge2])) ...
                     sep_times([edge1 edge2])]);
end


time_pos2 = max(time_pos2 + time_window, time_pos + time_window*2);
time_pos2 = min(num_frms, time_pos2);

extra_time_pos = min(dead_init([edge1 edge2]));

[flag found_edges new_links_times] = double_exchange(linked1, linked2, edge1, edges_to_check1, edge2, ...
        edges_to_check2, time_pos, time_pos2, time_window, num_frms, extra_time_pos);
if ~flag
    return
end

ind = (all_links(edge1).edges == edge2);
time_pos = find(all_links(edge1).on(:, ind), 1, 'last');

%if both edges are alive and kicking after their last contact, they do not
%shrink to the same vertex.
if sum(data.edges.len((time_pos+1):end, edge1) > 0 & data.edges.len((time_pos+1):end, edge2) > 0) > time_window
    flag = false;
    found_edges = [];
    return
end

%redundant
flag = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges_to_check = find_which_edges_to_check(edge1, edge2, ...
    linked1, linked2, all_links, time_pos, time_pos2)
edges_to_check = [];
%find edges connected to the correct end of edge1 (the end to which
%edge2 is not connected);
if any(linked1(edge1).edges == edge2)
    edges_to_check = linked2(edge1).edges;
elseif any(linked2(edge1).edges == edge2)
    edges_to_check = linked1(edge1).edges;
else
    return
end

edges_to_check = keep_only_edges_linked_in_time_range(edge1, ...
    edges_to_check, all_links, time_pos, time_pos2);

%make sure none of the edges is connected to edge1 at one end and to edge2
%at the other end.
keep = true(size(edges_to_check));
for cnt_i = 1:length(edges_to_check)
    i = edges_to_check(cnt_i);
    if (any(linked1(i).edges == edge1) && ...
                    any(linked2(i).edges == edge2)) || ...
       (any(linked2(i).edges == edge1) && ...
                    any(linked1(i).edges == edge2))
        keep(cnt_i) = false;
    end
end
edges_to_check = edges_to_check(keep);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges_to_check = keep_only_edges_linked_in_time_range(edge1, ...
    edges_to_check, all_links, time_pos, time_pos2);
%make sure the candidate edges were connected to edge1 recently before
%edge1 disappeared.
keep = false(size(edges_to_check));
for cnt_i = 1:length(edges_to_check)
    i = edges_to_check(cnt_i);
    ind = all_links(i).edges == edge1; %even though edge1 is connected to 
    %edge i, edge i might be not connected to edge1 becuase of not being 
    %selected at the time of contact. In that case, remove edge i from the
    %candidate list. Also, sometimes edges can touch each other on both ends.
    if ~any(ind) || nnz(ind) > 1
        keep(cnt_i) = false;
    else
        keep(cnt_i) = any(all_links(i).on(time_pos:time_pos2, ind));
    end
end
edges_to_check = edges_to_check(keep);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = are_clusters_connected(a, b, linked1, linked2, time_window, ...
    dead_init, dead_final, edge_breakup_init, edge_breakup_final, sep_times)
flag = false;
time_pos1 = min(edge_breakup_final(a.edges));
time_pos2 = min(edge_breakup_final(b.edges));
for ed1 = a.edges
    for ed2 = b.edges

        %find the time point at which each edge resolves
%         time_pos1 = sep_times(ed1);%node_death(ed1, edge_breakup, dead_final, dead_init);
%         time_pos2 = sep_times(ed2);%node_death(ed2, edge_breakup, dead_final, dead_init);
        
        if ~are_times_overlapping(dead_init(ed1), time_pos1, ...
                dead_init(ed2), time_pos2, 0) %time_window is already incorporated into sep_times
            continue
        end
        
        [node1 one_sided] = how_edges_linked(ed1, ed2, linked1, linked2);
        if ~one_sided
            continue
        end
        [node2 one_sided] = how_edges_linked(ed2, ed1, linked1, linked2);
        if ~one_sided
            continue
        end
        
        flag = edge_connected_to_cluster(linked1, linked2, ed1, node1, b);
        if flag
            return
        end
        flag = edge_connected_to_cluster(linked1, linked2, ed2, node2, a);
        if flag
            return
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function time_pos = node_death(ed, edge_breakup, dead_final, dead_init)
if edge_breakup(ed) > 0
    time_pos = edge_breakup(ed);
else
    time_pos = (dead_final(ed) + dead_init(ed))/2;
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [node1 flag] = how_edges_linked(ed1, ed2, linked1, linked2)
flag = false;
node1 = false;
if any(linked1(ed1).edges == ed2)
    node1 = true; %edge1 is connected to edge2 through the first node of edge1
    flag = true; %edges are connected
end
if any(linked2(ed1).edges == ed2)
    flag = true; %edges are connected
    if node1
        flag = false; %edges touch each other at both ends 
                     %(at different time points, can happen in narrow cells)
    end
    node1 = false; %edge1 is connected to edge2 through the second node of edge1
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = edge_connected_to_cluster(linked1, linked2, edge1, node1, cluster)
if node1
    links1 = linked2(edge1).edges;
else
    links1 = linked1(edge1).edges;
end
% if node2 
%     links2 = linked2(edge2).edges;
% else
%     links2 = linked1(edge2).edges;
% end
flag = are_linked_edges_part_of_cluster(links1, cluster);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = are_linked_edges_part_of_cluster(links1, cluster)
%flag = any(ismember(links1, intersect(cluster.all_edges, links2)));
flag = any(ismember(links1, cluster.all_edges, 'legacy'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_edges = find_edge_in_between(sep_edges, linked1, linked2, edge)
%for every pair of edges listed in sep_edges find all the edges that are
%connected between them. Returns a list of all found edges.
edges = [];
for i = 1:length(sep_edges(:, 1)); %for each pair
    %find how the pair is linked (at which end of the first edge does ...
    %it meet the second edge)
    [node1 one_sided] = how_edges_linked(...
            sep_edges(i, 1), sep_edges(i, 2), linked1, linked2);
    if ~one_sided
        continue
    end
    %list the edges connected to the first edge at the node the second edge
    %is not connected to.
    if node1
        links1 = linked1(sep_edges(i, 1)).edges;
    else
        links1 = linked2(sep_edges(i, 1)).edges;
    end
        
    %for each edge connected to the first edge of the pair, find out if it
    %is connected to the second edge at its other end.
    for j = links1
        if (any(linked1(j).edges == sep_edges(i, 1)) && ...
            any(linked2(j).edges == sep_edges(i, 2))) || ...
           (any(linked2(j).edges == sep_edges(i, 1)) && ...
            any(linked1(j).edges == sep_edges(i, 2)))
            edges = [edges j];
        end
    end
end
new_edges = setdiff(faster_unique(edges, length(linked1)), edge, 'legacy');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = resolved_edge_still_short(ed1, ed2, event_times, ...
    sep_times, edge_breakup_init, time_window)
%checks if the which of event_times is before (to a
%time_window) of the first time in which an edge created in the resolution 
%of either ed1 or ed2 is more than min_edge_length (defined elsewhere 
%(find_clusters_by_edges_init_vars) and can have a different value from 
%the value of min_edge_length that is used in this file).
flag = event_times < max(min(sep_times([ed1 ed2])), ...
    min(edge_breakup_init([ed1 ed2])) + time_window); 
%time_window is already incorporated into sep_times.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cluster_edges edges_touched edges_done cluster_breakup] = ...
    add_edge_to_cluster_depth_first(i, data, time_window, min_edge_length, ...
    dead_init, dead_final, edge_breakup_init, edge_breakup_final, ...
    num_frms, linked1, linked2, all_links, sep_times, ...
    cells_of_edge_touching, sep_edges, born_init, cluster_breakup,...
    edges_done, edges_touched, edges_to_do)

%
%returns a cluster containing edge i
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%edges_done is a logical list of edges that were already visited and should
%not be added to the cluster in any case.
%
%edges_touched is a non unique list of edges that are brought together by
%the shrinking of the edges in the clusters. Those servre as candidated for
%being part of the cluster as well as markers for which cells are part of
%the cluster
%
%edges_to_do is a list of possible edges in the same cluster as edge i
%
%

edges_touched = []; %passed during iteration but is redundant?

dead_list = find(dead_init);
inv_dead_list(dead_list) = 1:length(dead_list);

cluster_edges = [];

if born_init(i) 
    return
end

if max(data.edges.len(:, i)) < min_edge_length
%   cluster_edges = [];
%   return
end

if edges_done(i)
    return
end


if dead_init(i) == 0 
    return
end
%     if ~any(data.edges.selected((dead_init(i) - 1):dead_final(i), i))
%         return
%     end


%Find the edges at connected to edge i that actually meet as a result
%of edge i shrinking to a vertex.
time_pos = max(1, dead_init(i) - time_window);
time_pos2 =  min(num_frms, dead_init(i) + time_window);
edges_to_check1 = linked1(i).edges;
edges_to_check1 = keep_only_edges_linked_in_time_range(i, ...
    edges_to_check1, all_links, time_pos, time_pos2);

edges_to_check2 = linked2(i).edges;
edges_to_check2 = keep_only_edges_linked_in_time_range(i, ...
    edges_to_check2, all_links, time_pos, time_pos2);

time_pos = dead_init(i);
time_pos2 = dead_final(i) + time_window + 1;
if edge_breakup_final(i) < inf
    time_pos2 = max(time_pos2, edge_breakup_final(i));
end
time_pos2 = min(time_pos2, cluster_breakup + time_window);
time_pos2 = max(time_pos2, time_pos + time_window*2);
time_pos2 = min(num_frms, time_pos2);

extra_time_pos = dead_init(i);
[really_shrinks found_edges new_links_times] = double_exchange(...
    linked1, linked2, i, edges_to_check1, i, edges_to_check2, ...
    time_pos, time_pos2, time_window, num_frms, extra_time_pos);
if ~really_shrinks
    return %set edges_done(i) = 0?
end
same_time_space = resolved_edge_still_short(...
        i, i, new_links_times, sep_times, sep_times, time_window);
if ~any(same_time_space)
    return
end

edges_done(i) = true;

found_edges = found_edges(same_time_space, :);
found_edges = (found_edges(:))';
edges_touched = found_edges;
cluster_edges = i;
cluster_breakup = min(cluster_breakup, sep_times(i));

edges_to_do = [edges_to_do all_links(i).edges];
% edges_to_do2 = all_links(i).edges;

[dummy sort_ind] = sort(sep_times(edges_to_do));
edges_to_do = edges_to_do(sort_ind);

cnt = 0;
while cnt < length(edges_to_do)
    cnt = cnt + 1;
    j = edges_to_do(cnt);
    if dead_init(j) == 0 || edges_done(j) || (sum(data.edges.selected(:, j) > 0) < time_window)
        continue
    end
    
    
    if (sep_times(i) && dead_init(j) > sep_times(i)) || ...
            (sep_times(j) && dead_init(i) > sep_times(j))
        continue
    end
    
    if dead_init(j) > cluster_breakup
        continue
    end
    
    if sep_edges(i) && is_edge_long_near_death_other_edge(data, sep_edges(i), j, ...
            dead_init, min_edge_length) %&& ...
%         is_edge_long_near_death_other_edge(data, sep_edges(i), j, ...
%             dead_final, min_edge_length)
        continue
    end
    if sep_edges(j) && is_edge_long_near_death_other_edge(data, sep_edges(j), i,  ...
            dead_init, min_edge_length) %|| ...
%         is_edge_long_near_death_other_edge(data, sep_edges(j), i,  ...
%             dead_final, min_edge_length)
        continue
    end

    ts = cells_of_edge_touching(:, inv_dead_list(j));
    if ~is_edge_short_before_res_other_edge(data, i, j, ...
        dead_init, ts, min_edge_length, time_window)
        continue
    end
    ts = cells_of_edge_touching(:, inv_dead_list(i));
    if ~is_edge_short_before_res_other_edge(data, j, i, ...
        dead_init, ts, min_edge_length, time_window)
        continue
    end
    
    
    [flag found_edges new_links_times] = are_edges_really_linked(...
            i, j, dead_init, dead_final, cluster_breakup, ...
            all_links, linked1, linked2, time_window, num_frms, data, ...
            edge_breakup_init, edge_breakup_final, sep_times);

    if ~flag
        continue
    end

    if seprated_before_death(i, j, sep_times, dead_init, time_window)
        continue
    end
    
    %are the two edges very short when they shrink and resolve?
    same_time_space =  resolved_edge_still_short(...
        i, j, new_links_times, sep_times, edge_breakup_init, time_window);
    if any(same_time_space)
        found_edges = found_edges(same_time_space, :);
        found_edges = (found_edges(:))';
        
% % % % % % % % % % % % % % %         continue
% % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % %     %do the the two edges shrink and resolve at the same time?
% % % % % % % % % % % % % % %     if abs(edge_breakup(j) - edge_breakup(i)) < time_window ...
% % % % % % % % % % % % % % %          || (isinf(edge_breakup(j)) && edge_breakup(i) > (dead_final(j) - time_window))...
% % % % % % % % % % % % % % %          || (isinf(edge_breakup(i)) && edge_breakup(i) > (dead_final(j) - time_window))...





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %The two edges shrink to the same cluster. Add edge j to the cluster
       %by iterating this function. 
       edges_touched = [edges_touched found_edges];
       
%%%%%%%%%%%%%%%%%%%%% depth first iteration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [new_cluster_edges new_edges_touched edges_done cluster_breakup] = ...
        add_edge_to_cluster_depth_first(j, data, time_window, min_edge_length, ...
        dead_init, dead_final, edge_breakup_init, edge_breakup_final, ...
        num_frms, linked1, linked2, all_links, sep_times, ...
        cells_of_edge_touching, sep_edges, born_init, cluster_breakup,...
        edges_done, edges_touched, found_edges);
            
            cluster_edges = [cluster_edges new_cluster_edges];
            edges_to_do = [edges_to_do edges_touched];
            edges_touched = [edges_touched new_edges_touched];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       edges_done(j) = true; %for cases when j is determined not to be a 
       %real shrinking by the subsequent call to add_edge_to_cluster_depth_first  

    
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = is_edge_short_in_time_range(data, edge, time_pos, time_pos2, min_edge_length)
time_pos = max(1, time_pos);
time_pos2 = min(length(data.edges.len(:, 1)), time_pos2);
flag = min(data.edges.len(time_pos:time_pos2, edge)) < min_edge_length;

function flag = is_edge_long_in_time_range(data, edge, time_pos, time_pos2, min_edge_length)
time_pos = max(1, time_pos);
time_pos2 = min(length(data.edges.len(:, 1)), time_pos2);
flag = max(data.edges.len(time_pos:time_pos2, edge)) > min_edge_length;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = is_edge_short_near_death_other_edge(data, edge1, edge2, ...
    dead_init, min_edge_length, time_window)
time_pos = dead_init(edge2) - time_window;
time_pos2 = dead_init(edge2) + time_window;
flag = is_edge_short_in_time_range(data, edge1, time_pos, time_pos2, min_edge_length);

function flag = is_edge_long_near_death_other_edge(data, edge1, edge2, ...
    dead_init, min_edge_length)
time_pos = dead_init(edge2) - 1;
time_pos2 = dead_init(edge2) + 1;
flag = is_edge_long_in_time_range(data, edge1, time_pos, time_pos2, min_edge_length);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = is_edge_short_before_res_other_edge(data, edge1, edge2, ...
    dead_init, ts, min_edge_length, time_window)
time_pos = dead_init(edge2) - time_window;
time_pos2 = find(ts, 1, 'last');
flag = is_edge_short_in_time_range(data, edge1, time_pos, time_pos2, min_edge_length);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = seprated_before_death(edge1, edge2, sep_times, dead_final, time_window)
flag = (sep_times(edge1) < (dead_final(edge2))) || (sep_times(edge2) < dead_final(edge1));