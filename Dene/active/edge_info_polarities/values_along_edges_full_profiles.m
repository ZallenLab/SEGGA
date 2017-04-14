function values_along_edges_full_profiles(base_dir, seg_filename, channel_info, seq, ...
    data, options, save_name, edges)
% save_name = ['edges_info_max_proj_',layers_str]; % string used to name mat file

disp(base_dir)
if nargin < 7 || isempty(save_name)
    save_name = 'edges_info_cell_background_full_profiles';
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

[levels_all_full_profiles background_levels x1 x2 y1 y2 cells_levels min_pixel] = ...
    seq2edgeIntensities_data_full_profiles(seq, {channel_info.filename}, edges, seg_filename, ...
    options, data, cells);

len = smoothen(data.edges.len(:, edges));
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
ang = smoothen(ang);
len(~data.edges.selected(:, edges)) = nan; 


inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
inverse_edges_map(edges) = 1:length(edges);


for ch = 1:length(channel_info)

    channel_info(ch).cells.cytoplasm = cells_levels(:, :, ch) - min(min_pixel(:, ch));
    channel_info(ch).cells.cytoplasm_unadjusted = cells_levels(:, :, ch);
    channel_info(ch).levels_all_full_profiles = levels_all_full_profiles(:, :, ch);
    channel_info(ch).background = background_levels(:, :, ch);
    channel_info(ch).min_pixel = min_pixel(:, ch);
end

    
    


save(save_name, ...
    'seq', 'channel_info', 'edges', 'x1', 'x2', 'y1', 'y2', 'options');

