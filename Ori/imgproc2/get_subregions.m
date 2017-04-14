function reg = get_subregions(a, grid_size, min_num_cells, cell_length, b)
%a is alist of cell positions
%reg is a logical 2d array of lists of cells in each region. If reg(i, j)
%is true then cell j is in region i. Each cell is part of exactly one
%region.
%grid_size is number of regions to have along each dimension.
%min_num_cells is the minimum average number of cells along each dimension
%of each region.
%cell_length is the expected average length of cells.
%b (optional) is a list of cells that determines the span of the grid.
if nargin < 2 || isempty(grid_size)
    grid_size = 8;
end
if nargin < 3 || isempty(min_num_cells)
    min_num_cells = 4;
end

if nargin < 5 || isempty(b)
    b = a;
end

max_x = max(b(1, :));
min_x = min(b(1, :));
max_y = max(b(2, :));
min_y = min(b(2, :));

if nargin < 4 || isempty(cell_length)
    cell_length = realsqrt((max_x - min_x) * (max_y - min_y) / size(a, 1));
end

region_size_x = region_size_one_dim(min_x, max_x, cell_length, min_num_cells, grid_size);
region_size_y = region_size_one_dim(min_y, max_y, cell_length, min_num_cells, grid_size);


x = min_x:region_size_x:(max_x - region_size_x/2);
reg_x = true(size(a, 2), length(x));
for cnt = 2:length(x);
    reg_x(:, cnt) = a(1, :) >= x(cnt);
end
for cnt = 1:(length(x)-1);
    reg_x(:, cnt) = reg_x(:, cnt) & ~reg_x(:, cnt+1);
end


y = min_y:region_size_y:(max_y - region_size_y/2);
reg_y = true(size(a, 2), length(y));
for cnt = 2:length(y);
    reg_y(:, cnt) = a(2, :) >= y(cnt);
end
for cnt = 1:(length(y)-1);
    reg_y(:, cnt) = reg_y(:, cnt) & ~reg_y(:, cnt+1);
end

reg = false(size(a, 2), size(reg_x, 2)*size(reg_y, 2));
cnt = 0;
for cnt_x = 1:size(reg_x, 2)
    for cnt_y = 1:size(reg_y, 2)
        cnt = cnt + 1;
        reg(:, cnt) = reg_x(:, cnt_x) & reg_y(:, cnt_y);
    end
end

 

function rs = region_size_one_dim(mn, mx, len, num_cells, def_gs);
%make sure the grid size will result in sub regions with at least num_cells
%along each dimension. len is the expected average length of cells.
rs = (mx - mn) / max(1, min(def_gs, floor(0.25 + (mx - mn)/(len * num_cells))));