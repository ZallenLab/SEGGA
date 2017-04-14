function geom = update_edgecell(geom)

%Do the whole nodes/edges shtick. See create_edges for details.
nodes_vectors = geom.nodes(geom.nodecellmap(:,2), :)...
    -geom.circles(geom.nodecellmap(:,1), 1:2);
angles = atan2(nodes_vectors(:,2), nodes_vectors(:,1));

nodes_cells = sortrows(...
        [single(geom.nodecellmap(:,1))...
        single(geom.nodecellmap(:,2))...
        angles ], [1 3]);
geom.nodecellmap = int16(nodes_cells(:,1:2));


geom.edges = create_edgecellmap(geom.nodecellmap);
geom.edges_length = realsqrt(sum((geom.nodes(geom.edges(:,1),:) - geom.nodes(geom.edges(:,2),:)).^2'));

%%%% mark cells with less than 3 nodes as invalid
zero_cells = setdiff(1:length(geom.circles(:,1)), nodes_cells(:,1), 'legacy');
[n_c_unique, n_c, dummy2] = unique(nodes_cells(:,1), 'legacy');
n_c_s = [0 n_c(1:end - 1)'];

faces = nan(length(n_c_unique), max(n_c - n_c_s'), 'single');

for cnt = 1:length(geom.circles(:, 1))
    nmap = geom.nodecellmap((n_c_s(cnt) + 1):n_c(cnt),2);
    faces(cnt, 1:length(nmap)) = nmap;
end

geom.faces = faces;


ugly_cells = ((n_c - n_c_s') < 3) & ((n_c - n_c_s') > 0);
ugly_cells = n_c_unique(ugly_cells);

valid = true(1,length(geom.circles(:,1)));
valid(zero_cells) = 0;
valid(ugly_cells) = 0;


geom.valid = valid;
