function varargout = SEGGA_main(varargin)
% SEGGA_MAIN MATLAB code for SEGGA_main.fig
%      SEGGA_MAIN, by itself, creates a new SEGGA_MAIN or raises the existing
%      singleton*.
%
%      H = SEGGA_MAIN returns the handle to a new SEGGA_MAIN or the handle to
%      the existing singleton*.
%
%      SEGGA_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_MAIN.M with the given input arguments.
%
%      SEGGA_MAIN('Property','Value',...) creates a new SEGGA_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_main

% Last Modified by GUIDE v2.5 08-Dec-2016 18:52:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_main_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_main_OutputFcn, ...
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


% --- Executes just before SEGGA_main is made visible.
function SEGGA_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_main (see VARARGIN)

% Choose default command line output for SEGGA_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% check if dir is root
if all(strcmp(filesep,pwd))
    display('changing to home dir from root dir');
    cd('~');
end

global public_release
public_release = true;

if public_release
    release_modifications(handles);
end

if isdeployed()
    warning('off','all');
    display(['curr dir: ',pwd]);
    set(handles.import_different_seg_format,'visible','off');
%     try
%         startup_DIP_mac;
%     catch
%         display('could not start up dip image');
%     end
end

try
    check_that_default_settings_files_exist();
catch
    display('could not check and/or create default files');
end

SEGGA_add_in_functions;

% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in acquire_images.
function acquire_images_Callback(hObject, eventdata, handles)
% hObject    handle to acquire_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_acquireImages;

% --- Executes on button press in proc_and_seg.
function proc_and_seg_Callback(hObject, eventdata, handles)
% hObject    handle to proc_and_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
play_movie;

% --- Executes on button press in corr_and_view_seg.
function corr_and_view_seg_Callback(hObject, eventdata, handles)
% hObject    handle to corr_and_view_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global public_release
h_corrections = commandsui;
if public_release
    setappdata(h_corrections,'public_release',public_release);
end

% --- Executes on button press in analyze.
function analyze_Callback(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in analyze_single.
function analyze_single_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_single (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_single_movie_analysis;

% --- Executes on button press in analyze_many.
function analyze_many_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_many (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_mult_movie_charts;


% --- Executes on button press in auto_correct_button.
function auto_correct_button_Callback(hObject, eventdata, handles)
% hObject    handle to auto_correct_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
seg_autocorrection;


% --- Executes on button press in check_errors_button.
function check_errors_button_Callback(hObject, eventdata, handles)
% hObject    handle to check_errors_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

keyframes = inputdlg('key frames','input key frames',1,{num2str([1,20,40,60,80])});
if isempty(keyframes)
    display('cancelled...');
    return
end
keyframes = str2num(keyframes{1});
display_bool = true;
SEGGA_check_errors(keyframes,display_bool);


% --- Executes on button press in polarity.
function polarity_Callback(hObject, eventdata, handles)
% hObject    handle to polarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(pwd,filesep);
    cd('~');
end
SEGGA_single_movie_polarity_analysis;




% --- Executes on button press in single_image_toolbox.
function single_image_toolbox_Callback(hObject, eventdata, handles)
% hObject    handle to single_image_toolbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_single_image_toolbox;


% --- Executes on button press in zshift_seg_btn.
function zshift_seg_btn_Callback(hObject, eventdata, handles)
global public_release
if ~public_release
    SEGGA_resegment_from_exisiting_segmentation;
else
    display('shifting segmentation in z function is still under development');
    return
end


% --- Executes on button press in import_different_seg_format.
function import_different_seg_format_Callback(hObject, eventdata, handles)

convdir = uigetdir();
if convdir
    cd(convdir)
else
    display('missing dir');
    return
end
SEGGA_conv_pixelSeg2geomSeg;
% convert_pixelSeg_to_geomSeg()

function release_modifications(handles)
set(handles.zshift_seg_btn,'visible','off');
% set(handles.import_different_seg_format,'visible','off');
% set(handles.conv_segs_panel,'visible','off');
