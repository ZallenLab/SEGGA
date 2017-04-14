 function SEGGA_node_res_single_dir(savedir)

% the use of 'all_dirs_separated'
% which gives full paths for each directory 
% makes it possible to use any set of directories,
% not just some set under the same path base dir

dir_str_inds = strfind(pwd,filesep);
currdir = pwd;
% base_dir = currdir(1:(dir_str_inds(end-1)));
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));


if (nargin < 1) || isempty(savedir)
    figs_dir = [pwd,filesep,'..',filesep,container_dir,'_figs'];
    savedir = [figs_dir,filesep,'node_res',filesep];
end
if ~isdir(savedir)
    mkdir(savedir);
end
if ~isdir(savedir)
    errordlg('could not create save dir');
    return
end


start_dir = pwd;

if isempty(dir('node_res_data.mat'))
   display('running ''node_analysis_script_alignment''');
   node_analysis_script_alignment
end
load('node_res_data')
%res_time;
%all_possible;
%unresolved_dead_finals;
%unresolved_time_existed;
%ind_aligned;
%ind_ros;
%ind_clusters;
%res_means;

if any(res_time<0)
    display('something wrong!')
end


all_res_h = figure;
% scatter(res_time);
hold on
plot(rand(1,length(res_time))*2+1,res_time,...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 0 1],...
        'MarkerSize',4);

% t1_res_h = figure;
% scatter(res_time(~ind_ros));
t1_res_times = res_time(~ind_ros);
plot(rand(1,length(res_time(~ind_ros)))*2+4,res_time(~ind_ros),...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[1 0 1],...
        'MarkerSize',4);

% ros_res_h = figure;
% scatter(res_time(ind_ros));
ros_res_times = res_time(logical(ind_ros));
plot(rand(1,length(res_time(logical(ind_ros))))*2+7,res_time(logical(ind_ros)),...
        'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 1 1],...
        'MarkerSize',4);
    
set(gca,'XTick',[2,5,8])
set(gca,'XTickLabel',{'All','T1s','Ros'})
pos = [680   408   1200   684];
set(gcf, 'position', pos);
fix_2016a_figure_output(gcf);
title('Node Resolution Times')
ylabel('Minutes');
saveas(gcf,[savedir,filesep,container_dir,'_noderes','.pdf']);

return
csvwrite([savedir,filesep,'all_res_times.csv'],res_time');
csvwrite([savedir,filesep,'t1_res_times.csv'],t1_res_times');
csvwrite([savedir,filesep,'ros_res_times.csv'],ros_res_times');



