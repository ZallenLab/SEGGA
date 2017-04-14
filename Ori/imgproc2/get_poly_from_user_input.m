function [x, y] = get_poly_from_user_input()
%%% [X,Y] = ginput(N)
%%% 'x' and 'y'  below refer to the vertical and horizontal placement respectively
%%% from help: [x,y] = ginput(n)


% [a y x] = roipoly;

% y = y';
% x = x';
% y = y(1:end-1); %roipoly produces a closed poly.
% x = x(1:end-1);
x=[]; y=[]; l=[];
[yin,xin, b] = ginput(1);
while ~isempty(xin) & b ~= 27 & b ~= 3;
  l(end+1) = plot(yin,xin,'b*', 'MarkerSize',12);
  if ~isempty(x) 
    l(end+1) = plot([y(end) yin],[x(end) xin],'r');
  end
  x(end+1)=xin;
  y(end+1)=yin;
  last_b = b;
  [yin,xin, b] = ginput(1);
end
delete(l);
