function auto_limit = limit2embryo(img, weak_signal)
if nargin < 2
    weak_signal = false;
end
t = graythresh(nonzeros(img));
h = imhist(nonzeros(img));
% if t < 0.99
%     [dummy i] = max(h(round(t * 255) + 1:end - 2));
% end
%a = bwareaopen(im2bw(img,(i/255 + t)), 10);
if weak_signal
    a = bwareaopen(im2bw(img,0.3*t), 10);
else
    a = bwareaopen(im2bw(img,0.7*t), 10);
end
[x, y] = size(a);
[x, y] = meshgrid(1:y, 1:x);
x = x.*a;
y = y.*a;
x(~a) = NaN;
y(~a) = NaN;
bnd1 = min(x');
bnd2 = min(y);
bnd3 = max(x');
bnd4 = max(y);
x = [bnd1 1:length(bnd2) bnd3 1:length(bnd4)];
y = [1:length(bnd1) bnd2 1:length(bnd3) bnd4];
ind = isnan(x) | isnan(y);
x = x(~ind);
y = y(~ind);
ch = convhull(x, y);
x = x(ch);
y = y(ch);
auto_limit = [y' x'];
