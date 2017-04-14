function combine_many_polarities_SEGGA(settings)

% home_dir = settings.movie_base_dir;
save_dir = settings.save_base_dir;
if ~isdir(save_dir)
    mkdir(save_dir);
end

% handles.settings.pol_combined_tag_mapping;
% handles.settings.dirnames;
% handles.settings.fullpath_dirnames;
% handles.settings.vars_to_plot;
% handles.settings.groups.dirs;
% %%% To Do, Allow User to Set pol Vals in chart to Absolute
% handles.settings.pol_abs_bool;
% reg_time_series_list = {'one_fig_per_group','one_fig_per_var','single_movies_group',...
%                       'single_movies_var','one_fig'};
% handles.settings.plot_style
% handles.settings.plot_style_ind

% all_dirs_separated = settings.fullpath_dirnames;
%%% need to group 
legendtxt = settings.pol_combined_tag_mapping.legend_tags;
tagged_name_list = settings.pol_combined_tag_mapping.collective_tag_map;

%%% Remove tags that are to be excluded
cnt = 0;
for i = 1:length(legendtxt)
    if strcmp(legendtxt{i-cnt},'EXCLUDE')
        legendtxt(i-cnt) = [];
        tagged_name_list(i-cnt) = [];
        cnt = cnt+1;
    end
end
                    
all_dirs_separated = give_structured_dir_list(settings.movie_base_dir,...
    settings.fullpath_dirnames,settings.groups);

timestep_goal = 1/4;
glob_time_min = settings.time_window(1);
glob_time_max = settings.time_window(2);
global_timepoints = glob_time_min:timestep_goal:glob_time_max;


num_proteins = size(tagged_name_list,2);
num_dirs = size([all_dirs_separated{:}],2);

big_pol_mat = nan(length(global_timepoints),num_dirs,num_proteins);
big_pol_mat_normed = big_pol_mat;
big_pol_mat_stack = big_pol_mat;
big_cortical_to_cyto_mat = big_pol_mat;
big_legtxt_mat = cell(num_proteins,1);

dirnum = 0;
for ii = 1:length(all_dirs_separated)
    for i = 1:length(all_dirs_separated{ii})
        cd(all_dirs_separated{ii}{i});
        display(pwd);
        dirnum = dirnum+1;
        [~, justdirpath] = get_filename_from_fullpath(pwd);
        [justfile, ~] = get_filename_from_fullpath(justdirpath);
        load shift_info
        load timestep
        load edges_info_cell_background channel_info
        
%%% Not Using the Score based on Angular Ordering of Edge Intensities
%         if  isempty(dir('polarity_scores.mat'))
%             score_polarity_dir(pwd);
%         end
%         load polarity_scores


        temptimes = 1:size(channel_info(1).cells.polarity,1);
        temptimes = ((temptimes+shift_info) * (timestep/60));
        for chan_ind = 1:length(channel_info)
            protein_ind = 0;
            for chansearch = 1:num_proteins
                if any(strcmp(channel_info(chan_ind).name,  tagged_name_list{chansearch}))
                    protein_ind = chansearch;
                end
            end
            
            if protein_ind == 0
                display('protein name not found for channel');
                continue
            else
                interp_pols = interp1(temptimes,channel_info(chan_ind).cell_avg.polarity,global_timepoints);
                big_pol_mat(:,dirnum,protein_ind) = interp_pols;
                big_pol_mat_normed(:,dirnum,protein_ind) = interp_pols/max(abs(interp_pols));
%                 big_pol_mat_stack(:,dirnum,protein_ind) = interp1(temptimes,polarity_scores(chan_ind).scoreList,global_timepoints);

                cort2cyto = log2((channel_info(chan_ind).cell_avg.cytoplasm_unadjusted+channel_info(chan_ind).cell_avg.mean_edge_intensity)./...
                channel_info(chan_ind).cell_avg.cytoplasm_unadjusted);

                big_cortical_to_cyto_mat(:,dirnum,protein_ind) = interp1(temptimes,cort2cyto,global_timepoints);

                big_legtxt_mat{protein_ind,:} = [big_legtxt_mat{protein_ind},{justfile}];
            end
        end

    end
