function faces_for_area = faces2ffa(faces);
faces(isnan(faces)) = 0;

faces_for_area = faces;

for cnt = 1:length(faces(:, 1))
    ind = nnz(faces(cnt, :));
    faces_for_area(cnt, ind:end) = faces(cnt, ind);
end
