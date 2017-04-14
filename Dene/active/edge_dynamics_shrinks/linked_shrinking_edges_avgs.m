function linked_shrinking_edges_avgs(directory)
if~isempty(dir('timestep'))
load('timestep')
else timestep = 15;
end


if nargin < 1 || isempty(directory)
    directory = pwd;
end
cd(directory);
% seq = load_dir(directory);
% 
%     seq.t = seq.frames(1).t;
%     seq.z = seq.frames(1).z;
%     seq.img_num = seq.frames_num(seq.t, seq.z);
%     [seq.frames.cells] = deal([]);
%     [seq.frames.edges] = deal([]);
% load('analysis', 'seq')
% seq= update_seq_dir(seq);
% t_start = 1;
% t_end = length(seq.frames);
% if length(dir('time_points_to_anal'))
%     load('time_points_to_anal');
% end
%     
% load('poly_seq');
load analysis;
load shrinking_edges_info_new;

% function v = v_linkage_over_time(seq, data, all_links, theta, shift)
small_thresh = 7;
[v_linked v_linked_drop_smalls vertical_edges] = find_vert_linked(seq, data, misc.all_links, 15, 0, small_thresh);
% v_linked: for all edges, linked or not?
% vertical_edges: for all edges, vertical or not?
shrinking_edges_ind = zeros(size(data.edges.len));
shrinking_edges_ind(:,unique([clusters.edges], 'legacy')) = true;
shrink_to_shrink_linked = find_shrink_linked(seq, data, misc.all_links, shrinking_edges_ind);

shrink_isolated = find_shrink_isolated(seq, data, misc.all_links, shrinking_edges_ind);

%     save('aligned_edges_info_linkage', ...
%     'shrink_to_shrink_linked','-append')
% 
% return

% % %  now we need to find out which of the shrinking edges are linked
shrinking_edges_vlinked = sort_vlink_shrinks(v_linked,edges_global_ind);
% n x m
% time x number of edges
% shrinking_edges_vlinked(i,:) = all edges at a point in time
% shrinking_edges_vlinked(:,i) = all points in time for an edge

aligned_vlinked = zeros(size(shrinking_edges_vlinked));
% % now we need to make the list aligned 
% %  this is for a dynamical list (edges can move in and out of 'linked')
% for i = 1:length(shrinking_edges_vlinked(1,:))
%     
%     end_point = shrink_times(i);
%     temp = shrinking_edges_vlinked(end_point:-1:1,i);
%     aligned_vlinked(1:length(temp),i) = temp;
% end


% % %  THE OTHER WAY
% now we need to make the list aligned (for static we define all time points)
%  this is for a static list (edges are defined once)
% linked_min is the minimum number of frames that a contracting edge must
% be vlinked in order to classified as such throughout.
linked_min = 20;
for i = 1:length(shrinking_edges_vlinked(1,:))    
    if sum(shrinking_edges_vlinked(:,i))>linked_min
        aligned_vlinked(:,i) = 1;
    end
end

if isempty(aligned_ang_sh)
    special_info = 'empty set';
    save('aligned_edges_info_linkage','special_info');
    return
end
aligned_ang_sh = mod(aligned_ang_sh, 180);
aligned_ang_sh = 90 - abs(90 - aligned_ang_sh);    
aligned_ang_gr = mod(aligned_ang_gr, 180);
aligned_ang_gr = 90 - abs(90 - aligned_ang_gr);


len_sh_mean_vlinked = nan(size(aligned_len_sh, 1), 1);
len_sh_std_vlinked = len_sh_mean_vlinked;
ang_sh_mean_vlinked = len_sh_mean_vlinked;
ang_sh_std_vlinked = len_sh_mean_vlinked;


angvel_sh_mean_vlinked = len_sh_mean_vlinked;
angvel_sh_std_vlinked = len_sh_mean_vlinked;

len_sh_mean_notlinked = len_sh_mean_vlinked;
len_sh_std_notlinked = len_sh_mean_vlinked;
ang_sh_mean_notlinked = len_sh_mean_vlinked;
ang_sh_std_notlinked = len_sh_mean_vlinked;

