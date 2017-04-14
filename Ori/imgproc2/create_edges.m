function cellgeom = create_edges(circles, mask, workingarea, min_area, factor, shift_y, shift_x, only_3x3)
%This function builds the geomtery and returns it in cellgeom. The geometry
%is built according to the BW image, mask, and is limited to workingarea.
%mask is expected to have white pixels for the boundaries of cells.
%The boundary is assumed to be one pixel wide and, as much as possible, 
%composing a single component (in the %8-connected object sense). The 
%function identifies corners by searching for pixels neighboring 3 
%different cells (3 different connected components in the negative image). 
%It then orders the corners of each cell according to its phase angle 
%relative to the cell's center and later on builds the edges based on that.
%Before building the edges the function tries to correct errors that might
%rise in producing and analyzing the BW image, mask. Small cells (as 
%determined by min_area) with only one or two corners are removed 
%(update_mask_first_phase). Small cells with 3 or more corners are merged 
%with a neighboring cell (update_mask_second_phase). Cells that have more 
%than one circle in them are divided into two cells 
%(update_mask_first_phase). 
%
%The structure of cellgeom is:
%   cellgeom.nodes = (:,2) = [y x] of each node
%   cellgeom.nodecellmap = (:,2) = [cell node] a list of all the nodes of
%   each cell. It is sorted by cell and then by node phase angle relative
%   to the cell center.
%   cellgeom.edges = (:,2) = [node1 node2] list of all edges by specifiying
%   the end nodes. node2 is always greater than node1.
%   cellgeom.edgecellmap  = (:,2) = [cell egde] a list of all edges of each
%   cell

%   cellgeom.circles = (:,3) = [y x radius] where x and y are the
%   coordinated of the circle center and radius is its radius. Right now
%   radius is arbitrarly set to 2. THIS IS DIFFERENT FROM THE INPUT CIRCLES
%   and is used later on to list all the cells.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% cellgeom.circles(:,3) is no longer used only the x and y are kept %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   cellgeom.border_cells = logical(number_of_cells) = true if the cell is
%   on the border.
%   cellgeom.border_nodes = a one dimensional vector listing all the border
%   nodes.
  
if nargin < 8 || isempty(only_3x3)
    only_3x3 = false;
end
max_area = 20000;

circles = double(circles);
cells_objects = [];
cells_centroids = [];
cells_areas = [];
nodes_objects = [];
nodes_centroids = [];
nodes_cells = [];
nodes = [];
cells_bbox = [];

workingarea(:,1) = workingarea(:,1) - shift_y + 1;
workingarea(:,2) = workingarea(:,2) - shift_x + 1;
circles(:,1) = circles(:,1) - shift_y + 1;
circles(:,2) = circles(:,2) - shift_x + 1;

%limit everything to a rectangle bounding the workingarea and make sure we
%are at least 2 pixels away from the image boundaries so we will be able to find 
%all the corner pixels.

[m n] = size(mask);
top = max(min(floor(workingarea(:,1))), 3);
left = max(min(floor(workingarea(:,2))), 3);
bottom = min(max(ceil(workingarea(:,1))), m - 2);
right = min(max(ceil(workingarea(:,2))), n - 2);

crop_t = max(min(floor(workingarea(:,1))), 1);
crop_l = max(min(floor(workingarea(:,2))), 1);
crop_b = min(max(ceil(workingarea(:,1))), m);
crop_r = min(max(ceil(workingarea(:,2))), n);
    
max_radius = max(circles(:,3));

%create a binary image of the working area and of its boundary.   
    polymask = bwmorph(poly2mask(workingarea(:,2), workingarea(:,1), m, n), 'dilate')    ;
    temp = bwmorph(polymask, 'erode');
    working_area_boundary = polymask & ~temp;
    working_area_inner_boundary = temp & ~(bwmorph(temp, 'erode', 1));

