function faces_for_area = cellgeom2faces_for_area(geom)
faces_for_area = geom.faces;
for k = 2:length(geom.faces(1,:))
    ind = isnan(geom.faces(:, k));
    faces_for_area(ind, k) = faces_for_area(ind, k - 1);
end
