function cellgeom = select_all_cells(cellgeom, workingarea)

cellgeom.selected_cells = true(1,length(cellgeom.circles(:,1)));
cen = mean(workingarea);
inner_work(:,1) = cen(1)*0.07 + workingarea(:,1) .* 0.93;
inner_work(:,2) = cen(2)*0.07 + workingarea(:,2) .* 0.93;
n_ind = ~inpolygon(cellgeom.nodes(:,1), cellgeom.nodes(:,2), inner_work(:,1), inner_work(:,2));
c_ind = ismember(cellgeom.nodecellmap(:,2), find(n_ind), 'legacy');
cellgeom.selected_cells(cellgeom.nodecellmap(c_ind,1)) = 0;
% cellgeom.selected_cells(cellgeom.border_cells) = 0;
cellgeom.selected_cells(~cellgeom.valid) = 0;