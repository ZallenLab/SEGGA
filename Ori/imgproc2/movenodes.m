function [cellgeom success] = movenodes(cellgeom, activefig, trackingstate)
if nargin < 3 || isempty(trackingstate)
    trackingstate = false;
end 
success = false;
figure(activefig);
clickradius = 8;

fprintf('Click on node to move. Press Return when done.\n');
[y,x, button] = ginput(1);
while ~isempty(x) & button ~= 27 & button ~= 3;
    d=sqrt((cellgeom.nodes(:,1)-x).^2 + (cellgeom.nodes(:,2)-y).^2);
    [D,I] = min(d);
    if D < clickradius
        % Plot the point
%         ptH = plot(cellgeom.nodes(I,2),cellgeom.nodes(I,1),'rx');
            
% % %             DEBUG DLF BEGIN
ptH = plot(cellgeom.nodes(I,2),cellgeom.nodes(I,1),'rs',...
                'MarkerEdgeColor','r',...
                'MarkerFaceColor','r',...
                'MarkerSize',10);
% % %             DEBUG DLF END


        fprintf('Click on new node location. Press Return to abort.\n');
        [y,x, button] = ginput(1);
        if isempty(x) | button == 27 | button == 3
            if ishandle(ptH)
                delete(ptH);
            end
            return
        end

        cellgeom.nodes(I,:) = [x,y];

        

        if ishandle(ptH)
            delete(ptH);
        end
        success = true;
        cells = cellgeom.nodecellmap(cellgeom.nodecellmap(:,2) == I, 1);
        for i = 1:length(cells)
            cellgeom.circles(cells(i),1:2) = centroid(cellgeom.nodes(cellgeom.nodecellmap(cellgeom.nodecellmap(:,1) ==  cells(i), 2),1:2));
        end
        if ~trackingstate
            wallH = drawgeom(cellgeom, activefig);
            % Edges to redraw
            for eidx = [find(cellgeom.edges(:,1) == I); find(cellgeom.edges(:,2) == I)]' 
                delete(wallH(eidx));
                wallH(eidx) = plot([cellgeom.nodes(cellgeom.edges(eidx,1),2) cellgeom.nodes(cellgeom.edges(eidx,2),2)], [cellgeom.nodes(cellgeom.edges(eidx,1),1) cellgeom.nodes(cellgeom.edges(eidx,2),1)], 'y');
            end
            draw_selected_cells;
        else
            return
        end

        
        
        fprintf('Click on next node to move. Click the right mouse button when done.\n');  
    else
        fprintf('No node selected. Click on node to move. Press Return when done.\n');  
    end
    
    [y,x, button] = ginput(1);
end
cellgeom.edges_length = realsqrt(sum((cellgeom.nodes(cellgeom.edges(:,1),:) - cellgeom.nodes(cellgeom.edges(:,2),:)).^2'));
