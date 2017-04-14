function rot_img_dir(alpha, t, b, l, r)
files = dir('*.tif');
for i = 1:length(files);
    img = imread(files(i).name);
    img = imrotate(img, -alpha, 'bicubic');
    if nargin > 2
        img = img(t:b, l:r);
    end
    imwrite(img, files(i).name, 'tif');
end
    