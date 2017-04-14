function cell = cell_from_pos(x, y, cellgeom)
%Given a point (x,y) return returns the cell containing that point
%If the point is on a boudary of two cells it returns the cell whose 
%centeroid is closer to the given point.
%The containing cell must be among the NUM_CELLS_THRESHOLD cells whose
%centroids are closest to the given point.
%Returns zero if fails to find a containing cell.

NUM_CELLS_THRESHOLD = 5;
d=((cellgeom.circles(:,1)-y).^2 + (cellgeom.circles(:,2)-x).^2);
[d,I] = sort(d);
cnt = 1;
inpoly = false;
while ~inpoly;
    if cnt > NUM_CELLS_THRESHOLD
        cell = 0;
        return;
    end
    nodes = cellgeom.faces(I(cnt), :);
    nodes = nonzeros(nodes(~isnan(nodes)));
%    nodes = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 1) == I(cnt), 2);
    inpoly = inpolygon(x, y, cellgeom.nodes(nodes, 2), cellgeom.nodes(nodes, 1));
    cnt = cnt +1;
end
cell = I(cnt-1);