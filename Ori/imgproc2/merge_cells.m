function [cellgeom success] = merge_cells(cellgeom, activefig, trackingstate)
if nargin < 3 || isempty(trackingstate)
    trackingstate = false;
end 

success = false;
figure(activefig);
[y,x, button] = ginput(1);
if isempty(x) | button == 27 | button == 3  
    return
end
edge = nearest_edge(cellgeom, x, y);
nodes = cellgeom.edges(edge, :);
cells1 = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 2) == nodes(1), 1);
cells2 = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 2) == nodes(2), 1);
cells = intersect(cells1, cells2, 'legacy');
if length(cells) ~= 2
    h= msgbox('Couldn''t find a proper edge where you clicked', '', 'error', 'modal');
    disp(cells);
    waitfor(h);
    return
end
I1 = cells(1);
I2 = cells(2);
[cellgeom success] = unite_cells(cellgeom, I1, I2, 0, ~trackingstate);

if trackingstate
    return
end
