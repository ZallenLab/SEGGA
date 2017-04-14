function p=drawcircle(cx,cy,r,varargin)

  washold = ishold;
  hold on
  t=linspace(0,2*pi,20);
  x=cx+r*sin(t);
  y=cy+r*cos(t);
  p = plot(x,y,varargin{:},'LineWidth',0.3,'Color','c');
  
%   if washold == 0
%     hold off
%   end
  
