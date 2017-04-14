function edges_len = edges_len_from_geom(cellgeom);
%returns edges angle in degrees: - = 0; / = 45; | = 90; \ = 135; - = 0; 
x1 = cellgeom.nodes(cellgeom.edges(:,1),2);
x2 = cellgeom.nodes(cellgeom.edges(:,2),2);
y1 = cellgeom.nodes(cellgeom.edges(:,1),1);
y2 = cellgeom.nodes(cellgeom.edges(:,2),1);
edges_len = realsqrt((x2-x1).^2 + (y2-y1).^2);
