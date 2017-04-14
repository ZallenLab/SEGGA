function [cellgeom success] = addedge(cellgeom, activefig, trackingstate, given_cell, given_pos1, given_pos2)
%Functions calling addedge (such as rectify_seq_ assume the new cell
%created here is added to the end of the list of cells and the rest of the 
%list remains untouched.

success = false;

if nargin > 3
    batch_mode = true;
else
    batch_mode = false;
end
if nargin < 3 || isempty(trackingstate)
    trackingstate = false;
end
ptH = [];

if ~batch_mode
    pos_vec = get(get(activefig,'CurrentAxes'), 'position');
    pos_vec2 = get(activefig, 'position');
    if trackingstate
        marker_size = pos_vec2(3);    
    else
        marker_size = pos_vec2(3) * (pos_vec(3) - pos_vec(1))/3;
    end

    figure(activefig);
    fprintf('Select the first node (existing or new) of the new edge.\n');
    [first_y, first_x, button] = ginput(1);
    if isempty(first_x) | button == 27 | button == 3
        delete(ptH(ishandle(ptH)))
        return
    end
    ptH = scatter(get(activefig,'CurrentAxes'), first_y, first_x, marker_size, 'r', '.');

    fprintf('Select the second node (existing or new) of the new edge.\n');
    [second_y, second_x, button] = ginput(1);
    if isempty(second_x) | button == 27 | button == 3
        delete(ptH(ishandle(ptH)))
        return
    end
    ptH = [ptH scatter(get(activefig,'CurrentAxes'), second_y, second_x, marker_size, 'r', '.')];

    I1 = cell_from_pos((first_y + second_y)/2, (first_x + second_x)/2, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell between the two nodes.', '', 'error', 'modal');
        waitfor(h);
        delete(ptH(ishandle(ptH)));
        return
    end
else
    I1 = given_cell;
    first_x = given_pos1(1);
    first_y = given_pos1(2);
    second_x = given_pos2(1);
    second_y = given_pos2(2);
end

% find nodes of selected cell
cell_nodes = cellgeom.nodecellmap(cellgeom.nodecellmap(:,1) == I1 ,2);
circular_cell_nodes = cell_nodes;
circular_cell_nodes(end +1) = cell_nodes(1);
% %highlight cell nodes
% if ishandle(ptH)
%     delete(ptH);
% end
% nodesH = scatter(get(activefig,'CurrentAxes'), cellgeom.nodes(cell_nodes,2), cellgeom.nodes(cell_nodes,1), marker_size, 'b', '.');
fake_nodes = ([cellgeom.nodes(cell_nodes,1), cellgeom.nodes(cell_nodes,2)] + ...
    [cellgeom.nodes(circshift(cell_nodes,-1),1), cellgeom.nodes(circshift(cell_nodes,-1),2)])/2;


x = first_x;
y = first_y;
new_node1 = [];
d=(cellgeom.nodes(cell_nodes,1)-x).^2 + (cellgeom.nodes(cell_nodes,2)-y).^2;
[D,node1] = min(d);
d=(fake_nodes(:,1) -x).^2 + (fake_nodes(:,2)-y).^2;
[D_fake, fake_node1] = min(d);
D_fake = D_fake / 2;
fake_node1 = fake_node1 + 0.5;                
if D > D_fake
    new_node1 = [x,y];
    neighbor_cell1 = intersect(cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == circular_cell_nodes(ceil(fake_node1)), 1), ...
        cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == cell_nodes(floor(fake_node1)),1), 'legacy');
    neighbor_cell1 = setdiff(neighbor_cell1 , I1, 'legacy');
    if length(neighbor_cell1) ~= 1
        if ~batch_mode
            msgboxH = msgbox('Was not able to add a node where you clicked', 'Try again', 'warn', 'modal');
            disp(neighbor_cell1)
            waitfor(msgboxH);
            delete(ptH(ishandle(ptH)));
        end
        return
    end
end

x = second_x;
y = second_y;
new_node2 = [];
d=(cellgeom.nodes(cell_nodes,1)-x).^2 + (cellgeom.nodes(cell_nodes,2)-y).^2;
[D,node2] = min(d);
d=(fake_nodes(:,1) -x).^2 + (fake_nodes(:,2)-y).^2;
[D_fake, fake_node2] = min(d);
D_fake = D_fake / 2;
fake_node2 = fake_node2 + 0.5;
if D > D_fake
    new_node2 = [x,y];
    neighbor_cell2 = intersect(cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == circular_cell_nodes(ceil(fake_node2)), 1), ...
        cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == cell_nodes(floor(fake_node2)),1), 'legacy');
    neighbor_cell2 = setdiff(neighbor_cell2 , I1, 'legacy');
    if length(neighbor_cell2) ~= 1
        if ~batch_mode
            msgboxH = msgbox('Was not able to add a node where you clicked', 'Try again', 'warn', 'modal');
            waitfor(msgboxH);
            delete(ptH(ishandle(ptH)));
        end
        return
    end
end

if isempty(new_node1)
    if isempty(new_node2)
        start_node = min(node1, node2) + 1;
        end_node = max(node1, node2) -1;
    else
        start_node = ceil(min(node1 + 0.5, fake_node2));
        end_node = floor(max(node1 - 0.5, fake_node2));
    end
