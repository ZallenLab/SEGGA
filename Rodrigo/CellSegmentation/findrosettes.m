%  out = findrosettes(in, cube_sz)
%  out = findrosettes(in, cube_sz, rosette_size)
%  out = findrosettes(in, cube_sz, rosette_size, exact_flag)
%
%  Looks for rosettes in a three-dimensional image (dimension three can equal 1, though). Uses findrosettes2, a C function, for this purpose.
%  
%  IN is a 3D (MxNxZ) labeled image.
%  CUBE_SZ is 3-element vector containing the row (height), col (width) and Z (depth)
%  size of a cube that will be dragged along image IN looking for places where multiple 
%  cells (labels) are included in the cube.
%  ROSETTE_SIZE is a number indicating the minimum or exact size of the rosettes sought.
%  EXACT_FLAG indicates whether rosettes of size equal to (1) or equal or larger than (0)
%  ROSETTE_SIZE should be looked for.
%
%  OUT is a 3D binary image where pixels are set to one if they are around a high order 
%  vertex (as defined by ROSETTE_SIZE).
%  
%  Many multiplications are repeated in the C code: room to optimize a bit!
%  
%  Rodrigo Fernandez-Gonzalez
%  fernanr1@mskcc.org
%  2/14/2007

function varargout = findrosettes(varargin)

if (isa(varargin{1}, 'dip_image'))
	varargin{1} = double(varargin{1});	
end

switch (nargin)
	case 2
		out_doubles = findrosettes2(varargin{1}, varargin{2});
	case 3
		out_doubles = findrosettes2(varargin{1}, varargin{2}, varargin{3});
	case 4
		out_doubles = findrosettes2(varargin{1}, varargin{2}, varargin{3}, varargin{4});
		
	case 5
		out_doubles = findrosettes2(varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5});

	otherwise
end

out_doubles = reshape(out_doubles, size(varargin{1}));

varargout{1} = dip_image(out_doubles, 'bin');
