function seq = color_clusters(orbit, field_name, f_field_name, ghost_field, seq)
if nargin < 5
    global seq
end


if length(seq.clusters_colors) < length(seq.clusters_map(1,:))
    seq.clusters_colors(end + 1:length(seq.clusters_map(1,:))) = ...
        length(seq.clusters_colors) + 1: length(seq.clusters_map(1,:));
end
    
for j = 1:length(orbit)
    cell_colors = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)), 3);
    cell_weight = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)), 1);
    cell_alphas = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)), 1);
    if length(seq.frames(orbit(j)).clusters_data)
        cluster_colors(find(seq.inv_clusters_map(orbit(j), :)), 1:3) = ...
            get_cluster_colors(seq.clusters_colors(...
            nonzeros(seq.inv_clusters_map(orbit(j), :))));
        for ii = 1:length(seq.frames(orbit(j)).clusters_data)
            if length(seq.frames(orbit(j)).clusters_data(ii).cells)
                cell_weight(seq.frames(orbit(j)).clusters_data(ii).cells) = ...
                    cell_weight(seq.frames(orbit(j)).clusters_data(ii).cells) + 1;
                c = repmat(cluster_colors(ii, :), [length(seq.frames(orbit(j)).clusters_data(ii).cells), 1]);
                cell_colors(seq.frames(orbit(j)).clusters_data(ii).cells, :) = ...
                    cell_colors(seq.frames(orbit(j)).clusters_data(ii).cells, :) + c;
            end
        end
        cells = find(cell_weight);
        cell_colors(cells, :) = cell_colors(cells,:) ./ [cell_weight(cells) cell_weight(cells) cell_weight(cells)];
        cell_alphas(cells) = min(cell_weight(cells) / 5, 1);
        seq.frames(orbit(j)).cells = cells;
        seq.frames(orbit(j)).cells_colors = ...
            zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)),3);
        seq.frames(orbit(j)).cells_colors(nonzeros(cells),:) = cell_colors(nonzeros(cells),:);
        seq.frames(orbit(j)).cells_alphas = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)),1);
        seq.frames(orbit(j)).cells_alphas(nonzeros(cells),:) = cell_alphas(nonzeros(cells),:); 
    else
        seq.frames(orbit(j)).cells = [];
    end
end
