function node = nearest_node(x, y, cellgeom)
d=((cellgeom.nodes(:,1)-y).^2 + (cellgeom.nodes(:,2)-x).^2);
d(~cellgeom.border_nodes) = inf;
% d = d(cellgeom.border_nodes);
[d,I] = sort(d);
node = I(1);