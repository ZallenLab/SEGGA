function shrinking_edge_angles_new


% in this file "single_global_ind" denotes t1 inds, so shrinking to a t1

% saving the following vars with the following definitions

% 'shrink_angs_new': first file name
% 'all_ang_sh_mean':
% 'selectlength_ang_sh_mean'
% 'all_ang_sh_hist'
% 'selectlength_ang_sh_hist'
% 'linked_ang_sh_mean'
% 'vert_ang_sh_mean'
% 'ros_ang_sh_mean'
% 'ros_ang_sh_hist'
% 'all_contract_rate_mean'
% 'selectlength_contract_rate_mean'
% 'linked_contract_rate_mean'
% 'vert_contract_rate_mean'
% 'ros_contract_rate_mean'
% 'singlevert_contract_rate_mean'
% 'shrink_linked_ang_sh_mean'
% 'shrink_linked_contract_rate_mean'
% 'just_vlinked_mean'
% 'just_vert_isos_mean'
% 't1_contract_rate_mean'
% 'nonvert_contract_rate_mean'


% 
% 'shrink_rate_ratios': second file name to save
% 'shrink_rate_diffs': third file name to save
% shrink_rate_ratios.shrinkshrink_over_vertt1s: shrink linked rate over
% single vert shrink rate
% shrink_rate_ratios.ros_over_t1s: ros rate over t1 rate
% shrink_rate_ratios.vertlinkedall_over_vertisot1s: vertical, shrinking or
% not over vertical t1s shrink rate
% shrink_rate_ratios.nonvert_over_vert = nonvert_contract_rate_mean./vert_contract_rate_mean;
% shrink_rate_diffs.vertt1s_and_shrinkshrink = (singlevert_contract_rate_mean-shrink_linked_contract_rate_mean)./all_contract_rate_mean;
% shrink_rate_diffs.t1s_and_ros = (t1_contract_rate_mean-ros_contract_rate_mean)./all_contract_rate_mean;
% shrink_rate_diffs.vertisot1s_and_vertlinkedall = (singlevert_contract_rate_mean-just_vlinked_mean)./all_contract_rate_mean;
% shrink_rate_diffs.vert_and_nonvert = (vert_contract_rate_mean-nonvert_contract_rate_mean)./all_contract_rate_mean;
% 





load('analysis','data','misc','clusters');
load('where_shrinks_go', 'shrink_to_ros');
if isempty(whos('shrink_to_ros'))
    display('lacking where_shrinks_go info');
    return
end

load('aligned_edges_info_linkage', 'v_linked','vertical_edges','shrink_to_shrink_linked')

shrink_global_inds = [];
shrink_global_inds = [shrink_global_inds,clusters(:).edges];
shrink_global_inds = unique(shrink_global_inds, 'legacy');

if length(shrink_to_ros)==length(shrink_global_inds)
    ros_global_inds = shrink_global_inds(logical(shrink_to_ros));
    single_global_inds = shrink_global_inds(~logical(shrink_to_ros));
else
    display('problem: ros index list is not the same size as the list of shrinking edges');
    return
end

ang_sh = mod(data.edges.angles, 180);
ang_sh = 90 - abs(90 - ang_sh);  

vel_sh = deriv(data.edges.len);


num_frames = size(data.edges.selected,1);
all_ang_sh_mean = nan(num_frames,1);
selectlength_ang_sh_mean = all_ang_sh_mean;
linked_ang_sh_mean = all_ang_sh_mean;
vert_ang_sh_mean = all_ang_sh_mean;
ros_ang_sh_mean = all_ang_sh_mean;
shrink_linked_ang_sh_mean = all_ang_sh_mean;


all_contract_rate_mean = nan(num_frames,1);
selectlength_contract_rate_mean = all_ang_sh_mean;
linked_contract_rate_mean = all_ang_sh_mean;
vert_contract_rate_mean = all_ang_sh_mean;
nonvert_contract_rate_mean = all_ang_sh_mean;
ros_contract_rate_mean = all_ang_sh_mean;
t1_contract_rate_mean = all_ang_sh_mean;
singlevert_contract_rate_mean = all_ang_sh_mean;
shrink_linked_contract_rate_mean = all_ang_sh_mean;
just_vlinked_mean = all_ang_sh_mean;
just_vert_isos_mean = all_ang_sh_mean;

max_pos_len = 12;
min_pos_len = 6;

shrink_global_inds_long = zeros(1,size(data.edges.selected,2));
shrink_global_inds_long(shrink_global_inds) = 1;

ros_global_inds_long = zeros(1,size(data.edges.selected,2));
ros_global_inds_long(ros_global_inds) = 1;

single_global_inds_long = zeros(1,size(data.edges.selected,2));
single_global_inds_long(single_global_inds) = 1;


ang_bins = 0:15:90;
ang_bins(end) = ang_bins(end)+1;

all_ang_sh_hist.bins = ang_bins;
all_ang_sh_hist.data = nan(num_frames,length(ang_bins));

selectlength_ang_sh_hist.bins = ang_bins;
selectlength_ang_sh_hist.data = nan(num_frames,length(ang_bins));

linked_ang_sh_hist.bins = ang_bins;
linked_ang_sh_hist.data = nan(num_frames,length(ang_bins));

vert_ang_sh_hist.bins = ang_bins;
vert_ang_sh_hist.data = nan(num_frames,length(ang_bins));

ros_ang_sh_hist.bins = ang_bins;
ros_ang_sh_hist.data = nan(num_frames,length(ang_bins));


