function [xout yout area] = poly_centroid(x,y,dim)
%poly_centroid Centroid of polygon. Based on Mathworks' polyarea. --Ori 2008
%   poly_centroid(X,Y) returns the x and y coordinated of the centroid 
%   (= center of mass, when mass is uniformly distributed) of the polygon 
%   specified by the vertices in the vectors X and Y.  If X and Y are 
%   matrices of the same size, then poly_centroid returns the centroids of
%   polygons defined by the columns X and Y.  If X and Y are
%   arrays, poly_centroid returns the centroids of the polygons in the
%   first non-singleton dimension of X and Y.  
%
%   The polygon edges must not intersect.  If they do, poly_centroid
%   returns the centroid of the difference between the clockwise
%   encircled areas and the counterclockwise encircled areas.
%
%   poly_centroid(X,Y,DIM) returns the centroid of the polygons specified
%   by the vertices in the dimension DIM.
%
%   Class support for inputs X,Y:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/03/02 21:47:55 $

if nargin==1 
  error('poly_centroid:NotEnoughInputs', 'Not enough inputs.'); 
end

if ~isequal(size(x),size(y)) 
  error('poly_centroid:XYSizeMismatch', 'X and Y must be the same size.'); 
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
  area = -reshape((sum( (x([2:siz(1) 1],:) - x(:,:)).* ...
                 (y([2:siz(1) 1],:) + y(:,:)))/2),[1 siz(2:end)]);

  xout = reshape((sum( (x([2:siz(1) 1],:) + x(:,:)).* ...
     (x(:,:).*y([2:siz(1) 1],:) - x([2:siz(1) 1],:).*y(:,:)))),[1 siz(2:end)]);

  yout = reshape((sum( (y([2:siz(1) 1],:) + y(:,:)).* ...
     (x(:,:).*y([2:siz(1) 1],:) - x([2:siz(1) 1],:).*y(:,:)))),[1 siz(2:end)]);

  xout = xout ./ (6 * area);
  yout = yout ./ (6 * area);
else

end

if nargin==2,
  xout = shiftdim(xout,-nshifts);
  yout = shiftdim(yout,-nshifts);
elseif nargin==3,
  xout = ipermute(xout,perm);
  yout = ipermute(yout,perm);
end
