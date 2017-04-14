function [new_img, cellgeom] = rot_everything_dlf(img, cellgeominput, alpha, top, bottom, left, right, flip, img_only)
declareglobs
if nargin < 9
    img_only = false;
end

if nargin < 8
    flip = false;
end

cellgeom = cellgeominput;    
new_img = imrotate(img, alpha, 'bicubic');
alpha = alpha * pi/180;
if ~img_only
    cellgeom.nodes = rot(alpha, cellgeom.nodes, size(img), size(new_img));
%     workingarea = rot(alpha, workingarea, size(img), size(new_img));
%     circles(:, 1:2) = rot(alpha, circles(:, 1:2), size(img), size(new_img));
    circles_pos = cellgeom.circles(:,1:2);
%     circles_rads = cellgeom.circles(:,3);
    cellgeom.circles(:,1:2) = rot(alpha, circles_pos, size(img), size(new_img));
    circles = cellgeom.circles;
%     for i = 1:length(celldata)
%         if ~isempty(celldata(i).circlecenter)
%             celldata(i).circlecenter = ...
%                 rot(alpha, celldata(i).circlecenter, size(img), size(new_img));
%         end
%     end
end

if nargin <7
%     top = max(round(min(workingarea(:,1)) - 5), 1);
%     bottom = min(round(max(workingarea(:,1)) + 5), length(new_img(:,1)));
%     left = max(round(min(workingarea(:,2)) - 5), 1);
%     right = min(round(max(workingarea(:,2)) + 5), length(new_img(1,:)));
    top = 1;
    bottom = length(new_img(:,1));
    left = 1;
    right = length(new_img(1,:));
end


new_img = new_img(top:bottom, left:right);
if ~img_only
    cellgeom.nodes = crop(cellgeom.nodes, top, left);
    cellgeom.circles = crop(cellgeom.circles, top, left);
%     circles(:, 1:2) = crop(circles(:, 1:2), top, left);
%     workingarea = crop(workingarea, top, left);
end
if flip
    new_img = new_img(end:-1:1, 1:end);
    if ~img_only    
        len = length(new_img(:,1));
        cellgeom.nodes(:,1) = flip_vec(cellgeom.nodes(:,1), len);
        cellgeom.circles(:,1) = flip_vec(cellgeom.circles(:,1), len);
%         circles(:,1) = flip_vec(circles(:,1), len);
%         workingarea(:,1) = flip_vec(workingarea(:,1), len);
    end
end

function vec = flip_vec(vec, len)
vec = len + 1 - vec;

function vec = crop(vec, top, left)
vec = vec';
vec(1,:) = vec(1,:) - top + 1;
vec(2,:) = vec(2,:) - left + 1;
vec = vec';

function vec = rot(alpha, vec, img_size, new_img_size)
vec = vec';
org_class = class(vec);
vec = double(vec);
rot_mat = [cos(alpha) -sin(alpha) ; sin(alpha) cos(alpha)];

vec(1,:) = vec(1,:) - img_size(1)/2;
vec(2,:) = vec(2,:) - img_size(2)/2;
vec = rot_mat * vec;
vec(1,:) = vec(1,:) + (new_img_size(1))/2;
vec(2,:) = vec(2,:) + (new_img_size(2))/2;

cmd = ['vec = ' org_class '(vec);'];
eval(cmd);
vec = vec';