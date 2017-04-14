function nghbrs = get_cell_nghbrs(geom, cell,depth)
%%% Function adapted to find 'conronae'
%%% DLF - 2016-Oct-27-Thurs
if (nargin < 3) || isempty(depth)
    depth = 1;
end

if numel(cell)==1 
    nodes = geom.nodecellmap(geom.nodecellmap(:, 1) == cell, 2);
    nghbrs = geom.nodecellmap(ismember(geom.nodecellmap(:, 2), nodes, 'legacy'), 1);
    nghbrs = faster_unique(nghbrs, length(geom.circles));
    nghbrs = nghbrs(nghbrs ~= cell);
else
    nodes = geom.nodecellmap(ismember(geom.nodecellmap(:, 1),cell), 2);
    nghbrs = geom.nodecellmap(ismember(geom.nodecellmap(:, 2), nodes, 'legacy'), 1);
    nghbrs = faster_unique(nghbrs, length(geom.circles));
end

if depth > 1
    nghbrs = [nghbrs, get_cell_nghbrs(geom,nghbrs,depth-1)];
    nghbrs = unique(nghbrs);
end
