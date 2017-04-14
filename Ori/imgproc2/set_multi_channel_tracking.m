function set_multi_channel_tracking(handles, multi)
if multi 
%     setappdata(handles.figure1, 'channel1', true);
    setappdata(handles.figure1, 'multi_channel', true)
    set(handles.multi_channel_menu, 'enable', 'on')
    set(handles.multi_channel_menu, 'checked', 'on')
    set(handles.channel1, 'visible', 'on')
    set(handles.channel2, 'visible', 'on')
    set(handles.channel3, 'visible', 'on')
    set(handles.chan2gray_btn, 'visible', 'on','value',false)
    if ~isappdata(handles.figure1, 'channel1_factor')
        setappdata(handles.figure1, 'channel1_factor', 1)
        setappdata(handles.figure1, 'channel1_shift_factor', 0)        
    end
    if ~isappdata(handles.figure1, 'channel2_factor')
        setappdata(handles.figure1, 'channel2_factor', 1)
        setappdata(handles.figure1, 'channel2_shift_factor', 0)        
    end
    if ~isappdata(handles.figure1, 'channel3_factor')
        setappdata(handles.figure1, 'channel3_factor', 1)
        setappdata(handles.figure1, 'channel3_shift_factor', 0)        
    end
else
    setappdata(handles.figure1, 'multi_channel', false)
    set(handles.multi_channel_menu, 'checked', 'off')
    set(handles.channel1, 'visible', 'off')
    set(handles.channel2, 'visible', 'off')
    set(handles.channel3, 'visible', 'off')
    if isfield(handles,'chan2gray_btn')
        set(handles.chan2gray_btn, 'visible', 'off','value',false);
    end
    
end