function [cellgeom options] = segment_image(img, options)
options.limit_within = 1;

%test
setdefaults;

all_fields = fieldnames(procparams);
for cnt = 1:length(all_fields);
    if ~isfield(options, all_fields(cnt))
        options.(all_fields{cnt}) = procparams.(all_fields{cnt});
    end
end


if isfield(options, 'workingarea')
    workingarea = options.workingarea;
else
    [imgx, imgy] = size(img);
    workingarea = [1 1; imgx 1; imgx imgy; 1 imgy];
end
if isfield(options, 'auto_limit') && options.auto_limit
    workingarea = limit2embryo(img);
end


size_factor = options.sizefactor;
options.normradius = round(options.normradius * size_factor);
options.normradius2 = round(options.normradius2 * size_factor);
options.blurradius = round(options.blurradius * size_factor);
options.blurradius2 = round(options.blurradius2 * size_factor);
options.blurstrength = options.blurstrength * size_factor;
options.blurstrength2 = options.blurstrength2 * size_factor;
options.allowed_radius = round(options.maxradius * size_factor);
options.med_thresh_radius = round(3 * size_factor);
if strcmp(options.thresh_function, 'binary_image')
    options.min_area = 0;
end



% size_factor = procparams.sizefactor;
% minradius = round(procparams.minradius * size_factor);
% grid_spacing = round(procparams.grid_spacing * floor(1 + size_factor/4));
% maxradius = round(procparams.maxradius * size_factor);
% boundary_thickness = round(procparams.boundary_thickness); 
% min_area = round(procparams.min_area * (size_factor^2));
outerpix = get_border_pix_of_poly(img, workingarea);
outerpix = logical(outerpix);
img(outerpix) = inf;


[thresh_images bbox] = first_preprocess_stage(img, workingarea, options);
[left right top bottom] = bbox2lrtb(bbox);

shifted_wa(:,1) = workingarea(:,1) - top + 1;
shifted_wa(:,2) = workingarea(:,2) - left + 1;


switch options.thresh_function
    case {'combine_bnr_with_original', 'large_nhood_operations'};
        mask = thresh_images.best(top:bottom, left:right) | ...
            thresh_images.thinner(top:bottom, left:right);
        thick_mask = thresh_images.thicker(top:bottom, left:right);
    case {'binary_image', 'watershed_l_nhood'}
        mask = thresh_images.best(top:bottom, left:right);
        thick_mask = thresh_images.best(top:bottom, left:right);
    otherwise
        mask = thresh_images.thicker(top:bottom, left:right);
        thick_mask = thresh_images.best(top:bottom, left:right) | ...
            thresh_images.thicker(top:bottom, left:right);
        thick_mask = thick_mask | thresh_images.thinner(top:bottom, left:right);

        

end

switch options.thresh_function
    case {'binary_image', 'watershed_l_nhood'}
        circles = [bbox(1)+1 bbox(3)+1 10]; %need not be empty but has no effect if only 
        %one circle is listed (circles are used to find out which 
        %connectivity components have more than one circle in them)
	otherwise
        circles=findcells(mask, ...
            options.minradius, options.grid_spacing, options.maxradius, shifted_wa, ...
            options.boundary_thickness, thick_mask);
        circles(:,1) = circles(:,1) + top - 1;
        circles(:,2) = circles(:,2) + left - 1;

        thresh_images.best(top:bottom, left:right) = second_preprocess_stage(workingarea, ...
            thresh_images.best(top:bottom, left:right), bbox, circles, ...
            thresh_images.thinner(top:bottom, left:right), ...
            thresh_images.thicker(top:bottom, left:right),...
            thresh_images.thickest(top:bottom, left:right), true);

        thresh_images.best(top:bottom, left:right) = second_preprocess_stage(workingarea, ...
            thresh_images.best(top:bottom, left:right), bbox, double(circles), ...
            thresh_images.thinner(top:bottom, left:right), ...
            thresh_images.thicker(top:bottom, left:right),...
            thresh_images.thickest(top:bottom, left:right), false);
end




% only_3x3 = strcmp(options.thresh_function, 'binary_image');
only_3x3 = 0;
cellgeom = create_edges(circles,thresh_images.best(bbox(1):bbox(2), bbox(3):bbox(4)), ...
    workingarea, options.min_area, size_factor, bbox(1), bbox(3), only_3x3);
