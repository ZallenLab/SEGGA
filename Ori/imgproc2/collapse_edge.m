function [cellgeom success cells] = collapse_edge(cellgeom, I1,I2, quiet_mode, do_faces)
%This function changes the geomtery by making two nodes (I1 and I2) into
%one. That is, it deletes an edge by deleting the nodes. It then associates
%the cells originally associated with the deleted nodes with the newly
%created node. 

if nargin < 5 || isempty(do_faces)
    do_faces = 0;
end

if nargin < 4 || isempty(quiet_mode)
    quiet_mode = 0;
end
success = false;
if I2 < I1 %make sure I2 > I1
    temp_I2 = I2;
    I2 = I1;
    I1 = temp_I2;
end

%Find the two cells sharing the edge to be deleted.
cells = intersect(cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,2) == I1),1), ...
    cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,2) == I2),1), 'legacy');
if length(cells) > 2 || length(cells) == 0;
    if ~quiet_mode
        msgboxH = msgbox('The number of cells common to both of the selected nodes is not two.', 'Are you sure this is an edge?', 'Warn', 'modal');
        waitfor(msgboxH);
    end
    return
end
cell1_nodes = cellgeom.nodecellmap(:,1) == cells(1);
if length(cells) == 2
    cell2_nodes = cellgeom.nodecellmap(:,1) == cells(2);
end
%If at least one of the two cells is a triangle, delete the edge by 
%merging the cells.
if sum(cell1_nodes) < 4 | (length(cells) == 2 && sum(cell2_nodes) < 4)
    if sum(cell1_nodes) < 4
        I3 = setdiff(cellgeom.nodecellmap(cell1_nodes,2), [I1 I2], 'legacy');
    else
        I3 = setdiff(cellgeom.nodecellmap(cell2_nodes,2), [I1 I2], 'legacy');
    end
    cells_to_merge = intersect(cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == I3 ,1), ...
        cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == I2, 1), 'legacy');
    if length(cells_to_merge) ~= 2
        if ~quiet_mode
            msgboxH = msgbox('Failed merging a 3-sided cell.', 'Pay attention', 'help', 'modal');
            waitfor(msgboxH);
        end
        return
    end

    if quiet_mode < 2
        [cellgeom success] = unite_cells(cellgeom, cells_to_merge(1), cells_to_merge(2), quiet_mode, do_faces);
    end
    if ~quiet_mode
        msgboxH = msgbox('A cell was collapsed.', 'Pay attention', 'help', 'modal');
        waitfor(msgboxH);
    end
    return
end




cellgeom.nodes(I1,:) = (cellgeom.nodes(I1,:) + cellgeom.nodes(I2,:))/2;
cellgeom.nodes = [cellgeom.nodes(1:I2 - 1,:) ; cellgeom.nodes(I2 + 1:end,:)];
cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,2) == I2), 2) = I1;
cellgeom.nodecellmap = unique(cellgeom.nodecellmap, 'rows', 'legacy');
cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) > I2, 2) = ...
    cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) > I2, 2) - 1;
%     cellgeom.faces(cellgeom.faces(:) > I2) = ...
%         cellgeom.faces(cellgeom.faces(:) > I2) - 1;


cells = cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == I1,1);

cellgeom.border_nodes = setdiff(cellgeom.border_nodes, I2, 'legacy');
cellgeom.border_nodes(find(cellgeom.border_nodes > I2)) = ...
    cellgeom.border_nodes(find(cellgeom.border_nodes > I2)) - 1;

cellgeom = update_edgecell(cellgeom);
for i = 1:length(cells)
    cellgeom.circles(cells(i),1:2) = ...
        centroid(cellgeom.nodes(cellgeom.nodecellmap(find(cellgeom.nodecellmap(:,1) == cells(i)),2),1:2));
end
success = true;

%if called from tracking, do_faces = 0 but faces will be updated with a
%call to fix_geom at tracking/edit_t
if do_faces
    for i = 1:length(cells)
    nmap = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 1) == cells(i), 2);
    cellgeom.faces(cells(i), :) = nan;
    cellgeom.faces(cells(i), 1:length(nmap)) = nmap;
    end
end
