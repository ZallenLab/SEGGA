function c = centroid(v)
[xout yout] = poly_centroid(v(:, 1), v(:, 2));
c = [xout yout];

return
% Returns the centroid of the vertices in the list v

  A = area(v);
  if A > 0 
    c = [ sum((v(1:end,1)+v([2:end 1],1)).*(v(1:end,1).*v([2:end 1],2)-v([2:end 1],1).*v(1:end,2))) ...
	  sum((v(1:end,2)+v([2:end 1],2)).*(v(1:end,1).*v([2:end 1],2)-v([2:end 1],1).*v(1:end,2))) ]/(6*A);
      % Detect sign error
      mv = mean(v);
      d1 = (mv(1)-c(1))^2 + (mv(2)-c(2))^2;
      d2 = (mv(1)+c(1))^2 + (mv(2)+c(2))^2;
      if d1 > d2
        c = -c;
      end
else
    c = v(1,:);
end