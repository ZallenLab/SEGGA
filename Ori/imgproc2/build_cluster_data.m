function cluster = build_cluster_data(cells, cellgeom, accurate)
if nargin < 3
    accurate = 1;
end
if ~length(cells)
    cluster.cells = [];
    cluster.boundary = [];
    cluster.center = [];
    cluster.boundary_edges = [];
    cluster.inner_edges = [];
    cluster.n_edges = [];
    cluster.area = [];
    cluster.ratio = [];
    return
end

cells = reshape(cells, 1, []);

cluster.cells = cells;
    cluster.boundary = [];
    cluster.center = [];
    cluster.boundary_edges = [];
    cluster.inner_edges = [];
    cluster.n_edges = [];
    cluster.area = [];
    cluster.ratio = [];
    
if ~accurate
    return    
end
    
% if accurate
%     cluster.boundary = cluster_outer_nodes(cells, cellgeom);
% else
%     %find a faster less accurate way to do this...
%     cluster.boundary = cluster_outer_nodes(cells, cellgeom);
% end

%cluster.boundary = cluster_outer_nodes(cells, cellgeom);
[cluster.boundary info] = cluster_outer_nodes(cells, cellgeom);
if info.components > 1
    cluster.boundary = cluster.boundary(1:info.starts(2) - 1);
end
if ~info.success
    %warning('Failed to find boundary of cluster');
    cluster.boundary = nonzeros(cluster.boundary);
end

cluster.center = centroid(cellgeom.nodes(cluster.boundary, :));
if accurate < 2
    return
end
edges = cellgeom.edgecellmap(ismember(cellgeom.edgecellmap(:,1), cells, 'legacy'),2);
edges = sort(edges);
[edges edges_ind dummy] = unique(edges, 'legacy');
all_edges = edges; 
b_edges = edges((edges_ind' - [0 edges_ind(1:end -1)']) == 1); 
cluster.boundary_edges = b_edges;

cluster.inner_edges = setdiff(all_edges, b_edges, 'legacy');
one_node_edges = find(...
    (ismember(cellgeom.edges(:,1), cluster.boundary, 'legacy') ...
        &  ~ismember(cellgeom.edges(:,2), cluster.boundary, 'legacy')) ...    
    | (ismember(cellgeom.edges(:,2), cluster.boundary, 'legacy') ...
        & ~ismember(cellgeom.edges(:,1), cluster.boundary, 'legacy')));
cluster.n_edges = setdiff(one_node_edges, all_edges, 'legacy');
cluster.area = polyarea(cellgeom.nodes(cluster.boundary, 2), ...
                        cellgeom.nodes(cluster.boundary, 1));
cluster.ratio = sum(cellgeom.edges_length(b_edges)) / ...
    sqrt(4 * pi * cluster.area);
