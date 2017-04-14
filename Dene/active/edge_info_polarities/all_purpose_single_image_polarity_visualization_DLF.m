function [seq, mod_cell_pol] =...
    all_purpose_single_image_polarity_visualization_DLF(chan_num, in_seq,...
    levels_single_protein, data, save_name, nnbr_bool, img_save_str, ...
    pol_cmap_opts, output_dir)

if nargin < 9 || isempty(output_dir)
    output_dir = [pwd,filesep,'analysis_charts',filesep];
    if ~isdir(output_dir)
        mkdir(output_dir);
    end
end

if nargin < 8 || isempty(pol_cmap_opts)
    pol_cmap_opts.type = 'Adaptive';
    pol_cmap_opts.val = 0;
    pol_cmap_opts.bounds = [];
end

if nargin < 7 || isempty(img_save_str)    
    img_save_str = 'raw-pols';        
end

if nargin < 6 || isempty(nnbr_bool)    
    nnbr_bool = false;    
end

if nargin>5 && ~isempty(save_name)
    load(save_name,'channel_info','edges');
else if ~isempty(save_name)
        display('warning: loading default -edges_info-');
        load edges_info;    
    else
        display('warning: loading any -edges_info*-');
        load edges_info*;   
    end   
end


seq = in_seq;

if~isempty(whos('local_cells')) clear('local_cells'); end

make_plot = true;
if length(seq.frames)>1
    len = smoothen(data.edges.len(:, edges));
else
    len = data.edges.len(:, edges);
end
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);

if length(seq.frames)>1
    ang = smoothen(ang);
end

if length(seq.frames)>1
    cells = find(any(data.cells.selected));
else
    cells = find(data.cells.selected);
end
num_frames = length(seq.frames);

% %-------- Edge MAPPING ----------
inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
inverse_edges_map(edges) = 1:length(edges);
edges_data_map = inverse_edges_map;

[pol_cells_labeledProtein, cell_mean_intensity ap_cells_labeledProtein dv_cells_labeledProtein] =...
    cell_polarity_from_edges_data(seq, ang, levels_single_protein, cells, edges_data_map, data);
nngbr_cell_pol = calc_pols_from_nearest_neighbors(pol_cells_labeledProtein,seq,data);
    

% %-------- Cell MAPPING ----------
linear_global = find(cells); %position -> global
inv_linear_map(linear_global) = 1:length(linear_global); %global -> position
%% --- (also used to debug do not remove)-----

for i = 1:num_frames
    local_cells(i,:) = seq.cells_map(i,cells(:));
end



for i = 1:num_frames
    seq.frames(i).cells = local_cells(i,:); %all cells to be colored (by local numbers)
    pos_inds = find(local_cells(i,:));

% % % %    IF USING NEAREST NEIGHBORS
    if nnbr_bool
        tempcellpols = nngbr_cell_pol(i, pos_inds);
        mod_cell_pol = nngbr_cell_pol;        
    else        
        tempcellpols = pol_cells_labeledProtein(i, pos_inds);
        mod_cell_pol = pol_cells_labeledProtein;        
    end
    
    switch pol_cmap_opts.type
        
        case 'Adaptive' % pol_cmap_opts.val = 0;
            if isfield(channel_info(chan_num),'cells')
                tmp_all_cells = channel_info(chan_num).cells.polarity(:);
            elseif isfield(channel_info(chan_num),'cell_pol')
                tmp_all_cells = channel_info(chan_num).cell_pol;    
            else
                display('could not find appropriate field for cell polarities in channel_info data structure');                    
            end
                
                
            tmp_all_cells = tmp_all_cells(~isnan(tmp_all_cells));
            pol_mean = mean(tmp_all_cells);
            pol_std = std(tmp_all_cells);
            pol_rad = abs(pol_mean)+2*pol_std;
            
            display('using adaptive polarity colormap bounds');
            b = [-pol_rad,pol_rad];
            incr_step = diff(b)/100;
            %%% if the magnitude of the value is larger than pol_rad*5 then it's probably
            %%% something weird/wrong - so map it back to the middle (done below)
            incrvals = [-pol_rad*5,b(1):incr_step:b(end),pol_rad*5];
        case 'User Defined' % pol_cmap_opts.val = 1;
            display('using user defined polarity colormap bounds');
            b = pol_cmap_opts.bounds;
            incr_step = diff(b)/100;
            %%% if the value is outside of the user defined range by twice the
            %%% span of the range, then map to the middle just as in the other
            %%% cases.
            far_left = b(1) - 2*diff(b);
            far_right = b(end) + 2*diff(b);
            incrvals = [far_left,b(1):incr_step:b(end),far_right];    
        case 'Hard Coded'
            %%% Hard Coded Color Map Values
            incrvals_baz = [-20,-1:.05:1,20];
            incrvals_sqh = [-20,-0.5:.025:0.5,20];   
            if strcmp(channel_info(chan_num).name,'sqh') || strcmp(channel_info(chan_num).name,'green')
                incrvals = incrvals_sqh;
            else if strcmp(channel_info(chan_num).name,'baz') || strcmp(channel_info(chan_num).name,'red')
                    incrvals = incrvals_baz;
                else if strcmp(channel_info(chan_num).name,'rna') || strcmp(channel_info(chan_num).name,'blue')
                        incrvals = incrvals_sqh;
                    else
                    display(['no condition for: ',channel_info(chan_num).name]);
                    end
                end
            end            
        otherwise
            display(['Unknown polarity cmap bounds option type [',pol_cmap_opts.type,']']);
    end
    incr_min = incrvals(2);
    incr_max = incrvals(end-1);
    
    
    

    % new diverging color map, with black in the middle
    specialcolormap = bipolar(length(incrvals), 0.1);

    
%     tempcellpols = pol_cells(i, pos_inds);
    temp_pol_inds = ~isnan(tempcellpols);
    [n,bin] = histc(tempcellpols(temp_pol_inds),incrvals);
    bin(bin==0) = floor(length(incrvals)/2);
    
    cell_passed_thru = pos_inds(temp_pol_inds);
    cell_did_not_pass = pos_inds(~temp_pol_inds);
    
    cellcolors = specialcolormap(bin,:);

    seq.frames(i).cells_colors(local_cells(i,cell_passed_thru), :) = cellcolors;
    seq.frames(i).cells_colors(local_cells(i,cell_did_not_pass), :) = repmat([0.4 0.4 0.4],length(cell_did_not_pass),1);
    seq.frames(i).cells_alphas(local_cells(i,cell_passed_thru)) = min(max(abs(tempcellpols(cell_passed_thru)).*(1/3),0.3),0.4);
    seq.frames(i).cells_alphas(local_cells(i,cell_did_not_pass)) = 0.3;
    seq.frames(i).cells = local_cells(i,data.cells.selected(i,cells));
   
end
load_seq(seq);


ticknums = [0,size(specialcolormap,1)/2,size(specialcolormap,1)];
ticktxt = {num2str(incr_min),num2str((incr_min+incr_max)/2),num2str(incr_max)};
rel_ticknums = ticknums./size(specialcolormap,1); 
% save_custom_cbar(colormap_in,tickvals,ticklabels,savedir,...
%                           savename,cbar_txt,alpha,ftypes)
alpha = [];
ftypes = {'tif'};
cbar_txt = [];
save_custom_cbar(specialcolormap,rel_ticknums,ticktxt,...
    output_dir,[channel_info(chan_num).name,'-cmap'],...
    cbar_txt, alpha, ftypes);

return