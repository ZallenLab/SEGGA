function c = circle(r)

  c= getnhood(strel('disk', r, 0));
  return

    
    c = zeros(2*r+1,2*r+1);
  
  
  cx=r+1;
  cy=r+1;
  x = 0;
  y = r;
  p = (5 - r*4)/4;
	
  c(cx,cy-r:cy+r)=ones(1,2*r+1);
  c(cx-r:cx+r,cy)=ones(2*r+1,1);
  while (x < y) 
    x=x+1;
    if p < 0
      p = p + 2*x+1;
    else
      y=y-1;
      p = p + 2*(x-y)+1;
    end

    if (x == y) 
      c(cx + x, cy-y : cy + y) = ones(1,2*y+1);
      c(cx - x, cy-y : cy + y) = ones(1,2*y+1);
    elseif (x < y) 
      c(cx + x, cy-y : cy + y) = ones(1,2*y+1);
      c(cx - x, cy-y : cy + y) = ones(1,2*y+1);
      c(cx + y, cy-x : cy + x) = ones(1,2*x+1);
      c(cx - y, cy-x : cy + x) = ones(1,2*x+1);
    end
  end
