function edge_intensity = get_edge_intensity_val(img, sample_pixels, method, buffer)

% img is a uint16 mXn matrix
% sample_pixels is (length of line) X 2 X (search radius * 2 + 1)
% method is the function used to return a score for an edge
%  buffer is the number of pixels to drop at each endpoint

% edge_intensity is a real number, the score for an edge


if nargin < 3 || isempty(method) 
    method = 'maxes_then_mean';
end

if nargin < 4 || isempty(buffer)
    buffer = 2;
end

% if nargin < 5 || isempty(bck_grnd)
%     if strcmp(method,'summed_box')
%     display('warning: lacking background values for summed_box method')               
%     end
%     bck_grnd = 0;
% end

% check for what buffer to use
sample_lngth = size(sample_pixels,1);
if sample_lngth < 2*buffer + 1;
    edge_intensity = nan;
    return
end


%buffer / length problems -- Ori
if isempty(sample_pixels) ||  buffer < 0
    edge_intensity = nan;
    return
end

% apply the buffer (remove node pixels)
sample_pixels = sample_pixels(1+buffer:end-buffer,:,:);
sample_lngth = size(sample_pixels,1);


edge_intensity = feval(method, img, sample_pixels, sample_lngth);

%     if strcmp(method,'summed_box')
%        edge_intensity = (edge_intensity - (bck_grnd * numel(sample_pixels)/2))/(numel(sample_pixels)/2);               
%     end

end
   
    function edge_intensity = weighted_sum(img2,sample_pixels,sample_lngth)

% image is padded before calling reposition_edge, no nan values expected.    
%         if any(isnan(sample_pixels(:)))
%         edge_intensity = nan;
%         return
%     end

%     sample_lngth = size(sample_pixels,1); %Redundant.
    sample_wdth  = size(sample_pixels,3);

    
    pix_vals    = zeros(sample_lngth,sample_wdth); %changed from nan to zeros
    pix_weights = pix_vals; %will give zero weight to unassigned pixels 
                            %(pixels with nan in sample_pixles). If all
                            %pixels in sample_pixels are nan, val will have
                            %a nan value (due to normalization by sum(pix_weights))p.

    

    x_weight = zero2one(sample_lngth+2);
    x_weight = x_weight(2:end-1) .* x_weight(end-1:-1:2);

    y_weight = zero2one(sample_wdth+2);
    y_weight = y_weight(2:end-1) .* y_weight(end-1:-1:2);

    %% Changed to gain some speed. nan values in sample_pixels will 
    %result in an error and should be taken care of before this point.
    %If nans are treated here, pix_vals and pix_weigths must both be 
    %changed to have compatible indices. March 05, 2009 -- Ori. 
    
    img_length = size(img2,1);
    for i = 1:sample_lngth
        for j = 1:sample_wdth
            if isnan(sample_pixels(i, 1, j)) || isnan(sample_pixels(i, 2, j)) %Now taking care of nan values
                continue
            end
            pix_weights(i,j) = ((x_weight(i)).^(1/4)) .* ((y_weight(j).^3)); %removed *2 should have no effect -- March 24 -- Ori.
            pix_vals(i,j) = img2(img_length * (sample_pixels(i, 1, j)-1) + sample_pixels(i, 2, j));
        end
    end
    weighted_vals = (pix_vals.*pix_weights);
    edge_intensity = sum(weighted_vals(:)) / sum(pix_weights(:));
    
    

    
    end
    
   function edge_intensity = summed_box(img2,sample_pixels,sample_lngth)
   sample_wdth  = size(sample_pixels,3);
   pix_vals = nan(sample_lngth,sample_wdth); 
   img_length = size(img2,1);
    for i = 1:sample_lngth
        for j = 1:sample_wdth
            if isnan(sample_pixels(i, 1, j)) || isnan(sample_pixels(i, 2, j)) %Now taking care of nan values
                continue
            end
            pix_vals(i,j) = img2(img_length * (sample_pixels(i, 1, j)-1) + sample_pixels(i, 2, j));
        end
    end
    edge_intensity = sum((pix_vals(:))) / numel(pix_vals);    
    end


   function edge_intensity = maxes_then_mean(img2,sample_pixels,sample_lngth)
   sample_wdth  = size(sample_pixels,3);
   pix_vals = nan(sample_lngth,sample_wdth); 
   img_length = size(img2,1);
    for i = 1:sample_lngth
        for j = 1:sample_wdth
            if isnan(sample_pixels(i, 1, j)) || isnan(sample_pixels(i, 2, j)) %Now taking care of nan values
                continue
            end
            pix_vals(i,j) = img2(img_length * (sample_pixels(i, 1, j)-1) + sample_pixels(i, 2, j));
        end
    end
    max_vals = max(pix_vals, [], 2);
    edge_intensity = sum(max_vals(:) / sample_lngth);
    

    
    end



    %  mode is biased to take the first value it sees if there is no mode
    function edge_intensity = maxes_then_mode(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_maxes = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_maxes(i) = max(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = mode(new_maxes);
    end

    

    function edge_intensity = maxes_then_max(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_maxes = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_maxes(i) = max(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = max(new_maxes);
    end


    function edge_intensity = sum_then_mean(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_sums = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_sums(i) = sum(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = mean(new_sums);
    end



    function edge_intensity = sum_then_mode(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_sums = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_sums(i) = sum(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = mode(new_sums);
    end



    function edge_intensity = sum_then_max(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_sums = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_sums(i) = sum(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = max(new_sums);
    end




    function edge_intensity = means_then_mean(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_means = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_means(i) = mean(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = mean(new_means);
    end




    function edge_intensity = means_then_mode(img,sample_pixels, sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_means = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_means(i) = mean(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = mode(new_means);
    end

    function edge_intensity = means_then_max(img,sample_pixels,sample_lngth)
    sample_lngth = size(sample_pixels,1);
    new_means = nan(1,sample_lngth);

    for i = 1:sample_lngth

        taker_pix = leave_out_nans(squeeze(sample_pixels(i, :, :)));
        new_means(i) = mean(get_part_from_matrix(img,taker_pix(1,:),taker_pix(2,:)));    

    end
    edge_intensity = max(new_means);
    end


% 
% function modes_then_mean
% 
% function modes_then_mode
% 
% function modes_then_max

function vec = zero2one(len)
vec = (0:(len-1))/(len-1);
% % vec = exp(-(tan(pi*vec/2)/2).^2);
% vec = vec + vec.*(2-vec);
end