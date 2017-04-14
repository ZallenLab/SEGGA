function [a_dist, new_Fx,new_Fy] = dist_gradient_special(img_in)



% params
max_expected = 15;
cortex_thickness = 7;

% thresh image and take distance transform
a_thresh = smoothn(double(img_in)) > mean(img_in(:));
a_thresh = bwareaopen(a_thresh,50);
a_dist = bwdist(a_thresh);
a_dist(~a_thresh) = a_dist(~a_thresh)+1;
a_dist = min(max_expected,a_dist);

% perform some image proc on a_dist
se = strel('disk',1);
a_erode = imclose(a_thresh,se);
a_erode = imerode(a_erode,se);
erosion_pix = logical(a_thresh-a_erode);
a_dist(erosion_pix) = 1;
a_dist = smoothn(a_dist);



a_norm = double(img_in) - double(min(img_in(:)));
a_norm = a_norm./max(a_norm(:));

[dist_Fx,dist_Fy] = gradient(-a_dist);
[img_Fx,img_Fy] = gradient(a_norm.*max_expected);

dist_Fx = smoothn(dist_Fx);
dist_Fy = smoothn(dist_Fy);

img_Fx = smoothn(img_Fx);
img_Fy = smoothn(img_Fy);

mean_Fx = (dist_Fx.*a_dist+img_Fx)./(a_dist+max_expected);
mean_Fy = (dist_Fy.*a_dist+img_Fy)./(a_dist+max_expected);



% gradient at "diff_recon_thresh"
% takes direction from [mean_Fx, mean_Fy]
% and magnitude from [a_dist]
a_dist = a_dist + cortex_thickness;
[new_Fx,new_Fy] = rescale_comp_mats(mean_Fx,mean_Fy,a_dist);


return

% display functions


figure;
imagesc(a_dist);
hold on
% quiver(dist_Fx,dist_Fy,'r','AutoScaleFactor', 1.5);
quiver(mean_Fx,mean_Fy,'r','AutoScaleFactor', 1.5);
hold off;
axis image;
title(filenames{counter},'interpreter','none')
set(gca,'xtick',[],'ytick',[])
drawnow;

