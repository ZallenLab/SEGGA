function meanseries = nanmean_dlf(matwithnans)

series_len = size(matwithnans,1);
meanseries = nan(series_len,1);

for i = 1:series_len
    meanseries(i) = mean(matwithnans(i,~isnan(matwithnans(i,:))));
end

