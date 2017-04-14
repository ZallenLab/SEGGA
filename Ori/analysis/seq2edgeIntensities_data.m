function [edge_intensity_levels background_levels x1 x2 y1 y2 cells_levels min_pixel] ...
    = seq2edgeIntensities_data(seq, edge_intensity_img_filename, edges, seg_filename,...
                               options, data, cells_sel)
                           
if nargin < 2 || isempty(edge_intensity_img_filename)
    [edge_intensity_img_filename, edge_intensity_img_path] = uigetfile('*.tif', 'Select images for intensity measurements (any timepoint)');
    if isequal(edge_intensity_img_filename, 0) && isequal(edge_intensity_img_path, 0)
        return
    end
    edge_intensity_img_filename = fullfile(edge_intensity_img_path, edge_intensity_img_filename);
end
if ischar(edge_intensity_img_filename)
    edge_intensity_img_filename = {edge_intensity_img_filename};
end
if nargin < 3 || isempty(edges)
%     true(1, size(seq.edges_map, 2)); %WRONG? expecting linear indexing 
%                                      %in definition of global_edges below
    h = msgbox('Please specify which edges to analyze.', 'Error', 'error', 'modal');
    waitfor(h);
    return
elseif islogical(edges)
    edges = find(edges);
end

if nargin < 4 || isempty(seg_filename)
    seg_filename = fullfile(seq.directory, seq.frames(1).img_file);
end
if nargin < 5 || isempty('options')
    options = struct;
end

if nargin < 7 || isempty('cells_sel')
    if length(seq.frames) >1
        cells_sel = find(any(data.cells.selected));
    else
        cells_sel = find(data.cells.selected);
    end
end
%default options
def_options.box_size = 75;
def_options.method = [];
def_options.limit_to_embryo = false;
def_options.smoothen_nodes = false;
def_options.smoothen_edges = true;
def_options.optimize_edges_pos = true;
def_options.edge_positions_from_options = false;
def_options.const_z_shift = 0;
def_options.const_z_for_t = 0;
def_options.const_z_seg = 0;
def_options.z_shift_file = [];
def_options.z_shift_file_for_following = [];
def_options.follow_edges_along_z = false;
def_options.background.only = false;

%overlay input options on default options.
options = overlay_struct(def_options, options);

%if final edge positions are given frmo an external variable, don't waste
%time optimizing edge positions.
options.smoothen_edges = options.smoothen_edges & ~options.edge_positions_from_options;
options.optimize_edges_pos = options.optimize_edges_pos & ~options.edge_positions_from_options;

if isempty(options.z_shift_file)
    for i = 1:length(seq.frames)
        [z_num t_num] = get_file_nums(seq.frames(i).img_file);
        z_for_t(t_num) = z_num;
    end
else
    [aa bb] = textread(options.z_shift_file, '%d = %d', 'commentstyle', 'matlab');
    z_for_t(aa) = bb;
end
z_for_t = z_for_t + options.const_z_shift;
if options.const_z_for_t
    z_for_t(:) = options.const_z_for_t;
end

if isempty(options.z_shift_file_for_following)
    for i = 1:length(seq.frames)
        [z_num t_num] = get_file_nums(seq.frames(i).img_file);
        z_for_t_follow(t_num) = z_num;
    end
else
    [aa bb] = textread(options.z_shift_file_for_following, '%d = %d', 'commentstyle', 'matlab');
    z_for_t_follow(aa) = bb;
end



if options.smoothen_nodes || options.smoothen_edges
    ebs = global_edges2cells(seq, edges);
    edges_by_cells(edges, :) = ebs;
    flip = edges_orientation(seq, edges, edges_by_cells);
end

if options.smoothen_nodes
    seq = smoothen_movement(seq, edges, ebs, flip);
end
if options.smoothen_edges
    %MESSY repeats below.
    [z_seg, t] = get_file_nums(seq.frames(1).img_file);
    if options.const_z_seg
        z_seg = options.const_z_seg;
    end
    
    img = imread(put_file_nums(seg_filename, seq.frames(1).t, z_seg));
    

    m = size(img, 1);
    n = size(img, 2);
    [x1 x2 y1 y2] = smoothen_edge_positions(seq, edges, ebs, flip, m, n);
