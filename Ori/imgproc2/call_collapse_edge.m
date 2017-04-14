function [cellgeom success] = call_collapse_edge(cellgeom, activefig, trackingstate)
if nargin < 3 || isempty(trackingstate)
    trackingstate = false;
end 

success = false;
figure(activefig);
short_edgesH = draw_short_edges(activefig, cellgeom); 
fprintf('Click on an edge to delete. Press Return or Esc to abort.\n');
[y,x, button] = ginput(1);
if isempty(x) | button == 27 | button == 3 
    exit_function
    return
end

edge = nearest_edge(cellgeom, x, y);
[cellgeom success cells] = collapse_edge(cellgeom, cellgeom.edges(edge,1), cellgeom.edges(edge,2), 0, ~trackingstate);
if trackingstate
    exit_function
    return
end

wallH = drawgeom(cellgeom, activefig);
exit_function
return

    function exit_function
        delete(short_edgesH(ishandle(short_edgesH)));
    end
end