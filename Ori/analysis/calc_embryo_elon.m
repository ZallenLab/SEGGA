function [hor ver num_cells L1 L2 angle] = calc_embryo_elon(seq, data, shift_value, num_frms, cells)

if nargin < 1 || isempty(seq)
   load('analysis','seq');
end

if nargin < 2 || isempty(data)
   load('analysis','data');
end
if nargin < 3 || isempty(shift_value)
    shift_value = 0;
end
if nargin < 4 || isempty(num_frms)
    num_frms = 80;
end
if nargin < 5 || isempty(cells)
    load('cells_for_elon');
end

if shift_value > 0
    disp('shift value adjusted');
    seq.directory
    'shift value was' 
    shift_value
    shift_value = 0;
end

if nargin < 5 || isempty(cells)
    if -shift_value + num_frms > length(data.cells.selected(:, 1))
        disp('num_frms adjusted');
        seq.directory
        num_frms = length(data.cells.selected(:, 1)) + shift_value;
    end
    time_range = -shift_value + (1:(num_frms));
    cells = all(data.cells.selected(time_range, :));
end
L1 = nan(1, length(seq.frames));
L2 = L1;
angle = L1;
for i = 1:length(seq.frames)
    l_cells = seq.cells_map(i, cells);
%     if all(data.cells.selected(i, cells))
     if all(l_cells) > 0
        geom = seq.frames(i).cellgeom;
        x = geom.circles(l_cells, 2);
        y = geom.circles(l_cells, 1);
        [xx yy xy] = inertia_tensor_discrete(x(:), y(:));
        [L1(i) L2(i) angle(i)] = tensor_props(xx, xy, yy);
    end
end
L1(L1 == 0) = nan;
L2(L2 == 0) = nan;
L1 = realsqrt(L1);
L2 = realsqrt(L2);
hor = sqrt((L1 .* cos(angle)).^2 + (L2 .* sin(angle)).^2);
ver = sqrt((L1 .* sin(angle)).^2 + (L2 .* cos(angle)).^2);
num_cells = nnz(cells);