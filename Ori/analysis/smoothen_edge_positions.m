function [x1 x2 y1 y2] = smoothen_edge_positions(seq, edges, ebs, flip, max_x, max_y)
if nargin <3 || isempty(ebs)
    ebs = global_edges2cells(seq, edges);
end

if nargin < 4 || isempty(flip)
    flip = edges_orientation(seq, edges, edges_by_cells);
end


x1 = nan(length(seq.frames), length(edges));
x2 = x1;
y1 = x1;
y2 = x1;
for frm = 1:length(seq.frames)
    geom = seq.frames(frm).cellgeom;
    for i = 1:length(edges)
        ed = seq.edges_map(frm, edges(i));
        if ed
            local_cells_id = seq.cells_map(frm, ebs(i, :));
            cells_x = sum(geom.circles(local_cells_id, 1))/2;
            cells_y = sum(geom.circles(local_cells_id, 2))/2;
            if flip(frm, edges(i))
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
x1 = smoothen(x1, 1, [], 1);
x2 = smoothen(x2, 1, [], 1);
y1 = smoothen(y1, 1, [], 1);
y2 = smoothen(y2, 1, [], 1);

for frm = 1:length(seq.frames)
    geom = seq.frames(frm).cellgeom;
    for i = 1:length(edges)
        ed = seq.edges_map(frm, edges(i));
        if ed
            local_cells_id = seq.cells_map(frm, ebs(i, :));
            cells_x = sum(geom.circles(local_cells_id, 1))/2;
            cells_y = sum(geom.circles(local_cells_id, 2))/2;
            x1(frm, i) = x1(frm, i) + cells_x;
            x2(frm, i) = x2(frm, i) + cells_x;
            y1(frm, i) = y1(frm, i) + cells_y;
            y2(frm, i) = y2(frm, i) + cells_y;
            if flip(frm, edges(i))
                t = x1(frm, i);
                x1(frm, i) = x2(frm, i);
                x2(frm, i) = t;
                t = y1(frm, i);
                y1(frm, i) = y2(frm, i);
                y2(frm, i) = t;
            end
        end
    end
end
if nargin > 4 && ~isempty(max_x)
    x1(x1<0) = 1;
    x2(x2<0) = 1;
    x1(x1>max_x) = max_x;
    x1(x1>max_x) = max_x;
end
if nargin > 5 && ~isempty(max_y)
    y1(y1<0) = 1;
    y2(y2<0) = 1;
    y1(y1>max_y) = max_y;
    y2(y2>max_y) = max_y;
end