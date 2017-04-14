function display_noderes(nodereslist, dirinfolist, figure_savedir, cntrl_ind, ftypes)

if nargin < 5 || isempty(ftypes)
    ftypes = {'tif'};
end

% P = mfilename('fullpath');
% reversestr = fliplr(P);
% [~, justdirpath] = strtok(reversestr,filesep);
% % justfile = fliplr(justfile);
% base_dir = fliplr(justdirpath);
% code_base_dir = [base_dir,filesep,'..',filesep,'..',filesep,'..',filesep];

if nargin < 3 %|| isempty(figure_savedir)
    figure_savedir = uigetdir(pwd,'select save dir');
end

if ~isdir(figure_savedir)
    mkdir(figure_savedir)
end

%%%%%% nodereslist structure:
    % dirinfolist.all_dirs_separated        -- (list of lists of dirs)
    % dirinfolist.leg_tex                   -- (legend, genotype names)        
    % nodereslist.res_time                  -- (all res times)
    % nodereslist.all_possible              -- (num possible)
    % nodereslist.unresolved_dead_finals    -- (last existence)
    % nodereslist.unresolved_time_existed   -- (shrink till movie end)
    % nodereslist.ind_aligned               -- (which were aligned)
    % nodereslist.res_means                 -- (mean of all events)
    % nodereslist.res_mean_of_means         -- (mean of dirs)
    % nodereslist.res_std_across_dirs       -- (std of dirs)
    % nodereslist.res_ste_across_dirs       -- (sterr of dirs)
    % nodereslist.res_std_all_points        -- (std of points)
    % nodereslist.res_ste_all_points        -- (sterr of points)
    
%     global numbers
glob_max_res_time = max([nodereslist(:).res_time]);
glob_min_res_time = min([nodereslist(:).res_time]);

glob_max_unres_time = max([nodereslist(:).unresolved_time_existed]);
glob_min_unres_time = min([nodereslist(:).unresolved_time_existed]);

numb_groups = length(nodereslist);

res_hist_bins_x_tick_vals = glob_min_res_time:((glob_max_res_time-glob_min_res_time)/15):glob_max_res_time;


%%%%%% The following charts are for plotting node separated by aligned/not.


colorlist = get_cluster_colors(1:length(dirinfolist.all_dirs_separated));

% removed: 'aligned','unaligned'
all_alignment_choices = {'all','rosette','t1'};

if nargin < 4 || isempty(cntrl_ind)
    
    cntrl_ind = 1;
end

cntrlname = dirinfolist.leg_txt{cntrl_ind};

% for i = 1:length(all_alignment_choices)
% %%%%%%%%%%%%%%%%% for plotting all
%     figure; % initiate the figure.
%     alignmentchoice = all_alignment_choices{i}; %(use all, aligned and unaligned)
%     h = [];
%     make_whole_noderes_chart(colorlist, cntrl_ind, nodereslist, dirinfolist, alignmentchoice, h, figure_savedir);
%     close(gcf);
% end


    
%%%%%%%%%%%%%%%%% for unresolved
% figure;
% h = [];
% make_whole_noderes_chart_unresolved(colorlist, nodereslist, dirinfolist, h, figure_savedir);


for i = 1:length(all_alignment_choices)
%%%%%%%%%%%%%%%%% for plotting all
    figure; % initiate the figure.
    alignmentchoice = all_alignment_choices{i}; %(use all, aligned and unaligned)
    h = [];
    make_whole_hist_chart(colorlist, nodereslist, dirinfolist, alignmentchoice, h,...
                          figure_savedir,res_hist_bins_x_tick_vals, ftypes);
    close(gcf);
    figure;
    h = [];
    make_normalizedwhole_hist_chart(colorlist, nodereslist, dirinfolist, alignmentchoice, h,...
                                    figure_savedir,res_hist_bins_x_tick_vals, ftypes);
    close(gcf);    
