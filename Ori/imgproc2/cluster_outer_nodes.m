function [outer_nodes info]= cluster_outer_nodes(cells, cellgeom);
cells = int16(cells);
%find the edges composing the boundary of the cluster = edges that are
%shared by exactly one cluster cell.
edges = cellgeom.edgecellmap(ismember(cellgeom.edgecellmap(:,1), cells, 'legacy'),2);
edges = sort(edges);
[edges ind dummy] = unique(edges, 'legacy');
edges = edges((ind' - [0 ind(1:end -1)']) == 1); 



%%%%%%%%%%%% - NEW VERSION - FASTER - LESS RELIABLE - %%%%%%%%%%%%%%%%%%%%%
% Might fail if the boundary has two loops coming out of the same node    %

nmap = zeros(length(cellgeom.nodes), 10);

for i = edges'
    do_nmap(cellgeom.edges(i, 1), cellgeom.edges(i, 2));
    do_nmap(cellgeom.edges(i, 2), cellgeom.edges(i, 1));
    
end
    function do_nmap(n1, n2)
        for j = 1:10
            if nmap(n1, j) == n2
                return
            end
            if ~nmap(n1, j)
                nmap(n1, j) = n2;
                return
            end
        end
    end

nmap_length = sum(nmap>0, 2);

for i = find(nmap(:,1))'
    for j = 1:(nmap_length(i) - 1)
        n1 = nmap(i, j);
        n2 = nmap(i, j + 1);
        if ismember(intersect(cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == n1, 1), ...
                cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == n2, 1), 'legacy'), cells, 'legacy')
            nmap(i, j + 1) = nmap(i, mod(j + 1, nmap_length(i)) + 1);
            nmap(i, mod(j + 1, nmap_length(i)) + 1) = n2;
        end
    end
    
end



visits = zeros(length(cellgeom.nodes), 1);
true_visits = zeros(length(cellgeom.nodes), 1);

outer_nodes = zeros(1, length(edges));
outer_nodes(1) = cellgeom.edges(edges(1), 1);
visits(outer_nodes(1)) = 1;
true_visits(outer_nodes(1)) = 1;


outer_nodes(2) = nmap(outer_nodes(1), 1);
visits(outer_nodes(2)) = 1;
true_visits(outer_nodes(2)) = 1;


    info.components = 1;
    info.starts = 1;
    info.success = true;

for i = 3:length(edges)
    if visits(outer_nodes(i-1)) == 1 && (nmap_length(outer_nodes(i-1)) > 2)
        ind = find(nmap(outer_nodes(i-1), :) == outer_nodes(i-2));
        nmap(outer_nodes(i-1),1:nmap_length(outer_nodes(i-1), :)) = ...
            circshift(nmap(outer_nodes(i-1),1:nmap_length(outer_nodes(i-1), :)),...
            [0 (1 - ind)]);
    end
    if ~(visits(outer_nodes(i-1)) > length(nmap(1,:)))
        nextnode = nmap(outer_nodes(i-1), visits(outer_nodes(i-1)));
    else
        nextnode = 0;
    end
    while nextnode && (nextnode == outer_nodes(i-2) || ...
                        true_visits(nextnode) >= nmap_length(nextnode)/2)
