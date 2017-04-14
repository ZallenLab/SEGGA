function rot_all_dlf(directory, alpha, top, bottom, left, right, flip)
if nargin < 7
    flip = false;
end
cd(directory);
files = dir('*.tif');
ind = true(1, length(files));
for i = 1:length(files)
    if isempty(strfind(files(i).name, '_T')) || isempty(strfind(files(i).name, '_Z'));
        ind(i) = 0;
    end
end
files = files(ind);
for i = 1:length(files)
    [pathstr, name, ext] = fileparts(files(i).name);
    filename = [name '.mat'];
    if length(dir(filename)) == 1
        load(filename, 'circles', 'workingarea', 'cellgeom');%, 'celldata');
        img = imread(files(i).name);
        
        if nargin < 6
            [img, cellgeom] = rot_everything_dlf(img, cellgeom, alpha);
        else
            [img, cellgeom] = rot_everything_dlf(img, cellgeom, alpha, top, bottom, left, right, flip, 0);
        end
        
        imwrite(img, files(i).name, 'tiff');    
        %save(filename, 'celldata', '-v6', '-append');
        save(filename, 'cellgeom', '-v6', '-append');
%         save(filename, 'workingarea', '-v6', '-append');
%         save(filename, 'circles', '-v6', '-append');   
    end
end

