function measurements = odds_and_ends(data, seq, t_start, t_end, time_window)


%NUMBER OF DISAPPEARING CELLS
min_area = mean(data.cells.area(1, data.cells.selected(1, :)));
[t_dis num_cells_measured] = cells_time_of_death(data, seq, min_area, time_window);
for i = 1:length(seq.frames)
    acc_dead(i) = nnz(nonzeros(t_dis) <= i);
end
if nargin < 3 || isempty(t_start)
    t_start = 1;
end
if nargin < 4 ||isempty(t_end)
	t_end = length(acc_dead);
end
measurements.num_cells_dead = acc_dead(t_start:t_end) / num_cells_measured;

%Texture tensor (Graner's pattern deformation)
[measurements.pat_defo, measurements.pat_defo_full] = defo_from_seq_full(seq, data.cells.selected);