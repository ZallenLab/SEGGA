function varargout = see_data(varargin)
% SEE_DATA M-file for see_data.fig
%      SEE_DATA, by itself, creates a new SEE_DATA or raises the existing
%      singleton*.
%
%      H = SEE_DATA returns the handle to a new SEE_DATA or the handle to
%      the existing singleton*.
%
%      SEE_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEE_DATA.M with the given input arguments.
%
%      SEE_DATA('Property','Value',...) creates a new SEE_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before see_data_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to see_data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help see_data

% Last Modified by GUIDE v2.5 03-Dec-2006 00:15:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @see_data_OpeningFcn, ...
                   'gui_OutputFcn',  @see_data_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before see_data is made visible.
function see_data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to see_data (see VARARGIN)

edges_tags =        {'Length', 'Angle', 'Length_Velocity', 'Angular_Velocity'};
edges_field_names = {'len',    'ang',   'len_vel',         'ang_vel'};
cells_tags = {'Area', 'Sides', 'Roundness'};

tag = lower(['edges_' edges_tags{1} '_check']);
han = getfield(handles, tag);
pos = get(han, 'position');
cal = get(han, 'callback');
unt = get(han, 'units');
set(han, 'UserData', 1);
for i = 2:length(edges_tags)
    tag = lower(['edges_' edges_tags{i} '_check']);
    str = edges_tags{i};
    str = strrep(str, '_', ' ');
    pos(2) = pos(2) - (pos(4)*1.5);
    han(i) = uicontrol('style', 'checkbox', 'tag', tag, 'string', str, ...
        'units', unt, 'Callback', cal, 'parent', handles.figure1, ...
        'position', pos, 'UserData', i);
end
setappdata(handles.figure1, 'edges_field_names', edges_field_names);
setappdata(handles.figure1, 'edges_field_on', false(length(edges_tags), 1));

tag = lower(['cells_' cells_tags{1} '_check']);
han = getfield(handles, tag);
pos = get(han, 'position');
cal = get(han, 'callback');
unt = get(han, 'units');
for i = 2:length(cells_tags)
    tag = lower(['cells_' cells_tags{i} '_check']);
    str = cells_tags{i};
    str = strrep(str, '_', ' ');
    pos(2) = pos(2) - (pos(4)*1.5);
    han(i) = uicontrol('style', 'checkbox', 'tag', tag, 'string', str, ...
        'units', unt, 'Callback', cal, 'parent', handles.figure1, 'position', pos);
end
handles = guihandles(hObject);
handles.output = hObject;
guidata(hObject, handles);        
setappdata(handles.figure1, 'edges_tags', lower(edges_tags));
setappdata(handles.figure1, 'cells_tags', lower(cells_tags));

% --- Outputs from this function are returned to the command line.
function varargout = see_data_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(hObject, 'Value', round(get(hObject,'Value')));
sd_update_frame(handles, get(hObject,'Value'), 1);


% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function frame_number_Callback(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_number as text
%        str2double(get(hObject,'String')) returns contents of frame_number as a double


% --- Executes during object creation, after setting all properties.
function frame_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in play_backward.
function play_backward_Callback(hObject, eventdata, handles)
% hObject    handle to play_backward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(hObject, 'value')
    return
end
set(handles.play_forward, 'value', 0);
i = str2double(get(handles.frame_number, 'String'));
while get(hObject, 'value')
    i = str2double(get(handles.frame_number, 'String'));
    i = i - 1;
    if i < get(handles.frame_slider, 'min')
        i = get(handles.frame_slider, 'max');
    end
    %z = str2double(get(handles.slice_number, 'String'));
    sd_update_frame(handles, i, 1)
    if ~ishandle(hObject)
        break
    end
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in edges_length_check.
function edges_check_Callback(hObject, eventdata, handles)
% hObject    handle to edges_length_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edges_length_check


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on slider movement.
function edges_slider_Callback(hObject, eventdata, handles)
% hObject    handle to edges_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

setappdata(handles.figure1, 'edges', round(get(hObject,'Value')))
draw_edges_plot(handles)

i = str2double(get(handles.frame_number, 'String'));
%z = str2double(get(handles.slice_number, 'String'));
z = 1;
sd_update_frame(handles, i, z)
    
function draw_edges_plot(handles)
edges_data = getappdata(handles.figure1, 'edges_data');
field_names = getappdata(handles.figure1, 'edges_field_names');
field_on = getappdata(handles.figure1, 'edges_field_on');
edges = getappdata(handles.figure1, 'edges');
data = [];
for i = 1:length(field_names)
    if field_on(i)
        data = [data getfield(edges_data, field_names{i}, {':', edges})];
    end
end
if ~isempty(data)
    plot(handles.edges_axes, data);
end

% --- Executes during object creation, after setting all properties.
function edges_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edges_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12



% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on slider movement.
function cells_slider_Callback(hObject, eventdata, handles)
% hObject    handle to cells_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function cells_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cells_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in cells_area_check.
function cells_check_Callback(hObject, eventdata, handles)
% hObject    handle to cells_area_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cells_area_check




% --- Executes on button press in all_edges.
function all_edges_Callback(hObject, eventdata, handles)
% hObject    handle to all_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_edges

if ~get(hObject,'Value')
    set(handles.edges_slider, 'Enable', 'on');
    return
end
set(handles.edges_slider, 'Enable', 'off');
setappdata(handles.figure1, 'edges', 1:get(handles.edges_slider, 'max'));
draw_edges_plot(handles)
i = str2double(get(handles.frame_number, 'String'));
%z = str2double(get(handles.slice_number, 'String'));
z = 1;
sd_update_frame(handles, i, z)

% --- Executes on button press in all_cells.
function all_cells_Callback(hObject, eventdata, handles)
% hObject    handle to all_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_cells




% --- Executes on button press in play_forward.
function play_forward_Callback(hObject, eventdata, handles)
% hObject    handle to play_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play_forward

if ~get(hObject, 'value')
    return
end
set(handles.play_backward, 'value', 0);
i = str2double(get(handles.frame_number, 'String'));
while get(hObject, 'value')
    i = str2double(get(handles.frame_number, 'String'));
    i = i + 1;
    if i > get(handles.frame_slider, 'max')
        i = get(handles.frame_slider, 'min');
    end

    %z = str2double(get(handles.slice_number, 'String'));
    z = 1;
    sd_update_frame(handles, i, z)
    if ~ishandle(hObject)
        break
    end
end



% --- Executes on mouse press over axes background.
function image_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to image_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in select_btn.
function select_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seq
edges_data = getappdata(handles.figure1, 'edges_data');
for i = 1:length(edges_data.len_vel(:, 1))
    shrinking = edges_data.len_vel(i, :) < 0; 
    seq.frames(i).edges = seq.frames(i).edges(shrinking);
end



% --- Executes on button press in edges_length_check.
function edges_length_check_Callback(hObject, eventdata, handles)
% hObject    handle to edges_length_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edges_length_check

i = get(hObject, 'UserData');
edges_field_on = getappdata(handles.figure1, 'edges_field_on');
edges_field_on(i) = get(hObject,'Value');
setappdata(handles.figure1, 'edges_field_on', edges_field_on);    
draw_edges_plot(handles)


% --- Executes on mouse press over axes background.
function edges_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edges_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function all_edges_CreateFcn(hObject, eventdata, handles)
% hObject    handle to all_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


