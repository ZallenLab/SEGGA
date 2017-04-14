function [new_mat_x,new_mat_y] = rescale_comp_mats(mat_x,mat_y,mags)

ratios = mat_x./mat_y;
new_mat_x = (mags.^2 .* 1./(1+ 1./ratios.^2)).^(1/2).*sign(mat_x);
new_mat_y = (mags.^2 .* 1./(ratios.^2+1)).^(1/2).*sign(mat_y);



%  checking work
% check_dists = (new_mat_x.^2 + new_mat_y.^2).^(1/2);
% distdiffs = mags-check_dists;
% figure; hist(distdiffs(:));
% max(distdiffs(:))
% 
% 
% startkratios = (mat_x./mat_y);
% newratios = (new_mat_x./new_mat_y);
% checkratios = startkratios-newratios;
% figure; hist(checkratios(:));
% max(checkratios(:))

display('warning: is not working in 1 out 10^5 cases, producing ratios off by a factor of 2'); 