function [nm sel_nodes] = node_mult(geom, sel_cells)
%passing sel_cells = 0 will analyze all cells

if nargin < 2 || isempty(sel_cells)
    sel_cells = geom.selected_cells;
end

if sel_cells == 0
    sel_cells = true(length(geom.faces(:, 1)),1);
end

sel_nodes = false(length(geom.nodes), 1);
nodes_list = geom.faces(sel_cells, :); %all nodes of selected cells
sel_nodes(nodes_list(~isnan(nodes_list))) = true; %logical list of selected nodes
nm = accumarray(geom.edges(:), 1, size(sel_nodes)); %accumulation of instances of each node
