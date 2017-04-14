function varargout = SEGGA_resegment_from_exisiting_segmentation(varargin)
% SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION MATLAB code for SEGGA_resegment_from_exisiting_segmentation.fig
%      SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION, by itself, creates a new SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION or raises the existing
%      singleton*.
%
%      H = SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION returns the handle to a new SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION or the handle to
%      the existing singleton*.
%
%      SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION.M with the given input arguments.
%
%      SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION('Property','Value',...) creates a new SEGGA_RESEGMENT_FROM_EXISITING_SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_resegment_from_exisiting_segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_resegment_from_exisiting_segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_resegment_from_exisiting_segmentation

% Last Modified by GUIDE v2.5 04-Jan-2017 12:32:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_resegment_from_exisiting_segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_resegment_from_exisiting_segmentation_OutputFcn, ...
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


% --- Executes just before SEGGA_resegment_from_exisiting_segmentation is made visible.
function SEGGA_resegment_from_exisiting_segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_resegment_from_exisiting_segmentation (see VARARGIN)

% Choose default command line output for SEGGA_resegment_from_exisiting_segmentation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SEGGA_resegment_from_exisiting_segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_resegment_from_exisiting_segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_seg_btn.
function select_seg_btn_Callback(hObject, eventdata, handles)
[filename, source_dir] = uigetfile( ...
    {'*.mat','Matlab Files'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');
fold_names = {fliplr(strtok(fliplr(source_dir),filesep))};
[~, d] = strtok(fliplr(source_dir),filesep);
source_dir_base = fliplr(d);

if (source_dir==0)
    error('No Source Directory Selected!');
    source_dir_base = [];
    source_dir = [];
    fold_names = {};
else
    fold_names = {fliplr(strtok(fliplr(source_dir),filesep))};

end

handles.params.seg_source_base = source_dir_base;
handles.params.fold_names = fold_names;
handles.params.seg_source_full = [source_dir_base,filesep,fold_names{:}];
%     set(handles.imprt_dir,'string',source_dir);

if isdir(source_dir_base)
    handles.params.source_full = source_dir;

    set(handles.exisiting_seg_base_txt,'string',source_dir,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    set(handles.exisiting_seg_fold_txt,'string',fold_names,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
end

guidata(hObject, handles);


% --- Executes on button press in select_proj_btn.
function select_proj_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_proj_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, new_proj_dir] = uigetfile( ...
    {'*.tif','TIF Files'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');
fold_names = {fliplr(strtok(fliplr(new_proj_dir),filesep))};
[~, d] = strtok(fliplr(new_proj_dir),filesep);
new_proj_dir_base = fliplr(d);

if (new_proj_dir==0)
    error('No Source Directory Selected!');
    new_proj_dir = [];
    new_proj_dir = [];
    fold_names = {};
else
    fold_names = {fliplr(strtok(fliplr(new_proj_dir),filesep))};

end

handles.params.new_proj_base = new_proj_dir_base;
handles.params.proj_fold_names = fold_names;
handles.params.proj_full_loc = [new_proj_dir_base,filesep,fold_names{:}];
%     set(handles.imprt_dir,'string',source_dir);

if isdir(new_proj_dir_base)
    handles.params.new_proj_full = new_proj_dir;

    set(handles.new_proj_base_txt,'string',new_proj_dir_base,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    set(handles.new_proj_fold_txt,'string',fold_names,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
end

guidata(hObject, handles);


function exisiting_seg_base_txt_Callback(hObject, eventdata, handles)

function exisiting_seg_base_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exisiting_seg_fold_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function new_proj_base_txt_Callback(hObject, eventdata, handles)
handles.params.new_proj_base = get(hObject,'string');
guidata(hObject, handles);

function new_proj_fold_txt_Callback(hObject, eventdata, handles)
handles.params.fold_names = get(hObject,'string');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function new_proj_base_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function new_proj_fold_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in conv_seg_w_dip_btn.
function conv_seg_w_dip_btn_Callback(hObject, eventdata, handles)

copy_mismatched_files_into_one_dir(handles)

%%% Change SEG file z nums
startdir = pwd;
cd(handles.params.destin_full);

%%% Check for DIPimage

%%%% Convert
redo_seg_with_z_shift_with_DIP;
cd(startdir);


% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)


% --- Executes on button press in sel_output_btn.
function sel_output_btn_Callback(hObject, eventdata, handles)
destin_base = uigetdir(pwd,'Select Base Destination Directory');
destin_base = [destin_base,filesep];
if (destin_base==0)
    error('No Destination Directory Selected!');
    handles.params.destin_base = [];
else
    if ~isdir(destin_base)
        error('The directory %s does not exist', destin_base);
        handles.params.destin_base = [];
        return;
    else

        handles.params.destin_base = destin_base;
        handles.params.destin_fold = 'shifted_seg';
        handles.params.destin_full =[handles.params.destin_base,handles.params.destin_fold];
        
        set(handles.seg_output_base_txt,'string',destin_base,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    set(handles.seg_output_fold_txt,'string',handles.params.destin_fold,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    end
end


guidata(hObject, handles);



function seg_output_base_txt_Callback(hObject, eventdata, handles)
handles.params.destin_base = get(hObject,'string');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function seg_output_base_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function seg_output_fold_txt_Callback(hObject, eventdata, handles)
handles.params.destin_fold = get(hObject,'string');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function seg_output_fold_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in copy_files_btn.
function copy_files_btn_Callback(hObject, eventdata, handles)
% hObject    handle to copy_files_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mod_seg_names_btn.
function mod_seg_names_btn_Callback(hObject, eventdata, handles)
startdir = pwd;
cd(handles.params.destin_full);
change_seg_file_names_to_match_img;
cd(startdir);


% --- Executes on button press in centers2water_btn.
function centers2water_btn_Callback(hObject, eventdata, handles)
startdir = pwd;
cd(handles.params.destin_full);
centers2watershed;
cd(startdir);

% --- Executes on button press in water2geom_btn.
function water2geom_btn_Callback(hObject, eventdata, handles)
startdir = pwd;
cd(handles.params.destin_full);
rod2ori_data_conversion('geometry');
cd(startdir);


% --- Executes on button press in rod2ori_fnames_btn.
function rod2ori_fnames_btn_Callback(hObject, eventdata, handles)
startdir = pwd;
cd(handles.params.destin_full);
load('basefilename')
convert_filenames_rod2ori([basefilename,'_'], 0);
cd(startdir);


function copy_mismatched_files_into_one_dir(handles)
%%% Make the Conversion
if ~isdir(handles.params.destin_full)
    mkdir(handles.params.destin_full)
end

%%% Copy IMG files
all_tifs = dir([handles.params.proj_full_loc,filesep,'*.tif']);
% all_tifs = {all_tifs(:).name};
for i = 1:length(all_tifs)
    copyfile([handles.params.proj_full_loc,filesep,all_tifs(i).name],...
             [handles.params.destin_full,filesep,all_tifs(i).name]);
end

%%% Copy SEG files
all_segs = dir([handles.params.seg_source_full,filesep,'*.mat']);
% all_tifs = {all_tifs(:).name};
for i = 1:length(all_segs)
    copyfile([handles.params.seg_source_full,filesep,all_segs(i).name],...
             [handles.params.destin_full,filesep,all_segs(i).name]);
end


% --- Executes on button press in conv_seg_usual_pipe_btn.
function conv_seg_usual_pipe_btn_Callback(hObject, eventdata, handles)
% hObject    handle to conv_seg_usual_pipe_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('need to finish coding, need to create redo_seg_with_z_shift_usual_pipeline');
return
copy_mismatched_files_into_one_dir(handles)
startdir = pwd;
cd(handles.params.destin_full);
%%%% Convert
redo_seg_with_z_shift_usual_pipeline;
cd(startdir);
