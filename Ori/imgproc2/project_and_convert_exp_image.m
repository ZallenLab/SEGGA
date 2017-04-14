function project_and_convert_exp_image(filename, dest_dir, new_filename, t, min_z, max_z)
if nargin < 5 || isempty(min_z)
    min_z = -inf;
end
if nargin < 6 || isempty(max_z)
    max_z = inf;
end

img_info = imfinfo(filename);
[dummy1 new_filename] = fileparts(new_filename);
new_filename = [new_filename(1:min(10, end)) '_T0000_new_Z0000.tif'];
for z = max(1,min_z):min(length(img_info), max_z)
    img(:, :, z) = (imread(filename, z));
end
proj_img = max(img, [], 3);
dest = fullfile(dest_dir, put_file_nums(new_filename, t, 1));
imwrite(proj_img, dest, 'tif');

% figure;imagesc(img(:,:,29));
