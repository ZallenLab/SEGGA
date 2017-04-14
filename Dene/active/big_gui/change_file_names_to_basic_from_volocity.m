function change_file_names_to_basic_from_volocity(indir)

if nargin ==0 || isempty(indir)
    indir = pwd;
    display(['current dir: ',pwd]);
    qstring = 'rename files in current dir';
    titlenow = 'proceed request';
    button = questdlg(qstring,titlenow,'yes','no','yes');
    
    switch button
    case 'yes'
        display('continuing');
    case 'no'
        
        h= msgbox('choose the right dir','pick dir to change names','help'); 
        
        uiwait(h);
        indir = uigetdir(pwd,'choose dir to change names');
        if indir ==0 || isempty(indir)
            display('stopping')
            return
        end
        
        cd(indir);
        display(['current dir: ',pwd]);
        qstring = 'rename files in current dir';
        titlenow = 'proceed request';
        button = questdlg(qstring,titlenow,'yes','no','yes');
        
            switch button
            case 'yes'
                display('continuing');
            case 'no'
                display('stopping');
                return
            end
        
    end
end

filenames = dir('*.tif');
extensionname = '.tif';

if isempty(filenames)
    
    filenames = dir('*.TIF');
    extensionname = '.TIF';
    
end

if isempty(filenames)
       filenames = dir('*.TIFF');
       extensionname = '.TIFF';
end

if isempty(filenames)
       filenames = dir('*.tiff');
       extensionname = '.tiff';
end

if isempty(filenames)
    display('no tif files found in this dir');
    return
end


filenames_as_cell = {filenames(:).name};
% filenames = vertcat(filenames(:).name);
% original_filenames = filenames;


t_str_start_ind = [strfind(filenames_as_cell, 'T=')];
z_str_start_ind = [strfind(filenames_as_cell, 'Z=')];
c_str_start_ind = [strfind(filenames_as_cell, 'C=')];

if isempty([t_str_start_ind{:}]) || isempty([z_str_start_ind{:}])
    display('could not find strings we were looking for');
end

% c_ind = [strfind(filenames_as_cell, '_t')];
% 
% if isempty([c_ind{:}])
%     c_ind = [strfind(filenames_as_cell, '_T')];
% end


if any(size(t_str_start_ind) ~= size(filenames_as_cell))
    msg = ['File name format error. Could not find ''T='' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end



% c_ind = [c_ind{:}];
% filenames = filenames(:,1:c_ind+5);
% filenames = [filenames,repmat(extensionname,size(filenames,1),1)];
example_number = 1;
[dummy new_filename] = fileparts(filenames(example_number).name);
new_filename = [new_filename(1:min(10,t_str_start_ind{example_number})) '_T0000_new_Z0000.tif'];

fid = fopen('change_these_filenames.m','w');
fprintf(fid, '%% ! sudo chmod 777 -R %s \n', indir);
for i = 1:length(filenames_as_cell)
    [t basename] = get_t_num_from_new_volocity_file_format(filenames_as_cell{i});
    [z basename] = get_z_num_from_new_volocity_file_format(filenames_as_cell{i});
    dest = ['''',fullfile(indir, filesep,put_file_nums(new_filename, t, z)),''''];
    
    fprintf(fid, '!mv %s ', ['''',indir,filesep,filenames(i).name,'''']);
    fprintf(fid, '%s \n', dest);
end
fclose(fid);
rehash path;
change_these_filenames;






