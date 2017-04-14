function cellgeom = dis_associate(cellgeom, cell, node, do_faces)
if nargin < 4 || isempty(do_faces)
    do_faces = true;
end
ind = (cellgeom.nodecellmap(:,1) == cell & cellgeom.nodecellmap(:, 2) == node);
cellgeom.nodecellmap = cellgeom.nodecellmap(~ind,:);
cellgeom = update_edgecell(cellgeom);
cellgeom.circles(cell,1:2) = centroid(...
    cellgeom.nodes(cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1) == cell),2),1:2));

if do_faces
    nmap = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 1) == cell, 2);
    cellgeom.faces(cell, :) = nan;
    cellgeom.faces(cell, 1:length(nmap)) = nmap;
end