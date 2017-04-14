function [numDVtoAP, numAPtoDV, roi20] = rotating_edge_analysis_v03()

%%% This is just for getting edge numbers


load analysis
load shrinking_edges_info_new 
load timestep
load shift_info
% channum = 1;
if ~isempty(dir('edges_info_cell_background.mat'))
    load edges_info_cell_background
    display('''edges_info_cell_background'' found.');
else
    edges = any(data.edges.selected);
    display('''edges_info_cell_background'' NOT found, using any edge that was selected in poly');
end
    


visualize_bool = false;
len = smoothen(data.edges.len(:, edges));
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
ang = smoothen(ang);
len(~data.edges.selected(:, edges)) = nan; 

start_ap = 45;
start_dv = 45;
end_ap = 70;
end_dv = 20;

ang_params.start_ap = start_ap;
ang_params.start_dv = start_dv;
ang_params.end_ap = end_ap;
ang_params.end_dv = end_dv;




[dv_to_ap, dv_to_ap_times, ap_to_dv, ap_to_dv_times] =  rotating_edges(ang,ang_params);

numDVtoAP = length(dv_to_ap);
numAPtoDV = length(ap_to_dv);
roi20 = length(find(sum(data.edges.selected(:,edges))>20));

save('rotate_n_val_data','numDVtoAP','numAPtoDV','roi20');
save('rotating_edge_info','dv_to_ap', 'dv_to_ap_times', 'ap_to_dv', 'ap_to_dv_times');
return

% dv_to_ap = dv_to_ap(last45_going_ap>-shift_info);
% ap_to_dv = ap_to_dv(last45_going_dv>-shift_info);

% create a subset of shrinking rotating edges

shrink_inds = find(ismember(edges,edges_global_ind, 'legacy'));

if ~isempty(shrink_inds)
    extract_inds = ismember(dv_to_ap,shrink_inds, 'legacy');
    dv_to_ap_shrinks = dv_to_ap(extract_inds);
    dv_to_ap_shrinks_times = structfun(@(x) ( x(extract_inds) ), dv_to_ap_times, 'UniformOutput', false);
end

% get the shrinking edges that ever were dv
[dv_to_shrinks, dv_to_shrinks_times] =  rotating_shrinks(ang,shrink_inds,shrink_times,timestep);




% % % % prep save_dir

tempsavedir_start = uigetdir();
[short_dir long_dir] = strtok(fliplr(pwd),filesep);
[spec_dir long_dir] = strtok(long_dir,filesep);
spec_dir = fliplr(spec_dir);
[group_dir long_dir] = strtok(long_dir,filesep);
group_dir = fliplr(group_dir);
tempsavedir = [tempsavedir_start,filesep,group_dir,filesep,spec_dir,filesep];
if ~isdir(tempsavedir)
    mkdir(tempsavedir)
end
display(['saving rotating edge info in: ',tempsavedir]);

save_dir = [tempsavedir,filesep];
if ~isdir(save_dir)
    mkdir(save_dir)
end

if visualize_bool

    savename = 'dv-to-ap';
    extratxt = 'align: vertical';
    visualize_rotating_edge_data(ang,len,channel_info,dv_to_ap,dv_to_ap_times,timestep,save_dir,savename,extratxt)
    visualize_rotating_edge_data_bestfit(ang,len,channel_info,dv_to_ap,dv_to_ap_times,timestep,save_dir,savename,extratxt)

    % savename = 'dv-to-ap--shrinks';
    % extratxt = 'align: vertical';
    % visualize_rotating_edge_data(ang,len,channel_info,dv_to_ap_shrinks,dv_to_ap_shrinks_times,timestep,save_dir,savename,extratxt)
    % 
    % savename = 'dv-to--shrinks';
    % extratxt = 'align: shrink';
    % visualize_rotating_edge_data(ang,len,channel_info,dv_to_shrinks,dv_to_shrinks_times,timestep,save_dir,savename,extratxt)
    % 
    % savename = 'ap-to-dv';
    % extratxt = 'align: dv';
    % visualize_rotating_edge_data(ang,len,channel_info,ap_to_dv,ap_to_dv_times,timestep,save_dir,savename,extratxt)
end




return 
fid = fopen([save_dir,filesep,'rotating_edge_nums.txt'],'w+');
temp_str_ap_to_dv = ['num ap (>',num2str(start_ap),') to dv (<',num2str(end_dv),') edges: ',num2str(length(ap_to_dv)),';'];
fwrite(fid,temp_str_ap_to_dv);
fprintf(fid,'\n');
temp_str_dv_to_ap = ['num dv (<',num2str(start_dv),') to ap (>',num2str(end_ap),') edges: ',num2str(length(dv_to_ap)),';'];
fwrite(fid,temp_str_dv_to_ap);
fprintf(fid,'\n');
temp_str_num_edges = ['num edges in ROI > 20 frames: ',num2str(roi20),';'];
fwrite(fid,temp_str_num_edges);
fprintf(fid,'\n');


temp_str_num_cells = ['num cells in ROI > 20 frames: ',num2str(length(find(sum(data.cells.selected)>20))),';'];
fwrite(fid,temp_str_num_cells);
fprintf(fid,'\n');


temp_str_num_vert_edges = ['num vert edges in ROI and vert > 10 frames: ',num2str(length(find(sum(ang>70)>10))),';'];
fwrite(fid,temp_str_num_vert_edges);
fprintf(fid,'\n');
fclose(fid);
% for viewing edges in browser and in movie in "commandsui"
% visualize_edges(pwd,dv_to_ap);

fid = fopen([save_dir,filesep,'rotating_edge_nums.txt'],'w+');
fwrite(fid,temp_str_ap_to_dv);
fprintf(fid,'\n');
fwrite(fid,temp_str_dv_to_ap);
fprintf(fid,'\n');
fwrite(fid,temp_str_num_edges);
fprintf(fid,'\n');
fwrite(fid,temp_str_num_cells);
fprintf(fid,'\n');
fwrite(fid,temp_str_num_vert_edges);
fprintf(fid,'\n');
fclose(fid);


