function convert_filenames_rod2ori(base_filename, shift_t)
if nargin < 2
    h = msgbox('error');
    waitfor(h);
    return
end
files = dir([base_filename '*.tif']); 
z_for_t = [];
for i = 1:length(files)
    [pathstr, name, ext] = fileparts(files(i).name);
    [z t] = get_file_nums(name);
    if length(z_for_t) >= t && z_for_t(t) 
        z_for_t(t) = min(z_for_t(t), z);
    else
        z_for_t(t) = z;
    end
end
base_filename = name;
files = dir('convgeom*.mat');
for i = 1:length(files)
    t = sscanf(files(i).name, 'convgeom%d');
    new_filename = put_file_nums(base_filename, t + shift_t, z_for_t(t + shift_t));
    casename = [new_filename '.mat'];
    image_filename = [new_filename '.tif'];
    filenames{1} = image_filename;
    save('-append', files(i).name, 'casename', 'filenames');
    movefile(files(i).name, fullfile(pathstr, casename));
end