%make a list of all the pixels within the working area that are white in
%the mask image (that is, pixels at boundaries of cells). Do the same  
%with the working area boundary 
    WA_indices = find(polymask(top: bottom, left:right) & mask(top: bottom, left:right));
    [ind_y, ind_x] = ind2sub([bottom - top + 1, right - left + 1], WA_indices);
    WA_indices = sub2ind([m n], ind_y + top -1, ind_x + left -1);
    WAIB_indices = find(working_area_inner_boundary & mask);
    
    do_nodes;
    toc
    update_mask_first_phase;
    toc
    do_nodes;
    toc
    update_mask_second_phase;
    toc
    do_nodes;
    toc
    update_mask_second_phase;
    toc
    do_nodes;
    toc
    
    border_nodes = unique([nodes_perimeter(working_area_inner_boundary);  nodes_perimeter(working_area_boundary)], 'legacy');
    border_cells = unique([cells_objects(1:5,1:n) cells_objects(m-4:m,1:n) cells_objects(1:m,1:5)' cells_objects(1:m,n-4:n)'], 'legacy');
    border_cells = union(border_cells, nodes_cells(ismember(nodes_cells(:,2), border_nodes, 'legacy'), 1), 'legacy');    
    border_nodes = setdiff(border_nodes, 0, 'legacy');
    border_cells = setdiff(border_cells, 0, 'legacy');
    
    %Changes below might need to be copied in update_edgecellmap.m
    
    %remove cells whose center is not inside the cell
    huge_cells = cells_areas > max_area;
    central_cells = cells_objects(sub2ind(size(cells_objects), ...
        round(cells_centroids(:, 2)), round(cells_centroids(:,1)))) ...
        == [1:length(cells_centroids(:,1))]';
    cells2keep = ~huge_cells & central_cells;
    
    cells_centroids = cells_centroids(cells2keep,:);
    a = find(cells2keep);
    b = zeros(1, length(cells2keep));
    b(a) = 1:length(a);
    border_cells = nonzeros(b(border_cells));
    
    nodes_cells = nodes_cells(ismember(nodes_cells(:,1), a, 'legacy'), :);
    nodes_cells(:,1) = b(nodes_cells(:,1));
    
    %%%% mark cells with less than 3 nodes as invalid
    zero_cells = setdiff(1:length(cells_centroids(:,1)), nodes_cells(:,1), 'legacy');
    [n_c_unique, n_c, dummy2] = unique(nodes_cells(:,1), 'legacy');
    n_c_s = [0 n_c(1:end - 1)'];
    ugly_cells = ((n_c - n_c_s') < 3) & ((n_c - n_c_s') > 0);
    ugly_cells = n_c_unique(ugly_cells);

    
    
    valid = true(1,length(cells_centroids(:,1)));
    valid(zero_cells) = 0;
    valid(ugly_cells) = 0;
    
    temp_mapping = cumsum(valid);
    temp_mapping(~valid) = 0;
    cells_centroids = cells_centroids(valid, :);
    border_cells = nonzeros(temp_mapping(border_cells));
    nodes_cells(:,1) = temp_mapping(nodes_cells(:,1));
    nodes_cells = nodes_cells(find(nodes_cells(:,1)), :);
    cellgeom.valid = true(1, length(cells_centroids(:,1)));

    %%% remove invalid nodes if they still exist
    missing_nodes = setdiff(1:length(nodes_centroids), nodes_cells(:,2), 'legacy');
    valid = true(1, length(nodes_centroids));
    valid(missing_nodes) = 0;
    temp_mapping = cumsum(valid);
    temp_mapping(~valid) = 0;
    nodes_centroids = nodes_centroids(valid, :);
    nodes_cells(:,2) = temp_mapping(nodes_cells(:,2));
    %The next line is not necessary because we marked nodes to be invalid
    %only if they're not listed in nodes_cells.
    
    %nodes_cells = nodes_cells(find(nodes_cells(:,2)), :);
    
    temp_mapping(end +1 : max(border_nodes)) = 0;
    border_nodes = nonzeros(temp_mapping(border_nodes));
   

    cellgeom.nodes = single(circshift(nodes_centroids, [0 1]));
    cellgeom.nodecellmap = int16(nodes_cells(:,1:2));
    [cellgeom.edges, all_edges] = create_edgecellmap(nodes_cells(:,1:2));
    cellgeom.circles = single([cells_centroids(:,2), cells_centroids(:,1)]);
    cellgeom.border_cells = int16(border_cells);
    cellgeom.border_nodes = int16(border_nodes);
    cellgeom.edges_length = single(realsqrt(sum(...
        (cellgeom.nodes(cellgeom.edges(:,1),:) - ...
         cellgeom.nodes(cellgeom.edges(:,2),:)).^2')));
     

    cellgeom.nodes(:, 2) = cellgeom.nodes(:, 2) + single(shift_x - 1) ;
    cellgeom.nodes(:, 1) = cellgeom.nodes(:, 1) + single(shift_y - 1);
    cellgeom.circles(:, 1) = cellgeom.circles(:, 1) + single(shift_y - 1);  
    cellgeom.circles(:, 2) = cellgeom.circles(:, 2) + single(shift_x - 1);  

    
%%%%%%%%%%%%%%%%% Try to automate the associate node with a cell fix %%%%%%
% Can circumvent this by using strel('square', 4) or strel('diamond', 2) 
% when finding which cells each node is a part of in do_nodes below, but
% that introduces some other problems with boundary nodes. UPDATE: I managed
% to do what I described above by limiting it to interior nodes almost
% exclusively. However, there are still some cases when a node is not
% properly associated with a cell.

%     all_edges = [all_edges ; circshift(all_edges, [0 1])];
%     all_edges = all_edges(all_edges(:, 1) <= all_edges(:,2), :);
%     all_edges = sortrows(all_edges);
%     [edges, ind, dummy] = unique(all_edges, 'rows');
%     ind = ind';
%     singles = find(ind - [0 ind(1:end - 1)] == 1);
%     int_singles = ~ismember(edges(singles, 1), border_nodes) & ...
%         ~ismember(edges(singles, 2), border_nodes);
%     singles = [edges(singles(int_singles), 1), edges(singles(int_singles),2)];

    %Find the node which is between the two ends of the edge and is not
    %associated with the cell.
    %Associate the node with the cell
    %cellgeom = associate(cellgeom, cell, node)
    %keep a list of affected nodes and cells in order to detrmine if all
    %corrections can be done in single round.
%%%%%%%%%%%%%%%%%%%%%%    
    toc

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function do_nodes
        cells_objects = bwlabel(~mask & polymask, 4) ;
        s  = regionprops(cells_objects, {'centroid', 'area', 'boundingbox'});
        cells_centroids = cat(1, s.Centroid);
        cells_areas = cat(1, s.Area);
        cells_bbox = cat(1, s.BoundingBox);
        cells_bbox = ceil(cells_bbox);
        cells_bbox(:,3:4) = cells_bbox(:,1:2) + cells_bbox(:,3:4);

        
        %find the corner pixels (= nodes).
        if only_3x3
            nodes = corners(mask, [], [WA_indices; WAIB_indices]);
        else
            nodes = corners(mask, WA_indices, WAIB_indices);
        end
        %add white pixels on boundary to the node list
        [x y] = find(working_area_boundary);
        nodes(working_area_boundary) = mask(working_area_boundary) | ...
            any(mask(sub2ind([m n], [max(1, x-1) min(m, x+1) x x], ...
            [y y max(1, y-1), min(n, y+1)])), 2);

        
        nodes_objects = bwlabel(nodes);
        s  = regionprops(nodes_objects, 'centroid');
        %DLF MOD/IMPROVMENT: Removes anomalous nodes that cause segmentation to
        %go haywire
        %2015 July 29
        bb_temp = regionprops(nodes_objects, 'boundingBox');
        bb_temp = {bb_temp(:).BoundingBox};
        bb_temp = cell2mat(bb_temp');
        badnodes = find([bb_temp(:,3)]>30|bb_temp(:,4)>30);
        s(badnodes) = [];
        for i = 1:length(badnodes)
            nodes(nodes_objects==badnodes(i))=0;
        end
        nodes_objects = bwlabel(nodes);
        %-------- End DLF MOD/IMPROVMENT ----------------------
        
        nodes_centroids = cat(1, s.Centroid);

        %find which cells each node is a part of

%         nodes_perimeter1 = imdilate(nodes_objects .* working_area_boundary, strel('square', 3)) .* ~~(cells_objects);
%         nodes_perimeter2 = imdilate(nodes_objects .* ~working_area_boundary, strel('disk', 2)) .* ~~(cells_objects);
%         nodes_perimeter = nodes_perimeter1 + nodes_perimeter2;
%         nodes_perimeter(nodes_perimeter1 & nodes_perimeter2) = nodes_perimeter2(nodes_perimeter1 & nodes_perimeter2);
        
        nodes_perimeter = imdilate(nodes_objects, strel('square', 3)) .* ~~(cells_objects);
        nodes_on_border = unique(nonzeros(...
            nodes_perimeter(working_area_inner_boundary | working_area_boundary)), 'legacy');
        ind = find(nodes_perimeter);

        
        [dummy1,unique_ind, dummy2] = unique([nodes_perimeter(ind) cells_objects(ind)], 'rows', 'legacy');

%REMOVE NODES WHICH ARE NOT ON THE BOUNDARY BUT CONNECT ONLY TWO CELLS.
%this is way too messy
%ind(unique_ind) is sorted according to node at this stage.

        true_ind = true(1,length(unique_ind));
        [dummy1, ind_nodes, dummy2] = unique(nodes_perimeter(ind(unique_ind)), 'legacy');
        dummy1 = circshift(ind_nodes, 1);
        dummy1(1) = 0;
        false_ind = ((ind_nodes - dummy1) < 3) & ~ismember(nodes_perimeter(ind(unique_ind(ind_nodes))),nodes_on_border, 'legacy');
        false_ind = find(false_ind);
        for i =1:length(false_ind)
            true_ind(dummy1(false_ind(i)) +1: ind_nodes(false_ind(i))) = 0;
        end

       
        unique_ind = unique_ind(true_ind);

        
        
        
        



%find the phase angle of each node relative to the cell center.
        nodes_vectors = nodes_centroids(nodes_perimeter(ind(unique_ind)), :)...
            -cells_centroids(cells_objects(ind(unique_ind)), :);
        angles = atan2(nodes_vectors(:,1), nodes_vectors(:,2));

% sort the nodes cells list according to cell and then according the node 
%phase angle

        nodes_cells = sortrows(...
            [cells_objects(ind(unique_ind))...
            nodes_perimeter(ind(unique_ind))...
            cells_centroids(cells_objects(ind(unique_ind)), :) ...
            nodes_centroids(nodes_perimeter(ind(unique_ind)), :)...
            angles ], [1 7]);
   
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function update_mask_second_phase
        function remove_boundary(cells)
        %updated the mask by deleting the boundary between the two cells lisetd in cells
            first_cell = find(cells_objects == cells(1));
            second_cell= find(cells_objects == cells(2));

            first_cell_dilated = [first_cell + 1; first_cell - 1];
            second_cell_dilated = [second_cell + 1; second_cell - 1];
            mask(intersect(first_cell_dilated, second_cell_dilated, 'legacy')) = 0;

            first_cell_dilated = [first_cell + m; first_cell - m];
            second_cell_dilated = [second_cell + m; second_cell - m];        
            mask(intersect(first_cell_dilated, second_cell_dilated, 'legacy')) = 0;
        end
        
        %find all the small cells.
        spurious_cells = find(cells_areas < min_area);
        
        % remove cells touching the boundary from the spurious cells list.
        boundary_cells = [cells_objects(working_area_boundary); cells_objects(working_area_inner_boundary)];
        spurious_cells = setdiff(spurious_cells, boundary_cells, 'legacy'); 
        old_mask = mask;
        for i =1:length(spurious_cells)
            %%% DEBUG DLF
            %%% use 'exter_display...' to inspect the process of removing
            %%% small cells
%             extern_display_removal_of_small_cell(nodes_cells,spurious_cells(i),mask);
            
            %How many nodes does the spurious cell have? if more than 2
            %then remove the cell by merging it with neighbor cell. Choose
            %the neighobr to merge with in such a way that the angle
            %distortion (before and after the merge) will be minimal.
            current_nodes_list = nodes_cells(find(nodes_cells(:,1) == spurious_cells(i)), 2);
            if length(current_nodes_list) > 2
                outer_angles = ones(1,length(current_nodes_list));
                second_node_list = circshift(current_nodes_list,1);
%                 third_node_list = circshift(current_nodes_list,2);
%                 zero_node_list = circshift(current_nodes_list,-1);
 
                for j=1:length(current_nodes_list)
                    other_cell = intersect(...
                        nodes_cells(find(nodes_cells(:,2) == current_nodes_list(j)), 1), ...
                        nodes_cells(find(nodes_cells(:,2) == second_node_list(j)), 1), 'legacy');
                    other_cell = setdiff(other_cell, spurious_cells(i), 'legacy');
                    all_extra_cells_node1 = setdiff(nodes_cells(find(nodes_cells(:,2) == current_nodes_list(j)), 1),[other_cell;spurious_cells(i)],'legacy');
                    all_extra_cells_node2 = setdiff(nodes_cells(find(nodes_cells(:,2) == second_node_list(j)), 1),[other_cell;spurious_cells(i)],'legacy');

                    if length(other_cell) ~= 1
                        disp('warning: failed to find an adjacent cell in update_mask_second_phase');
                        fprintf('cell center is at %g %g\n', cells_centroids(spurious_cells(i), 1:2));
                        outer_angles(j) = 0;
                    else
                        %%% Old way of calculating angles
%                         ang1 = find_node_angle(current_nodes_list(j), spurious_cells(i), nodes_cells) - ...
%                             find_node_angle(current_nodes_list(j), other_cell, nodes_cells);
%                         
%                         ang2 = find_node_angle(second_node_list(j), spurious_cells(i), nodes_cells) - ...
%                             find_node_angle(second_node_list(j), other_cell, nodes_cells);
                        
%                         ang1 = min(abs([ang1 pi - ang1]));
%                         ang2 = min(abs([ang2 pi - ang2]));
                        
                        %%%DLF MOD
                        ang1 = find_node_angle(current_nodes_list(j), spurious_cells(i), nodes_cells) + ...
                            find_node_angle(current_nodes_list(j), other_cell, nodes_cells);
                        
                        ang2 = find_node_angle(second_node_list(j), spurious_cells(i), nodes_cells) + ...
                            find_node_angle(second_node_list(j), other_cell, nodes_cells);
                        
                        ang1 = min(abs([ang1 pi - ang1]));
                        ang2 = min(abs([ang2 pi - ang2]));
                        
                        ang1_alts = find_node_angle(current_nodes_list(j), spurious_cells(i), nodes_cells);
                        if length(all_extra_cells_node1)>1
                            display('higher order vertex1');
                            for ii = 1:length(all_extra_cells_node1)
                                new_ang =find_node_angle(current_nodes_list(j), all_extra_cells_node1(ii), nodes_cells);
                                new_ang = min(abs([new_ang pi - new_ang]));
                                ang1_alts = [ang1_alts,new_ang];
                            end
                            ang1_reverse_alts = ang1 + cumsum(ang1_alts(end:-1:1));
                            ang1_alts = cumsum(ang1_alts);
                            ang1_alt = min(abs([ang1_alts, (pi - ang1_alts)]));
                            ang1_alt = min([ang1_alt,abs([ang1_reverse_alts, (pi - ang1_reverse_alts)])]);
                            ang1 = ang1_alt;
                        end
                        
                        
                        ang2_alts = [];
                        if length(all_extra_cells_node2)>1
                            display('higher order vertex2');
                            for ii = 1:length(all_extra_cells_node2)
                                new_ang =find_node_angle(second_node_list(j), all_extra_cells_node2(ii), nodes_cells);
                                new_ang = min(abs([new_ang pi - new_ang]));
                                ang2_alts = [ang2_alts,new_ang];
                            end
                            ang2_alts = cumsum(ang2_alts);
                            ang2_alt = min(abs([ang2_alts, (pi - ang2_alts)]));
                            ang2 = ang2_alt;
                        end
                        outer_angles(j) = ang1 + ang2;

                        
                    end
                end
                [dummy1 nodes_to_remove] = min(outer_angles);
                cells_1 = nodes_cells(find(nodes_cells(:,2) == current_nodes_list(nodes_to_remove)), 1);
                cells_2 = nodes_cells(find(nodes_cells(:,2) == second_node_list(nodes_to_remove)), 1);                
                if length(intersect(cells_1, cells_2, 'legacy')) == 2
                    remove_boundary(intersect(cells_1, cells_2, 'legacy'));
                end
            end

        end
    end

    function update_mask_first_phase
        
        %Make a list of cells with only one node and a list of cells with
        %only 2 nodes. 
        boundary_cells = [cells_objects(working_area_boundary); cells_objects(working_area_inner_boundary)];
        
        [n_c_unique, n_c, dummy2] = unique(nodes_cells(:,1), 'legacy');
        n_c_s = [0 n_c(1:end - 1)'];
        cells1 = (n_c - n_c_s') == 1;
        cells1 = n_c_unique(cells1);
        cells1 = setdiff(cells1, boundary_cells, 'legacy');
        cells2 = (n_c - n_c_s') == 2;
        cells2 = n_c_unique(cells2);
        cells2 = setdiff(cells2, boundary_cells, 'legacy');        
        
        old_mask = mask;     
        
        for i = 1:length(cells2)
            %remove surrouning boundary from mask and add a line
            %connecting the two nodes.
            li = cells_bbox(cells2(i), 1);
            ti = cells_bbox(cells2(i), 2);
            ri = cells_bbox(cells2(i), 3);
            bi = cells_bbox(cells2(i), 4);

            current_nodes_list = nodes_cells(find(nodes_cells(:,1) == cells2(i)), 2);
            mask(ti:bi,li:ri) = mask(ti:bi,li:ri) & ~imdilate(cells_objects(ti:bi,li:ri) == cells2(i), strel('square', 3));
            pt1 = double(round(nodes_centroids(current_nodes_list(1), 2:-1:1)));
            pt2 = double(round(nodes_centroids(current_nodes_list(2), 2:-1:1)));
            
            if pt1(1) == pt2(1) && pt1(2) == pt2(2)
                %for the rare cases where one node encircles the other node
                %and their rounded centroids overlap                
                
            else
                new_pt2 = ((pt2 - pt1) * 2) + pt1;
                pt1 = ((pt1 - pt2) * 2) + pt2;
                pt2 = new_pt2;
                new_line = connect_line(pt1, pt2);
                new_line(1,:) = min(max(new_line(1,:), 1), m);
                new_line(2,:) = min(max(new_line(2,:), 1), n);
                new_line = sub2ind(size(mask), new_line(1,:), new_line(2,:));
                mask(new_line(cells_objects(new_line) == cells2(i) | old_mask(new_line) == 1)) = 1;
            end
        end
        

        for i =1:length(cells1)
            li = cells_bbox(cells1(i), 1);
            ti = cells_bbox(cells1(i), 2);
            ri = cells_bbox(cells1(i), 3);
            bi = cells_bbox(cells1(i), 4);
            
            current_nodes_list = nodes_cells(find(nodes_cells(:,1) == cells1(i), 1), 2);
            %remove surrouning boundary from mask and add a line
            %from the single node through where the cell object
            %centroid was located.
            mask(ti:bi,li:ri) = mask(ti:bi,li:ri) & ~imdilate(cells_objects(ti:bi,li:ri) == cells1(i), strel('square', 3));
            pt1 = double(round(nodes_centroids(current_nodes_list, 2:-1:1)));
            pt2 = double(round(cells_centroids(i, :)));
            if pt1(1) == pt2(1) && pt1(2) == pt2(2)
                %for the rare cases where the overlaps with the cell's
                %centroid
                
            else
            %I assume the cell is
            %at most 4 times as big as the distance between
            %the node the centroid.
                new_pt2 = ((pt2 - pt1) * 2) + pt1;
                pt1 = ((pt1 - pt2) * 2) + pt2;
                pt2 = new_pt2;
                new_line = connect_line(pt1, pt2);
                new_line(1,:) = min(max(new_line(1,:), 1), m);
                new_line(2,:) = min(max(new_line(2,:), 1), n);
                new_line = sub2ind(size(mask), new_line(1,:), new_line(2,:));
                mask(new_line(cells_objects(new_line) == cells1(i) | old_mask(new_line) == 1)) = 1;
            end
        end

        %remove from mask the surrounding boundary of cells with no nodes 
        zero_cells = setdiff(1:length(cells_centroids(:,1)), nodes_cells(:,1), 'legacy');
        mask = mask & ~imdilate(ismember(cells_objects, zero_cells, 'legacy'), strel('square', 3));
        mask = bwmorph(mask, 'bridge');
        
        % Add a line to the mask image if there are two circles within the
        % cell object. The case of more than 2 circles in a single cell
        % object is not handled.        
        circles_cells = cells_objects(sub2ind(size(cells_objects), circles(:,1), circles(:,2)));
        for i =1:length(cells_areas)
            circles_in_current_cell = find(circles_cells == i);
            if length(circles_in_current_cell) > 1
                %draw a line between the two circles centers
                pt1 = double(circles(circles_in_current_cell(1), 1:2));
                pt2 = double(circles(circles_in_current_cell(2), 1:2));
                new_pt2 = ((pt2 - pt1) * 4) + pt1;
                pt1 = ((pt1 - pt2) * 4) + pt2;
                pt2 = new_pt2;
                new_line = connect_line(pt1, pt2);
                
                %rotate the line by 90 degree around its center
                new_line(1,:) = new_line(1,:) - round((pt1(1) + pt2(1))/2);
                new_line(2,:) = new_line(2,:) - round((pt1(2) + pt2(2))/2);
                new_line = circshift(new_line, 1);
                new_line(1,:) = -new_line(1,:);
                new_line(1,:) = min(max(new_line(1,:) + round((pt1(1) + pt2(1))/2), 1), m);
                new_line(2,:) = min(max(new_line(2,:) + round((pt1(2) + pt2(2))/2), 1), n);
                
                
                %add the line to the mask image
                new_line = sub2ind(size(mask), new_line(1,:), new_line(2,:));
                mask(new_line(cells_objects(new_line) == i)) = 1;
            end
        end
                
        %Make sure there are no holes, thick boundaries and spur egdes in mask image 

%        mask = bwmorph(mask, 'close');
%       in create_edges.m top bottom left and right are three pixels inside
%       the bounding box of the working area. We need to skel and spur the
%       whole cropped image
        mask(crop_t: crop_b, crop_l:crop_r) = mask(crop_t: crop_b, crop_l:crop_r) | nodes(crop_t: crop_b, crop_l:crop_r);
        mask(crop_t: crop_b, crop_l:crop_r) = ~bwareaopen(~mask(crop_t: crop_b, crop_l:crop_r), ceil(5 * (factor^2)), 4);    
        bndry_ind = [sub2ind(size(mask), crop_t:crop_b, crop_l * ones(1,crop_b - crop_t + 1))...
                     sub2ind(size(mask), crop_t:crop_b, crop_r * ones(1,crop_b - crop_t + 1))...
                     sub2ind(size(mask), crop_t * ones(1,crop_r - crop_l + 1), crop_l:crop_r)...
                     sub2ind(size(mask), crop_b * ones(1,crop_r - crop_l + 1), crop_l:crop_r)];
        bndry_val = mask(bndry_ind);
        mask(bndry_ind) = 1;
        mask(crop_t: crop_b, crop_l:crop_r) = bwmorph(mask(crop_t: crop_b, crop_l:crop_r), 'skel', 10);
        mask(crop_t: crop_b, crop_l:crop_r) = bwmorph(mask(crop_t: crop_b, crop_l:crop_r), 'spur', 10);        
        mask(crop_t: crop_b, crop_l:crop_r) = bwmorph(mask(crop_t: crop_b, crop_l:crop_r), 'skel', 10);
        mask(bndry_ind) = bndry_val;
        mask = bwmorph(mask, 'bridge');
        %%%%% not sure about the next couple of lines %%%%%
        mask(crop_t: crop_b, crop_l:crop_r) = ~bwareaopen(~mask(crop_t: crop_b, crop_l:crop_r), 3, 4);
        mask(crop_t: crop_b, crop_l:crop_r) = bwareaopen(mask(crop_t: crop_b, crop_l:crop_r), 5, 8);        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        WA_indices = find(polymask(top: bottom, left:right) & mask(top: bottom, left:right));
        [ind_y, ind_x] = ind2sub([bottom - top + 1, right - left + 1], WA_indices);
        WA_indices = sub2ind([m n], ind_y + top -1, ind_x + left -1);
                    
    end

end

function ang = find_node_angle(node, cell, nodes_cells)
%Returns the angle bewteen the two edges of cell meeting at node.
%Uses nodes_cells to find the egdes.

    nodes = nodes_cells(find(nodes_cells(:,1) == cell),:);
    nodes = circshift(nodes, 2 - find(nodes == node));
    if length(nodes(:,1)) < 3
        fprintf('warning: trying to find an internal angle in a 2-sided cell\n');
        ang = 0;
        return
    end
    vec1 = nodes(2, 5:6) - nodes(1, 5:6);
    vec2 = nodes(2, 5:6) - nodes(3, 5:6);
%     ang = subspace(vec1', vec2'); 
    ang = atan2(det([vec1',vec2']),dot(vec1',vec2'));
end

