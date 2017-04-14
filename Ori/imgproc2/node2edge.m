function [cellgeom success] = node2edge(cellgeom, activefig, trackingstate)
if nargin < 3 || isempty(trackingstate)
    trackingstate = false;
end 

success = false;

pos_vec = get(get(activefig,'CurrentAxes'), 'position');
pos_vec2 = get(activefig, 'position');
if trackingstate
    marker_size = pos_vec2(3);    
else
    marker_size = pos_vec2(3) * (pos_vec(3) - pos_vec(1))/6;
end



figure(activefig);
edgelength = 2;

% fprintf('You may add an edge between two cells sharing a node, but not an edge.\n');
% fprintf('Selecting the same cell twice will allow you to split the cell by adding an edge between two nodes.\n');
% fprintf('Click near the center of the first cell. Press Return to abort.\n');
[y,x, button] = ginput(1);
 
if isempty(x) | button == 27 | button == 3
    return
end
I1 = cell_from_pos(y, x, cellgeom);
if I1 == 0
    if exist('ptH') && ishandle(ptH)
        delete(ptH);
    end
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end
d = (cellgeom.circles(I1,2) - cellgeom.nodes(:,2)).^2 + ...
    (cellgeom.circles(I1,1) - cellgeom.nodes(:,1)).^2;
r = realsqrt(min(d))/4;
ptH = drawcircle(cellgeom.circles(I1,2),cellgeom.circles(I1,1),r,'r-');
fprintf('Click near the center of the second cell. Press Return to abort.\n');
[y,x, button] = ginput(1);
if isempty(x) | button == 27 | button == 3
    if ishandle(ptH)
        delete(ptH);
    end
    return
end
I2 = cell_from_pos(y, x, cellgeom);
if I2 == 0
    if ishandle(ptH)
        delete(ptH);
    end
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end

if I1 == I2
    msg = ['You selected the same cell twice. '...
        'You must select two distinct cells in order to transform '...
        'the node between them into an edge. '];
    msgboxH = msgbox(msg, 'Warn', 'modal');
    waitfor(msgboxH);
    if ishandle(ptH)
        delete(ptH);
    end
    return
else 
    %make an edge out of a node.
    ns1 = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1) == I1),2);
    ns2 = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1) == I2),2);
    ns = intersect(ns1, ns2, 'legacy');
    if length(ns) < 1
        msgboxH = msgbox('Selected cells do not share a node.', 'No no no!', 'Warn', 'modal');
        waitfor(msgboxH);
        if ishandle(ptH)
            delete(ptH);
        end
        return
    elseif length(ns) > 1
        msgboxH = msgbox('Selected cells share more than one node.', 'No no no!', 'Warn', 'modal');
        waitfor(msgboxH);
        if ishandle(ptH)
            delete(ptH);
        end
        return
    end
    %add new node to node list
    %reposition old node and new node
    ax = cellgeom.circles(I1,1:2) - cellgeom.circles(I2,1:2);
    ax = ax/norm(ax);
    ax = circshift(ax,[0 1]);
    ax(1) = -ax(1);
    cellgeom.nodes(end+1,1:2) = cellgeom.nodes(ns,1:2) + edgelength*ax;
    cellgeom.nodes(ns,1:2) = cellgeom.nodes(ns,1:2) - edgelength*ax;
    new_node = length(cellgeom.nodes(:,1));
    %update nodecellmap 
    cellgeom.nodecellmap(end+1,1:2) = [I1 new_node];
    cellgeom.nodecellmap(end+1,1:2) = [I2 new_node];             
    cell_list = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,2) == ns),1);
    cell_list = setdiff(cell_list, [I1 I2], 'legacy');
    for i =1:length(cell_list)
        if norm(cellgeom.circles(cell_list(i),1:2) - cellgeom.nodes(ns,1:2)) > ...
                norm(cellgeom.circles(cell_list(i),1:2) - cellgeom.nodes(new_node,1:2))
            index = find((cellgeom.nodecellmap(:,1) == cell_list(i)) &  (cellgeom.nodecellmap(:,2) == ns));
            cellgeom.nodecellmap(index,2) = new_node;                    
        end
    end
    touched_cells = [cell_list I1 I2];
end


cellgeom = update_edgecell(cellgeom);
for i = 1:length(touched_cells)
    cellgeom.circles(touched_cells(i),1:2) = ...
        centroid(cellgeom.nodes(cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1) == touched_cells(i)),2),1:2));
end
if ishandle(ptH)
    delete(ptH);
end

success = true;

if trackingstate
    return
end

%if called from tracking, do_faces = 0 but faces will be updated with a
%call to fix_geom at tracking/edit_t
for i = 1:length(touched_cells)
    nmap = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 1) == touched_cells(i), 2);
    cellgeom.faces(touched_cells(i), :) = nan;
    cellgeom.faces(touched_cells(i), 1:length(nmap)) = nmap;
end
wallH = drawgeom(cellgeom, activefig);
eidx = find(cellgeom.edges(:,1) == ns &  cellgeom.edges(:,2) == new_node); 
if length(wallH) >= eidx
    delete(wallH(eidx));
end
wallH(eidx) = plot([cellgeom.nodes(cellgeom.edges(eidx,1),2) cellgeom.nodes(cellgeom.edges(eidx,2),2)], [cellgeom.nodes(cellgeom.edges(eidx,1),1) cellgeom.nodes(cellgeom.edges(eidx,2),1)], 'r');
draw_selected_cells;