end
% 
% %%%%%%%%%%%%%%%%% for hists
% figure;
% h = [];
% % h = hist_of_restime_resolved(colorlist, indexnum_to_plot, nodereslist, alignmentchoice, h)
% make_whole_hist_chart(colorlist, nodereslist, dirinfolist, alignmentchoice, h, figure_savedir,res_hist_bins_x_tick_vals)
% 
% 
% figure;
% h = [];
% % h = hist_of_restime_resolved(colorlist, indexnum_to_plot, nodereslist, alignmentchoice, h)
% make_normalizedwhole_hist_chart(colorlist, nodereslist, dirinfolist, alignmentchoice, h, figure_savedir,res_hist_bins_x_tick_vals)
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 





function h = plot_restime_data_with_stats(colorlist, indexnum_to_plot, cntrl_ind, nodereslist, alignmentchoice, h)

i = indexnum_to_plot;

switch alignmentchoice
    
    case  'aligned'
        restimes_to_plot = nodereslist(i).res_time(logical(nodereslist(i).ind_aligned));
        compareforttest = nodereslist(cntrl_ind).res_time(logical(nodereslist(cntrl_ind).ind_aligned));
        
        
        
    case 'unaligned'
        restimes_to_plot = nodereslist(i).res_time(~logical(nodereslist(i).ind_aligned));
        compareforttest = nodereslist(cntrl_ind).res_time(~logical(nodereslist(cntrl_ind).ind_aligned));
        
    case 'all'
        restimes_to_plot = nodereslist(i).res_time;
        compareforttest = nodereslist(cntrl_ind).res_time;
            
    case  'rosette'
        
        takers = logical(nodereslist(i).ind_ros) & logical(nodereslist(i).ind_clusters);
        restimes_to_plot = nodereslist(i).res_time(takers);
        
        
        takers_cntrl = logical(nodereslist(cntrl_ind).ind_ros) & logical(nodereslist(cntrl_ind).ind_clusters);
        compareforttest = nodereslist(cntrl_ind).res_time(takers_cntrl);
        
    case 't1'
        
        takers = ~logical(nodereslist(i).ind_ros) & logical(nodereslist(i).ind_clusters);
        restimes_to_plot = nodereslist(i).res_time(takers);
        
        takers_cntrl = ~logical(nodereslist(cntrl_ind).ind_ros) & logical(nodereslist(cntrl_ind).ind_clusters);
        compareforttest = nodereslist(cntrl_ind).res_time(takers_cntrl);
end
    
%     compareforttest = nodereslist(cntrl_ind).res_time;

    hold on
    plot(rand(1,length(restimes_to_plot))*2+i*2.5,restimes_to_plot,...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',colorlist(i,:),...
        'MarkerSize',4);
    
    
