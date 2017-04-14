load analysis seq data
load edges_info_cell_background edges channel_info
load timestep
load shift_info
bins = [];

len = smoothen(data.edges.len(:, edges));
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
ang = smoothen(ang);
len(~data.edges.selected(:, edges)) = nan; 

h = bin_by_angles_func(seq, data, ang, channel_info, edges, bins, ...
    timestep, shift_info);

currdir = pwd;
figs_dir = [currdir,filesep,'..',filesep,'figs'];
if ~isdir(figs_dir)
    mkdir(figs_dir)
end

savedir = [figs_dir,filesep,'polarity',filesep];
if ~isdir(savedir)
    mkdir(savedir);
end 

for p = 1:length(h)
    	bname = [savedir, channel_info(p).name,'-binned-by-angle'];
        saveas(h(p), [bname '.fig']);
        saveas(h(p), [bname '.pdf']);
        saveas(h(p), [bname '.tif']);
end

% projection_type = 'test-proj';
% dir_name = 'test-dir';
% [h1_sqh_raw h2_baz_raw h3_sqh_raw time_points] = projection_type,dir_name(seq,data,edges,ang,len,...
%     channel_info(1).levels,channel_info(2).levels,...
%     channel_info(1).background,channel_info(2).background,...
%     shift_info,timestep,projection_type,dir_name);