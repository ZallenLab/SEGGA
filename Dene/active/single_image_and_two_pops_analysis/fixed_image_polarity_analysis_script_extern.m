function fixed_image_polarity_analysis_script_extern(home_seg, pol_bool,edge_opt_bool)

if nargin < 3
    pol_bool = false; %just basic analysis - no polarity
end

if nargin < 2
    edge_opt_bool = false; %don't try to optimize edges
end

if nargin <1
    home_seg = pwd;
end

cd(home_seg);
[~,l] = strtok(fliplr(pwd),filesep);
base_dir = fliplr(l);
new_dir = 0;

if new_dir
    shift_info = 0;
    save shift_info shift_info
    timestep = 15;
    save timestep timestep
    analyze_dir_new
end

if ~pol_bool
    analyze_single_image;
end

seq = load_dir(pwd);
seq = update_seq_dir(seq);
seq.t = 1;
seq.z = 1;
seq.img_num = 1;

data = seq2data(seq);
if length(seq.frames)>1
    edges = find(any(data.edges.selected));
else
    edges = find(data.edges.selected);
end



layers_str = 'single_given';
save_name = ['edges_info_max_proj_',layers_str];


total_colors_list = {};
if isdir([base_dir, filesep,'red'])
    total_colors_list = {total_colors_list{:},'red'};
end

if isdir([base_dir, filesep,'green'])
    total_colors_list = {total_colors_list{:},'green'};
end

if isdir([base_dir, filesep,'blue'])
    total_colors_list = {total_colors_list{:},'blue'};
end


%%%%%%%%%%%%%%%%%%% measure intensity along edges %%%%%%%%%%%%%%%%%%%%%%%%%
seg_filename = fullfile(relative_dir(base_dir, './seg'), 'convertedsize_seg_T0001_Z0001.tif');

projection_imgs_list = {};

tmp_chan_ind = 1;
for i = 1:length(total_colors_list)
    
    color_ind_name = total_colors_list{i};
    if strcmp(color_ind_name,'red');
        chan_red_filename = fullfile(relative_dir(base_dir, './red'), 'convertedsize_red_T0001_Z0001.tif');
        if ~isempty(dir(chan_red_filename))
            channel_info(tmp_chan_ind).filename = chan_red_filename;
            channel_info(tmp_chan_ind).name = 'red';
            channel_info(tmp_chan_ind).marker_type = 'unknown-red';
            channel_info(tmp_chan_ind).color = 'red';
            projection_imgs_list = {projection_imgs_list{:}, chan_red_filename};
            tmp_chan_ind = tmp_chan_ind +1;
        end
    end
    
    if strcmp(color_ind_name,'green');
        chan_green_filename = fullfile(relative_dir(base_dir, './green'), 'convertedsize_green_T0001_Z0001.tif');
        if ~isempty(dir(chan_green_filename))
            channel_info(tmp_chan_ind).filename = chan_green_filename;
            channel_info(tmp_chan_ind).name = 'green';
            channel_info(tmp_chan_ind).marker_type = 'unknown-green';
            channel_info(tmp_chan_ind).color = 'green';
            projection_imgs_list = {projection_imgs_list{:}, chan_green_filename};
            tmp_chan_ind = tmp_chan_ind +1;
        end
    end
    
    
	if strcmp(color_ind_name,'blue');
        chan_blue_filename = fullfile(relative_dir(base_dir, './blue'), 'convertedsize_blue_T0001_Z0001.tif');
        if ~isempty(dir(chan_blue_filename))
            channel_info(tmp_chan_ind).filename = chan_blue_filename;
            channel_info(tmp_chan_ind).name = 'blue';
            channel_info(tmp_chan_ind).marker_type = 'unknown-blue';
            channel_info(tmp_chan_ind).color = 'blue';
            projection_imgs_list = {projection_imgs_list{:}, chan_blue_filename};
            tmp_chan_ind = tmp_chan_ind +1;
        end
    end
    
    

        
end





options.const_z_for_t = 1;
options.limit_to_embryo = true;
options.poly_file = fullfile(relative_dir(base_dir, '.\seg'), 'poly_seq.mat');

options.edge_positions_from_options = false;
% options.x1 = x1;
% options.x2 = x2;
% options.y1 = y1;
% options.y2 = y2;
options.smoothen_edges = false;%true & ~options.edge_positions_from_options;
options.optimize_edges_pos = edge_opt_bool; %true & ~options.edge_positions_from_options;

if length(seq.frames) >1
    cells_sel = find(any(data.cells.selected));
else
    cells_sel = find(data.cells.selected);
end
[levels_all background_levels x1 x2 y1 y2] =...
    seq2edgeIntensities_data(seq, projection_imgs_list, edges,...
                             seg_filename, options, data, cells_sel);

levels_all(levels_all(:)<=0) = nan;
if length(size(data.edges.len))>1 && size(data.edges.len,1)>1
    len = smoothen(data.edges.len(:, edges));
end
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
if length(size(ang))>1 && size(ang,1)>1
    ang = smoothen(ang);
end
len(~data.edges.selected(:, edges)) = nan; 

%     cells = find(any(data.cells.selected));
cells = cells_sel;
num_frames = length(seq.frames);
inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
inverse_edges_map(edges) = 1:length(edges);

for ch = 1:length(channel_info)
    [cell_pol cell_mean_intensity ap_ratio dv_ratio ...
        dv_ratio_oriented ap_ratio_oriented] = ...
        cell_polarity_from_edges_data(seq, ang, levels_all(:, :, ch), ...
        cells, inverse_edges_map, data);
    channel_info(ch).cell_pol = cell_pol;
    channel_info(ch).cell_mean_intensity = cell_mean_intensity;
    channel_info(ch).ap_ratio = ap_ratio;
    channel_info(ch).dv_ratio = dv_ratio;
    channel_info(ch).dv_ratio_oriented = dv_ratio_oriented;
    channel_info(ch).ap_ratio_oriented = ap_ratio_oriented;
end

save(save_name, 'seq', 'levels_all', 'background_levels',  ...
     'channel_info', 'edges', 'x1', 'x2', 'y1', 'y2',...
     'data','save_name');


return

