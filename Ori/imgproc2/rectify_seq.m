function seq = rectify_seq(seq, directory, save_to_disk, poly_seq, poly_frame_ind)
%rectify_seq will compare every pair of adjacent frames and will try to add
%or remove an edge if a cell is missing in one of them. The decision if to
%add an edge to the frame with a missing cell or remove an edge from the
%other frame (with an extra cell) is made such that the two frames will be
%more similar to a near by frame/cell which the user corrected.
%An edge is added by using addedge with node positions derived from the edge
%at the other frame and the lattice movement between the two frames. A
%better way to do this might be to add the edge with node positions that
%will guarantee a correct topology, then move the two nodes based on the
%node positions in the other frame and then optimize the two nodes
%positions based on a fit with the underlying image.

if nargin < 2 || isempty(directory)
    directory = seq.directory;
    if ~isdir(directory)
        directory = pwd;
    end
end
if nargin < 3 || isempty(save_to_disk)
    save_to_disk = true;
end
if nargin < 4 || isempty(ploy_seq)
    if isempty(dir(fullfile(directory, 'poly_seq.mat')))
        msg = sprintf('Could not find poly_seq.mat in %s', directory);
        h = msgbox(msg, '', 'error', 'modal');
        waitfor(h);
        return
    end
    load(fullfile(directory, 'poly_seq.mat'))
end
poly_ind = zeros(size(seq.frames));
for i = 1:length(seq.frames)
    %assuming frame numbers are sorted. the poly/frame with the closest t and z
    %indices should be used, not the one with the closest frame index. 
    [dummy poly_ind(i)] = min(abs(i - poly_frame_ind));
end

frames_with_user_corrections = false(size(seq.frames));
for i = 1:length(frames_with_user_corrections)
    frames_with_user_corrections(i) = seq.frames(i).cellgeom.changed_by_user;
    seq.frames(i).dist_from_key_frame = inf(1, size(seq.frames(i).cellgeom.circles, 1));
    seq.frames(i).ok_cells = false(1, size(seq.frames(i).cellgeom.circles, 1));

    x1 = poly_seq(poly_ind(i)).x; 
    y1 = poly_seq(poly_ind(i)).y;
    geom = seq.frames(i).cellgeom_edit;
    sel_cells = cells_in_poly(geom, y1, x1);
    if frames_with_user_corrections(i)
        val = 0;
    else
        val = length(seq.frames);
    end
    seq.frames(i).dist_from_key_frame(sel_cells) = val;
    seq.frames(i).ok_cells(sel_cells) = true;
end

if ~isempty(frames_with_user_corrections)
    next_batch = find(frames_with_user_corrections);
else
    next_batch = 1;
end

touched_frames = false(size(seq.frames));
done_frames = frames_with_user_corrections;
frames_order = [];
while ~isempty(next_batch)
    for i = 1:length(next_batch)
        

        frame1 = next_batch(i)
        frame2 = seq.frames(frame1).next_frame;
        if ~isempty(frame2) && ~done_frames(frame2)
            seq = do_correction_between_two_frames(seq, frame1, frame2, poly_seq, poly_ind);
            seq = do_correction_between_two_frames(seq, frame2, frame1, poly_seq, poly_ind);
            touched_frames(frame2) = true;
            seq = update_dist_from_key_frames(seq, frame1, frame2, poly_seq, poly_ind);
%             seq.frames(frame2).dist_from_key_frame = seq.frames(frame1).dist_from_key_frame + 1;
            frames_order(end+1, 1:2) = [frame1 frame2];
        end
        
        frame2 = seq.frames(frame1).prev_frame;
        if ~isempty(frame2) && ~done_frames(frame2)
            seq = do_correction_between_two_frames(seq, frame1, frame2, poly_seq, poly_ind);
            seq = do_correction_between_two_frames(seq, frame2, frame1, poly_seq, poly_ind);
            touched_frames(frame2) = true;
            seq = update_dist_from_key_frames(seq, frame1, frame2, poly_seq, poly_ind);
