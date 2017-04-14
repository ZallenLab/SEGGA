function SEGGA_shrink_ang_dist(input_settings)

            
% the use of 'all_dirs_separated'
% which gives full paths for each directory 
% makes it possible to use any set of directories,
% not just some set under the same path base dir
ftypes = input_settings.output_filetypes;

leg_txt = {input_settings.groups(:).label};
% old home [input_settings.movie_base_dir,filesep]                   
all_dirs_separated = give_structured_dir_list(filesep,input_settings.fullpath_dirnames,input_settings.groups);               




savedir = [input_settings.save_base_dir,filesep,'shrink-and-event-data',filesep];
if ~isdir(savedir)
    mkdir(savedir);
end
if ~isdir(savedir)
    errordlg('could not create save dir');
    return
end

    start_dir = pwd;
    clear list
    




for ii = 1:length(all_dirs_separated)
     
    shrink_list(ii).edge_ang_hists_repeat = [];
    shrink_list(ii).edge_ang_hist_mean_repeat = [];
    shrink_list(ii).edge_ang_hist_stderr_repeat = [];
    shrink_list(ii).groupname = leg_txt{ii};





    for i = 1:length(all_dirs_separated{ii})
    cd(all_dirs_separated{ii}{i});


     txtstr = cell(length(all_dirs_separated),1);

    load shrinking_edges_info_new
    load cells_for_t1_ros
%     load('analysis','data');
    load shift_info
    load('topological_events_per_cell','n_lost_per_cell',...
        'n_edges_ang', 'ang_bins','n_edges_ang_with_time','n_node_mult');
    load timestep

    
    
    aligned_ang_sh = mod(aligned_ang_sh, 180);
    ang = 90 - abs(90 - aligned_ang_sh);
    mean_ang = nan(1, size(ang, 2));
    indstart = floor((60/timestep*3));
    indend = floor((60/timestep*5));
    
    for edge = 1:length(aligned_ang_sh(1, :))
        temp_vals = ang(indstart:indend, edge);
        temp_vals = temp_vals(~isnan(temp_vals));
        mean_ang(edge) = mean(temp_vals);
        
        
    end
    step = 15;
    bins = 0:step:90;
    bin_labels = cell(length(bins),1);
    for j = 1:length(bins)
        bin_labels{j} = num2str(bins(j)+step);
    end
    bins(end) = 91;
    ang_hist = histc(mean_ang, bins) / nnz(~isnan(mean_ang));
    ang_hist = ang_hist(1:(end-1));
    
    txtstr{ii} = [txtstr{ii},num2str(floor((length(n_lost_per_cell) + shift_info)*15/60)),', '];

    ang_hist_repeat = n_edges_ang';
   
    if nnz(ang_hist_repeat)>0
    shrink_list(ii).edge_ang_hists_repeat = [shrink_list(ii).edge_ang_hists_repeat;ang_hist_repeat];

    end
    
    

    

    if size(shrink_list(ii).edge_ang_hists_repeat,1)>1    
        shrink_list(ii).edge_ang_hist_mean_repeat = mean(shrink_list(ii).edge_ang_hists_repeat);
        num = size(shrink_list(ii).edge_ang_hist_mean_repeat,2);
        shrink_list(ii).edge_ang_hist_stderr_repeat = std(shrink_list(ii).edge_ang_hists_repeat)./realsqrt(num);
    else
        shrink_list(ii).edge_ang_hist_mean_repeat = shrink_list(ii).edge_ang_hists_repeat;
        shrink_list(ii).edge_ang_hist_stderr_repeat = nan(length(shrink_list(ii).edge_ang_hists_repeat),1);
    end




    end