elseif ~options.edge_positions_from_options
    [x1 x2 y1 y2] = breakup_lattice_to_edges(seq, edges);
else
    x1 = options.x1;
    x2 = options.x2;
    y1 = options.y1;
    y2 = options.y2;
end



if options.limit_to_embryo
    load(options.poly_file);
end

edge_intensity_levels = nan(length(seq.frames), length(edges), length(edge_intensity_img_filename));
background_levels = edge_intensity_levels;
% cells_sel = find(any(data.cells.selected));
inverse_cells_map = zeros(1, size(seq.cells_map, 2));
inverse_cells_map(cells_sel) = 1:length(cells_sel);
cells_levels = nan([length(seq.frames) length(cells_sel) length(edge_intensity_img_filename)]);
min_pixel = inf(length(seq.frames), length(edge_intensity_img_filename));
for i = 1:length(seq.frames) %assuming one z per time point
    i;
    [z_seg, t] = get_file_nums(seq.frames(i).img_file);
%     t = seq.frames(i).t;
%     z_seg = seq.frames(i).z;
    if options.const_z_seg
        z_seg = options.const_z_seg;
    end
    img = imread(put_file_nums(seg_filename, t, z_seg));
    if options.follow_edges_along_z
        z_path = [];
        if z_seg > z_for_t_follow(t)
            z_path = z:-1:z_for_t_follow(t);
        elseif z_seg < z_for_t_follow(t)
            z_path = z_seg:z_for_t_follow(t);
        end
        img_follow = zeros([size(img) length(z_path)]); 
        for j = 1:length(z_path)
%              img_follow(:, :, j) = double(imread(put_file_nums(seg_filename, t, z_path(j))));
%              img_follow(:, :, j) = local_background_of_image(img_follow(:, :, j), 1);
%              img_follow(:, :, j) = img_follow(:, :, j) > mean(reshape(img_follow(:, :, j), 1, []));
        end
        
        img_follow = zeros([size(img) 2]); 
        cnt = 0;
        for j = [1 length(z_path)]
            cnt = cnt  + 1;
         img_follow(:, :, cnt) = double(imread(put_file_nums(seg_filename, t, z_path(j))));
         img_follow(:, :, cnt) = local_background_of_image(img_follow(:, :, cnt), 1);
        end

        
