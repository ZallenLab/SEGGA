function [avg std_err std_std num] = avg_shifted_vecs_with_nans_binned(vecs, shifts, ...
    boundary_mode_l, boundary_mode_r, time_steps, global_timescale,...
    bins, binning_func, avg_func, num_from_hist_bool)

stop_pasting_at_furthest_bool = false;

if nargin < 5 || isempty(time_steps)
    time_steps = ones(size(shifts));
end
if nargin < 6 || isempty(global_timescale)
    global_timescale = ((1:length(vecs{1})) + shifts(1))*time_steps(1)/60;
    global_timescale = global_timescale'; 
end

if nargin < 10 || isempty(num_from_hist_bool)
    num_from_hist_bool = false;
end


temp_sum = nan(length(global_timescale), length(bins));
temp_sum_list = cell(length(vecs));
% temp_sum_with_nans = temp_sum; %DLF edit 21 July 2010
first = inf;
last = -inf;
for i = 1:length(vecs) %number of movies
    binned_vec = binning_func(vecs{i},shifts(i),bins);%./size(vecs{i},2);
    timescale = ((1:size(vecs{i},1)) + shifts(i))*time_steps(i)/60;
    for j = 1:length(bins)
        shifted_vec = interp1q(timescale', binned_vec(:,j), global_timescale);
        first = min(first, find(~isnan(shifted_vec), 1));
        last = max(last, find(~isnan(shifted_vec), 1, 'last')); 
    %     temp_sum_with_nans(:, i) = shifted_vec; %DLF edit 21 July 2010
        shifted_vec = handle_boundary_nans(shifted_vec, boundary_mode_l, ...
        boundary_mode_r);
        temp_sum(:,j) = shifted_vec;
    end
    temp_sum_list{i} = temp_sum;
end

if nargin < 9 || isempty(avg_func)

    num = zeros(length(global_timescale), 1);
    totals = zeros(length(global_timescale), length(bins));
    avg_of_sq = totals;
    for i = 1:length(vecs)
        if num_from_hist_bool
            num = double(num + sum(temp_sum_list{i}, 2));
        else
            num = double(num + (sum(~isnan(temp_sum_list{i}), 2)>0)); 
        end
        temp_sum_list{i}(isnan(temp_sum_list{i})) = 0;
        totals = totals + temp_sum_list{i};
        avg_of_sq = avg_of_sq + temp_sum_list{i}.^2;
    end
        num = repmat(num,1,size(totals,2));
        avg = totals ./ num;
        avg_of_sq = avg_of_sq./ num;
        

    
    %DLF edit 21 July 2010
    diffs = (avg_of_sq - avg.^2);
    if min(diffs(:))<0
        diffs = round(diffs, 8);
    end
        std_err = realsqrt(...
            diffs .* ...
            (num) ./ (num - 1));
    %     std_err = nan(size(avg));
    %     for i = 1:length(num)
    %         if num(i) > 1
    %             std_err(i) = realsqrt(...
    %             ((avg_of_sq(i) - avg(i))^2) .* ...
    %             (num(i)) ./ (num(i) - 1));
    %         else
    %             std_err(i) = nan;
    %         end
    %     end

    %     avg(isnan(std_err))=nan;
    std_std = std_err;
    std_err = std_err ./ realsqrt(num);
else
    avg = nan(size(global_timescale));
    std_err = avg;
    std_std = avg;
    for t = 1:length(global_timescale)
         tmp_avg = avg_func(temp_sum(t, ~isnan(temp_sum(t, :))));
         if isempty(tmp_avg)
             tmp_avg = nan;
         end
         avg(t) = tmp_avg;
    end
end

% set the avg to nan at timepoints before and after the beginning of the 
% earliest and the end of the latest movie. (In case when 
% boundary_mode_r/l does not equal to 2),

if stop_pasting_at_furthest_bool
    for i = 1:length(bins)
        avg(1:(first-1),i) = nan;
        avg((last+1):end,i) = nan;
    end
end

function vec = handle_boundary_nans(vec, l, r)
first_real_ind = find(~isnan(vec), 1);
switch l
    case 0
        vec(1:(first_real_ind-1)) = 0;
    case 1
        vec(1:(first_real_ind-1)) = vec(first_real_ind);
end


last_real_ind = find(~isnan(vec), 1, 'last');
switch r
    case 0
        vec((last_real_ind+1):length(vec)) = 0;
    case 1
        vec((last_real_ind+1):length(vec)) = vec(last_real_ind);
end
