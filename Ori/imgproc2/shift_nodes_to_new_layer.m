function [x1 x2 y1 y2] = shift_nodes_to_new_layer(seq, frame_num, img, x1, x2, y1, y2, edges, rad)
%edges are expected to be a lniear list, not a logical list
global_edges2selected_edges = zeros(1, length(seq.edges_map(1, :)));
global_edges2selected_edges(edges) = 1:length(edges);
[shifts_x shifts_y] = find(circle(rad));
shifts_x = shifts_x - rad - 1;
shifts_y = shifts_y - rad - 1;

geom = seq.frames(frame_num).cellgeom;
found_local_edges = nonzeros(seq.edges_map(frame_num, edges));
ecm = geom.edgecellmap;
flipped_ncm = geom.nodecellmap(:, [2 1]);

cells_list = faster_unique(ecm(ismember(ecm(:, 2), found_local_edges, 'legacy'), 1), length(geom.circles));
edges_list = faster_unique(ecm(ismember(ecm(:, 1), cells_list, 'legacy'), 2), length(geom.edges));
inv_edges_list(edges_list) = 1:length(edges_list);
cells = false(1, length(geom.circles));
cells(cells_list) = true;

ecm_ind = cells(ecm(:, 1));
ncm_ind = cells(flipped_ncm(:, 2));
ed_scores = zeros(size(edges_list));
ed_lengths = ed_scores;
cells_vals = zeros(length(geom.circles(:, 1)), length(shifts_x));
for k = 1:length(shifts_x)
    pad_img = shift_image_by_padding(img, -shifts_y(k), -shifts_x(k));
    for ed_ind = 1:length(edges_list)
        local_edge = edges_list(ed_ind);
        global_edge = seq.inv_edges_map(frame_num, local_edge);
        if global_edge
            sel_edge = global_edges2selected_edges(global_edge);
        else
            sel_edge = 0;
        end
        if sel_edge
            a = [x1(sel_edge) y1(sel_edge)];
            b = [x2(sel_edge) y2(sel_edge)];
        else
            a = geom.nodes(geom.edges(local_edge, 1), :);
            b = geom.nodes(geom.edges(local_edge, 2), :);
        end
        ed_scores(ed_ind) = check_for_myo(pad_img, a([2 1]), b([2 1]), 'weighted_sum', 0, 1, 0);
        ed_lengths(ed_ind) = sum((a-b).^2);
    end
    cells_vals(:, k) = aggregate_scores(ecm, inv_edges_list, ecm_ind, ed_scores .* ed_lengths, [size(cells_vals, 1), 1]);
end
cells_vals(isnan(cells_vals)) = -inf;
[max_score max_shift] = max(cells_vals, [], 2);
nodes_shift_x = aggregate_scores(flipped_ncm, 1:length(geom.circles), ncm_ind, shifts_x(max_shift), []);
nodes_shift_y = aggregate_scores(flipped_ncm, 1:length(geom.circles), ncm_ind, shifts_y(max_shift), []);
for local_edge = found_local_edges'
    global_edge = seq.inv_edges_map(frame_num, local_edge);
    sel_edge = global_edges2selected_edges(global_edge);
    x1(sel_edge) = x1(sel_edge) + nodes_shift_x(geom.edges(local_edge, 1));
    y1(sel_edge) = y1(sel_edge) + nodes_shift_y(geom.edges(local_edge, 1));
    x2(sel_edge) = x2(sel_edge) + nodes_shift_x(geom.edges(local_edge, 2));
    y2(sel_edge) = y2(sel_edge) + nodes_shift_y(geom.edges(local_edge, 2));
end


function pad_img = shift_image_by_padding(img, x, y)
pad_img = [img(1:y, :); img(max(1, 1-y):end, :)];
pad_img = [pad_img(:, 1:x) pad_img(:, max(1, 1-x):end)];

function cells_vals = aggregate_scores(ecm, map, ind, edges_vals, siz)
cells_vals = accumarray(ecm(ind, 1), edges_vals(map(ecm(ind, 2))), siz, @mean);
