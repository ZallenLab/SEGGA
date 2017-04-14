%EXTRACT_GEOMETRY Obtains nodes and edges from a labeled image.
%
% Rodrigo Fernandez-Gonzalez
% fernanr1@mskcc.org
% 2007/10/08

function [nodes edges cellnodes] = extract_geometry(im2D, nodes, cube_sz)

if nargin < 3
	cube_sz = [3 3 1];
end

if nargin < 2
	nodes = [];
end

% Just in case only two parameters are supplied and the second is not the node list but the cube size.
if (~isempty(nodes)) & numel(nodes) < 4
	cube_sz = nodes;
	nodes = [];
end

%gbin = findrosettes(im2D, [3 3 1], 2, 0, 0);
%sk = dip_image(bwmorph(double(gbin),'skel',inf));

bgid = max(im2D) + 1;
im2D(im2D == 0) = bgid;

% Find nodes.
fprintf('Looking for nodes ...\n');

% If no nodes were provided, find them with findrosettes.
if isempty(nodes)
	nodes_im = findrosettes(im2D, cube_sz, 3, 0, 0);
	nodes_im = label(nodes_im, 2);
	%overlay(squeeze(im2D), nodes_im)
	%overlay(sk, nodes_im) % This image shows an intermediate between your segmentation results and finding of the nodes.
	m = measure(nodes_im, [], 'Center', [], 2);
	nodes = round(double(m(1:max(nodes_im))'));
	nodes = nodes(:, 1:2);
% But if the node positions were provided, use them.
else
	nodes = circshift(nodes, [0 1]);
	nodes_im = dip_image(zeros(size(im2D, 2), size(im2D, 1)), 'uint16');
	for ii = 1:size(nodes, 1)
		if (~ isempty(find(edges == ii))) & nodes(ii, 1) <= size(nodes_im, 1) & nodes(ii, 2) <= size(nodes_im, 2)
			nodes_im(nodes(ii, 1)-1, nodes(ii, 2)-1) = ii;
		end
	end

	nodes_im = dilation(nodes_im, 3, 'rectangular');
end

% Find [node cell] matrix.
fprintf('Looking for edges ...\n');
nodecells = [];
jj = 0;

for i = 1:size(nodes, 1)
	large_node = dilation((nodes_im == i), 3, 'rectangular');
	tmp = unique(double(im2D(large_node)));
	
	for kk = 1:numel(tmp)
		jj = jj + 1;
		nodecells(jj, 1:2) = [i tmp(kk)];
	end
end	

ind = find(nodecells(:, 2) ~= bgid);
nodecells = nodecells(ind, :);

% Now find [cell node] matrix.
[tmp, ind] = sort(nodecells(:, 2));
cellnodes = circshift(nodecells(ind, :), [0 1]);

nnodes = [];
thecells = unique(cellnodes(:, 1));

for i = 1:numel(thecells)
	thiscell = thecells(i);
	ind = find(cellnodes(:, 1) == thiscell);
	nnodes(i) = numel(ind);
end

% Remove cells with less than 3 sides.
keepcells = find(nnodes >= 3);
nnodes = nnodes(keepcells);
thecells = thecells(keepcells);
ind = find(ismember(cellnodes(:, 1), thecells));
cellnodes = cellnodes(ind, :);


% Find edges.
m = measure(im2D, [], 'Center', thecells);
centers = round(m.Center');
centers = centers(:, 1:2);
edges = [];
jj = 0;

for i = 1:numel(thecells)
	ind = find(cellnodes(:, 1) == thecells(i));
	ind = cellnodes(ind, 2);
	
	tmpnodes = nodes(ind, 1:2);
	tmpnodes = tmpnodes - repmat(centers(i, :), [size(tmpnodes, 1) 1]);
	
	[th r] = cart2pol(tmpnodes(:, 1), tmpnodes(:, 2));
	indth = find(th < 0);
	th(indth) = 2 * pi + th(indth);	
	[tmp order] = sort(th); % Counter-clockwise order.
	ind = ind(order);
	
	for kk = 1:numel(order)
		if kk ~= numel(order)
			if ~ isempty(edges)
				alreadythere = find(edges(:, 1) == ind(kk) & edges(:, 2) == ind(kk + 1));
				if isempty(alreadythere)
					alreadythere = find(edges(:, 1) == ind(kk + 1) & edges(:, 2) == ind(kk));
				end
			
				if isempty(alreadythere)
					jj = jj + 1;
					edges(jj, 1:2) = [ind(kk) ind(kk+1)];
				end
			else
				jj = jj + 1;
				edges(jj, 1:2) = [ind(kk) ind(kk+1)];
			end
		else
			if ~ isempty(edges)
				alreadythere = find(edges(:, 1) == ind(kk) & edges(:, 2) == ind(1));
				if isempty(alreadythere)
					alreadythere = find(edges(:, 1) == ind(1) & edges(:, 2) == ind(kk));	
				end
			
				if isempty(alreadythere)
					jj = jj + 1;
					edges(jj, 1:2) = [ind(kk) ind(1)];
				end
			else
				jj = jj + 1;
				edges(jj, 1:2) = [ind(kk) ind(1)];
			end
		end
	end
end
fprintf('\nDone!\n');

% Modify nodes and edges so that the output geometry looks like the one in the
% segmented image (see plot_geometry).
nodes = circshift(nodes, [0 1]);
edges = sort(edges, 2);
