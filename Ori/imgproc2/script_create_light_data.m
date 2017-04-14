data.cells.selected = false(size(seq.cells_map));
data.cells.border = false(1, length(seq.cells_map(1,:)));
data.edges.selected = false(size(seq.edges_map));
data.edges.len = zeros(size(seq.edges_map));
data.edges.node = data.edges.len ;
data.edges.node2 = data.edges.len; 
for i =1:length(seq.cells_map(:, 1))
    geom = seq.frames(i).cellgeom;

    data.cells.selected(i, seq.inv_cells_map(i, find(geom.selected_cells))) = 1;
    new_map = new_edgecellmap(geom);
    data.cells.border(i, seq.inv_cells_map(i, new_map(isnan(new_map(:, 2)), 1))) = true;
    new_map = new_map(all(~isnan(new_map), 2), :);
    nmap = false(length(geom.circles(:,1)));
    nmap(sub2ind(size(nmap), new_map(:, 1), new_map(:, 2))) = 1;
    nmap = nmap | nmap';
    data.cells.border(i, seq.inv_cells_map(i, any(nmap(seq.cells_map(i, data.cells.border(i, :)), :)))) = 1;



    edges = geom.edgecellmap(ismember(geom.edgecellmap(:, 1), ...
        find(geom.selected_cells), 'legacy'), 2);
    data.edges.selected(i, nonzeros(seq.inv_edges_map(i, edges))) = true;
    data.edges.node(i, nonzeros(seq.inv_edges_map(i, :))) = ...
        geom.edges(find(seq.inv_edges_map(i, :)), 1);
    data.edges.node2(i, nonzeros(seq.inv_edges_map(i, :))) = ...
        geom.edges(find(seq.inv_edges_map(i, :)), 2);    
    edges_length = single(realsqrt(sum(...
        (geom.nodes(geom.edges(:,1),:) - ...
         geom.nodes(geom.edges(:,2),:)).^2')))';
    data.edges.len(i, nonzeros(seq.inv_edges_map(i, :))) = ...
        edges_length(find(seq.inv_edges_map(i, :)), :);

    data.nodes.selected(i, length(geom.nodes(:, 1))) = 0;
    data.nodes.selected(i, geom.edges(edges, :)) = true;

    
    s_by_n = sort(geom.nodecellmap(:,2));
    [a b c] = unique(s_by_n, 'legacy');
    num_c_per_n(s_by_n(b)) = b - [0 ; b(1:end -1)];
    data.nodes.mult(i, 1:length(num_c_per_n)) = num_c_per_n;
end

return