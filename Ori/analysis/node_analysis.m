function [res_time followed] = node_analysis(seq, data, misc, timestep)
% time_in_minutes = 10;
% time_window = 10; %used in calculating misc
% time_thresh = time_in_minutes*60/timestep; 
% num_frames = size(data.cells.selected, 1);
% followed = false(size(misc.dead_final));
% res_time = inf(size(followed));
% dead_list = find(misc.dead_final);
% inv_dead_list(dead_list) = 1:length(dead_list);
% for j = dead_list
%     if (misc.dead_init(j) + time_thresh) > num_frames
%         continue
%     end
%     sel_times = all(data.cells.selected(:, ...
%         misc.edges_by_cells(j, :)), 2);
%     
%     exist_times = zeros(1,length(seq.frames(:)));
%     
%     for i = 1:length(seq.frames(:))
%         local_cells = seq.cells_map(i,misc.edges_by_cells(j, :));
%         exist_times(i) = length(nonzeros(local_cells))>1;
%     end
%     
%         if all(sel_times(misc.dead_init(j):min(misc.dead_init(j)+time_thresh,end)))...
%                 && all(exist_times(min(end, misc.edge_breakup_final(j) + (0:time_window))))
%             followed(j) = true;
%             sep = sel_times(misc.dead_init(j):end) & ...
%                 ~misc.cells_of_edge_touching(misc.dead_init(j):end, inv_dead_list(j));
%             sep_time = find(sep, 1); 
%             if ~isempty(sep_time) && misc.edge_breakup_final(j) < num_frames
%                 res_time(j) = (misc.edge_breakup_final(j) + misc.edge_breakup_final(j))/2;
%             end
%         end
%         
% end

time_window = 10; %used in calculating misc
time_in_minutes = 10;
time_thresh = time_in_minutes*60/timestep; 
num_frames = size(data.cells.selected, 1);
followed = false(size(misc.dead_init));
res_time = inf(size(followed));
dead_list = find(misc.dead_init);
inv_dead_list(dead_list) = 1:length(dead_list);
for j = dead_list
    if (misc.dead_init(j) + time_thresh) > num_frames
        continue
    end
    sel_times = all(data.cells.selected(:, ...
        misc.edges_by_cells(j, :)), 2);
    
     exist_times = zeros(1,length(seq.frames(:)));
%     
    for i = 1:length(seq.frames(:))
        local_cells = seq.cells_map(i,misc.edges_by_cells(j, :));
        exist_times(i) = length(nonzeros(local_cells))>1;
    end
    
    if all(sel_times(min(end, misc.dead_init(j) + (0:time_thresh))))...
         && all(exist_times(min(end, misc.edge_breakup_final(j) + (0:time_window))))
        followed(j) = true;
        sep = sel_times(misc.dead_init(j):end) & ...
            ~misc.cells_of_edge_touching(misc.dead_init(j):end, inv_dead_list(j));
        sep_time = find(sep, 1); 
        if ~isempty(sep_time) && misc.edge_breakup_final(j) < num_frames
            res_time(j) = (misc.edge_breakup_final(j) + misc.edge_breakup_final(j))/2;
        end
    end
end

