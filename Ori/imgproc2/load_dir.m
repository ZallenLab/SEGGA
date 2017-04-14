function image_sequence = load_dir(directory)
cd(directory);
options_file = 'tracking_options.txt';
image_file_list = 'batch_image_list.txt';
z_shift_file = 'z_shift.txt';
bnr_dir = 'bnr';
%%% default options values
t_min = 1; t_max = 1000; z_min = -20; z_max = 100; ignore_z = 0;
shift_z = 1; z_jump = 1; t_jump = 1; 
z_shift_for_t = 0;
size_scale = 1;
channel1 = []; channel2 = []; channel3 = [];
if length(dir(fullfile(directory, options_file)))
    [a b] = textread(options_file, '%s = %s', 'commentstyle', 'matlab');
    for i = 1:length(b)
        eval([a{i} ' = ' b{i} ';'])
    end  
end
if shift_z & length(dir(fullfile(directory, z_shift_file)))
    
%     DLF EDIT updating code here:
    fid = fopen(z_shift_file);
    z_shift_output = textscan(fid, '%d = %d');
    a = z_shift_output{1};
    b = z_shift_output{2};
    z_shift_for_t(a) = b;
    fclose(fid);
    
%     [a b] = textread(z_shift_file, '%d = %d', 'commentstyle', 'matlab');
%     z_shift_for_t(a) = b;


end
if ignore_z & length(dir(fullfile(directory, image_file_list)))
    fid = fopen(image_file_list, 'r');
    cnt = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline),   break,   end
        [pathstr, name, ext] = fileparts(tline);
        files(cnt).name = [name '.mat'];
        cnt = cnt +1;
    end
    fclose(fid);
else
    files = dir('*.mat');
end
ind = false(1, length(files));
z_for_sorting = zeros(size(ind));
t_for_sorting = z_for_sorting;
valid_z_vals = z_min : z_jump : z_max;
valid_t_vals = t_min : t_jump : t_max;
for i = 1:length(files)
    [pathstr, name, ext] = fileparts(files(i).name);
    temp_file = dir([name '.tif']);
    if length(temp_file) == 1
        [z t] = get_file_nums(name);
        if any(z_shift_for_t)
            try
                z = z - z_shift_for_t(t);
            catch
                display('failed at ''z = z - z_shift_for_t(t)'';');
                display(['z_shift_for_t:', num2str(z_shift_for_t)]);
                display(['length(z_shift_for_t):', num2str(length(z_shift_for_t))]);
                display(['t: ',num2str(t)]);
                display(['name: ',name]);                
            end
        end
        if ismember(t, valid_t_vals, 'legacy') && ismember(z, valid_z_vals, 'legacy') %t_min <= t && t <= t_max && z_min <= z && z <= z_max
            ind(i) = 1;
        end
        z_for_sorting(i) = z;
        t_for_sorting(i) = t;
    end
end
files = files(ind);
z_for_sorting = z_for_sorting(ind);
t_for_sorting = t_for_sorting(ind);

%sort files by t and then z
[dummy sorted_ind] = sortrows([t_for_sorting' z_for_sorting'], [1 2]);
files = files(sorted_ind);

frames = [];
if isempty(files)
    cmd_w_str = 'no segmentation files found... quitting';
    cprintf('*[1,0.5,0]',[cmd_w_str,'\n']);
    image_sequence = [];
    ST = dbstack;
    display(ST(1));
    return
end
%h = waitbar(1./length(files), 'Please wait...', 'WindowStyle', 'Modal');
h = waitbar(0, 'Reading files... ', 'WindowStyle', 'Modal');
t_start = clock;
frames = load_frame(files(1).name, frames, 1, ignore_z, z_shift_for_t);

frames_num(frames(1).t, frames(1).z) = 1;
frames(1:length(files)) = frames;
for i = 2:length(files)
    frames = load_frame(files(i).name, frames, i, ignore_z, z_shift_for_t);
    frames_num(frames(i).t, frames(i).z) = i;
    t_elapsed = etime(clock, t_start);
    t_remain = t_elapsed * ((1 + length(files) - i) / i);
%     h = waitbar(i./length(files), h, sprintf(...
%         'Reading files...   Time elapsed: %3.1f seconds\n Time remaining: %3.1f seconds', t_elapsed, t_remain));
end
t_end = etime(clock, t_start);
%close(h);