for i = 1:num_frames
    
    all_angs_to_take = data.edges.selected(i,:)&shrink_global_inds_long;    
    all_ang_sh_mean(i) = mean(ang_sh(i,all_angs_to_take));
    all_ang_sh_hist.data(i,:) = histc(ang_sh(i,all_angs_to_take),ang_bins);
    all_ang_sh_hist.data(i,:) = all_ang_sh_hist.data(i,:)/sum(all_ang_sh_hist.data(i,:));
    all_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,all_angs_to_take)));
    
    selectlength_angs_to_take = data.edges.selected(i,:)&shrink_global_inds_long...
        &data.edges.len(i,:)>min_pos_len&data.edges.len(i,:)<max_pos_len;
    selectlength_ang_sh_mean(i) = mean(ang_sh(i,selectlength_angs_to_take));
    selectlength_ang_sh_hist.data(i,:) = histc(ang_sh(i,selectlength_angs_to_take),ang_bins);
    selectlength_ang_sh_hist.data(i,:) = selectlength_ang_sh_hist.data(i,:)/sum(selectlength_ang_sh_hist.data(i,:));
    selectlength_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,selectlength_angs_to_take)));
    
    linked_angs_to_take = v_linked(i,:)&shrink_global_inds_long;    
    linked_ang_sh_mean(i) = mean(ang_sh(i,linked_angs_to_take));
    linked_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,linked_angs_to_take)));
    
    just_vlinked_mean(i) = mean(nonzeros(vel_sh(i,v_linked(i,:))));
    
    
    vert_angs_to_take = vertical_edges(i,:)&shrink_global_inds_long;    
    vert_ang_sh_mean(i) = mean(ang_sh(i,vert_angs_to_take));
    vert_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,vert_angs_to_take)));
    
	nonvert_angs_to_take = ~vertical_edges(i,:)&shrink_global_inds_long;    
    nonvert_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,nonvert_angs_to_take)));
    
    
    just_vert_isos_mean(i) = mean(nonzeros(vel_sh(i,vertical_edges(i,:)&~v_linked(i,:))));
    
    ros_angs_to_take = data.edges.selected(i,:)&ros_global_inds_long;    
    ros_ang_sh_mean(i) = mean(ang_sh(i,ros_angs_to_take));
    ros_ang_sh_hist.data(i,:) = histc(ang_sh(i,ros_angs_to_take),ang_bins);
    ros_ang_sh_hist.data(i,:) = all_ang_sh_hist.data(i,:)/sum(ros_ang_sh_hist.data(i,:));
    ros_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,ros_angs_to_take)));
    
    
    t1_angs_to_take = data.edges.selected(i,:)&single_global_inds_long;
    t1_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,t1_angs_to_take)));
    
    
    
    singlevert_angs_to_take = vertical_edges(i,:)&single_global_inds_long&~v_linked(i,:);    
    singlevert_ang_sh_mean(i) = mean(ang_sh(i,singlevert_angs_to_take));
    singlevert_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,singlevert_angs_to_take)));
    
    shrink_linked_angs_to_take = shrink_to_shrink_linked(i,:)&shrink_global_inds_long;    
    shrink_linked_ang_sh_mean(i) = mean(ang_sh(i,shrink_linked_angs_to_take));
    shrink_linked_contract_rate_mean(i) = mean(nonzeros(vel_sh(i,shrink_linked_angs_to_take)));
    
    
end

save('shrink_angs_new','all_ang_sh_mean','selectlength_ang_sh_mean','all_ang_sh_hist','selectlength_ang_sh_hist',...
    'linked_ang_sh_mean','vert_ang_sh_mean','ros_ang_sh_mean','ros_ang_sh_hist',...
    'all_contract_rate_mean','selectlength_contract_rate_mean','linked_contract_rate_mean',...
    'vert_contract_rate_mean','ros_contract_rate_mean','singlevert_contract_rate_mean',...
    'shrink_linked_ang_sh_mean','shrink_linked_contract_rate_mean','just_vlinked_mean',...
    'just_vert_isos_mean', 't1_contract_rate_mean', 'nonvert_contract_rate_mean');

%  do some ratios

shrink_rate_ratios.shrinkshrink_over_vertt1s = shrink_linked_contract_rate_mean./singlevert_contract_rate_mean;
shrink_rate_ratios.ros_over_t1s = ros_contract_rate_mean./t1_contract_rate_mean;
shrink_rate_ratios.vertlinkedall_over_vertisot1s = just_vlinked_mean./singlevert_contract_rate_mean;
shrink_rate_ratios.nonvert_over_vert = nonvert_contract_rate_mean./vert_contract_rate_mean;


shrink_rate_diffs.vertt1s_and_shrinkshrink = (singlevert_contract_rate_mean-shrink_linked_contract_rate_mean)./all_contract_rate_mean;
shrink_rate_diffs.t1s_and_ros = (t1_contract_rate_mean-ros_contract_rate_mean)./all_contract_rate_mean;
shrink_rate_diffs.vertisot1s_and_vertlinkedall = (singlevert_contract_rate_mean-just_vlinked_mean)./all_contract_rate_mean;
shrink_rate_diffs.vert_and_nonvert = (vert_contract_rate_mean-nonvert_contract_rate_mean)./all_contract_rate_mean;

save('shrink_rate_ratios', 'shrink_rate_ratios');
save('shrink_rate_diffs','shrink_rate_diffs');

