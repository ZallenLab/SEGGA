function figsH = plot_bins(avg_vecs, titles, groups, vars, time_axis, ...
    figsH, time_lim, save_dir,action,hist_points, save_filetypes)
% colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 0.6 0 1; 0 1 1; 1 1 0; 0.5 0.5 0.5];
% if nargin < 5 || isempty(colors)
%     colors = [0 0 0; 0 0 1; 1 0 0 ; 0 1 1; 0.5 0.5 0.5];
% end
% if length(groups) > length(colors(:, 1))
%     colors = get_cluster_colors(1:length(groups));
%     colors(1, :) = 0;
% end
% err_colors = (colors + 2)/3;

% if nargin <6 || isempty(linespecs)
%     linespecs = cell(size(groups));
%     for i = 1:length(linespecs)
%         linespecs{i} = '';
%     end
% end

if nargin <11 || isempty(save_filetypes)
    save_filetypes = {'pdf','tif','fig'};
end


highlights = false;

create_timeseries_bool = false;

if isempty(figsH)
    use_existing_figs = false;
else
    use_existing_figs = true;
end
    legend_text = [];
    
for i = 1:length(avg_vecs)
    
    if highlights
        len = length(vars(i).bins);
    else
        len = 1;
    end
        for bin_ind = 1:len

    
            if ~use_existing_figs
                figsH(i) = figure;
            else
                figure(figsH(i));
            end

            for j = length(groups):-1:1
                err_colors = (groups(j).color + 2)/3;
                if ~isfield(vars(i), 'error') || isempty(vars(i).error) || vars(i).error == 1
                    err_data = avg_vecs(i).group(j).std_err;
                elseif vars(i).error == 0
                    continue
                elseif vars(i).error == 2
                    err_data = avg_vecs(i).group(j).std_std;
                end
                
                %%% Time Series
%                 if strcmpi(action,'binned_charts_together')
%                     for k = 1:length(vars(i).bins)
%                         errorbar(time_axis, (avg_vecs(i).group(j).avg(:,k)), err_data(:,k), ...
%                             'color', err_colors, 'linewidth', 0.5);
%                         hold on
%                     end
%                     if highlights
%                         errorbar(time_axis, (avg_vecs(i).group(j).avg(:,bin_ind)), err_data(:,bin_ind), ...
%                         'color', 'red', 'linewidth', 0.5);
%                     end
%                 end
            end
        
    
            %%% Time Series
