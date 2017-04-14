function track_clusters(force_read)
if nargin < 1
    force_read = 0;
end
r = 7; %radius of circle of frames in which clusters will be initially tracked around each frame  
global seq

for i = 1:length(seq.frames)
    if ~isfield(seq.frames(1), 'clusters_data') | force_read
        temp_vars = load(seq.frames(i).filename, 'clusters_data');
        seq.frames(i).clusters_data = temp_vars.clusters_data;
    else
        if ~isempty(seq.frames(i).clusters_data)
            ind = ~cellfun(@isempty, {seq.frames(i).clusters_data.cells});
        else
            ind = [];
        end
        seq.frames(i).clusters_data = seq.frames(i).clusters_data(ind);
    end
end



seq.inv_clusters_map = zeros(length(seq.frames), ...
                             length(seq.frames(end).clusters_data),...
                             'uint16');
last_cluster = 0;
for i = 1:length(seq.frames)
    seq.inv_clusters_map(i, 1:length(seq.frames(i).clusters_data)) = ...
        last_cluster + (1:length(seq.frames(i).clusters_data));
    last_cluster = last_cluster + length(seq.frames(i).clusters_data);
end
for i = 1:length(seq.frames)
    for j = 1:length(seq.frames(i).clusters_data)
        for l = nghbr_frames(i, r)'
            for k = 1:length(seq.frames(l).clusters_data)
                cells1 = seq.inv_cells_map(l, seq.frames(l).clusters_data(k).cells);
                cells2 = seq.inv_cells_map(i, seq.frames(i).clusters_data(j).cells);
                cells = intersect(cells1, cells2, 'legacy');
                %if more than three and more than half the cells are common
                %to both clusters, identify the two clusters as one
                if length(cells) > 3 && length(cells) * 4 > length(cells1) + length(cells2) 
                    new_cluster = min(seq.inv_clusters_map(i,j), seq.inv_clusters_map(l,k));
                    seq.inv_clusters_map(i,j) = new_cluster;
                    seq.inv_clusters_map(l,k) = new_cluster;
                    break
                end
            end
        end
    end
end

seq.clusters_map = zeros(length(seq.frames), max(seq.inv_clusters_map(:)), 'uint8');
for i = 1:length(seq.frames)
    seq.clusters_map(i, nonzeros(seq.inv_clusters_map(i, :))) = ...
        reshape(find(seq.inv_clusters_map(i, :)), ...
        size(seq.clusters_map(i, nonzeros(seq.inv_clusters_map(i, :)))));
end

%remove the zero columns from the map and update inv_clusters_map accordingly
a = any(seq.clusters_map);
seq.clusters_map = seq.clusters_map(:, a);
b = uint16([0 cumsum(a)])';
seq.inv_clusters_map = b(seq.inv_clusters_map + 1);



    function f_nums = nghbr_frames(i, d)
        c = circle(d);
        c(1:d, :) = 0;
        c(d + 1, 1:d) = 0;
        [t z] = find(c);
        t = t + seq.frames(i).t - 1 - d;
        z = z + seq.frames(i).z - 1 - d;
        ind = 0 < t & t <= seq.max_t & 0 < z & z <= seq.max_z;
        f_nums = nonzeros(seq.frames_num(sub2ind(size(seq.frames_num), t(ind), z(ind))));
    end

for i = 1:length(seq.clusters_map(1,:))
    on_frames = find(seq.clusters_map(:,i));
    t_frames = [seq.frames(on_frames).t];
    z_frames = [seq.frames(on_frames).z];
    min_t = min([seq.frames(on_frames).t]);
    max_t = max([seq.frames(on_frames).t]);
    min_z = min([seq.frames(on_frames).z]);
    max_z = max([seq.frames(on_frames).z]);
    g_cells = [];
%     for j = on_frames'
%         g_cells = [g_cells seq.inv_cells_map(j, ...
%             seq.frames(j).clusters_data(seq.clusters_map(j,i)).cells)];
%     end
%     g_cells = unique(g_cells);
    frames_block = nonzeros(seq.frames_num(min_t:max_t, min_z:max_z));
    for frm_num = frames_block(:)'
        t = seq.frames(frm_num).t;
        z = seq.frames(frm_num).z;
        for_t_frames = on_frames(t_frames > t);
        back_t_frames = on_frames(t_frames <= t);
