function seg_conv_remove_big_cells(homedir,outputdir,outfile)


if (nargin <1) || isempty(homedir)
    homedir = pwd;
end

if (nargin <2) || isempty(outputdir)
    outputdir = [homedir,'/Conv/'];
end

if (nargin <2) || isempty(outfile)
    outfile = [outputdir,filesep,'convgeom_T0001_new_Z0001'];
end


% Use Exisiting Labels
startdir = pwd;
cd(outputdir);
load(outfile);


badcells = sum(~isnan(cellgeom.faces))>20;
badcells = find(badcells);
for cell_id = badcells
    cellgeom = remove_cell_from_geom(cellgeom, cell_id);
end
cellgeom = fix_geom(cellgeom);
% save('convgeom_T0001_new_Z0001.mat', 'cellgeom','casename','filenames');
save([outfile,'.mat'], 'cellgeom','casename','filenames');

cd(startdir);
return


function geom = remove_cell_from_geom(geom, cell_id)
geom.circles = [geom.circles(1:cell_id - 1, :); geom.circles(cell_id + 1: end, :)];
geom.selected_cells = reshape(geom.selected_cells, 1, length(geom.selected_cells));
geom.selected_cells = [geom.selected_cells(1:cell_id -1), geom.selected_cells(cell_id + 1: end)];
geom.border_cells = setdiff(geom.border_cells, cell_id, 'legacy');
geom.border_cells(geom.border_cells  > cell_id) = ...
    geom.border_cells(geom.border_cells  > cell_id) - 1;
geom.nodecellmap = geom.nodecellmap(geom.nodecellmap(:,1) ~= cell_id, :);
geom.nodecellmap(geom.nodecellmap(:,1) > cell_id, 1) = ...
    geom.nodecellmap(geom.nodecellmap(:,1) > cell_id, 1) - 1;





