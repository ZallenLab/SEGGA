
function binAngH = ...
    bin_by_angles_test_orientation(seq,data,edges,ang,len,...
    levels,...
    shift_info,time_step,dir_name, segdirname, imgdirname)


temp_ylims = [0, 35];
ang_incr_size = 5;
bins = (0:ang_incr_size:175); 
ind = data.edges.selected;% & data.edges.len > 10;
ind = ind(:, edges);
bin_ind = zeros(size(ind));
for j = 1:length(bins);
    bin_ind(ang >= bins(j)) = j;
end
ang_bins = zeros(length(seq.frames), length(bins));

for i = 1:length(seq.frames)
    indind = ind(i, :) & ~isnan(levels(i, :));
    ang_bins(i, :) = accumarray(bin_ind(i, indind)', squeeze(levels(i, indind)), size(bins'), @mean)';
    
end



for j = 1:length(bins)
    leg{j} = sprintf('%d\\circ - %d\\circ', bins(j), bins(j) + (bins(2) - bins(1)));
end



    
%     figure;
%     bar(bins,ang_bins(1,:));
%     myylim = [min(ang_bins(1,:)),max(ang_bins(1,:))];
%     set(gca,'ylim', myylim);
    
%     check out the dist, the min, the max, the interval, possible shifts
%     of angular coordinate orientation

% distance away from 90 degrees where the interval is still considered
% meaningful

    thresh_away_from_ninety = 20;
    
    smoothangbins = smoothen(smoothen(ang_bins(1,:)));
    [minval,imin] = min(smoothangbins);
    [maxval,imax] = max(smoothangbins);
    minang = bins(imin)+ ang_incr_size/2;
    maxang = bins(imax)+ ang_incr_size/2;
    
    display(['min intensity angle = ',num2str(minang)]);
    display(['max intensity angle = ',num2str(maxang)]);
    
    %%% TO DO: Implement automatic shifting of coordinate orientation
    %%% Based on angular distribution of intensities (user -guided)
    dist_min_to_max = diff([minang,maxang]);
    dist_from_ninety = abs(diff([dist_min_to_max,90]));
    
    if dist_from_ninety > thresh_away_from_ninety
%         display('distribution not structured well enough for a coordinate orientation shift');
%         return
    end
    
    shift_to_fix_min = diff([minang,90]);
    
    %%%% have to make sure this works for the [0,90] side as well as the
    %%%% [90,180] side. wrap values above 180. 
    if shift_to_fix_min >= 0 
        %%% need a right shift for min, then look to shift the max right also
        shift_to_fix_max = diff([maxang,180]);
    else
        %%% need a left shift, then look to shift the max to the left also
        shift_to_fix_max = diff([maxang,0]);
    end
    
    if abs(shift_to_fix_max) > thresh_away_from_ninety
        display('problem in calculating separate shifts');
    end
    
    if sign(shift_to_fix_min*shift_to_fix_max) ==-1
        display('adjustment shifts for max and min are in different directions');
    end
    
    %%% need to shift in opposite direction (reason unclear)
    rotalpha = -mean([shift_to_fix_min,shift_to_fix_max]);
    
    binAngH = figure;
    bar(bins,smoothangbins);
    myylim = [min(ang_bins(1,:)),max(ang_bins(1,:))];
    set(gca,'ylim', myylim);
    
    rotate_action = false;
if rotate_action == true
    
%     rotdir = pwd;
    cd(segdirname);
    rot_all_dlf(segdirname, rotalpha);
    cd(imgdirname);
    % shift goes in the expected direction when using this function (hence
    % minus sign to reverse the previous adjustment)
    rot_img_dir(-rotalpha);
end
    
    
    