%         [dummy min_frm_for] = min((t - t_frames(for_t_frames)).^2 + ...
%             (z - z_frames(for_t_frames)).^2);
%         [dummy min_frm_back] = min((t - t_frames(back_t_frames)).^2 + ...
%             (z - z_frames(back_t_frames)).^2);
%         min_frm_for = on_frames(min_frm(for_t_frames));
%         min_frm_back = on_frames(min_frm(back_t_frames));
        g_for_cells = [];
        for t_frm = for_t_frames'
            g_for_cells = [g_for_cells seq.inv_cells_map(t_frm, ...
                seq.frames(t_frm).clusters_data(seq.clusters_map(t_frm,i)).cells)];
        end
        g_back_cells = [];
        for t_frm = back_t_frames'
            g_back_cells = [g_back_cells seq.inv_cells_map(t_frm, ...
                seq.frames(t_frm).clusters_data(seq.clusters_map(t_frm,i)).cells)];
        end
        g_cells = intersect(g_back_cells, g_for_cells, 'legacy');
        f_cells = nonzeros(seq.cells_map(frm_num, g_cells))';
        if ~seq.clusters_map(frm_num, i)
%             cells = nonzeros(seq.cells_map(frm_num, nonzeros(seq.inv_cells_map(frm_num-1, ...
%                 seq.frames(frm_num-1).clusters_data(seq.clusters_map(frm_num-1, i)).cells))))';            
            if length(seq.frames(frm_num).clusters_data)
                seq.frames(frm_num).clusters_data(end + 1, 1) = build_cluster_data(f_cells, ...
                    seq.frames(frm_num).cellgeom);
            else
                seq.frames(frm_num).clusters_data = build_cluster_data(f_cells, ...
                    seq.frames(frm_num).cellgeom);
            end
            seq.clusters_map(frm_num, i) = length(seq.frames(frm_num).clusters_data);
            seq.inv_clusters_map(frm_num, length(seq.frames(frm_num).clusters_data)) = i;
        elseif length(f_cells) > length(...
            seq.frames(frm_num).clusters_data(seq.clusters_map(frm_num, i)).cells)
            seq.frames(frm_num).clusters_data(seq.clusters_map(frm_num, i)) = ...
                build_cluster_data(f_cells, seq.frames(frm_num).cellgeom);
        end
    end
end

%Keep only those clusters that appear for more than 3 frames.
valid_clusters = sum(seq.clusters_map > 0) > 3;
new_global_number = uint16([0 cumsum(valid_clusters)]);


for i = 1:length(seq.frames)
    ind = false(1, length(seq.frames(i).clusters_data));
    ind(nonzeros(seq.clusters_map(i, valid_clusters))) = true;
    seq.frames(i).clusters_data = seq.frames(i).clusters_data(ind);
    % by selecting clusters_data without ind, directly with
    % nonzeros(seq.clusters_map(i, valid_clusters)))
    % the order of the clusters changes.
        
    b = uint8([0 cumsum(ind)]);
    seq.clusters_map(i,:) = b(seq.clusters_map(i,:) + 1);
end


seq.clusters_map = seq.clusters_map(:, valid_clusters);
seq.inv_clusters_map = zeros(length(seq.frames), max(seq.clusters_map(:)), 'uint16');
for i = 1:length(seq.frames)
    seq.inv_clusters_map(i, nonzeros(seq.clusters_map(i, :))) = ...
        find(seq.clusters_map(i, :));
end

if isfield(seq, 'clusters_colors')
     seq.clusters_colors(end + 1:length(seq.clusters_map(1,:))) = ...
         (length(seq.clusters_colors) + 1):length(seq.clusters_map(1,:)); 
else
    seq.clusters_colors = 1:length(seq.clusters_map(1,:));
end
% color_clusters(1:length(seq.frames), 'cluster_tracking_b', 'cluster_tracking_f', ...
%     'ghost_clusters');

