function [background_levels cells_level] = edge_back_level_from_cells(seq, data, img, ...
    frame_num, edges_pos_x, edges_pos_y, num_neighbors, rad, shape, method)

if nargin < 7 || isempty(num_neighbors)
    num_neighbors = 20;
end
if nargin < 8 || isempty(rad)
    rad = 2;
end
if nargin < 9 || isempty(shape)
    shape = 'square';
end
if nargin < 10 || isempty(method)
    method = 'median';
end


% cell_levels = nan(size(seq.cells_map));
cells_pos = seq.frames(frame_num).cellgeom.circles;
cells_pos_x = cells_pos(seq.cells_map(frame_num, data.cells.selected(frame_num, :)), 2);
cells_pos_y = cells_pos(seq.cells_map(frame_num, data.cells.selected(frame_num, :)), 1);
% cells_pos_x = cells_pos(nonzeros(seq.cells_map(frame_num, :)), 2);
% cells_pos_y = cells_pos(nonzeros(seq.cells_map(frame_num, :)), 1);
cells_level = intensity_at_cell_centers(img, round(cells_pos_x), ...
                round(cells_pos_y), rad, shape, method);

%     local_edges = nonzeros(seq.edges_map(i, edges));

% edges_pos_x = (x1 + x2)/2;
% edges_pos_y = (y1 + y2)/2;

nn = n_nearest_neighobrs_2d(edges_pos_x, edges_pos_y, ...
                            cells_pos_x, cells_pos_y, num_neighbors);

% background_levels = median(cells_level(nn), 2);                        
nn = sort(cells_level(nn), 2);
% background_levels = nn(:, 1);
background_levels = nn(:, ceil(num_neighbors/4));



