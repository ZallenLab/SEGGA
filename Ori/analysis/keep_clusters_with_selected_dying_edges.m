function clusters = keep_clusters_with_selected_dying_edges(clusters, data, misc)

ind = false(size(clusters));
for i = 1:length(ind)
    vec = false(1, length(clusters(i).edges));
    for cnt_j= 1:length(clusters(i).edges)
        j = clusters(i).edges(cnt_j);
        vec(cnt_j) = any(all(data.cells.selected(misc.dead_init(j):misc.dead_final(j), misc.edges_by_cells(j, :)), 2));
    end
    if ~any(vec)
        ind(i) = true;
    end
end

clusters = clusters(~ind);

