function prepinfo = get_analysis_prep_info(indir)

shift_info_filename = 'shift_info.mat';
timestep_filename = 'timestep.mat';
options_filename = 'tracking_options.txt';
z_shift_file = 'z_shift.txt';
cells_for_elon_file = 'cells_for_elon.mat';
cells_for_topo_file = 'cells_for_t1_ros.mat';
poly_filename = 'poly_seq.mat';
polarity_filename = 'edges_info_cell_background.mat';

prepinfo.seq = [];
prepinfo.data = [];


startdir = pwd;
if nargin <1 || isempty(indir)
    indir = pwd;
end

cd(indir);

shift_info_file_exists = ~isempty(dir(shift_info_filename));
if shift_info_file_exists
    load(shift_info_filename)
    shift_info_text_output = {['shift_info =                ',num2str(shift_info),'  (found)']};
else
    shift_info = [];
    shift_info_text_output = {['shift_info =              --- (NOT found)']};
end

timestep_file_exists = ~isempty(dir(timestep_filename));
if timestep_file_exists
    load(timestep_filename)
    timestep_text_output = {['timestep =                 ',num2str(timestep),'   (found)']};
else
    timestep = [];
    timestep_text_output = {['timestep =               --- (NOT found)']};
end

tracking_options_exists = ~isempty(dir(options_filename));
if tracking_options_exists
	[a b] = textread(options_filename, '%s = %s', 'commentstyle', 'matlab');
    for i = 1:length(b)
        eval([a{i} ' = ' b{i} ';'])
    end
    if ~exist('t_min','var')
        t_min = -inf;
    end
    if ~exist('t_max','var')
        t_max = inf;
    end
    tracking_options_text_output = {['tracking_options = [',...
        num2str(t_min),',',num2str(t_max),']    (found)']};
else
    t_min = -inf;
    t_max = +inf;
    tracking_options_text_output = {['tracking_options =   --- (NOT found)']};
end

z_shift_for_t = 0;
z_shift_exists = ~isempty(dir(z_shift_file));
if z_shift_exists    

    fid = fopen(z_shift_file);
    z_shift_output = textscan(fid, '%d = %d');
    a = z_shift_output{1};
    b = z_shift_output{2};
    z_shift_for_t(a) = b;
    fclose(fid);
    z_shift_text_output = {['z_shift =                     [',num2str(unique(z_shift_for_t(:)', 'legacy')),']  (found)']};
else
    z_shift_for_t = [];
    z_shift_text_output = {['z_shift =                  --- (NOT found)']};
end

cells_for_elon_exists = ~isempty(dir(cells_for_elon_file));
if cells_for_elon_exists
    load(cells_for_elon_file)
    cells_for_elon = cells;
    cells_for_elon_text_output = {['cells_for_elon N =      ',num2str(numel(find(cells>0))),'  (found)']};
else
    cells_for_elon = [];
    cells_for_elon_text_output = {['cells_for_elon N =   --- (NOT found)']};
end



cells_for_topo_exists = ~isempty(dir(cells_for_topo_file));
if cells_for_topo_exists
    load(cells_for_topo_file)
    cells_for_topo = cells;
    cells_for_topo_text_output = {['cells_for_t1_ros N =  ',num2str(numel(find(cells>0))),' (found)']};
else
    cells_for_topo = [];
    cells_for_topo_text_output = {['cells_for_t1_ros N = ---(NOT found)']};
end


poly_found_bool = ~isempty(dir(poly_filename));
if poly_found_bool
    poly_text_output = {['poly file = ',poly_filename,'   (found)']};
else
    poly_text_output = {['poly file =            --- (NOT found)']};
end

if poly_found_bool
    seq = load_dir(pwd);
    seq = get_mistake_cells(seq);
    untacked_cells = cells_for_chart(seq);
    data = seq2data(seq);
    
    prepinfo.seq = seq;
    prepinfo.data = data;
    errors_text_output = {[' Total Untracked Cells = ',num2str(sum(untacked_cells))]};
else
    errors_text_output = {' Total Untracked Cells = N/A'};
end

polarity_file_exists = ~isempty(dir(polarity_filename));
if polarity_file_exists
    load(polarity_filename)
    pol_edges = edges;
    pol_edges_text_output = {['pol_edges N =  ',num2str(numel(find(edges>0))),' (found)']};
else
    pol_edges = [];
    pol_edges_text_output = {[polarity_filename, ' --- (NOT found)']};
end


prepinfo.exist.shift_info = shift_info_file_exists;
prepinfo.exist.timestep = timestep_file_exists;
prepinfo.exist.options = tracking_options_exists;
prepinfo.exist.z_shift = z_shift_exists;
prepinfo.exist.cells_for_elon = cells_for_elon_exists;
prepinfo.exist.cells_for_topo = cells_for_topo_exists;
prepinfo.exist.poly_filename = poly_found_bool;
prepinfo.exist.polarity_filename = polarity_file_exists;

prepinfo.vals.shift_info = shift_info;
prepinfo.vals.timestep = timestep;
prepinfo.vals.options = [t_min,t_max];
prepinfo.vals.z_shift = [z_shift_for_t(:)];
prepinfo.vals.cells_for_elon = cells_for_elon;
prepinfo.vals.cells_for_topo = find(cells_for_topo);
prepinfo.vals.poly_filename = poly_filename;
prepinfo.vals.polarity_filename = polarity_filename;

prepinfo.text_out = {...
                    shift_info_text_output{:},...
                    timestep_text_output{:},...
                    tracking_options_text_output{:},...
                    z_shift_text_output{:},...
                    cells_for_elon_text_output{:},...
                    cells_for_topo_text_output{:},...
                    poly_text_output{:},...
                    pol_edges_text_output{:},...
                    ''...
                    };
                
    all_files_found_Bool = prepinfo.exist.shift_info && prepinfo.exist.timestep && prepinfo.exist.options &&...
                      prepinfo.exist.z_shift && prepinfo.exist.cells_for_elon && prepinfo.exist.cells_for_topo;
    if all_files_found_Bool
        essential_files_found_Bool = true;
        temptxt = {prepinfo.text_out{:},'--- ALL FILES FOUND ---'};
    else
        essential_files_found_Bool = prepinfo.exist.shift_info && prepinfo.exist.timestep  &&...
                      prepinfo.exist.cells_for_elon && prepinfo.exist.cells_for_topo;
        if essential_files_found_Bool
            temptxt = {prepinfo.text_out{:},'--- ESSENTIAL FILES FOUND ---'};   
        else
            temptxt = {prepinfo.text_out{:},'--- ESSENTIAL FILES MISSING ---'};
        end
    end
                
 prepinfo.text_out = {temptxt{:},'',errors_text_output{:}};
 prepinfo.bools.all_files_found_Bool = all_files_found_Bool;
 prepinfo.bools.essential_files_found_Bool = essential_files_found_Bool;

cd(startdir);

function cells = cells_for_chart(seq)


len = length(seq.frames);
cells = nan(len,1);
for i=1:len
    cells(i) = length(seq.frames(i).cells);
end