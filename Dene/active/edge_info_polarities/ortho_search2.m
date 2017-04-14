function sample_pixels = ortho_search2(img_dims,max_rad,trap_bool,pt_one,pt_two)

% max_rad: the search distance
% junct_buffer: distance to move from end points before search for myosin
% centr_intrvl: distance between search points
% pt_one and pt_two: the end points of an edge

% sample_pixels is (length of line) X 2 X (search radius * 2 + 1) 



% Begin changes -- Ori, March 05, 2009 
[search_centers flipped] = connect_line(pt_one,pt_two);
sample_pixels = zeros(length(search_centers), 2, max_rad*2+1);
trans = -max_rad:max_rad;
sample_lngth = length(search_centers);
sample_wdth = length(trans);
if flipped
    dim1 = 2;
    dim2 = 1;
else
    dim1 = 1;
    dim2 = 2;
end
for i = 1:sample_lngth
    for j = 1:sample_wdth
        if search_centers(dim1, i) > img_dims(dim2) %img_dims are inverted
            sample_pixels(i, dim1, j) = nan;
            sample_pixels(i, dim2, j) = nan;
        else
            sample_pixels(i, dim1, j) = search_centers(dim1, i);
        end
        if search_centers(dim2, i) + trans(j) > img_dims(dim1)
            sample_pixels(i, dim2, j) = nan;
            sample_pixels(i, dim1, j) = nan;
        else
            sample_pixels(i, dim2, j) = search_centers(dim2, i) + trans(j);
        end
    end
end
sample_pixels(sample_pixels < 1) = nan;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% OLD VERSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % orth_dir = abs(pt_one - pt_two) == min(abs((pt_one - pt_two)));
% % % 
% % % if sum(orth_dir) ~= 1
% % %     orth_dir = [0,1];
% % % end
% % % 
% % % 
% % % search_path = [(-max_rad:max_rad)*orth_dir(1);(-max_rad:max_rad)*orth_dir(2)]; %translatable search path
% % % search_centers = connect_line(pt_one,pt_two); %centrs of pixels along edge
% % % sample_pixels = nan(length(search_centers),2,max_rad*2+1); % all sample pixels
% % % 
% % % 
% % % % stepwise function to account for junctions
% % % 
% % % 
% % % for i  = 1:length(search_centers)
% % %     
% % %    if trap_bool       
% % %        s_rad = get_s_rad(i,max_rad,search_centers);
% % %    else
% % %        s_rad = max_rad;
% % %    end
% % % 
% % %    
% % %     sample_pixels(i,:,max_rad+1 - s_rad : max_rad+1 + s_rad) = ...
% % %         [search_path(1,max_rad + 1 - s_rad : max_rad+1 + s_rad) + search_centers(1,i);...
% % %         search_path(2,max_rad+1 - s_rad : max_rad+1 + s_rad) + search_centers(2,i)]; 
% % %     
% % % end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % 
% % % 
% % % %  boundary conditions
% % % 
% % % back_to_nans = zeros(length(search_centers),max_rad*2+1);
% % % 
% % % for i = 1:length(search_centers)
% % %     for j = 1:(max_rad*2+1)
% % % 
% % % back_to_nans(i,j) = sample_pixels(i,1,j) <= 0 | sample_pixels(i,2,j) <= 0 ...
% % %     | sample_pixels(i,1,j) > img_dims(2) | sample_pixels(i,2,j) > img_dims(1);
% % % 
% % % if back_to_nans(i,j)
% % %     sample_pixels(i,:,j) = NaN;
% % % end
% % % 
% % %     end
% % %     
% % % end
% % % 
% % % 
% % %     
% % % function s_rad = get_s_rad(index_point,max_rad,search_centers)
% % % 
% % % i = index_point;
% % % l = length(search_centers);
% % % 
% % % if i < max_rad + 1
% % %     s_rad = i - 1;
% % %     
% % % elseif i > l - (max_rad + 1)
% % %     s_rad = l - (i + 1);
% % %     
% % % else s_rad = max_rad;
% % % 
% % % end
% % % 
%%%%%%%%%%%%%%%%%%%% end of changes -- Ori, March 05, 2009 