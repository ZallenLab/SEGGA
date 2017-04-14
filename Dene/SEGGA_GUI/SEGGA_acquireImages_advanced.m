function varargout = SEGGA_acquireImages_advanced(varargin)
% SEGGA_ACQUIREIMAGES_ADVANCED MATLAB code for SEGGA_acquireImages_advanced.fig
%      SEGGA_ACQUIREIMAGES_ADVANCED, by itself, creates a new SEGGA_ACQUIREIMAGES_ADVANCED or raises the existing
%      singleton*.
%
%      H = SEGGA_ACQUIREIMAGES_ADVANCED returns the handle to a new SEGGA_ACQUIREIMAGES_ADVANCED or the handle to
%      the existing singleton*.
%
%      SEGGA_ACQUIREIMAGES_ADVANCED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_ACQUIREIMAGES_ADVANCED.M with the given input arguments.
%
%      SEGGA_ACQUIREIMAGES_ADVANCED('Property','Value',...) creates a new SEGGA_ACQUIREIMAGES_ADVANCED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_acquireImages_advanced_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_acquireImages_advanced_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_acquireImages_advanced

% Last Modified by GUIDE v2.5 21-Apr-2015 11:41:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_acquireImages_advanced_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_acquireImages_advanced_OutputFcn, ...
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


% --- Executes just before SEGGA_acquireImages_advanced is made visible.
function SEGGA_acquireImages_advanced_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_acquireImages_advanced (see VARARGIN)

% Choose default command line output for SEGGA_acquireImages_advanced
handles.output = hObject;

if numel(varargin) > 0 && ~isempty(varargin{1})
    calling_fun_handle = varargin{1};
    handles.calling_fun_handle = calling_fun_handle;
else
    display('must call SEGGA_acquireImages_advanced with the handle of the calling figure as an input variable');
    error('needs handle of calling function as input');
    return;
end
% Update handles structure


% UIWAIT makes SEGGA_acquireImages_advanced wait for user response (see UIRESUME)
% uiwait(handles.figure1);

output_settings.scriptsBool = get(handles.scriptsBool,'value');
output_settings.combinedBool = get(handles.combinedBool,'value');
output_settings.multi_settingsBool = get(handles.multi_settingsBool,'value');
output_settings.adaptMaxBool = get(handles.adaptMaxBool,'value');
output_settings.PIVBool = get(handles.PIVBool,'value');
output_settings.showPIVelon = get(handles.showPIVelon,'value');
output_settings.visualize_PIV = get(handles.visualize_PIV,'value');
output_settings.super_smplBool = get(handles.super_smplBool,'value');
output_settings.denoisingBool = get(handles.denoisingBool,'value');
output_settings.aniso_smthBool = get(handles.aniso_smthBool,'value');
handles.output_settings = output_settings;

guidata(hObject, handles);

setappdata(handles.figure1,'output_settings_togo',output_settings);
setappdata(handles.calling_fun_handle,'advanced_settings_pushed',output_settings);
% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_acquireImages_advanced_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function scriptsBool_Callback(hObject, eventdata, handles)
% hObject    handle to scriptsBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scriptsBool as text
%        str2double(get(hObject,'String')) returns contents of scriptsBool as a double
output_settings.scriptsBool = get(handles.scriptsBool,'value');

handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function scriptsBool_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function multi_settingsBool_Callback(hObject, eventdata, handles)
% hObject    handle to multi_settingsBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of multi_settingsBool as text
%        str2double(get(hObject,'String')) returns contents of multi_settingsBool as a double

output_settings.multi_settingsBool = get(handles.multi_settingsBool,'value');

handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function multi_settingsBool_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function combinedBool_Callback(hObject, eventdata, handles)

output_settings.combinedBool = get(handles.combinedBool,'value');

handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function combinedBool_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PIVBool_Callback(hObject, eventdata, handles)

output_settings.PIVBool = get(handles.PIVBool,'value');

handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PIVBool_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function showPIVelon_Callback(hObject, eventdata, handles)

output_settings.showPIVelon = get(handles.showPIVelon,'value');
handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function showPIVelon_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function adaptMaxBool_Callback(hObject, eventdata, handles)


output_settings.adaptMaxBool = get(handles.adaptMaxBool,'value');
handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function adaptMaxBool_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in submit_opts.
function submit_opts_Callback(hObject, eventdata, handles)
% hObject    handle to submit_opts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

output_settings.scriptsBool = get(handles.scriptsBool,'value');
output_settings.combinedBool = get(handles.combinedBool,'value');
output_settings.multi_settingsBool = get(handles.multi_settingsBool,'value');
output_settings.adaptMaxBool = get(handles.adaptMaxBool,'value');
output_settings.PIVBool = get(handles.PIVBool,'value');
output_settings.showPIVelon = get(handles.showPIVelon,'value');

output_settings.visualize_PIV = get(handles.visualize_PIV,'value');
output_settings.super_smplBool = get(handles.super_smplBool,'value');
output_settings.denoisingBool = get(handles.denoisingBool,'value');
output_settings.aniso_smthBool = get(handles.aniso_smthBool,'value');


output_settings.handles.output_settings = output_settings;
guidata(hObject, handles);
setappdata(handles.figure1,'output_settings_togo',output_settings);
setappdata(handles.calling_fun_handle,'advanced_settings_pushed',output_settings);
close(handles.figure1);


function aniso_smthBool_Callback(hObject, eventdata, handles)
% hObject    handle to aniso_smthBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aniso_smthBool as text
%        str2double(get(hObject,'String')) returns contents of aniso_smthBool as a double
output_settings.aniso_smthBool = get(handles.aniso_smthBool,'value');
handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function aniso_smthBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aniso_smthBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function denoisingBool_Callback(hObject, eventdata, handles)
% hObject    handle to denoisingBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of denoisingBool as text
%        str2double(get(hObject,'String')) returns contents of denoisingBool as a double
output_settings.denoisingBool = get(handles.denoisingBool,'value');
handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function denoisingBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to denoisingBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function super_smplBool_Callback(hObject, eventdata, handles)
% hObject    handle to super_smplBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of super_smplBool as text
%        str2double(get(hObject,'String')) returns contents of super_smplBool as a double
output_settings.super_smplBool = get(handles.super_smplBool,'value');
handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function super_smplBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to super_smplBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function visualize_PIV_Callback(hObject, eventdata, handles)
% hObject    handle to visualize_PIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of visualize_PIV as text
%        str2double(get(hObject,'String')) returns contents of visualize_PIV as a double
output_settings.visualize_PIV = get(handles.visualize_PIV,'value');
handles.output_settings = output_settings;
setappdata(handles.figure1,'output_settings_togo',output_settings);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function visualize_PIV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visualize_PIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
