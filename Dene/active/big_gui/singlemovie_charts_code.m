
create_csv_files = false;

dir_str_inds = strfind(pwd,filesep);
currdir = pwd;
base_dir = currdir(1:(dir_str_inds(end-1)));
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
text_string = '';
shift_hack = 0;
% time_window = [-10 30];
time_window = [];
figsH = [];

figs_dir = [currdir,filesep,'..',filesep,container_dir,'_figs'];
if ~isdir(figs_dir)
    mkdir(figs_dir)
end




    
clear vars groups dir_names
vars = current_vars_to_plot_SEGGA;
% [vars(:).post_func] = deal(@(x)smoothen(x));

dirnames = {...
	container_dir
    };

[groups([1]).dirs] = deal([1]);
[groups(:).color] = deal([1 0 1]);
labels = dirnames;

[groups(:).label] = deal(labels{:});
savedir = [figs_dir,filesep,'basic_timeseries',filesep];
if ~isdir(savedir)
    mkdir(savedir);
end 
unifydecimals =[];
xtra_txt = [];
ylim_input = [];

h = plot_analysis_graphs_single_movie('one_fig_per_var', vars, dirnames, groups, ...
    base_dir,savedir,[],time_window,[],text_string,shift_hack,...
    unifydecimals,xtra_txt,ylim_input,create_csv_files);
% close all;

