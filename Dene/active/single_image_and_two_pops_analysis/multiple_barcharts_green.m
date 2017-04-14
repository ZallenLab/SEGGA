function multiple_barcharts_green(histcounts,binranges,legendtxt,fig_name_str,savedir, indnumsspecial)


    max_var_freq = 0;
    fig_now_handle = figure;
    hold on;
    hlist = [];
    colorlist = [[0 0 1];[0 1 0];[1 0 0];[0 0 0]; [0.5 0.5 0]; [0 0.5 0.5]; [0.6 0 0.6];[0.3 0.6 0.3]];
    
    if ~isempty(indnumsspecial)
        colorlist = colorlist(indnumsspecial,:);
    end
    
    incrsize = (max(binranges)-min(binranges))/(length(binranges)-1);
    shiftval = incrsize*0.2;
    
    mean_of_means = [];
    
    
    for ii = 1:length(histcounts)
        
        if   ~isempty(histcounts(ii).hist_perc_list) 
            
            currbins = histcounts(ii).hist_perc_list;
            
            max_var_freq = max([currbins(:);max_var_freq]);
            
                if any(~isnan(mean(currbins,1)))
        
                xvals = binranges - (ii-1)*shiftval;
                
                current_alpha = 1 - ii*0.1;
                
                currbins = histcounts(ii).hist_perc_list;
                
        
                hb = bar(xvals,mean(currbins,2),0.2,...
                    'FaceColor',colorlist(ii,:),...
                    'EdgeColor','w',...
                    'FaceAlpha',current_alpha,...
                    'EdgeAlpha',current_alpha);
               
                
                h = findobj(gca,'Type','patch');
                if isempty(h)
                    h = hb;
                end
                hlist = [hlist; h(1)];
%                 set(h(1),'FaceColor',colorlist(ii,:));
%                 set(h(1),'EdgeColor','w');
%                 set(h(1),'FaceAlpha',current_alpha);
%                 set(h(1),'EdgeAlpha',current_alpha);
                
                if size(currbins,1) >1
                
                    errorbar(xvals,mean(currbins,2),std(currbins,0,2)/sqrt(size(currbins,2)),'.',...
                        'color',min(colorlist(ii,:).*0.6,1),'linewidth',2);
                end
                
                
                    legendtxt = {legendtxt{:}};
                end
                
        end
                
                
    end


                h = legend(hlist(:),legendtxt);
                set(h,'Interpreter','none');
                toph = title(['Histogram of Pols']);
                xh=xlabel('Pol');
                yh=ylabel('Frequency');
                ylim([0 max_var_freq]);
            %     text(1,1.2,['movie lengths :',txtstr{i}]);
            
                set(gca,...
                  'linewidth',3,...
                  'fontsize',16,...
                  'fontname','arial',...
                  'fontweight','bold');
             set([xh,yh,toph],...
                  'fontweight','bold',...
                  'fontname','arial',...
                  'fontsize',16);
            
            
                upperdir = [savedir,filesep,'..',filesep];
                figuredirstring = [upperdir,fig_name_str];
                figurenamestring = [figuredirstring,'/',...
                    'separate-as_freqs'];
                if ~isdir(figuredirstring)
%                     fid = fopen('create_these_dirs.m','w');
%                     fprintf(fid, '%% ! sudo chmod 777 -R %s \n', upperdir);
%                     fprintf(fid, '!mkdir %s ', [figuredirstring]);                       
%                     fclose(fid);
%                     rehash path;
%                     create_these_dirs;
                    
                    mkdir(figuredirstring)
                end
                saveas(gca,[figurenamestring,'.pdf']);
                saveas(gca,[figurenamestring,'.tif']);
                close(gcf);
%                 legendtxt = {};
%             endf
%         end



% return

