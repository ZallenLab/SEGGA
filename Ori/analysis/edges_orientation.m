function flip = edges_orientation(seq, edges, edges_by_cells)
%Returns the relative orientation (positive or negative) between each edge
%and the line connecting the centroids of the two cells it divides. 
%For each edge, the value of flip depends on the order the nodes at its 
%ends are listed at every time point and can change over time (flip tells 
%us at which time points the two nodes are ordered one way and at which 
%time points the two nodes are ordered the opposite way).

if nargin < 2 || isempty(edges)
    edges = 1:length(seq.edges_map(1, :));
end
if islogical(edges)
    edges = find(edges);
end
flip = false(size(seq.edges_map));

for e = edges
    cells = edges_by_cells(e, :);
    for i = 1:length(seq.edges_map(:, 1))
        ed = seq.edges_map(i, e);
        if ~ed
            continue
        end
        geom = seq.frames(i).cellgeom;
        local_cells = seq.cells_map(i, cells);
        cells_vec = geom.circles(local_cells(1), 1:2) - geom.circles(local_cells(2), 1:2);
        edge_vec = geom.nodes(geom.edges(ed, 1), :) - geom.nodes(geom.edges(ed, 2), :);
        %ori = vectors relative orientation = cross product
        ori = cells_vec(1) * edge_vec(2) - cells_vec(2) * edge_vec(1);
        if ori < 0
            flip(i, e) = true;
        end
    end
end
        