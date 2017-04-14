function [data, full_data, other_data]= static_data_function(geom, sel_cells, light_data)
%passing sel_cells = 0 will analyze all cells
%full_data lists the area, perimeter length, number of sides and circularity
%of each individual cell.
%If light_data is true, the routine will return at that point without 
%calculating averages etc. If light_data is false, static_data_function
%will continue to calculate averages and stds of various measurements that
%are outputed as fields of the data variable. 
%
%data lists various averages and std for the entire collection of cells.
%

if nargin < 2 || isempty(sel_cells)
    sel_cells = geom.selected_cells;
end

if sel_cells == 0
    sel_cells = true(length(geom.faces(:, 1)), 1);
end

%num bhgbrs
num_nghbrs = zeros(length(geom.faces(sel_cells, 1)), 1);
faces = geom.faces(sel_cells, :);
for i = 1:length(num_nghbrs)
    num_nghbrs(i) = sum(~isnan(faces(i, :)));
end

%util
faces_for_area = faces2ffa(faces);
ny = geom.nodes(:, 1);
nx = geom.nodes(:, 2);
x = nx(faces_for_area);
y = ny(faces_for_area);
if size(x, 2) == 1
    x = x';
    y = y';
end

%peri
total_length = sum(realsqrt(...
     (x(:, [2:end 1]) - x).^2 + (y(:, [2:end 1]) - y).^2), 2);    
 
%area
areas = polyarea(x, y, 2);

%circ & distortions
% [d c] = cell_distortion(total_length, areas, num_nghbrs);
c = cell_circularity(total_length, areas);

full_data.area = areas;
full_data.peri = total_length;
full_data.num_sides = num_nghbrs;
full_data.circ = c;

if exist('light_data') && light_data
    data = [];
    return
end

%light_data = false, add more fields to full_data and calc averages and
%stds over the entire selected cell population
% full_data.distortion = d;

%area per num sides
other_data.area_per_ns = accumarray(num_nghbrs, areas, [], @mean);


num_cells = length(areas);

data.qVal.avg = mean(total_length./realsqrt(areas));
data.qVal.std = std(total_length./realsqrt(areas));
data.qVal.n = numel(total_length);


data.num_nghbrs.avg = mean(num_nghbrs);
data.num_nghbrs.std = std(num_nghbrs);
data.num_nghbrs.n = length(num_nghbrs);


data.areas.avg = mean(areas);
data.areas.std = std(areas);
data.areas.n = length(areas);


data.peri.avg = mean(total_length);
data.peri.std = std(total_length);
data.peri.n = length(total_length);


data.circ.avg = mean(c);
data.circ.std = std(c);
data.circ.n = length(c);

%%% Not using distortion measurement anymore
% data.dist.avg = mean(d);
% data.dist.std = std(d);
% data.dist.n = length(d);

%node multiplicity
[temp_nm sel_nodes] = node_mult(geom, sel_cells);
nm = temp_nm(sel_nodes);

data.nm.avg = mean(nm);
data.nm.std = std(nm);
data.nm.n = length(nm);

%eccentricity
[cell_L1 cell_L2 cell_angle temp_ratio] = cell_ellipse(geom.nodes, faces_for_area);
ecc = realsqrt(1 - (cell_L2 ./ cell_L1).^2);
%ecc(isnan(ecc)) = 0; removed --ori Dec 8th 2008

% [absL1, absL2, conv] = convert_inertial_tensor_to_absolute_metrics(cell_L1, cell_L2, areas);
% full_data.abs_cell_length = absL1;
% full_data.abs_cell_length = absL2;
% full_data.conv = conv;



length_width_ratio = (cell_L1 ./ cell_L2);

hor = sqrt((cell_L1 .* cosd(cell_angle)).^2 + (cell_L2 .* sind(cell_angle)).^2);
ver = sqrt((cell_L1 .* sind(cell_angle)).^2 + (cell_L2 .* cosd(cell_angle)).^2);

full_data.ecc = ecc;
full_data.cell_length = cell_L1;
full_data.cell_width = cell_L2;
full_data.length_width_ratio = length_width_ratio;
full_data.cell_angle = cell_angle;
full_data.cell_hor = hor;
full_data.cell_ver = ver;
full_data.cell_hor_ver_ratio = hor./ver;


data.ecc.avg = mean(ecc);
data.ecc.std = std(ecc);
data.ecc.n = length(ecc);


%need to change to geometric mean (exp(mean(log()))
data.length_width_ratio.avg = exp(mean(log((length_width_ratio))));
data.length_width_ratio.std = exp(std(log(length_width_ratio)));
data.length_width_ratio.n = length(cell_angle);

data.length.avg = mean(cell_L1);
data.length.std = std(cell_L1);
data.length.n = length(cell_angle);


%changed to weight by ecc sep 24 2008.
%changed the weight to length_width_ratio from ecc -- Ori 05 Dec 2008
% length_width_ratio = length_width_ratio - 1; %commented out, noe taking log.
                                               % -- Ori June 26 2009
cell_angle_90  = cell_angle;
cell_angle_90(cell_angle_90 > 90) = 180 - cell_angle_90(cell_angle_90 > 90); %avg over [0-90] rather than [0-180]. -- Ori Feb 2009

inds = ~isnan(length_width_ratio);
data.cell_angle.avg = wmean(cell_angle_90(inds), log(length_width_ratio(inds))); %changed from mean to wmean sep 24 2008.
data.cell_angle.std = std(cell_angle_90(inds), log(length_width_ratio(inds))); %changed to log(length_width_ratio) June 26 2009.
data.cell_angle.n = length(length_width_ratio);

% hor = hor(ind);
% ver = ver(ind);

data.cell_hor.avg = mean(hor);
data.cell_hor.std = std(hor);
data.cell_hor.n = length(hor);

data.cell_ver.avg = mean(ver);
data.cell_ver.std = std(ver);
data.cell_ver.n = length(ver);

%need to change to geometric mean (exp(mean(log()))
data.cell_hor_ver_ratio.avg = exp(mean(log(mean(hor./ver))));
data.cell_hor_ver_ratio.std = exp(std(log(hor./ver)));
data.cell_hor_ver_ratio.n = length(hor);

%internal angle distribution
tri = faces2tri(faces);
vert = [geom.nodes(:, 1) geom.nodes(:, 2)];
int_angs = ...
    angle_rad_2d_vec(vert(tri(:,1:3) + length(vert)), vert(tri(:,1:3)));        
int_angs(int_angs==0) = nan;
int_angs = int_angs * 180/pi;
data.int_ang.avg = mean(int_angs(~isnan(int_angs)));
data.int_ang.std = std(int_angs(~isnan(int_angs)));
data.int_ang.n = nnz(~isnan(int_angs));

data.frac_int_ang150.avg = sum(int_angs > 150) ./ sum(int_angs > 0);
data.frac_int_ang150.std = 0;
