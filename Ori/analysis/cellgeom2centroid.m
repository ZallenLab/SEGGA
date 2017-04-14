function [pc_x pc_y area] = cellgeom2centroid(cellgeom, faces_for_area)
nodes = reshape(cellgeom.nodes', [], 1);
[pc_x pc_y area] = poly_centroid(nodes(faces_for_area*2), nodes(faces_for_area*2 - 1), 2);
ind = area == 0;
if sum(ind) == 1
    pc_x(ind) = mean([nodes(faces_for_area(ind, :)*2)]);
    pc_y(ind) = mean([nodes(faces_for_area(ind, :)*2 - 1)]);
else
    pc_x(ind) = mean([nodes(faces_for_area(ind, :)*2)], 2);
    pc_y(ind) = mean([nodes(faces_for_area(ind, :)*2 - 1)], 2);
end
