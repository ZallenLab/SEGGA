function value = quantile(data, q)
data = sort(data(~isnan(data(:))));
value = data(max(1, min(length(data), round(length(data)*q))));