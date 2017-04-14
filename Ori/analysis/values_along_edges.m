function values_along_edges(base_dir, seg_filename, channel_info, seq, ...
    data, options, save_name, edges)
% save_name = ['edges_info_max_proj_',layers_str]; % string used to name mat file
make_figs_bool = false;
disp(base_dir)
if nargin < 7 || isempty(save_name)
    save_name = 'edges_info_cell_background';
end
if nargin < 8 || isempty(edges)
    edges = find(any(data.edges.selected));
end

seg_dir = fullfile(relative_dir(base_dir, './seg'));
old_dir = pwd;
cd(base_dir);
if ~isdir('./figures')
    mkdir('figures')
end
figures_dir = fullfile(relative_dir(base_dir, './figures'));
cd(old_dir);

def_options.z_shift_file = [];
%%% DEBUG DLF Edit
% def_options.const_z_for_t = 9999;
def_options.const_z_for_t = [];
def_options.limit_to_embryo = false;
def_options.poly_file = fullfile(relative_dir(base_dir, './seg'), 'embryo.mat');

def_options.edge_positions_from_options = false;
def_options.smoothen_edges = true;
def_options.optimize_edges_pos = true;

def_options.figs_prefix = '';

%overlay input options on default options.
options = overlay_struct(def_options, options);
options.smoothen_edges = options.smoothen_edges & ~options.edge_positions_from_options;
options.optimize_edges_pos = options.smoothen_edges & ~options.edge_positions_from_options;




cells = find(any(data.cells.selected)); %which cells to report cytoplasm 
% levels for. Later used to specify in which cells to calculate polarity
% and mean intensity etc.

[levels_all background_levels x1 x2 y1 y2 cells_levels min_pixel] = ...
    seq2edgeIntensities_data(seq, {channel_info.filename}, edges, seg_filename, ...
    options, data, cells);

len = smoothen(data.edges.len(:, edges));
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
ang = smoothen(ang);
len(~data.edges.selected(:, edges)) = nan; 

for i = 1:size(levels_all,3)
    temp_l = levels_all(:, :, i);
    temp_l = temp_l(data.edges.selected(:, edges));
    disp(sum(temp_l(:)<=0))
    disp(sum(temp_l(:)>0))
end
% temp_l = levels_all(:, :, 2);
% temp_l = temp_l(data.edges.selected(:, edges));
% disp(sum(temp_l(:)<=0))
% disp(sum(temp_l(:)>0))

levels_all(levels_all(:)<=0) = nan;
% levels_all(:,:,1) = channel_info(1).levels;
% levels_all(:,:,2) = channel_info(2).levels;

inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
inverse_edges_map(edges) = 1:length(edges);

for ch = 1:length(channel_info)
    [polarity mean_cell_edge_intensity ap_ratio dv_ratio] = ...
        cell_polarity_from_edges_data_vectorized(seq, ang, ...
        smoothen(levels_all(:, :, ch)), cells, inverse_edges_map, data, 8);
%     mean_cell_edge_intensity = mean_cell_edge_intensity ;
    channel_info(ch).cells.polarity = polarity;
    channel_info(ch).cells.mean_edge_intensity = mean_cell_edge_intensity;
    channel_info(ch).cells.ap_ratio = ap_ratio;
    channel_info(ch).cells.dv_ratio = dv_ratio;
    channel_info(ch).cells.cytoplasm = cells_levels(:, :, ch) - min(min_pixel(:, ch));
    channel_info(ch).cells.cytoplasm_unadjusted = cells_levels(:, :, ch);
    channel_info(ch).levels = levels_all(:, :, ch);
    channel_info(ch).background = background_levels(:, :, ch);
    channel_info(ch).min_pixel = min_pixel(:, ch);
end

% %DEBUG
% save(save_name, 'seq', 'channel_info', 'edges', 'x1', 'x2', 'y1', 'y2', 'options',...
%     'cells_levels', 'min_pixel');


no_shift_info = true;
if length(dir(fullfile(seg_dir, 'shift_info.mat')))
    load('shift_info')
    no_shift_info = false;
else
    shift_info = 0;
end

no_timestep = true;
if length(dir(fullfile(seg_dir, 'timestep.mat')))
    load('timestep')
    no_timestep = false;
else
    timestep = 35;
end

if make_figs_bool
    h = bin_by_angles_func(seq, data, ang, channel_info, edges, [], ...
        timestep, shift_info);
end

for ch = 1:length(h)
    if no_timestep || no_shift_info
        set(get(h(ch), 'currentAxes'), 'xColor', 'r');
    end
    set(get(h(ch), 'currentAxes'),'xlim',[-15,20]);
    fig_name = fullfile(figures_dir, ...
        [options.figs_prefix,'intensity_by_angle_',channel_info(ch).name,num2str(ch)]);
    saveas(h(ch), [fig_name '.fig']);
     saveas(h(ch), [fig_name '.pdf']);
    close(h(ch))
end

