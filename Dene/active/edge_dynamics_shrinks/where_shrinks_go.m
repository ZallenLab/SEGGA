% function where_shrinks_go
clear('misc','data','clusters','v_linked','v_linked_drop_smalls','vertical_edges',...
    'shrink_to_shrink_linked');
load analysis misc data clusters;
load('aligned_edges_info_linkage','v_linked','v_linked_drop_smalls',...
    'vertical_edges','shrink_to_shrink_linked');

if isempty(whos('v_linked'))
    display('missing aligned_edges_info_linkage data');
    special_info = 'empty set: missing aligned_edges_info_linkage data';
    save('where_shrinks_go','special_info');
    return
end

shrink_global_inds = [];
shrink_global_inds = [shrink_global_inds,clusters(:).edges];
shrink_global_inds = unique(shrink_global_inds, 'legacy');


num_shrink_selected = sum(data.edges.selected(:,shrink_global_inds),2);

num_shrink_vert = sum(vertical_edges(:,shrink_global_inds),2);

num_shrink_vert_linked_basic = sum(v_linked(:,shrink_global_inds),2);

num_shrink_vert_linked_nosmalls = sum(v_linked_drop_smalls(:,shrink_global_inds),2);

num_shrink_to_shrink_linked = sum(shrink_to_shrink_linked(:,shrink_global_inds),2);

num_frames = size(data.edges.angles,1);
clear('shrink_linked','shrink_single');
shrink_linked(:).t1 = nan(num_frames,1);
shrink_linked(:).ros = shrink_linked(:).t1;
shrink_single(:).t1 = shrink_linked(:).t1;
shrink_single(:).ros = shrink_linked(:).t1;

% This analysis is only for vertical edges.
%The following variable keeps track of which edges did what.
shrink_to_ros = zeros(length(shrink_global_inds),1);

for i = 1:num_frames
    shrink_linked_edges = shrink_global_inds(v_linked_drop_smalls(i,shrink_global_inds));
    shrink_single_edges = shrink_global_inds(vertical_edges(...
        i,shrink_global_inds(~v_linked_drop_smalls(i,shrink_global_inds))...
        ));
    
    linked_to_t1 = 0;
    linked_to_ros = 0;
    total_sum = length(shrink_linked_edges)+length(shrink_single_edges);
    predicted_sum = num_shrink_vert(i);
    if total_sum ~= predicted_sum
        display('warning, the total sum of linked edges and single edges does not add up to the sum of vertical edges.')
        display(['linked = ',num2str(length(shrink_linked_edges))]);
        display(['single = ',num2str(length(shrink_single_edges))]);
        display(['vertical = ',num2str(num_shrink_vert(i))]);
    end
    
    % Just calculating linked edges
    for j = shrink_linked_edges
        clusters_participating.inds = [];
        clusters_participating.sizes = [];
        
        for jj = 1:length(clusters)
%             display(clusters(jj).edges)
            if any(clusters(jj).edges==j)
                
                clusters_participating.inds = [clusters_participating.inds,jj];
                clusters_participating.sizes = [clusters_participating.sizes,length(clusters(jj).all_edges)];
            end
        end
        
%         %% Debug
%         for i = 1:length(seq.frames)
%             
%             inds_to_show = find(v_linked_drop_smalls(i,:));
%              seq.frames(i).edges = nonzeros(seq.edges_map(i,inds_to_show));
%         end
%         load_seq(seq);
%         sum(data.edges.selected(:,j))
        
        
        if length(clusters_participating.inds) > 1 
            display('edges is in more than one cluster')
            display(['edge ',num2str(j)]);
        end
        
        if length(clusters_participating.inds) < 1 
            display('edges is not in any cluster')
            display(['edge ',num2str(j)]);
        end
        
        if length(clusters_participating.inds) == 1 
            if clusters_participating.sizes(:) > 4
            	linked_to_ros = linked_to_ros +1;
            else
                linked_to_t1 = linked_to_t1 +1;
            end
        end
        
        
        
    end
    
    shrink_linked(i).t1 =  linked_to_t1;
    shrink_linked(i).ros = linked_to_ros;
    

    
    single_to_t1 = 0;
    single_to_ros = 0;

    
        % Just calculating single edges
    for k = shrink_single_edges
        clusters_participating.inds = [];
        clusters_participating.sizes = [];
        
        for kk = 1:length(clusters)
        
            if any(clusters(kk).edges==k)
    
                clusters_participating.inds = [clusters_participating.inds,kk];
                clusters_participating.sizes = [clusters_participating.sizes,length(clusters(kk).all_edges)];
            end
        end
        
        if length(clusters_participating.inds) > 1 
            display('edges is in more than one cluster')
            display(['edge ',num2str(k)]);
        end
        
        if length(clusters_participating.inds) < 1 
            display('edges is not in any cluster')
            display(['edge ',num2str(k)]);
        end
        
        if length(clusters_participating.inds) == 1 
            if clusters_participating.sizes(:) > 4
            	single_to_ros = single_to_ros +1;
            else
                single_to_t1 = single_to_t1 +1;
            end
        end
        
        
        
    end
    
    
    shrink_single(i).t1 =  single_to_t1;
    shrink_single(i).ros = single_to_ros;
    
    
    
            % For All Edges
    for h = 1:length(shrink_global_inds)
        edge_ind = shrink_global_inds(h);
        clusters_participating.inds = [];
        clusters_participating.sizes = [];
        
        for hh = 1:length(clusters)
        
            if any(clusters(hh).edges==edge_ind)
    
                clusters_participating.inds = [clusters_participating.inds,hh];
                clusters_participating.sizes = [clusters_participating.sizes,length(clusters(hh).all_edges)];
            end
        end
        
        if length(clusters_participating.inds) > 1 
            display('edges is in more than one cluster')
            display(['edge ',num2str(edge_ind)]);
        end
        
        if length(clusters_participating.inds) < 1 
            display('edges is not in any cluster')
            display(['edge ',num2str(edge_ind)]);
        end
        
        if length(clusters_participating.inds) == 1 
            if clusters_participating.sizes(:) > 4
            	shrink_to_ros(h) = 1;
            end
        end
        
        
    end
    
    
