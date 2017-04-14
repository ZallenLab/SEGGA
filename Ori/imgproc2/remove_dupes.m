function v=remove_dupes(img, v, allowed_radius, boundary_thickness)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% I assume that all the circles centers are at least rad %
                %% away from the img boundary                             %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function received a list of circles (v) and keep in it only non 
%intersecting circles which are not inside the same cell.
%Not in the same cell - This is determined by trying to pass lines between
%the two circles and computing how many white pixels they intersect.
%The test whether circles are intersecting is partitioned into blocks
%in order to accelerate the process

img = ~bwareaopen(~img, 4, 4);
[m n] = size(img);
if length(v) > 0
    fprintf('\nnumber of circles is %u\n\n', length(v(:,1)));
    toc
    fprintf('Removing multiple finds...\n\n');
    ind = true(length(v(:,1)), 1);
    v=sortrows(v,3);
    max_radius = v(end,3);
    x = 1:2*max_radius:m;
    y = 1:2*max_radius:n;
    [xx yy] = meshgrid(x, y);
    [v_by_x by_x_ind] = sort(v(:,1));
    [v_by_y by_y_ind] = sort(v(:,2));
    
    x_start_ind = zeros(1,length(x));
    y_start_ind = zeros(1,length(y));
    for i = 1:length(x)
        x_start_ind(i) = min([length(v) find(v_by_x >= x(i), 1, 'first')]);
    end
    x_end_ind = [x_start_ind(3:end) length(v_by_x)];
    x_start_ind = x_start_ind(1:end-1);
    for i = 1:length(y)
        y_start_ind(i) = min([length(v) find(v_by_y >= y(i), 1, 'first')]);
    end
    y_end_ind = [y_start_ind(3:end) length(v_by_y)];
    y_start_ind = y_start_ind(1:end-1);
    for k=1:length(x_start_ind)
        for l=1:length(y_start_ind)
            block_ind = intersect(by_x_ind(x_start_ind(k):x_end_ind(k)), ...
                by_y_ind(y_start_ind(l):y_end_ind(l)), 'legacy');
            block_ind = block_ind(ind(block_ind));
            I = 1;
            while I < length(block_ind) +1 % v is shrinking...
                for J=I+1:length(block_ind)
                    if (v(block_ind(I),1)-v(block_ind(J),1))^2 + ...
                            (v(block_ind(I),2)-v(block_ind(J),2))^2 < ...
                            (v(block_ind(I),3)+v(block_ind(J),3) + boundary_thickness)^2  
                        ind(block_ind(I)) = 0;
                        break; 
                    end
                end
              I=I+1;
            end
        end
    end
    v = v(ind, :);
    
    

%     % Are the two balls touching?
%     while I < length(ind) +1 % v is shrinking...
%         for J=I+1:length(ind)
%             if (v(I,1)-v(J,1))^2 + (v(I,2)-v(J,2))^2 < (v(I,3)+v(J,3) + boundary_thickness)^2  
%                 ind(I) = 0;
%                 break; 
%             end
%         end
%       I=I+1;
%     end
%     v = v(ind, :);
    fprintf('number of circles is %u\n\n', length(v(:,1)));
    toc
    I =1;
       
       
    ind = true(1,length(v(:,1)));
    % is there a cell boundary between the two balls?
    dxx = repmat(v(:,1), 1, length(v(:,1)));
    dyy = repmat(v(:,2), 1, length(v(:,2)));
    dxx = dxx' - dxx;
    dyy = dyy' - dyy;
    dist = dxx.^2 + dyy.^2;
    [x y] = find(triu(dist < 4*allowed_radius^2, 1));
    for k = 1:length(x)  % v is shrinking...
        I = x(k);
        J = y(k);
        pt1 = [v(I,2), v(I,1)];
        pt2 = [v(J,2), v(J,1)];
        rad = min(v(J,3), v(I,3));
        if ind(I) & ind(J)

            connecting_line = connect_line(pt1, pt2);
            if ~length(connecting_line)
                ind(I) = 0;
            else
                if abs(pt1(1) - pt2(1)) > abs(pt1(2) - pt2(2))
                    connecting_line = [connecting_line [connecting_line(1,:) ; connecting_line(2,:) + 1] [connecting_line(1,:) ; connecting_line(2,:) - 1]]; 

                    connecting_line2 = connecting_line;
                    connecting_line3 = connecting_line;
                    connecting_line2(2,:) = connecting_line(2,:) + rad -2;
                    connecting_line3(2,:) = connecting_line(2,:) - rad +2 ;
                else
                    connecting_line = [connecting_line [connecting_line(1,:) + 1; connecting_line(2,:)] [connecting_line(1,:) - 1; connecting_line(2,:)]]; 

                    connecting_line2 = connecting_line;
                    connecting_line3 = connecting_line;
                    connecting_line2(1,:) = connecting_line(1,:) + rad -2;
                    connecting_line3(1,:) = connecting_line(1,:) - rad +2;
                end



                %sub2ind is slow...
                first_intersect = sum(img((connecting_line(1,:) - 1)*m + connecting_line(2,:)));
                second_intersect = sum(img((connecting_line2(1,:) - 1)*m + connecting_line2(2,:)));
                third_intersect = sum(img((connecting_line3(1,:) - 1)*m + connecting_line3(2,:)));
    %                max_intersect = max([first_intersect, second_intersect, third_intersect]);
                num_of_empty = ~first_intersect + ~second_intersect +~third_intersect;
                sum_of_intersect = first_intersect + second_intersect + third_intersect;
    %                if (sum_of_intersect < 5 & num_of_empty > 1) | ...
    %                        (num_of_empty == 2 & dist_sq < allowed_radius^2 & sum_of_intersect < 9) | ...
    %                        (num_of_empty == 1 & (dist_sq < (allowed_radius /1)^2) & sum_of_intersect < 12)
                if num_of_empty >1 || (num_of_empty == 1 && sum_of_intersect < (0.5 * allowed_radius))
                    ind(I) = 0;
                end
            end
        end
    end
    v = v(ind, :);
    fprintf('\nnumber of circles is %u\n\n', length(v(:,1)));
end