function nlost_after_t0 = create_nlost_for_visual(indir)  

startdir = pwd;
cd(indir);
load topological_events_per_cell cells_lost_hist
load shift_info
if ~(shift_info < 0)
    display('movie starts after t0')
    nlost_after_t0 = cells_lost_hist;
    save('nlost_visual_special','nlost_after_t0');
    return;
end

nlost_at_tzero = cells_lost_hist(-shift_info,:);
nlost_after_t0 = zeros(size(cells_lost_hist));
nlost_after_t0(1:-shift_info,:) = 0;
afterzero_points = repmat(nlost_at_tzero,size(cells_lost_hist(-shift_info:end,:),1),1);
nlost_after_t0(-shift_info:end,:) = cells_lost_hist(-shift_info:end,:) - afterzero_points;




save('nlost_visual_special','nlost_after_t0');


