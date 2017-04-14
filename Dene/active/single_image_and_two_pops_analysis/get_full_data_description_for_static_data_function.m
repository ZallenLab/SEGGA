function desc = get_full_data_description_for_static_data_function()

desc.area = 'cell areas in pixels';
% desc.peri = 'cell perimeters in pixels';
desc.num_sides = 'number of sides per cell';
% desc.circ = 'cell circularity  [1 -> (circle), 0 -> (infinitely irregular)]';
% desc.qVal = 'perimeter over sqrt(area) for all cells';
desc.nm = 'node multiplicities for each node';
desc.ecc = 'eccentricity of each cell (realsqrt(1 - (L2 ./ L1).^2)) [0 -> (isotropic) and 1 -> (anisotropic -> a line)]';
desc.cell_length = 'length of long axis of ellipse approximating the cell (pixels)';
desc.cell_width = 'length of minor axis (perpendicular to the long axis) of ellipse approximating the cell (pixels)';
desc.length_width_ratio = 'ratio of long to short axis';
desc.cell_angle = 'angle of major axis of cell with respect to horizontal axis of image (degrees)';
desc.cell_hor = 'horizontal length of cell (pixels)';
desc.cell_ver = 'vertical length of cell (pixels)';
desc.cell_hor_ver_ratio = 'ratio of horizontal to vertical dimensions of cell';
desc.int_ang = 'internal angles of all nodes, each with respect to all cells with which they are shared';
desc.pd = 'pattern deformation from Graner paper: realsqrt(L1_avg / L2_avg), where L1 and L2 are eigen values of the inertia tensor of the centers of a cell and its ngbrs';
