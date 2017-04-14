function scores = intensity_at_cell_centers(img, x_pos, y_pos, rad, shape, method)
%scores is the intensity of img pixels at positions (x_pos, y_pos).
%Measured by method (min, mean, median etc) at a region around the 
%given positions. The region is specified by shape (disk, square etc) 
%and rad (the size of the region).
%
% img is a 2d array
% x_pos and y_pos are 1d array of integers
% rad is a scalar determining the size of the neighborhood to sample 
% around each position 
% shape is a string determining the shape of the neighborhood to sample 
% around each position. It can be any flat 2d symmetric argument that strel 
% accepts (disk, square, etc)
% method is a string and can be min, max, mean or median.


[img_y img_x] = size(img);
if img_x < 2*rad || img_y < 2*rad
    error('img size must be larger than 2*rad');
    return
end
%find centers which are too close to a boundary of the image;
invalid_pos = x_pos < rad+1;
invalid_pos = invalid_pos | (x_pos + rad + 1)  > img_x;
invalid_pos = invalid_pos | (y_pos + rad + 1)  > img_y;
invalid_pos = invalid_pos | y_pos < rad+1;

%reposition these centers away from the boundary (scores are later
%set to nan)
x_pos(invalid_pos) = rad+1;
y_pos(invalid_pos) = rad+1;


%draw shape and convert into indices.
if strcmpi(shape, 'disk')
    s = getnhood(strel(shape, rad, 0));
elseif strcmpi(shape, 'square')
    s = getnhood(strel(shape, 2*rad + 1));
else
    s = getnhood(strel(shape, rad));
end
[s_x_ind s_y_ind] = find(s);
s_x_ind = s_x_ind - rad - 1;
s_y_ind = s_y_ind - rad - 1;

%lift the shape over each center
x_pos = reshape(x_pos, 1, length(x_pos));
y_pos = reshape(y_pos, 1, length(y_pos));

ind_x_plus_s = repmat(x_pos, length(s_x_ind), 1) + ... 
               repmat(s_x_ind, 1, length(x_pos));

ind_y_plus_s = repmat(y_pos, length(s_y_ind), 1) + ... 
               repmat(s_y_ind, 1, length(y_pos));

%lifted_pixels is a 2d array whose values are intensities of pixels in img.
%Each column represnts a cell listed in the passed variables x_pos and y_pos.
%Each element in each row is one pixel around that cell center as
%determined by shape and rad.
lifted_pixels = img(sub2ind(size(img), ind_y_plus_s, ind_x_plus_s));


%apply the method to the lifted pixels over each center
switch method
    case 'median'
        scores = median(lifted_pixels, 1);
    case 'min'
        scores = min(lifted_pixels, [], 1);
    case 'max'
        scores = max(lifted_pixels, [], 1);
    case 'mean'
        scores = mean(lifted_pixels, 1);
end


%discard scores of centers originally too close to a boundary of the image
scores(invalid_pos) = nan;