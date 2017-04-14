function convert_exp_images_dir_dlf(dir_name, dest_dir, base_filename, min_z)
%base_filename set the base file name for the destination files (new
%images)

if nargin < 1 || isempty(dir_name)
    dir_name = pwd;
end
if nargin < 2 || isempty(dest_dir)
    dest_dir = fullfile(dir_name, 'new_images');
end
%The z value for the new filenames start at min_z
if nargin < 4 || isempty(min_z)
    min_z = 1;
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
    [t_num base_name] = get_t_num_from_new_file_format(files(i).name);
    if isempty(t_num)
        continue
    end
    if nargin > 2 && ~isempty(base_filename)
        base_name = base_filename;
    end
    convert_exported_image(files(i).name, dest_dir, base_name, t_num, min_z);
end
cd(old_dir)