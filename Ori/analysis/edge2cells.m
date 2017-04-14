function cells = edge2cells(geom, edge)
% DLF Edit Sept 12 2012, changing 'edge' to 'full(edge)' to deal with
% error about sparse array
cells = geom.edgecellmap(geom.edgecellmap(:, 2) == full(edge), 1);

