function [inv_cells cells] = track_movie_no_z(seq, size_scale, num_iter)
if nargin < 2 || isempty(size_scale)
    size_scale = 1;
end
if nargin < 3 || isempty(num_iter)
    num_iter = 5;
end

final_bad_tracking_thresh = 400 / size_scale;
radius = 100 / size_scale;
thresh = 25 / size_scale;
min_num_cells = 4;
grid_size = 8;

orbit = nonzeros(seq.frames_num(seq.min_t:seq.max_t, seq.min_z))';
dis_vec = ([0 0]);
reg_cells = true(length(seq.frames(1).cellgeom.circles(:, 1)), 1);
for i = orbit
    if isfield(seq.frames, 'next_frame') && ~isempty(seq.frames(i).next_frame)
        %Approximate average cell length
        cell_length = mean(seq.frames(i).cellgeom.edges_length)*2;
        
        j = seq.frames(i).next_frame;
        %Tracking is based on the positions of cell centers
        a = seq.frames(i).cellgeom.circles(:,1:2)';
        b = seq.frames(j).cellgeom.circles(:,1:2)';
        
        %Move each cell in the source frame by the average displacement
        %of tracked cells within the same region in the previous frame.
        for cnt = 1:size(reg_cells, 2)
            a(1, reg_cells(:, cnt)) = a(1, reg_cells(:, cnt)) + dis_vec(cnt, 1);
            a(2, reg_cells(:, cnt)) = a(2, reg_cells(:, cnt)) + dis_vec(cnt, 2);
        end
        
        %update regions
        reg_cells = get_subregions(a, grid_size, min_num_cells, cell_length);
        
        %Track the cells of 'a' (with shifted locations) into 'b'
        tf = iterative_tracking(a, b, num_iter, radius, thresh, reg_cells);
        
        %some mistaken tracked cells might have been added in the last
        %tracking step.
        real_dis_vecs = a(:, find(tf)) - b(:, nonzeros(tf));
        mean_real_dis_vec = mean(real_dis_vecs, 2);
        real_dis_vecs(1, :) =  real_dis_vecs(1, :) - mean_real_dis_vec(1, :);
        real_dis_vecs(2, :) =  real_dis_vecs(2, :) - mean_real_dis_vec(2, :);
        bad_cells = sum(real_dis_vecs.^2) > final_bad_tracking_thresh; %DEBUG CODE HARD CODED VALUE REPLACE CHANGE
        bad_cells_temp_map = find(tf);
        tf(bad_cells_temp_map(bad_cells)) = 0;


        
        %Assign tracking info.
        t_info(i).tracking_f = tf;

