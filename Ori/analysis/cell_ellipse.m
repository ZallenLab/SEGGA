function [L1 L2 angle temp_ratio] = cell_ellipse(nodes, faces_for_area)

nodes = reshape(nodes', [], 1);

x_poly = nodes(2 * faces_for_area);
y_poly = nodes(2 * faces_for_area - 1);
if size(x_poly, 2) == 1
    x_poly = x_poly';
    y_poly = y_poly';
end
[x y cellsareas] = poly_centroid(x_poly, y_poly, 2);
siz = size(faces_for_area);
x = reshape(x, [], 1);
y = reshape(y, [], 1);
x = repmat(x, 1, siz(2));
y = repmat(y, 1, siz(2));

[xx xy yy] = poly_tensor(x_poly - x, y_poly - y, 2);
% cellsareas = polyarea(x_poly, y_poly, 2);

[L1 L2 angle] = tensor_props(xx, xy, yy);
L1 = realsqrt(L1);
L2 = realsqrt(L2);
temp_ratio = realsqrt(pi*L1.*L2 ./ abs(cellsareas'));
L1 = L1 ./ temp_ratio;
L2 = L2 ./ temp_ratio;

L1 = 2*L1; %convert from radius to diameter
L2 = 2*L2; %convert from radius to diameter
    
% angle = mod(angle, pi); %%%doesn't do anything
angle = 180*angle/pi;

