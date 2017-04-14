function [inv_edges edges] = track_edges(seq)





for i = 1:length(seq.frames)
    map = sortrows(seq.frames(i).cellgeom.edgecellmap, 2);
    [a b c] = unique(map(:,2), 'legacy');
    ind = find((b - [0 b(1:end-1)']') == 2);
    
    numcells = length(seq.frames(i).cellgeom.circles(:,1));
    s_map = sort([map(b(ind), 1) map(b(ind) - 1, 1)], 2, 'descend');    
    seq.frames(i).edge2cells = int16(s_map);
    %looks like here I assume there are no gaps in edge numbers. That is,
    %ind gives the right edge number and not only its position among all
    %edges. If for some reason, edgecellmap does not list a certain edge,
    %this will be wrong. Can be fixed with ind = map(b(ind), 2);
    if sum(ind ~= map(b(ind), 2))
        disp('ind = map(b(ind), 2) was needed???');
        ind = map(b(ind), 2);
    end
    inv_ind = zeros(1,length(seq.frames(i).cellgeom.edges(:,1)));
    inv_ind(ind) = 1:length(ind);
    %seq.frames(i).cells2edge = sparse(s_map(:,1), s_map(:,2), ind, numcells, numcells);
    seq.frames(i).ind = ind;
    %seq.frames(i).edges_ind = inv_ind;
end


edges = zeros(length(seq.frames), length(seq.frames(1).ind), 'uint32');
%using a sparse matrix is too slow here because its size is kept being
%increased below
%edges = sparse(length(seq.frames), length(seq.frames(1).ind)); 
inv_edges = edges;
edges(1, :) = 1:length(seq.frames(1).ind);
edges_by_g_cells = double(reshape(...
        seq.inv_cells_map(1, seq.frames(1).edge2cells), ...
        length(seq.frames(1).ind), 2));
g_cells2edges = sparse(length(seq.cells_map(1,:)), length(seq.cells_map(1,:)));
g_cells2edges(sub2ind(size(g_cells2edges), edges_by_g_cells(:, 1), edges_by_g_cells(:,2))) = ...
    1:length(seq.frames(1).ind);
for i = 1:length(seq.frames)
    edges_by_g_cells = double(reshape(...
        seq.inv_cells_map(i, seq.frames(i).edge2cells), ...
        length(seq.frames(i).ind), 2));
    edges_by_g_cells = sort(edges_by_g_cells, 2, 'descend');
    tracked_edges = g_cells2edges(sub2ind(size(g_cells2edges), edges_by_g_cells(:, 1), edges_by_g_cells(:, 2)));
    edges(i, nonzeros(tracked_edges)) = seq.frames(i).ind(find(tracked_edges));
    new_edges = tracked_edges == 0;
    old_edges_num = length(edges(i, :));
    edges(i, end + 1: end + sum(new_edges)) = seq.frames(i).ind(new_edges);
	g_cells2edges(sub2ind(size(g_cells2edges), ...
        edges_by_g_cells(new_edges, 1), edges_by_g_cells(new_edges, 2))) = ...
        old_edges_num + 1 : old_edges_num + sum(new_edges);
    
    inv_edges(i, nonzeros(edges(i, :))) = find(edges(i, :));
end

if nnz(edges) < 0.3 * length(edges(:))
    [ind_x ind_y] = find(edges);
    sp_edges = sparse(ind_x, ind_y, 1, length(edges(:, 1)), length(edges(1, :)));
    sp_edges(find(edges(:))) = nonzeros(edges(:));
    edges = sp_edges;
end