return




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% old version %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frames_num = seq.frames_num;
min_t = seq.min_t;
max_t = seq.max_t;
min_z = seq.min_z;
max_z = seq.max_z;
for i = 1:length(seq.frames)
    if ~isfield(seq.frames(1), 'clusters_data') | force_read
        temp_vars = load(seq.frames(i).filename, 'clusters_data');
        cl_frames(i).clusters_data = temp_vars.clusters_data;
    else
        if ~isempty(seq.frames(i).clusters_data)
            ind = ~cellfun(@isempty, {seq.frames(i).clusters_data.cells});
        else
            ind = [];
        end
        cl_frames(i).clusters_data = seq.frames(i).clusters_data(ind);
    end
    for clst_cnt = 1:length(cl_frames(i).clusters_data)
        cl_frames(i).clusters_data(clst_cnt).on = false;
%         cl_frames(i).clusters_data(clst_cnt).boundary = ...
%             cluster_outer_nodes(cl_frames(i).clusters_data(clst_cnt).cells, seq.frames(i).cellgeom);
%         cl_frames(i).clusters_data(clst_cnt).center = ...
%             centroid(seq.frames(i).cellgeom.nodes(cl_frames(i).clusters_data(clst_cnt).boundary, :));
    end
end


t_start = clock;
cl_frames(1).ghost_clusters = struct([]);
for i = 1:length(cl_frames)
    if isfield(seq.frames, 'next_frame') & ~isempty(seq.frames(i).next_frame)
        j = seq.frames(i).next_frame;
        len_i = length(cl_frames(i).clusters_data) + length(cl_frames(i).ghost_clusters);
        len_j = length(cl_frames(j).clusters_data);
        if len_i
            if length(cl_frames(i).clusters_data) && length(cl_frames(i).ghost_clusters)
                a = reshape([cl_frames(i).clusters_data.center cl_frames(i).ghost_clusters.center], 2, len_i);
                [cl_frames(i).clusters_data.on] = deal(false); %%%%%%%%%%%fix this in tracking_z
            elseif length(cl_frames(i).ghost_clusters)
                a = reshape([cl_frames(i).ghost_clusters.center], 2, len_i);
            else
                a = reshape([cl_frames(i).clusters_data.center], 2, len_i);
                [cl_frames(i).clusters_data.on] = deal(false);
            end
        else
            cl_frames(j).cluster_tracking_b = zeros(1,len_j);
            cl_frames(i).cluster_tracking_f = zeros(1,len_i);
        end
        if len_j
            b = reshape([cl_frames(j).clusters_data.center], 2, len_j);
        else
            cl_frames(j).cluster_tracking_b = zeros(1,len_j);
            cl_frames(i).cluster_tracking_f = zeros(1,len_i);
        end
        if len_i && len_j
            [cl_frames(i).cluster_tracking_f cl_frames(j).cluster_tracking_b] = track(a,b);
            
            cl_frames(i).cluster_tracking_f = ver_tracking(...
                [cl_frames(i).clusters_data ; cl_frames(i).ghost_clusters], ...
                cl_frames(j).clusters_data, cl_frames(i).cluster_tracking_f, ...
                seq.cells_map(j, nonzeros(seq.inv_cells_map(i, :))));
            cl_frames(j).cluster_tracking_b = ver_tracking(...
                cl_frames(j).clusters_data, ...
                [cl_frames(i).clusters_data ; cl_frames(i).ghost_clusters], ...
                cl_frames(j).cluster_tracking_b, ...
                seq.cells_map(i, nonzeros(seq.inv_cells_map(j, :))));
        end
        missing_clusters = setdiff(1:length(cl_frames(i).clusters_data),...
            cl_frames(j).cluster_tracking_b);
        cl_frames(j).ghost_clusters = cl_frames(i).clusters_data(missing_clusters);
        for k = 1:length(cl_frames(j).ghost_clusters)
            cl_frames(j).ghost_clusters(k).cells = ...
                nonzeros(seq.cells_map(j, nonzeros(seq.inv_cells_map(i, cl_frames(i).clusters_data(missing_clusters(k)).cells))))';
        end
    end
end

last_used_max = 1;


