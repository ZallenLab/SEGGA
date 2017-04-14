function data = invert_data_time(data)
fields = fieldnames(data.edges);
for i = 1:length(fields)
    data.edges.(fields{i}) = data.edges.(fields{i})(end:-1:1, :);
end
fields = fieldnames(data.cells);
for i = 1:length(fields)
    data.cells.(fields{i}) = data.cells.(fields{i})(end:-1:1, :);
end