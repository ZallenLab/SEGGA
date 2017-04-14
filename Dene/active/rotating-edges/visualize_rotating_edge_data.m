function visualize_rotating_edge_data(ang,len,channel_info,dv_to_ap,dv_to_ap_times,timestep,save_dir,savename,extratxt)


timelen = size(channel_info(1).levels,1);
var_names = {'length','angle'};
for i = 1:length(channel_info)
    var_names = [var_names,{channel_info(i).name}];
end

timeindspossible = (timelen*2+1);
aligned_edge_data = nan(timeindspossible,length(var_names),length(dv_to_ap));

for ii = 1:length(dv_to_ap)
    temp_edge = dv_to_ap(ii);
    
    if isfield(dv_to_ap_times,'first_aps')
        timeinds = (1:timelen)+(timelen - dv_to_ap_times.first_aps(ii));
    else if isfield(dv_to_ap_times,'shrink_times_tested')
            timeinds = (1:timelen)+(timelen - dv_to_ap_times.shrink_times_tested(ii));
        else if isfield(dv_to_ap_times,'first_dvs')
                timeinds = (1:timelen)+(timelen - dv_to_ap_times.first_dvs(ii));
            end
        end
    end
    
    aligned_edge_data(timeinds,1,ii) = len(:,temp_edge);
    aligned_edge_data(timeinds,2,ii) = ang(:,temp_edge);
    
    for i = 1:length(channel_info)
        aligned_edge_data(timeinds,2+i,ii) = channel_info(i).levels(:,temp_edge)./channel_info(i).cell_avg.mean_edge_intensity';
    end
    
end
nexist = zeros(timelen,1);
nusable = zeros(timelen,1);

for time_ind = 1:timeindspossible
    nexist(time_ind) = sum(~isnan(aligned_edge_data(time_ind,2,:)));   
    nusable(time_ind) = sum(~isnan(aligned_edge_data(time_ind,1,:)));   
    
    if nusable(time_ind) < length(dv_to_ap)*0.4
        aligned_edge_data(time_ind,:,:) = nan;
    end
end


    

% % % % % % % % 
% % % % % % % % 
% % % % % % % % 
%  regular plot - timeseries
% % % % % % % % 
% % % % % % % % 
% % % % % % % %

figure;
legend_handles = [];
hold on;
aligned_angs = reshape(aligned_edge_data(:,2,:),size(aligned_edge_data,1),size(aligned_edge_data,3));
aligned_lens = reshape(aligned_edge_data(:,1,:),size(aligned_edge_data,1),size(aligned_edge_data,3));
clear('aligned_levels');
    for i = 1:length(channel_info)
        aligned_levels(i).levels = reshape(aligned_edge_data(:,2+i,:),size(aligned_edge_data,1),size(aligned_edge_data,3));
        if ~isempty(aligned_levels(i).levels);
            aligned_levels(i).levels = smoothen(aligned_levels(i).levels);
            aligned_levels(i).chan_name = channel_info(i).name;      
        end
    end
    
    

len_handle = plot(nanmean_dlf(aligned_lens)/30,'c', 'linewidth', 2);
ang_handle = plot(nanmean_dlf(aligned_angs)/90,'b', 'linewidth', 2);
legend_handles = [legend_handles, len_handle, ang_handle];
twocolors = [[0.8 0 0];[0 0.75 0]];

for i = 1:length(channel_info)
    tempmean = nanmean_dlf(aligned_levels(i).levels);
    temp_handle = plot(tempmean,'color',twocolors(i,:), 'linewidth', 2);
    legend_handles = [legend_handles, temp_handle];
    xvals = [1:length(tempmean)]';
    xvals = xvals(~isnan(tempmean));


% % %     best fit line
    a = polyfit(xvals,tempmean(~isnan(tempmean)),6);
    y1 = polyval(a,[1:length(tempmean)]);
%     tempcolor = interp1([0;1],[twocolors(i,:);[1,1,1]],0.5);
%     plot(y1,'color',tempcolor, 'linewidth', 2);
    
    aligned_levels(i).mean = tempmean;
    aligned_levels(i).bestfit = y1;
    aligned_levels(i).xvals = (([1:length(tempmean)] - timelen)*timestep/60);
    
end
ax1 = gca; % current axes

save('rotating_edges','aligned_levels');


twocolors = [[0.8 0 0];[0 0.75 0]];
for i = 1:length(channel_info)
    tempmean = nanmean_dlf(aligned_levels(i).levels);
    tempderiv = deriv(smoothen(tempmean));
    tempderiv(isnan(tempmean)) = nan;
    signchanges = give_sign_changes(tempderiv);
    deriv_zeros = signchanges;
    if ~isempty(deriv_zeros)
        scatter(deriv_zeros,tempmean(deriv_zeros),70,...
            'markerfacecolor',twocolors(i,:),...
            'markeredgecolor',twocolors(i,:));
        for ii = 1:length(deriv_zeros)
        line(deriv_zeros(ii)*ones(101,1),...
            [0:2/100:2]',...
            'color',twocolors(i,:));
        left_shift = 5;       
        text(deriv_zeros(ii)-left_shift,2.1,...
            num2str((deriv_zeros(ii)-timelen)*timestep/60),...
            'fontsize',9);
        end
    end
