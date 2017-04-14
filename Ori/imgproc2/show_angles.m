function varargout = show_angles(varargin)
% SHOW_ANGLES M-file for show_angles.fig
%      SHOW_ANGLES, by itself, creates a new SHOW_ANGLES or raises the existing
%      singleton*.
%
%      H = SHOW_ANGLES returns the handle to a new SHOW_ANGLES or the handle to
%      the existing singleton*.
%
%      SHOW_ANGLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOW_ANGLES.M with the given input arguments.
%
%      SHOW_ANGLES('Property','Value',...) creates a new SHOW_ANGLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before show_angles_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to show_angles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help show_angles

% Last Modified by GUIDE v2.5 24-Jul-2006 18:17:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @show_angles_OpeningFcn, ...
                   'gui_OutputFcn',  @show_angles_OutputFcn, ...
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


% --- Executes just before show_angles is made visible.
function show_angles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to show_angles (see VARARGIN)

% Choose default command line output for show_angles
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes show_angles wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = show_angles_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angle1 = str2double(get(handles.edit_left, 'string'));
angle2 = str2double(get(handles.edit_right, 'string'));
angles = [angle1 angle2];
h = getappdata(handles.figure1, 'calling_window');
setappdata(h, 'angles', angles);
close(handles.figure1);

% --- Executes on slider movement.
function slider_left_Callback(hObject, eventdata, handles)
% hObject    handle to slider_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.edit_left, 'String', num2str(get(hObject, 'value')))

% --- Executes during object creation, after setting all properties.
function slider_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_left_Callback(hObject, eventdata, handles)
% hObject    handle to edit_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_left as text
%        str2double(get(hObject,'String')) returns contents of edit_left as a double


% --- Executes during object creation, after setting all properties.
function edit_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_right_Callback(hObject, eventdata, handles)
% hObject    handle to edit_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_right as text
%        str2double(get(hObject,'String')) returns contents of edit_right as a double


% --- Executes during object creation, after setting all properties.
function edit_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_right_Callback(hObject, eventdata, handles)
% hObject    handle to slider_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit_right, 'String', num2str(get(hObject, 'value')))

% --- Executes during object creation, after setting all properties.
function slider_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
h = getappdata(handles.figure1, 'edges_handle');
delete(h(ishandle(h)));
delete(hObject);




% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