end


% reg_time_series_list = {'one_fig_per_group','one_fig_per_var','single_movies_group',...
%                       'single_movies_var','one_fig'};
% handles.settings.plot_style
% handles.settings.plot_style_ind

input_data.big_pol_mat = big_pol_mat;
input_data.big_pol_mat_normed = big_pol_mat_normed;
% input_data.big_pol_mat_stack = big_pol_mat_stack;
input_data.big_cortical_to_cyto_mat = big_cortical_to_cyto_mat;

save_ftypes = settings.output_filetypes;
xlim_input = settings.time_window;
if isfield(settings,'ylim_input')
    ylim_input = settings.ylim_input;
else
    ylim_input = [];
end

if isfield(settings,'errorbar_style')
    err_display_style = settings.errorbar_style;
else
    err_display_style = [];
end

for varind = 1:length(settings.vars)
    var = settings.vars(varind);
    switch settings.plot_style
        case 'single_movies_var'
            %%% This shows each movie separately for each tag
            single_general_plot(var,save_dir,tagged_name_list,global_timepoints,input_data,...
                big_legtxt_mat,save_ftypes,xlim_input,ylim_input);
        case 'one_fig_per_var'
            %%% This shows the average of all movies grouped for any given
            %%% tag
            grouped_general_plot(var,save_dir,tagged_name_list,global_timepoints,input_data,...
                legendtxt,save_ftypes,xlim_input,ylim_input,err_display_style);
    end
end

%%% what case is 'singe_movies_group used?

%%% Need new plotting functions for these
switch settings.plot_style
    case 'one_fig_per_group'
        %%% this would group multiple measurements over a single tag.
        %%% I have not created that plotting function yet.

    case 'one_fig'
        
end



return

%%%% SEPARATE PLOTTING FUNCTIONS
%%%% These are no longer in use

single_per_tag_pols_basic_plot(save_dir,tagged_name_list,...
    global_timepoints,big_pol_mat,big_legtxt_mat);
    
single_per_tag_pols_stack_plot(save_dir,tagged_name_list,...
    global_timepoints,big_pol_mat_stack,big_legtxt_mat);
    
single_per_tag_cyto2cort_plot(save_dir,tagged_name_list,...
    global_timepoints,big_cortical_to_cyto_mat,big_legtxt_mat);
    
grouped_per_tag_pols_basic_plot(save_dir,tagged_name_list,...
    global_timepoints,big_pol_mat,legendtxt);
    
grouped_per_tag_pols_stacked_plot(save_dir,tagged_name_list,...
    global_timepoints,big_pol_mat_stack,legendtxt);
    
grouped_per_tag_cort2cyto_plot(save_dir,tagged_name_list,...
    global_timepoints,big_cortical_to_cyto_mat,legendtxt);
    
grouped_per_tag_pol_normed_plot(save_dir,tagged_name_list,...
    global_timepoints,big_pol_mat_normed,legendtxt);
    


%%%%%%% GENERAL SINGLES

function single_general_plot(var,save_dir,tagged_name_list,global_timepoints,input_data,...
        big_legtxt_mat,save_filetypes,xlim_input,ylim_input)
    
    if isfield(var,'sub_save_name') && ~isempty(var.sub_save_name)
        subsave = [save_dir,filesep,var.sub_save_name,filesep];
        if ~isdir(subsave)
            mkdir(subsave);
        end
    else
        subsave = save_dir;
    end

    linewidth = 3;
    colors = jet(length(tagged_name_list)).*0.9;
    pol_mat = input_data.(var.pol_field_name);
    for tag_ind = 1:length(tagged_name_list)
        figure;
        hold on        
        temppols = pol_mat(:,:,tag_ind);
        temppols = temppols(:,any(~isnan(temppols)));
        plot(global_timepoints,temppols,'linewidth',2);
        title(tagged_name_list{tag_ind}(1));
        set(gca,'xlim',xlim_input);
        if isfield(var,'ylabel_txt') && ~isempty(var.ylabel_txt)
            ylabel(var.ylabel_txt,'fontsize',18);
        end
        xlabel('Time (min)','fontsize',18);

        set(gca,'fontsize',18)
        set(gcf,'position',[100 100 800 800]);
    
        for i = 1:length(global_timepoints)
            tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
            tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
