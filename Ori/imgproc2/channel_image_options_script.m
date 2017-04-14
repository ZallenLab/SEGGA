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
histhist = 0;
num_images = 0;
for i = 1:length(files)
    temp_img = imread(files(i).name);
    num_images = num_images + 1;
    min_val = min(min_val, min(double(temp_img(:))));
    max_val = max(max_val, max(double(temp_img(:))));
    histhist((end+1):(ceil(max_val)+1)) = 0;
    histhist = histhist + hist(temp_img(:), 0:ceil(double(max_val)));
end
threshold = 100*num_images;
sumsum = cumsum(histhist(end:-1:1));
max_val = max_val - find((sumsum / sumsum(end)) > 1/threshold, 1);
sumsum = cumsum(histhist);
min_val = find((sumsum / sumsum(end)) > 1/threshold, 1);
fprintf(fid, '%% img(:, :, ch) = max(1, min(255, round(read_image - shift_fac)* fac)));\r\n');
fprintf(fid, 'shift_factor = %d\r\n', min_val);
fprintf(fid, 'brightness_factor  = %d\r\n', 255/double(max_val - min_val));
fclose(fid)

    