function [L1 L2 angle] = tensor_props(xx, xy, yy)
ind = xx < 0;  %make sure the tensor integrals were computed with a positive orientation
xx(ind) = -xx(ind);
yy(ind) = -yy(ind);
xy(ind) = -xy(ind);
xy = -xy; %tensor = [yy -xy; -xy xx];
trac = xx + yy;
dt = xx.*yy - xy.^2;
ind = (xx.*yy < xy.^2); %invalid data coming from invalid (= self interscting) polygons
dt(ind) = 0;
inner = (trac.^2)/4 - dt;
inner(inner<0) = 0;
L1 = trac / 2 + realsqrt(inner);
L2 = trac / 2 - realsqrt(inner);
L1(ind) = nan;
L2(ind) = nan;
%ratio = sqrt(L1 ./ L2);
angle = atan2(L1 - xx, xy);
ind = xy == 0 & xx < xy; 
angle(ind) = pi/2;

