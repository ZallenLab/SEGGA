function varargout = embryo_orientation_UI(varargin)
% EMBRYO_ORIENTATION_UI MATLAB code for embryo_orientation_UI.fig
%      EMBRYO_ORIENTATION_UI, by itself, creates a new EMBRYO_ORIENTATION_UI or raises the existing
%      singleton*.
%
%      H = EMBRYO_ORIENTATION_UI returns the handle to a new EMBRYO_ORIENTATION_UI or the handle to
%      the existing singleton*.
%
%      EMBRYO_ORIENTATION_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMBRYO_ORIENTATION_UI.M with the given input arguments.
%
%      EMBRYO_ORIENTATION_UI('Property','Value',...) creates a new EMBRYO_ORIENTATION_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before embryo_orientation_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to embryo_orientation_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help embryo_orientation_UI

% Last Modified by GUIDE v2.5 25-Jan-2016 18:58:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @embryo_orientation_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @embryo_orientation_UI_OutputFcn, ...
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


% --- Executes just before embryo_orientation_UI is made visible.
function embryo_orientation_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to embryo_orientation_UI (see VARARGIN)

% Choose default command line output for embryo_orientation_UI
handles.output = hObject;

dvtxt = {'Back','Belly'};
aptxt = {'Head','Tail'};
dv_ordered = true;
ap_ordered = true;
setappdata(handles.figure1,'dvtxt',dvtxt);
setappdata(handles.figure1,'aptxt',aptxt);
setappdata(handles.figure1,'dv_ordered',dv_ordered);
setappdata(handles.figure1,'ap_ordered',ap_ordered);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes embryo_orientation_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = embryo_orientation_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in dv_btn.
function dv_btn_Callback(hObject, eventdata, handles)
% hObject    handle to dv_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dvtxt = getappdata(handles.figure1,'dvtxt');
dv_ordered = ~getappdata(handles.figure1,'dv_ordered');
if dv_ordered
    handles.dorsal_txt.String = dvtxt{1};
    handles.ventral_txt.String = dvtxt{2};
else
	handles.dorsal_txt.String = dvtxt{2};
    handles.ventral_txt.String = dvtxt{1};
end
setappdata(handles.figure1,'dv_ordered',dv_ordered);

% --- Executes on button press in ap_btn.
function ap_btn_Callback(hObject, eventdata, handles)
% hObject    handle to ap_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aptxt = getappdata(handles.figure1,'aptxt');
ap_ordered = ~getappdata(handles.figure1,'ap_ordered');
if ap_ordered
    handles.anterior_txt.String = aptxt{1};
    handles.posterior_txt.String = aptxt{2};
else
	handles.anterior_txt.String = aptxt{2};
    handles.posterior_txt.String = aptxt{1};
end
setappdata(handles.figure1,'ap_ordered',ap_ordered);

% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ap_ordered = getappdata(handles.figure1,'ap_ordered');
dv_ordered = getappdata(handles.figure1,'dv_ordered');
if ~isempty(dir('embryo_orientation.mat'))
    save('embryo_orientation','dv_ordered','ap_ordered','-append');
else
    save('embryo_orientation','dv_ordered','ap_ordered');
end
close(handles.figure1);
return
