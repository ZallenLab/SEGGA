function [seq ebs flip] = smoothen_movement(seq, edges, ebs, flip)
if nargin <3 || isempty(ebs)
    ebs = global_edges2cells(seq, edges);
end
edges_by_cells(edges, :) = ebs;

if nargin < 4 || isempty(flip)
    flip = edges_orientation(seq, edges, edges_by_cells);
end

%smoothen centers
cells = faster_unique(ebs(:) + 1, length(seq.cells_map(1, :)) + 1) - 1;
if cells(1) == 0
    cells = cells(2:end);
end
seq = smoothen_centers(seq, cells);

%%%%% smoothen nodes movement
seq = smoothen_node_movements(seq, edges, ebs, flip(:, edges));

%%%% recenter
for i = 1:length(seq.frames)
    faces_for_area = cellgeom2faces_for_area(seq.frames(i).cellgeom);
    [pc_x pc_y] = cellgeom2centroid(seq.frames(i).cellgeom, faces_for_area);
    seq.frames(i).cellgeom.circles(:, 1) = pc_y;
    seq.frames(i).cellgeom.circles(:, 2) = pc_x;
end



function seq = smoothen_centers(seq, cells)
x = nan(length(seq.frames), length(cells));
y = x;
for i = 1:length(seq.frames)
    local_cells = nonzeros(seq.cells_map(i, cells));
    global_cells = find(seq.cells_map(i, cells));
    x(i, global_cells) = seq.frames(i).cellgeom.circles(local_cells, 1);
    y(i, global_cells) = seq.frames(i).cellgeom.circles(local_cells, 2);
end
x = smoothen(x, 2, 'median', 1);
x = smoothen(x, 1);
y = smoothen(y, 2, 'median', 1);
y = smoothen(y, 1);
for i = 1:length(seq.frames)
    local_cells = nonzeros(seq.cells_map(i, cells));
    global_cells = find(seq.cells_map(i, cells));
    seq.frames(i).cellgeom.circles(local_cells, 1) = x(i, global_cells) ;
    seq.frames(i).cellgeom.circles(local_cells, 2) = y(i, global_cells);
end




function seq = smoothen_node_movements(seq, edges, edges_by_cells, flip)



x1 = nan(length(seq.frames), length(edges));
x2 = x1;
y1 = x1;
y2 = x1;
for frm = 1:length(seq.frames)
    geom = seq.frames(frm).cellgeom;
    for i = 1:length(edges)
        ed = seq.edges_map(frm, edges(i));
        if ed
            local_cells_id = seq.cells_map(frm, edges_by_cells(i, :));
            cells_x = mean(geom.circles(local_cells_id, 1));
            cells_y = mean(geom.circles(local_cells_id, 2));
            if flip(frm, i)
                node2 = 1;
                node1 = 2;
            else
                node1 = 1;
                node2 = 2;
            end
            x1(frm, i) = geom.nodes(geom.edges(ed, node1), 1) - cells_x;
            x2(frm, i) = geom.nodes(geom.edges(ed, node2), 1) - cells_x;
            y1(frm, i) = geom.nodes(geom.edges(ed, node1), 2) - cells_y;
            y2(frm, i) = geom.nodes(geom.edges(ed, node2), 2) - cells_y;
        end
    end
end

x1 = smoothen(x1, 1, 'median', 1);
x2 = smoothen(x2, 1, 'median', 1);
y1 = smoothen(y1, 1, 'median', 1);
y2 = smoothen(y2, 1, 'median', 1);
x1 = smoothen(x1, 2, [], 1);
x2 = smoothen(x2, 2, [], 1);
y1 = smoothen(y1, 2, [], 1);
y2 = smoothen(y2, 2, [], 1);

for frm = 1:length(seq.frames)
    geom = seq.frames(frm).cellgeom;
    nodes = zeros(size(geom.nodes));
    nodes_w = nodes;
    for i = 1:length(edges)
        ed = seq.edges_map(frm, edges(i));
        if ed
            local_cells_id = seq.cells_map(frm, edges_by_cells(i, :));
            cells_x = mean(geom.circles(local_cells_id, 1));
            cells_y = mean(geom.circles(local_cells_id, 2));
            if flip(frm, i)
                node2 = 1;
                node1 = 2;
            else
                node1 = 1;
                node2 = 2;
            end
            nodes(geom.edges(ed, node1), 1) = nodes(geom.edges(ed, node1), 1) + x1(frm, i) + cells_x;
            nodes_w(geom.edges(ed, node1), 1) = nodes_w(geom.edges(ed, node1), 1) + 1;
            
            nodes(geom.edges(ed, node2), 1) = nodes(geom.edges(ed, node2), 1) + x2(frm, i) + cells_x;
            nodes_w(geom.edges(ed, node2), 1) = nodes_w(geom.edges(ed, node2), 1) + 1;
            
            nodes(geom.edges(ed, node1), 2) = nodes(geom.edges(ed, node1), 2) + y1(frm, i) + cells_y;
            nodes_w(geom.edges(ed, node1), 2) = nodes_w(geom.edges(ed, node1), 2) + 1;
            
            nodes(geom.edges(ed, node2), 2) = nodes(geom.edges(ed, node2), 2) + y2(frm, i) + cells_y;
            nodes_w(geom.edges(ed, node2), 2) = nodes_w(geom.edges(ed, node2), 2) + 1;
        end
    end
    ind = nodes_w > 0;
    seq.frames(frm).cellgeom.nodes(ind) = nodes(ind) ./ nodes_w(ind);
end