function add_on_analysis_fixed_polarity_image(pol_cmap_opts)

if nargin <1 || isempty(pol_cmap_opts)
    pol_cmap_opts.type = 'Adaptive';
    pol_cmap_opts.val = 0;
    pol_cmap_opts.bounds = [];
end

% savename = dir('edges_info*');
% 
% if isempty(savename)
%     display('savename not found, analysis not saved, or not found');
%     return
% end
% 
% if length(savename) >1
%     display('more than one edges_info file');
%     display(savename(:).name);
% end

% savename = savename(1).name;
% DLF DEBUG
savename = 'edges_info_max_proj_single_given.mat';
if isempty(dir(savename))
    display(['savename: (',savename,') missing']);
    return
end

output_dir = [pwd,filesep,'analysis_charts',filesep];
if ~isdir(output_dir)
    mkdir(output_dir);
end

load(savename);
seq.directory = pwd;
seq = load_dir(pwd);
if isempty(seq)
    return
end
data = seq2data(seq);


% if isempty(dir('figure-nearest-ngbr-calcs*'))
%     display('trying to fix saved edges for data, fix seq and data variables');
%     % temp update code
%     seq = load_dir(pwd);
%     data = seq2data(seq);
%     save(savename,'seq','data','-append');
% end

currdir = pwd;
currdirreverse = currdir(end:-1:1);
[toke, remain] = strtok(currdirreverse,'/');
currcolor = toke(end:-1:1);

colorind = 0;
colorfound = 0;
for i = 1:length(channel_info)
    if strcmp(channel_info(i).color,currcolor)
        colorind = i;
        colorfound = 1;
        continue
    end
end

if ~colorfound
    display('color of dir not matched: error');
    return
end


dir_name = 'dummyvar';
seg_foldername = pwd;

cell_pol = channel_info(colorind).cell_pol;
imgfilename = channel_info(colorind).filename;
imgfilenamereverse = imgfilename(end:-1:1);
[toke, remain] = strtok(imgfilenamereverse,'/');
current_color_foldername = remain(end:-1:1);


% % old technique, needed to get this earlier (above)
% strspots = strfind(current_color_foldername,filesep);
% lastspot = strspots(end-1);
% currcolor = current_color_foldername((lastspot+1):end-1);

possiblecolors = {'red','green','blue'};

if isempty(intersect(currcolor,possiblecolors, 'legacy'))
    display('missing proper color name');
    return
end


% % commenting this stuff out because it's in the script: 
% % fixed_image_polarity_single_color_script;

len = smoothen(data.edges.len(:, edges));
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
ang = smoothen(ang);
len(~data.edges.selected(:, edges)) = nan; 

if length(seq.frames)>1
    cells = find(any(data.cells.selected));
else
    cells = find(data.cells.selected);
end
shift_info = 0;
timestep = 15;


if size(levels_all,3)>1
    curr_levels_single = levels_all(:,:,colorind);
else
    curr_levels_single = levels_all;
end


%%% need to keep angles in the interval [0,180];
ang = (data.edges.angles(:, edges));

binAngH = bin_by_angles_test_orientation(seq,data,edges,ang,len,...
    curr_levels_single,...
    shift_info,timestep,dir_name,seg_foldername,current_color_foldername);


particularbname = 'hist-of-ang-intensity';
% bname = [pwd,filesep,particularbname];
bname = [output_dir,filesep,particularbname];
pos = [680   408   801   684];
set(gcf, 'position', pos);
fix_2016a_figure_output(gcf);
% saveas(gcf, [bname '.fig']);
% saveas(gcf, [bname '.pdf']);
saveas(gcf, [bname '.tif']);      
close(binAngH);
                
                
% %   DLF DEBUG MISMATCH NEW TO OLD SEG FILES - NOT TO BE USED
% %   IN FUTURE
% %   h = figure;
% %   uiwait(h);
%     commandsui;
%     seq = getappdata(gcf, 'seq');
%     data = seq2data(seq);
%     cells = find(data.cells.selected(1,:));
                
% fixed_image_polarity_single_color_script;

% nnbr_bool = 1;
% img_save_str = 'nngbr-pols';
% [new_colored_seq mod_cell_pols] = all_purpose_single_image_polarity_visualization(seq, curr_levels_single, data,save_name, nnbr_bool, img_save_str);
% seq = new_colored_seq;
% make_and_save_single_pol_img(new_colored_seq,cells,mod_cell_pols, img_save_str);

nnbr_bool = 0;
img_save_str = ['raw-pols-',channel_info(colorind).color];
[new_colored_seq, mod_cell_pols] = ...
    all_purpose_single_image_polarity_visualization_DLF(colorind, seq, curr_levels_single,...
    data,save_name, nnbr_bool, img_save_str, pol_cmap_opts, output_dir);
seq = new_colored_seq;
make_and_save_single_pol_img(new_colored_seq,cells,mod_cell_pols, img_save_str, output_dir);


% rnadir = %<rna-dir-name-here>;
% if isdir(rnadir)
%     make_and_save_single_pol_img_in_situ(seq, cells, cell_pol, img_save_str, rnadir)
% end
% 
% img_save_str = '';
% extra_save_name = 'cells_extra_info';
% make_and_save_single_cellareas_img(seq,cells,mod_cell_pols, img_save_str, extra_save_name);
% close all
% 
% img_save_str = '';
% make_and_save_single_topo_img(seq,cells,mod_cell_pols, img_save_str, extra_save_name);
% close all
% 
% img_save_str = '';
% make_and_save_single_cellshapes_img(seq, cells, img_save_str, extra_save_name)
% close all





return
                

                