%         temp = nmap(outer_nodes(i-1), visits(outer_nodes(i-1) + 1));
%         nmap(outer_nodes(i-1), visits(outer_nodes(i-1) + 1)) = ...
%             nmap(outer_nodes(i-1), visits(outer_nodes(i-1) + 2));
%         nmap(outer_nodes(i-1), visits(outer_nodes(i-1) + 2)) = temp;
        visits(outer_nodes(i-1)) = visits(outer_nodes(i-1)) + 1;
        if visits(outer_nodes(i-1)) > length(nmap(1,:)) || ...
            ~nmap(outer_nodes(i-1), visits(outer_nodes(i-1)))
            break
        end
        nextnode = nmap(outer_nodes(i-1), visits(outer_nodes(i-1)));
    end
    if visits(outer_nodes(i-1)) > length(nmap(1,:)) || ...
            ~nmap(outer_nodes(i-1), visits(outer_nodes(i-1))) 
        %the cluster has 
        %probably broken up to more than one component
        new_start = find(visits == 0 & (nmap(:,1)), 1);
        if isempty(new_start) & nargout > 1
            info.success = false;
            return
        end
        true_visits(outer_nodes(i-1)) = true_visits(outer_nodes(i-1)) - 1;
        info.ends(info.components(end)) = outer_nodes(i-1);
        outer_nodes(i - 1) = new_start;
        visits(new_start) = 1;
        true_visits(new_start) = 1;
        outer_nodes(i) = nmap(new_start, 1);
        visits(outer_nodes(i)) = 1;
        true_visits(outer_nodes(i)) = 1;

            info.components = info.components + 1;
            info.starts(info.components) = i - 1;


    else
        outer_nodes(i) = nmap(outer_nodes(i-1), visits(outer_nodes(i-1)));
        visits(outer_nodes(i)) = visits(outer_nodes(i)) + 1;
        true_visits(outer_nodes(i)) = true_visits(outer_nodes(i)) + 1;
    end
end
for i = 2:length(info.components)
    outer_nodes = [outer_nodes(info.start(info.components(i-1)):info.start(info.components(i)) - 1) ; ...
        info.ends(i - 1) ; outer_nodes(info.start(info.components(i)):end)];
    info.starts(i) = info.starts(i) + i - 1;
end
return


%%%%%%%%%%%% - OLD VERSION - SLOWER - MORE RELIABLE - %%%%%%%%%%%%%%%%%%%%%

%nodes on the boundary 
%of the cluster have a higher number of edges than cells belonging to the
%cluster
%(some of the edges belong to cells outside the cluster).
nodes = cellgeom.nodecellmap(ismember(cellgeom.nodecellmap(:,1), cells), 2);
nodes = sort(nodes);
[nodes ind dummy] = unique(nodes);

% global summary
% nodes_num_edges = [summary.nodeInfo(summary.nodenum2sel(nodes)).numEdges];
% outer_nodes = nodes((ind' - [0 ind(1:end -1)']) < nodes_num_edges); 

nodes_num_edges = hist(cellgeom.edges(:), 1:length(cellgeom.nodes(:,1)));
outer_nodes = nodes((ind' - [0 ind(1:end -1)']) < nodes_num_edges(nodes)); 


%add the first two nodes to the sorted nodes vector.
sorted_nodes = outer_nodes(1);
remaining_outer_nodes = outer_nodes(2:end);
nodes_vectors(:,1) = cellgeom.nodes(remaining_outer_nodes,1) - cellgeom.nodes(sorted_nodes(end),1);
nodes_vectors(:,2) = cellgeom.nodes(remaining_outer_nodes,2) - cellgeom.nodes(sorted_nodes(end),2);

candidate_nodes = cellgeom.edges(edges(...
        find(cellgeom.edges(edges,1) == sorted_nodes(end))),2);
candidate_nodes = [candidate_nodes; ...
    cellgeom.edges(edges(...
    find(cellgeom.edges(edges,2) == sorted_nodes(end))),1)];
candidate_nodes = intersect(candidate_nodes, remaining_outer_nodes);
if length(candidate_nodes) < 2
    
    return
end
sorted_nodes(end+1) = candidate_nodes(1);
remaining_outer_nodes = setdiff(remaining_outer_nodes, candidate_nodes(1));

