function [inv_cells cells] = track_movie(seq)
%h = waitbar(1./length(seq.frames), 'Please wait...', 'WindowStyle', 'Modal');
t_start = clock;
for i = 1:length(seq.frames)
    if isfield(seq.frames, 'next_frame') & ~isempty(seq.frames(i).next_frame)
        j = seq.frames(i).next_frame;
        a = seq.frames(i).cellgeom.circles(:,1:2)';
        b = seq.frames(j).cellgeom.circles(:,1:2)';
        %[seq.frames(i).tracking_f seq.frames(j).tracking_b] = track(a,b);
        [seq.frames(i).tracking_f seq.frames(j).tracking_b dummy seq.frames(j).b_dist] = track(a,b);
    end
    
    if isfield(seq.frames, 'up_frame') & ~isempty(seq.frames(i).up_frame)
        j = seq.frames(i).up_frame;
        a = seq.frames(i).cellgeom.circles(:,1:2)';
        b = seq.frames(j).cellgeom.circles(:,1:2)';
        %[seq.frames(i).tracking_u seq.frames(j).tracking_d] = track(a,b);
        [seq.frames(i).tracking_u dummy seq.frames(i).u_dist]= track(a,b);
    end
%     t_elapsed = etime(clock, t_start);
%     t_remain = t_elapsed * ((1 + length(seq.frames) - i) / i);
end

cells = zeros(length(seq.frames), length(seq.frames(1).cellgeom.circles(:,1)), 'uint16');
cells(1, :) = 1:length(seq.frames(1).cellgeom.circles(:,1));
inv_cells = uint32(cells);
max_cell_num = length(seq.frames(1).cellgeom.circles(:,1));

orbit = nonzeros(seq.frames_num(seq.min_t, seq.min_z:seq.max_z));
% create_map(orbit, 'tracking_u', 'up_frame');

orbit = nonzeros(seq.frames_num(seq.min_t:seq.max_t, seq.min_z));
%create_map(orbit, 'tracking_f', 'next_frame');
    
    
orbit = nonzeros(seq.frames_num(seq.min_t, (seq.min_z + 1):seq.max_z));
for i = 1:length(seq.frames)
    old_cells_length = length(cells(i, :));
    cells(i, end + 1: end + length(seq.frames(i).cellgeom.circles(:,1))) = ...
        1:length(seq.frames(i).cellgeom.circles(:,1));
    inv_cells(i, 1:length(seq.frames(i).cellgeom.circles(:,1))) = ...
        (1:length(seq.frames(i).cellgeom.circles(:,1))) + old_cells_length; 
end

% for t = seq.min_t:seq.max_t
%     orbit = nonzeros(seq.frames_num(t, seq.min_z:seq.max_z));
%     create_map(orbit, 'tracking_u', 'up_frame');
% end
% for z = seq.min_z:seq.max_z
%     
%     orbit = nonzeros(seq.frames_num(seq.min_t:seq.max_t, z));
%     
%     create_map(orbit, 'tracking_f', 'next_frame');
% end

max_cell_num = length(cells(1,:));


[x y] = meshgrid(seq.min_t:seq.max_t, seq.min_z:seq.max_z);
% x = x';
% y = y';
orbit = nonzeros(seq.frames_num(sub2ind(size(seq.frames_num), x(:), y(:))));
track_along_z(orbit);
clean_up
% track_along_z(orbit(end:-1:1));
% clean_up

    function clean_up
        %clean up
        cells(:) = 0;
        for i = 1:length(seq.frames)
            cells(i, nonzeros(inv_cells(i, :))) = find(inv_cells(i,:));
        end

        %remove the zero columns from cells and update inv_cells accordingly
        a = any(cells, 1);
        cells = cells(:, a);
        if sum(~~cells(:))< 0.3 * length(cells(:))
            cells = sparse(double(cells));
        end
        b = uint32([0 cumsum(a)]);
        inv_cells = b(inv_cells + 1);
    end
    function create_map(orbit, track_field, frame_field)
        for k = 1:length(orbit)
            i = orbit(k);
            if isfield(seq.frames(i), frame_field) && ~isempty(getfield(seq.frames, {i}, frame_field));
                j = getfield(seq.frames, {i}, frame_field);
                tracked_cells = getfield(seq.frames, {i}, track_field);
                cells(j, nonzeros(inv_cells(i, :))) = tracked_cells;
                new_cells = true(1, length(seq.frames(j).cellgeom.circles(:,1)));
                new_cells(nonzeros(tracked_cells)) = false;
                new_cells(find(inv_cells(j, :))) = false;
                new_cells = find(new_cells);
                cells(j, end + 1: end + length(new_cells)) = new_cells;
                inv_cells(j, nonzeros(tracked_cells)) = inv_cells(i, find(tracked_cells));
                inv_cells(j, new_cells) = 1 + length(cells(j,:)) - length(new_cells): length(cells(j,:));
            end
            if isfield(seq.frames(i), frame_field) && isempty(getfield(seq.frames, {i}, frame_field));
                tracked_cells = nonzeros(cells(i,:));
                new_cells = true(1, length(seq.frames(i).cellgeom.circles(:,1)));
                new_cells(nonzeros(tracked_cells)) = false;
                new_cells(find(inv_cells(i, :))) = false;
                new_cells = find(new_cells);
                cells(i, end + 1: end + length(new_cells)) = new_cells;
                inv_cells(i, new_cells) = 1 + length(cells(i,:)) - length(new_cells): length(cells(i,:));
            end
        end
    end

    function track_along_z(orbit);
        for i = orbit'
            if isfield(seq.frames(i), 'up_frame')
                j = seq.frames(i).up_frame;
            else
                j = [];
            end
            if ~isempty(j)
                find_tracked_i_u = find(seq.frames(i).tracking_u);

