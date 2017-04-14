frm_num = orbit(1);
nodes = find(data.nodes.selected(1,:));
node_cells = zeros(10*length(nodes), 5);
num_global_nodes = 0;
nodelist = zeros(10*length(nodes), max(orbit));

for j = 1:length(orbit)
    frm_num = orbit(j);
    geom = seq.frames(frm_num).cellgeom;

    covered_nodes = false(length(geom.nodes(:,1)), 1);
    for global_node = 1:num_global_nodes
        cells = nonzeros(node_cells(global_node, :));
        cells = nonzeros(seq.cells_map(frm_num, cells));
        if length(cells) > 2
            faces = seq.frames(frm_num).cellgeom.faces(cells, :);
            local_node = intersect(faces(1, :), faces(2, :), 'legacy');
            for i = 3:length(cells)
                if isempty(local_node)
                    break
                end
                local_node = intersect(local_node, faces(i, :), 'legacy');
            end
            if length(local_node) > 1
                disp('Cells share more than one node!')
                disp(sprintf('Frame: %d \t cells: ', frm_num))
                disp(cells)
            end
            if length(local_node) == 1
                covered_nodes(local_node) = 1;
                nodelist(global_node, frm_num) = local_node;
            end
        end
    end

    nodes = find(data.nodes.selected(frm_num,:));
    for local_node = nodes
        if ~covered_nodes(local_node)
            num_global_nodes = num_global_nodes + 1;
            global_node = num_global_nodes;
            cells = geom.nodecellmap(geom.nodecellmap(:, 2) == local_node, 1);
            node_cells(global_node, 1:length(cells)) = ...
                seq.inv_cells_map(frm_num, cells);
            nodelist(global_node, frm_num) = local_node;
        end
    end
end
nodelist = nodelist(1:num_global_nodes, :);
for j = (length(orbit)-1):-1:1
    frm_num = orbit(j);
    geom = seq.frames(frm_num).cellgeom;
    for global_node = ...
            find(any(nodelist(:, frm_num + 1:end), 2) & nodelist(:, frm_num) == 0)'
        cells = nonzeros(node_cells(global_node, :));
        cells = nonzeros(seq.cells_map(frm_num, cells));
        if length(cells) > 2
            faces = seq.frames(frm_num).cellgeom.faces(cells, :);
            local_node = intersect(faces(1, :), faces(2, :), 'legacy');
            for i = 3:length(cells)
                if isempty(local_node)
                    break
                end
                local_node = intersect(local_node, faces(i, :), 'legacy');
            end
            if length(local_node) > 1
                disp('Cells share more than one node!')
                disp(sprintf('Frame: %d \t cells: ', frm_num))
                disp(cells)
            end
            if length(local_node) == 1
                nodelist(global_node, frm_num) = local_node;
            end
        end
    end
end

nodelist2 = nodelist;
%% a 4 folded to a higher folded transition (or vice versa) is missed
%% above. taken care of below.
for j = 1:(length(orbit)-1)
    frm_num = orbit(j);
    geom = seq.frames(frm_num).cellgeom;
    for node = find(data.nodes.mult(frm_num, :) >= 4)
        cells = geom.nodecellmap(geom.nodecellmap(:, 2) == node, 1);
        cells = seq.inv_cells_map(frm_num, cells);
        geom2 = seq.frames(frm_num+1).cellgeom;
        should_break = false;
        for node2 = find(data.nodes.mult(frm_num+1, :) > 4)
            cells2 = geom2.nodecellmap(geom2.nodecellmap(:, 2) == node2, 1);
            cells2 = seq.inv_cells_map(frm_num+1, cells2);
            if length(intersect(cells, cells2, 'legacy')) > 2
                if ~any(nodelist(:, frm_num) == node & ...
                        nodelist(:, frm_num+1) == node2)
                    nodelist(end+1, frm_num) = node;
                    nodelist(end, frm_num+1) = node2;
                    should_break = true;
                    break
                end
            end
        end
        if should_break
            continue
        end
    end
end

for j = 1:(length(orbit)-1)
    frm_num = orbit(j);
    geom = seq.frames(frm_num).cellgeom;
    for node = find(data.nodes.mult(frm_num, :) > 4)
        cells = geom.nodecellmap(geom.nodecellmap(:, 2) == node, 1);
        cells = seq.inv_cells_map(frm_num, cells);
        geom2 = seq.frames(frm_num+1).cellgeom;
        for node2 = find(data.nodes.mult(frm_num+1, :) >= 4)
            cells2 = geom2.nodecellmap(geom2.nodecellmap(:, 2) == node2, 1);
            cells2 = seq.inv_cells_map(frm_num+1, cells2);
            should_break = false;
            if length(intersect(cells, cells2, 'legacy')) > 2
                if ~any(nodelist(:, frm_num) == node & ...
                        nodelist(:, frm_num+1) == node2)
                    nodelist(end+1, frm_num) = node;
                    nodelist(end, frm_num+1) = node2;
                    should_break = true;
                    break
                end
            end
        end
        if should_break
            continue
        end
    end
