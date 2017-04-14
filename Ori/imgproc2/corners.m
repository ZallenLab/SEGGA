function corners_img =corners(img, ind, boundary_indices)

%For every pixel listed in ind, checks if the 5x5 frame around it in img crosses
%more than 2 white regions (= boundaries between cells. That is, we are looking
%for pixels which are on the boundary of more than 2 cells). For every pixel in
%boundary_indices, checks if the 3x3 frame around it in img crosses more
%than 2 white regions. Returns an image in which every such pixel is set to
%one. Assumes pixels in ind are at least 2 pixels away from the boundaries 
%of img and pixels in boundary_indices are at least 1 pixel away.

    corners_img = zeros(size(img));

    nhood_x = [1 1 1 2 3 4 5 5 5 5 5 4 3 2 1 1];
    nhood_y = [3 2 1 1 1 1 1 2 3 4 5 5 5 5 5 4];
    
    nhood = sub2ind(size(img), nhood_x, nhood_y);
    nhood = nhood - sub2ind(size(img), 3, 3);

    ind = reshape(ind, 1, length(ind));
    ind_to_xor = repmat(ind, length(nhood_x), 1) + repmat(nhood', 1, length(ind));

    corners_img(ind(sum(xor(img(ind_to_xor) , img(circshift(ind_to_xor, 1))))>4))=1;




    nhood_x = [1 1 2 3 3 3 2 1];
    nhood_y = [2 1 1 1 2 3 3 3];
    nhood = sub2ind(size(img), nhood_x, nhood_y);
    nhood = nhood - sub2ind(size(img), 2, 2);

    boundary_indices = reshape(boundary_indices, 1, length(boundary_indices));
    ind_to_xor2 = repmat(boundary_indices, length(nhood_x), 1) + repmat(nhood', 1, length(boundary_indices));

    corners_img(boundary_indices(sum(xor(img(ind_to_xor2) , img(circshift(ind_to_xor2, 1))))>4))=1;
