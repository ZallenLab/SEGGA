
function analyze_single_image(directory,SEGGA_call) 

currdir = pwd;
dir_str_inds = strfind(pwd,filesep);
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));

min_edge_length = 8;
min_edge_length2 = 5; %clusters whose shrinking edges are never longer 
                      %than min_edge_length2 are removed.

if nargin < 1 || isempty(directory)
    directory = pwd;
end

if nargin < 2 || isempty(SEGGA_call)
    SEGGA_call = false;
end

cd(directory);
if isempty(dir('poly_seq.mat'))
    display('missing poly_seq file');
    h = warndlg('missing poly_seq file, sure is this a seg dir?');
    uiwait(h);
end
seq = load_dir(directory);

seq.t = seq.frames(1).t;
seq.z = seq.frames(1).z;
seq.img_num = seq.frames_num(seq.t, seq.z);
[seq.frames.cells] = deal([]);
[seq.frames.edges] = deal([]);
% load('analysis', 'seq')
% seq= update_seq_dir(seq);


%     seq = load_dir(pwd);
%     
for iii = 1:length(seq.frames)
    temp_geom_check = seq.frames(iii).cellgeom.edgecellmap;
    temp_geom_class = whos('temp_geom_check');
    temp_geom_class = temp_geom_class.class;
    if all(strcmp(temp_geom_class,'int')) || all(strcmp(temp_geom_class,'int16'))
        display('fixing geoms for this dir');
        fix_geoms_dir
        display('geoms fixed.');
        seq = load_dir(pwd);
    end
end

t_start = 1;
t_end = length(seq.frames);

    
load('poly_seq');
disp('data')
data = seq2data(seq);
data.edges.angles((data.edges.len(:) == 0)) = nan;
disp('misc')
time_window = [];
misc = find_clusters_by_edges_init_vars(seq, data, [], time_window, min_edge_length);

disp('vertical linkage')
v_linkage = v_linkage_over_time(seq, data, misc.all_links, 15, 0);
save('v_link', 'v_linkage');

disp('saving: ''seq'', ''data'', ''misc''');
save('analysis', 'seq', 'data', 'misc');
disp('measurements');
avrgs = seq2averages(seq, data, any(data.cells.selected));
save('avrgs', 'avrgs');
[~, full_metrics,desc] = seq2full_list_metrics(seq, data);
save('full_metrics','full_metrics');


svdir = [container_dir,'_analysis2csv'];
if ~isdir(svdir)
    mkdir(svdir);
end
all_cells_svdir = [svdir,filesep,'all_cells'];
if ~isdir(all_cells_svdir)
    mkdir(all_cells_svdir)
end
avgs_svdir = [svdir,filesep,'avgs'];
if ~isdir(avgs_svdir)
    mkdir(avgs_svdir)
end
exclusion_list = {'nm',...
                  'peri',...
                  'qVal',...
                  'circ',...
                  'int_ang'...
                  };
              
names = fieldnames(full_metrics);
for i = 1:length(names)
    f = names{i};
    if any(strcmp(f,exclusion_list))
%         display(['excluding ',f]);
        continue
    end
    pop_bool = false;
    %%% the first map changes the variable names to whatever is used for
    %%% movies if there is an appropriate analog
    [first_mapped_name, default_readable_name] =...
        SEGGA_single_image_analysis_output_names_mapping(pop_bool,f);

	if isempty(first_mapped_name)
        continue
    end
	%%% the second map changes the variable names to the end-user readable
    %%% format
    mapped_name = movie_var_name_mapping_SEGGA(first_mapped_name, default_readable_name);
    if isempty(mapped_name)
        continue
    end
    sname = [pwd,filesep,all_cells_svdir,filesep,mapped_name,'.csv'];
%     sname = [pwd,filesep,all_cells_svdir,filesep,container_dir,'-',mapped_name,'.csv'];
    csvwrite(sname,getfield(full_metrics,f));
end

avg_names = fieldnames(avrgs);

avg_exclusion_list =   {'qVal',...
                        'qVal_std_over_mean',...
                        'num_nghbrs',...
                        'num_nghbrs_std_over_mean',...
                        'areas',...
                        'peri',...
                        'peri_std_over_mean',...
                        'circ',...
                        'circ_std_over_mean',...
                        ...'nm',...
                        'nm_std_over_mean',...
                        'ecc',...
                        'ecc_std_over_mean',...
                        'length_width_ratio',...
                        'length_width_ratio_std_over_mean',...
                        'length',...
                        'length_std_over_mean',...
                        'cell_angle',...
                        'cell_angle_std_over_mean',...
                        'cell_hor',...
                        'cell_hor_std_over_mean',...
                        'cell_ver',...
                        'cell_ver_std_over_mean',...
                        'cell_hor_ver_ratio',...
                        'cell_hor_ver_ratio_std_over_mean',...
                        'int_ang',...
                        'int_ang_std_over_mean',...
                        'frac_int_ang150',...
                        'frac_int_ang150_std_over_mean'...
                  };
for i = 1:length(avg_names)
    f = avg_names{i};
    if any(strcmp(f,avg_exclusion_list))
%         display(['excluding ',f]);
        continue
    end
    pop_bool = true;
    %%% the first map changes the variable names to whatever is used for
    %%% movies if there is an appropriate analog
    [first_mapped_name, default_readable_name] =...
        SEGGA_single_image_analysis_output_names_mapping(pop_bool,f);
    %%% the second map changes the variable names to the end-user readable
    %%% format
    if isempty(first_mapped_name)
        continue
    end
    mapped_name = movie_var_name_mapping_SEGGA(first_mapped_name, default_readable_name);
    if isempty(mapped_name)
        continue
    end
    sname = [pwd,filesep,avgs_svdir,filesep,mapped_name,'.csv'];
%     sname = [pwd,filesep,avgs_svdir,filesep,container_dir,'-',mapped_name,'.csv'];
    csvwrite(sname,getfield(avrgs,f));
end

%%% Additional Avg and Aggregate Metrics
load('v_link', 'v_linkage');
clear('f');
f.name = 'v_linkage';
f.var = v_linkage*100; %fraction -> percentage;
pop_bool = true;
[first_mapped_name, default_readable_name] =...
    SEGGA_single_image_analysis_output_names_mapping(pop_bool,f.name);
% sname = [pwd,filesep,avgs_svdir,filesep,container_dir,'-',mapped_name,'.csv'];
sname = [pwd,filesep,avgs_svdir,filesep,default_readable_name,'.csv'];
csvwrite(sname,f.var);
clear('f');

%%%% Letting users refer to the documentation for descriptions.
% names = fieldnames(desc);
% desc_file = [pwd,filesep,svdir,filesep,'descriptions','.txt'];
% fileID = fopen(desc_file,'w');
% for i = 1:length(names)
%     A1 = names{i};
%     A2 = getfield(desc,A1);
%     formatSpec = '%s: %s \n';
%     fprintf(fileID,formatSpec,A1,A2);
% end   
    


measurements = odds_and_ends(data, seq, [], [], time_window);
save('measurements', 'measurements');
display('finished running analyze_single_image...');
    
    