end

node_mult = nodelist;
for j = 1:length(orbit)
    frm_num = orbit(j);
    node_mult(find(nodelist(:, frm_num)), frm_num) = ...
        data.nodes.mult(frm_num, nonzeros(nodelist(:, frm_num)));
end

%Some edges shrink transiently and resolves back. ignore these new nodes.
clear d
edges = false(1, length(seq.edges_map(1,:)));
for edge = 1:length(seq.edges_map(1,:))
    a = find(seq.edges_map(:, edge) == 0);
    b = find(diff(a) > 20);
    c = find(diff(b) == 1);
    d(edge).time_points = [];
    if length(a) == 1
        d(edge).time_points = 1;
    elseif ~isempty(a)
        if a(1) > 20 && a(2) > a(1) + 20
            d(edge).time_points = a(1);
        end
    	if ~isempty(c)
            d(edge).time_points = [d(edge).time_points (a(b(c) + 1))];
            edges(edge) = true;
        end
        if a(end) < length(seq.edges_map(:, 1)) && a(end-1) < a(end) - 20
            d(edge).time_points = [d(edge).time_points a(end)];
        end
    end
end
for edge = find(edges)
    l_edge = seq.edges_map(20, edge);
    cells = seq.frames(20).cellgeom.edgecellmap(...
        seq.frames(20).cellgeom.edgecellmap(: ,2) == l_edge, 1);
    if all(cells < length(seq.inv_cells_map(1,:)))
        g_cells = seq.inv_cells_map(20, cells);
        for i = d(edge).time_points;
            cells = full(seq.cells_map(i, g_cells));
            if length(nonzeros(cells)) ~= 2
                break
            end
            faces = seq.frames(i).cellgeom.faces(cells, :);
            local_node = intersect(faces(1, :), faces(2, :), 'legacy');
            if ~isempty(local_node) && length(local_node) == 1
                g_nodes = nodelist(:, i) == local_node;
                nodelist(g_nodes, i) = 0;
                node_mult(g_nodes, i) = 0;
            end
        end
    end
end

return




for j = 1:(length(orbit)-1)
    frm_num = orbit(j);
    next_geom = seq.frames(orbit(j+1)).cellgeom;;
    geom = seq.frames(frm_num).cellgeom;
    missing_nodes = setdiff(find(data.nodes.selected(frm_num,:)), nodelist(:, frm_num));
    nodelist(last_node+1:last_node+length(missing_nodes), frm_num) = missing_nodes;
    last_node = last_node+length(missing_nodes);
    nodes = nodelist(:, frm_num);
    temp_node_list = zeros(length(next_geom.nodes(:, 1)), 2); %[node_dist num_edges]
    inv_node_list = zeros(length(next_geom.nodes(:, 1)), 2);
%    temp_temp_node_list = temp_node_list;
    for i = find(nodes)'
        node = nodes(i);
        e = find(geom.edges(:,1) == node | geom.edges(:, 2) == node);
        e = e(seq.inv_edges_map(frm_num, e) > 0);
        [e_lengths, idx] = sort(geom.edges_length(e), 'descend');
        new_edge = full(seq.edges_map(frm_num+1, seq.inv_edges_map(frm_num, e(idx))));
        %new_edge = new_edge(find(new_edge, 1));
        temp_node_list(:) = 0;
        for e_e = find(new_edge)
            [n_dist, idx] = min(sum(([geom.nodes(node, :); geom.nodes(node, :)]...
                - next_geom.nodes(next_geom.edges(new_edge(e_e), :), :)).^2, 2));
            temp_node_list(next_geom.edges(new_edge(e_e), idx), :) = ...
                temp_node_list(next_geom.edges(new_edge(e_e), idx), :) + ...
                [n_dist 1];  
        end
        cand_nodes = reshape(next_geom.edges(nonzeros(new_edge), :), [], 1);
        ind = ...
            temp_node_list(cand_nodes, 2) == max(temp_node_list(cand_nodes, 2));
        cand_nodes = cand_nodes(ind);
        [dummy idx] = min(temp_node_list(cand_nodes, 1));
        if ~isempty(idx) && (~inv_node_list(cand_nodes(idx)) || (inv_node_list(cand_nodes(idx)) > i))
            inv_node_list(cand_nodes(idx)) = i;
            nodelist(i, orbit(j+1)) = cand_nodes(idx);
        end
        
%         ind = (temp_temp_node_list(:, 2) > temp_node_list(:, 2)) | ...
%             (temp_temp_node_list(:, 2) == temp_node_list(:, 2) & ...
%             temp_temp_node_list(:, 1) > temp_node_list(:, 1));
%         temp_node_list(ind, :) = temp_temp_node_list(ind, :);

    end
end
nodelist = nodelist(1:last_node, :);        
