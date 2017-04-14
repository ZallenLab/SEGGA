function clusters = create_reverse_clusters(time_window, min_edge_length,min_edge_length2)

seq = load_dir(pwd);
seq_backwards = seq;
seq_backwards.frames = seq_backwards.frames(end:-1:1);
seq_backwards.cells_map = flipud(seq_backwards.cells_map);
seq_backwards.inv_cells_map = flipud(seq_backwards.inv_cells_map);
seq_backwards.edges_map = flipud(seq_backwards.edges_map);
seq_backwards.inv_edges_map = flipud(seq_backwards.inv_edges_map);

data = seq2data(seq);
data = invert_data_time(data);
data.edges.angles((data.edges.len(:) == 0)) = nan;
disp('misc')
misc = find_clusters_by_edges_init_vars(seq_backwards, data, [], time_window, min_edge_length);
disp('clusters')
clusters = find_clusters_by_edges(seq_backwards, data, time_window, min_edge_length2, misc);
clusters = keep_clusters_with_selected_dying_edges(clusters, data, misc);
clusters = remove_clusters_with_faulty_cells(clusters, data);
clusters = remove_clusters_with_only_short_edges(clusters, data, misc, min_edge_length, min_edge_length2);
clusters = clusters_life_times(clusters, data, misc, time_window);
clusters = clusters([clusters.s] < [clusters.e]);