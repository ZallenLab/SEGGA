declareglobs;

if ishandle(selH)
    delete(selH);
end
if isempty(cellgeom)
    return
end
if isempty(cellgeom.selected_cells)
    return
end
pos_vec = get(get(activefig,'CurrentAxes'), 'position');
pos_vec2 = get(activefig, 'position');

marker_size = pos_vec2(3) * (pos_vec(3) - pos_vec(1))/14;


selH = scatter(get(activefig,'CurrentAxes'), cellgeom.circles(cellgeom.selected_cells,2),cellgeom.circles(cellgeom.selected_cells,1), marker_size, 'y', '+');
clear marker_size pos_vec pos_vec2