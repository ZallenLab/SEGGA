function convert_and_project_exp_images_dir(dir_name, dest_dir, base_filename, min_z, max_z)
%base_filename set the base file name for the destination files (new
%images)

log_filename = 'projection_method.txt';
if nargin < 1 || isempty(dir_name)
    dir_name = pwd;
end
if nargin < 2 || isempty(dest_dir)
    dest_dir = fullfile(dir_name, 'new_images');
end
%The z values to include in the projection
if nargin < 4 || isempty(min_z)
    min_z = -inf;
end
if nargin < 5 || isempty(max_z)
    max_z = inf;
end

old_dir = pwd;
cd(dir_name)
files = dir('*.TIF');
if isempty(files)
    files = dir('*.tif');
end
if ~isdir(dest_dir)
    mkdir(dest_dir);
end
for i = 1:length(files)
    [t_num, base_name] = get_t_num_from_new_file_format(files(i).name);
    if isempty(t_num)
        continue
    end
    if nargin > 2 && ~isempty(base_filename)
        base_name = base_filename;
    end
    project_and_convert_exp_image(files(i).name, dest_dir, base_name, t_num, min_z, max_z);
end

cd(dest_dir);
fid = fopen(fullfile(pwd, log_filename), 'w');
if fid == -1
    msg_string = sprintf(['There was an error opening the log file.\n'...
        'Make sure %s is not open in another application and try again.'], filename);
    h = msgbox(msg_string, '', 'warn', 'modal');
    waitfor(h)
    return
end
fprintf(fid, 'min z = %d\r\nmax_z = %d\r\nProjection method = max', min_z, max_z);
fclose(fid);

cd(old_dir)
