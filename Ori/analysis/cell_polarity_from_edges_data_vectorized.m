function [cell_score cell_mean_intensity ap_ratio dv_ratio rerun_data] = ...
    cell_polarity_from_edges_data_vectorized(seq, ang_vals, ch1_vals, cells, ...
    edges_data_map, data, edge_len_thresh, rerun_data)
%edges_data_map = A mapping from all edges to edges in ang_vals and ch1_vals.
%   usually of the form inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
%                       inverse_edges_map(edges) = 1:length(edges);
%cells = cells to analyze.

if islogical(cells)
    cells = find(cells);
end

% ind = data.edges.selected & data.edges.len > 10;
% ind = ind(:, find(edges_data_map));

cell_score = nan(length(seq.frames), length(cells));
cell_mean_intensity = cell_score;
dv_ratio = cell_score;
ap_ratio = cell_score;

if nargin < 8 || isempty(rerun_data)
    cells_edges_list(1, length(cells)) = ...
        struct('ap', [], 'dv', [], 'diag', [], 'cell_ap', [], ...
        'cell_dv', [], 'cell_diag', []);
    rerun_data.num_edges_per_cell = nan(length(seq.frames), length(cells));
    for i = 1:length(seq.frames)
        cells_edges_list(:) = ...
            struct('ap', [], 'dv', [], 'diag', [], 'cell_ap', [], ...
            'cell_dv', [], 'cell_diag', []);

        ecm = seq.frames(i).cellgeom.edgecellmap;
        ecm_max = accumarray(ecm(:, 1), 1:size(ecm, 1), [], @max);
        ecm_min = accumarray(ecm(:, 1), 1:size(ecm, 1), [], @min);
        for j = 1:length(cells)
            if ~data.cells.selected(i, cells(j))
                continue
            end

            cell_edges = ecm(ecm_min(seq.cells_map(i, cells(j))):ecm_max(seq.cells_map(i, cells(j))), 2);
            cell_edges = nonzeros(seq.inv_edges_map(i, cell_edges));
            cell_edges = cell_edges(data.edges.len(i, cell_edges) > edge_len_thresh);
            cell_edges = edges_data_map(cell_edges);
%             cell_edges = nonzeros(cell_edges);
            [ap dv] = ap_dv_edges(ang_vals(i, cell_edges), 60, 30);
            cells_edges_list(j).ap = cell_edges(ap);
            cells_edges_list(j).dv = cell_edges(dv);
            cells_edges_list(j).diag = cell_edges(~(ap | dv));
            cells_edges_list(j).cell_ap = ones(size(cell_edges(ap)))' .* j;%...
%                 sub2ind(size(rerun_data.cells_edges_list), i, j);
            cells_edges_list(j).cell_dv = ones(size(cell_edges(dv)))' .* j;%...
%                 sub2ind(size(rerun_data.cells_edges_list), i, j) ; 
            cells_edges_list(j).cell_diag = ones(size(cell_edges(~(ap | dv))))' .* j;%...
%                 sub2ind(size(rerun_data.cells_edges_list), i, j);
            rerun_data.num_edges_per_cell(i, j) = length(cell_edges);
        end
        rerun_data.ap(i).list = [cells_edges_list(:).ap];
        rerun_data.dv(i).list = [cells_edges_list(:).dv];
        rerun_data.diag(i).list = [cells_edges_list(:).diag];

        rerun_data.ap(i).cell = vertcat(cells_edges_list(:).cell_ap);
        rerun_data.dv(i).cell = vertcat(cells_edges_list(:).cell_dv);
        rerun_data.diag(i).cell = vertcat(cells_edges_list(:).cell_diag);
    end
end

for i = 1:length(seq.frames)
    ap_sum = accumarray(rerun_data.ap(i).cell, ...
        rerun_data.ap(i).list, ...
        [length(cells) 1], ...
        @(x) sum(ch1_vals(i, x)), 0);
    dv_sum = accumarray(rerun_data.dv(i).cell, ...
        rerun_data.dv(i).list, ...
        [length(cells) 1], ...
        @(x) sum(ch1_vals(i, x)), 0);
    diag_sum = accumarray(rerun_data.diag(i).cell, ...
        rerun_data.diag(i).list, ...
        [length(cells) 1], ...
        @(x) sum(ch1_vals(i, x)), 0);

    ap_mean = ap_sum ./ accumarray(rerun_data.ap(i).cell,...
        rerun_data.ap(i).list, ...
        [length(cells) 1], @(x) length(x), nan);
    dv_mean = dv_sum./ accumarray(rerun_data.dv(i).cell, ...
        rerun_data.dv(i).list, ...
        [length(cells) 1], @(x) length(x), nan);    
    
    cell_score(i, :) = ap_mean ./ dv_mean;
    cell_mean_intensity(i, :) = (ap_sum + dv_sum + diag_sum)' ./ rerun_data.num_edges_per_cell(i, :); 

    ap_ratio(i, :) = accumarray(rerun_data.ap(i).cell, ...
        rerun_data.ap(i).list, ...
        [length(cells) 1], ...
        @(x) max(ch1_vals(i, x))/min(ch1_vals(i, x)), nan);
    dv_ratio(i, :) = accumarray(rerun_data.dv(i).cell, ...
        rerun_data.dv(i).list, ...
        [length(cells) 1], ...
        @(x) max(ch1_vals(i, x))/min(ch1_vals(i, x)), nan);
end

cell_score = reallog(cell_score)/reallog(2);
dv_ratio = reallog(dv_ratio)/reallog(2);
ap_ratio = reallog(ap_ratio)/reallog(2);

% cell_score = reshape(cell_score, length(seq.frames), length(cells));
% cell_mean_intensity = reshape(cell_mean_intensity, length(seq.frames), length(cells));
% dv_ratio = reshape(dv_ratio, length(seq.frames), length(cells));
% ap_ratio= reshape(ap_ratio, length(seq.frames), length(cells));

function val = ratio_within_range(ang, ch1, ang_min, ang_max)
edges_vals = ch1((ang >= ang_min) & (ang <= ang_max));
if ~isempty(edges_vals) && length(edges_vals) > 1
    val = max(edges_vals)/min(edges_vals);
else
    val = nan;
end


function val = ratio_within_range_oriented(ang, ch1, ang_min, ang_max, pos)
ind = (ang >= ang_min) & (ang <= ang_max);
edges_vals = ch1(ind);
if ~isempty(edges_vals) && length(edges_vals) > 1
    pos = pos(ind);
    [pos ind] = sort(pos);
    edges_vals = edges_vals(ind);
    val = edges_vals(1)/edges_vals(end);
else
    val = nan;
end

function [val] = score_per_cell(ang, ch1, ch2, len, vel)
% [val alpha] = vec_over_len(2*ang, ch1);
val = ap_dv_ratio(ang, ch1, 60, 30);


function val = ap_dv_ratio(ch1, ap, dv)
ap = ch1(ang >= ap_ang);
dv = ch1(ang <= dv_ang);
if ~isempty(ap) && ~isempty(dv)
    val = mean(ap)/mean(dv);
else
    val = nan;
end

function [ap dv] = ap_dv_edges(ang, ap_ang, dv_ang)
ap = ang >= ap_ang;
dv = ang <= dv_ang;