h = [h plot(2.5*i+1,mean(restimes_to_plot),...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',colorlist(i,:),...
        'MarkerSize',8)];
    
        line([2.5*i+1,2.5*i+1],[mean(restimes_to_plot)+std(restimes_to_plot),...
            mean(restimes_to_plot)-std(restimes_to_plot)],...
        'Color',colorlist(i,:),...
        'LineWidth',4);
    
    line([2.5*i+1,2.5*i+1],[mean(restimes_to_plot)+std(restimes_to_plot),...
            mean(restimes_to_plot)-std(restimes_to_plot)],...
        'Color','k',...
        'LineWidth',1);
    
        text(2.5*i,-2,...
            num2str(round(length(nodereslist(i).res_time)/nodereslist(i).all_possible*100)/100),...
            'fontweight','bold',...
        'Color','r');
    
            text(2.5*i,-4,...
            num2str(round(mean(restimes_to_plot)*100)/100),...
            'fontweight','bold',...
        'Color','b');
    
               text(2.5*i,-6,...
            num2str(round(median(restimes_to_plot)*100)/100),...
            'fontweight','bold',...
        'Color','m');
    
    
                   text(2.5*i,-8,...
            num2str(round(nodereslist(i).res_mean_of_means*100)/100),...
            'fontweight','bold',...
        'Color','k');
    
                       text(2.5*i,-10,...
            num2str(round(nodereslist(i).res_std_across_dirs*100)/100),...
            'fontweight','bold',...
        'Color','k');
    
    
                               text(2.5*i,-12,...
            num2str(round(nodereslist(i).res_ste_across_dirs*100)/100),...
            'fontweight','bold',...
        'Color','k');
    
    
                                   text(2.5*i,-14,...
            num2str(round(nodereslist(i).res_std_all_points*100)/100),...
            'fontweight','bold',...
        'Color','k');
    
                                       text(2.5*i,-16,...
            num2str(round(nodereslist(i).res_ste_all_points*100)/100),...
            'fontweight','bold',...
        'Color','k');
    
    
                                           text(2.5*i,-18,...
            num2str(length(restimes_to_plot)),...
            'fontweight','bold',...
        'Color','k');
    
            if numel(restimes_to_plot)<2
                return
            end
    
                                               text(2.5*i,-20,...
            num2str(round(ftest(restimes_to_plot,compareforttest)*10000)/10000),...
            'fontweight','bold',...
        'Color','k');
    
                                                   text(2.5*i,-22,...
            num2str(round(ttest(restimes_to_plot,compareforttest)*100000)/100000),...
            'fontweight','bold',...
        'Color','k');
    
                                                   text(2.5*i,-24,...
            num2str(round(uttest(restimes_to_plot,compareforttest)*100000)/100000),...
            'fontweight','bold',...
        'Color','k');
    
    
    function addtext_to_noderes_data_plot(nodereslist, dirinfolist, alignmentchoice, h, figure_savedir, cntrlname)
        
         text(-3,-2,...
            'frac.res.',...
            'fontweight','bold',...
        'Color','r');
    
                text(-3,-4,...
            'mean.res.',...
            'fontweight','bold',...
        'Color','b');
    
                    text(-3,-6,...
            'median res.',...
            'fontweight','bold',...
        'Color','m');
    
                text(-3,-8,...
            'mean of means',...
            'fontweight','bold',...
        'Color','k');
    
                text(-3,-10,...
            'std dirs',...
            'fontweight','bold',...
        'Color','k');
    
                    text(-3,-12,...
            'sterr dirs',...
            'fontweight','bold',...
        'Color','k');

    
                    text(-3,-14,...
            'std points',...
            'fontweight','bold',...
        'Color','k');
    
                    text(-3,-16,...
            'sterr points',...
            'fontweight','bold',...
        'Color','k');
    
    text(-3,-18,...
            'num points',...
            'fontweight','bold',...
        'Color','k');
    
        text(-3,-20,...
            'ftest',...
            'fontweight','bold',...
        'Color','k','interpreter','none');
    
            text(-3,-22,...
            'ttest',...
            'fontweight','bold',...
        'Color','k','interpreter','none');
    
                text(-3,-24,...
            'utest',...
            'fontweight','bold',...
        'Color','k','interpreter','none');
    
                    text(-3,-26,...
            ['control: ',cntrlname],...
            'fontweight','bold',...
        'Color','k','interpreter','none');
    
    
xlim([-4,length(dirinfolist.all_dirs_separated)*2.5+3])
ylim([-26,45])
ylabel('Time (Minutes) ');
legend(h,dirinfolist.leg_txt,'Interpreter','none');

set(gca,'XTick',(1:length(dirinfolist.all_dirs_separated))*2.5+1)
set(gca,'XTickLabel',dirinfolist.leg_txt)
    pos = [680   408   1200   684];
    set(gcf, 'position', pos);