mean_adjusted_levels_out = mean_adjusted_levels_edge_info(channel_info);
adjusted_chan_info = channel_info;
for ch = 1:length(channel_info)
    adjusted_chan_info(ch).levels = mean_adjusted_levels_out(ch).levels;
end

if make_figs_bool
    h_adjusted = bin_by_angles_func(seq, data, ang, adjusted_chan_info, edges, [], ...
        timestep, shift_info);


    for ch = 1:length(h_adjusted)
        if no_timestep || no_shift_info
            set(get(h_adjusted(ch), 'currentAxes'), 'xColor', 'r');
        end
        set(get(h_adjusted(ch), 'currentAxes'),'xlim',[-15,20]);
        fig_name = fullfile(figures_dir, ...
            [options.figs_prefix 'adjusted_intensity_by_angle_'   channel_info(ch).name    num2str(ch)]);
        saveas(h_adjusted(ch), [fig_name '.fig']);
         saveas(h_adjusted(ch), [fig_name '.pdf']);
        close(h_adjusted(ch))
    end

end % if make_figs_bool


        
additional_var_names = {};
timepoints = length(seq.frames);
for ch = 1:length(channel_info)
    fns = fieldnames(channel_info(ch).cells);
    for cnt = 1:length(fns)
        fn = fns{cnt};
        channel_info(ch).cell_avg.(fn) = nan(1, timepoints);
        for j = 1:timepoints
            channel_info(ch).cell_avg.(fn)(j) = mean(...
                channel_info(ch).cells.(fn)(j, ...
                    ~isnan(channel_info(ch).cells.(fn)(j, :))));
        end
    end
    new_var_name = [channel_info(ch).name '_cell_polarity']; 
    eval([new_var_name ' = channel_info(ch).cell_avg.polarity;']);
    additional_var_names{end+1} = new_var_name;
    
    new_var_name = [channel_info(ch).name '_edge_intensity_back_subtracted']; 
    eval([new_var_name ' = channel_info(ch).cell_avg.mean_edge_intensity;']);    
    additional_var_names{end+1} = new_var_name;
    
    edge_raw_all = channel_info(ch).levels + channel_info(ch).background; %for all edges
    edge_raw_avg = nan(size(edge_raw_all,1),1);
    for ii = 1:size(edge_raw_all,1)
        edge_raw_avg(ii)  = mean(edge_raw_all(ii,~isnan(edge_raw_all(ii,:))));
    end
    
    new_var_name = [channel_info(ch).name '_edge_intensity_unadjusted']; 
    eval([new_var_name ' = edge_raw_avg;']);
    additional_var_names{end+1} = new_var_name;
    
    
    edges_min_sub = edge_raw_avg - channel_info(ch).min_pixel;
    edges_min_sub = edges_min_sub';
    new_var_name = [channel_info(ch).name '_edge_intensity_min_subtracted']; 
    eval([new_var_name ' = edges_min_sub;']);
    additional_var_names{end+1} = new_var_name;
    
    
    
    new_var_name = [channel_info(ch).name '_cytoplasm']; 
    eval([new_var_name ' = channel_info(ch).cell_avg.cytoplasm;']);
    additional_var_names{end+1} = new_var_name;
    
    new_var_name = [channel_info(ch).name '_cytoplasm_unadjusted']; 
    eval([new_var_name ' = channel_info(ch).cell_avg.cytoplasm_unadjusted;']);
    additional_var_names{end+1} = new_var_name;
    
	new_var_name = [channel_info(ch).name '_edge_to_cyto_ratio']; 
    eval([new_var_name ' = edges_min_sub./(channel_info(ch).cell_avg.cytoplasm);']);
    additional_var_names{end+1} = new_var_name;
    
	new_var_name = [channel_info(ch).name '_edge_to_cyto_diff']; 
    eval([new_var_name ' = edges_min_sub - channel_info(ch).cell_avg.cytoplasm;']);
    additional_var_names{end+1} = new_var_name;
    
    
    new_var_name = [channel_info(ch).name '_min_pixel']; 
    eval([new_var_name ' = channel_info(ch).min_pixel;']);
    additional_var_names{end+1} = new_var_name;
    
    
    
%  min(channel_info(ch).min_pixel) is already substracted from cyto levels
%  when setting channel_info.cells above.
    %     eval([new_var_name ' = ' new_var_name ' - min(channel_info(ch).min_pixel);']); 
%     additional_var_names{end+1} = new_var_name;
end
% % DEBUG
% save(save_name, ...
%     'seq', 'channel_info', 'edges', 'x1', 'x2', 'y1', 'y2', 'options', ...
%     additional_var_names{:});



