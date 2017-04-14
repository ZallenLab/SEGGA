function newfigH = select_filetypes_for_SEGGA_multi_charts(calling_handle)

if nargin < 1
    callinghandle_empty = true;
else
    callinghandle_empty = false;
end

newfigH = figure;
handles.vars_selected = {};
handles.selected_user = false;


set(newfigH,'Position',[20 20 400 440]);
possible_file_types = {'tif','pdf','fig','png','jpeg'};
txt_vars = possible_file_types;

handles.h_list = uicontrol('style','list','max',1000,...
     'min',1,'Position',[20 20 200 400],...
     'string',txt_vars);
 


handles.submit_btn = uicontrol('Style', 'pushbutton', 'String', 'Submit',...
        'Position', [250 20 50 20],...
        'Callback', @submit_callback); 
    

handles.cancel_btn = uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
        'Position', [340 20 50 20],...
        'Callback', 'close(newfigH)'); 
    
    

function submit_callback(varargin)
    vars_possible = (get(handles.h_list,'string'));
    inds_selected = (get(handles.h_list,'value'));
    vars_selected = {vars_possible{inds_selected}};
    selection_user = true;
    
	if callinghandle_empty
        display('vars selected');
        display(vars_selected);
    else
        vars.names = vars_selected;
        setappdata(calling_handle,'output_filetypes',vars_selected);
    end
    close(newfigH);

    
%     guidata(hObject, handles);
end

function cancel_callback(varargin)
    vars_selected = (get(handles.h_list,'string'));
    selection_user = false;
	if callinghandle_empty
        display('user canceled');
    end
    close(newfigH);    
end



end