[x y] = meshgrid(min_t:max_t, min_z:max_z);
x = x';
y = y';
orbit = frames_num(sub2ind(size(frames_num), x(:), y(:)));
do_tracking(orbit, 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters'); % track along the t axis

%now the the ghosts are lighted up, we can find the tracking map along z
for i = 1:length(seq.frames)
    if isfield(seq.frames, 'up_frame') & ~isempty(seq.frames(i).up_frame)
        j = seq.frames(i).up_frame;
        if length(cl_frames(i).ghost_clusters)
            ghost_lit_i = [cl_frames(i).ghost_clusters.on];
        else
            ghost_lit_i = [];
        end
        if length(cl_frames(j).ghost_clusters)
            ghost_lit_j = [cl_frames(j).ghost_clusters.on];
        else
            ghost_lit_j = [];
        end

        if length(cl_frames(i).clusters_data)
            lit_i = [cl_frames(i).clusters_data.on];
        else
            lit_i = [];
        end
        if length(cl_frames(j).clusters_data)
            lit_j = [cl_frames(j).clusters_data.on];
        else
            lit_j = [];
        end
        len_i = sum(ghost_lit_i) + sum(lit_i);
        len_j = sum(ghost_lit_j) + sum(lit_j);
        if any(ghost_lit_i) && any(lit_i)
            a = reshape([cl_frames(i).clusters_data(lit_i).center ...
                cl_frames(i).ghost_clusters(ghost_lit_i).center], 2, len_i);
        elseif any(ghost_lit_i)
            a = reshape([cl_frames(i).ghost_clusters(ghost_lit_i).center], 2, len_i);
        elseif any(lit_i)
            a = reshape([cl_frames(i).clusters_data(lit_i).center], 2, len_i);
        end

        if any(ghost_lit_j) && any(lit_j)
            b = reshape([cl_frames(j).clusters_data(lit_j).center ...
                cl_frames(j).ghost_clusters(ghost_lit_j).center], 2, len_j);
        elseif any(ghost_lit_j)
            b = reshape([cl_frames(j).ghost_clusters(ghost_lit_j).center], 2, len_j);
        elseif any(lit_j)
            b = reshape([cl_frames(j).clusters_data(lit_j).center], 2, len_j);
        end
        if len_i && len_j
            [cl_frames(i).cluster_tracking_u cl_frames(j).cluster_tracking_d] = track(a,b);
            cl_frames(i).cluster_tracking_u = ver_tracking(...
                [cl_frames(i).clusters_data(lit_i) ; cl_frames(i).ghost_clusters(ghost_lit_i)], ...
                [cl_frames(j).clusters_data(lit_j) ; cl_frames(j).ghost_clusters(ghost_lit_j)], ...
                cl_frames(i).cluster_tracking_u, seq.cells_map(j, nonzeros(seq.inv_cells_map(i, :))));
            cl_frames(j).cluster_tracking_d = ver_tracking(...
                [cl_frames(j).clusters_data(lit_j) ; cl_frames(j).ghost_clusters(ghost_lit_j)], ...
                [cl_frames(i).clusters_data(lit_i) ; cl_frames(i).ghost_clusters(ghost_lit_i)], ...
                cl_frames(j).cluster_tracking_d, seq.cells_map(i, nonzeros(seq.inv_cells_map(j, :))));
        else
            cl_frames(j).cluster_tracking_d = zeros(1,len_j);
            cl_frames(i).cluster_tracking_u = zeros(1,len_i);
        end
    end
end


color_map = 1:last_used_max;
[x y] = meshgrid(min_t:max_t, min_z:max_z);
x = x';
y = y';
orbit = frames_num(sub2ind(size(frames_num), x(:), y(:)));
track_along_z(orbit);
track_along_z(orbit(end:-1:1));

seq.max_cluster_color = max(color_map);
clusters_map = zeros(length(seq.frames), seq.max_cluster_color);

for i = 1:length(seq.frames)
    color_numbers = cl_frames(i).visible_clusters_color_numbers;
    seq.frames(i).clusters_data = [];
    if length(cl_frames(i).clusters_data)
%         color_numbers = cl_frames(i).visible_clusters_color_numbers(...
%             find([cl_frames(i).clusters_data.on]));
        seq.frames(i).clusters_data =...
            cl_frames(i).clusters_data([cl_frames(i).clusters_data.on]);
    end
    if length(cl_frames(i).ghost_clusters)
%         color_numbers = [color_numbers ...
%             cl_frames(i).visible_clusters_color_numbers(...
%                 length(cl_frames(i).clusters_data) + 1: end)];
        for clst_cnt = 1:length(cl_frames(i).ghost_clusters)
            cl_frames(i).ghost_clusters(clst_cnt).boundary = ...
                cluster_outer_nodes(cl_frames(i).ghost_clusters(clst_cnt).cells, seq.frames(i).cellgeom);
            cl_frames(i).ghost_clusters(clst_cnt).center = ...
                centroid(seq.frames(i).cellgeom.nodes(cl_frames(i).ghost_clusters(clst_cnt).boundary, :));
        end
        seq.frames(i).clusters_data = [seq.frames(i).clusters_data' ...
            cl_frames(i).ghost_clusters([cl_frames(i).ghost_clusters.on])']';
    end
    clusters_map(i, color_numbers) = 1:length(color_numbers);
    inv_clusters_map(i, 1:length(color_numbers)) = color_numbers;
end
seq.clusters_map = uint16(clusters_map);
seq.inv_clusters_map = uint16(inv_clusters_map);
seq.clusters_colors = 1:length(clusters_map(1,:));
color_clusters(1:length(seq.frames), 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters');


% rmfield(seq.frames, {'ghost_clusters', 'cluster_tracking_b', ...
%         'cluster_tracking_f', 'clusters_color_numbers', ...
%         'visible_clusters_color_numbers', 'cluster_tracking_u', 'cluster_tracking_d'});
    
function track_along_z(orbit)
% clusters_color_numbers = colors of clusters in clusters_data and ghost 
% clusters for which ghost_clusters.on == 1
for i = orbit'
    if isfield(seq.frames(i), 'up_frame')
        j = seq.frames(i).up_frame;
    else
        j = [];
    end
    if ~isempty(j)
        cl_frames(i).visible_clusters_color_numbers = color_map(cl_frames(i).visible_clusters_color_numbers);
        cl_frames(j).visible_clusters_color_numbers = color_map(cl_frames(j).visible_clusters_color_numbers);
        cluster_map = cl_frames(i).cluster_tracking_u;
        vals = sort([cl_frames(i).visible_clusters_color_numbers(find(cluster_map))' ... 
                    cl_frames(j).visible_clusters_color_numbers(nonzeros(cluster_map))'], 2);
        if ~isempty(vals)
            color_map(vals(:,2)) = vals(:,1);
        end
        cl_frames(i).visible_clusters_color_numbers = color_map(cl_frames(i).visible_clusters_color_numbers);
        cl_frames(j).visible_clusters_color_numbers = color_map(cl_frames(j).visible_clusters_color_numbers);
    end
end
    
end

%% track along t%%%%%%%%%%%%%%
function do_tracking(orbit, field_name, f_field_name, ghost_field)
    cl_frames(orbit(1)).clusters_color_numbers = 1:length(cl_frames(orbit(1)).clusters_data);
    %last_used_max = max(cl_frames(orbit(1)).clusters_color_numbers);
    last_used_max = 0;
    if isempty(last_used_max)
        last_used_max = 0;
    end
    for j = 1:length(orbit)
        clusters_lighted = {};
        cell_colors = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)), 3);
        cell_weight = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)), 1);
        cell_alphas = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)), 1);

        track_map = getfield(cl_frames, {orbit(j)}, field_name);
        f_track_map = getfield(cl_frames, {orbit(j)}, f_field_name);
        if isempty(cl_frames(orbit(j)).clusters_data)
            seq.frames(orbit(j)).cells = [];
            seq.frames(orbit(j)).cells_colors = ...
                zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)),3);
            seq.frames(orbit(j)).cells_alphas = zeros(length(seq.frames(orbit(j)).cellgeom.circles(:,1)),1);
            visible_clusters_color_numbers = [];
            if isfield(seq.frames, 'prev_frame') & ~isempty(seq.frames(orbit(j)).prev_frame)
                missing_clusters = 1:length(cl_frames(seq.frames(orbit(j)).prev_frame).clusters_data);

                cl_frames(orbit(j)).clusters_color_numbers = ...
                    (cl_frames(seq.frames(orbit(j)).prev_frame).clusters_color_numbers(missing_clusters));
                
                if isfield(seq.frames, 'next_frame') & ~isempty(seq.frames(orbit(j)).next_frame)

                    gap_filling = getfield(cl_frames, {seq.frames(orbit(j)).next_frame}, field_name) ...
                        - length(track_map);
                    gap_filling = gap_filling(gap_filling > 0);
                    if gap_filling
                        [cl_frames(orbit(j)).ghost_clusters(gap_filling).on] = deal(true);
                        temp_var = getfield(cl_frames, {orbit(j)}, ghost_field);
                        visible_clusters_color_numbers = ...
                        [cl_frames(orbit(j)).clusters_color_numbers(gap_filling)];
                    end
                end
            end
           
        else
            
            
            

            if isfield(seq.frames, 'prev_frame') & ~isempty(seq.frames(orbit(j)).prev_frame)
                cl_frames(orbit(j)).clusters_color_numbers = 1:length(track_map) + ...
                    length(getfield(cl_frames, {orbit(j)}, ghost_field));
                cl_frames(orbit(j)).clusters_color_numbers(find(track_map)) = ...
                    cl_frames(seq.frames(orbit(j)).prev_frame).clusters_color_numbers(...
                    nonzeros(track_map));
                len = length(cl_frames(seq.frames(orbit(j)).prev_frame).clusters_data);
                missing_clusters = setdiff(1:len, track_map, 'legacy');
                cl_frames(orbit(j)).clusters_color_numbers(length(track_map) + 1 :end) = ...
                        (cl_frames(seq.frames(orbit(j)).prev_frame).clusters_color_numbers(missing_clusters));

                unused_colors = setdiff(...
                        last_used_max + 1:last_used_max + 1 + ...
                        length(cl_frames(orbit(j)).clusters_color_numbers), ...
                    cl_frames(orbit(j)).clusters_color_numbers(find(track_map)), 'legacy');
                cl_frames(orbit(j)).clusters_color_numbers(find(~track_map)) = ...
                    unused_colors(1:sum(~track_map));
                                
                if isfield(seq.frames, 'next_frame') & ~isempty(seq.frames(orbit(j)).next_frame)

                    ind = track_map ~= 0 | f_track_map(1:length(track_map)) ~= 0;
                    [cl_frames(orbit(j)).clusters_data(ind).on] = deal(true);
                    gap_filling = getfield(cl_frames, {seq.frames(orbit(j)).next_frame}, field_name) ...
                        - length(track_map);
                    gap_filling = gap_filling(gap_filling > 0);
                    if gap_filling
                        temp_var = getfield(cl_frames, {orbit(j)}, ghost_field);
                        [cl_frames(orbit(j)).ghost_clusters(gap_filling).on] = deal(true);
                    end
                    visible_clusters_color_numbers = ...
                        [cl_frames(orbit(j)).clusters_color_numbers(ind) ...
                        cl_frames(orbit(j)).clusters_color_numbers(length(ind) + gap_filling)];
                else % no next frame but prev frame exists.
                    ind = track_map ~= 0;
                    [cl_frames(orbit(j)).clusters_data(ind).on] = deal(true);
                    visible_clusters_color_numbers = ...
                        cl_frames(orbit(j)).clusters_color_numbers(ind);
                end
            else % no prev frame
                cl_frames(orbit(j)).clusters_color_numbers = ...
                    last_used_max + 1: length(cl_frames(orbit(j)).clusters_data) + last_used_max';
                if isfield(seq.frames, 'next_frame') & ~isempty(seq.frames(orbit(j)).next_frame)
                    ind = f_track_map(1:length(track_map)) ~= 0;
                    [cl_frames(orbit(j)).clusters_data(ind).on] = deal(true);
                    visible_clusters_color_numbers = ...
                        cl_frames(orbit(j)).clusters_color_numbers(ind);
                else % no prev and no next frames
                    visible_clusters_color_numbers = cl_frames(orbit(j)).clusters_color_numbers;
                end
            end
            
        end
        last_used_max = max([last_used_max cl_frames(orbit(j)).clusters_color_numbers(:)']);
        cl_frames(orbit(j)).visible_clusters_color_numbers = visible_clusters_color_numbers;
    end
end
function cluster_map = ver_tracking(a_clusters, b_clusters, cluster_map, cell_map)
    cell_map = double(full(cell_map));
    for in_cnt = 1:length(a_clusters)
        if cluster_map(in_cnt) && length(intersect(cell_map(nonzeros(a_clusters(in_cnt).cells)), ...
                b_clusters(cluster_map(in_cnt)).cells, 'legacy')) < 3;
            cluster_map(in_cnt) = 0;
        end
    end
end
end