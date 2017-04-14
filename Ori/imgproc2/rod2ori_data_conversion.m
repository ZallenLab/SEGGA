function rod2ori_data_conversion(filename, directory)
[tP, tN, tE] = fileparts(filename);
directory = tP;
if nargin < 2 || isempty(directory)
    directory = pwd;
end
cd(directory);
s = load(filename);

for i = 1:length(s.geom)
    cellgeom = convert_geom(s.geom(i));
    procstate = 7;
    save(['convgeom' num2str(i) '.mat'], 'cellgeom', 'procstate');
end

function geom = convert_geom(geom);
temp = unique(geom.nodecellmap(:, 1), 'legacy');
inv_map(temp) = 1:length(temp);
geom.nodecellmap(:, 1) = inv_map(geom.nodecellmap(:, 1));

[n_c_unique, n_c, dummy2] = unique(geom.nodecellmap(:,1), 'legacy');
n_c_s = [0 n_c(1:end - 1)'];
cell_centers = nan(length(temp) , 2);

for cnt =1:length(temp)
    nmap = geom.nodecellmap((n_c_s(cnt) + 1):n_c(cnt),2);
    cell_centers(cnt, :) = mean(geom.nodes(nmap, :));
end
 
        
%find the phase angle of each node relative to the cell center.
    nodes_vectors = geom.nodes(geom.nodecellmap(:, 2), :)...
        -cell_centers(geom.nodecellmap(:, 1), :);
    angles = atan2(nodes_vectors(:,1), nodes_vectors(:,2));

% sort the nodes cells list according to cell and then according the node 
%phase angle

nodes_cells = sortrows(...
    [double(geom.nodecellmap)...
    -angles], [1 3]);
geom.nodecellmap = nodes_cells(:, 1:2);
geom = fix_geom(geom);