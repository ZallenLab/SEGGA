function [geom success] = remove_cell(geom, activefig, trackingstate)
success = false;

figure(activefig);


fprintf('Select cell to remove');
[y,x, button] = ginput(1);
if isempty(x) || button == 27 || button == 3
    return
end
cell_id = cell_from_pos(y, x, geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end

geom = remove_cell_from_geom(geom, cell_id);
success = true;

function geom = remove_cell_from_geom(geom, cell_id)
geom.circles = [geom.circles(1:cell_id - 1, :); geom.circles(cell_id + 1: end, :)];
geom.selected_cells = reshape(geom.selected_cells, 1, length(geom.selected_cells));
geom.selected_cells = [geom.selected_cells(1:cell_id -1), geom.selected_cells(cell_id + 1: end)];
geom.border_cells = setdiff(geom.border_cells, cell_id, 'legacy');
geom.border_cells(geom.border_cells  > cell_id) = ...
    geom.border_cells(geom.border_cells  > cell_id) - 1;
geom.nodecellmap = geom.nodecellmap(geom.nodecellmap(:,1) ~= cell_id, :);
geom.nodecellmap(geom.nodecellmap(:,1) > cell_id, 1) = ...
    geom.nodecellmap(geom.nodecellmap(:,1) > cell_id, 1) - 1;

