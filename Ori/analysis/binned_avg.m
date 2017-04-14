function [a s] = binned_avg(x, bins, y, cyclic)
x_in_bin = zeros(length(x), 1);
for i = 1:length(bins)
    x_in_bin(x > bins(i)) = i;
end
if cyclic
    x_in_bin(x_in_bin == length(bins)) = 1;
end
% x_in_bin = x_in_bin +1;
a = accumarray(x_in_bin, y, [length(bins) 1], @mean);
s = accumarray(x_in_bin, y, [length(bins) 1], @std);
if cyclic
    a(end) = a(1);
    s(end) = s(1);
end