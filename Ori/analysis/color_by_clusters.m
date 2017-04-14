function seq = color_by_clusters(seq, clusters, ind, data, partiality_method)
custom_win_bool = true; %set to true to modify how long clusters are highlighted
custom_win_rad = 14; %radius number of frames to highlight clusters
center_method = 0;
% method 0: use the center of the clusters data (begin + e)/2
% method 1: use the 'f' time (formation) - same as nlost
if nargin < 5 || isempty(partiality_method)
    partiality_method = 0;
    % method 0; (partial) exclude cell if not in ROI 
    % method 1; (whole exclusion) exclude cluster if any cell is missing from ROI
    % method 2; (whole inclustion) include all cells when possible
end

if nargin < 3 || isempty(ind)
    ind = 1:length(clusters);
end

if islogical(ind)
    ind = find(ind);
end

if nargin <4 || isempty(data)
    data = seq2data(seq);
end

colors = get_cluster_colors(1:length(clusters));
for i = 1:length(seq.frames)
    cells_count = zeros(1, length(seq.frames(i).cellgeom.circles(:, 1)));
    cells_colors = zeros(length(seq.frames(i).cellgeom.circles(:, 1)), 3);
    for j = ind
        if custom_win_bool
            switch center_method
                case 0
                    center = floor((clusters(j).begin_time + clusters(j).e)/2);
                case 1
                    center = clusters(j).f;
                otherwise
                    display(['center method ',num2str(center_method),' undefined - quitting color_by_clusters']);
            end
            
            left = max(center - custom_win_rad,1);
            right = min(center + custom_win_rad,length(seq.frames));
        else
            left = clusters(j).begin_time;
            right = clusters(j).e;
        end
        
        if i >= left && i <= right
            cells = seq.cells_map(i, clusters(j).cells);
            switch partiality_method
                case 0 % partial inclusion (cell based)
                    cells = cells(data.cells.selected(i,clusters(j).cells));
                case 1 % whole exclusion - remove cluster if any cell is not in ROI poly
                    completeness = all(data.cells.selected(i,clusters(j).cells));
                    if ~completeness
                        continue % cluster will not be highlighted if any cell is missing from poly
                    end                    
                case 2 % whole inclusion - keep cluster as far as possible 
                    % need not modify cells for whole inclusion (default)
                otherwise
                    display(['partiality method ',num2str(partiality_method),' undefined - quitting color_by_clusters']);
            end
            cells = nonzeros(cells);
            cells_count(cells) = cells_count(cells) + 1;
            for k = 1:3
%                 cells_colors(cells, k) = cells_colors(cells, k) + colors(j, k);
                 cells_colors(cells, k) = colors(j, k);
            end
        end
    end
    seq.frames(i).cells = find(cells_count);
%     for k = 1:3
%         cells_colors(seq.frames(i).cells, k) = ...
%             cells_colors(seq.frames(i).cells, k) ./ cells_count(seq.frames(i).cells)';
%     end
    seq.frames(i).cells_colors = cells_colors;
    seq.frames(i).cells_alphas = 0.3 + 0.3 * min(cells_count-1,1)';
end