% %         tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
%         tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
%         plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))
%         newlegtxt  = [big_legtxt_mat{tag_ind,:},{'mean'}];
        newlegtxt  = [big_legtxt_mat{tag_ind,:}];
        if length(newlegtxt) > 6
            legtxtsize = 7;
        else
            legtxtsize = 10;
        end
        legend(newlegtxt,'interpreter','none','fontsize',legtxtsize);

        tagname = tagged_name_list{1,tag_ind};
        set(gca, 'fontsize', 14, 'fontweight', 'bold');
        xlabel('Time (min)', 'fontsize', 14,'fontweight', 'bold');
        pos = [680   408   801   684];
        set(gcf, 'position', pos);
        plot(xlim_input, [0 0], 'k');
    
        if any(mod(get(gca, 'YTick'),1)>0)
            if any(mod(get(gca, 'YTick'),0.1)>0)
            set(gca, 'YTickLabel', num2str(get(gca, 'YTick')', '%.2f'));
            else
            set(gca, 'YTickLabel', num2str(get(gca, 'YTick')', '%.1f'));
            end
        end
    
    
        if ~isempty(ylim_input)
            set(gca, 'ylim',ylim_input);
        end

        ticksize = get(gca, 'TickLength');
        set(gca,'TickLength',ticksize.*2);
        set(gca,'linewidth',3);
        set(gca, 'Layer','top');
        fix_figure_boundaries_for_export(gcf);
        
        if isfield(var,'save_name') && ~isempty(var.save_name)
            bname = [subsave, var.save_name, '_',tagname{:}];
        else
            bname = [subsave,tagname{:}];
        end

        for s_i = 1:length(save_filetypes)
            saveas(gcf, [bname '.',save_filetypes{s_i}]);
        end
        close(gcf);
    end
    
    
%%%%%%%%%%GENERAL GROUPED
function grouped_general_plot(var,save_dir,tagged_name_list,global_timepoints,input_data,...
        legendtxt,save_filetypes,xlim_input,ylim_input,err_display_style)
    %%% Here the 'var' is a measurement
    %%% and the grouping is across tags, not directories
	if (nargin <10) || (isempty(err_display_style)) %#ok<ALIGN>
        err_display_style = 'none';
    end
    ylim_bool = true;
    if (nargin <9) || (isempty(ylim_input))
        ylim_bool = false;
        ylim_input = [];
%         ylim_input = [-0.2,1];
    end
    if (nargin < 8) || (isempty(xlim_input))
        xlim_input = [-25,10];
    end
    
    num_proteins = length(tagged_name_list);
    tagmeans = nan(length(global_timepoints),num_proteins);
    tagerrs = tagmeans;
    pol_mat = input_data.(var.pol_field_name);
    for tag_ind = 1:length(tagged_name_list)

        temppols = pol_mat(:,:,tag_ind);
        for i = 1:length(global_timepoints)
            if length(temppols(i,~isnan(temppols(i,:))))>1
                tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
                tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
            end

            if numel(temppols(i,~isnan(temppols(i,:))))<3
               tagerrs(i,tag_ind) =0;
            end
        end
%         tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
    end



    if num_proteins>7
        colors = jet(num_proteins).*0.9;
    else
        colors = [[0 0.8 0];[0 0 1];[0.8 0 0];[0.7 0 0.7];[0.9 0.5 0.1];[1 0 0];[0.3 0 0.3]];
    end
    err_colors = colors;
    for i = 1:num_proteins
        err_colors(i,:) = (colors(i,:)+2)/3;
    end
    fh = figure;
    axesh = axes('Parent', fh);
    hold on
    linewidth = 3;

    %%% Create Chart
    h = [];
    for tag_ind = 1:length(tagged_name_list)
        h = [h plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
    end
    %%% Add Err Bars
    switch err_display_style
        
        case 'none'
            %%% - do nothing
        case 'line'
            for tag_ind = 1:length(tagged_name_list)
                errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind), 'color', err_colors(tag_ind, :));            
            end
        case 'solid' %prob don't want to use this one
            for tag_ind = 1:length(tagged_name_list)
                [hLine, hPatch] = boundedline(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),...
                    '-r',axesh,... 
                    'orientation', 'vert',...
                    'cmap',colors(tag_ind,:),...
                    'linewidth',linewidth);
            end
            
        case 'transparent'
            for tag_ind = 1:length(tagged_name_list)
                [hLine, hPatch] = boundedline(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),...
                    '-r',axesh,... 
                    'transparency', 0.55,...
                    'orientation', 'vert',...
                    'cmap',colors(tag_ind,:),...
                    'linewidth',linewidth,...
                    'alpha');
            end
            
    end
    
    %%% Modify Lims, Tick Marks, etc.
    set(gca,'xlim',xlim_input);
    if ~strcmp(var.pol_field_name,'big_cortical_to_cyto_mat') && ~isempty(ylim_input)
        if ylim_bool
            set(gca,'ylim',ylim_input);
        end
    end
    if isfield(var,'ylabel_txt') && ~isempty(var.ylabel_txt)
        ylabel(var.ylabel_txt,'fontsize',18);
    end
    xlabel('Time (min)','fontsize',18);
%     plot(global_timepoints,zeros(size(global_timepoints)),'m')
    set(gca,'fontsize',18)
    set(gcf,'position',[100 100 800 800]);
    legend(h,legendtxt,'interpreter','none','fontsize',12,'location','northwest');
    
    if min(get(gca,'ylim'))<0
        plot(xlim_input, [0 0], 'k');
    end
    
    %%% Regarding Tickmarks: Matlab is creating weird non-zero numbers at zero.
    %%% Capping it at 4 decimal places. This could cause problems when
    %%% charting very small numbers.
    yticknums = get(gca, 'YTick');
    yticknums = round(yticknums,3,'significant');
    yticknums = round(yticknums,4);
    if any(mod(yticknums,1)>0)
        if any(mod(yticknums,0.1)>0)
            set(gca, 'YTickLabel', num2str(yticknums', '%.2f'));
        else
            set(gca, 'YTickLabel', num2str(yticknums', '%.1f'));
        end
    end

    
    ticksize = get(gca, 'TickLength');
    set(gca,'TickLength',ticksize.*2);
    set(gca,'linewidth',3);
    set(gca, 'Layer','top');
%     fix_figure_boundaries_for_export(gcf);
    fix_figure_boundaries_for_export(gcf);
        
    if isfield(var,'save_name') && ~isempty(var.save_name)
        bname = [save_dir, var.save_name];
    else
        bname = [save_dir, 'all-grouped-generic-output'];
    end

    
    for s_i = 1:length(save_filetypes)
        saveas(gcf, [bname '.',save_filetypes{s_i}]);
    end
    pause(0.2);
    close(gcf);
    
    return
    


% % % %  Show separate lines for polarity - regular cell Polarity
function single_per_tag_pols_basic_plot(save_dir,tagged_name_list,global_timepoints,big_pol_mat,...
        big_legtxt_mat)
        
    subsave = [save_dir,filesep,'singles-reg',filesep];
    if ~isdir(subsave)
        mkdir(subsave);
    end

    linewidth = 3;
    colors = jet(length(tagged_name_list)).*0.9;
    tempmean = nan(length(global_timepoints),1);
    for tag_ind = 1:length(tagged_name_list)
        figure;
        hold on
        temppols = big_pol_mat(:,:,tag_ind);
        temppols = temppols(:,any(~isnan(temppols)));
        plot(global_timepoints,temppols,'linewidth',2);
        title(tagged_name_list{tag_ind}(1));
        set(gca,'xlim',[-30,20]);
        ylabel('polarity (log2)','fontsize',18);
        xlabel('time (min)','fontsize',18);

        set(gca,'fontsize',18)
        set(gcf,'position',[100 100 800 800]);
    
        for i = 1:length(global_timepoints)
            tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
            tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
%         tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
        plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))
        newlegtxt  = [big_legtxt_mat{tag_ind,:},{'mean'}];
        if length(newlegtxt) > 6
            legtxtsize = 7;
        else
            legtxtsize = 10;
        end
        legend(newlegtxt,'interpreter','none','fontsize',legtxtsize);

        tagname = tagged_name_list{1,tag_ind};
        bname = [subsave, 'reg-pol-',tagname{:}];
        saveas(gcf, [bname '.fig']);
        saveas(gcf, [bname '.pdf']);
        saveas(gcf, [bname '.tif']);


    end



    % % % %  Show separate lines for stack scores
    function single_per_tag_pols_stack_plot(save_dir,tagged_name_list,global_timepoints,big_pol_mat_stack,...
        big_legtxt_mat)

    subsave = [save_dir,filesep,'singles-stack',filesep];
    if ~isdir(subsave)
        mkdir(subsave);
    end
    % % % % % % 
    % % % % % % %  stack scores

    linewidth = 3;
    colors = jet(length(tagged_name_list)).*0.9;
    tempmean = nan(length(global_timepoints),1);
    for tag_ind = 1:length(tagged_name_list)
        figure;
        hold on
        temppols = big_pol_mat_stack(:,:,tag_ind);
        temppols = temppols(:,any(~isnan(temppols)));
        plot(global_timepoints,temppols);
        title(tagged_name_list{tag_ind}(1));
        set(gca,'xlim',[-30,20]);
        ylabel('stacking score','fontsize',18);
        xlabel('time (min)','fontsize',18);

        set(gca,'fontsize',18)
        set(gcf,'position',[100 100 800 800]);
        newlegtxt  = [big_legtxt_mat{tag_ind,:},{'mean'}];
        if length(newlegtxt) > 7
            legtxtsize = 7;
        else
            legtxtsize = 10;
        end
        legend(newlegtxt,'interpreter','none','fontsize',legtxtsize);


        for i = 1:length(global_timepoints)
            tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
            tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
        plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))

        tagname = tagged_name_list{1,tag_ind};
        bname = [subsave, 'stack-pol-',tagname{:}];
        saveas(gcf, [bname '.fig']);
        saveas(gcf, [bname '.pdf']);
        saveas(gcf, [bname '.tif']);


    end




    % % % %  Show separate lines for cyto/cortical ratio
    function single_per_tag_cyto2cort_plot(save_dir,tagged_name_list,global_timepoints,big_cortical_to_cyto_mat,...
        big_legtxt_mat)
    subsave = [save_dir,filesep,'singles-cytocortical',filesep];
    if ~isdir(subsave)
        mkdir(subsave);
    end

    linewidth = 3;
    colors = jet(length(tagged_name_list)).*0.9;
    tempmean = nan(length(global_timepoints),1);
    for tag_ind = 1:length(tagged_name_list)
        figure;
        hold on
        temppols = big_cortical_to_cyto_mat(:,:,tag_ind);
        temppols = temppols(:,any(~isnan(temppols)));
        plot(global_timepoints,temppols);
        title(tagged_name_list{tag_ind}(1));
        set(gca,'xlim',[-30,20]);
        ylabel('cortical / cytoplasm ratio','fontsize',18);
        xlabel('time (min)','fontsize',18);

        set(gca,'fontsize',18)
        set(gcf,'position',[100 100 800 800]);
        newlegtxt  = [big_legtxt_mat{tag_ind,:},{'mean'}];
        if length(newlegtxt) > 6
            legtxtsize = 7;
        else
            legtxtsize = 10;
        end
        legend(newlegtxt,'interpreter','none','fontsize',legtxtsize);


        for i = 1:length(global_timepoints)
            tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
            tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/(numel(temppols(i,~isnan(temppols(i,:))))^(1/2));
            if numel(temppols(i,~isnan(temppols(i,:))))<4
                tagerrs(i,tag_ind) =nan;
            end
                
        end
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
        plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))

        tagname = tagged_name_list{1,tag_ind};
        bname = [subsave, 'stack-pol-',tagname{:}];
        saveas(gcf, [bname '.fig']);
        saveas(gcf, [bname '.pdf']);
        saveas(gcf, [bname '.tif']);


    end
    




