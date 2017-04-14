function varargout = inv_gradient(f,varargin)
%GRADIENT Approximate inv_gradient.
%modified from Matlab builtin function

[err,f,ndim,loc,rflag] = parse_inputs(f,varargin);
if err, error(message('MATLAB:gradient:InvalidInputs')); end

% Loop over each dimension. Permute so that the gradient is always taken along
% the columns.

if ndim == 1
  perm = [1 2];
else
  perm = [2:ndim 1]; % Cyclic permutation
end

for k = 1:ndim
   [n,p] = size(f);
   h = loc{k}(:);   
   g  = zeros(size(f),class(f)); % case of singleton dimension

   % Take forward sums on left and right edges
   if n > 1
      g(1,:) = (f(2,:) + f(1,:))/(h(2)-h(1));
      g(n,:) = (f(n,:) + f(n-1,:))/(h(end)-h(end-1));
   end

   % Take centered sums on interior points
   if n > 2
      h = h(3:n) + h(1:n-2);
      g(2:n-1,:) = (f(3:n,:)+f(1:n-2,:))./h(:,ones(p,1));
   end

   varargout{k} = ipermute(g,[k:max(ndim,2) 1:k-1]);

   % Set up for next pass through the loop
   f = permute(f,perm);
end 

% Swap 1 and 2 since x is the second dimension and y is the first.
if ndim>1
  tmp = varargout{1};
  varargout{1} = varargout{2};
  varargout{2} = tmp;
end

if rflag, varargout{1} = varargout{1}.'; end


%-------------------------------------------------------
function [err,f,ndim,loc,rflag] = parse_inputs(f,v)
%PARSE_INPUTS
%   [ERR,F,LOC,RFLAG] = PARSE_INPUTS(F,V) returns the spacing
%   LOC along the x,y,z,... directions and a row vector
%   flag RFLAG. ERR will be true if there is an error.

err = false;
loc = {};
nin = length(v)+1;

% Flag vector case and row vector case.
ndim = ndims(f);
vflag = 0; rflag = 0;
if iscolumn(f)
   ndim = 1; vflag = 1; 
elseif isrow(f) % Treat row vector as a column vector
   ndim = 1; vflag = 1; rflag = 1;
   f = f.';
end;
   
indx = size(f);

% Default step sizes: hx = hy = hz = 1
if nin == 1, % gradient(f)
   loc = cell(1, ndims(f));
   for k = 1:ndims(f)
      loc(k) = {1:indx(k)};
   end;

elseif (nin == 2) % gradient(f,h)
   % Expand scalar step size
   if (length(v{1})==1)
      loc = cell(1, ndims(f)); 
      for k = 1:ndims(f)
         h = v{1};
         loc(k) = {h*(1:indx(k))};
      end;
   % Check for vector case
   elseif vflag
      loc(1) = v(1);
   else
      err = true;
   end

elseif ndims(f) == numel(v), % gradient(f,hx,hy,hz,...)
   % Swap 1 and 2 since x is the second dimension and y is the first.
   loc = v;
   if ndim>1
     tmp = loc{1};
     loc{1} = loc{2};
     loc{2} = tmp;
   end

   % replace any scalar step-size with corresponding position vector
   for k = 1:ndims(f)
      if length(loc{k})==1
         loc{k} = loc{k}*(1:indx(k));
      end;
   end;

else
   err = true;

end