cellgeom = select_all_cells(cellgeom, workingarea);
if isfield(options, 'update_positions') && options.update_positions
    short_length = 4 * size_factor; 
    cellgeom.nodes = reposition(cellgeom, img, 1:length(cellgeom.nodes(:,1)));
    short_edges = find(sum(...
        (cellgeom.nodes(cellgeom.edges(:,1),:) - cellgeom.nodes(cellgeom.edges(:,2),:)).^2') ...
                        < short_length);
    i = 1;
    while length(short_edges) >= i
        [cellgeom success] = collapse_edge(cellgeom, ...
            cellgeom.edges(short_edges(i), 1), ...
            cellgeom.edges(short_edges(i), 2), true);
        if ~success
            i = i + 1;
        else
            i = 1;
        end
        short_edges = find(sum(...
            (cellgeom.nodes(cellgeom.edges(:,1),:) - cellgeom.nodes(cellgeom.edges(:,2),:)).^2') ...
            < short_length);
    end
end
cellgeom = fix_geom(cellgeom);
cellgeom = fix_boundary_edges(cellgeom);




function img = second_preprocess_stage(wa, img, bbox, circles, img2, img3, img4, small_bbox)
max_area = 4000;
max_radius = max(circles(:,3));
pad = 3;
[size_y size_x] = size(img);
top = bbox(1);
bottom = bbox(2);
left = bbox(3);
right = bbox(4);
circles(:,1) = circles(:,1) - top + 1;
circles(:,2) = circles(:,2) - left + 1;
wa(:,1) = wa(:,1) - top + 1;
wa(:,2) = wa(:,2) - left + 1;
wa(:,1) = max(1, wa(:,1));
wa(:,2) = max(1, wa(:,2));
wa(:,1) = min(size_y, wa(:,1));
wa(:,2) = min(size_x, wa(:,2));

cells_objects = bwlabel(~img, 4);
s = regionprops(cells_objects, 'BoundingBox', 'area');
cells_area = cat(1, s.Area);
cells_bbox = cat(1, s.BoundingBox);
cells_bbox = ceil(cells_bbox);
cells_bbox(:,3:4) = cells_bbox(:,1:2) + cells_bbox(:,3:4) - 1;

circles_cells = cells_objects(sub2ind(size(cells_objects), circles(:,1), circles(:,2)));
[circles_cells circ_num]= sort(circles_cells);
circ_num = circ_num(circles_cells > 0);
circles_cells = circles_cells(circles_cells > 0);
[cc_unique, cc, dummy2] = unique(circles_cells, 'legacy');
cc_s = [0 cc(1:end - 1)'];
if small_bbox
    cells_ind = find(((cc - cc_s') > 1));
else
    cells_ind = find((cc - cc_s') > 1); %  & ((cc - cc_s') < 8) & cells_area(cc_unique) < max_area);
end
%     all(inpolygon([(cells_bbox(cc_unique, 1) - pad - 1) ...
%     (cells_bbox(cc_unique, 3) + pad + 1)], ...
%     [(cells_bbox(cc_unique, 2) - pad - 1) ...
%     (cells_bbox(cc_unique, 4) + pad + 1)], wa(:,2), wa(:,1)), 2));



for j = 1:length(cells_ind)
    i = cells_ind(j);
    cell = cc_unique(i);
    circs_in = circ_num((cc_s(i) + 1):cc(i));
    
    if small_bbox
        [val ind] = min(circles(circs_in,1));
        rad = circles(circs_in(ind),3);
        cells_bbox(cell, 2) = val - rad;

        [val ind] = min(circles(circs_in,2));
        rad = circles(circs_in(ind),3);
        cells_bbox(cell, 1) = val - rad;

        [val ind] = max(circles(circs_in,1));
        rad = circles(circs_in(ind),3);
        cells_bbox(cell, 4) = val + rad;

        [val ind] = max(circles(circs_in,2));
        rad = circles(circs_in(ind),3);
        cells_bbox(cell, 3) = val + rad;
    end

    if length(circs_in) > 8 | cells_area(cell) > max_area | ...
            ~all(inpolygon([(cells_bbox(cell, 1) - pad - 1) ...
            (cells_bbox(cell, 3) + pad + 1)], ...
            [(cells_bbox(cell, 2) - pad - 1) ...
            (cells_bbox(cell, 4) + pad + 1)], wa(:,2), wa(:,1)), 2);
        y_bbox = max(1, cells_bbox(cell, 2) - 1):min(size_y, cells_bbox(cell, 4) + 1);
        x_bbox = max(1, cells_bbox(cell, 1) - 1):min(size_x, cells_bbox(cell, 3) + 1);
    else
        y_bbox = cells_bbox(cell, 2) - 1:cells_bbox(cell, 4) + 1;
        x_bbox = cells_bbox(cell, 1) - 1:cells_bbox(cell, 3) + 1;
    end
    temp_circles = circles(circs_in,1) - y_bbox(1) + 1;
    temp_circles(:,2) = circles(circs_in,2) - x_bbox(1) + 1;
    temp_img = img(y_bbox, x_bbox);
    [cell_int cell_int_ind] = bwselect(~temp_img, temp_circles(1,2), temp_circles(1,1), 4);
    ind_shift = length(temp_img(:));
    temp_centers = sub2ind(size(temp_img), temp_circles(:,1), temp_circles(:,2));
    edit_img = repmat(temp_img, [1 1 4]);

    temp_img = img4(y_bbox, x_bbox);
    edit_img(cell_int_ind + 3*ind_shift) = temp_img(cell_int_ind);
    temp_cells_objects = bwlabel(~edit_img(:,:,4), 4);
    img4_num_cells = length(unique(temp_cells_objects(temp_centers), 'legacy'));
    
    new_img1_num_cells = 0;
    img2_num_cells = 0;
    img3_num_cells = 0;
    
    if img4_num_cells ~= length(temp_centers)
        temp_img = img3(y_bbox, x_bbox);
        temp_img = bwmorph(temp_img, 'bridge');
        edit_img(cell_int_ind + 2*ind_shift) = temp_img(cell_int_ind);
        temp_cells_objects = bwlabel(~edit_img(:,:,3), 4);
        img3_num_cells = length(unique(temp_cells_objects(temp_centers), 'legacy'));
    end
    new_img1_num_cells = 0;
    img2_num_cells = 0;
    
    if img3_num_cells ~= length(temp_centers) && img4_num_cells ~= length(temp_centers)
        temp_img = temp_img | img2(y_bbox, x_bbox);
        temp_img = bwmorph(temp_img, 'bridge');
        edit_img(cell_int_ind + ind_shift) = temp_img(cell_int_ind);
        temp_cells_objects = bwlabel(~edit_img(:,:,2), 4);
        img2_num_cells = length(unique(temp_cells_objects(temp_centers), 'legacy'));
        if img2_num_cells ~= length(temp_centers)
            temp_img = bwmorph(bwmorph(temp_img, 'dilate'), 'bridge');
            temp_cells_objects = bwlabel(~temp_img, 4);
            if length(unique(temp_cells_objects(temp_centers), 'legacy')) > img2_num_cells
                edit_img(cell_int_ind + ind_shift) = temp_img(cell_int_ind);
                img2_num_cells = length(unique(temp_cells_objects(temp_centers), 'legacy'));
            end
        end                        
        if img2_num_cells ~= length(temp_centers) && ~small_bbox
            temp_img = edit_img(:,:,1); 
            temp_cells_objects = bwlabel(~edit_img(:,:,1), 4);
            old_img1_num_cells = 1;
            for cnt = 1:2 %dilating more than twice alters the image too much.
                temp_img = bwmorph(bwmorph(edit_img(:,:,1), 'dilate'), 'bridge');
                temp_img(~cell_int) = edit_img(~cell_int);
                temp_cells_objects = bwlabel(~temp_img, 4);
                new_img1_num_cells = length(unique(temp_cells_objects(temp_centers), 'legacy'));
                if new_img1_num_cells > old_img1_num_cells
                    edit_img(cell_int_ind) = temp_img(cell_int_ind);
                    old_img1_num_cells = new_img1_num_cells;
                    if  new_img1_num_cells == length(temp_centers);
                        break
                    end
                end
            end
        end
    end
    [best_score best_method] = max([img4_num_cells img3_num_cells img2_num_cells new_img1_num_cells]);
    if best_score > 1
        if length(temp_centers) > 8 | cells_area(cell) > max_area | ...
            ~all(inpolygon([(cells_bbox(cell, 1) - pad - 1) ...
            (cells_bbox(cell, 3) + pad + 1)], ...
            [(cells_bbox(cell, 2) - pad - 1) ...
            (cells_bbox(cell, 4) + pad + 1)], wa(:,2), wa(:,1)), 2);

            %temp_img = bwmorph(~bwareaopen(~edit_img(:,:,5 - best_method), 8 , 4), 'thin');
            temp_img = edit_img(:,:,5 - best_method);
            temp_img = bwmorph(temp_img, 'skel', 10);
            edit_img(cell_int_ind) = temp_img(cell_int_ind);
            img(y_bbox, x_bbox) = edit_img(:,:,1);
        else        
            temp_img2 = img((y_bbox(1) - pad):(y_bbox(end) + pad), ...
                (x_bbox(1) - pad):(x_bbox(end) + pad));
            temp_img2(pad + 1:(end-pad), pad + 1:(end - pad)) = ...
                ~bwareaopen(~edit_img(:,:,5 - best_method), 8 , 4);
            temp_img2 = bwmorph(temp_img2, 'skel', 5);
            img(y_bbox, x_bbox) = temp_img2(pad + 1:(end-pad), pad + 1:(end - pad));
        end
    end
end

[m n] = size(img);
b_ind = [sub2ind([m n], 1:m, ones(1,m)) sub2ind([m n], 1:m, n*ones(1,m)) sub2ind([m n], ones(1,n), 1:n) sub2ind([m n], m*ones(1,n), 1:n)];
b_val = img(b_ind);
img(b_ind) = 1;
img = bwmorph(img, 'spur', 5);
img = ~bwareaopen(~img, 11 , 4);
img = bwareaopen(img, 100); %????
img = bwmorph(img, 'skel', 5);
img = bwmorph(img, 'spur', 5);
%%%%% fill in pixels in zigzag shaped lines: %%%%%%%%
%   
%   0 0 0       0 0 0
%   1 0 1  -->  1 1 1
%   0 1 0       0 1 0
%
lut = makelut(@(x) ((sum(x(:)) == 3 && sum(x([2 4 6 8])) == 3) || x(5) == 1),3);
img = applylut(img, lut);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img(b_ind) = b_val;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function [thresh_images bbox] = first_preprocess_stage(img, wa, options)


[m n] = size(img);
left = round(max(min(wa(:,2)), 1));
top = round(max(min(wa(:,1)), 1));
right = round(min(max(wa(:,2)), n));
bottom = round(min(max(wa(:,1)), m));
img = img(top:bottom, left:right);
bbox = [top bottom left right];


wa_region = poly2mask(wa(:,2) - left, wa(:,1) - top, ...
                      bottom - top + 1, right -left + 1);
                  
if isfield(options, 'limit_within') && options.limit_within
    temp = bwmorph(wa_region, 'erode');
    working_area_boundary = wa_region & ~temp;
    working_area_boundary(1:end, 1) = 0;
    working_area_boundary(1:end, end) = 0;
    working_area_boundary(1, 1:end) = 0;
    working_area_boundary(end, 1:end) = 0;
    options.working_area_boundary = working_area_boundary;
end



if isfield(options, 'median_over_time') && options.median_over_time
    if isfield(options.med_ind)
        ind = options.med_ind;
    else
        temp_ind = true(size(img));
        temp_ind(1:end,1) = 0;
        temp_ind(1:end,end) = 0;
        temp_ind(end,1:end) = 0;
        temp_ind(1,1:end) = 0;
        temp_ind = find(temp_ind)';
        nhood_x = [2 1 1 2 3 3 3 2 1];
        nhood_y = [2 2 1 1 1 2 3 3 3];
        nhood = sub2ind(size(img), nhood_x, nhood_y);
        nhood = nhood - sub2ind(size(img), 2, 2);
        ind = repmat(temp_ind, length(nhood_x), 1) + repmat(nhood', 1, length(temp_ind));
        setappdata(commandsuiH, 'med_ind', ind);
    end

    prev_img = double(options.prev_img);
    next_img = double(options.next_img);
    med_img = median([prev_img(ind); img(ind); next_img(ind)]);
    med_img = reshape(med_img, size(img) - [2 2]);
    new_img = img;
    new_img(2:end - 1, 2:end - 1) = med_img;

%   DEBUG NEED TO FIX THIS: img is being cropped here again but has already been cropped above.
    new_img = new_img(top:bottom, left:right);
%     bnr_img = double(imagedata.prev_img) .* double(img) .* double(imagedata.next_img);
%     img = bnr_img * 255 / max(bnr_img(:));
%     img = double(imagedata.new_disp);
    img = img(top:bottom, left:right);
    options.med_thresh = bwareaopen(...
                circthresh(double(new_img) .* double(img), med_thresh_radius), ...
        20 * (size_factor^2));
end

func = options.thresh_function;
img = double(img);
thresh_images = feval(func, img, wa, options, bbox, wa_region);

function thresh_images = watershed_l_nhood(img, wa, options, bbox, wa_region)
[left right top bottom] = bbox2lrtb(bbox);
img = large_nhood_operations(img, wa, options, bbox, wa_region, 1);
img = ~bwareaopen(~img, 10*(options.sizefactor^2) , 4);  
img = bwmorph(img, 'skel', 10);
img = watershed((img), 4) == 0;
img = bwmorph(img, 'thin');
thresh_images.best = false(size(img));
thresh_images.best(top:bottom, left:right) = img;
thresh_images.thinner = false(size(img)); 
thresh_images.thinner(top:bottom, left:right) = img;
thresh_images.thicker = false(size(img));
thresh_images.thicker(top:bottom, left:right) = img;
thresh_images.thickest = false(size(img));
thresh_images.thickest(top:bottom, left:right) = img;

function thresh_images = binary_image(img, wa, options, bbox, wa_region)
[left right top bottom] = bbox2lrtb(bbox);
% img = bwmorph(img, 'skel', inf);
img = watershed(img) == 0;
img = bwmorph(img, 'thin');
thresh_images.best = false(size(img));
thresh_images.best(top:bottom, left:right) = img;
thresh_images.thinner = false(size(img)); 
thresh_images.thinner(top:bottom, left:right) = img;
thresh_images.thicker = false(size(img));
thresh_images.thicker(top:bottom, left:right) = img;
thresh_images.thickest = false(size(img));
thresh_images.thickest(top:bottom, left:right) = img;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function thresh_images = thicker_edges_less_gaps(img, wa, options, bbox, wa_region)
[left right top bottom] = bbox2lrtb(bbox);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function thresh_images = combine_bnr_with_original(img, wa, options, bbox, wa_region)
[left right top bottom] = bbox2lrtb(bbox);
original = double(imread(options.original_file));
original = original(top:bottom, left:right);

r = options.normradius;

basic_thresh = threshold_img(img, r, options);
dilated_thresh = imdilate(basic_thresh, strel('square', 3));

% outlines_only_with_original_vals = original;
% outlines_only_with_original_vals(~(dilated_thresh & ~basic_thresh)) = 0;
% outlines_only_with_original_vals(basic_thresh) = original(basic_thresh)*2;


original_large_nghbrhood = local_background_of_image(original, r);

best = false(size(original));
% best((original < original_large_nghbrhood)) = 0;
best((dilated_thresh & ~(original < 1.05*original_large_nghbrhood))) = 1;
best(basic_thresh) = 1;
best = bwareaopen(best, 50);
best = bwmorph(best, 'bridge', 1);

best_with_image_operations = common_img_ops(best, options.sizefactor);


img = gaussfilt(img, options.blurradius, options.blurstrength);
basic_thresh_of_smoothened = threshold_img(img, r, options);

dilated_thresh_of_smoothened = imdilate(basic_thresh_of_smoothened, strel('diamond', 1));

% outlines_only_with_original_vals = original;
% outlines_only_with_original_vals(~(dilated_thresh_of_smoothened & ~basic_thresh_of_smoothened)) = 0;
% outlines_only_with_original_vals(basic_thresh_of_smoothened) = original(basic_thresh_of_smoothened)*2;

% img_large_nghbrhood = local_background_of_image(outlines_only_with_original_vals, r);
best_of_smoothened = false(size(original));
best_of_smoothened((dilated_thresh_of_smoothened & ~(original < 1.05*original_large_nghbrhood))) = 1;
best_of_smoothened(basic_thresh_of_smoothened) = 1;
best_of_smoothened = bwareaopen(best_of_smoothened, 50);
best_of_smoothened = bwmorph(best_of_smoothened, 'bridge', 1);


if isfield(options, 'limit_within') && options.limit_within
    basic_thresh = basic_thresh | options.working_area_boundary;
    best_of_smoothened = best_of_smoothened | options.working_area_boundary;
    best = best | options.working_area_boundary;
    basic_thresh_of_smoothened = basic_thresh_of_smoothened | ...
                                 options.working_area_boundary;
    best_with_image_operations = best_with_image_operations | ...
                                 options.working_area_boundary;
end


thresh_images.best = false(size(img));
thresh_images.best(top:bottom, left:right) = best_with_image_operations;
thresh_images.thinner = false(size(img)); 
thresh_images.thinner(top:bottom, left:right) = basic_thresh;
thresh_images.thicker = false(size(img));
thresh_images.thicker(top:bottom, left:right) = basic_thresh | basic_thresh_of_smoothened;
thresh_images.thickest = false(size(img));
thresh_images.thickest(top:bottom, left:right) = best | best_of_smoothened;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function thresh_images = large_nhood_operations(img, wa, options, bbox, wa_region, just_best)
if nargin < 6 || isempty(just_best)
    just_best = false;
end
[left right top bottom] = bbox2lrtb(bbox);
r = options.normradius;

basic_thresh = threshold_img(img, r, options);
temp = false(size(basic_thresh));
best = bwareaopen(basic_thresh, 50);
for deg = 0:45:135
    nhood = line_nghbrhood(deg);
    deg_t = conv2(double(basic_thresh), nhood, 'same');
    nhood2 = line_nghbrhood(deg+180);
    deg180_t = conv2(double(basic_thresh), nhood2,'same');
    not_nhood = ~(nhood | nhood2);
    not_t = conv2(double(basic_thresh), double(not_nhood), 'same');
    temp = temp | (deg_t & deg180_t) & (deg_t > not_t) & (deg180_t > not_t);
end
temp = temp & ~bwareaopen(temp & ~best, 6);
best = best | temp;
best = bwareaopen(best, 50);
best = bwmorph(best, 'bridge', 1);
if just_best 
    thresh_images = best;
    return
end
best_with_image_operations = common_img_ops(best, options.sizefactor);
%% repeat with smoothened img
img = gaussfilt(img, options.blurradius, options.blurstrength);
basic_thresh_of_smoothened = threshold_img(img, r, options);
best_of_smoothened = basic_thresh_of_smoothened;
for deg = 0:45:135
    nhood = line_nghbrhood(deg);
    deg_t = conv2(double(basic_thresh), nhood, 'same') > 0;
    nhood2 = line_nghbrhood(deg+180);
    deg180_t = conv2(double(basic_thresh), nhood2,'same') > 0;
    not_nhood = ~(nhood | nhood2);
    not_t = conv2(double(basic_thresh), double(not_nhood), 'same') > 0;
    best_of_smoothened = best_of_smoothened | (deg_t & deg180_t & ~not_t);
end
best_of_smoothened = bwareaopen(best_of_smoothened, 50);
best_of_smoothened = bwmorph(best_of_smoothened, 'bridge', 1);


if isfield(options, 'limit_within') && options.limit_within
    basic_thresh = basic_thresh | options.working_area_boundary;
    best_of_smoothened = best_of_smoothened | options.working_area_boundary;
    best = best | options.working_area_boundary;
    basic_thresh_of_smoothened = basic_thresh_of_smoothened | ...
                                 options.working_area_boundary;
    best_with_image_operations = best_with_image_operations | ...
                                 options.working_area_boundary;
end

basic_thresh = bwareaopen(basic_thresh, 50);

thresh_images.best = false(size(img));
thresh_images.best(top:bottom, left:right) = best_with_image_operations;
thresh_images.thinner = false(size(img)); 
thresh_images.thinner(top:bottom, left:right) = bwareaopen(basic_thresh, 50);
thresh_images.thicker = false(size(img));
thresh_images.thicker(top:bottom, left:right) = basic_thresh | basic_thresh_of_smoothened;
thresh_images.thickest = false(size(img));
thresh_images.thickest(top:bottom, left:right) = best | best_of_smoothened;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function thresh_images = thinner_edges_more_gaps(img, wa, options, bbox, wa_region)
[left right top bottom] = bbox2lrtb(bbox);
size_factor = options.sizefactor;

if 0%layers_mode
    if weak_signal
        


%         a = circthresh(img, normradius, 1.2);    
%         temp_img = img;
%         temp_img(~a) = false;
%         a = circthresh(gaussfilt(temp_img,blurradius,blurstrength),normradius);    
%         
%         b = circthresh(img, normradius2, 1.2);    
%         temp_img = img;
%         temp_img(~b) = false;
%         b = circthresh(gaussfilt(temp_img,blurradius2,blurstrength2),normradius2);
 
        fac = 1;
        
        c = round(size(img)/2);
        x = c(1); y = c(2);
        x1 = max(1, x - 50);
        x2 = min(2*x, x + 50);
        y1 = max(1, y - 50);
        y2 = min(2*y, y + 50);
        window = img(x1:x2, y1:y2);
        for i = 1:255
            h(i) = sum(window(:) < i + 7 & window(:) > i - 7);
        end
        r = h(255)/h(128);
        %fac = r * 0.159 + 0.94;
        fac = 0.1164 .* exp((r - 0.4)/(0.6)) + 0.8836;

        fac = min(1.25, max(1, fac));
        a = circthresh(gaussfilt(img,blurradius,blurstrength),normradius, fac);    
        b = circthresh(gaussfilt(img,blurradius2,blurstrength2),normradius2, fac);
%         temp_img = img;
%         temp_img(a) = false;
%         a = a | circthresh(temp_img, normradius, fac/3);    
%         temp_img = img;
%         temp_img(b) = false;
%         b = b | circthresh(temp_img, normradius2, fac/3);
        
    else
        a = circthresh(gaussfilt(img,blurradius,blurstrength),normradius);    
        b = circthresh(gaussfilt(img,blurradius2,blurstrength2),normradius2);
    end
elseif 1%~weak_signal
    img = double(img);
    temp_img = gaussfilt(img,options.blurradius,options.blurstrength);    
    a = threshold_img(temp_img, options.normradius, options);
    temp_img = gaussfilt(img,options.blurradius2,options.blurstrength2);    
    b = threshold_img(temp_img, options.normradius2, options);
    med_thresh = bwmorph(bwareaopen(b, 20), 'bridge');
end
 
a = (a & wa_region);
if isfield(options, 'limit_within') && options.limit_within
    a = a | options.working_area_boundary;
end
a = bwareaopen(a, 50 * (size_factor^2), 8);


b = (b & wa_region);
if isfield(options, 'limit_within') && options.limit_within
    b = b | options.working_area_boundary;
end

if 0%weak_signal
    b = bwareaopen(b,50 * (size_factor^2), 8);
else
    b = bwareaopen(b,50 * (size_factor^2), 4);
end

c = bwmorph(b, 'spur', 1);
c = bwmorph(c, 'skel', 1);


c = bwpack(c);
se = strel('line',3*size_factor,90);
c = imdilate(c, se, 'ispacked');
c = imerode(c, se, 'ispacked', size(a,1));
se = strel('line',3*size_factor,0);
c = imdilate(c, se, 'ispacked');
c = imerode(c, se, 'ispacked', size(a,1));
c = bwunpack(c, size(a,1));

c = bwmorph(c, 'spur', 10);

%keep pixel only if it appears in both filters
thresh_images.thinner = false(size(img));
a = bwareaopen(a & b, 50 * (size_factor^2));
thresh_images.thinner(top:bottom, left:right) = a;
thresh_images.thicker = false(size(img));
thresh_images.thicker(top:bottom, left:right) = c;


b = med_thresh .* a;
b = bwareaopen(b, 15);    

if isfield(options, 'limit_within') && options.limit_within
    b = b | options.working_area_boundary;
end

lut = makelut(@(x) (~x(5)),3);
lut = lut & lutbridge;
bridge_pixels = applylut(b, lut);

[x y] = size(b);
bndry_ind = [sub2ind([x y], 1:x, ones(1,x)) sub2ind([x y], 1:x, y*ones(1,x)) sub2ind([x y], ones(1,y), 1:y) sub2ind([x y], x*ones(1,y), 1:y)];
bndry_val = b(bndry_ind);
b(bndry_ind) = 1;
b = ~bwareaopen(~b, 10 , 4);
b = bwmorph(b, 'thin', 1);
b = bwmorph(b, 'skel', 10);

%%%%%%%%% This adds a few too many white pixels. We'll use it as one of the
%%%%%%%%% backup methods in the second preprocessing stage
c = bwmorph(bwmorph(b , 'bridge') | bridge_pixels, 'bridge');
c = bwareaopen(c, 10);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b = bwareaopen(b, 10);
b(bndry_ind) = bndry_val;
b = bwmorph(b, 'bridge');

thresh_images.best = false(size(img));
thresh_images.best(top:bottom, left:right) = b;
thresh_images.thickest = false(size(img));
thresh_images.thickest(top:bottom, left:right) = c;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function thresh_images = basal_sqh(img, wa, options, bbox, wa_region)
%HARD CODED VALUES FOR sqh MOVIES
options.sqh_low_thresh_val = 30;
img(img < options.sqh_low_thresh_val) = 0;
img = double(adapthisteq(uint8(img)));
% func = options.thresh_function;
% thresh_images = feval(func, img, wa, options, bbox, wa_region);
thresh_images = large_nhood_operations(img, wa, options, bbox, wa_region);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function thresh_images = projected_ecad_with_hard_coded_values(img, wa, options, bbox, wa_region)
%HARD CODED VALUES FOR ecad MOVIES

[left right top bottom] = bbox2lrtb(bbox);
cir = circle(15);


mean_vals = conv2(img, double(cir), 'same')./sum(cir(:));
if isfield(options, 'thresh_factor')
    factor = options.thresh_factor;
else
    factor = 1;
end

img_open = (bwareaopen(img>(mean_vals*factor), 50));

a = gaussfilt(img,2,9);
mean_vals = conv2(a, double(cir), 'same')./sum(cir(:));
a_thick = (a - mean_vals) > -5;
a_thick  = bwareaopen(a_thick, 50);
a = (a - mean_vals) > 5;
a = bwareaopen(a, 50);

b = gaussfilt(img,3,7);
mean_vals = conv2(b, double(cir), 'same')./sum(cir(:));
b_thick = (b - mean_vals) > -5;
b = (b - mean_vals) > 5;
b_thick  = bwareaopen(b_thick, 50);
b = bwareaopen(b, 50);

a = (a & wa_region);
a_thick = (a_thick & wa_region);

b = (b & wa_region);
b = (b_thick & wa_region);

img_open = (img_open & wa_region);
if isfield(options, 'limit_within') && options.limit_within
    img_open = img_open | options.working_area_boundary;
end


thick = (img_open | a | b);
c = bwmorph(thick, 'spur', 10);
c = bwmorph(c, 'skel', 10);
c = bwmorph(c, 'spur', 10);

c = ~bwareaopen(~c, 10 , 4);
c = bwmorph(c, 'thin', 1);
c = bwmorph(c, 'skel', 10);
c = bwareaopen(c, 10);

thresh_images.best = false(size(img));
thresh_images.best(top:bottom, left:right) = c;

thresh_images.thinner = false(size(img));
thresh_images.thinner(top:bottom, left:right) = img_open;

thresh_images.thicker = false(size(img));
thresh_images.thicker(top:bottom, left:right) = a|b;

thresh_images.thickest = false(size(img));
thresh_images.thickest(top:bottom, left:right) = thick;


function [left right top bottom] = bbox2lrtb(bbox)
top = bbox(1);
bottom = bbox(2);
left = bbox(3);
right = bbox(4);

function c = common_img_ops(img, factor)
%factor indicates by how much the image is larger/smaller than the images the
%values were optimized for, in terms of the physical size of each pixel.
%area grows as the square of the linear length. Therefore the size factor is squared.
c = ~bwareaopen(~img, ceil(10*(factor^2)) , 4);  
c = bwmorph(c, 'spur', 4);
c = bwmorph(c, 'skel', 4);
c = bwmorph(c, 'spur', 4);


c = ~bwareaopen(~c, ceil(10*(factor^2)) , 4);  
c = bwmorph(c, 'thin', 1);
c = bwmorph(c, 'skel', 10);
c = bwareaopen(c, ceil(10*(factor^2)));

function nhood = line_nghbrhood(deg)
switch deg
    case 0
nhood =  [...
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     1     1     1
     0     0     0     1     1     1     1
     0     0     0     0     1     1     1
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0];
    case 45
nhood =  [...
     0     0     0     0     1     1     1
     0     0     0     0     1     1     1
     0     0     0     0     1     1     1
     0     0     0     1     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0];
    case 90
nhood =  [...
     0     0     1     1     1     0     0
     0     0     1     1     1     0     0
     0     0     1     1     1     0     0
     0     0     0     1     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0];
    case 135
nhood =  [...
     1     1     1     0     0     0     0
     1     1     1     0     0     0     0
     1     1     1     0     0     0     0
     0     0     0     1     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0];
    case 180
nhood =  [...
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     1     1     1     0     0     0     0
     1     1     1     1     0     0     0
     1     1     1     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0];
    case 225
nhood =  [...
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     1     0     0     0
     1     1     1     0     0     0     0
     1     1     1     0     0     0     0
     1     1     1     0     0     0     0];
    case 270
nhood =  [...
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     1     0     0     0
     0     0     1     1     1     0     0
     0     0     1     1     1     0     0
     0     0     1     1     1     0     0];
     case 315
nhood =  [...
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     0     0     0     0
     0     0     0     1     0     0     0
     0     0     0     0     1     1     1
     0     0     0     0     1     1     1
     0     0     0     0     1     1     1];
end

function a = threshold_img(img, r, options)
if isfield(options, 'thresh_factor')
    factor = options.thresh_factor;
else
    factor = 1;
end
if options.local_mean
    bckgrnd = local_background_of_image(img, r);
    a = img > (bckgrnd*factor);
else
%     a = img > (mean(img(:))*factor);
    max_val_of_img = max(img(:));
    min_val_of_img = min(img(:));
    img_hist = hist(double(img(:)), double(min_val_of_img:max_val_of_img));
    img_hist_cumsum = cumsum(img_hist);
    dist_vals = img_hist_cumsum ./ img_hist_cumsum(end);
    last_ind = find(dist_vals < options.intensity_percentile, 1, 'last');
    mean_intensity_val = sum(img_hist(1:last_ind) .* (1:last_ind));
    mean_intensity_val = mean_intensity_val / img_hist_cumsum(last_ind);
    mean_intensity_val = mean_intensity_val + min_val_of_img;



    a = img > (mean_intensity_val * factor);
end
