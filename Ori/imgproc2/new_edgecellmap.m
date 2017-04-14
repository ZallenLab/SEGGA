function [new_map faulty_cells]= new_edgecellmap(cellgeom)
fc = [];
new_map = nan(size(cellgeom.edges));
for i = 1:length(cellgeom.edgecellmap(:,1))
    if isnan(new_map(cellgeom.edgecellmap(i, 2), 1)) 
        new_map(cellgeom.edgecellmap(i, 2), 1) = cellgeom.edgecellmap(i, 1);
    elseif new_map(cellgeom.edgecellmap(i, 2), 1) ~= cellgeom.edgecellmap(i, 1)
        if ~isnan(new_map(cellgeom.edgecellmap(i, 2), 2)) && ...
            new_map(cellgeom.edgecellmap(i, 2), 2) ~= cellgeom.edgecellmap(i, 1)
            fc = [fc new_map(cellgeom.edgecellmap(i, 2), :) cellgeom.edgecellmap(i, 1)];
            disp('edge with 3 cells')
            disp(sprintf('%d', i)); 
        end
        new_map(cellgeom.edgecellmap(i, 2), 2) = cellgeom.edgecellmap(i, 1);
    end
end
if nargout > 1
    faulty_cells = fc;
end