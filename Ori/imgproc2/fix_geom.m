function cellgeom = fix_geom(cellgeom)


%Almost the same as in create_edges
if ~isfield(cellgeom, 'circles')
    cellgeom.circles = [1:max(cellgeom.nodecellmap(:, 1))]'; 
    cellgeom.circles = [cellgeom.circles cellgeom.circles cellgeom.circles];
end
cellgeom = full_edgecellmap(cellgeom);
cellgeom.edges_length = single(realsqrt(sum(...
        (cellgeom.nodes(cellgeom.edges(:,1),:) - ...
         cellgeom.nodes(cellgeom.edges(:,2),:)).^2')));
cellgeom = rmv_cells(cellgeom);
cellgeom = rmv_nodes(cellgeom);
cellgeom = full_edgecellmap(cellgeom);
cellgeom = rmv_cells(cellgeom);
cellgeom = full_edgecellmap(cellgeom);

[n_c_unique, n_c, dummy2] = unique(cellgeom.nodecellmap(:,1), 'legacy');
n_c_s = [0 n_c(1:end - 1)'];
faces = nan(length(n_c_unique), max(n_c - n_c_s'), 'single');
faces_for_area = zeros(size(faces));

for cnt = 1:length(cellgeom.circles(:, 1))
    nmap = cellgeom.nodecellmap((n_c_s(cnt) + 1):n_c(cnt),2);
    faces(cnt, 1:length(nmap)) = nmap;
    faces_for_area(cnt, 1:length(nmap)) = nmap;
    faces_for_area(cnt, length(nmap):end) = nmap(end);
end

cellgeom.faces = faces;


[pc_x pc_y area] = cellgeom2centroid(cellgeom, faces_for_area);
cellgeom.circles(:, 1) = pc_y;
cellgeom.circles(:, 2) = pc_x;
cellgeom.circles(:, 3) = 3;

new_map = new_edgecellmap(cellgeom);
border_cells = new_map(isnan(new_map(:, 2)), 1);
border_nodes = true(1, length(cellgeom.nodes));
cellgeom.border_cells = false(length(cellgeom.faces(:, 1)), 1);
cellgeom.border_cells(border_cells) = 1;
n = cellgeom.faces(~border_cells, :);
n= n(~isnan(n));
border_nodes(n) = false;
cellgeom.border_nodes = find(border_nodes);
cellgeom.edgecellmap = double(cellgeom.edgecellmap);

function cellgeom = rmv_cells(cellgeom)
    %%% remove double entries
    [b, m, n] = unique(cellgeom.nodecellmap, 'rows', 'legacy');
    cellgeom.nodecellmap = cellgeom.nodecellmap(sort(m), :);

    %%%% mark cells with less than 3 nodes as invalid
    zero_cells = setdiff(1:length(cellgeom.circles(:,1)), cellgeom.nodecellmap(:,1), 'legacy');
    [n_c_unique, n_c, dummy2] = unique(cellgeom.nodecellmap(:,1), 'legacy');
    n_c_s = [0 n_c(1:end - 1)'];
    ugly_cells = ((n_c - n_c_s') < 3) & ((n_c - n_c_s') > 0);
    ugly_cells = n_c_unique(ugly_cells);
    
    valid = true(1,length(cellgeom.circles(:,1)));
    valid(zero_cells) = 0;
    valid(ugly_cells) = 0;
    
    max_length = 150;
    subs = cellgeom.edgecellmap(:, 1);
    vals = cellgeom.edges_length(cellgeom.edgecellmap(:, 2)) > max_length;
    cells_with_long_edges = accumarray(subs, vals, [length(valid) 1], @(x) nnz(x)>0);
    cells_with_long_edges = cells_with_long_edges > 0;
    valid = valid & ~cells_with_long_edges';
    
    temp_mapping = cumsum(valid);
    temp_mapping(~valid) = 0;
    if length(cellgeom.circles) > length(temp_mapping)
        temp_mapping((end+1):length(cellgeom.circles)) = 0;
    end
    cellgeom.circles = cellgeom.circles(valid, :);


    
    if isfield(cellgeom, 'selected_cells')
        temp_select = cellgeom.selected_cells;
        cellgeom.selected_cells = false(1, length(cellgeom.circles(:,1)));
        cellgeom.selected_cells(nonzeros(temp_mapping(find(temp_select)))) = 1;
    else
        cellgeom.selected_cells = false(1, length(cellgeom.circles(:,1)));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cellgeom.nodecellmap(:,1) = temp_mapping(cellgeom.nodecellmap(:,1));
    cellgeom.nodecellmap = cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1)), :);
    cellgeom.valid = true(1, length(cellgeom.circles(:,1)));
%     if isfield(cellgeom, 'border_cells')
%         cellgeom.border_cells = int16(nonzeros(temp_mapping(cellgeom.border_cells)));
%     else

%        cellgeom.border_cells = false(1, length(cellgeom.circles(:, 1)));
%        cellgeom.border_cells(new_map(isnan(new_map(:, 2)) & ~ isnan(new_map(:, 1)), 1)) = true;
%     end
%     
function cellgeom = rmv_nodes(cellgeom);    
    %%% remove invalid nodes if they still exist %%%%%%%%%%%%%%%%%
    
    %%% nodes with no edges
    missing_nodes = setdiff(1:length(cellgeom.nodes(:,1)), cellgeom.nodecellmap(:,2), 'legacy');
    valid = true(1, length(cellgeom.nodes));
    valid(missing_nodes) = 0;
    
    %%% nodes connecting two cells (it's not enough to check for nodes with
    %%% only two edges because of border nodes)
    extra_nodes = [];
    s_by_n = sort(cellgeom.nodecellmap(:,2));
    [a b c] = unique(s_by_n, 'legacy');
    num_c_per_n(s_by_n(b)) = b - [0 ; b(1:end -1)];
    mult2_nodes = find(num_c_per_n == 2);
    for i = mult2_nodes
        edges = cellgeom.edges(:, 1) == i | cellgeom.edges(:, 2) == i;
%         cells = intersect(...
%             cellgeom.edgecellmap(cellgeom.edgecellmap(:,2) == edges(1), 1),...
%             cellgeom.edgecellmap(cellgeom.edgecellmap(:,2) == edges(2), 1));
        if sum(edges) == 2
            extra_nodes = [extra_nodes i];
        end
    end
    valid(extra_nodes) = 0;
    cellgeom.nodecellmap = cellgeom.nodecellmap(...
        ~ismember(cellgeom.nodecellmap(:,2), extra_nodes, 'legacy'), :);
    temp_mapping = cumsum(valid);
    cellgeom.nodes = cellgeom.nodes(valid, :);
    cellgeom.nodecellmap(:,2) = temp_mapping(cellgeom.nodecellmap(:,2));
    
    
%     if isfield(cellgeom, 'border_nodes') && ~isempty(cellgeom.border_nodes)
%         temp_mapping((end+1) : max(cellgeom.border_nodes)) = 0;
%         cellgeom.border_nodes = int16(nonzeros(temp_mapping(cellgeom.border_nodes)));
%     end