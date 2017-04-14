function [sqrness_full, sqrness_cells] = calc_int_ang_squareness(geom,sel_cells)

if nargin < 1 || isempty(geom)
    seq = load_dir(pwd);
    if isempty(seq)
        return
    end
    geom = seq.frames(1).cellgeom;
end

if nargin < 2 || isempty(sel_cells)
    sel_cells = geom.selected_cells;
end

if sel_cells == 0
    sel_cells = true(length(geom.faces(:, 1)), 1);
end


faces = geom.faces(sel_cells, :);
% faces = geom.faces;
%%%faces are lists of nodes

%%%internal angle distribution
tri = faces2tri(faces);
vert = [geom.nodes(:, 1) geom.nodes(:, 2)];
int_angs = ...
    angle_rad_2d_vec(vert(tri(:,1:3) + length(vert)), vert(tri(:,1:3)));        
int_angs(int_angs==0) = nan;
int_angs = int_angs * 180/pi;


int_angs_mod = mod(int_angs,90);
int_angs_mod(int_angs_mod > 45) = 90 - int_angs_mod(int_angs_mod > 45);
sqrness = 1-int_angs_mod/45;



%%%inds to count across, instead of down
inds = repmat((1:size(faces,1)),size(faces,2),1);
inds = inds(:);
indShifts = 0:size(faces,1):(size(faces,1)*(size(faces,2)-1));
inds = inds + repmat(indShifts',size(faces,1),1);

%%% centerNodes are the same as the original 'faces' list
% structTri = nan(numel(faces),size(tri,2));
% structTri(~isnan(faces(inds)),:) = tri;
% centerNodes(inds) = nan(size(faces));
% centerNodes(inds) = structTri(:,2);

sqrness_full = nan(size(faces));
sqrness_full(inds(~isnan(faces(inds)))) = sqrness;
sqrness_cells = nanmean(sqrness_full,2);
%%% map for [cell,node,ang]:
%%% cell is first dimension ind, node value at 'faces', ang is value at
%%% 'int_angs_full'