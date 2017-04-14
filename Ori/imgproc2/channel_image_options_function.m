function histhist = channel_image_options_function(min_z, max_z, bottom_threshold, top_threshold)
if nargin < 1 || isempty(min_z)
    min_z = -inf;
end
if nargin < 2 || isempty(max_z)
    max_z = inf;
end
if nargin < 3 || isempty(bottom_threshold)
    bottom_threshold = 0.001; %fraction of pixels per image to remove as outliers and set to min intensity
end
if nargin < 4 || isempty(top_threshold)
    top_threshold = 0.001; %fraction of pixels per image to remove as outliers and set to max intensity
end

filename = 'channel_image_settings.txt';
fid = fopen(filename, 'w');
if fid == -1
    h = msgbox('Failed to open file', '', 'error', 'modal');
    waitfor(h);
    return
end

min_val = inf;
max_val = -inf;
files = dir('*.tif');
if isempty(files)
    files = dir('*.TIF');
    if isempty(files)
        display('no files found for channel_image_options_function');
        return
    else
        display('channel_image_options_function:');
        display('found ''TIF'' files');
    end
else
    display('channel_image_options_function:');
	display('found ''tif'' files');
    
end

histhist = 0;
num_images = 0;
for i = 1:length(files)
    img_info = imfinfo(files(i).name);
    for z = max(1,min_z):min(length(img_info), max_z)
        temp_img = (imread(files(i).name, z));
        num_images = num_images + 1;
        min_val = min(min_val, min(temp_img(:)));
        max_val = double(max(max_val, max(temp_img(:))));
        histhist((end+1):(ceil(max_val)+1)) = 0;
        if max_val ==0
            histhist = 0;
        else
            histhist = histhist + hist(temp_img(:), 0:ceil(double(max_val)));
        end
    end
end
top_threshold = top_threshold/num_images;
bottom_threshold = bottom_threshold/num_images;
sumsum = cumsum(histhist(end:-1:1));
max_val = max_val - find((sumsum / sumsum(end)) > top_threshold, 1);
sumsum = cumsum(histhist);
min_val = find((sumsum / sumsum(end)) > bottom_threshold, 1);
fprintf(fid, '%% img(:, :, ch) = max(1, min(255, round(read_image - shift_fac)* fac)));\r\n');
fprintf(fid, 'shift_factor = %d\r\n', min_val);
fprintf(fid, 'brightness_factor  = %d\r\n', 255/double(max_val - min_val));
fclose(fid);