%             seq.frames(frame2).dist_from_key_frame = seq.frames(frame1).dist_from_key_frame + 1;
            frames_order(end+1, 1:2) = [frame1 frame2];
        end
        done_frames(frame1) = true;
        
    end
    next_batch = find(touched_frames & ~done_frames);
    
end
%redo in reverse order
for i = length(frames_order):-1:1
    frame1 = frames_order(i, 1)
    frame2 = frames_order(i, 2);
    seq = do_correction_between_two_frames(seq, frame1, frame2, poly_seq, poly_ind);
    seq = do_correction_between_two_frames(seq, frame2, frame1, poly_seq, poly_ind);
    seq = update_dist_from_key_frames(seq, frame1, frame2, poly_seq, poly_ind);
end

if save_to_disk
%save cellgeom_edit from seq to disk for all frames.
    for i = 1:length(seq.frames)
        cellgeom = seq.frames(i).cellgeom_edit;
        cellgeom.changed_by_user = false;
        save(fullfile(directory, seq.frames(i).filename), 'cellgeom', '-append');
    end
end

function seq = update_dist_from_key_frames(seq, frame1, frame2, poly_seq, poly_ind)
%update the distance from a key frame of cells in frame1 and frame2 to be
%the dist in the other frame + 1, if it is not already less than that. Do
%this only for selected cells (cells_in_poly) and cells with no failed 
%corrections (ok_cells).

x1 = poly_seq(poly_ind(frame1)).x; 
y1 = poly_seq(poly_ind(frame1)).y;
x2 = poly_seq(poly_ind(frame2)).x; 
y2 = poly_seq(poly_ind(frame2)).y;
geom1 = seq.frames(frame1).cellgeom_edit;
geom2 = seq.frames(frame2).cellgeom_edit;
sel_cells = cells_in_poly(geom1, y1, x1);
sel_cells = sel_cells & cells_in_poly(geom1, y2, x2);
sel_cells = sel_cells' & seq.frames(frame1).ok_cells;
[fc fc_targets inverse_tracking shifts forward] = untracked_cells(...
    geom1, geom2, seq, frame1, frame2, poly_seq, poly_ind);

tracked = forward(sel_cells) > 0;
temp_list = find(sel_cells);
tracked = temp_list(tracked);
targets = nonzeros(forward(sel_cells));


%Do the cells in frame2 fall into the polygon in frame1 and frame2?
sel_cells = cells_in_poly(geom2, y1, x1, targets);
sel_cells = sel_cells & cells_in_poly(geom2, y2, x2, targets);

%Mark ok cells in frame2
ind = seq.frames(frame2).ok_cells(targets);

%keep only the cells satisfying the last two conditions.
ind = ind & sel_cells';
tracked = tracked(ind);
targets = targets(ind);

seq.frames(frame1).dist_from_key_frame(tracked) = min(...
    seq.frames(frame1).dist_from_key_frame(tracked), ...
    seq.frames(frame2).dist_from_key_frame(targets) + 1);
seq.frames(frame2).dist_from_key_frame(targets) = min(...
    seq.frames(frame2).dist_from_key_frame(targets), ...
    seq.frames(frame1).dist_from_key_frame(tracked) + 1);


function seq = do_correction_between_two_frames(seq, frame1, frame2, poly_seq, poly_ind)
if isempty(frame2) || isempty(frame1)
    return
end

times_done = 0;
needs_to_redo = 1;
while times_done < 4 && needs_to_redo
    [seq needs_to_redo] = correct_frames_once(seq, frame1, frame2, poly_seq, poly_ind, times_done + 1);
    times_done = times_done + 1;
end

function [seq needs_to_redo] = correct_frames_once(seq, frame1, frame2, poly_seq, poly_ind, iteration)
needs_to_redo = false;
geom1 = seq.frames(frame1).cellgeom_edit;
geom2 = seq.frames(frame2).cellgeom_edit;