%             h = [];
%             for j = 1:length(groups)
%                 if ~isfield(vars(i), 'linewidth') || isempty(vars(i).linewidth)
%                     linewidth = 3;
%                 else
%                     linewidth = vars(i).linewidth;
%                 end
% 
%                     linewidth = min(linewidth,2);
% 
%                 for k = 1:length(vars(i).bins)
%                      color_now = groups(j).color.*(1.2 - ((k-1)/(length(vars(i).bins)-1))*1);
%                      for ind = 1:length(color_now)
%                          color_now(ind) = min(1,color_now(ind));
%                      end
%                      linewidth_now = linewidth + ((k-1)/(length(vars(i).bins)-1))*3;
%                         h = [h plot(time_axis, (avg_vecs(i).group(j).avg(:,k)), groups(j).linespec, ...
%                                 'linewidth', linewidth_now,  'color', color_now)];
%                         hold on
% 
%                 if isempty(legend_text)
%                     legend_text = {[groups(j).label]};
%                 else
%                         legend_text = {legend_text{:},[groups(j).label]};
%                 end
%                 end
%                 
%                 
%                 
%                 if strcmpi(action,'binned_charts_separate')
%                     if ~use_existing_figs
%                         figsH(i) = figure;
%                     else
%                         figure(figsH(i));
%                     end
% 
%                 end
%             end
%             if create_timeseries_bool
%                 if ~isempty(time_lim)
%                     xlim(time_lim)
%                 end
%                 legend(h, legend_text, 'location', 'NorthWest', 'interpreter', 'none')
%                 title(titles{i}, 'fontsize', 16, 'fontweight', 'bold','interpreter', 'none')
%                 xlabel('Time [minutes]', 'fontsize', 14);
%                 set(gca, 'fontsize', 16, 'fontweight', 'bold', 'box', 'off');
%             %     pos = [153   225   504   867];
%             %     pos = [680   472   874   620];
%                 pos = [680   408   801   684];
%                 set(gcf, 'position', pos);
%                 if highlights
%                     bname = [save_dir, titles{i},'-',num2str(bin_ind)];
%                 else
%                     bname = [save_dir, titles{i}];
%                 end
% 
%                 saveas(gcf, [bname '.fig']);
%                 saveas(gcf, [bname '.pdf']);
%             %     print(gcf, [bname '.emf'], '-dmeta',   '-r0',    '-loose')
%             %     close(gcf);
%             end

        end
        
        if ~isempty(hist_points)
            for hist_point_ind = hist_points
                time_in = time_axis == hist_point_ind;
                y_in = [];
                errs_all = [];
                for j = 1:length(groups)

                    y_in = [y_in;...
                        avg_vecs(i).group(j).avg(time_in,:)];
                    errs_all = [errs_all;...
                        avg_vecs(i).group(j).std_err(time_in,:)];
                end

                hb = bar(vars(i).bins,y_in', 'grouped');
                hold on
                hErr=[];
                for ib = 1:numel(hb)
                    %XData property is the tick labels/group centers; XOffset is the offset
                    %of each distinct group
                    xData = hb(ib).XData+hb(ib).XOffset;
                    hErr=[hErr,errorbar(xData,y_in(ib,:),errs_all(ib,:),'k.')];
%                     set(hErr(end),'LineStyle','none');
                end
                
                legend(gca, {groups.label}, 'location', 'NorthEast', 'interpreter', 'none');
                title([titles{i}, ' at time = ',num2str(hist_point_ind)], 'fontsize', 16, 'fontweight', 'bold','interpreter', 'none')
                xlabel(vars(i).title, 'fontsize', 14);
                ylabel('Percentage of cells','fontsize', 14)
                set(gca, 'fontsize', 16, 'fontweight', 'bold', 'box', 'off');
                pos = [680   408   801   684];
                set(gcf, 'position', pos);
                
                fix_2016a_figure_output(gcf);
                
                if ~isdir(save_dir)
                    mkdir(save_dir);
                end
                bname = [save_dir, titles{i},'-hist-at-t',num2str(hist_point_ind)];
                for s_i = 1:length(save_filetypes)
                    saveas(gcf, [bname '.',save_filetypes{s_i}]);
                end
                close(gcf);
            end
        end

%%%%%%%%%%      DLF  EDIT
% % figure;
% % for j = 1:length(groups)
% % 
% % plot(time_axis,avg_vecs(i).group(j).num,groups(j).linespec, ...
% %                     'linewidth', linewidth,  'color', groups(j).color);
% % title([titles{i},' (number of embryos)'], 'fontsize', 16, 'fontweight', 'bold');
% % hold on
% %     if ~isempty(time_lim)
% %         xlim(time_lim)
% %     end
% %     
% %     legend(h, {groups.label}, 'location', 'NorthWest', 'interpreter', 'none')
% %     xlabel('Time [minutes]', 'fontsize', 14);
% %     set(gca, 'fontsize', 16, 'fontweight', 'bold', 'box', 'off');
% % %     pos = [153   225   504   867];
% % %     pos = [680   472   874   620];
% %     pos = [680   408   801   684];
% %     set(gcf, 'position', pos);
% %     bname = [save_dir [titles{i},' (number of embryos)']];
% %     saveas(gcf, [bname '.fig']);
% %     saveas(gcf, [bname '.pdf']);
% % end
%%%%%%%%%END OF EDIT
end