for t = min([frames(:).t]) : max([frames(:).t] - t_jump)
    for z = min([frames(:).z]) : max([frames(:).z])
        if frames_num(t,z) && frames_num(t + t_jump,z)
            frames(frames_num(t,z)).next_frame = frames_num(t + t_jump, z);
            frames(frames_num(t + t_jump,z)).prev_frame = frames_num(t, z);
        elseif frames_num(t,z)
            frames(frames_num(t,z)).next_frame = [];
        elseif frames_num(t + t_jump,z)
            frames(frames_num(t + t_jump,z)).prev_frame = [];
        end
    end
end
for t = min([frames(:).t]) : max([frames(:).t])
    for z = min([frames(:).z]) : max([frames(:).z] - z_jump)
        if frames_num(t,z) && frames_num(t,z + z_jump)
            frames(frames_num(t,z)).up_frame = frames_num(t, z + z_jump);
            frames(frames_num(t, z + z_jump)).down_frame = frames_num(t, z);
        elseif frames_num(t,z)
            frames(frames_num(t,z)).up_frame = [];
        elseif frames_num(t,z + z_jump)
            frames(frames_num(t,z + z_jump)).down_frame = [];
        end
    end
end

% 
% [dummy ind] = sortrows([frames.t ; frames.z]');
% 
% for i = 1:length(ind) - 1
%     frames(ind(i)).next_frame = ind(i+1);
%     frames(ind(i+1)).prev_frame = ind(i);
% end
% frames(ind(end)).next_frame = ind(1);
% frames(ind(1)).prev_frame = ind(end);

% next_frame = [frames.next_frame];
% orbit = zeros(1,length(next_frame));
% orbit(1) = ind(1);
% for i = 2:length(next_frame)
%     orbit(i) = next_frame(orbit(i-1));
% end


image_sequence.directory = directory;
image_sequence.changed = 0;
image_sequence.frames = frames;
image_sequence.min_t = min(nonzeros([frames(:).t]));
image_sequence.max_t = max(nonzeros([frames(:).t]));
image_sequence.min_z = min(nonzeros([frames(:).z]));
image_sequence.max_z = max(nonzeros([frames(:).z]));
image_sequence.frames_num = frames_num;
image_sequence.orbit = frames_num(:, image_sequence.min_z);
image_sequence.valid_z_vals = unique(nonzeros([frames(:).z]), 'legacy');
image_sequence.valid_t_vals = unique(nonzeros([frames(:).t]), 'legacy');
image_sequence.t_jump = t_jump;
image_sequence.bnr_dir = bnr_dir;
image_sequence.channel1 = channel1; 
image_sequence.channel2 = channel2;
image_sequence.channel3 = channel3;

h = waitbar(3/8, h, 'Tracking cells... ');
if image_sequence.min_z == image_sequence.max_z 
    [image_sequence.inv_cells_map image_sequence.cells_map] = track_movie_no_z(image_sequence, size_scale);
else
    [image_sequence.inv_cells_map image_sequence.cells_map] = track_movie(image_sequence);
end

h = waitbar(9/10, h, 'Tracking edges... ');
[image_sequence.inv_edges_map image_sequence.edges_map] = track_edges(image_sequence);

% h = waitbar(9/10, h, 'Tracking clusters... ');
% frames = track_clusters(frames);


h = waitbar(1, h, 'Done.');


close(h)
function frames = load_frame(filename, frames, i, ignore_z, z_shift_for_t)
temp_vars = load(filename, 'filenames', 'cellgeom');
frames(i).filename = filename;
frames(i).img_file = temp_vars.filenames{1};
frames(i).cellgeom = temp_vars.cellgeom;
frames(i).cellgeom_edit = temp_vars.cellgeom;
%frames(i).celldata = temp_vars.celldata;
%frames(i).celldata = cell2struct({temp_vars.celldata.nodes}, 'nodes', 1);

%create a polygon within the interior of each cell.
%this is slow, skip for now. add as an option later on

% for j = 1:length(frames(i).celldata)
%     if ~isempty(frames(i).celldata(j).nodes)
%         frames(i).celldata(j).nodes_inside = frames(i).celldata(j).nodes;
%         frames(i).celldata(j).nodes_inside(:,1) = (frames(i).celldata(j).nodes(:,1) + ...
%             frames(i).cellgeom.circles(j,1))/2;
%         frames(i).celldata(j).nodes_inside(:,2) = (frames(i).celldata(j).nodes(:,2) + ...
%             frames(i).cellgeom.circles(j,2))/2;
%     end
% end


frames(i).saved = false;
frames(i).changed = false;
frames(i).sticky_changed = false;
[frames(i).z frames(i).t] = get_file_nums(filename);

if ignore_z
    frames(i).z = 1;
end
if any(z_shift_for_t)
    frames(i).z = frames(i).z - z_shift_for_t(frames(i).t);
end


