function cellgeom = full_edgecellmap(cellgeom)
%%% create the edges list %%%%%%%%%%%%%
[edges, all_edges, all_edges_map] = create_edgecellmap(cellgeom.nodecellmap);
cellgeom.edges = edges;

% % % 
% % % [dummy1, cell_ind, dummy2] = unique(cellgeom.nodecellmap(:,1));
% % % edges_end = circshift(cellgeom.nodecellmap(:,2), -1);
% % % edges = [cellgeom.nodecellmap(:, 2) edges_end];
% % % edges(cell_ind, 1:2) = [cellgeom.nodecellmap(cell_ind, 2) edges_end(circshift(cell_ind,+1))];
% % % 
% % % all_edges = edges;
% % % % Each inner edge is listed twice, once back and and once forth (once
% % % % for each cell on the two sides of the edge).
% % % % Boundary edges are listed once.
% % % % Make sure each edge is listed back and forth and then 
% % % % keep only one listing of each edge.
% % % edges = [edges ; circshift(edges, [0 1])];
% % % edges = unique(edges(edges(:, 1) <= edges(:,2), :), 'rows');


%create the edge_cell map
edgecellmap = cellgeom.nodecellmap;
edgecellmap(:, 2) = all_edges_map;

% for i = 1:length(all_edges)
%     current_edge = find(...
%         (edges(:,1) == all_edges(i,1) & edges(:,2) == all_edges(i,2))...
%         | (edges(:,1) == all_edges(i,2) & edges(:,2) == all_edges(i,1))...
%         , 1);
%     if length(current_edge) == 1
%         edgecellmap(i, 2) = current_edge;
%     else
%         fprintf('WARNING: failed to create the edge between nodes %g and %g for cell %g\n Please report.\n'...
%             ,all_edges(i,1:2), edgecellmap(i,1));
%     end
% 
% end

cellgeom.edgecellmap = unique(edgecellmap, 'rows', 'legacy');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if ~isfield(cellgeom, 'edges_length')
    cellgeom.edges_length = single(realsqrt(sum(...
        (cellgeom.nodes(cellgeom.edges(:,1),:) - ...
         cellgeom.nodes(cellgeom.edges(:,2),:)).^2')));
%end