%   OLD   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%         %Cell centers locations in 'a' were already shifted by the average
%         %difference between cells locations in the previous two frames.
%         %Therefore, the mean displacement between the previous two frames
%         %must be added to the difference between 'a' and 'b' to be equal to the
%         %displacement between the cells in the current two frames.
% 
%         dis_vec = dis_vec + mean(a(:, find(tf)) - b(:, nonzeros(tf)), 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %get a list of b-cells in a-regions
        reg_cells_b = get_subregions(b, grid_size, min_num_cells, cell_length, a);
        
        a = seq.frames(i).cellgeom.circles(:,1:2)';
        dis_vec = zeros(size(reg_cells, 2), 2);
        for cnt = 1:size(reg_cells, 2)
            tracked_reg = (reg_cells(:, cnt))' & tf > 0;
            dis_vec(cnt, :) = (mean(b(:, tf(tracked_reg)) - a(:, tracked_reg), 2))';
        end
        
        reg_cells = reg_cells_b;
        
    end
end


%Build the global cell map based on tracking info of cells between each
%pair of sequential frames.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Assign each cell in each frame with a unique global id. This step
%guarantees each cell will have a global id
inv_cells = zeros(length(seq.frames), length(seq.frames(1).cellgeom.circles(:,1)), 'uint32');
max_cell_num = length(seq.frames(1).cellgeom.circles(:,1));
old_cells_length = 0;
for i = 1:length(seq.frames)
    num_cells = length(seq.frames(i).cellgeom.circles(:,1));
    inv_cells(i, 1:num_cells) = (1:num_cells) + old_cells_length;
    old_cells_length = old_cells_length + num_cells;
end

%Assign to each cell in each frame the same global id the corresponding cell
%in the previous frame was assigned to.
for i = orbit
    if isfield(seq.frames(i), 'next_frame') && ~isempty(seq.frames(i).next_frame)
        j = seq.frames(i).next_frame;
        inv_cells(j, nonzeros(t_info(i).tracking_f)) = inv_cells(i, find(t_info(i).tracking_f));
    end
end

%Update inv_cells so that all the global cells ids are sequential. That is,
%if n is a global id, then all positive k that are smaller than n are also 
%global cell id-s (some cell in some frame is mapped to the the global id k). 
a = false(1, max(inv_cells(:)));
a(nonzeros(inv_cells(:))) = 1;
b = uint32([0 cumsum(a)]);
inv_cells = b(inv_cells + 1);

        
%Create the cells map based on inv_cells
cells = zeros(length(seq.frames), max(inv_cells(:)), 'uint16');
for i = 1:length(seq.frames)
    cells(i, nonzeros(inv_cells(i, :))) = find(inv_cells(i,:));
end


function tf = iterative_tracking(a, b, num_iter, radius, thresh, reg_cells)
%For each locations in 'a', find the closest location in 'b'
%If tracking failed for some cells locations or the distance between two 
%corresponding cells is more than sqrt(radius) (defined below), move these 
%cells by the average displacement of succesfully tracked cells. Repeat this
%process num_iter times.

% %%%%%% HARD CODED VALUE DEBUG REPLACE CELL SIZE FACTOR %%%%%%%%%%%%%%%%%%%%%%
% radius = 100; %squared dist 
% thresh = 25; %squared dist 
% %%%%%% HARD CODED VALUE DEBUG REPLACE CELL SIZE FACTOR %%%%%%%%%%%%%%%%%%%%%%

if num_iter == 0
    thresh = radius;
end

%Track all cells
[tf tb df] = track(a,b);

%Find tracked cells, with distance less than radius
tracked_cells = tf ~= 0 & df < radius; %df is distance squared
tracked_cells_b = tb ~= 0;

if ~any(tracked_cells)
    tf(:) = 0;
    return
end

%Calculate mean displacement between tracked cells in each region
dis_not_zero = false;
for cnt = 1:size(reg_cells, 2)
    tracked_reg = tracked_cells' & reg_cells(:, cnt);
    not_tracked_reg = ~tracked_cells' & reg_cells(:, cnt);

    dis_vecs = a(:, tracked_reg) - b(:, tf(tracked_reg));
    mean_dis_vec = mean(dis_vecs, 2);
    dis_not_zero = dis_not_zero | any(mean_dis_vec);
    
    %If the length of the difference between the displacement vector and the
    %mean displacement vector is more than 'thresh', mark as untracked
    new_dis_vecs = dis_vecs;
    new_dis_vecs(1, :) =  dis_vecs(1, :) - mean_dis_vec(1, :);
    new_dis_vecs(2, :) =  dis_vecs(2, :) - mean_dis_vec(2, :);
    bad_cells = sum(new_dis_vecs.^2) > thresh;
    bad_cells_temp_map = find(tracked_reg);
    tracked_cells(bad_cells_temp_map(bad_cells)) = 0;
    tracked_cells_b(tf(bad_cells_temp_map(bad_cells))) = 0;
    
    %Move untracked cells by mean displacement and track again
    a(1, not_tracked_reg) = a(1, not_tracked_reg) - mean_dis_vec(1);
    a(2, not_tracked_reg) = a(2, not_tracked_reg) - mean_dis_vec(2);
end
%limit reg_cell to untracked cells
% new_reg_cells = reg_cells(~tracked_cells, :);

%Iterate with shifted locations.
if num_iter > 0 && any(~tracked_cells) && any(~tracked_cells_b) && dis_not_zero
    b_missing_cells = true(1, length(tb));
    b_missing_cells(tf(tracked_cells)) = 0;
    tf2 = iterative_tracking(a(:, ~tracked_cells), b(:, b_missing_cells), num_iter - 1, radius, thresh, reg_cells(~tracked_cells, :));
    tf2_temp_map = [0 find(b_missing_cells)];
    tf(~tracked_cells) = tf2_temp_map(tf2 + 1);
end

