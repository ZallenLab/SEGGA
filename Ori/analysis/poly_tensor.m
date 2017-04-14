function [xx xy yy] = poly_tensor(x,y,dim)
%poly_tensor: inertia tensor of polygon. Based on Mathworks' polyarea and 
%John Burkardt's polygon_xx_2d etc. --Ori 2008



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DOES NOT NORMALIZE BY POLYGON AREA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==1 
  error('poly_tensor:NotEnoughInputs', 'Not enough inputs.'); 
end

if ~isequal(size(x),size(y)) 
  error('poly_tensor:XYSizeMismatch', 'X and Y must be the same size.'); 
end

if nargin==2,
  [x,nshifts] = shiftdim(x);
  y = shiftdim(y);
elseif nargin==3,
  perm = [dim:max(length(size(x)),dim) 1:dim-1];
  x = permute(x,perm);
  y = permute(y,perm);
end

siz = size(x);
if ~isempty(x),
  yy = reshape((sum( (x([2:siz(1) 1],:) - x(:,:)).* ...
                 (y([2:siz(1) 1],:).^3 + ...
                  y([2:siz(1) 1],:).^2 .* y(:,:) + ...
                  y([2:siz(1) 1],:)    .* y.^2 + ...
                  y.^3))) ...
                 ,[1 siz(2:end)]);

  yy = -yy ./ 12;

  xx = reshape((sum( (y([2:siz(1) 1],:) - y(:,:)).* ...
                 (x([2:siz(1) 1],:).^3 + ...
                  x([2:siz(1) 1],:).^2 .* x(:,:) + ...
                  x([2:siz(1) 1],:)    .* x.^2 + ...
                  x.^3))) ...
                 ,[1 siz(2:end)]);

  xx = xx ./ 12;

  xy = reshape((sum( (y([2:siz(1) 1],:) - y(:,:)).* (...
                 y([2:siz(1) 1],:) .* ...
                 (3*x([2:siz(1) 1],:).^2 + 2*x([2:siz(1) 1],:).* x + x.^2) + ...
                 y .* ...
                 (x([2:siz(1) 1],:).^2 + 2*x([2:siz(1) 1],:).* x + 3*x.^2) ...
                 ))) ...
                 ,[1 siz(2:end)]);
    xy = xy/24;
  
else

end

if nargin==2,
  xx = shiftdim(xx,-nshifts);
  yy = shiftdim(yy,-nshifts);
  xy = shiftdim(xy,-nshifts);
elseif nargin==3,
  xx = ipermute(xx,perm);
  yy = ipermute(yy,perm);
  xy = ipermute(xy,perm);
end

ind = xx < 0;  %make sure the tensor integrals were computed with a positive orientation
xx(ind) = -xx(ind);
yy(ind) = -yy(ind);
xy(ind) = -xy(ind);
