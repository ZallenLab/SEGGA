function new_dir = relative_dir(source_dir, dest_dir)
source_dir = make_dir_name_platform_compatible(source_dir);
dest_dir = make_dir_name_platform_compatible(dest_dir);
old_dir = pwd;
if ~isdir(source_dir)
    new_dir = '';
    cd(old_dir)
    error('The directory %s does not exist', source_dir);
    return
end
cd(source_dir);
if ~isdir(dest_dir)
    new_dir = pwd;
    cd(old_dir)
    error('The directory %s does not exist under %s', dest_dir, new_dir);
    return
end
cd(dest_dir);
new_dir = pwd;
cd(old_dir)

function directory = make_dir_name_platform_compatible(directory)
f = filesep;
directory = strrep(directory, '/', f);
directory = strrep(directory, '\', f);