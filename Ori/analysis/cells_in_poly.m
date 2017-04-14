function cells = cells_in_poly(geom, x, y, cells)
if nargin < 4 || isempty(cells)
    cells = true(size(geom.circles, 1), 1);
end

%%%%%%%%%%%%%%%%%%%%%% CHANGED -- Ori, Oct 29 2009 %%%%%%%%%%%%%%%%%%%%%%%%
% This changed the order of cells. Should not affect results, only
% perforamce.
% if ~islogical(cells)
%     cells_list = cells;
%     cells = false(size(geom.circles, 1), 1);
%     cells(cells_list) = true;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cells = inpolygon(geom.circles(cells,1), geom.circles(cells,2), y, x);