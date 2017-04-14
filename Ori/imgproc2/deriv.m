function d = deriv(data, wl, filter_order, drv_order, wr, left_deriv, right_deriv)
if isvector(data)
    data = data(:);
end
if nargin < 2 || isempty(wl)
    wl = 7;
end
if nargin < 3 || isempty(filter_order)
    filter_order = 2;
end
if nargin < 4 || isempty(drv_order)
    drv_order = 1;
end
if nargin < 5 || isempty(wr)
    wr = wl;
end
c = sgfilter(wl, wr, filter_order, drv_order);
for i = 1:length(data(1, :))
    f = find(~isnan(data(:, i)), 1);
    l = find(~isnan(data(:, i)), 1, 'last');
    data(1:f, i) = data(f, i);
    data(l:end, i) = data(l, i);
end

if nargin > 6 && ~isempty(right_deriv) && right_deriv
    c = c((wl+2):(wl+1+wr)).*2;  %right deriv
    c = [-sum(c); c];
    wl = 0;
elseif nargin> 5 && ~isempty(left_deriv) && left_deriv
    c = c(1:(wl)).*2;  %left deriv
    c = [c; -sum(c)];
    wr = 0;
end
% data(isnan(data)) = 0;
data = fill_nans_linear(data);
pad_data = [repmat(data(1,:), wl, 1) ; data ; repmat(data(end,:), wr, 1)];
d = zeros(size(data));
for i = 1:length(data(:,1))
    t = zeros(1, length(data(1,:)));
    for j = -wl:wr
%        t = t + c(w+1+j).*pad_data(i + w + j, :) + c(w+1-j) .* pad_data(i + w - j, :);
        t = t + c(wl+1+j).*pad_data(i + wl + j, :);
    end
    d(i, :) = t;
end
