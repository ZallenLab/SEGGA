function varargout = SEGGA_rotation_interface(varargin)
% SEGGA_ROTATION_INTERFACE MATLAB code for SEGGA_rotation_interface.fig
%      SEGGA_ROTATION_INTERFACE, by itself, creates a new SEGGA_ROTATION_INTERFACE or raises the existing
%      singleton*.
%
%      H = SEGGA_ROTATION_INTERFACE returns the handle to a new SEGGA_ROTATION_INTERFACE or the handle to
%      the existing singleton*.
%
%      SEGGA_ROTATION_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_ROTATION_INTERFACE.M with the given input arguments.
%
%      SEGGA_ROTATION_INTERFACE('Property','Value',...) creates a new SEGGA_ROTATION_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_rotation_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_rotation_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_rotation_interface

% Last Modified by GUIDE v2.5 11-Apr-2017 16:41:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_rotation_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_rotation_interface_OutputFcn, ...
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


% --- Executes just before SEGGA_rotation_interface is made visible.
function SEGGA_rotation_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_rotation_interface (see VARARGIN)

% Choose default command line output for SEGGA_rotation_interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SEGGA_rotation_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_rotation_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in submit_btn.
function submit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to submit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
calling_fig = getappdata(handles.figure1,'calling_fig');
% calling_fig_rot_txt_handle = getappdata(handles.figure1,'calling_fig_rot_txt_handle');
alpha = getappdata(handles.figure1,'rot_ang');
setappdata(calling_fig,'updated_alpha',alpha);
close(handles.figure1);
return

% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);
return

% --- Executes on slider movement.
function rot_slider_Callback(hObject, eventdata, handles)
% hObject    handle to rot_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
alpha = get(hObject,'Value');
setappdata(handles.figure1,'rot_ang',alpha);
set(handles.degrees_txt,'String',alpha);
guidata(hObject, handles);
update_rotation_interface(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rot_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rot_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0,'Max',360,'SliderStep',[1/36,20/36]);
    


function degrees_txt_Callback(hObject, eventdata, handles)
% hObject    handle to degrees_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of degrees_txt as text
%        str2double(get(hObject,'String')) returns contents of degrees_txt as a double
setappdata(handles.figure1,'rot_ang',str2double(get(hObject,'String')));
set(handles.rot_slider,'Value',str2double(get(hObject,'String')));
guidata(hObject, handles);
update_rotation_interface(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function degrees_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to degrees_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on slider movement.
function z_slider_Callback(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
z = round(get(hObject,'Value'));
setappdata(handles.figure1,'z',z);
set(handles.z_txt,'String',z);
guidata(hObject, handles);
update_rotation_interface(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function z_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function z_txt_Callback(hObject, eventdata, handles)
% hObject    handle to z_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_txt as text
%        str2double(get(hObject,'String')) returns contents of z_txt as a double
z = str2double(get(hObject,'String'));
setappdata(handles.figure1,'z',z);
set(handles.z_slider,'Value',z);
guidata(hObject, handles);
update_rotation_interface(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function z_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_img_btn.
function load_img_btn_Callback(hObject, eventdata, handles)
new_img_file = uigetfile({'*.tif','*.*'},'load new img');
if isempty(new_img_file) || all(new_img_file == 0)
    display('no image file selected');
    return
end
img = imread(new_img_file);
setappdata(handles.figure1,'img',img);
update_rotation_interface(handles);
set(handles.z_slider,'Min',1,'Max',size(img,3),'SliderStep',[1/(size(img,3)-1),5/(size(img,3)-1)]);

