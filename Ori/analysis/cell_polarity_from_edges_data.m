function [cell_score cell_mean_intensity ap_ratio dv_ratio dv_ratio_oriented ap_ratio_oriented] = cell_polarity_from_edges_data(seq, ang_vals, ch1_vals, cells, edges_data_map, data)
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
dv_ratio_oriented = cell_score;
ap_ratio_oriented = cell_score;
% alpha = cell_score;
for i = 1:length(seq.frames)
    ecm = seq.frames(i).cellgeom.edgecellmap;
%     ecm = uint16(ecm);
    ecm_max = accumarray(ecm(:, 1), 1:size(ecm, 1), [], @max);
    ecm_min = accumarray(ecm(:, 1), 1:size(ecm, 1), [], @min);
    for j = 1:length(cells)
        if ~data.cells.selected(i, cells(j))
            continue
        end
        cell_edges = ecm(ecm_min(seq.cells_map(i, cells(j))):ecm_max(seq.cells_map(i, cells(j))), 2);
        cell_edges = nonzeros(seq.inv_edges_map(i, cell_edges));
        cell_edges = cell_edges(data.edges.len(i, cell_edges) > 8);
        cell_edges_local = seq.edges_map(i, cell_edges); 
        cell_edges = edges_data_map(cell_edges);
%       Edit DLF 2012 September 20, to get rid of zeros
        cell_edges = nonzeros(cell_edges);
        
        
        edges_pos_y = seq.frames(i).cellgeom.nodes(seq.frames(i).cellgeom.edges(cell_edges_local, :), 1);
        edges_pos_y = reshape(edges_pos_y, size(seq.frames(i).cellgeom.edges(cell_edges_local, :)));
        edges_pos_y = mean(edges_pos_y, 2);
        
        edges_pos_x = seq.frames(i).cellgeom.nodes(seq.frames(i).cellgeom.edges(cell_edges_local, :), 2);
        edges_pos_x = reshape(edges_pos_x, size(seq.frames(i).cellgeom.edges(cell_edges_local, :)));
        edges_pos_x = mean(edges_pos_x, 2);
        
%         [cell_score(i, j) alpha(i, j)] = score_per_cell(ang_vals(i, cell_edges), ch1_vals(i, cell_edges));
        cell_score(i, j) = score_per_cell(ang_vals(i, cell_edges), ch1_vals(i, cell_edges));
        cell_mean_intensity(i, j) = mean(ch1_vals(i, cell_edges));
        dv_ratio(i, j) = ratio_within_range(ang_vals(i, cell_edges), ch1_vals(i, cell_edges), 0, 30);
        ap_ratio(i, j) = ratio_within_range(ang_vals(i, cell_edges), ch1_vals(i, cell_edges), 60, 90);
        dv_ratio_oriented(i, j) = ratio_within_range_oriented(ang_vals(i, cell_edges), ch1_vals(i, cell_edges), 0, 30, edges_pos_y);
        ap_ratio_oriented(i, j) = ratio_within_range_oriented(ang_vals(i, cell_edges), ch1_vals(i, cell_edges), 60, 90, edges_pos_x);
        
%         Edit DLF 2013 November 20, to get rid of negative values
        list_of_all = [cell_score(i, j), cell_mean_intensity(i, j), dv_ratio(i, j),...
            ap_ratio(i, j), dv_ratio_oriented(i, j), ap_ratio_oriented(i, j)];
        if any(list_of_all<0)
            display('negative value problem, skipping, problem if this shows up more than a couple times');
                cell_score(i, j) = nan;
                cell_mean_intensity(i, j) = nan;
                dv_ratio(i, j) = nan;
                ap_ratio(i, j) = nan;
                dv_ratio_oriented(i, j) = nan;
                ap_ratio_oriented(i, j) = nan;
        end
            
    end
%     indind = ind(i, :) & ~isnan(ch1_vals(i, :));
%     [mean_r(i) mean_alpha(i)] = vec_over_len(2*ang_vals(i, indind), ch1_vals(i, indind));
end

cell_score = reallog(cell_score)/reallog(2);
dv_ratio = reallog(dv_ratio)/reallog(2);
ap_ratio = reallog(ap_ratio)/reallog(2);
dv_ratio_oriented = reallog(dv_ratio_oriented)/reallog(2);
ap_ratio_oriented = reallog(ap_ratio_oriented)/reallog(2);
% alpha = mod(alpha, 180);
% for i = 1:length(seq.frames)
% %     [mean_r(i) mean_alpha(i)] = vec_over_len(alpha(i, ~isnan(alpha(i, :))), cell_score(i, ~isnan(alpha(i, :))));
% end

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


function val = ap_dv_ratio(ang, ch1, ap_ang, dv_ang)
ap = ch1(ang >= ap_ang);
dv = ch1(ang <= dv_ang);
if ~isempty(ap) && ~isempty(dv)
    val = mean(ap)/mean(dv);
else
    val = nan;
end