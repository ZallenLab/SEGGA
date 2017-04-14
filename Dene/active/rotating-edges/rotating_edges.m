function [dv_to_ap, dv_to_ap_times, ap_to_dv, ap_to_dv_times] =  rotating_edges(ang,ang_params)

cuttoff_start_duration  = 5; %frames
cutoff_end_duration = 5; % frames

% weak_dv_ang = 30;
% weak_ap_ang = 70;
% strong_dv_ang = 30;
% strong_ap_ang = 70;


weak_dv_ang = ang_params.start_dv;
weak_ap_ang = ang_params.start_ap;
strong_dv_ang = ang_params.end_dv;
strong_ap_ang = ang_params.end_ap;



is_ever_weakly_dv = sum(ang < weak_dv_ang)>cuttoff_start_duration;
is_ever_weakly_ap = sum(ang > weak_ap_ang)>cuttoff_start_duration;

last45_rotate_vert = find_last_seconddim(ang(:,is_ever_weakly_dv)<weak_dv_ang);
last45_rotate_horz = find_last_seconddim(ang(:,is_ever_weakly_ap)>weak_ap_ang);




dv_to_ap = [];
last45_going_ap = [];
first_aps = [];
weakdvs_inds = find(is_ever_weakly_dv);
for i = 1:length(weakdvs_inds)
    curr_edge = weakdvs_inds(i);
    rotate_bool = sum(ang(last45_rotate_vert(i):end,curr_edge)>strong_ap_ang)>cutoff_end_duration;
    if rotate_bool
        dv_to_ap = [dv_to_ap,curr_edge];
        last45_going_ap = [last45_going_ap, last45_rotate_vert(i)];
        first_ap_temp = find(ang(last45_rotate_vert(i):end,curr_edge)>strong_ap_ang, 1, 'first');
        first_ap_temp = first_ap_temp + last45_rotate_vert(i) - 1;
        first_aps = [first_aps, first_ap_temp];
%         display('found dv to ap');
    end
end
dv_to_ap_times.last45_going_ap = last45_going_ap;
dv_to_ap_times.first_aps = first_aps;

ap_to_dv = [];
last45_going_dv = [];
first_dvs = [];
weakaps_inds = find(is_ever_weakly_ap);
for i = 1:length(weakaps_inds)
    curr_edge = weakaps_inds(i);
    rotate_bool = sum(ang(last45_rotate_horz(i):end,curr_edge)<strong_dv_ang)>cutoff_end_duration;
    if rotate_bool
        ap_to_dv = [ap_to_dv,curr_edge];
        last45_going_dv = [last45_going_dv, last45_rotate_horz(i)];
        first_dv_temp = find(ang(last45_rotate_horz(i):end,curr_edge)<strong_dv_ang, 1, 'first');
        first_dv_temp = first_dv_temp + last45_rotate_horz(i) - 1;
        first_dvs = [first_dvs, first_dv_temp];
%         display('found ap to dv');
    end
end

ap_to_dv_times.last45_going_dv = last45_going_dv;
ap_to_dv_times.first_dvs = first_dvs;