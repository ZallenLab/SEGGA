function h = draw_short_edges(activefig, cellgeom)
persistent edgesH
delete(edgesH(ishandle(edgesH)));
[dummy edges_to_draw] = sort(cellgeom.edges_length);
num_edges_to_draw = round(length(edges_to_draw) / 20);
edges_to_draw = edges_to_draw(1:num_edges_to_draw);
X = [cellgeom.nodes(cellgeom.edges(edges_to_draw,1),2), ...
    cellgeom.nodes(cellgeom.edges(edges_to_draw,2),2)];
Y = [cellgeom.nodes(cellgeom.edges(edges_to_draw,1),1), ...
    cellgeom.nodes(cellgeom.edges(edges_to_draw,2),1)];
delete(edgesH(ishandle(edgesH)));
edgesH = plot(get(activefig,'CurrentAxes'), X', Y', 'r', 'LineWidth',1.5);
h = edgesH;