% % % % 
% % % % 
% % % % % % % % % %       
% % % % % % % % % % 
% % % % % % % % % % 

% run regular mean polarity plot


function grouped_per_tag_pols_basic_plot(save_dir,tagged_name_list,...
        global_timepoints,big_pol_mat,legendtxt,save_ftypes,xlim_input,ylim_input)

if nargin < 8 || isempty(ylim_input)
    ylim_bool = false;
%     ylim_input = [-0.2,1];
else
    ylim_bool = true;
end
    
if nargin < 7 || isempty(xlim_input)
    xlim_bool = false;
%     xlim_input = [-25,10];
else
    xlim_bool = true;
end

if nargin < 6 || isempty(save_ftypes)
    save_ftypes = {'.tif'};
end
num_proteins = length(tagged_name_list);
tagmeans = nan(length(global_timepoints),num_proteins);
tagerrs = tagmeans;
for tag_ind = 1:length(tagged_name_list)
    
    temppols = big_pol_mat(:,:,tag_ind);
    for i = 1:length(global_timepoints)
        if length(temppols(i,~isnan(temppols(i,:))))>1
        tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
        tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
        
        if numel(temppols(i,~isnan(temppols(i,:))))<3
           tagerrs(i,tag_ind) =0;
        end
    end
%         if tag_ind == baz_ind;
%             tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
%         end
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
end


