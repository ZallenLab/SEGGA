function new_data = smoothen_special(data, t, method, fill_nans, max_fillsize_val)
flip = false;
if ndims(data) == 2 && size(data, 1) == 1
    data = data';
    flip = true;
end
if nargin < 2 || isempty(t)
    t = 3;
end
if nargin < 3 || isempty(method)
    method= 'mean';
end
if nargin < 3 || isempty(fill_nans)
    fill_nans = false;
end

if nargin < 5 || isempty(max_fillsize_val)
    max_fillsize_val = 5;
end

ind = isnan(data);
% for i = 2:length(data(:, 1))
%     data(i, isnan(data(i, :))) = data(i-1, isnan(data(i, :)));
% end
% for i = (length(data(:, 1))-1):-1:1
%     data(i, isnan(data(i, :))) = data(i+1, isnan(data(i, :)));
% end
data = fill_nans_linear_special(data,max_fillsize_val);
new_data = nan(size(data));
for i = 1:length(data(:, 1))
    w = min([t, i - 1, length(data(:, 1)) - i]);
    switch method
        case 'mean'
            new_data(i, :) = mean(data(i-w : i+w, :), 1);
        case 'median'
            new_data(i, :) = median(data(i-w : i+w, :), 1);
    end
end
if ~fill_nans
    new_data(ind) = nan;    
end
if flip
    new_data = new_data';
end