function [top, bot] = find_top_of_embryo(filename)



img_info = imfinfo(filename);
img = uint16(zeros(img_info(1).Height,img_info(1).Width,length(img_info)));
z_stds = zeros(length(img_info),1);
for z = 1:length(img_info)
    img(:, :, z) = (imread(filename, z));
    tempimg = img(:,:,z);
    z_stds(z) = std(double(tempimg(:)),1,1);    
end
z_means = squeeze(mean(mean(img,1),2));

% figure;plot(abs(deriv(z_stds)));
    
[~, meanHigh_ind] = max(z_means);
[~, stdHigh_ind] = max(z_stds);
z_high_ind = floor(mean([meanHigh_ind,stdHigh_ind]));

% % take layers from the larger half if splitting at z_high_ind
% direction = (length(img_info)/2) > z_high_ind; %true -> right, %false -> left
direction = false; %force it left;

proj_reach = 3;
offset = 3;

both_zlayers = [max(z_high_ind-offset,1), min(max(z_high_ind - proj_reach*(1-direction)-offset,1),length(img_info))];
both_zlayers = fliplr(sort(both_zlayers));
top = both_zlayers(1);
bot = both_zlayers(2);


