function avrgs = seq2averages(seq, data, cells, shift_value, num_frms)
if nargin < 4 || isempty(shift_value) || shift_value > 0
    shift_value = 0;
end
if nargin < 5 || isempty(num_frms)
    num_frms = 80;
end
if -shift_value + num_frms > length(data.cells.selected(:, 1))
    disp('num_frms adjusted');
    seq.directory
    num_frms = length(data.cells.selected(:, 1)) + shift_value;
end
time_range = -shift_value + (1:(num_frms));

if nargin < 3 || isempty(cells)
    cells = any(data.cells.selected(time_range, :));
end

for i = 1:length(seq.frames)
    geom = seq.frames(i).cellgeom;
    l_cells = nonzeros(seq.cells_map(i, cells & data.cells.selected(i, :)));
    data_local = static_data_function(geom, l_cells);
    fns = fieldnames(data_local);
    for j = 1:length(fns)
        fn = fns{j};
        if length(data_local.(fn)) == 1; %% not needed
            avrgs.(fn)(i) = data_local.(fn).avg;
            avrgs.([fn '_std_over_mean'])(i) = data_local.(fn).std ./ data_local.(fn).avg;
        end
    end
    avrgs.cell_angle_std_over_mean(i) = data_local.cell_angle.std / 45;
    avrgs.top_dis = (avrgs.num_nghbrs_std_over_mean .* avrgs.num_nghbrs).^2;
end
    