end

v_linked_to_ros = nan(num_frames,1);
v_linked_nosmalls_to_ros = v_linked_to_ros;
shrink_to_shrink_linked_to_ros = v_linked_to_ros;
all_selected_shrinks_to_ros = v_linked_to_ros;
all_selected_vertical_shrinks_to_ros = v_linked_to_ros;

v_linked_to_ros_over_possible = v_linked_to_ros;
v_linked_nosmalls_to_ros_over_possible = v_linked_to_ros;
shrink_to_shrink_linked_to_ros_over_possible = v_linked_to_ros;
all_selected_shrinks_to_ros_over_possible = v_linked_to_ros;
all_selected_vertical_shrinks_to_ros_over_possible = v_linked_to_ros;

for i = 1:num_frames
    temp_v_linked_reg = v_linked(i, shrink_global_inds);
    temp_v_linked_nosmalls = v_linked_drop_smalls(i, shrink_global_inds);
    temp_shrink_to_shrink_linked = shrink_to_shrink_linked(i, shrink_global_inds);
    temp_all_selected_shrinks = data.edges.selected(i,shrink_global_inds);
    temp_all_selected_vertical_shrinks = vertical_edges(i,shrink_global_inds);
    
    v_linked_to_ros(i) = sum(shrink_to_ros(temp_v_linked_reg));
    v_linked_nosmalls_to_ros(i) = sum(shrink_to_ros(temp_v_linked_nosmalls));
    shrink_to_shrink_linked_to_ros(i) = sum(shrink_to_ros(temp_shrink_to_shrink_linked));
    all_selected_shrinks_to_ros(i) = sum(shrink_to_ros(temp_all_selected_shrinks));
    all_selected_vertical_shrinks_to_ros(i) = sum(shrink_to_ros(temp_all_selected_vertical_shrinks));
       
    v_linked_to_ros_over_possible(i) = v_linked_to_ros(i)./sum(temp_v_linked_reg);
    v_linked_nosmalls_to_ros_over_possible(i) = v_linked_nosmalls_to_ros(i)./sum(temp_v_linked_nosmalls);
    shrink_to_shrink_linked_to_ros_over_possible(i) = ...
        shrink_to_shrink_linked_to_ros(i)./sum(temp_shrink_to_shrink_linked);
    all_selected_shrinks_to_ros_over_possible(i) = all_selected_shrinks_to_ros(i)./sum(temp_all_selected_shrinks);
    all_selected_vertical_shrinks_to_ros_over_possible(i) = all_selected_vertical_shrinks_to_ros(i)./sum(temp_all_selected_vertical_shrinks);
    
end

vert_over_selected = num_shrink_vert./num_shrink_selected;
vert_over_selected(isinf(vert_over_selected)) = nan;

linked_nosmalls_over_vert = num_shrink_vert_linked_nosmalls./num_shrink_vert;
linked_nosmalls_over_vert(isinf(linked_nosmalls_over_vert)) = nan;

linked_ros_to_t1_proportion = [shrink_linked(:).ros] ./ [shrink_linked(:).t1];
linked_ros_to_t1_proportion(isinf(linked_ros_to_t1_proportion)) = nan;

single_ros_to_t1_proportion = [shrink_single(:).ros] ./ [shrink_single(:).t1];
single_ros_to_t1_proportion(isinf(single_ros_to_t1_proportion)) = nan;


save('where_shrinks_go', 'num_shrink_selected', 'num_shrink_vert', 'num_shrink_vert_linked_basic','num_shrink_vert_linked_nosmalls',...
    'num_shrink_to_shrink_linked','vert_over_selected','linked_nosmalls_over_vert',...
	'shrink_linked','shrink_single',...
    'v_linked_to_ros','v_linked_nosmalls_to_ros','shrink_to_shrink_linked_to_ros','all_selected_shrinks_to_ros','all_selected_vertical_shrinks_to_ros',...
	'linked_ros_to_t1_proportion', 'single_ros_to_t1_proportion',...
    'v_linked_to_ros_over_possible','v_linked_nosmalls_to_ros_over_possible','shrink_to_shrink_linked_to_ros_over_possible',...
    'all_selected_shrinks_to_ros_over_possible','all_selected_vertical_shrinks_to_ros_over_possible',...
    'shrink_global_inds','shrink_to_ros')
     
        
    