% FIXING GEOM AND BOUDNARY EDGES IS NOW DONE AFTER EVERY STEP AND DURING
% SEGMENTATION. NO NEED TO DO IT AGAIN HERE.
% %fix_geom and (mainly) fix_boundary_edges change the number of cells.
% %for now we track cells between the old and the new geom and update the
% %dist lists based on that tracking
% old_dist1 = seq.frames(frame1).dist_from_key_frame;
% old_dist2 = seq.frames(frame2).dist_from_key_frame;
% 
% old_geom1 = geom1;
% geom1 = fix_boundary_edges(geom1);
% [fc fc_targets inverse_tracking shifts forward] = untracked_cells(...
%     geom1, old_geom1, seq, frame1, frame1, poly_seq, poly_ind); 
% dist1 = inf(1, size(geom1.circles, 1));
% dist1(forward > 0) = old_dist1(nonzeros(forward));
% seq.frames(frame1).dist_from_key_frame = dist1;
% 
% old_geom2 = geom2;
% geom2 = fix_boundary_edges(geom2);
% [fc fc_targets inverse_tracking shifts forward] = untracked_cells(...
%     geom2, old_geom2, seq, frame2, frame2, poly_seq, poly_ind); 
% dist2 = inf(1, size(geom2.circles, 1));
% dist2(forward > 0) = old_dist2(nonzeros(forward));
% seq.frames(frame2).dist_from_key_frame = dist2;

dist1 = seq.frames(frame1).dist_from_key_frame;
dist2 = seq.frames(frame2).dist_from_key_frame;
ok_cells1 = seq.frames(frame1).ok_cells;
ok_cells2 = seq.frames(frame2).ok_cells;


[cells1 cells1_target inverse_tracking shifts] = untracked_cells(...
    geom1, geom2, seq, frame1, frame2, poly_seq, poly_ind);
x = poly_seq(poly_ind(frame1)).x; 
y = poly_seq(poly_ind(frame1)).y;
sel_cells = cells_in_poly(geom1, y, x, cells1);
x = poly_seq(poly_ind(frame2)).x; 
y = poly_seq(poly_ind(frame2)).y;
sel_cells = sel_cells | cells_in_poly(geom1, y, x, cells1);


if isempty(cells1)
    %nothing to do but keep some updates from fix_boudnary_edges
    seq.frames(frame1).cellgeom_edit = geom1; 
    seq.frames(frame2).cellgeom_edit = geom2;    
    return
end

cells1 = cells1(sel_cells);
cells1_target = cells1_target(sel_cells);
inverse_tracking = inverse_tracking(sel_cells);
shifts = shifts(:, sel_cells);
if isempty(inverse_tracking)
    %nothing to do but keep some updates from fix_boudnary_edges
    seq.frames(frame1).cellgeom_edit = geom1; 
    seq.frames(frame2).cellgeom_edit = geom2;    
    return
end


