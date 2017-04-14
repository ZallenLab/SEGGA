function extend_clusters(span, clusters)
global seq
clusters = reshape(clusters, 1, length(clusters));


for i = clusters
    on_frames = find(seq.clusters_map(:,i));
    min_t = max(min([seq.frames(on_frames).t]) - span, seq.min_t);
    max_t = min(max([seq.frames(on_frames).t]) + span, seq.max_t);    
    min_z = min([seq.frames(on_frames).z]);
    max_z = max([seq.frames(on_frames).z]);

    g_cells = [];
    for j = on_frames'
        g_cells = [g_cells seq.inv_cells_map(j, ...
            seq.frames(j).clusters_data(seq.clusters_map(j,i)).cells)];
    end
    g_cells = unique(g_cells, 'legacy');
    frames_block = nonzeros(seq.frames_num(min_t:max_t, min_z:max_z));
    for t = frames_block(:)' 
        f_cells = nonzeros(seq.cells_map(t, g_cells))';
        if ~seq.clusters_map(t, i)
%             cells = nonzeros(seq.cells_map(t, nonzeros(seq.inv_cells_map(t-1, ...
%                 seq.frames(t-1).clusters_data(seq.clusters_map(t-1, i)).cells))))';            
            if length(seq.frames(t).clusters_data)
                seq.frames(t).clusters_data(end + 1, 1) = build_cluster_data(f_cells, ...
                    seq.frames(t).cellgeom);
            else
                seq.frames(t).clusters_data = build_cluster_data(f_cells, ...
                    seq.frames(t).cellgeom);
            end
            seq.clusters_map(t, i) = length(seq.frames(t).clusters_data);
            seq.inv_clusters_map(t, length(seq.frames(t).clusters_data)) = i;
        elseif length(f_cells) > length(...
            seq.frames(t).clusters_data(seq.clusters_map(t, i)).cells)
            seq.frames(t).clusters_data(seq.clusters_map(t, i)) = ...
                build_cluster_data(f_cells, seq.frames(t).cellgeom);
        end
    end
end