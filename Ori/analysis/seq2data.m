function data = seq2data(seq, poly_seq, poly_frame_ind, all_cells)
if nargin < 4 || isempty(all_cells)
    all_cells = false;
end
if nargin < 2 || (nargin < 3 && ~isempty(poly_seq))
    if ~isempty(dir('poly_seq.mat'))
        load(fullfile(seq.directory, 'poly_seq.mat'))
    else
        poly_seq = [];
    end
%     disp('define poly_seq or set it to an empty array to use the cells highlighted in each frame');
%     return
end
data.cells.selected = false(length(seq.frames), size(seq.cells_map, 2));
data.cells.area = zeros(size(data.cells.selected));
data.cells.peri = data.cells.area;
data.cells.num_sides = data.cells.area;
data.cells.circ = data.cells.area;

if ~isempty(poly_seq)
    for i = 1:length(seq.frames)
        %assuming frame numbers are sorted. the poly/frame with the closest t and z
        %indices should be used, not the one with the closest frame index. 
        [dummy poly_ind(i)] = min(abs(i - poly_frame_ind));
    end
end

for i = 1:length(seq.frames)
    geom = (seq.frames(i).cellgeom);
    if max(geom.edgecellmap(:, 2)) > size(geom.edges, 1)
        geom = fix_geom(geom);
    end
    [frame_data, full_frame_data] = static_data_function(geom, 0, 1);
    
    if isempty(poly_seq)
        full_frame_data.selected = false(size(geom.border_cells));
        full_frame_data.selected(seq.frames(i).cells) = 1;
    else
        %Use the sequence of polygon defining a region of interest to
        %select cells for analysis.
        x = poly_seq(poly_ind(i)).x; 
        y = poly_seq(poly_ind(i)).y;
        full_frame_data.selected = cells_in_poly(geom, y, x);
    end
    if ~all_cells
    %make sure cells selected for analysis are not on the border.
        full_frame_data.selected = full_frame_data.selected & ~(geom.border_cells);
    end

    %add the all data fields of the current frame to the growing data struct
    data = full2data(seq, full_frame_data, data, i);
    
    %edges are selected if at least one of the two cells of which they are part, is selected 
    edges_sel = ...
        accumarray(geom.edgecellmap(:, 2), ...
                   full_frame_data.selected(geom.edgecellmap(:, 1)), ...
                   [size(geom.edges, 1), 1]) ...
        > 0;
    edges_ang = edges_angs_from_geom(geom);
    edges_length = edges_len_from_geom(geom);
    edges_sel = edges_sel & edges_length > 0; %1/25/2010 --Ori 
    edges_sel_dis_zeros = edges_sel; %9/11/2012 --Dene 
    data = loc_edges2data(seq, edges_sel, data, 'selected', i);
    data = loc_edges2data(seq, edges_length, data, 'len', i);
    data = loc_edges2data(seq, edges_ang, data, 'angles', i);
    data = loc_edges2data(seq, edges_sel_dis_zeros, data, 'selected_withphantoms', i);
end

function data = full2data(seq, full, data, i)
fn = fieldnames(full);
for j = 1:length(fn);
    data.cells.(fn{j})(i, seq.inv_cells_map(i, 1:length(full.(fn{j})))) = full.(fn{j});
end

function data = loc_edges2data(seq, edges_data, data, field, i)
ind = seq.inv_edges_map(i, :) > 0;
if length(ind) > length(edges_data)
    ind = ind(1:length(edges_data));
end
edges_data = edges_data(ind);
data.edges.(field)(i, seq.inv_edges_map(i, ind)) = edges_data;
