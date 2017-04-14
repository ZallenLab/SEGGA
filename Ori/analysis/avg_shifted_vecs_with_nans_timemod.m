function [avg std_err std_std num] = avg_shifted_vecs_with_nans_timemod(vecs, shifts, ...
    boundary_mode_l, boundary_mode_r, time_steps, global_timescale, avg_func, xvals)

if nargin < 5 || isempty(time_steps)
    time_steps = ones(size(shifts));
end
if nargin < 6 || isempty(global_timescale)
    global_timescale = ((1:length(vecs{1})) + shifts(1))*time_steps(1)/60;
    global_timescale = global_timescale'; 
end

temp_sum = nan(length(global_timescale),  length(vecs));
% temp_sum_with_nans = temp_sum; %DLF edit 21 July 2010
first = inf;
last = -inf;
for i = 1:length(vecs);
    timescale = xvals{i};
    shifted_vec = interp1q(timescale', vecs{i}(:), global_timescale);
    first = min(first, find(~isnan(shifted_vec), 1));
    last = max(last, find(~isnan(shifted_vec), 1, 'last')); 
%     temp_sum_with_nans(:, i) = shifted_vec; %DLF edit 21 July 2010
    shifted_vec = handle_boundary_nans(shifted_vec, boundary_mode_l, ...
        boundary_mode_r);
    temp_sum(:, i) = shifted_vec;
    
end

if nargin < 7 || isempty(avg_func)
    num = sum(~isnan(temp_sum), 2); 
%     num = sum(~isnan(temp_sum_with_nans), 2); %DLF edit 21 July 2010
    temp_sum(isnan(temp_sum)) = 0;
    avg = sum(temp_sum, 2) ./ num;
    avg_of_sq = sum(temp_sum.^2, 2)./ num;

    
    
%DLF edit 21 July 2010    
    std_err = realsqrt(...
        ceil((avg_of_sq - avg.^2).*1000)./1000 .* ...
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
        avg(t) = avg_func(temp_sum(t, ~isnan(temp_sum(t, :))));
    end
end
% set the avg to nan at timepoints before and after the beginning of the 
% earliest and the end of the latest movie. (In case when 
% boundary_mode_r/l does not equal to 2),
avg(1:(first-1)) = nan;
avg((last+1):end) = nan;

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
