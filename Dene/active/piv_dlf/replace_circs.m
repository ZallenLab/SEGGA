function newmat =  replace_circs(mat_in,rad,label,locx,locy)
    
    [circmat, rel_indx, rel_indy] = concent_circs(rad,label);
    newmat = mat_in;
% place the circle in the bigger mat
    rel_indx = rel_indx + locx;
    rel_indy = rel_indy + locy;
% find which pixels go off the grid
    off_gridx = (rel_indx<1)|(rel_indx>size(mat_in,2));
    off_gridy = (rel_indy<1)|(rel_indy>size(mat_in,1));
    off_grid = off_gridx|off_gridy;
    

    
    lin_subinds = sub2ind(size(mat_in), rel_indy(~off_grid), rel_indx(~off_grid));
    newmat(lin_subinds) = circmat(~off_grid);
%     figure; imagesc(newmat);