for ch = 1:length(channel_info)
    if make_figs_bool
        
        h = draw_pol_fig(channel_info(ch).cell_avg, ...
                fieldnames(channel_info(ch).cell_avg), ...
                ['Cell Polarity '   channel_info(ch).name   num2str(ch)], ...
                timestep, shift_info, no_timestep || no_shift_info);

        fig_name = fullfile(figures_dir, ...
            [options.figs_prefix 'misc_polarity_'   channel_info(ch).name   num2str(ch)]);
            saveas(h, [fig_name '.fig']);
            saveas(h, [fig_name '.pdf']);
            close(h)
    


        cmap = [1 0 0; 0 1 0; 0 0 1];
        for ch = 1:length(channel_info)
            graph_data.(['ch' num2str(ch)]) = channel_info(ch).cell_avg.polarity;
        end
        h = draw_pol_fig(graph_data, {channel_info.name}, 'Cell Polarity', ...
                    timestep, shift_info, no_timestep || no_shift_info, cmap);

        fig_name = fullfile(figures_dir, [options.figs_prefix  'cell_polarity_all_channels']);
            saveas(h, [fig_name '.fig']);
            saveas(h, [fig_name '.pdf']);
            close(h)        

        for ch = 1:length(channel_info)
            graph_data.(['ch' num2str(ch)]) = deriv(channel_info(ch).cell_avg.polarity);
        end
        h = draw_pol_fig(graph_data, {channel_info.name}, ...
                    'Derivative of Cell Polarity', ...
                    timestep, shift_info, no_timestep || no_shift_info, cmap);

        fig_name = fullfile(figures_dir, [options.figs_prefix 'cell_polarity_d_all_channels']);
            saveas(h, [fig_name '.fig']);
            saveas(h, [fig_name '.pdf']);
            close(h)
    end % if make_figs_bool
            


    for ch = 1:length(channel_info)
        cytomean = nan(size(cells));
        edgecell_mean = nan(size(cells));
        qc = nan(length(seq.frames), 101);
        qe = nan(length(seq.frames), 101);
        for i = 1:length(cells)
            cytomean(i) = mean(channel_info(ch).cells.cytoplasm(...
                        ~isnan(channel_info(ch).cells.cytoplasm(:, i)), i));
            edgecell_mean(i) = mean(...
                channel_info(ch).cells.mean_edge_intensity(...
                ~isnan(channel_info(ch).cells.mean_edge_intensity(:, i)), i));
        end

        cyto_normed = (channel_info(ch).cells.cytoplasm) ./ ...
            repmat(cytomean, length(seq.frames), 1);
        edgecell_normed = (channel_info(ch).cells.cytoplasm) ./ ...
            repmat(cytomean, length(seq.frames), 1);    
        for i = 1:length(seq.frames)
            qc(i, 1:101) = quantile(cyto_normed(i, :), 0:0.01:1);
            qe(i, 1:101) = quantile(edgecell_normed(i, :), 0:0.01:1);
        end
        
        if make_figs_bool
            h = figure;
            set(gca, 'colorOrder', jet(101), 'nextPlot', 'replacechildren')
            plot(qc);
            fig_name = fullfile(figures_dir, ...
                [options.figs_prefix 'cyto_deviation'   channel_info(ch).name    num2str(ch)]);
            saveas(h, [fig_name '.fig']);
            close(h)
            h = figure;
            set(gca, 'colorOrder', jet(101), 'nextPlot', 'replacechildren')
            plot(qe);
            fig_name = fullfile(figures_dir, ...
                [options.figs_prefix 'mean_edgecell_deviation'   channel_info(ch).name    num2str(ch)]);
            saveas(h, [fig_name '.fig']);
            saveas(h, [fig_name '.pdf']);
            close(h)
        end % if make_figs_bool
    end 
        

    new_var_name = [channel_info(ch).name '_cyto_deviation']; 
    eval([new_var_name ' = qc;']);
    additional_var_names{end+1} = new_var_name;

    new_var_name = [channel_info(ch).name '_mean_edgecell_deviation']; 
    eval([new_var_name ' = qe;']);
    additional_var_names{end+1} = new_var_name;
       
end


save(save_name, ...
    'seq', 'channel_info', 'edges', 'x1', 'x2', 'y1', 'y2', 'options', ...
    additional_var_names{:});


function h = draw_pol_fig(pol_data, leg, ttl, timestep, shift_info, ...
                          red_flag, cmap)

h = figure;
fns = fieldnames(pol_data);    
if nargin < 2 || isempty(leg)
    leg = fns;
end

if nargin < 7 || isempty(cmap)
    cmap = lines(length(fns));
    cmap(1, :) = [0 0 0];
end
if size(cmap, 1) < length(fns)
    cmap((end+1):length(fns), :) = lines(length(fns) - size(cmap, 1));
end

for cnt = 1:length(fns)
    fn = fns{cnt};
    plot(timestep*((1:length(pol_data.(fn))) + shift_info)/60, ...
        smoothen(pol_data.(fn)), 'linewidth', 3, 'color', cmap(cnt, :));
    hold on
end
set(gca, 'fontsize', 14);
if red_flag
    set(gca, 'xColor', 'r');
end
title(ttl, 'interpreter', 'none', 'fontsize', 14);
legend(leg, 'interpreter', 'none');