%                 vals = ([inv_cells(j, nonzeros(seq.frames(i).tracking_u));...
%                             inv_cells(i, find(seq.frames(i).tracking_u))]');
                        
                b_dist_top = inf(1, length(seq.frames(i).cellgeom.circles(:,1)));
                if isfield(seq.frames(j), 'prev_frame')
                    k = seq.frames(j).prev_frame;
                else
                    k = [];
                end
                if ~isempty(k)
                    find_tracked_j_b = find(seq.frames(j).tracking_b);
                    temp_b_dist_top(find_tracked_j_b) = seq.frames(j).b_dist(find_tracked_j_b);
                    mismatches = false(size(temp_b_dist_top));
                    mismatches(find_tracked_j_b) = ...
                        inv_cells(j, find_tracked_j_b) ~= inv_cells(k, nonzeros(seq.frames(j).tracking_b));
                    temp_b_dist_top(mismatches) = inf;
                    b_dist_top(find_tracked_i_u) = seq.frames(j).b_dist(nonzeros(seq.frames(i).tracking_u));
                end
                
                b_dist = inf(1, length(seq.frames(i).cellgeom.circles(:,1)));
                if isfield(seq.frames(i), 'prev_frame')
                    l = seq.frames(i).prev_frame;
                else
                    l = [];
                end
                if ~isempty(l)
                    find_tracked_i_b = find(seq.frames(i).tracking_b);
                    mismatches = false(size(b_dist));
                    mismatches(find_tracked_i_b) = ...
                        inv_cells(i, find_tracked_i_b) ~= inv_cells(l, nonzeros(seq.frames(i).tracking_b));
                    b_dist(find_tracked_i_b) = seq.frames(i).b_dist(find_tracked_i_b);
                    b_dist(mismatches) = inf;
                end
                
                u_dist = inf(1, length(seq.frames(i).cellgeom.circles(:,1)));
                u_dist(find_tracked_i_u) = seq.frames(i).u_dist(find_tracked_i_u);

                prev_u_dist = inf(1, length(seq.frames(i).cellgeom.circles(:,1)));
                if ~isempty(l) && isfield(seq.frames(l), 'up_frame')
                    m = seq.frames(l).up_frame;
                else
                    m = [];
                end
                if ~isempty(m) && m == k 
                    temp_prev_u_dist = inf(1, length(seq.frames(l).cellgeom.circles(:,1)));
                    find_tracked_l_u = find(seq.frames(l).tracking_u);
                    temp_prev_u_dist(find_tracked_l_u) = seq.frames(l).u_dist(find_tracked_l_u);
                    mismatches = false(size(temp_prev_u_dist));
                    mismatches(find_tracked_l_u) = ...
                        inv_cells(l, find_tracked_l_u) ~= inv_cells(m, nonzeros(seq.frames(l).tracking_u));
                    temp_prev_u_dist(mismatches) = inf;
                    prev_u_dist(find_tracked_i_b) = temp_prev_u_dist(nonzeros(seq.frames(i).tracking_b));
                end
                shorter_b_dist = b_dist < b_dist_top;
                b_dist(~shorter_b_dist) = b_dist_top(~shorter_b_dist);
                vals_to_change = u_dist < b_dist & u_dist < prev_u_dist;
                vals_to_change(find(nonzeros(seq.frames(i).tracking_u))) = ...
                    vals_to_change(find(nonzeros(seq.frames(i).tracking_u))) & ...
                    inv_cells(i, find(nonzeros(seq.frames(i).tracking_u))) ~= inv_cells(j, nonzeros(seq.frames(i).tracking_u));
                up2down = shorter_b_dist & vals_to_change;
                down2up = ~shorter_b_dist & vals_to_change;
                
                
                
                inv_cells(i, down2up) = inv_cells(j, seq.frames(i).tracking_u(down2up));
                existing_cells = ismember(inv_cells(i, ~down2up), inv_cells(i, down2up), 'legacy');
                ind = find(~down2up);
                inv_cells(i, ind(existing_cells)) = (1:sum(existing_cells)) + max_cell_num;
                max_cell_num = max_cell_num + sum(existing_cells);
                
                new_ind = false(size(inv_cells(1,:)));
                new_ind(seq.frames(i).tracking_u(up2down)) = true;
                inv_cells(j, seq.frames(i).tracking_u(up2down)) = inv_cells(i, up2down);
                existing_cells = ismember(inv_cells(j, ~new_ind), inv_cells(j, new_ind), 'legacy');
                ind = find(~new_ind);
                inv_cells(j, ind(existing_cells)) = (1:sum(existing_cells)) + max_cell_num;
                max_cell_num = max_cell_num + sum(existing_cells);
                if isfield(seq.frames(j), 'next_frame')
                    n = seq.frames(j).next_frame;
                else
                    n = [];
                end
                if ~isempty(n)
                    inv_cells(n, nonzeros(seq.frames(j).tracking_f)) = inv_cells(j, find(seq.frames(j).tracking_f));
                end
            end
            if isfield(seq.frames(i), 'next_frame')
                j = seq.frames(i).next_frame;
            else
                j = [];
            end
            if ~isempty(j)
                inv_cells(j, nonzeros(seq.frames(i).tracking_f)) = inv_cells(i, find(seq.frames(i).tracking_f));
            end
        end
    end
    
end

