function load_channel_tracking(handles, ch, filename, pathname)
ctrl = handles.(['channel' num2str(ch)]);
set(ctrl, 'value', true);
set(ctrl, 'enable', 'on');
setappdata(handles.figure1, ['dir_channel' num2str(ch)], pathname);
setappdata(handles.figure1, ['filename_channel' num2str(ch)], filename);

[ch_z_val, ch_t_val] = get_file_nums(filename);
setappdata(handles.figure1, ['z_channel' num2str(ch)], ch_z_val);

if isfield(handles, ['z_shift_ch' num2str(ch)])
    set(handles.(['z_shift_ch' num2str(ch)]), 'enable', 'on')
end
if isfield(handles, ['wt_ch' num2str(ch)])
    set(handles.(['wt_ch' num2str(ch)]), 'enable', 'on')
end


settings_file = getappdata(handles.figure1, 'channel_settings_filename');
if length(dir(fullfile(pathname, settings_file)))
    brightness_factor = getappdata(handles.figure1, ...
        ['channel' num2str(ch) '_factor']);
    shift_factor = getappdata(handles.figure1, ...
        ['channel' num2str(ch) '_shift_factor']);

    
    [a b] = textread(fullfile(pathname, settings_file), ...
                     '%s = %s', 'commentstyle', 'matlab');
    for i = 1:length(b)
        eval([a{i} ' = ' b{i} ';'])
    end
    setappdata(handles.figure1, ['channel' num2str(ch) '_factor'], ...
        brightness_factor);
    setappdata(handles.figure1, ['channel' num2str(ch) '_shift_factor'], ...
        shift_factor);
end
