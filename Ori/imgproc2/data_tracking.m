function data = data_tracking(seq, orbit)
[pathstr, name, ext, versn] = fileparts(seq.frames(orbit(1)).filename);
filename = [name '_data.mat'];
f = load(filename);
cells_fields = fieldnames(f.data.cells);
edges_fields = fieldnames(f.data.edges);
for j = 1:length(cells_fields);
    data.cells.(cells_fields{j}) = nan(length(orbit), ...
                                   length(seq.cells_map(1,:)), ...
                                   length(f.data.cells.(cells_fields{j})(1,:)), 'single');

end
for j = 1:length(edges_fields);
    data.edges.(edges_fields{j}) = nan(length(orbit), ...
                                   length(seq.edges_map(1,:)), ...
                                   length(f.data.edges.(edges_fields{j})(1,:)), 'single');
end

data.nodes.mult = zeros(length(seq.cells_map(:,1)), 2);
data.nodes.selected = false(size(data.nodes.mult));

data.edges.selected = false(size(data.edges.selected));
data.cells.selected = false(size(data.cells.selected));

% 
% data.edges.len_vel = -eps('single');
% data.cells.area = -eps('single');

for k = 1:length(orbit)
    i = orbit(k);
    [pathstr, name, ext, versn] = fileparts(seq.frames(i).filename);
    filename = [name '_data.mat'];
    f = load(filename);
    num_cells = length(f.data.cells.(cells_fields{j}));
    for j = 1:length(cells_fields);
        data.cells.(cells_fields{j})(k,seq.inv_cells_map(i,1:num_cells),:) = ...
            f.data.cells.(cells_fields{j});        
    end
    for j = 1:length(edges_fields);
        data.edges.(edges_fields{j})(k,nonzeros(seq.inv_edges_map(i,:)),:) = ...
            f.data.edges.(edges_fields{j})(find(seq.inv_edges_map(i,:)));
    end
    data.nodes.mult(k, 1:length(f.data.nodes.mult)) = f.data.nodes.mult;
    data.nodes.selected(k, 1:length(f.data.nodes.mult)) = f.data.nodes.selected;
end


data.frames_t = [seq.frames(orbit).t];
data.frames_z = [seq.frames(orbit).z];

data.edges.len_vel = vel_deriv(data.edges.len, 5);

% 
% w=2;
% smooth_len = smoothen(data.edges.len, w);
% data.edges.len_vel = smooth_len(1:end,:) - ...
%     [repmat(smooth_len(1,:), 2*w +1, 1) ; smooth_len(1:end - 2*w - 1,:)];
% 
% smooth_area = smoothen(data.cells.area, w);
% data.cells.area_vel = smooth_area(1:end,:) - ...
%     [repmat(smooth_area(1,:), 2*w +1, 1) ; smooth_area(1:end - 2*w - 1,:)];
% 
% 
% 
