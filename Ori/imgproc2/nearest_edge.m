function edge = nearest_edge(cellgeom, x, y);
    pts = 10;
    edges_lines = zeros(length(cellgeom.edges(:,1)),2,pts);
    edges_lines(:,:,1) = cellgeom.nodes(cellgeom.edges(:,1),:);
    edges_lines(:,:,pts) = cellgeom.nodes(cellgeom.edges(:,2),:);
    o_lines = ones(length(edges_lines(:,1,1)),1);
    o100 = ones(pts,1);
    edges_lines(:,1,:) = (o_lines * (0:(pts-1))) .* ...
        (((edges_lines(:,1,pts) - edges_lines(:,1,1))/(pts-1))* o100') ...
        + edges_lines(:,1,1) * o100';
    edges_lines(:,2,:) = (o_lines * (0:(pts-1))) .* ...
        (((edges_lines(:,2,pts) - edges_lines(:,2,1))/(pts-1))* o100') ...
        + edges_lines(:,2,1) * o100';   
    
    d=squeeze((edges_lines(:,1,:)-x).^2 + (edges_lines(:,2,:)-y).^2);
    [D, edge] = min(min(d,[],2));
end