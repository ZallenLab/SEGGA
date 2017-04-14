function [avg_diff fns] = diff_indi_start_to_end(seq, data, start_time)
if start_time < 1

    cells_start = data.cells.selected(1, :);
    sel_cells = seq.cells_map(1, cells_start);
    [dummy full_data_start]= static_data_function(seq.frames(1).cellgeom, sel_cells);
    fns = fieldnames(full_data_start);
    avg_diff = nan(length(seq.frames), length(fns));
    return
%     disp(seq.directory);
%     disp(sprintf('start time adjusted from %d to 1', start_time));
%     start_time = 1;
end



cells_start = data.cells.selected(start_time, :);
sel_cells = seq.cells_map(start_time, cells_start);
[dummy full_data_start]= static_data_function(seq.frames(start_time).cellgeom, sel_cells);
fns = fieldnames(full_data_start);
avg_diff = nan(length(seq.frames), length(fns));
for i = 1:length(seq.frames)
    cells = data.cells.selected(i, :) & cells_start;
    cells_start_to_match = cells(cells_start);
    
    sel_cells = seq.cells_map(i, cells);
    
    if ~any(sel_cells)
        continue
    end
    [dummy full_data]= static_data_function(seq.frames(i).cellgeom, sel_cells);
    for j = 1:length(fns)
        norm_factor = full_data_start.(fns{j})(cells_start_to_match); 
        avg_diff(i, j) = mean(...
            (abs(full_data_start.(fns{j})(cells_start_to_match) - full_data.(fns{j}))...
            ./ norm_factor));
        %mean([full_data_start.(fns{j})(cells_start_to_match); full_data.(fns{j})]);
%         avg_diff(i, j) = avg_diff(i, j) ;
    end
    j = cellfun(@(x) strcmp(x, 'cell_angle'), fns);
    avg_diff(i, j) = mean(...
        (abs(full_data_start.(fns{j})(cells_start_to_match) - full_data.(fns{j}))...
        .* (full_data_start.length_width_ratio(cells_start_to_match) + ...
            full_data.length_width_ratio - 2) / 2)) / 90;
end