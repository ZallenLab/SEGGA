function clusters = remove_clusters_with_faulty_cells(clusters, data);
ind = false(size(clusters));
for i = 1:length(clusters)
    ts = all(data.cells.selected(:, clusters(i).cells) >0, 2);
    ind(i) = any(ts);
end
clusters = clusters(ind);