%if any cell appears more than once in inverse tracking, keep only one
%corresponding cell in cells1 and raise the redo flag
count = accumarray(inverse_tracking' + 1, 1);
count(1) = 0;
% + 1 because inverse_tracking can have zero values. Undone when setting
% dups below.
if any(count > 1)
    needs_to_redo = 1;
    dups = find(count > 1) - 1;
    remove_ind = false(size(cells1));
    dups_ind = remove_ind;
    for i = 1:length(dups)
        ind = inverse_tracking == dups(i);
        remove_ind(ind) = true;
        remove_ind(find(ind, 1)) = false;
        dups_ind(find(ind, 1)) = true;
    end
    
    cells1 = cells1(~remove_ind);
    cells1_target = cells1_target(~remove_ind);
    inverse_tracking = inverse_tracking(~remove_ind);
    shifts = shifts(:, ~remove_ind);
    dups_cells1 = dups_ind(~remove_ind);
end
    


correct1 = compare_geoms(cells1, cells1_target, inverse_tracking, dist1, dist2);


[geom1 geom2 dist1 dist2 ok_cells1 ok_cells2 success_list ...
          cells1 inverse_tracking cells1_target] = ...
    edit_geom_from_geom(geom1, geom2, dist1, dist2, ok_cells1, ok_cells2, ...
        cells1, correct1, cells1_target, inverse_tracking, shifts);

% if the fixing of cells with multiple inverse_tracking sources failed for 
% each and every one of those, then lower redo flag
if needs_to_redo && ~any(success_list(dups_cells1))
    needs_to_redo = 0;
end

failed1 = ~ok_cells1;
failed1(cells1(~success_list)) = 1;
failed1(nonzeros(inverse_tracking(~success_list))) = 1;

failed2 = ~ok_cells2;
failed2(cells1_target(~success_list)) = 1;



%fix_geom and (mainly) fix_boundary_edges change the number of cells.
%for now we track cells between the old and the new geom and update the
%dist lists based on that tracking
old_geom1 = geom1;
old_dist1 = dist1;
old_ok_cells1 = ok_cells1;
geom1 = fix_geom(geom1);
geom1 = fix_boundary_edges(geom1);
[fc fc_targets inverse_tracking shifts forward] = untracked_cells(...
    geom1, old_geom1, seq, frame1, frame1, poly_seq, poly_ind); 
dist1 = inf(1, size(geom1.circles, 1));
dist1(forward > 0) = old_dist1(nonzeros(forward));

%ok_cells = cells successfully corrected or not needed to be corrected
ok_cells1 = false(size(dist1));
ok_cells1(forward > 0) = ~failed1(nonzeros(forward)); 

old_geom2 = geom2;
old_dist2 = dist2;
geom2 = fix_geom(geom2);
geom2 = fix_boundary_edges(geom2);
[fc fc_targets inverse_tracking shifts forward] = untracked_cells(...
    geom2, old_geom2, seq, frame2, frame2, poly_seq, poly_ind); 
dist2 = inf(1, size(geom2.circles, 1));
dist2(forward > 0) = old_dist2(nonzeros(forward));

%ok_cells = cells successfully corrected or not needed to be corrected
ok_cells2 = false(size(dist2));
ok_cells2(forward > 0) = ~failed2(nonzeros(forward)); 

seq.frames(frame1).cellgeom_edit = geom1;
seq.frames(frame2).cellgeom_edit = geom2;        
seq.frames(frame1).dist_from_key_frame = dist1;
seq.frames(frame2).dist_from_key_frame = dist2;
seq.frames(frame1).ok_cells = ok_cells1;
seq.frames(frame2).ok_cells = ok_cells2;


function [fc fc_targets inverse_tracking shifts forward] = untracked_cells(...
    geom1, geom2, seq, frame1, frame2, poly_seq, poly_ind) 
min_num_cells = 4;
grid_size = 8;
cell_length = mean(geom1.edges_length)*2;

% modify a positions based on tracking between frame1 and frame2 in seq to
% accomodate for tissue changes
a = seq.frames(frame1).cellgeom.circles(:, 1:2)';
b = seq.frames(frame2).cellgeom.circles(:, 1:2)';
a_to_b = zeros(1, length(a));
a_to_b((seq.inv_cells_map(frame1, :) > 0)) = ...
    seq.cells_map(frame2, nonzeros(seq.inv_cells_map(frame1, :)));
found_a_to_b = a_to_b > 0;

x = poly_seq(poly_ind(frame1)).x; 
y = poly_seq(poly_ind(frame1)).y;
sel_cells = inpolygon(a(1, :), a(2, :), x, y);
x = poly_seq(poly_ind(frame2)).x; 
y = poly_seq(poly_ind(frame2)).y;
sel_cells = sel_cells & inpolygon(a(1, :), a(2, :), x, y);
found_a_to_b_sel = found_a_to_b & sel_cells;

reg_cells = get_subregions(a, grid_size, min_num_cells, cell_length);
dis_vec = zeros(size(reg_cells, 2), 2);
for cnt = 1:size(reg_cells, 2)
    found_reg = reg_cells(:, cnt)' & found_a_to_b_sel;
    if ~any(found_reg)
        found_reg = reg_cells(:, cnt)' & found_a_to_b;
    end
    dis_vec(cnt, :) = (mean(b(:, a_to_b(found_reg)) - a(:, found_reg), 2))';
end

old_a = a;
a = geom1.circles(:, 1:2)';
b = geom2.circles(:, 1:2)';
reg_cells = get_subregions(a, grid_size, min_num_cells, cell_length, old_a);
shifts = zeros(size(a));
for cnt = 1:size(reg_cells, 2)
    a(1, reg_cells(:, cnt)) = a(1, reg_cells(:, cnt)) + dis_vec(cnt, 1);
    a(2, reg_cells(:, cnt)) = a(2, reg_cells(:, cnt)) + dis_vec(cnt, 2);
    shifts(1, reg_cells(:, cnt)) = dis_vec(cnt, 1);
    shifts(2, reg_cells(:, cnt)) = dis_vec(cnt, 2);
end

[forward backward f_dist b_dist i1] = track(a, b);
fc = find(forward == 0);
shifts = shifts(:, forward == 0);

% fc_targets = i1(fc);
% inverse_tracking = zeros(size(fc));
fc_targets = zeros(size(fc));
for i = 1:length(fc)
    fc_targets(i) = cell_from_pos(a(2, fc(i)), a(1, fc(i)), geom2);
end
% fc_targets(fc_targets == 0) = i1(fc(fc_targets == 0));
fc = fc(fc_targets ~= 0);
shifts = shifts(:, fc_targets ~=0);
fc_targets = fc_targets(fc_targets ~=0);
inverse_tracking = backward(fc_targets); %fc_targets are never zero


function correct1 = compare_geoms(cells1, cells1_target, ...
    inverse_tracking, dist1, dist2)
correct1 = zeros(size(cells1));
temp_dist1 = dist1(cells1);
ind = inverse_tracking > 0;
temp_dist1(ind) = min(temp_dist1(ind), dist1(inverse_tracking(ind)));

correct1(temp_dist1 < dist2(cells1_target)) = 1;
correct1(temp_dist1 > dist2(cells1_target)) = 2;

% % %for now just mark the cells of the frame which is closer to a key frame to be correct
% if dist_from_key_frame1 > dist_from_key_frame2
%     correct1 = false(size(cells1));
% else
%     correct1 = true(size(cells1));
% end

% correct1 = geom1.certainty(cells1) > geom2.certainty(cells1_target);

function [geom1 geom2 dist1 dist2 ok_cells1 ok_cells2 success_list ...
          cells1 inverse_tracking cells1_target] = ...
    edit_geom_from_geom(geom1, geom2, dist1, dist2, ok_cells1, ok_cells2, ...
        cells1, correct1, cells1_target, inverse_tracking, shifts)
%cells1 = list of extra cells in geom1
%correct1 = A list of instructions for every extra cell in geom1.
%1 if the cell should be kept (ie, make geom2 like geom1 for this case), 
%2 if the cell should be removed (ie, make geom1 like geom2 for this case),
%0 if failed to decide and nothing should be done.

% the indices of cells1, correct1, cells1_target must not be changed. The
% contents of these lists can and should be updated to reflect changes in
% the topology and indexing of cells in each geom. That is, the k-th item
% of a list should remain the k-th item on the list during the life span of
% edit_geom_from_geom but the contect of the k-th item on the list should
% change to reflect a possibly new index that same cell has been assigned.

%dist1, dist2, ok_cells1 and ok_cells2 are logical lists and their indices 
%are updated to maintain their integrity. That is, if a cell whose index 
%was k in geom1 now has index l (because of changes made to the topology 
%in geom1), the content of dist1(l) will have the value that dist1(k) had
%before.

% success_list is a logical flag for each cell listed in cells1 and
% therefore its indices should not change. success_list(i) is true iff the
% correction of cells1(i)/cells1_target(i) was succesful.
 
success_list = false(size(cells1));

border_cells1 = geom1.border_cells(cells1);
border_cells2 = geom2.border_cells(cells1_target);

for i = 1:length(cells1)
    if isinf(dist1(cells1(i))) && isinf(dist2(cells1_target(i)))
        continue
    end
    if cells1(i) == inverse_tracking(i)
        'same cell'
        continue
    end
    cand_ed1 = geom1.edgecellmap(geom1.edgecellmap(:, 1) == cells1(i), 2);
    cand_ed2 = geom1.edgecellmap(geom1.edgecellmap(:, 1) == inverse_tracking(i), 2);
    edge = faster_intersect(cand_ed1, cand_ed2, length(geom1.edges));
    if isempty(edge)
        'could not find edge in geom1';
        continue
    end
    if correct1(i) == 1 && ~border_cells1(i) %geom1 has the correct topology: 
        %update geom2 to include the missing cell
        
        %find node positions for the edge in geom1
        nodes = geom1.nodes(geom1.edges(edge, :), :);
        nodes(:, 1) = nodes(:, 1) + shifts(1, i);
        nodes(:, 2) = nodes(:, 2) + shifts(2, i);
        %add edge at node positions to geom2
        [geom2 success] = addedge(geom2, [], 1, cells1_target(i), nodes(1, :), nodes(2, :));
        if ~success
            'failed to add edge';
            continue
        end
        %update certainty list in geom2
        dist2 = add_item_to_list(dist2, dist1(cells1(i)) + 1);
        ok_cells2 = add_item_to_list(ok_cells2, true);

        %update certainty score for the affected cells in geom2 
        dist2(cells1_target(i)) = dist1(cells1(i)) + 1;
        ok_cells2(cells1_target(i)) = 1;

        %update cells1_target to reflect changes in geom2 (There's no need
        %to update the cells1_target list because the new cell was added to
        %the end of the cells list in geom2 and therefore the cell indices
        %of exisiting cells were not affected).
        
    elseif correct1(i) == 2 && ~border_cells2(i)
        %update geom1 to remove the extra cell
        %remove edge in geom1
        [geom1 success] = unite_cells(geom1, cells1(i), inverse_tracking(i), 1);
        if ~success
            'failed to unite cells';
            continue
        end
        geom1 = full_edgecellmap(geom1); %edgecellmap is used to find the edge 
        %between two cells at the beginning of the loop. It must be kept
        %updated for future iterations of the loop.
        
        %unite_cells removes the cell with higher index 
        removed_cell = max(cells1(i), inverse_tracking(i));
        united_cell = min(cells1(i), inverse_tracking(i));
        
        %update certainty list in geom1
        dist1 = remove_item_from_list(dist1, removed_cell);
        ok_cells1 = remove_item_from_list(ok_cells1, removed_cell);

        %update certainty score for the affected cells in geom1 
        dist1(united_cell) = dist2(cells1_target(i)) + 1;
        ok_cells1(united_cell) = true;
        
        %update cells1 list to reflect changes in geom1
        cells1 = remove_item_from_target_list(cells1, removed_cell);
        
        %update inverse_tracking to reflect changes in geom1
        inverse_tracking = remove_item_from_target_list(inverse_tracking, removed_cell);
    end
    success_list(i) = true;
end

function list = add_item_to_list(list, new_item)
list(end+1) = new_item;

function list = remove_item_from_list(list, item)
list = list([1:(item-1) (item+1):end]);

function list = add_item_to_target_list(list, item_value)

function list = remove_item_from_target_list(list, item_value)
list(list == item_value) = 0;
list(list > item_value) = list(list > item_value) - 1;

function edge = edge_from_cells(necm, cell1, cell2)
if cell2 > cell1
    temp_cell = cell1;
    cell1 = cell2;
    cell2 = cell1;
end
edge = find(necm(:, 1) == cell1 & necm(:, 2) == cell2);