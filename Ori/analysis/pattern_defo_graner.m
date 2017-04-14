function [m_avg, m] = pattern_defo_graner(geom, cells)
%%% OUTPUTS:
% m_avg - average pattern deformation on the tissue
% m - pattern deformation of each cell

cnt = 0;
xx = zeros(1, length(cells));
yy = xx;
xy = xx;
for cell = cells
    cnt = cnt + 1;
    %find node-neighbors.
    nghbrs = get_cell_nghbrs(geom, cell);

    %measure distantances.
    x = geom.circles(nghbrs, 1) - geom.circles(cell, 1);
    y = geom.circles(nghbrs, 2) - geom.circles(cell, 2);
    
    %texture matrix for each cell.
    xx(cnt) = mean(x.^2) ;
    yy(cnt) = mean(y.^2) ;
    xy(cnt) = mean(x.*y) ;
end

%%%ALL CELLS

%compute ellipse.
[L1 L2 angle] = tensor_props(xx, xy, yy);

m = realsqrt(L1 ./ L2); 

%%%MEAN OF TISSUE

%average matrices.
xx_avg = mean(xx);
yy_avg = mean(yy);
xy_avg = mean(xy);

%compute ellipse.
[L1_avg L2_avg angle_avg] = tensor_props(xx_avg, xy_avg, yy_avg);

m_avg = realsqrt(L1_avg / L2_avg); 