switch alignmentchoice
    
    case  'aligned'
        title('Average Node Resolution Time (Aligned Edges)');
        saveas(gcf, [figure_savedir,'node-res-aligned'],'tif');
        fix_2016a_figure_output(gcf);
        saveas(gcf, [figure_savedir,'node-res-aligned'],'pdf');
        
    case 'unaligned'
        title('Average Node Resolution Time (Unaligned Edges)');
        saveas(gcf, [figure_savedir,'node-res-unaligned'],'tif');
        fix_2016a_figure_output(gcf);
        saveas(gcf, [figure_savedir,'node-res-unaligned'],'pdf');
    case 'all'
       title('Average Node Resolution Time (All Edges)');
       saveas(gcf, [figure_savedir,'node-res-all'],'tif');
       fix_2016a_figure_output(gcf);
       saveas(gcf, [figure_savedir,'node-res-all'],'pdf');
       
	case 'rosette'
        title('Average Node Resolution Time (Rosette Events)');
        saveas(gcf, [figure_savedir,'node-res-ros'],'tif');
        fix_2016a_figure_output(gcf);
        saveas(gcf, [figure_savedir,'node-res-ros'],'pdf');
    case 't1'
       title('Average Node Resolution Time (T1 Events)');
       saveas(gcf, [figure_savedir,'node-res-t1'],'tif');
       fix_2016a_figure_output(gcf);
       saveas(gcf, [figure_savedir,'node-res-t1'],'pdf');
end

xlabel('Genotype')
ylabel('Time For Resolution (Minutes)')


function h = plot_unrestime_data_with_stats(colorlist, indexnum_to_plot, nodereslist, h)
        
    
    i = indexnum_to_plot;


    hold on
        xvals=rand(1,length(nodereslist(i).unresolved_dead_finals))*2+i*2.5;

plot(xvals,nodereslist(i).unresolved_dead_finals,...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',colorlist(i,:),...
        'MarkerSize',4);
    hold on
    
h = [h plot(2.5*i+1,mean(nodereslist(i).unresolved_dead_finals),...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',colorlist(i,:),...
        'MarkerSize',8)];
    
 for indx = 1:length(xvals)
     currx = xvals(indx);
     line([currx,currx],[nodereslist(i).unresolved_dead_finals(indx),...
         nodereslist(i).unresolved_dead_finals(indx)+nodereslist(i).unresolved_time_existed(indx)],...
        'Color',colorlist(i,:),...
        'LineWidth',1);
 end  
    
        text(2.5*i,-2,...
            num2str(round(length(nodereslist(i).res_time)/nodereslist(i).all_possible*100)/100),...
            'fontweight','bold',...
        'Color','r');
    
            text(2.5*i,-4,...
            num2str(round(mean(nodereslist(i).unresolved_time_existed)*100)/100),...
            'fontweight','bold',...
        'Color','b');
   
        
    
    
    function addtext_to_noderes_data_plot_unres(dirinfolist, h, figure_savedir)
    
            text(-3,-2,...
            'frac.res.',...
            'fontweight','bold',...
        'Color','r');
    
                text(-3,-4,...
            'mean unres.',...
            'fontweight','bold',...
        'Color','b');
    
                    text(-3,-6,...
            '(average length of line)',...
            'fontweight','bold',...
        'Color','b');
    
    
                        text(-3,52,...
            'Small Dots show the time that an unresolved edge disappears',...
            'fontweight','bold',...
        'Color','k');
    
                            text(-3,50,...
            'Large Dots are an average of the small dots (final disappearance times)',...
            'fontweight','bold',...
        'Color','k');
    
                                text(-3,48,...
            'Lines show the distance to the end of the movie',...
            'fontweight','bold',...
        'Color','k');
    
    
    
        
xlim([-4,length(dirinfolist.all_dirs_separated)*2.5+3])
ylim([-20,65])

legend(h,dirinfolist.leg_txt,'Interpreter','none');

set(gca,'XTick',(1:length(dirinfolist.all_dirs_separated))*2.5+1)
set(gca,'XTickLabel',dirinfolist.leg_txt)


title('Timing of Unresolved Nodes')
xlabel('Genotype')
ylabel('Edge Disappearance (Dot) End of Movie (Line)')
    pos = [680   408   801   684];
    set(gcf, 'position', pos);
       saveas(gcf, [figure_savedir,'node-res-all-unresolved'],'tiff');
       
       
       
       function h = hist_of_restime_resolved(colorlist, indexnum_to_plot, nodereslist, alignmentchoice, h, bins, current_alpha)

    i = indexnum_to_plot;

    hold on;