% plot the same data as lines


    
    fig_now_handle = figure;
    hold on;
    hlist = [];

    for ii = 1:length(histcounts)
        
        if   ~isempty(histcounts(ii).hist_perc_list) 
            
            mean_of_means(ii) = mean(histcounts(ii).outpols_means);
        
            currbins = histcounts(ii).hist_perc_list;
            
            max_var_freq = max([currbins(:);max_var_freq]);
            
                if any(~isnan(mean(currbins,1)))

                    xvals = binranges; 

                    current_alpha = 1 - ii*0.1;

                    currbins = histcounts(ii).hist_perc_list;



                    hlist = [hlist plot(xvals,mean(currbins,2),'color',colorlist(ii,:),...
                        'linewidth',2)];

                    if size(currbins,1) >1

                        errorbar(xvals,mean(currbins,2),std(currbins,0,2)/sqrt(length(currbins)),'.',...
                            'color',min(colorlist(ii,:).*0.6,1),'linewidth',2);

                    end

                    xpos = mean_of_means(ii).*[1 1];
                    line(xpos,[0 0.35],'color',min(colorlist(ii,:).*0.6,1),'linewidth',2);
     
                
                end
                
                
        end
                
                
                
    end
    
        ax1 = gca; 
        set(gca,'TickDir','out');
        set(gca,'xlim',[-1.5,2]);

              h = legend(hlist(:),legendtxt);
                set(h,'Interpreter','none');
                toph = title(['']);
                xh=xlabel('Pol');
                yh=ylabel('Frequency');
                ylim([0 max_var_freq]);
            %     text(1,1.2,['movie lengths :',txtstr{i}]);
            
                set(gca,...
                  'linewidth',3,...
                  'fontsize',16,...
                  'fontname','arial',...
                  'fontweight','bold');
             set([xh,yh,toph],...
                  'fontweight','bold',...
                  'fontname','arial',...
                  'fontsize',16);
            

            
%             custom xticks
            myxticks = ([0:.1:4]);
            myxticklabels = num2str((myxticks)');
            myxticksreal = log2(myxticks);
            remove_ind = ~ismember([1:length(myxticklabels)],[2, 6, 11, 16, 21, 26, 31,41], 'legacy');
            myxticklabels(remove_ind,:) = ' ';
            set(gca,'xticklabel',myxticklabels,'xtick',myxticksreal');
            set(gca,'TickDir','out');
            
            previous_xlim = get(gca,'xlim');
            set(gca,'ylim',[-0,0.31]);
            
%             ax1 = gca; 

            
            myxtickslogs = ([-4:0.5:4]);
            myxticklabelslogs = num2str([-4:0.5:4]');
            ax2 = axes('Position',get(ax1,'Position'),... 
                        'XAxisLocation','top',... 
                        'YAxisLocation','right',... 
                        'Color','none',... 
                        'XColor','k','YColor','k');
            set(ax2,'xlim',previous_xlim);
            set(ax2,'xticklabel',myxticklabelslogs,'xtick',myxtickslogs');
                set(ax2,...
                  'linewidth',3,...
                  'fontsize',16,...
                  'fontname','arial',...
                  'fontweight','bold');
              set(ax2,'TickDir','out');
              set(gca,'ylim',[-0,0.31]);
              set(ax2,'YTick',[])
%               set(ax2,'xlabel','log2-converstion');
            
%             set(gca,'xticklabel',myxticklabels')
           
            

                figurenamestring = [savedir,filesep,fig_name_str,'-green-as-line'];
                if ~isdir(savedir)
%                     fid = fopen('create_these_dirs.m','w');
%                     fprintf(fid, '%% ! sudo chmod 777 -R %s \n', upperdir);
%                     fprintf(fid, '!mkdir %s ', [figuredirstring]);                       
%                     fclose(fid);
%                     rehash path;
%                     create_these_dirs;
                    
                    mkdir(savedir)
                end
                saveas(gca,[figurenamestring,'.pdf']);
                saveas(gca,[figurenamestring,'.tif']);
                close(gcf);