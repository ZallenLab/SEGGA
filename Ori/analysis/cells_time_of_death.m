function [time_of_disappearance num_cells_measured] = cells_time_of_death(data, seq, min_area, time_window)

num_frames = length(data.cells.area(:, 1));
num_cells = length(data.cells.area(1, :));

time_of_disappearance = zeros(1, num_cells);
cells = sum(data.cells.selected) > time_window;
num_cells_measured = nnz(cells);
num_cells_measured_time = zeros(1, length(seq.frames));
for i = find(cells)
    last_alive = find(data.cells.area(:, i) > 0, 1, 'last');
    if last_alive == num_frames;
        continue
    end
    time_range = max(1, (last_alive-time_window)):last_alive;
    time_range = time_range(data.cells.selected(time_range, i));
    num_cells_measured_time(time_range) = num_cells_measured_time(time_range) + 1;
    
    if data.cells.selected(last_alive, i) && ~isempty(time_range) && ...
            min(data.cells.area(time_range, i)) < min_area && ...
            neighbors_still_view(data, seq, i, last_alive)
        time_of_disappearance(i) = last_alive + 1;
    end
end
num_cells_measured = mean(sum(data.cells.selected, 2));

function flag = neighbors_still_view(data, seq, cell, frame_num)
[nghbrs l_nghbrs] = get_cell_nghbrs_global(seq, cell, frame_num);
flag = all(data.cells.selected(frame_num + 1, nghbrs));
flag = flag && length(nghbrs) == length(l_nghbrs);
