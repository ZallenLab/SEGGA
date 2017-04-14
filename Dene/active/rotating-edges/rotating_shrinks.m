function [dv_to_shrinks, dv_to_shrinks_times] =  rotating_shrinks(ang,shrink_inds,shrink_times,timestep)

% this finds dv to shrink (may or may not rotate)

cuttoff_dv_duration  = ceil(2.5*60/timestep); % 2.5 mins
time_distance_dv_before_shrink = ceil(5*60/timestep); % 5 mins

% find edges that were ever dv
weak_dv_ang = 45;
is_ever_weakly_dv = sum(ang < weak_dv_ang)>cuttoff_dv_duration;
%  change to linear
is_ever_weakly_dv_inds = find(is_ever_weakly_dv);
% which shrinks are in that group
dv_shrink_inds = ismember(shrink_inds,is_ever_weakly_dv_inds, 'legacy');
% shorten the shrink times to the list above
shrink_times_untested =  shrink_times(dv_shrink_inds);

% the list that will be pared down
dv_to_shrink_untested = shrink_inds(dv_shrink_inds);



dv_to_shrinks = [];
shrink_times_tested = [];
last45_shrink = [];


for i = 1:length(dv_to_shrink_untested)
    curr_edge = dv_to_shrink_untested(i);
    temp_endtime = max(1,shrink_times_untested(i) - time_distance_dv_before_shrink);
    exist_dv_early_bool = sum(ang(1:temp_endtime,curr_edge)<weak_dv_ang)>cuttoff_dv_duration;
    last45_shrink_temp = find(ang(1:shrink_times_untested(i),curr_edge)<weak_dv_ang,1,'last');
    if exist_dv_early_bool
        dv_to_shrinks = [dv_to_shrinks,curr_edge];
        last45_shrink = [last45_shrink, last45_shrink_temp];
        shrink_times_tested = [shrink_times_tested, shrink_times_untested(i)];
%         display('found dv to shrink');
    end
end
dv_to_shrinks_times.last45_shrink = last45_shrink;
dv_to_shrinks_times.shrink_times_tested = shrink_times_tested;
