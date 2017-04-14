function varargout = change_in_nghbrs_dlg(varargin)
% CHANGE_IN_NGHBRS_DLG M-file for change_in_nghbrs_dlg.fig
%      CHANGE_IN_NGHBRS_DLG by itself, creates a new CHANGE_IN_NGHBRS_DLG or raises the
%      existing singleton*.
%
%      H = CHANGE_IN_NGHBRS_DLG returns the handle to a new CHANGE_IN_NGHBRS_DLG or the handle to
%      the existing singleton*.
%
%      CHANGE_IN_NGHBRS_DLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANGE_IN_NGHBRS_DLG.M with the given input arguments.
%
%      CHANGE_IN_NGHBRS_DLG('Property','Value',...) creates a new CHANGE_IN_NGHBRS_DLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before change_in_nghbrs_dlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to change_in_nghbrs_dlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help change_in_nghbrs_dlg

% Last Modified by GUIDE v2.5 29-Jun-2007 19:19:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @change_in_nghbrs_dlg_OpeningFcn, ...
                   'gui_OutputFcn',  @change_in_nghbrs_dlg_OutputFcn, ...
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

% --- Executes just before change_in_nghbrs_dlg is made visible.
function change_in_nghbrs_dlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to change_in_nghbrs_dlg (see VARARGIN)

% Choose default command line output for change_in_nghbrs_dlg
options.cancel = true;
handles.output = options;

% Update handles structure
guidata(hObject, handles);

options.hide = {};
options.check = {};
options.text = {};
options.lower_lim = [];
options.upper_lim = [];
if nargin > 3
    options = overlay_struct(options, varargin{1});
end

for i = 1:length(options.hide)
    set(handles.(options.hide{i}), 'visible', 'off')
end

for i = 1:length(options.check)
    set(handles.(options.check{i}), 'value', 1)
end

set(handles.msg_txt, 'string', options.text)
set(handles.upper_lim, 'string', num2str(options.upper_lim))
set(handles.lower_lim, 'string', num2str(options.lower_lim))

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes change_in_nghbrs_dlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = change_in_nghbrs_dlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    close(handles.figure1)
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    
end    


% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --- Executes on button press in sel_cells.
function sel_cells_Callback(hObject, eventdata, handles)
% hObject    handle to sel_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sel_cells


% --- Executes on button press in high_cells.
function high_cells_Callback(hObject, eventdata, handles)
% hObject    handle to high_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of high_cells


% --- Executes on button press in count_gain.
function count_gain_Callback(hObject, eventdata, handles)
% hObject    handle to count_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of count_gain


% --- Executes on button press in count_loss.
function count_loss_Callback(hObject, eventdata, handles)
% hObject    handle to count_loss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of count_loss


% --- Executes on button press in high_edges.
function high_edges_Callback(hObject, eventdata, handles)
% hObject    handle to high_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of high_edges


% --- Executes on button press in ok_btn.
function ok_btn_Callback(hObject, eventdata, handles)
% hObject    handle to ok_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




options.cells_lim_to_sel = get(handles.sel_cells, 'value');
options.lim_cells_to_high = get(handles.high_cells, 'value');
options.count_gain = get(handles.count_gain, 'value');
options.count_loss = get(handles.count_loss, 'value');
options.edge_nghbrs = ~get(handles.node_nghbrs, 'value');
options.lower_lim = str2double(get(handles.lower_lim, 'string'));
options.upper_lim = str2double(get(handles.upper_lim, 'string'));

% count = strcmp(get(handles.count_loss, 'visible'), 'on');
% if count & ~options.count_gain & ~options.count_loss 
%     h = msgbox('Select type of neighbors change to count', '', 'warn', 'modal');
%     waitfor(h);
%     return
% end

options.cancel = false;
handles.output = options;
guidata(hObject, handles);
close(handles.figure1);


% --- Executes on button press in sel_nodes.
function sel_nodes_Callback(hObject, eventdata, handles)
% hObject    handle to sel_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sel_nodes


% --- Executes on button press in high_cells_for_nodes.
function high_cells_for_nodes_Callback(hObject, eventdata, handles)
% hObject    handle to high_cells_for_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of high_cells_for_nodes


% --- Executes on button press in high_edges_for_nodes.
function high_edges_for_nodes_Callback(hObject, eventdata, handles)
% hObject    handle to high_edges_for_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of high_edges_for_nodes





function upper_lim_Callback(hObject, eventdata, handles)
% hObject    handle to upper_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upper_lim as text
%        str2double(get(hObject,'String')) returns contents of upper_lim as a double


% --- Executes during object creation, after setting all properties.
function upper_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upper_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lower_lim_Callback(hObject, eventdata, handles)
% hObject    handle to lower_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lower_lim as text
%        str2double(get(hObject,'String')) returns contents of lower_lim as a double


% --- Executes during object creation, after setting all properties.
function lower_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lower_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in node_nghbrs.
function node_nghbrs_Callback(hObject, eventdata, handles)
% hObject    handle to node_nghbrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of node_nghbrs