colors = [[0 0 1];[0 0.8 0];[0.8 0 0.8];[0.9 0.5 0.1];[1 0 0];[0.3 0 0.3];[0 0 0]];
colors = [[0 0.8 0];[0 0 1];[0.8 0 0];[0.7 0 0.7]];
fh = figure;
axesh = axes('Parent', fh);
hold on
linewidth = 3;
% 
% for tag_ind = 1:length(tagged_name_list)
%     errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'color',colors(tag_ind,:))
% end
h = [];
for tag_ind = 1:length(tagged_name_list)
    h = [h plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
end

if xlim_bool
    set(gca,'xlim',xlim_input);
end
if ylim_bool
    set(gca,'ylim',ylim_input);
end
plot(global_timepoints,zeros(size(global_timepoints)),'m')
ylabel('polarity (log2)','fontsize',18);
xlabel('time (min)','fontsize',18);

set(gca,'fontsize',18)
set(gcf,'position',[100 100 800 800]);
legend(h,legendtxt,'interpreter','none','fontsize',12,'location','northwest');
fix_2016a_figure_output(gcf);
bname = [save_dir, 'all-pols-reg'];
saveas(gcf, [bname '.fig']);
saveas(gcf, [bname '.pdf']);
saveas(gcf, [bname '.tif']);
plot(global_timepoints,zeros(size(global_timepoints)),'m');
    
for tag_ind = 1:length(tagged_name_list)
%     h = [h errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
    warning('off','all');
    try
     [hLine, hPatch] = boundedline(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),...
                '-r',axesh,... 
                'transparency', 0.5,...
                'orientation', 'vert',...
                'cmap',colors(tag_ind,:),...
                'linewidth',linewidth);
    catch
        display('failed to generate chart.');
    end
    warning('on','all');

end

    savename = [save_dir,filesep,'all-pols-reg-errors'];
    saveas(gcf,[savename,'.pdf']);
    saveas(gcf,[savename,'.jpg']);
    saveas(gcf,[savename,'.fig']);
      
      
% % % % % % % % % %       
% % % % % % % % % % 
% % % % % % % % % % 

% run stacking algorithm plot
function grouped_per_tag_pols_stacked_plot(save_dir,tagged_name_list,global_timepoints,big_pol_mat_stack,...
        legendtxt)

tagmeans = nan(length(global_timepoints),num_proteins);
tagerrs = tagmeans;
for tag_ind = 1:length(tagged_name_list)
    
    temppols = big_pol_mat_stack(:,:,tag_ind);
    for i = 1:length(global_timepoints)
        
        if length(temppols(i,~isnan(temppols(i,:))))>1
            tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
            tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
        
        if numel(temppols(i,~isnan(temppols(i,:))))<3
           tagerrs(i,tag_ind) =0;
        end
    end
%         tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));

