function c = cell_circularity(peri, area)
%returns the circularity over the minimal possible circularity 
%for a polygon with a given numebr of sides.
c = peri.^2 ./ (4*pi*area);

