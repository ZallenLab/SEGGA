function v = findcells(img, minsize, inc, maxsize, workingarea, boundary_thickness, thick_mask)
%This function creates a list of the largest circles fitting into img (that
%is, circles not intersecting white pixels in img) at each point of a
%grid with grid spacing equal to inc. The analysis is limited to
%workingarea. It starts by trying to insert circles of radius minsize,
%continues by increasing the candidate circles' radius by inc until the 
%the circle itersects white pixels or radius is equal to maxsize.
%Scheme of the algorithm:
%Try to insert circles of radius r at list of points. For all points where
%this succeeded, set the circle radius to r. Increase r and repeat for
%these points.
%The function tries to insert circles for all the listed points AT ONCE. 
%This makes the procedure run much faster.

    inc = max([1 floor(inc)]);

    %crop the image to be the smallest rectangle covering the working
    %area with coordinates being integral multiples of minsize.
    top = max(floor(min(workingarea(:,1))/minsize)*minsize, minsize);
    left = max(floor(min(workingarea(:,2))/minsize)*minsize, minsize);
    bottom = ceil(max(workingarea(:,1))/minsize)*minsize;
    right = ceil(max(workingarea(:,2))/minsize)*minsize;
    if bottom > length(img(:,1))
        bottom = floor(length(img(:,1))/minsize)*minsize;
    end
    if right > length(img(1,:))
        right = floor(length(img(1,:))/minsize)*minsize;
    end
    
    img = img(top:bottom, left:right);
    thick_mask = thick_mask(top:bottom, left:right);
    workingarea(end +1,:) = workingarea(1,:);
    workingarea(:,1) = workingarea(:,1) - top;
    workingarea(:,2) = workingarea(:,2) - left;
  
    %xx and yy are the grid point coordinates
    x = [1+minsize:inc: right - left - minsize + 1];
    y = [1+minsize:inc:bottom - top - minsize + 1]';    
    xx = repmat(x, 1, length(y));
    yy = repmat(y, 1, length(x))';
    yy = reshape(yy, 1, length(x)*length(y));
    grid = zeros(1,length(xx));
    
    
    init_pts = ~thick_mask & ...
        poly2mask(workingarea(:,2), workingarea(:,1), bottom - top + 1, right -left + 1);
    
    pt_ind = init_pts(sub2ind(size(init_pts), yy, xx));
%    pt_ind(pt_ind) = inpolygon(xx(pt_ind), yy(pt_ind), workingarea(:,2), workingarea(:,1));
    pt_ind = insert_circles(pt_ind, minsize, minsize);
    first_ind = pt_ind;
    grid(pt_ind) = minsize;
    
    toc
    for r = minsize + inc: inc : maxsize
        pt_ind(sub2ind([length(x) length(y)], 1:length(x), ((r-minsize)/inc) .* ones(1,length(x)))) = 0;
        pt_ind(sub2ind([length(x) length(y)], 1:length(x), (length(y) - (r-minsize)/inc + 1) .* ones(1,length(x)))) = 0;
        pt_ind(sub2ind([length(x) length(y)], ((r-minsize)/inc) .* ones(1,length(y)), 1:length(y))) = 0;
        pt_ind(sub2ind([length(x) length(y)], (length(x) - (r-minsize)/inc + 1) .* ones(1,length(y)), 1:length(y))) = 0;
        pt_ind = insert_circles(pt_ind, r,inc);
        grid(pt_ind) = r;
        if ((r-minsize)/inc) >= length(x) || ((r-minsize)/inc) >= length(y)
            break
        end
    end


    v = [yy(first_ind); xx(first_ind); grid(first_ind)]';
    
    if length(v) > 0

        v=remove_dupes(thick_mask,v,maxsize, boundary_thickness); 

    else
        fprintf('No cells identified.\nTry changing pre-processing parameters or the working area.\n');
    end
    v(:,1) = v(:,1) + top - 1;
    v(:,2) = v(:,2) + left - 1;
%     v = int16(v); --ori dec 12 2008
    
%--------------------------------------------------------------------------
    function indices = insert_circles(indices, r, inc)
        %for each point in indices make a list of pixels composing the
        %circle of radius r around that point. Then keep in the indices
        %list only those points whose corresponding pixel list is
        %empty (i.e. does not intersect any boundaries).
        c = circle(r);
        c(inc+1:2*r + 1 -inc, inc+1:2*r + 1 -inc) = c(inc+1:2*r + 1 -inc, inc+1:2*r + 1 -inc) - circle(r - inc);
        c_indices = find(c);
        c_x = repmat(1:2*r +1, 1, 2*r +1)' -r -1;
        c_y = reshape(repmat((1:2*r +1)', 1, 2*r +1)', (2*r+1)^2, 1) -r -1;    

        ind_x_plus_c = repmat(xx(indices),length(c_indices),1) + ... 
        repmat(c_x(c_indices), 1, sum(indices));


        ind_y_plus_c = repmat(yy(indices),length(c_indices),1) + ... 
        repmat(c_y(c_indices), 1,sum(indices));

        indices(indices) = sum(img(sub2ind(size(img), ind_y_plus_c, ind_x_plus_c))) == 0;

    end    

end    
