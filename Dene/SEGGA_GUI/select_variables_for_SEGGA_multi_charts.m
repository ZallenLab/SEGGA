function newfigH = select_variables_for_SEGGA_multi_charts(calling_handle)

if nargin < 1
    callinghandle_empty = true;
else
    callinghandle_empty = false;
end

possible_var_types = {'time_series_normal','bar_chart','polarity','rotation'};
vars_type_ind = 1;
newfigH = figure;
handles = guihandles(newfigH); 
handles.figure1 = newfigH;
handles.vars_selected = {};
handles.selected_user = false;
guidata(newfigH,handles);
setappdata(handles.figure1,'possible_var_types',possible_var_types);
setappdata(handles.figure1,'vars_type_ind',vars_type_ind);


set(newfigH,'Position',[20 20 400 440]);
[txt_vars,display_names] = give_possible_variables_to_SEGGA_basic;
if ~callinghandle_empty
    setappdata(calling_handle,'txt_vars',txt_vars);
end

handles.h_list = uicontrol('style','list','max',1000,...
     'min',1,'Position',[20 20 200 400],...
     'string',display_names);
 
handles.load_basic_btn = uicontrol('Style', 'pushbutton', 'String', 'Basic',...
        'Position', [250 350 50 20],...
        'Callback', @load_basic_callback);
    
%%% CONTRIBS ANALYSIS IN DEVELOPMENT   
% handles.load_contribs_btn = uicontrol('Style', 'pushbutton', 'String', 'Contribs',...
%         'Position', [320 350 50 20],...
%         'Callback', @load_contribs_callback);
    
handles.load_shrink_btn = uicontrol('Style', 'pushbutton', 'String', 'Shrinks',...
        'Position', [250 310 50 20],...
        'Callback', @load_shrink_callback);
    
handles.load_barchart_btn = uicontrol('Style', 'pushbutton', 'String', 'Bar Charts',...
        'Position', [250 270 50 20],...
        'Callback', @load_barchartvars_callback);
    
%%% 'EXTRAS' VARIABLES IN DEVELOPMENT
%     handles.load_extras_btn = uicontrol('Style', 'pushbutton', 'String', 'Extras',...
%         'Position', [250 230 50 20],...
%         'Callback', @load_extras_callback);
    
handles.load_polarity_btn = uicontrol('Style', 'pushbutton', 'String', 'Polarity',...
        'Position', [250 190 50 20],...
        'Callback', @load_polarity_callback);
    
handles.load_polarity_chan_based_btn = uicontrol('Style', 'pushbutton', 'String', 'Pol. by Chans',...
        'Position', [320 190 70 20],...
        'Callback', @load_polarity_chan_based_callback);
    
handles.load_rotation_btn = uicontrol('Style', 'pushbutton', 'String', 'Rotating Edges',...
        'Position', [250 140 50 20],...
        'Callback', @load_rotation_callback,...
        'visible','off');

handles.submit_btn = uicontrol('Style', 'pushbutton', 'String', 'Submit',...
        'Position', [250 20 50 20],...
        'Callback', @submit_callback); 
    

handles.cancel_btn = uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
        'Position', [340 20 50 20],...
        'Callback', @cancel_callback); 
    
    
    
function load_basic_callback(varargin)
    [txt_vars,display_names] = give_possible_variables_to_SEGGA_basic;
    set(handles.h_list,'string',display_names);
    setappdata(calling_handle,'txt_vars',txt_vars);
    vars_type_ind = 1; %normal
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);    
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end


function load_contribs_callback(varargin)
    [txt_vars,display_names] = give_possible_variables_to_SEGGA_contribs;
    set(handles.h_list,'string',display_names);
    setappdata(calling_handle,'txt_vars',txt_vars);
    vars_type_ind = 1; %normal
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);    
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end

function load_shrink_callback(varargin)
	[txt_vars,display_names] = give_possible_variables_to_SEGGA_shrink;
    set(handles.h_list,'string',display_names);
    vars_type_ind = 1; %normal
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end

function load_barchartvars_callback(varargin)
	[txt_vars,display_names] = give_possible_variables_to_SEGGA_barchartvars;
    set(handles.h_list,'string',display_names);
    vars_type_ind = 2; %bar chart type
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end

function load_extras_callback(varargin)
	[txt_vars,display_names] = give_possible_variables_to_SEGGA_extras;
    set(handles.h_list,'string',display_names);
    vars_type_ind = 1; %normal
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end

function load_polarity_callback(varargin)
	[txt_vars,display_names] = give_possible_variables_to_SEGGA_polarity;
    set(handles.h_list,'string',display_names);
    vars_type_ind = 3; %polarity
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end

function load_polarity_chan_based_callback(varargin)
	[txt_vars,display_names] = give_possible_variables_to_SEGGA_polarity_by_chan_num;
    set(handles.h_list,'string',display_names);
    vars_type_ind = 1; %normal
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end



function load_rotation_callback(varargin)
	[txt_vars,display_names] = give_possible_variables_to_SEGGA_rotation;
    set(handles.h_list,'string',display_names);
    vars_type_ind = 4; %rotation
    setappdata(handles.figure1,'vars_type_ind',vars_type_ind);
    if ~callinghandle_empty
        setappdata(calling_handle,'txt_vars',txt_vars);
    end
end

    
function submit_callback(varargin)
%     vars_possible = (get(handles.h_list,'string'));
    vars_possible = getappdata(calling_handle,'txt_vars');
    inds_selected = (get(handles.h_list,'value'));
    vars_selected = {vars_possible{inds_selected}};
    selection_user = true;
    
    possible_var_types = getappdata(handles.figure1,'possible_var_types');
    vars_type_ind = getappdata(handles.figure1,'vars_type_ind');
    
	if callinghandle_empty
        display('vars selected');
        display(vars_selected);
    else
        vars.names = vars_selected;
        setappdata(calling_handle,'vars_to_plot',vars.names);
        setappdata(calling_handle,'vars_type',possible_var_types{vars_type_ind});
        setappdata(calling_handle,'possible_var_types',possible_var_types);
        setappdata(calling_handle,'vars_type_ind',vars_type_ind);
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
    close(handles.figure1);
%     close(newfigH);    
end



end