end




    cd(start_dir);

    colorlist = get_cluster_colors(1:length(all_dirs_separated));
    vals = vertcat(shrink_list(:).edge_ang_hist_mean_repeat)./repmat(sum(vertcat(shrink_list(:).edge_ang_hist_mean_repeat),2),...
           1,length(ang_hist));
    h = figure;
    bar(vals.*100, 'stack');
	hold on

    legendcustomtxt = {};
    bins(end) = 90;
    for i = 2:(length(bins))
        legendcustomtxt{i-1} = [num2str(bins(i-1)),'-',num2str(bins(i))];
    end
    
	h1 = legend(gca,legendcustomtxt,'fontweight','bold','fontsize',13);
    set(h1,'Interpreter','none');
    set(gca,'XTick',(1:length(shrink_list(:))));
    set(gca,'XTickLabel',{leg_txt{:}});
    
    ax = gca;
    usethesevalues=get(ax,'XTickLabel');
    set(ax,'XTickLabel',[]);

    putthemhere=get(ax,'XTick');
    set(ax,'Ylim',[0,100]);
    ylimits=get(ax,'Ylim');
    ypos=ylimits(1)-.02*(ylimits(2)-ylimits(1));
       
    th=text(putthemhere,ypos*ones(1,length(putthemhere)),usethesevalues,...
    'fontweight','bold','fontsize',13,'interpreter','none',...
    'HorizontalAlignment','right','rotation',90,'parent',ax); 
    
    
    
    title('Angular Distribution of Shrinking Edges');
%     xlabel('Genotype','fontweight','bold','fontsize',13,'color','g');
    ylabel('Percentage of Shrinking Edges','fontweight','bold','fontsize',13);
    
    
    ax1 = gca;
%     set(ax1,'XColor','g','YColor','g')
    set(gca,'fontweight','bold','fontsize',13);
	pos = [680   408   801   600];
    set(gcf, 'position', pos);
    
    
% 	outpos = get(gca,'OuterPosition');
%     outpos(2) = outpos(2)*2;
%     set(gca,'OuterPosition',outpos);

    scale = 0.15;
    newpos = get(gca, 'Position');
    newpos(2) = newpos(2)+scale*newpos(4);
    newpos(4) = (1-scale)*newpos(4);
    set(gca, 'Position', newpos);
    fix_2016a_figure_output(gcf);
	fig_name = fullfile([savedir,'Percentage-of-Shrinking-Edges']);
    for i = 1:length(ftypes)
        saveas(h, [fig_name,'.',ftypes{i}]);
    end
%     saveas(h, [fig_name '.fig']);
%     saveas(h, [fig_name '.pdf']);
%     saveas(h, [fig_name '.tif']);
    close(h);
    
    
    h = figure;
    bar(vertcat(shrink_list(:).edge_ang_hist_mean_repeat),...
    'stack');
	hold on    
	h1 = legend(gca,legendcustomtxt,'fontweight','bold','fontsize',13);
    set(h1,'Interpreter','none');
    set(gca,'XTick',(1:length(shrink_list(:))));
    set(gca,'XTickLabel',{leg_txt{:}});
    
    ax = gca;
    usethesevalues=get(ax,'XTickLabel');
    set(ax,'XTickLabel',[]);

    putthemhere=get(ax,'XTick');
    ylimits=get(ax,'Ylim');
    ypos=ylimits(1)-.02*(ylimits(2)-ylimits(1));
    th=text(putthemhere,ypos*ones(1,length(putthemhere)),usethesevalues,...
    'fontweight','bold','fontsize',13,'interpreter','none',...
    'HorizontalAlignment','right','rotation',90,'parent',ax); 
    
    
    
    title('Angular Distribution of Shrinking Edges');
%     xlabel('Genotype','fontweight','bold','fontsize',13,'color','g');
    ylabel('Shrinking Edges/Cell','fontweight','bold','fontsize',13);
    
    
    ax1 = gca;
%     set(ax1,'XColor','g','YColor','g')
    set(gca,'fontweight','bold','fontsize',13);
	pos = [680   408   801   600];
    set(gcf, 'position', pos);

    
    % 	outpos = get(gca,'OuterPosition');
%     outpos(2) = outpos(2)*3;
%     set(gca,'OuterPosition',outpos);
    
    
    scale = 0.15;
    newpos = get(gca, 'Position');
    newpos(2) = newpos(2)+scale*newpos(4);
    newpos(4) = (1-scale)*newpos(4);
    set(gca, 'Position', newpos);


    fix_2016a_figure_output(gcf);
	fig_name = fullfile([savedir,'Shrinking-Edges-per-Cell']);
	for i = 1:length(ftypes)
        saveas(h, [fig_name,'.',ftypes{i}]);
    end
%     saveas(h, [fig_name '.fig']);
%     saveas(h, [fig_name '.pdf']);
%     saveas(h, [fig_name '.tif']);
    close(h);