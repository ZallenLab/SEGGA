function varargout = ext_clusters_dlg(varargin)
% EXT_CLUSTERS_DLG M-file for ext_clusters_dlg.fig
%      EXT_CLUSTERS_DLG, by itself, creates a new EXT_CLUSTERS_DLG or raises the existing
%      singleton*.
%
%      H = EXT_CLUSTERS_DLG returns the handle to a new EXT_CLUSTERS_DLG or the handle to
%      the existing singleton*.
%
%      EXT_CLUSTERS_DLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXT_CLUSTERS_DLG.M with the given input arguments.
%
%      EXT_CLUSTERS_DLG('Property','Value',...) creates a new EXT_CLUSTERS_DLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ext_clusters_dlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ext_clusters_dlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ext_clusters_dlg

% Last Modified by GUIDE v2.5 17-Jan-2007 23:13:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ext_clusters_dlg_OpeningFcn, ...
                   'gui_OutputFcn',  @ext_clusters_dlg_OutputFcn, ...
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


% --- Executes just before ext_clusters_dlg is made visible.
function ext_clusters_dlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ext_clusters_dlg (see VARARGIN)

% Choose default command line output for ext_clusters_dlg
data.span = str2double(get(handles.span, 'String'));
data.clusters = 0;
handles.output = data;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ext_clusters_dlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ext_clusters_dlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data.span = str2double(get(handles.span, 'String'));
data.clusters = get(handles.apply_to, 'userdata');
handles.output = data;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data.span = str2double(get(handles.span, 'String'));
data.clusters = 0;
handles.output = data;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


function span_Callback(hObject, eventdata, handles)
% hObject    handle to span (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of span as text
%        str2double(get(hObject,'String')) returns contents of span as a double


% --- Executes during object creation, after setting all properties.
function span_CreateFcn(hObject, eventdata, handles)
% hObject    handle to span (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function apply_to_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to apply_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.apply_to, 'userdata', get(hObject, 'userdata'));



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




