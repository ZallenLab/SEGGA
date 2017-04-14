function misc = find_clusters_by_edges_init_vars(seq, data, edges, time_window, min_edge_length, linked1, linked2, all_links, flip)
debug_hist = zeros(1, 10);
%data should be of all cells, not just selected cells;
%used field:
%data.cells.area
%data.edges.selected
%data.edges.len

if nargin < 3 || isempty(edges)
    edges = find(any(data.edges.selected > 0, 1));
end

if nargin < 4 || isempty(time_window)
    time_window = 10;
end

if nargin < 5 || isempty(min_edge_length)
    min_edge_length = 10;
end

num_frms = length(seq.frames);


[dead_init dead_final born_init born_final ...
    edges_by_cells edges_can_exist] = edges_events_timepoint(seq, data, edges, time_window, min_edge_length);

if nargin < 9
    %make sure the order of the nodes for an edge, as listed in cellgeom is the
    %same for all time points
    flip = edges_orientation(seq, edges, edges_by_cells);
end

if nargin < 6 || isempty(linked1)
    linked1 = global_edges2linked_edges_sided(seq, data, edges, true, false, flip);
    linked2 = global_edges2linked_edges_sided(seq, data, edges, false, true, flip);
    
    all_links = linked1;
    for i = 1:length(linked1)
        all_links(i).edges = [linked1(i).edges linked2(i).edges];
        all_links(i).on = [linked1(i).on linked2(i).on];
    end
end

    
%edge starts to resolve
edge_breakup_init = inf(size(dead_init));
%edge resolved
edge_breakup_final = inf(size(dead_init));

%For edge i, sep_edges(i) is the edge separating the two cells divided by
%edge i (that is, the edge created when edge i resolves).
sep_edges = zeros(size(dead_init));
%indicates the time at which the two cells divided by edge i are not close
%to each other (measured through the length of the separating edge see
%below for details)
sep_times = inf(size(dead_init));

dead_list = find(dead_init);
inv_dead_list(dead_list) = 1:length(dead_list);

%cells_of_edge_touching indicates if the two cells divided by a given edge 
%are touching (have at least one vertex in common). Enumerated by dead_list
%
%cells_of_edge_touching(t, inv_dead_list(i)) indicated the above for edge i at
%timepoint t.
cells_of_edge_touching = false(length(seq.frames), nnz(dead_init)); 

%sep_edge_touching_cells_of_edge indicates if the edge that separated
%the two cells divided by a given edge, after the shrinking and resolution 
%of the given edge, is touching both cells. Enumerated by dead_list.
%
%sep_edge_touching_cells_of_edge(t, inv_dead_list(i)) indicated the above for
%edge i at timepoint t.
sep_edge_touching_cells_of_edge = cells_of_edge_touching; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find the first time after edge death for which two edges that were 
%previously linked at one end of edge i are no longer linked.
for i = find(dead_init > 0)
    %find all the time points for which the two cells divided by edge i
    %touch each other (with one or two vertices).
    t = are_cells_touching(i, edges_by_cells, seq, data);
    cells_of_edge_touching(:, inv_dead_list(i)) = t;
    %find the first time point after edge death in which the two cells
    %divided by it are no longer in contact (through a single vertex).
    touching_frames_on = t((dead_init(i)-1):end);
    last_touch_time = find(~touching_frames_on, 1);
    if isempty(last_touch_time)
        edge_breakup_init(i) = num_frms;
    else
        edge_breakup_init(i) = last_touch_time + dead_init(i) - 2;
    end
    %find the first time point after edge death in which the two cells
    %divided by it are no longer in contact (through a single vertex) for
    %at least time_window time points in a continuous block.
    first_block_pos = find_begining_of_block_in_vec(...
                                touching_frames_on, time_window);
    if ~first_block_pos %no block was found
        edge_breakup_final(i) = find(touching_frames_on, 1, 'last') ...
                                    + dead_init(i) - 2;
    else
        edge_breakup_final(i) = first_block_pos + dead_init(i) - 2;
    end
    
    %find the edge that separates the two cells divided by edge i after 
    %edge i disappears.
    
    [e flipped] = find_edge_connecting_cells(...
        i, t, edges_by_cells, seq, data, dead_init, flip, time_window);
    if e
        sep_edges(i) = e;
        %find the time points in which the separating edge touches both cells
        t_sep = is_edge_sep_cells(e, t, edges_by_cells(i, :), seq, data, ...
            dead_init(i), flipped, flip);

        %find the first time point in which the separating edge is longer
        %than min_edge_length or is not touching the two cells for a 
        %continuous block of time_window. 
        cells_are_near = t((dead_init(i) - 1):end) | ...
            ((data.edges.len((dead_init(i) - 1):end, e) < min_edge_length)'...
             & t_sep((dead_init(i) - 1):end));
        first_block_pos = find_begining_of_block_in_vec(cells_are_near, time_window);
        if first_block_pos
            sep_times(i) = first_block_pos + dead_init(i) - 2;
        else
            sep_times(i) = find(cells_are_near, 1, 'last') + dead_init(i) - 2;
        end
        sep_edge_touching_cells_of_edge(:, inv_dead_list(i)) = t_sep;
    end
    
    
    
    %edge_breakup_old is not used anymore;
