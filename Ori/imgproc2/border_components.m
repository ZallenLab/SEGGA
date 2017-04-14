function [c border_bool] = border_components(cellgeom)

% get edge cell map
new_ecm = new_edgecellmap(cellgeom);

% which edges are border edges
border_bool = isnan(new_ecm(:, 2));

border_edges = cellgeom.edges(border_bool, :);
node_con_mat = false(length(cellgeom.nodes));
for i = 1:length(border_edges)
    node_con_mat(border_edges(i, 1), border_edges(i, 2)) = true;
end
node_con_mat = node_con_mat | node_con_mat';

% list of node index positions in connectivity components
c = components_of_nghbrs_matrix(node_con_mat, 'nodes');