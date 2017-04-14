function wallH2 = drawgeom(cellgeom, activefig)
persistent wallH
delete(wallH(ishandle(wallH)));  
if ~isempty(cellgeom)
    X = [cellgeom.nodes(cellgeom.edges(:,1),2), cellgeom.nodes(cellgeom.edges(:,2),2)];
    Y = [cellgeom.nodes(cellgeom.edges(:,1),1), cellgeom.nodes(cellgeom.edges(:,2),1)];
    wallH = plot(get(activefig,'CurrentAxes'), X', Y', 'g');
%     figure(activefig);
%     wallH = patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, 'EdgeColor', [0 1 0]);
end
wallH2 = wallH;