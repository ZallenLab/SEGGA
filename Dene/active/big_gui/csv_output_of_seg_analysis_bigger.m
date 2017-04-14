function csv_output_of_seg_analysis_bigger(indir)

cd(indir);
dir_str_inds = strfind(pwd,filesep);
currdir = pwd;
base_dir = currdir(1:(dir_str_inds(end-1)));
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));

save_dir = [pwd,filesep,'..',filesep,container_dir,'_txt_output',filesep];
if ~isdir(save_dir)
    mkdir(save_dir);
end

load shift_info
load timestep
load('analysis','seq','data');
load('poly_seq')


fid = fopen([save_dir,'datetime_created.txt'], 'w+');
fseek(fid,0,'bof');
datetime_txt = datestr(datetime());
entry_txt = [datetime_txt, ' --- Date this folder was created.'];
fwrite(fid,entry_txt);
fprintf(fid,'\n');


datetime_txt = get_file_last_mod_date('analysis.mat');
entry_txt = [datetime_txt, ' --- Date ''analysis.mat'' was last modified:'];
fwrite(fid,entry_txt);
fprintf(fid,'\n');

seg_file_names = {seq.frames(:).filename};
[all_seg_mods_str, all_seg_mods_nums] = ...
    cellfun(@get_file_last_mod_date,seg_file_names,...
                    'UniformOutput',false);
[~,idx] = sort([all_seg_mods_nums{:}]);
% oldest = all_seg_mods_str(idx(1));
youngest = all_seg_mods_str{idx(end)};

datetime_txt = get_file_last_mod_date('analysis.mat');
entry_txt = [youngest, ' --- Date most recent segmentation file was last modified:'];
fwrite(fid,entry_txt);
fprintf(fid,'\n \n');


entry_txt = ['***If you did not JUST NOW generate this file,',...
    '\n i.e. if the first date does not represent present time, ',...
    '\n then  you must manually check for the true last modified dates [or re-run text-output]',...
    '\n these time stamps (above) represent the modification and creation dates',...
    '\n at the time that this output was generated***'];

fprintf(fid,entry_txt);



fclose(fid);

combine_all_SEGGA_outputs_in_one_file(save_dir);

% return;
% More output available below.
% I dont think anyone would want it because
% It would be easier to access through matlab
% But you can remove the 'return' statement
% to output all the segmenation data as text files

%%% This conversion factor is for 40X, need to parameterize for other
%%% magnifications and/or get user input
conv_factor = 0.33;
edge_lengths_converted = data.edges.len.*conv_factor;
edge_lengths_pixels = data.edges.len;
edge_selected = data.edges.selected;



if isempty(dir('node_res_data.mat'));
    node_analysis_script_alignment;
end

load('node_res_data','res_time','ind_ros','all_possible',...
     't1_res_times','ros_res_times');
num_events_unresolved = all_possible - length(res_time);

load('topological_events_per_cell','num_t1_per_cell',...
    'num_ros_per_cell', 'n_lost_per_cell',...
    'cells_lost_hist', 'cells_t1_hist', 'cells_ros_hist',...
    'cells_gain_hist');

edge_lengths_converted(~edge_selected) = nan;

load('elon','L1','hor');
elon_func = @(x,t) x/x(max(-t, 0)+1);
longaxis_elon = elon_func(L1,shift_info);
hor_elon = elon_func(hor,shift_info);

if ~isempty(dir('piv_data*'))
    if isempty(dir('piv_procd_data.mat'))
        display('processing PIV data');
        process_piv_data;
    end
    load('piv_procd_data','rel_elon_mean');
end

%%%Indices of resolution event times that are for rosettes
res_ind_ros =   ind_ros;


meas_dir = [save_dir,filesep,'measurements',filesep];
if ~isdir(meas_dir)
    mkdir(meas_dir);
end