%     [edge_breakup_old(i) sep_edges] = edge_breakup_time(i, data, all_links, ...
%     linked1, linked2, time_window, dead_final);
% 
% 
%     if ~isempty(sep_edges)
%         separated_edges(i).new_edges = find_edge_in_between(sep_edges, linked1, linked2, i);
%         temp_min = inf;
%         for j = separated_edges(i).new_edges;
%             if born_init(j)
%                 temp_min2 = find(data.edges.len(dead_init(i):end, j) > ...
%                                  min_edge_length, 1);
%                 if ~isempty(temp_min2)
%                     temp_min = min(temp_min, temp_min2);
%                 end
%             end
%         end
% 
%         %separated_edges(i).time is the first time point that an edge that 
%         %was formed when the shrinking edge i resolved, is more than
%         %min_edge_length in length.
%         separated_edges(i).time = temp_min + dead_init(i) - 1;
%     else
%         separated_edges(i).new_edges = [];
%         separated_edges(i).time = inf;
%     end
end


misc.dead_init = dead_init;
misc.dead_final = dead_final;
misc.born_init = born_init;
misc.born_final = born_final;
misc.edges_by_cells = edges_by_cells;
misc.linked1 = linked1;
misc.linked2 = linked2;
misc.all_links = all_links;
misc.flip = flip;
misc.edge_breakup_init = edge_breakup_init;
misc.edge_breakup_final = edge_breakup_final;
misc.sep_times = sep_times;
misc.sep_edges = sep_edges;
misc.sep_edge_touching_cells_of_edge = sep_edge_touching_cells_of_edge;
misc.cells_of_edge_touching = cells_of_edge_touching;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = are_cells_touching(edge, edges_by_cells, seq, data)
t = true(1, length(seq.frames));
cells = edges_by_cells(edge, :);
for i = (find(data.edges.len(:, edge) == 0))'
    local_cells = nonzeros(seq.cells_map(i, cells));
    if length(local_cells) < 2
        t(i) = false;
        continue
    end
    t(i) = are_cells_touching_in_geom(seq.frames(i).cellgeom, local_cells);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = are_cells_touching_in_geom(geom, cells)
nodes_touched = zeros(1, length(geom.nodes(:, 2)));
nodes_touched(geom.nodecellmap(geom.nodecellmap(:, 1) == cells(1), 2)) = 1;
nodes_touched(geom.nodecellmap(geom.nodecellmap(:, 1) == cells(2), 2)) = ...
    nodes_touched(geom.nodecellmap(geom.nodecellmap(:, 1) == cells(2), 2)) + 1;
