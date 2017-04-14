function clusters = remove_clusters_with_only_short_edges(clusters, data, misc, min_edge_length, min_edge_length2)

ind = false(size(clusters));
for i = 1:length(ind)
    len = data.edges.len(:, (clusters(i).edges));
    if max(len(:)) < min_edge_length
        if max(len(:)) < min_edge_length2 || all(isinf(misc.sep_times(clusters(i).edges)))
            ind(i) = true;
        end
    end
end

clusters = clusters(~ind);