end


% mark the mid point of alignment
yvals = 0:0.1:2;
plot(ones(size(yvals))*timelen,yvals,'m','Parent',ax1);
% plot(1:timeindspossible,nusable/max(nusable),'color',[0.8 0.8 0]);
% plot(1:timeindspossible,nexist/max(nexist),'color',[0 0.8 0.8]);



% create manual grid lines
plot(1:timeindspossible,ones(size(timeindspossible)),'k','Parent',ax1);
plot(1:timeindspossible,ones(size(timeindspossible))*1.5,'k','Parent',ax1);

legtxt = {'length','angle'};
    for i = 1:length(channel_info)
        legtxt = [legtxt {channel_info(i).name}];
    end
legtxt = [legtxt {'alignment', '%n avialable', '%n exist'}];
legend(legend_handles,legtxt,'fontweight','bold');
set(ax1,'ylim',[0,2.2]);
ytickmarks = 0:0.2:2.2;
yticktxt = num2str(ytickmarks');
set(ax1,'ytick',ytickmarks,'yticklabel',yticktxt);


set(gca,'xlim',[timelen-30*60/timestep,timelen + 15*60/timestep]);
xlim = get(gca,'xlim');
% xtickmarks = 0:10:timeindspossible;
xtickmarks = xlim(1):60/timestep*5:xlim(2);
xticktxt = num2str(round(ceil(((xtickmarks - timelen)*timestep/60)')/5)*5);
set(gca,'xtick',xtickmarks,'xticklabel',xticktxt);

title(savename);

myylim = get(gca,'ylim');
myxlim = get(gca,'xlim');
myypos01 = ((myylim(2)-myylim(1))*9/10)+myylim(1);
myxpos01 = ((myxlim(2)-myxlim(1))*1/10)+myxlim(1);
myypos02 = ((myylim(2)-myylim(1))*8/10)+myylim(1);
myxpos02 = ((myxlim(2)-myxlim(1))*1/10)+myxlim(1);
text(myxpos01,myypos01,extratxt,'interpreter','none','fontsize',12,'fontweight','bold');

ntxt = ['n (max) = ',num2str(length(dv_to_ap))];
text(myxpos02,myypos02,ntxt,'interpreter','none','fontsize',12,'fontweight','bold');

xlabel('time (min)','fontsize',12,'fontweight','bold');
ylabel('norm. edge intensity (AU)','fontsize',12,'fontweight','bold');

ax2 = axes('XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
set(ax2,'xtick',[],'xticklabel',[]);
ylims_other = get(ax1,'ylim');
loc_of_one = 1 - (max(ylims_other) - 1)/diff(ylims_other)  + min(ylims_other);
sixth = loc_of_one/6;
a2_xticks = 0:sixth:loc_of_one;
a2_xticklabels = num2str([0:15:90]');
set(ax2,'xtick',[],'xticklabel',[]);
set(ax2,'ytick',a2_xticks,'yticklabel',a2_xticklabels);
ylabel(ax2,'angle','fontsize',12,'fontweight','bold');

	bname = [save_dir, filesep,[savename,'-rot-v-time-allchans']];
    saveas(gcf, [bname '.fig']);
    saveas(gcf, [bname '.pdf']);
    saveas(gcf, [bname '.tif']);
        close(gcf);



    

    
    
    
    
    
phasespc_bool = false;
    
    
    
% % % % % % % % 
% % % % % % % % 
% % % % % % % % 
%  phase space angle to intensity
% % % % % % % % 
% % % % % % % % 
% % % % % % % %
if phasespc_bool
    figure;
    hold on;
    aligned_angs = reshape(aligned_edge_data(:,2,:),size(aligned_edge_data,1),size(aligned_edge_data,3));
    aligned_lens = reshape(aligned_edge_data(:,1,:),size(aligned_edge_data,1),size(aligned_edge_data,3));
    clear('aligned_levels');
        for i = 1:length(channel_info)
            aligned_levels(i).levels = reshape(aligned_edge_data(:,2+i,:),size(aligned_edge_data,1),size(aligned_edge_data,3));
        end

    plot(nanmean_dlf(aligned_angs)/90,nanmean_dlf(aligned_lens)/30,'c', 'linewidth', 2);
    % plot(nanmean_dlf(aligned_angs)/90,'b', 'linewidth', 2);
    plot(nanmean_dlf(aligned_angs)/90,nanmean_dlf(aligned_levels(1).levels),'color',[0.8 0 0], 'linewidth', 2);
    if length(aligned_levels)>1
        plot(nanmean_dlf(aligned_angs)/90,nanmean_dlf(aligned_levels(2).levels),'color',[0 0.75 0], 'linewidth', 2);
    end

    % mark the mid point of alignment
    yvals = 0:0.1:2;
    meanangs = nanmean_dlf(aligned_angs)/90;
    plot(ones(size(yvals))*meanangs(timelen-1),yvals,'m');
    % plot(nanmean_dlf(aligned_angs)/90,nusable/max(nusable),'color',[0.8 0.8 0]);

    % create manual grid lines
    plot(0:.01:1,ones(size(0:.01:1)),'k');
    plot(0:.01:1,ones(size(0:.01:1))*1.5,'k');

    legtxt = {'length'};
        for i = 1:length(channel_info)
            legtxt = [legtxt {channel_info(i).name}];
        end
    legtxt = [legtxt {'alignment'}];
    legend(gca,legtxt,'fontweight','bold');
    set(gca,'ylim',[0,2.2]);
    ytickmarks = 0:0.5:2.2;
    yticktxt = num2str(ytickmarks');
    set(gca,'ytick',ytickmarks,'yticklabel',yticktxt);

    xtickmarks = 0:0.1:1;
    xticktxt = num2str(xtickmarks');
    set(gca,'xtick',xtickmarks,'xticklabel',xticktxt);

    title(savename);

    myylim = get(gca,'ylim');
    myxlim = get(gca,'xlim');
    myypos01 = ((myylim(2)-myylim(1))*17/20)+myylim(1);
    myxpos01 = ((myxlim(2)-myxlim(1))*1/10)+myxlim(1);
    myypos02 = ((myylim(2)-myylim(1))*8/10)+myylim(1);
    myxpos02 = ((myxlim(2)-myxlim(1))*1/10)+myxlim(1);
    
    text(myxpos01,myypos01,extratxt,'interpreter','none','fontsize',12,'fontweight','bold');

    ntxt = ['n (max) = ',num2str(length(dv_to_ap))];
    text(myxpos02,myypos02,ntxt,'interpreter','none','fontsize',12,'fontweight','bold');

    xlabel('angle (% of 2/pi)','fontsize',12,'fontweight','bold');
    ylabel('norm. edge intensity (AU)','fontsize',12,'fontweight','bold');

        bname = [save_dir, filesep,[savename,'-rot-v-Angle-allchans']];
        saveas(gcf, [bname '.fig']);
        saveas(gcf, [bname '.pdf']);
        saveas(gcf, [bname '.tif']);
        close(gcf);
        
end

return


    tempsavedir_start = 'save_dir';
    [short_dir long_dir] = strtok(fliplr(pwd),filesep);
    [spec_dir long_dir] = strtok(long_dir,filesep);
    spec_dir = fliplr(spec_dir);
    [group_dir long_dir] = strtok(long_dir,filesep);
    group_dir = fliplr(group_dir);
    tempsavedir = [tempsavedir_start,filesep,group_dir,filesep,spec_dir,filesep];
    if ~isdir(tempsavedir)
        mkdir(tempsavedir)
    end

	bname = [tempsavedir, filesep,[savename,'-rot-v-Angle-allchans']];
    saveas(gcf, [bname '.pdf']);
    close(gcf);
    
    
    
    
    

return

% old visualization



% normalize dv_to_aps
dv_to_ap_angs = ang(:,dv_to_ap);
dv_to_ap_levels = channel_info(channum).levels(:,dv_to_ap);
for i = 1:length(dv_to_ap)
    dv_to_ap_levels(:,i) = dv_to_ap_levels(:,i)./channel_info(channum).cell_avg.mean_edge_intensity';
end

dv_to_ap_levels = smoothen(dv_to_ap_levels);
[ang_means, ang_bins] =  give_mean_per_angle(dv_to_ap_angs,dv_to_ap_levels);


% normailze ap_to_dv
ap_to_dv_angs = ang(:,ap_to_dv);
ap_to_dv_levels = channel_info(channum).levels(:,ap_to_dv);
for i = 1:length(ap_to_dv)
    ap_to_dv_levels(:,i) = ap_to_dv_levels(:,i)./channel_info(channum).cell_avg.mean_edge_intensity';
end
% [ang_means, ang_bins] =  give_mean_per_angle(ap_to_dv_angs,ap_to_dv_levels);

ap_to_dv_levels = interp_pol(ap_to_dv_levels);
ap_to_dv_levels  = smoothen(ap_to_dv_levels );
[ang_means, ang_bins] =  give_mean_per_angle(ap_to_dv_angs,ap_to_dv_levels);


% % figure;
% plot(ang_bins, ang_means,'b');
% legend({'dv to ap', 'ap to dv'});
% title(channel_info(channum).name);
% 
% plot(ones(size(ang_bins)),'m');


% figure;
% hold on
% plot(nanmean_dlf(dv_to_ap_levels),'g');
% plot(nanmean_dlf(ap_to_dv_levels),'b');
% plot(ones(size(nanmean_dlf(ap_to_dv_levels))),'m');

% figure; scatter(dv_to_ap_angs(:),dv_to_ap_levels(:),5,'filled');