% Is there a node that is part of more than one cell? If tes, the cells are
% touching.
t = any(nodes_touched > 1); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [e flipped] = find_edge_connecting_cells(edge, cells_touching, ...
    edges_by_cells, seq, data, dead_init, flip, time_window)
%Return the global edge index of an edge that separates/connects the two
%cells divided by edge (ie, the two cells share the input edge, edge,
%as an edge: both vertices of edge are part of both cells. Each vertex of 
%the output edge, e, is part of one of the two cells).

cells = edges_by_cells(edge, :);
        %find time points where the two cells divided by edge are not
    frms = find(... touching but at least one of these two cells is 
        (cells_touching == 0)' ... still in view.
        & any(data.cells.selected(:, edges_by_cells(edge, :)), 2)); 
       
e = [];
flipped = [];
for i = frms';
    %we want to find an edge that separates the cells after the
    %disappearance of the input edge.
    if i < dead_init(edge)
        continue
    end
    local_cells = seq.cells_map(i, cells);
    if ~all(local_cells)
        continue
    end
    %find an edge that connects the two cells.
    geom = seq.frames(i).cellgeom;
    cond1 = ...
        (ismember(geom.edges(:, 1), geom.faces(local_cells(1), :), 'legacy') & ...
        ismember(geom.edges(:, 2), geom.faces(local_cells(2), :), 'legacy'));
    cond2 = ...
        (ismember(geom.edges(:, 2), geom.faces(local_cells(1), :), 'legacy') & ...
        ismember(geom.edges(:, 2), geom.faces(local_cells(2), :), 'legacy'));

    %is there an edge that separates the cells, and if so at what
    %orientation?

    local_e = find(cond1);
    flipped_list = false(1, length(local_e));
    
    local_e2 = [local_e find(cond2)];
    
    local_e = [local_e local_e2];
    flipped_list = [flipped_list true(1, length(local_e2))];
    if isempty(local_e)
        continue
    end
    
    valid_local_e = local_e <= length(seq.inv_edges_map(1, :));
    true_valid_local_e = seq.inv_edges_map(i, local_e(valid_local_e));
    valid_local_e(~true_valid_local_e) = false;
    
    e = [e seq.inv_edges_map(i, local_e(valid_local_e))];
    flipped = [flipped flipped_list(valid_local_e)];
end
if isempty(e)
    return
end

%get rid of the repititions in e and update flipped accordingly flipped:
if length(e) > 1
    [e temp_ind dummy] = unique(e, 'legacy');
    flipped = flipped(temp_ind);
end
%for cases where two separating edges, find the one that divides two
%cells that the original edge separated.
if length(e) > 1
    ind = find_best_valid_sep_edge(edge, e, flipped, edges_by_cells, ...
        seq, data, flip, dead_init, time_window, cells_touching);
    e = e(ind);
    flipped = flipped(ind);
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind = find_best_valid_sep_edge(edge, candidate_edges, flipped,...
    edges_by_cells, seq, data, flip, dead_init, time_window, ...
    cells_divided_by_input_edge_touching)
%Of the candidate edges (edges that separate the cells the input edge
%divides), find the one that divide cells that the input edge separates.
%If there is more than one such edge, return the one existing the longest.

%find the cells separated by input edge. Do this only in relevant time
%points to save computation time.
cells1 = [];
cells2 = [];
st_frm = max(1, dead_init(edge)-time_window);
for frm = st_frm:length(seq.frames)
    if ~data.edges.selected(frm, edge)
        continue
    end
    [c1 c2] = cells_sep_by_edge(seq.frames(frm).cellgeom, ...
        seq.edges_map(frm, edge), flip(frm, edge));
    c1 = seq.inv_cells_map(frm, c1);
    c2 = seq.inv_cells_map(frm, c2);
    cells1 = [cells1 c1];
    cells2 = [cells2 c2];
