function edges_by_cells = global_edges2cells(seq, edges)
%For each edge returns the two cells separated by it.
if islogical(edges)
    edges = find(edges);
end
edges_by_cells = zeros(length(edges), 2);
for ind = 1:length(edges)
    i = edges(ind);
    frm = find(full(seq.edges_map(:, i) > 0), 1);
    local_edge = seq.edges_map(frm, i);
    
    %Denote the edge by the two cells separated by it.
    edges_by_cells(ind, :) = edge2cells(seq.frames(frm).cellgeom, local_edge);
    edges_by_cells(ind, find((edges_by_cells(ind, :)))) = ...
        seq.inv_cells_map(frm, nonzeros(edges_by_cells(ind, :)));
end