function [geom success]= unite_cells(geom, cell1, cell2, quiet_mode, do_faces)
if nargin < 5 || isempty(do_faces)
    do_faces = 0;
end

if nargin < 4 || isempty(quiet_mode)
    quiet_mode = 0;
end
if nargout > 1
    success = false;
end
old_geom = geom;
if cell1 == cell2
    if ~quiet_mode
        h = msgbox('You can''t merge a cell with itself.', 'What was I thinking?', 'warn', 'modal');
        waitfor(h);
    end
    return
end
%make sure cell2 > cell1
if cell2 < cell1
    old_cell1 = cell1;
    cell1 = cell2;
    cell2 = old_cell1;
end

nodes = intersect(...
    geom.nodecellmap(geom.nodecellmap(:,1) == cell1, 2), ...
    geom.nodecellmap(geom.nodecellmap(:,1) == cell2, 2), 'legacy');

if length(nodes) ~= 2
    if ~quiet_mode
        msgboxH = msgbox('I can only merge cells that share two nodes.', '', 'warn', 'modal');
        waitfor(msgboxH);
    end
    return
end

cells_at_node1 = geom.nodecellmap(find(geom.nodecellmap(:,2) == nodes(1)),1);
cells_at_node2 = geom.nodecellmap(find(geom.nodecellmap(:,2) == nodes(2)),1);    
if length(cells_at_node1) < 3 | length(cells_at_node2) < 3
    if ~quiet_mode
        msgboxH = msgbox('Only two cells meet at this node. There''s nothing I can do. Hmmm...','','warn', 'modal');
        waitfor(msgboxH);
    end
    return
end

%this is just a precaution. nodes should already be sorted.
nodes = sort(nodes);
%this is the edge to delete
edge = find((geom.edges(:,1) == nodes(1)) & (geom.edges(:,2) == nodes(2)));

center1 = geom.circles(cell1,1:2);
center2 = geom.circles(cell2,1:2);

%After the edge is deleted, nodes which were associated with 3 cells are
%no longer a corner and therefore are not considered nodes anymore. 
if length(cells_at_node1) == 3 & length(cells_at_node2) > 3

    geom.nodes = [geom.nodes(1:nodes(1) - 1,:) ; geom.nodes(nodes(1) + 1:end,:)];
    geom.nodecellmap = geom.nodecellmap(geom.nodecellmap(:,2) ~= nodes(1), :);
    geom.nodecellmap = geom.nodecellmap(~(geom.nodecellmap(:,2) == nodes(2) & geom.nodecellmap(:,1) == cell2),:);
    geom.nodecellmap(geom.nodecellmap(:,2) > nodes(1), 2) = ...
    geom.nodecellmap(geom.nodecellmap(:,2) > nodes(1), 2) - 1;

    geom.border_nodes = setdiff(geom.border_nodes, nodes(1), 'legacy');
    geom.border_nodes(geom.border_nodes > nodes(1)) = ...
        geom.border_nodes(geom.border_nodes > nodes(1)) - 1;

end

if length(cells_at_node1) > 3 & length(cells_at_node2) == 3

    geom.nodes = [geom.nodes(1:nodes(2) - 1,:) ; geom.nodes(nodes(2) + 1:end,:)];
    geom.nodecellmap = geom.nodecellmap(geom.nodecellmap(:,2) ~= nodes(2),:);
    geom.nodecellmap = geom.nodecellmap(~(geom.nodecellmap(:,2) == nodes(1) & geom.nodecellmap(:,1) == cell2),:);
    geom.nodecellmap(geom.nodecellmap(:,2) > nodes(2), 2) = ...
    geom.nodecellmap(geom.nodecellmap(:,2) > nodes(2), 2) - 1;

    geom.border_nodes = setdiff(geom.border_nodes, nodes(2), 'legacy');
    geom.border_nodes(find(geom.border_nodes > nodes(2))) = ...
        geom.border_nodes(find(geom.border_nodes > nodes(2))) - 1;

end

if length(cells_at_node1) == 3 & length(cells_at_node2) == 3

    geom.nodes = [geom.nodes(1:nodes(1) - 1,:) ; ...
        geom.nodes(nodes(1) + 1:nodes(2) - 1,:); geom.nodes(nodes(2) + 1:end,:)];
    geom.nodecellmap = geom.nodecellmap(geom.nodecellmap(:,2) ~= nodes(1) ...
        & geom.nodecellmap(:,2) ~= nodes(2),:);
    geom.nodecellmap(geom.nodecellmap(:,2) > nodes(2), 2) = ...
        geom.nodecellmap(geom.nodecellmap(:,2) > nodes(2), 2) - 1;
    geom.nodecellmap(geom.nodecellmap(:,2) > nodes(1), 2) = ...
        geom.nodecellmap(geom.nodecellmap(:,2) > nodes(1), 2) - 1;

    geom.border_nodes = setdiff(geom.border_nodes, [nodes(1) nodes(2)], 'legacy');
    geom.border_nodes(find(geom.border_nodes > nodes(2))) = ...
        geom.border_nodes(find(geom.border_nodes > nodes(2))) - 1;
    geom.border_nodes(find(geom.border_nodes > nodes(1))) = ...
        geom.border_nodes(find(geom.border_nodes > nodes(1))) - 1;

end

if length(cells_at_node1) > 3 & length(cells_at_node2) > 3
    geom.nodecellmap = geom.nodecellmap(~(...
        (geom.nodecellmap(:,2) == nodes(1) | geom.nodecellmap(:,2) == nodes(2)) ...
        & geom.nodecellmap(:,1) == cell2), :);
end

geom.circles = [geom.circles(1:cell2 - 1, :); geom.circles(cell2 + 1: end, :)];
geom.selected_cells = reshape(geom.selected_cells, 1, length(geom.selected_cells));
geom.selected_cells = [geom.selected_cells(1:cell2 -1), geom.selected_cells(cell2 + 1: end)];
geom.border_cells = setdiff(geom.border_cells, cell2, 'legacy');
geom.border_cells(geom.border_cells  > cell2) = ...
    geom.border_cells(geom.border_cells  > cell2) - 1;


geom.nodecellmap(geom.nodecellmap(:,1) == cell2, 1) = cell1;
geom.nodecellmap(geom.nodecellmap(:,1) > cell2, 1) = ...
    geom.nodecellmap(geom.nodecellmap(:,1) > cell2, 1) - 1;    

%     [b, m, n] = unique(cellgeom.nodecellmap, 'rows');
%     cellgeom.nodecellmap = cellgeom.nodecellmap(sort(m), :);

geom = update_edgecell(geom);
geom.circles(cell1,1:2) = centroid(...
    geom.nodes(geom.nodecellmap(geom.nodecellmap(:,1) == cell1, 2),1:2));
if do_faces
    geom.faces = geom.faces([1:(cell2-1) (cell2+1):end], :);
    nmap = geom.nodecellmap(geom.nodecellmap(:, 1) == cell1, 2);
    geom.faces(cell1, :) = nan;
    geom.faces(cell1, 1:length(nmap)) = nmap;
end
if nargout > 1
    success = true;
end

