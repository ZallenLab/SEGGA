function [ang_means, ang_bins] = give_mean_per_angle(angs,levels)


ang_bins = 1:4:90;
ang_means = nan(numel(ang_bins),1);

angs_nodims = angs(:);
levels_nodims = levels(:);

[~, bins] = histc(angs_nodims,ang_bins);

for i = 1:length(ang_bins)
    
    templevels = levels(bins==i);
    templevels = templevels(~isnan(templevels));
    ang_means(i) = sum(templevels)./numel(templevels);
end
    