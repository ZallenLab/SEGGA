function cluster_cells = select_clusters_nodes(cellgeom, ...
    edges_high, edges_low, min_cluster_size, max_cluster_size, all_cells);
global summary
if nargin < 6
    all_cells = 0;
end


if all_cells
    sel = 1:length(cellgeom.circles(:,1));
    candidate_nodes = 1:length(cellgeom.nodes(:,1));
    edges_sel = true(1, length(cellgeom.edges(:,1)));
    if isfield(cellgeom, 'border_cells');
        border_cells = false(length(cellgeom.faces(:, 1)), 1);
        border_cells(cellgeom.border_cells) = 1;
        n = cellgeom.faces(~border_cells, :);
        candidate_nodes = double(n(~isnan(n)))';
        sel = sel(~border_cells);

    end
    
else
    sel = find(cellgeom.selected_cells);
    candidate_nodes = [summary.nodeInfo.nodeNum];
    edges_sel = summary.edges_sel';
end
edges = cellgeom.edges_length <= edges_high & cellgeom.edges_length >= edges_low ...
    & edges_sel;
edges = cellgeom.edges(edges, 1:2);
% candidate_nodes = find([summary.nodeInfo.numEdges] >= nodes_low & [summary.nodeInfo.numEdges] <= nodes_high);
% candidate_nodes = [summary.nodeInfo(candidate_nodes).nodeNum];
% candidate_nodes = unique([candidate_nodes edges(:,1)' edges(:,2)']);
% selected_nodes = [summary.nodeInfo.nodeNum];
% candidate_nodes = intersect(candidate_nodes, selected_nodes);    





cluster_cells =[];
h = [];
i = 1;
while length(candidate_nodes)
    current_nodes = candidate_nodes(1);
%     global activefig
%     delete(h(ishandle(h)));
%     h = scatter(get(activefig,'CurrentAxes'), cellgeom.nodes(current_nodes, 2), cellgeom.nodes(current_nodes,1), 'r')

    candidate_nodes = setdiff(candidate_nodes, current_nodes, 'legacy');
    ind = ismember(edges(:,1), current_nodes, 'legacy');
    next_nodes = edges(ind,2);
    ind = ismember(edges(:,2), current_nodes, 'legacy');
    next_nodes = union(next_nodes, edges(ind,1), 'legacy');
   
    current_cluster = [];
    while length(next_nodes) && length(next_nodes) < (max_cluster_size - 1)
        current_cluster = [current_cluster current_nodes];
        current_nodes = intersect(candidate_nodes, next_nodes, 'legacy');
        candidate_nodes = setdiff(candidate_nodes, current_nodes, 'legacy');
        ind = ismember(edges(:,1), current_nodes, 'legacy');
        next_nodes = edges(ind,2);
        ind = ismember(edges(:,2), current_nodes, 'legacy');
        next_nodes = union(next_nodes, edges(ind,1), 'legacy');

    end
    current_cluster = [current_cluster current_nodes];
    ind = ismember(cellgeom.nodecellmap(:,2), current_cluster, 'legacy');
    current_cluster_cells = intersect(cellgeom.nodecellmap(ind,1), sel, 'legacy');
    if length(current_cluster_cells) >= min_cluster_size
        if length(current_cluster_cells) > max_cluster_size
            cluster_cells{i} = current_cluster_cells(1:max_cluster_size);
        else
            cluster_cells{i} = current_cluster_cells;
        end
        i = i + 1;
    end
end
