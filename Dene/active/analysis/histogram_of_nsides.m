function nsides_hist = histogram_of_nsides(data,bins)
nframes = size(data.cells.selected,1);
if nargin<2 || isempty(bins)
    extreme_max = 20;
    bins = [1:12,extreme_max];
    %%% extreme_max is necessary because values outside of any bin are
    %%% automatically mapped to zero, not the extreme bin
    nsides_hist = zeros(nframes,length(bins));
end

for i=1:nframes
    sel_frames = i;
    sel_cells = data.cells.selected(i,:);
    nsides_set = data.cells.num_sides(sel_frames,sel_cells);
    nsides_hist(i,:) = histc(nsides_set(:),bins);
end
    