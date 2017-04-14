function varargout = select_integral_value(varargin)
% SELECT_INTEGRAL_VALUE M-file for select_integral_value.fig
%      SELECT_INTEGRAL_VALUE, by itself, creates a new SELECT_INTEGRAL_VALUE or raises the existing
%      singleton*.
%
%      H = SELECT_INTEGRAL_VALUE returns the handle to a new SELECT_INTEGRAL_VALUE or the handle to
%      the existing singleton*.
%
%      SELECT_INTEGRAL_VALUE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_INTEGRAL_VALUE.M with the given input arguments.
%
%      SELECT_INTEGRAL_VALUE('Property','Value',...) creates a new SELECT_INTEGRAL_VALUE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_integral_value_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_integral_value_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_integral_value

% Last Modified by GUIDE v2.5 30-Jun-2007 20:36:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_integral_value_OpeningFcn, ...
                   'gui_OutputFcn',  @select_integral_value_OutputFcn, ...
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


% --- Executes just before select_integral_value is made visible.
function select_integral_value_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_integral_value (see VARARGIN)

% Choose default command line output for select_integral_value
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes select_integral_value wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_integral_value_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
mx = get(handles.slider1, 'max');
mn = get(handles.slider1, 'min');
new_val = max(mn, min(mx, round((get(hObject,'value')))));
set(handles.slider1, 'value', new_val);
set(handles.edit1, 'string', num2str(new_val));
do_my_thing(new_val, handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
mx = get(handles.slider1, 'max');
mn = get(handles.slider1, 'min');
new_val = max(mn, min(mx, round(str2double(get(hObject,'String')))));
set(handles.slider1, 'value', new_val);
set(hObject, 'string', num2str(new_val));
do_my_thing(new_val, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function do_my_thing(val, handles)
f = getappdata(handles.figure1, 'function_to_call');
options.count_gain = get(handles.count_gain, 'value');
options.count_loss = get(handles.count_loss, 'value');
options.val = val;
f(options);


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


