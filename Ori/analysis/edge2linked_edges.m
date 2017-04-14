function linked_edges_list = edge2linked_edges(geom, edge, node1, node2)
%Returns all the edges connected to the first node (if node1 == true) and /
%or the second node (if node2 == true) of edge according to geom.
%The default is both nodes.

if nargin < 3
    node1 = true;
    node2 = true;
end
linked_edges = false(size(geom.edges(:, 1)));
if node1
    linked_edges = ...
        geom.edges(:, 1) == geom.edges(edge, 1) |...
        geom.edges(:, 2) == geom.edges(edge, 1); 
end
if node2
    linked_edges = linked_edges | ...    
        geom.edges(:, 1) == geom.edges(edge, 2) |...
        geom.edges(:, 2) == geom.edges(edge, 2);
end

linked_edges(edge) = false;
linked_edges_list = find(linked_edges);