end



fh = figure;
axesh = axes('Parent', fh);
hold on
linewidth = 3;
% 
% for tag_ind = 1:length(tagged_name_list)
%     errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'color',colors(tag_ind,:))
% end
h = [];
for tag_ind = 1:length(tagged_name_list)
    h = [h plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
end


set(gca,'xlim',[-25,10]);
set(gca,'ylim',[-0.2,1]);
plot(global_timepoints,zeros(size(global_timepoints))+0.5,'--c')
ylabel('polarity stacking score','fontsize',18);
xlabel('time (min)','fontsize',18);

set(gca,'fontsize',18)
set(gcf,'position',[100 100 800 800]);
legend(h,legendtxt,'interpreter','none','fontsize',12,'location','northwest');

bname = [save_dir, 'all-pols-stack'];
saveas(gcf, [bname '.fig']);
saveas(gcf, [bname '.pdf']);
saveas(gcf, [bname '.tif']);
   
    
        
    plot(global_timepoints,zeros(size(global_timepoints)),'m');
    
%     for tag_ind = 1:length(tagged_name_list)
%     h = [h errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
%     end
    
    for tag_ind = 1:length(tagged_name_list)
     [hLine, hPatch] = boundedline(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),...
                '-r',axesh,...        
                'transparency', 0.4,...
                'orientation', 'vert',...
                'cmap',colors(tag_ind,:),...
                'linewidth',linewidth);
    end


savename = [save_dir,filesep,'all-pols-stack-errors'];
saveas(gcf,[savename,'.pdf']);
saveas(gcf,[savename,'.jpg']);
saveas(gcf,[savename,'.fig']);
    
      
      
      
      
% % % % % % % % % %       
% % % % % % % % % % 
% % % % % % % % % % 

% run full cortical / cyto  plot
function grouped_per_tag_cort2cyto_plot(save_dir,tagged_name_list,global_timepoints,big_cortical_to_cyto_mat,...
        legendtxt)
   tagmeans = nan(length(global_timepoints),num_proteins);
    tagerrs = tagmeans;
    for tag_ind = 1:length(tagged_name_list)

        temppols = big_cortical_to_cyto_mat(:,:,tag_ind);
        for i = 1:length(global_timepoints)
            tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
            tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
%         tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
    end


    fh = figure;
    axesh = axes('Parent', fh);
    hold on
    linewidth = 3;

    h = [];
    for tag_ind = 1:length(tagged_name_list)
        h = [h plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
    end


    set(gca,'xlim',[-30,20]);
    plot(global_timepoints,zeros(size(global_timepoints)),'m')
    ylabel('cortical to cyto ratio','fontsize',18);
    xlabel('time (min)','fontsize',18);

    set(gca,'fontsize',18)
    set(gcf,'position',[100 100 800 800]);
    legend(h,legendtxt,'interpreter','none','fontsize',12);

        bname = [save_dir, 'all-cort-to-cyto'];
        saveas(gcf, [bname '.fig']);
        saveas(gcf, [bname '.pdf']);
        saveas(gcf, [bname '.tif']);

        plot(global_timepoints,zeros(size(global_timepoints)),'m');


        for tag_ind = 1:length(tagged_name_list)
        h = [h errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
        end


        savename = [save_dir,filesep,'all-cort-to-cyto-errors'];
        saveas(gcf,[savename,'.pdf']);
         saveas(gcf,[savename,'.jpg']);
          saveas(gcf,[savename,'.fig']);
      
      
      
      
      
% % % % 
% % % % 
% % % % % % % % % %       
% % % % % % % % % % 
% % % % % % % % % % 

% run regular mean polarity plot normed


function grouped_per_tag_pol_normed_plot(save_dir,tagged_name_list,global_timepoints,big_pol_mat_normed,...
        legendtxt)

tagmeans = nan(length(global_timepoints),num_proteins);
tagerrs = tagmeans;
for tag_ind = 1:length(tagged_name_list)
    
    temppols = big_pol_mat_normed(:,:,tag_ind);
    for i = 1:length(global_timepoints)
        if length(temppols(i,~isnan(temppols(i,:))))>1
        tagmeans(i,tag_ind) = mean(temppols(i,~isnan(temppols(i,:))));
        tagerrs(i,tag_ind) = (std(temppols(i,~isnan(temppols(i,:)))))/numel(temppols(i,~isnan(temppols(i,:))))^(1/2);
        end
        
        if numel(temppols(i,~isnan(temppols(i,:))))<3
           tagerrs(i,tag_ind) =0;
        end
    end
%         if tag_ind == baz_ind;
%             tagmeans(:,tag_ind) = abs(tagmeans(:,tag_ind));
%         end
        tagmeans(:,tag_ind) = smoothen(tagmeans(:,tag_ind));
end


% colors = [[0 0 1];[0 0.8 0];[0.8 0 0.8];[0.9 0.5 0.1];[1 0 0];[0.3 0 0.3];[0 0 0]];
fh = figure;
axesh = axes('Parent', fh);
hold on
linewidth = 3;
% 
% for tag_ind = 1:length(tagged_name_list)
%     errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'color',colors(tag_ind,:))
% end
h = [];
for tag_ind = 1:length(tagged_name_list)
    h = [h plot(global_timepoints,tagmeans(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
end


set(gca,'xlim',[-25,10]);
set(gca,'ylim',[-0.2,1]);
plot(global_timepoints,zeros(size(global_timepoints)),'m')
ylabel('polarity (log2)','fontsize',18);
xlabel('time (min)','fontsize',18);

set(gca,'fontsize',18)
set(gcf,'position',[100 100 800 800]);
legend(h,legendtxt,'interpreter','none','fontsize',12,'location','northwest');

	bname = [save_dir, 'reg-pols-normed'];
    saveas(gcf, [bname '.fig']);
    saveas(gcf, [bname '.pdf']);
    saveas(gcf, [bname '.tif']);
    
    plot(global_timepoints,zeros(size(global_timepoints)),'m');
    
%     for tag_ind = 1:length(tagged_name_list)
%     h = [h errorbar(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),'linewidth',linewidth,'color',colors(tag_ind,:))];
%     end
    
    
for tag_ind = 1:length(tagged_name_list)
     [hLine, hPatch] = boundedline(global_timepoints,tagmeans(:,tag_ind),tagerrs(:,tag_ind),...
                '-r',axesh,...        
                'transparency', 0.4,...
                'orientation', 'vert',...
                'cmap',colors(tag_ind,:),...
                'linewidth',linewidth);
 end   


    savename = [save_dir,filesep,'reg-pols-normed-errorbars'];
    saveas(gcf,[savename,'.pdf']);
    saveas(gcf,[savename,'.jpg']);
    saveas(gcf,[savename,'.fig']);
    

    

    