else
    if isempty(new_node2)
        start_node = ceil(min(fake_node1, node2 + 0.5));
        end_node = floor(max(fake_node1, node2 -0.5));
    else
        start_node = ceil(min(fake_node1, fake_node2));
        end_node = floor(max(fake_node1, fake_node2));
    end
end

if start_node <= end_node
    cellgeom.circles(end+1,:) = cellgeom.circles(I1,:);
    new_cell = length(cellgeom.circles(:,1));
    if isempty(new_node1)
        ns = cell_nodes(node1); %ns and new_node are for the redrawing below
        if isempty(new_node2)
            cellgeom.nodecellmap(end+1,:) = [new_cell cell_nodes(node1)];
            cellgeom.nodecellmap(end+1,:) = [new_cell cell_nodes(node2)];
            new_node = cell_nodes(node2);
        else
            cellgeom.nodes(end+1,:) = new_node2;           
            cellgeom.nodecellmap(end+1,:) = [new_cell cell_nodes(node1)];
            cellgeom.nodecellmap(end+1,:) = [new_cell length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [I1 length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [neighbor_cell2 length(cellgeom.nodes(:,1))];

            new_node = length(cellgeom.nodes(:,1));%ns and new_node are for the redrawing below
        end
    else
        ns = length(cellgeom.nodes(:,1)) + 1;%ns and new_node are for the redrawing below
        if isempty(new_node2)
            cellgeom.nodes(end+1,:) = new_node1;
            cellgeom.nodecellmap(end+1,:) = [new_cell cell_nodes(node2)];
            cellgeom.nodecellmap(end+1,:) = [new_cell length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [I1 length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [neighbor_cell1 length(cellgeom.nodes(:,1))];
            new_node = cell_nodes(node2);  %ns and new_node are for the redrawing below                                  
        else
            cellgeom.nodes(end+1,:) = new_node1;
            cellgeom.nodecellmap(end+1,:) = [new_cell length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [I1 length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [neighbor_cell1 length(cellgeom.nodes(:,1))];
            cellgeom.nodes(end+1,:) = new_node2;
            cellgeom.nodecellmap(end+1,:) = [new_cell length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [I1 length(cellgeom.nodes(:,1))];
            cellgeom.nodecellmap(end+1,:) = [neighbor_cell2 length(cellgeom.nodes(:,1))];
            new_node = length(cellgeom.nodes(:,1)); %ns and new_node are for the redrawing below
        end
    end
    nodes_to_flip = cell_nodes(start_node:end_node);
    cellgeom.nodecellmap(cellgeom.nodecellmap(:,1) == I1 & ismember(cellgeom.nodecellmap(:,2), nodes_to_flip, 'legacy'), 1) = new_cell;

    cellgeom.selected_cells(new_cell) = cellgeom.selected_cells(I1);
    touched_cells = [I1 new_cell];
else
    if ~batch_mode
        msgboxH = msgbox(['There must be at least one existing node'...
            ' between the two selected nodes.'],...
            'Try again', 'warn', 'modal');
        waitfor(msgboxH);
        delete(ptH(ishandle(ptH)));
    end
    return
end


for i = 1:length(touched_cells)
    cellgeom.circles(touched_cells(i),1:2) = ...
        mean(cellgeom.nodes(cellgeom.nodecellmap(cellgeom.nodecellmap(:,1) == touched_cells(i), 2),1:2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% NOTE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Updates to the topology should 
% be made to the affected cells only (I1, new_cell and possibly
% neighbor_cell1 and neighbor_cell2) by directly resorting
% cellgeom.nodecellmap
% THIS IS TRUE FOR EVERY EDITING FUNCTION (merge/unite_cells,
% associate_node etc).
cellgeom = update_edgecell(cellgeom);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

success = true;

delete(ptH(ishandle(ptH)));
if trackingstate || batch_mode
    return
end
for i = 1:length(touched_cells)
    cellgeom.circles(touched_cells(i),1:2) = ...
        centroid(cellgeom.nodes(cellgeom.nodecellmap(cellgeom.nodecellmap(:,1) == touched_cells(i), 2),1:2));

    nmap = cellgeom.nodecellmap(cellgeom.nodecellmap(:, 1) == touched_cells(i), 2);
    cellgeom.faces(touched_cells(i), :) = nan;
    cellgeom.faces(touched_cells(i), 1:length(nmap)) = nmap;
    
end
wallH = drawgeom(cellgeom, activefig);
eidx = find(cellgeom.edges(:,1) == ns &  cellgeom.edges(:,2) == new_node); 
if length(wallH) >= eidx
    delete(wallH(eidx));
end
wallH(eidx) = plot([cellgeom.nodes(cellgeom.edges(eidx,1),2) cellgeom.nodes(cellgeom.edges(eidx,2),2)], [cellgeom.nodes(cellgeom.edges(eidx,1),1) cellgeom.nodes(cellgeom.edges(eidx,2),1)], 'r');
draw_selected_cells;

fprintf('New edge added. Use the ''Move Node'' command to position the edge.\n');