% [D, node] = min(sum(nodes_vectors.^2'));
% sorted_nodes(end+1) = remaining_outer_nodes(node);
% remaining_outer_nodes = [remaining_outer_nodes(1:node-1); remaining_outer_nodes(node+1:end)];

%make sure each node in remaining_nodes is listed the same number of times
%it should be connected.
for i = 1:length(outer_nodes)
    candidate_nodes = cellgeom.edges(find(cellgeom.edges(:,1) == outer_nodes(i)),2);
    candidate_nodes = [candidate_nodes; ...
        cellgeom.edges(find(cellgeom.edges(:,2) == outer_nodes(i)),1)];
    candidate_nodes = intersect(candidate_nodes, outer_nodes);
    node_cells = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,2) == outer_nodes(i)),1);
    node_cells = intersect(node_cells, cells);
    shared_cells_num = zeros(1,length(candidate_nodes));
    for j = 1:length(candidate_nodes)
        candidate_node_cells = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,2) == candidate_nodes(j)),1);
        candidate_node_cells = intersect(candidate_node_cells, cells);
        shared_cells_num(j) = length(intersect(candidate_node_cells, node_cells));
    end
    candidate_nodes = candidate_nodes(shared_cells_num == 1);
    if length(candidate_nodes) > 2
       num_to_add = round(length(candidate_nodes)/2 - 1);
       remaining_outer_nodes(end + 1 : end + num_to_add) = outer_nodes(i);
    end
end

%set the orientation to follow that of the cells.
edge = find((cellgeom.edges(:,1) == sorted_nodes(1) & cellgeom.edges(:,2) == sorted_nodes(2)) ...
    | (cellgeom.edges(:,1) == sorted_nodes(2) & cellgeom.edges(:,2) == sorted_nodes(1)));
cell = cellgeom.edgecellmap(find(cellgeom.edgecellmap(:,2) == edge),1);
cell = intersect(cell, cells);

cell_nodes = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1) == cell),2);
if find(cell_nodes == sorted_nodes(1)) < find(cell_nodes == sorted_nodes(2))
    sorted_nodes = circshift(sorted_nodes, [1 1]);
end

%sort the nodes according the the angle between the last edge and the next
%edge
for i = 1:length(remaining_outer_nodes)
    vector = cellgeom.nodes(sorted_nodes(end),:) - cellgeom.nodes(sorted_nodes(end - 1),:);
    last_angle = atan2(vector(1), -vector(2));
    candidate_nodes = cellgeom.edges(edges...
        (find(cellgeom.edges(edges,1) == sorted_nodes(end))),2);
    candidate_nodes = [candidate_nodes; ...
        cellgeom.edges(edges(...
        find(cellgeom.edges(edges,2) == sorted_nodes(end))),1)];
    candidate_nodes = intersect(candidate_nodes, remaining_outer_nodes);
    candidate_nodes = setdiff(candidate_nodes, sorted_nodes(end - 1));
    
    vector_x = cellgeom.nodes(sorted_nodes(end),2) - cellgeom.nodes(candidate_nodes,2);
    vector_y = cellgeom.nodes(sorted_nodes(end),1) - cellgeom.nodes(candidate_nodes,1);    
    angles = atan2(vector_y, -vector_x);
    
    %make sure the angle difference between last_angle and angles is in the
    %(-2pi, 0] interval.
    angles(last_angle - angles < 0) = angles(last_angle - angles < 0) - 2*pi;
    
    [D, node] = min(last_angle - angles);
%     h = scatter(cellgeom.nodes(candidate_nodes(node), 2), cellgeom.nodes(candidate_nodes(node), 1));
%     delete(h);
    try
        sorted_nodes(end+1) = candidate_nodes(node); %This will fail if the 
        %cluster is not simply connected (i.e. the boundary has more than a
        %single connected component) 
    catch
        break
    end
    node_to_remove = (find(remaining_outer_nodes == candidate_nodes(node), 1));  
    remaining_outer_nodes = [remaining_outer_nodes(1:node_to_remove -1);
        remaining_outer_nodes(node_to_remove +1:end)];
end
outer_nodes = sorted_nodes;

end