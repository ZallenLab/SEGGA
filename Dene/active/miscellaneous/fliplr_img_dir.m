function fliplr_img_dir(t, b, l, r)
files = dir('*.tif');
for i = 1:length(files);
    img = imread(files(i).name);
    
%     for thirddim_ind = 1:size(img,3)
%         img(:,:,thirddim_ind) = fliplr(img(:,:,thirddim_ind));
%     end

    img = flipdim(img,2);
    
if nargin > 2
        img = img(t:b, l:r);
    end
    imwrite(img, files(i).name, 'tif');
end
    