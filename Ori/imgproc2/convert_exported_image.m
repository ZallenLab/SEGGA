function convert_exported_image(filename, dest_dir, new_filename, t, min_z)
if nargin < 5 || isempty(min_z)
    min_z = 1;
end
img_info = imfinfo(filename);
[dummy1 new_filename] = fileparts(new_filename);
new_filename = [new_filename(1:min(10, end)) '_T0000_new_Z0000.tif'];
for z = 1:length(img_info)
%     img = double(imread(filename, z));
%     img = img - min(img(:));
%     out_of_range_pixels = img > 255;
%     n = nnz(out_of_range_pixels);
%     if n
%         sprintf('%g out of range pixels were set to 255', n)
%     end
%     img(out_of_range_pixels) = 255;
% 
%     img = img / max(img(:));
%     img = round(img * 255);
%     img = uint8(img);

    img = imread(filename, z);
    dest = fullfile(dest_dir, put_file_nums(new_filename, t, z + min_z - 1));
    imwrite(img, dest, 'tif');
end
