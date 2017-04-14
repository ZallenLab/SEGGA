function B = flatten(A)

% flattens n-dimensional matrix to 1-D list.

B = reshape(A,1,prod(size(A)));