angvel_sh_mean_notlinked = len_sh_mean_vlinked;
angvel_sh_std_notlinked = len_sh_mean_vlinked;


len_gr_mean_vlinked = len_sh_mean_vlinked;
len_gr_std_vlinked = len_sh_mean_vlinked;
ang_gr_mean_vlinked = len_sh_mean_vlinked;
ang_gr_std_vlinked = len_sh_mean_vlinked;

len_gr_mean_notlinked = len_sh_mean_vlinked;
len_gr_std_notlinked = len_sh_mean_vlinked;
ang_gr_mean_notlinked = len_sh_mean_vlinked;
ang_gr_std_notlinked = len_sh_mean_vlinked;

num_sh_linked = nan(size(aligned_len_sh, 1), 1);
num_sh_notlinked = num_sh_linked;
ratio_linked = num_sh_linked;

aligned_angvel_sh = deriv(aligned_ang_sh);

    for i = 1:size(aligned_len_sh, 1)
        sel_linked = aligned_sel_sh(i, :) > 0 & aligned_vlinked(i, :) > 0;
        sel_notlinked = aligned_sel_sh(i, :) > 0 & aligned_vlinked(i, :) < 1;
        
            len_sh_mean_vlinked(i) = mean(aligned_len_sh(i, sel_linked));
            len_sh_mean_notlinked(i) = mean(aligned_len_sh(i, sel_notlinked));
            
            len_sh_std_vlinked(i) = std(aligned_len_sh(i, sel_linked));
            len_sh_std_notlinked(i) = std(aligned_len_sh(i, sel_notlinked));
            
            ang_temp_vlinked = aligned_ang_sh(i, sel_linked);
            ang_temp_notlinked = aligned_ang_sh(i, sel_notlinked);
            angvel_temp_vlinked = aligned_angvel_sh(i, sel_linked);
            angvel_temp_notlinked = aligned_angvel_sh(i, sel_notlinked);

            
            ang_temp_vlinked = ang_temp_vlinked(~isnan(ang_temp_vlinked));
            ang_temp_notlinked = ang_temp_notlinked(~isnan(ang_temp_notlinked));
            
            ang_sh_mean_vlinked(i) = mean(ang_temp_vlinked);
            ang_sh_mean_notlinked(i) = mean(ang_temp_notlinked);

            angvel_sh_mean_vlinked(i) = mean(angvel_temp_vlinked);
            angvel_sh_mean_notlinked(i) = mean(angvel_temp_notlinked);
            
            
            ang_sh_std_vlinked(i) = std(ang_temp_vlinked);
            ang_sh_std_notlinked(i) = std(ang_temp_notlinked);
            
            num_sh_linked(i) = nnz(sel_linked);
            num_sh_notlinked(i) = nnz(sel_notlinked);
            ratio_linked(i) = num_sh_linked(i)/num_sh_notlinked(i);
  
    end
    
    timepoints = -length(len_sh_mean_vlinked)+1:0;
    
    vertselsum=sum(data.edges.selected&vertical_edges,2);
    shrinkselsum = sum(data.edges.selected(:,edges_global_ind),2);
    v_linkedselsum=sum(data.edges.selected&v_linked,2);
    
    vertselsum_normbysel= vertselsum./sum(data.edges.selected,2);
    shrinkselsum_normbysel = shrinkselsum./sum(data.edges.selected,2);
    
    v_linkedsel = data.edges.selected&v_linked;
    v_linkedselshrink = v_linkedsel(:,edges_global_ind);
    
    v_linked_percent_shrink = sum(v_linkedselshrink,2)./sum(v_linkedsel,2);    
    
    save('aligned_edges_info_linkage', ...
    'len_sh_mean_vlinked', 'len_sh_std_vlinked', 'ang_sh_mean_vlinked', 'ang_sh_std_vlinked', ...
    'len_sh_mean_notlinked', 'len_sh_std_notlinked', 'ang_sh_mean_notlinked', 'ang_sh_std_notlinked', ...
    'num_sh_linked','num_sh_notlinked','ratio_linked','timepoints','v_linked','v_linked_drop_smalls','vertical_edges',...
    'angvel_sh_mean_vlinked','angvel_sh_mean_notlinked','vertselsum','shrinkselsum','vertselsum_normbysel',...
    'shrinkselsum_normbysel','v_linked_percent_shrink', 'shrink_to_shrink_linked','shrink_isolated')