switch alignmentchoice
    
    case  'aligned'
        restimes_to_plot = nodereslist(i).res_time(logical(nodereslist(i).ind_aligned));
    case 'unaligned'
        restimes_to_plot = nodereslist(i).res_time(~logical(nodereslist(i).ind_aligned));
    case 'all'
        restimes_to_plot = nodereslist(i).res_time;
            
    case  'rosette'
        
        takers = logical(nodereslist(i).ind_ros) & logical(nodereslist(i).ind_clusters);
        restimes_to_plot = nodereslist(i).res_time(takers);
    case 't1'
        
        takers = ~logical(nodereslist(i).ind_ros) & logical(nodereslist(i).ind_clusters);
        restimes_to_plot = nodereslist(i).res_time(takers);
end

    xvals = bins + (i * 0.6);
    
    binvals = histc(restimes_to_plot,bins);
    bar(xvals,binvals,0.6);
    h = findobj(gca,'Type','patch');
    if isempty(h)
        h = findobj(gca,'Type','bar');
        if isempty(h)
            return
        end
    end
    set(h(1),'FaceColor',colorlist(i,:));
    set(h(1),'EdgeColor','w');
    set(h(1),'FaceAlpha',current_alpha);
    set(h(1),'EdgeAlpha',current_alpha);

    
    
    function h = histnormalized_of_restime_resolved(colorlist, indexnum_to_plot, nodereslist, alignmentchoice, h, bins, current_alpha)

    i = indexnum_to_plot;

    hold on;

switch alignmentchoice
    
    case  'aligned'
        restimes_to_plot = nodereslist(i).res_time(logical(nodereslist(i).ind_aligned));
    case 'unaligned'
        restimes_to_plot = nodereslist(i).res_time(~logical(nodereslist(i).ind_aligned));
    case 'all'
        restimes_to_plot = nodereslist(i).res_time;
            
    case  'rosette'
        
        takers = logical(nodereslist(i).ind_ros) & logical(nodereslist(i).ind_clusters);
        restimes_to_plot = nodereslist(i).res_time(takers);
    case 't1'
        
        takers = ~logical(nodereslist(i).ind_ros) & logical(nodereslist(i).ind_clusters);
        restimes_to_plot = nodereslist(i).res_time(takers);
end

    xvals = bins + (i * 0.6);
    
    binvals = histc(restimes_to_plot,bins);
    binvals = binvals./sum(binvals);
    bar(xvals,binvals,0.6);
    h = findobj(gca,'Type','patch');
    if isempty(h)
        h = findobj(gca,'Type','bar');
        if isempty(h)
            return
        end
    end
    set(h(1),'FaceColor',colorlist(i,:));
    set(h(1),'EdgeColor','w');
    set(h(1),'FaceAlpha',current_alpha);
    set(h(1),'EdgeAlpha',current_alpha);



        
        function make_whole_noderes_chart_unresolved(colorlist, nodereslist, dirinfolist, h, figure_savedir)
            
        for i = 1:length(dirinfolist.all_dirs_separated)

        %     plot_restime_data_with_stats(colorlist, indexnum_to_plot, indexnum_to_compare, nodereslist, alignmentchoice)
        
        %     alignmentchoice ('aligned', 'unaligned', 'all');
      
        h = plot_unrestime_data_with_stats(colorlist, i, nodereslist, h);
    
        end
