function parts = get_part_from_matrix(mat,x,y)

% written for a 2-D matrix


m = size(mat,1);

parts = mat(m*(x(:)-1) + y(:));