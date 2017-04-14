function nxchange_hist = histogram_of_nghbr_xchange(d,bins)
%
% Get the histogram of neighbors lost (T1s or Rosettes) or neighbors
% gained
%
% INPUT
% d -> accumulative nxchange data on every cell
% bins -> bins for output histogram
%
% OUTPUT
% nxchange_hist -> frequency counts for each bin for each time point
%


nframes = size(d,1);
if nargin<2 || isempty(bins)
    extreme_max = 10;
    bins = [0:4,extreme_max];
    %%% extreme_max was necessary because values outside of any bin are
    %%% automatically mapped to zero, not the extreme bin
    %%% no longer necessary - I fixed it below
    %%% this is a special case where outliers are only on one side, so it
    %%% was an easy fix.
    nxchange_hist = zeros(nframes,length(bins));
end

for i=1:nframes
    nxchange_set = d(i,:);
    [nxchange_hist(i,:), idx] = histc(nxchange_set(:),bins);
    %%% handle outliers:
    idx(idx==0) = length(bins);
    corrected_hist = zeros(1,length(bins));
    for j=1:length(bins)
        corrected_hist(j) = sum(idx==j);
    end
    nxchange_hist(i,:) = corrected_hist;
end

% display(['old bins: ',num2str(nxchange_hist(end,:))]);
% display(['new bins: ',num2str(corrected_hist)]);

return