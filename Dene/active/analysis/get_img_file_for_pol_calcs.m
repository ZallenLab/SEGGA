function outfilenames = get_img_file_for_pol_calcs(options,seq,start_pol_filename)



def_options.box_size = 75;
def_options.method = [];
def_options.limit_to_embryo = false;
def_options.smoothen_nodes = false;
def_options.smoothen_edges = true;
def_options.optimize_edges_pos = true;
def_options.edge_positions_from_options = false;
def_options.const_z_shift = 0;
def_options.const_z_for_t = 0;
def_options.const_z_seg = 0;
def_options.z_shift_file = [];
def_options.z_shift_file_for_following = [];
def_options.follow_edges_along_z = false;
def_options.background.only = false;

%overlay input options on default options.
options = overlay_struct(def_options, options);




if isempty(options.z_shift_file)
    for i = 1:length(seq.frames)
        [z_num t_num] = get_file_nums(seq.frames(i).img_file);
        z_for_t(t_num) = z_num;
    end
else
    [aa bb] = textread(options.z_shift_file, '%d = %d', 'commentstyle', 'matlab');
    z_for_t(aa) = bb;
end
z_for_t = z_for_t + options.const_z_shift;
if options.const_z_for_t
    z_for_t(:) = options.const_z_for_t;
end

outfilenames = cell(size(seq.frames));
for ii = 1:length(seq.frames)
    [z_seg, t] = get_file_nums(seq.frames(ii).img_file);
    outfilenames{ii} = put_file_nums(start_pol_filename, t, z_for_t(t));
end
