function [connecting_line flipped] = connect_line(pt1, pt2)

flipped = false;
if abs(pt1(1) - pt2(1)) < abs(pt1(2) - pt2(2))
    pt1 = pt1([2 1]);
    pt2 = pt2([2 1]);
    flipped = true;
end
if pt1(1) < pt2(1)
    l = pt1(1):pt2(1);
else
    l = pt1(1):-1:pt2(1);
end
if round(l(end)) ~= round(pt2(1))
    l(end+1) = pt2(1);
end
connecting_line = zeros(2, length(l));
connecting_line(1,:) = l;
if pt1(2) == pt2(2) || length(l) == 1
    connecting_line(2,:) = pt1(2);
else
    connecting_line(2,:) = pt1(2):(pt2(2) - pt1(2))/(length(l)-1):pt2(2);
end

if flipped
    connecting_line = connecting_line([2 1], :);
end
connecting_line = round(connecting_line);