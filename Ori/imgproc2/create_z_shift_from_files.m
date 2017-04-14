function z_for_t_out = create_z_shift_from_files(method, readonly)

if nargin < 2
    readonly = true;
end
if nargin < 1 || ~strcmp(method, 'tif')
    %based on mat files.

    files = dir('*.mat');
    z_for_t = [];
    for i = 1:length(files)
        [pathstr, name, ext] = fileparts(files(i).name);
        temp_file = dir([name '.tif']);
        if length(temp_file) == 1
            [z t] = get_file_nums(name);
            if length(z_for_t) >= t && z_for_t(t) 
                z_for_t(t) = min(z_for_t(t), z);
            else
                z_for_t(t) = z;
            end
        end
    end
else
    %based on tif files.
    files = dir('*.tif'); 
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
end

min_t = find(z_for_t, 1);
z_for_t = z_for_t - z_for_t(min_t);
if nargout > 0
    z_for_t_out = z_for_t;
end

if ~readonly
    z_shift_file = 'z_shift.txt';
    fid = fopen(fullfile(pwd, z_shift_file), 'w');
    if fid == -1
        msg_string = sprintf(['There was an error opening the file. '...
            'Make sure %s is not open in another application and try again.'], z_shift_file);
        h = msgbox(msg_string, 'I''m running out of witty things to say', 'warn', 'modal');
        waitfor(h)
        return
    end
    for t = min_t:length(z_for_t)
        fprintf(fid, '%d = %d\r\n', t, z_for_t(t));
    end
    fclose(fid);
end




