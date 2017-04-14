function [cellgeom success] = associate_node(cellgeom, activefig, trackingstate)
if nargin < 3 || isempty(trackingstate)
    trackingstate = false;
end
success = false;
figure(activefig);
pos_vec = get(get(activefig,'CurrentAxes'), 'position');
pos_vec2 = get(activefig, 'position');
if trackingstate
    marker_size = pos_vec2(3);    
else
    marker_size = pos_vec2(3) * (pos_vec(3) - pos_vec(1))/3;
end

 
fprintf('Click on the cell you wish to fix.\n');
[y,x, button] = ginput(1);

if ~isempty(x) & button ~= 27 & button ~= 3
    cell = cell_from_pos(y, x, cellgeom);
    if cell == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end

    cell_nodes = cellgeom.nodecellmap(cellgeom.nodecellmap(:,1) == cell,2);
    d = (cellgeom.circles(cell,2) - cellgeom.nodes(cell_nodes,2)).^2 + ...
        (cellgeom.circles(cell,1) - cellgeom.nodes(cell_nodes,1)).^2;
    r = realsqrt(min(d))/4;
    ptH = drawcircle(cellgeom.circles(cell,2),cellgeom.circles(cell,1),r,'r-');
    nodesH = scatter(get(activefig,'CurrentAxes'), cellgeom.nodes(cell_nodes,2), cellgeom.nodes(cell_nodes,1), marker_size, 'b', 'o');
    nodesH2 = scatter(get(activefig,'CurrentAxes'), cellgeom.nodes(cell_nodes,2), cellgeom.nodes(cell_nodes,1), marker_size, 'b', '.');
    fprintf('Click on a node you wish to add to the cell.\n');
    [y,x, button] = ginput(1);
    if ~isempty(x) & button ~= 27 & button ~= 3
        d=(cellgeom.nodes(:,1)-x).^2 + (cellgeom.nodes(:,2)-y).^2;
        [D,node] = min(d);
        if ismember(node, cell_nodes, 'legacy')
            cellgeom = dis_associate(cellgeom, cell, node, ~trackingstate);
        else
            cellgeom = associate(cellgeom, cell, node, ~trackingstate);
        end
        success = true;
    end
    if ishandle(ptH)
        delete(ptH);
    end
    if ishandle(nodesH)
        delete(nodesH)
    end
    if trackingstate
        return
    end
    wallH = drawgeom(cellgeom, activefig);
end