%         
%         img_follow = diff(img_follow, 1, 3);
%         px = zeros(size(img_follow)); 
%         py = px;
%         
%             px = deriv(img_follow, 4) ;
%             py = deriv(img_follow', 4)' ;
%         
%         for j = 1:size(img_follow, 3)
% %             px(:, :, j) = deriv(img_follow(:, :, j), 4) ./ mean(reshape(img_follow(:, :, j), 1, []));
% %             py(:, :, j) = deriv(img_follow(:, :, j)', 4)' ./ mean(reshape(img_follow(:, :, j), 1, []));
%         end


        [x1(i, :) x2(i, :) y1(i, :) y2(i, :)] = shift_nodes_to_new_layer(...
            seq, i, img_follow(:, :, end), ...
            x1(i, :), x2(i, :), y1(i, :), y2(i, :), ...
            edges, 5);

    end
    local_edges = nonzeros(seq.edges_map(i, edges));
    %global_edges = edges((seq.edges_map(i, edges)) > 0);
    found_edges = find((seq.edges_map(i, edges)));
    for channel = 1:length(edge_intensity_img_filename)
        protein_img(channel).image = double(imread(put_file_nums(edge_intensity_img_filename{channel}, t, z_for_t(t))));
    end
    protein_img_modified = protein_img; %for backgronud levels    
    m = size(protein_img(1).image, 1);
    n = size(protein_img(1).image, 2);
    if options.limit_to_embryo %do not include regions outside the embryo for background calculations.
        poly = get_poly_for_frame(i, poly_frame_ind, poly_seq);
        for channel = 1:length(protein_img)
            protein_img_modified(channel).image(~poly2mask(poly.y, poly.x, m, n)) ...
                = inf; 
        end
    end
    
    if options.optimize_edges_pos
        rad = 3;
        if options.follow_edges_along_z
            img = img_follow(:, :, end);
        end
        pad_img = zeros(size(img) + [4*rad 4*rad]);
        PSF = fspecial('gaussian',2,3);
        blurred = imfilter(double(img),PSF,'conv');
        pad_img(2*rad + 1: end - 2*rad, 2*rad + 1: end - 2*rad) = +50 + double(blurred);
    end

    
    

    cellgeom = seq.frames(i).cellgeom;
    for ed_num = 1:length(local_edges);
        original_a = cellgeom.nodes(cellgeom.edges(local_edges(ed_num), 1), :);
        original_b = cellgeom.nodes(cellgeom.edges(local_edges(ed_num), 2), :);
%         [a b] = follow_edge_in_z_image(img, seq.frames(i).cellgeom, local_edges(ed_num));
        a = [x1(i, found_edges(ed_num)) y1(i, found_edges(ed_num))];
        b = [x2(i, found_edges(ed_num)) y2(i, found_edges(ed_num))];
        
        if options.optimize_edges_pos
            if sum((a - b).^2) <= 10 &&  sum((original_a - original_b).^2) > sum((a - b).^2)
                a = original_a;
                b = original_b;
            end
            cellgeom.nodes(cellgeom.edges(local_edges(ed_num), 1), :) = a;
            cellgeom.nodes(cellgeom.edges(local_edges(ed_num), 2), :) = b;
            old_a = a;
            old_b = b;
            if sum((a - b).^2) > 10
                [a b] = reposition_edge(pad_img(:, :), cellgeom, local_edges(ed_num), rad);
                if sum((a - b).^2) < 10 
                    a = old_a;
                    b = old_b;
                end
            end
            % Undo changes above so to not move nodes of edges to be
            % repositioned in future iterations of the loop.
            cellgeom.nodes(cellgeom.edges(local_edges(ed_num), 1), :) = original_a;
            cellgeom.nodes(cellgeom.edges(local_edges(ed_num), 2), :) = original_b;
        end

%         a = a([2 1]);
%         b = b([2 1]);
%         if options.follow_edges_along_z
%             [a b] = track_edge_intensity_along_z_stack(a, b, px, py);
%         end
%         a = a([2 1]);
%         b = b([2 1]);        
%         DEBUG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if options.edge_positions_from_options
            a(1) = options.x1(i, found_edges(ed_num));
            a(2) = options.y1(i, found_edges(ed_num));
            b(1) = options.x2(i, found_edges(ed_num));
            b(2) = options.y2(i, found_edges(ed_num));
        end

        x1(i, found_edges(ed_num)) = a(1);
        y1(i, found_edges(ed_num)) = a(2);
        x2(i, found_edges(ed_num)) = b(1);
        y2(i, found_edges(ed_num)) = b(2);
        
        
    end
    for channel = 1:length(edge_intensity_img_filename)
        [background_levels(i, found_edges, channel) ...
            cells_levels(i, inverse_cells_map(data.cells.selected(i, :)), channel)]= ...
            edge_back_level_from_cells(seq, data, protein_img(channel).image, i, ...
            (y1(i, found_edges) + y2(i, found_edges))/2, ...
            (x1(i, found_edges) + x2(i, found_edges))/2);
        min_pixel(i, channel) = min(protein_img(channel).image(:));
    end
    
    for ed_num = 1:length(local_edges);
        a(1) = max(1, min(m, x1(i, found_edges(ed_num))));
        b(1) = max(1, min(m, x2(i, found_edges(ed_num))));
        a(2) = max(1, min(n, y1(i, found_edges(ed_num))));
        b(2) = max(1, min(n, y2(i, found_edges(ed_num))));
        
        for channel = 1:length(edge_intensity_img_filename)
            img_minus_background = protein_img(channel).image - ... 
                background_levels(i, found_edges(ed_num), channel);
            edge_intensity_levels(i, found_edges(ed_num), channel) = ...
                check_for_edge_intensity_val(img_minus_background, a([2 1]), b([2 1]),...
                options.method);
%             background_levels(i, found_edges(ed_num), channel) = ...
%                 find_min_around_point(protein_img_modified(channel).image, ...
%                     (a+b)/2, options.box_size);
        end

    end
end
% edge_intensity_levels = edge_intensity_levels - background_levels;