load('aligned_edges_info');
aligned_ang_sh = mod(aligned_ang_sh, 180);
aligned_ang_sh = 90 - abs(90 - aligned_ang_sh);    
aligned_ang_gr = mod(aligned_ang_gr, 180);
aligned_ang_gr = 90 - abs(90 - aligned_ang_gr);

ang_bins = 0:15:90;
ang_bins(end) = ang_bins(end)+1;
ang_sh_hist.bins = ang_bins;
ang_sh_hist.data = nan(size(aligned_ang_sh, 1),length(ang_bins));
ang_sh_hist.binind = nan(size(aligned_ang_sh));
    for i = 1:size(aligned_len_sh, 1)
        [ang_sh_hist.data(i,:) ang_sh_hist.binind(i,:)] = histc(aligned_ang_sh(i,:),ang_bins);
        ang_sh_hist.data(i,:) = ang_sh_hist.data(i,:)/sum(ang_sh_hist.data(i,:));
    end
    
save('aligned_edges_info', 'ang_sh_hist','-append')



function [v_linked v_linked_drop_smalls vertical_edges] = find_vert_linked(seq, data, all_links, theta, shift,small_len_thresh)
vertical_edges = abs(data.edges.angles - (90 + shift)) < theta;
vertical_edges = vertical_edges & data.edges.selected;
% vertical_edges = vertical_edges & data.edges.len > 10;
v_linked = false(size(vertical_edges));
v_linked_drop_smalls = v_linked;
for i = 1:length(seq.frames);
    for j = find(vertical_edges(i, :) & data.edges.selected(i, :) > 0 );
        linked = all_links(j).edges(all_links(j).on(i, :));
        if any(vertical_edges(i, linked))
            v_linked(i, j) = true;
            v_linked_drop_smalls(i, j) = true;
        end
        
        linked_small = linked(data.edges.len(i,linked)<=small_len_thresh);
        
        for k = linked_small
            if ~isempty(all_links(k).edges)
                linked_thru_small = all_links(k).edges(all_links(k).on(i, :));
                linked_thru_small = linked_thru_small(linked_thru_small~=j);
                if any(vertical_edges(i, linked_thru_small))
                    v_linked_drop_smalls(i, j) = true;
                end
            end
        end
            %don't include self
        
        %%% need to include linked edges that are broken up by small edges.
        %%% do this later.
    end
end



function [shrink_linked] = find_shrink_linked(seq, data, all_links, shrinking_edges_ind)
shrink_linked = false(size(data.edges.angles));
for i = 1:length(seq.frames);
    for j = find(shrinking_edges_ind(i,:) & data.edges.selected(i, :) > 0);
        linked = all_links(j).edges(all_links(j).on(i, :));
        if any(shrinking_edges_ind(i,linked))
            shrink_linked(i, j) = true;
        end
    end
end

function [shrink_isolated] = find_shrink_isolated(seq, data, all_links, shrinking_edges_ind)
shrink_isolated = false(size(data.edges.angles));
for i = 1:length(seq.frames);
    for j = find(shrinking_edges_ind(i,:) & data.edges.selected(i, :) > 0);
        linked = all_links(j).edges(all_links(j).on(i, :));
        if ~any(shrinking_edges_ind(i,linked))
            shrink_isolated(i, j) = true;
        end
    end
end




function shrinking_edges_vlinked = sort_vlink_shrinks(v_linked,edges_global_ind)

shrinking_edges_vlinked = false(size(v_linked,1),size(edges_global_ind,2));
for i = 1:size(v_linked,1)
    for j = 1:length(edges_global_ind)
    shrinking_edges_vlinked(i,j) = v_linked(i,edges_global_ind(j));
    end
end
    
    



