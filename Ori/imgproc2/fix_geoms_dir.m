function fix_geoms_dir(directory)
if nargin < 1 || isempty(directory)
    directory = pwd;
end
cd(directory);
files = dir('*.mat');
for i = 1:length(files)
    [pathstr, name, ext] = fileparts(files(i).name);
    if ~length(dir([name '.tif']))
        continue
    end
    s = load(files(i).name);
    s.cellgeom = fix_geom(s.cellgeom);
    save(files(i).name, '-struct', 's');
end