%       addtext_to_noderes_data_plot(nodereslist, dirinfolist, alignmentchoice, h)
       
        addtext_to_noderes_data_plot_unres(dirinfolist, h, figure_savedir);
            
              
        
        
        
        
        function make_whole_noderes_chart(colorlist, cntrl_ind, nodereslist, dirinfolist, alignmentchoice, h, figure_savedir)
            
            cntrlname = dirinfolist.leg_txt(cntrl_ind);
            for i = 1:length(dirinfolist.all_dirs_separated)
        %     plot_restime_data_with_stats(colorlist, indexnum_to_plot, indexnum_to_compare, nodereslist, alignmentchoice)
        %     alignmentchoice ('aligned', 'unaligned', 'all');
              h = plot_restime_data_with_stats(colorlist, i, cntrl_ind, nodereslist, alignmentchoice, h);
            end
    %       addtext_to_noderes_data_plot(nodereslist, dirinfolist, alignmentchoice, h)
            addtext_to_noderes_data_plot(nodereslist, dirinfolist, alignmentchoice, h, figure_savedir, cntrlname)
            
            
            
            
	function h = make_whole_hist_chart(colorlist, nodereslist, dirinfolist, alignmentchoice,...
                                       h, figure_savedir, res_hist_bins_x_tick_vals, ftypes)
        
        if nargin < 8 || isempty(ftypes)
            ftypes = {'tif'};
        end
	
        for i = 1:length(dirinfolist.all_dirs_separated)
    %     plot_restime_data_with_stats(colorlist, indexnum_to_plot, indexnum_to_compare, nodereslist, alignmentchoice)
    %     alignmentchoice ('aligned', 'unaligned', 'all');
    
        current_alpha = 1 - (i-1)/length(dirinfolist.all_dirs_separated);
          h = hist_of_restime_resolved(colorlist, i, nodereslist, alignmentchoice, h, res_hist_bins_x_tick_vals,current_alpha);

%           addtext_to_noderes_data_plot(nodereslist, dirinfolist, alignmentchoice, h, figure_savedir);
    

        end
        reorder_leg_text = [];
        allcolors =  findobj(gca,'Type','patch');
        use_patch = true;
        if isempty(allcolors)
            allcolors =  findobj(gca,'Type','bar');
            use_patch = false;
        end
        for i = 1:length(dirinfolist.all_dirs_separated)
            if use_patch
                reordered_ind = find(allcolors == findobj(gca,'Type','patch','FaceColor',colorlist(i,:)));
            else
                reordered_ind = find(allcolors == findobj(gca,'Type','bar','FaceColor',colorlist(i,:)));
            end
            
            if (numel(reorder_leg_text)<1)&&(numel(reordered_ind)<1)
                continue
            end
            reorder_leg_text(i) = reordered_ind;
        end
            
        legend(h,dirinfolist.leg_txt(reorder_leg_text),'Interpreter','none');
        
        title('histograms of resolution times');
        
        ylabel('Number of Nodes');
        xlabel('Time (Minutes)  to Resolution');
        extratxt = 'abslt-';
        
        addtext_to_noderes_hist(alignmentchoice, h, figure_savedir, extratxt, ftypes);
        
        
    function h = make_normalizedwhole_hist_chart(colorlist, nodereslist, dirinfolist,...
            alignmentchoice, h, figure_savedir, res_hist_bins_x_tick_vals, ftypes)
        if nargin <8 || isempty(ftypes)
            ftypes = {'tif'};
        end
	
        for i = 1:length(dirinfolist.all_dirs_separated)
    %     plot_restime_data_with_stats(colorlist, indexnum_to_plot, indexnum_to_compare, nodereslist, alignmentchoice)
    %     alignmentchoice ('aligned', 'unaligned', 'all');
    
        current_alpha = 1 - (i-1)/length(dirinfolist.all_dirs_separated);
          h = histnormalized_of_restime_resolved(colorlist, i, nodereslist, alignmentchoice, h, res_hist_bins_x_tick_vals,current_alpha);

