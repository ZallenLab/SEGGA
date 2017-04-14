function nn = n_nearest_neighobrs_2d(ax, ay, bx, by, n)
%for every item in a find the n nearest neighbors in b

xx = repmat(ax(:), 1, length(bx)) - repmat(bx(:)', length(ax), 1);
yy = repmat(ay(:), 1, length(by)) - repmat(by(:)', length(ay), 1);
d = xx.^2 + yy.^2;
[d nn] = sort(d, 2);
nn = nn(:, 1:n);
