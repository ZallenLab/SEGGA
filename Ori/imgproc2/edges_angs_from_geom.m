function edges_ang = edges_angs_from_geom(cellgeom);
%returns edges angle in degrees: - = 0; / = 45; | = 90; \ = 135; - = 0; 
x1 = cellgeom.nodes(cellgeom.edges(:,1),2);
x2 = cellgeom.nodes(cellgeom.edges(:,2),2);
y1 = cellgeom.nodes(cellgeom.edges(:,1),1);
y2 = cellgeom.nodes(cellgeom.edges(:,2),1);
edges_ang = 180 * mod((atan2((y2-y1) , (x2 - x1))), single(pi)) / pi;
