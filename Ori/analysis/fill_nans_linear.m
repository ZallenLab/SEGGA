function mat = fill_nans_linear(mat, fill_l, fill_r)
if nargin < 2 || isempty(fill_l)
    fill_l = true;
end
if nargin < 3 || isempty(fill_r)
    fill_r = true;
end

for i= 1:length(mat(1, :))
    mat(:, i) = fill_nans(mat(:, i), fill_l, fill_r);
end



function vec = fill_nans(vec, fill_l, fill_r)
ind = isnan(vec);
if ~any(ind) || all(ind)
    return
end
boundaries = find(xor(ind(1:end-1), ind(2:end)));
if ind(1) && boundaries(1) > 0
    boundaries = [0; boundaries];
    if ~fill_l
        boundaries = boundaries(3:end);
    end
end
if ind(end) && boundaries(end) < length(ind) 
    boundaries = [boundaries; length(ind)];
    if ~fill_r
        boundaries = boundaries(1:end-2);
    end

end

for i = 1:2:(length(boundaries) - 1)
    indices = false(size(ind));
    indices((1+boundaries(i)):boundaries(i+1)) = 1;
    indices = indices & ind;
    if boundaries(i) > 0
        lval = vec(boundaries(i));
    else
        lval = vec(boundaries(i+1) + 1);
    end
    if boundaries(i+1) < length(ind)
        rval = vec(boundaries(i+1)+ 1);
    else
        rval = vec(boundaries(i));
    end
    vec(indices) = approx_lin(lval, rval, boundaries(i+1) - boundaries(i));
end

function v = approx_lin(l, r, n);
v = l + (1:n) .* (r-l) ./ (n + 1);
