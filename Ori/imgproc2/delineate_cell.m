function [geom success] = delineate_cell(geom, activefig, tracking_state)
success = false;

dist_thresh = 25; %if user clicks at a position more than sqrt(dist_thresh)
% away from the closest node, create a new node, otherwise assume the user
% meant to use the closest node.

h = zeros(0);
pos_vec = get(activefig, 'position');
marker_size = pos_vec(3)/4;    

        
ok_nodes = true(size(geom.nodes, 1), 1);
cnt = 1;
[x(cnt), y(cnt), button] = ginput(1);
while ~(isempty(x(cnt)) || button == 27 || button == 3)
    d=(geom.nodes(ok_nodes, 1) - y(cnt)).^2 + (geom.nodes(ok_nodes, 2) - x(cnt)).^2;
    [D, node] = min(d);
    temp_nodes = find(ok_nodes, node);
    node = temp_nodes(node);
    if D < dist_thresh
        node_list(cnt) = node;
        ok_nodes(node) = false;
        current_x = geom.nodes(node, 2);
        current_y = geom.nodes(node, 1);
        h(end+1) = scatter(get(activefig, 'CurrentAxes'), current_x, current_y, marker_size/2, 'r', 'o');
    else
        node_list(cnt) = 0;
        current_x = x(cnt);
        current_y = y(cnt);
        h(end+1) = scatter(get(activefig, 'CurrentAxes'), current_x, current_y, marker_size*2, 'b', 'x');
    end
    if cnt > 1
        h(end+1) = plot(get(activefig, 'CurrentAxes'), [prev_x current_x], [prev_y current_y], 'color', 'm');
    end
    prev_x = current_x;
    prev_y = current_y;
    cnt = cnt + 1;
    [x(cnt), y(cnt), button] = ginput(1);
end
delete(h(ishandle(h)));

if cnt < 4
    return
end

new_cell = size(geom.circles, 1) + 1;
new_nodes = node_list == 0;
node_list(new_nodes) = size(geom.nodes, 1) + (1:nnz(new_nodes));
geom.nodes(end + (1:nnz(new_nodes)), :) = [y(new_nodes)' x(new_nodes)'];

[cen_x cen_y] = poly_centroid(...
    geom.nodes(node_list, 1), geom.nodes(node_list, 2));
geom.circles(new_cell, 1:2) = [cen_x cen_y];


geom.nodecellmap(end + (1:length(node_list)), 1:2) = ...
    [repmat(new_cell, length(node_list), 1)  node_list(:)];

geom.selected_cells(new_cell) = 0;

geom = update_edgecell(geom);
success = true;    
return

% FOR FUTURE USE, when update_edgecell is not called?

%selected_cells



%update faces
geom.faces(end+1, :) = nan;
geom.faces(end, 1:length(node_list)) = node_list;


%update edge info NOT TAKING CARE OF ALREADY EXISTING EDGES
edges = [node_list(:) node_list([2:end 1])'];
ind = edges(:, 1) > edges(:, 2);
edges(ind, :) = edges(ind, [2 1]);
edges = [geom.edges; edges];
geom.edges = sortrows(edges);

success = true;    

