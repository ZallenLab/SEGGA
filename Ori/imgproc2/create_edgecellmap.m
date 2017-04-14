function [edges, all_edges, all_edges_map] = create_edgecellmap(nodes_cells)
%nodes_cells is expected to be sorted by cell and then by the phase angle of each
%node relative to the cell center. 

    [dummy1, cell_ind, dummy2] = unique(nodes_cells(:,1), 'legacy');
    edges_end = circshift(nodes_cells(:,2), -1);
    edges = [nodes_cells(:, 2) edges_end];
    edges(cell_ind, 1:2) = [nodes_cells(cell_ind, 2) edges_end(circshift(cell_ind,+1))];

    all_edges = edges;

%     % Each inner edge is listed twice, once back and and once forth (once
%     % for each cell on the two sides of the edge).
%     % Boundary edges are listed once.
%     % Make sure each edge is listed back and forth and then 
%     % keep only one listing of each edge.
%     edges = [edges ; circshift(edges, [0 1])];
%     edges = unique(edges(edges(:, 1) <= edges(:,2), :), 'rows');

    edges(edges(:, 1) > edges(:, 2), :) = edges(edges(:, 1) > edges(:, 2), [2 1]);
    [edges dummy all_edges_map] = unique(edges, 'rows', 'legacy');

return