end
cells1 = faster_unique(cells1, length(seq.cells_map(1, :)));
cells2 = faster_unique(cells2, length(seq.cells_map(1, :)));
ind = false(1, length(candidate_edges));

%for each candidate edge check if it divided two cells that the input edge
%separates
for i = 1:length(candidate_edges)
    e = candidate_edges(i);
    if (    any(edges_by_cells(e, 1) == cells1) && ...
            any(edges_by_cells(e, 2) == cells2)) ...
        || ...
       (    any(edges_by_cells(e, 2) == cells1) && ...
            any(edges_by_cells(e, 1) == cells2))
        ind(i) = true;
    end
end
if nnz(ind) == 1
    ind = find(ind);
    return
end


% %for each remaining candidate edge, count for how many frames it acts as a
% %separating edge for the two cells divided by the input edge.
% 
% new_ind = find(ind);
% 
% divided_cells = edges_by_cells(edge, :);
% count_frms = zeros(size(candidate_edges));
% for cnt = find(new_ind)
%     i = new_ind(cnt);
%     e = candidate_edges(i);
%     ts = is_edge_sep_cells(e, ...
%         cells_divided_by_input_edge_touching, divided_cells, ...
%         seq, data, dead_init(edge), flipped(i), flip);
%     count_frms(i) = sum(ts);
%     
% end
% [dummy ind] = max(count_frms);    

%for each remaining candidate edge, count for how many frames it exists.

count_frms = sum(data.edges.len(:, candidate_edges) > 0);
count_frms(~ind) = 0;  %SOME TIMES all(ind == 0). HOW COME?
[dummy ind] = max(count_frms);    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cells1 cells2] = cells_sep_by_edge(geom, edge, flipped)
%returns two lists: cells1 are the cells connected to an edge at its first
%node and cells2 are the cells connected to the cell at its second node.
if flipped
    node1 = geom.edges(edge, 2);
    node2 = geom.edges(edge, 1);
else
    node1 = geom.edges(edge, 1);
    node2 = geom.edges(edge, 2);
end
cells1 = geom.nodecellmap(geom.nodecellmap(:, 2) == node1, 1);
cells2 = geom.nodecellmap(geom.nodecellmap(:, 2) == node2, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ts = is_edge_sep_cells(edge, t, cells, seq, data, ...
    dead_init_frm, edge_flipped, flip)
%cells are the two cells the edge separates
%t true for every time point at which the two cells touch by either one or
%two vertices.
%dead_init_frm is the first frame for which the condition is evaluated for.
%(that is from dead_init_frm until the last frame).

ts = false(1, length(seq.frames));
for i = dead_init_frm:length(ts) 
    % make sure the cells are in view, not touching and that the edge
    % exists at the current time point.
    if ~any(data.cells.selected(i, cells) > 0) || t(i) || ...
            ~data.edges.len(i, edge)
        continue
    end
    flipped = xor(edge_flipped, flip(i, edge));
    if ~flipped
        local_cells = seq.cells_map(i, cells);
    else
        local_cells = seq.cells_map(i, cells([2 1]));
    end
    if ~all(local_cells)
        continue
    end
    local_edge = seq.edges_map(i, edge);
    if ~(local_edge)
        continue
    end
    ts(i) = is_edge_sep_cells_in_geom_oriented(...
                    seq.frames(i).cellgeom, local_edge, local_cells);
                
    %%the flip info (of the cells?) seems to be wrong at this stage --Ori 15 May 2009
    ts(i) = ts(i) | is_edge_sep_cells_in_geom_oriented(...
                    seq.frames(i).cellgeom, local_edge, local_cells([2 1]));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = is_edge_sep_cells_in_geom_oriented(geom, edge, cells)
flag = any(geom.edges(edge, 1) == geom.faces(cells(1), :)) && ...
    any(geom.edges(edge, 2) == geom.faces(cells(2), :));