map_name = movie_var_name_mapping_SEGGA('node_resolution_times');
csvwrite([meas_dir, map_name,'.csv'],res_time');

if ~isempty(whos('rel_elon_mean'))
    map_name = movie_var_name_mapping_SEGGA('piv_hor_elon');
    csvwrite([meas_dir,map_name,'.csv'],rel_elon_mean);
end


map_name = movie_var_name_mapping_SEGGA('t1_res_times');
csvwrite([meas_dir,map_name,'.csv'],t1_res_times');
   
map_name = movie_var_name_mapping_SEGGA( 'ros_res_times');
csvwrite([meas_dir,map_name,'.csv'],ros_res_times');

if ~isempty(dir('edges_info_cell_background.mat'))
    pol_files = dir('edges_info_cell_background.mat');
    load(pol_files(1).name);
    for c = 1:length(channel_info)
        tmp_pol = channel_info(c).cell_avg.polarity;
        tmp_name = [channel_info(c).name,'_cell_polarity'];
        map_name = [channel_info(c).name,'_',movie_var_name_mapping_SEGGA(tmp_name)];
        csvwrite([meas_dir,tmp_name,'.csv'],tmp_pol');
    end
end
        


return 
meas_dir = [save_dir,filesep,'extra_measurements',filesep];
if ~isdir(meas_dir)
    mkdir(meas_dir);
end
%%%% Edges
edges = sum(data.edges.selected)>0;
edge_lens = data.edges.len(:,edges);
edge_lens(~data.edges.selected(:,edges)) = nan;
csvwrite([meas_dir, 'edge_lengths.csv'],edge_lens);

edge_angs = data.edges.angles(:,edges);
edge_angs(~data.edges.selected(:,edges)) = nan;
csvwrite([meas_dir, 'edge_angles.csv'],edge_angs);
csvwrite([meas_dir, 'edge_in_ROI.csv'],edges);

%%%% Cells
csvwrite([meas_dir, 'neighbors_gained.csv'],cells_gain_hist);
csvwrite([meas_dir, 'all_rearrangements.csv'],cells_lost_hist);
csvwrite([meas_dir, 't1s.csv'],cells_t1_hist);
csvwrite([meas_dir, 'rosettes.csv'],cells_ros_hist);



cells = sum(data.cells.selected)>0;
csvwrite([meas_dir, 'cell_in_ROI.csv'],cells);
nsides = data.cells.num_sides(:,cells);
nsides(~data.cells.selected(:,cells)) = nan;
csvwrite([meas_dir, 'number_of_sides.csv'],nsides);

areas = data.cells.area(:,cells);
areas(~data.cells.selected(:,cells)) = nan;
csvwrite([meas_dir, 'cell_area.csv'],areas);

hor_full = nan(size(areas));
ver_full = hor_full;
% hor_ver_ratio_full = hor_full;

for i = 1:length(seq.frames)
    geom = seq.frames(i).cellgeom;
    l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
	faces = geom.faces(l_cells, :);
    faces_for_area = faces2ffa(faces);
    [cell_L1, cell_L2, cell_angle, ~] = cell_ellipse(geom.nodes, faces_for_area);
    hor = sqrt((cell_L1 .* cosd(cell_angle)).^2 + (cell_L2 .* sind(cell_angle)).^2);
    ver = sqrt((cell_L1 .* sind(cell_angle)).^2 + (cell_L2 .* cosd(cell_angle)).^2);
%     hor_ver_ratio = log2(hor./ver);
    
    hor_full(i,data.cells.selected(i, cells)) = hor;
    ver_full(i,data.cells.selected(i, cells)) = ver;
%     hor_ver_ratio_full(i,data.cells.selected(i, cells)) = hor_ver_ratio;
end


csvwrite([meas_dir, 'cell_horizontal_length.csv'],hor_full);
csvwrite([meas_dir, 'cell_vertical_length.csv'],ver_full);




return 
%%% Stopping the outputs of segmentation file data
%%% This is more easily accessed through Matlab

save_dir_segfiles = [save_dir,filesep,'segmentation_txt_files',filesep];
mkdir(save_dir_segfiles);
nodefold = [save_dir_segfiles,filesep,'nodes',filesep];
mkdir(nodefold);
ncmfold = [save_dir_segfiles,filesep,'nodecellmap',filesep];
mkdir(ncmfold);
edgesfold = [save_dir_segfiles,filesep,'edges',filesep];
mkdir(edgesfold);
circlesfold = [save_dir_segfiles,filesep,'circles',filesep];
mkdir(circlesfold);
ecmfold = [save_dir_segfiles,filesep,'edgecellmap',filesep];
mkdir(ecmfold);
facesfold = [save_dir_segfiles,filesep,'faces',filesep];
mkdir(facesfold);
mapsfold = [save_dir_segfiles,filesep,'maps',filesep];
mkdir(mapsfold);



for i = 1:length(seq.frames)
    s = ['frame_',num2str(zeros(1,3-length(num2str(i)))),num2str(i),'_'];
    frametxt = regexprep(s,'[^\w'']','');
    csvwrite([nodefold,frametxt,'nodes.csv'],seq.frames(i).cellgeom.nodes);
    csvwrite([ncmfold,frametxt,'nodecellmap.csv'],seq.frames(i).cellgeom.nodecellmap);
    csvwrite([edgesfold,frametxt,'edges.csv'],seq.frames(i).cellgeom.edges);
    csvwrite([circlesfold,frametxt,'circles.csv'],seq.frames(i).cellgeom.circles);
    csvwrite([ecmfold,frametxt,'edgecellmap.csv'],seq.frames(i).cellgeom.edgecellmap);
    csvwrite([facesfold,frametxt,'faces.csv'],seq.frames(i).cellgeom.faces);
end
    csvwrite([mapsfold,'edges_map.csv'],full(seq.edges_map));
    csvwrite([mapsfold,'inv_edges_map.csv'],seq.inv_edges_map);
	csvwrite([mapsfold,'cells_map.csv'],seq.cells_map);
    csvwrite([mapsfold,'inv_cells_map.csv'],seq.inv_cells_map);
    
cd(indir);
write_shift_info_txt_file(pwd,save_dir);


%%% 'data' was already loaded above

save_dir_data_files = [save_dir,filesep,'basic_data_txt_files',filesep];
mkdir(save_dir_data_files);
data_cells_fold = [save_dir_data_files,filesep,'cells',filesep];
mkdir(data_cells_fold);
cells_sel_fold = [data_cells_fold,filesep,'cells_selected',filesep];
mkdir(cells_sel_fold);
cells_numsides_fold = [data_cells_fold,filesep,'cells_numsides',filesep];
mkdir(cells_numsides_fold);

data_edges_fold = [save_dir_data_files,filesep,'edges',filesep];
mkdir(data_edges_fold);
edges_sel_fold = [data_edges_fold,filesep,'edges_selected',filesep];
mkdir(edges_sel_fold);
edges_len_fold = [data_edges_fold,filesep,'edges_len',filesep];
mkdir(edges_len_fold);
edges_angle_fold = [data_edges_fold,filesep,'edges_angle',filesep];
mkdir(edges_angle_fold);

csvwrite([cells_sel_fold,'cells_selected.csv'],data.cells.selected);
csvwrite([cells_numsides_fold,'cells_numsides.csv'],data.cells.num_sides);
csvwrite([edges_sel_fold,'edges_selected.csv'],data.edges.selected);
csvwrite([edges_len_fold,'edges_len.csv'],data.edges.len);
csvwrite([edges_angle_fold,'edges_angle.csv'],data.edges.angles);


ROI_poly_fold = [save_dir_segfiles,filesep,'ROI_poly',filesep];
mkdir(ROI_poly_fold);


poly_maxsize = 0;
for i = 1:length(poly_seq)
    poly_maxsize = max([poly_maxsize,length(poly_seq(i).x)]);
end

poly_seq_xmat = nan(length(poly_seq),poly_maxsize);
poly_seq_ymat = poly_seq_xmat;
for i = 1:length(poly_seq)
    poly_seq_xmat(i,1:length(poly_seq(i).x)) = poly_seq(i).x;
    poly_seq_ymat(i,1:length(poly_seq(i).y)) = poly_seq(i).y;
end


csvwrite([ROI_poly_fold,'ROI_poly_seq_x.csv'],poly_seq_xmat);
csvwrite([ROI_poly_fold,'ROI_poly_seq_y.csv'],poly_seq_ymat);
csvwrite([ROI_poly_fold,'ROI_poly_ind.csv'],poly_frame_ind);

    
cd(indir);
write_shift_info_txt_file(pwd,save_dir);





   
    