%           addtext_to_noderes_data_plot(nodereslist, dirinfolist, alignmentchoice, h, figure_savedir);
    

        end
        reorder_leg_text = [];
        allcolors =  findobj(gca,'Type','patch');
        use_patch = true;
        if isempty(allcolors)
            allcolors =  findobj(gca,'Type','bar');
            use_patch = false;
        end
        for i = 1:length(dirinfolist.all_dirs_separated)
            if use_patch
                reordered_ind = find(allcolors == findobj(gca,'Type','patch','FaceColor',colorlist(i,:)));
            else
                reordered_ind = find(allcolors == findobj(gca,'Type','bar','FaceColor',colorlist(i,:)));
            end
            
            if (numel(reorder_leg_text)<1)&&(numel(reordered_ind)<1)
                continue
            end
            reorder_leg_text(i) = reordered_ind;
        end
            
        legend(h,dirinfolist.leg_txt(reorder_leg_text),'Interpreter','none');
        
        title('histograms of resolution times');
        
        ylabel('Fraction of Nodes');
        xlabel('Time (Minutes)  to Resolution');
        extratxt = 'norm-';
        addtext_to_noderes_hist(alignmentchoice, h, figure_savedir,extratxt, ftypes);
        
        
    
        
        function addtext_to_noderes_hist(alignmentchoice, h, figure_savedir,extratxt, ftypes)
            
            if nargin < 5 || isempty(ftypes)
                ftypes = {'tif'};
            end

            switch alignmentchoice

                case  'aligned'
                    title('Hist of Node Resolution Time (Aligned Edges)');
                    sname = 'hist-node-res-aligned';
                    fix_2016a_figure_output(gcf);
                    for i = 1:length(ftypes)
                        saveas(gcf, [figure_savedir,extratxt,sname],ftypes{i});
                    end
%                     saveas(gcf, [figure_savedir,extratxt,'hist-node-res-aligned'],'tif');
%                     fix_2016a_figure_output(gcf);
%                     saveas(gcf, [figure_savedir,extratxt,'hist-node-res-aligned'],'pdf');

                case 'unaligned'
                    title('Hist of Node Resolution Time (Unaligned Edges)');
                    sname = 'hist-node-res-unaligned';
                    fix_2016a_figure_output(gcf);
                    for i = 1:length(ftypes)
                        saveas(gcf, [figure_savedir,extratxt,sname],ftypes{i});
                    end
%                     saveas(gcf, [figure_savedir,extratxt,'hist-node-res-unaligned'],'tif');
%                     fix_2016a_figure_output(gcf);
%                     saveas(gcf, [figure_savedir,extratxt,'hist-node-res-unaligned'],'pdf');
                case 'all'
                   title('Hist of Node Resolution Time (All Edges)');
                   sname = 'hist-node-res-all';
                    fix_2016a_figure_output(gcf);
                    for i = 1:length(ftypes)
                        saveas(gcf, [figure_savedir,extratxt,sname],ftypes{i});
                    end
%                    saveas(gcf, [figure_savedir,extratxt,'hist-node-res-all'],'tif');
%                    fix_2016a_figure_output(gcf);
%                    saveas(gcf, [figure_savedir,extratxt,'hist-node-res-all'],'pdf');

                case 'rosette'
                    title('Hist of Node Resolution Time (Rosette Events)');
                    sname = 'hist-node-res-ros';
                    fix_2016a_figure_output(gcf);
                    for i = 1:length(ftypes)
                        saveas(gcf, [figure_savedir,extratxt,sname],ftypes{i});
                    end
%                     saveas(gcf, [figure_savedir,extratxt,'hist-node-res-ros'],'tif');
%                     fix_2016a_figure_output(gcf);
%                     saveas(gcf, [figure_savedir,extratxt,'hist-node-res-ros'],'pdf');
                case 't1'
                    title('Hist of Node Resolution Time (T1 Events)');
                    sname = 'hist-node-res-t1';
                    fix_2016a_figure_output(gcf);
                    for i = 1:length(ftypes)
                        saveas(gcf, [figure_savedir,extratxt,sname],ftypes{i});
                    end
                   
%                    saveas(gcf, [figure_savedir,extratxt,'hist-node-res-t1'],'tif');
%                    fix_2016a_figure_output(gcf);
%                    saveas(gcf, [figure_savedir,extratxt,'hist-node-res-t1'],'pdf');
            end

            ylabel('Fraction of Occurrences');
            xlabel('Time (Minutes) to Resolution');
        
        
