function [cellgeom success] = hole2cell(cellgeom, activefig, trackingstate)
success = false;

figure(activefig);


fprintf('Select the gap space');
[first_y, first_x, button] = ginput(1);
if isempty(first_x) || button == 27 || button == 3
    return
end


%  make sure the area is a gap
I1 = cell_from_pos((first_y), (first_x), cellgeom);
if I1 ~= 0
    h = msgbox('A cell already exists at the clicked position.', '', 'error', 'modal');
    waitfor(h);
    return
end


cellgeom = fix_geom(cellgeom);
c = border_components(cellgeom);

start_node = nearest_node((first_y), (first_x), cellgeom);
found_component=0;
for i = 1:length(c)
    if ismember(start_node,c(i).nodes, 'legacy')
        found_component=i;
        break
    end
end

if ~found_component
    msg = 'Could not find nearest component of border nodes';
    h = msgbox(msg, '', 'error', 'modal');
    waitfor(h);
    return
end

new_cell_nodes = c(found_component).nodes;
if length(new_cell_nodes) < 3
    msg = sprintf('%d nodes found. At least 3 nodes are needed to create a new cell', length(new_cell_nodes));
    h = msgbox(msg, '', 'error', 'modal');
    waitfor(h);
    return
end

nodes_positions = cellgeom.nodes(new_cell_nodes,:);
nodes_center = repmat(mean(nodes_positions),length(nodes_positions),1);

nodes_vectors = nodes_positions - nodes_center;

angles = atan2(nodes_vectors(:,1), nodes_vectors(:,2));

[angs angs_I] = sort(angles);

cellgeom.nodecellmap(end +(1:length(angs)), 1) = length(cellgeom.circles)+1;
cellgeom.nodecellmap(end + 1 - (length(angs):-1:1), 2) = new_cell_nodes(angs_I);

cellgeom.circles(end+1,:) = poly_centroid(nodes_positions(:, 1),nodes_positions(:,2));

cellgeom = fix_geom(cellgeom);
    
success = true;
