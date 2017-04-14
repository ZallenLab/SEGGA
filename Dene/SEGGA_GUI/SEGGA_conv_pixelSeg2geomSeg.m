function varargout = SEGGA_conv_pixelSeg2geomSeg(varargin)
% SEGGA_CONV_PIXELSEG2GEOMSEG MATLAB code for SEGGA_conv_pixelSeg2geomSeg.fig
%      SEGGA_CONV_PIXELSEG2GEOMSEG, by itself, creates a new SEGGA_CONV_PIXELSEG2GEOMSEG or raises the existing
%      singleton*.
%
%      H = SEGGA_CONV_PIXELSEG2GEOMSEG returns the handle to a new SEGGA_CONV_PIXELSEG2GEOMSEG or the handle to
%      the existing singleton*.
%
%      SEGGA_CONV_PIXELSEG2GEOMSEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_CONV_PIXELSEG2GEOMSEG.M with the given input arguments.
%
%      SEGGA_CONV_PIXELSEG2GEOMSEG('Property','Value',...) creates a new SEGGA_CONV_PIXELSEG2GEOMSEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_conv_pixelSeg2geomSeg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_conv_pixelSeg2geomSeg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_conv_pixelSeg2geomSeg

% Last Modified by GUIDE v2.5 10-Apr-2017 17:03:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_conv_pixelSeg2geomSeg_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_conv_pixelSeg2geomSeg_OutputFcn, ...
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


% --- Executes just before SEGGA_conv_pixelSeg2geomSeg is made visible.
function SEGGA_conv_pixelSeg2geomSeg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_conv_pixelSeg2geomSeg (see VARARGIN)
try
    handles = attempt_auto_pop(handles);
catch
    display('could not auto populate. define input and output manually');
end

% Choose default command line output for SEGGA_conv_pixelSeg2geomSeg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes SEGGA_conv_pixelSeg2geomSeg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_conv_pixelSeg2geomSeg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_seg_btn.
function select_seg_btn_Callback(hObject, eventdata, handles)
[filename, source_dir] = uigetfile( ...
    {'*.tif','Matlab Files'; ...
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
handles.params.seg_source_filename = filename;
handles.params.seg_source_full = [source_dir,filesep,filename];
%     set(handles.imprt_dir,'string',source_dir);

if isdir(source_dir_base)
    handles.params.source_full = source_dir;

    set(handles.exisiting_seg_base_txt,'string',source_dir,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    set(handles.exisiting_seg_file_txt,'string',filename,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
end

guidata(hObject, handles);


% --- Executes on button press in select_proj_btn.
function select_proj_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_proj_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, proj_dir] = uigetfile( ...
    {'*.tif','TIF Files'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');
fold_names = {fliplr(strtok(fliplr(proj_dir),filesep))};
[~, d] = strtok(fliplr(proj_dir),filesep);
proj_dir_base = fliplr(d);

if (proj_dir==0)
    error('No Source Directory Selected!');
    proj_dir = [];
    fold_names = {};
else
    fold_names = {fliplr(strtok(fliplr(proj_dir),filesep))};

end

handles.params.proj_base = proj_dir_base;
handles.params.proj_filename = filename;
handles.params.proj_full = [proj_dir,filesep,filename];


if isdir(proj_dir_base)
    set(handles.background_img_base_txt,'string',proj_dir,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    set(handles.background_image_file_txt,'string',filename,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
end

guidata(hObject, handles);


function exisiting_seg_base_txt_Callback(hObject, eventdata, handles)
handles.params.seg_source_base = get(hObject,'string');
handles.params.seg_source_full = [handles.params.seg_source_filename,...
                                  filesep, handles.params.seg_source_filename];

function exisiting_seg_file_txt_Callback(hObject, eventdata, handles)
handles.params.seg_source_filename = get(hObject,'string');
handles.params.seg_source_full = [handles.params.seg_source_filename,...
                                  filesep, handles.params.seg_source_filename];
                              

function exisiting_seg_base_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exisiting_seg_file_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function background_img_base_txt_Callback(hObject, eventdata, handles)
handles.params.proj_base = get(hObject,'string');
handles.params.proj_full = [handles.params.proj_base,...
                            filesep, handles.params.proj_filename];
guidata(hObject, handles);

function background_image_file_txt_Callback(hObject, eventdata, handles)
handles.params.proj_filename = get(hObject,'string');
handles.params.proj_full = [handles.params.proj_base,...
                            filesep, handles.params.proj_filename];

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function background_img_base_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function background_image_file_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in conv_seg_btn.
function conv_seg_btn_Callback(hObject, eventdata, handles)
output_params.start_seg = handles.params.seg_source_full;
output_params.start_img = handles.params.proj_full;
output_params.output_dir = handles.params.destin_base;
output_params.output_filename = handles.params.destin_file;
homedir = handles.params.seg_source_base;
autobool = true;
debugbool = false;
convert_pixelSeg_to_geomSeg(homedir,autobool,debugbool,output_params);


% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
close(handles.figure1);
display('user cancelled conversion');
return

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
        handles.params.destin_file = 'convgeom_T0001_new_Z0001';
        handles.params.destin_full =[handles.params.destin_base,handles.params.destin_file];
        
        set(handles.seg_output_base_txt,'string',destin_base,...
        'foregroundcolor',[0 1 0],...
        'backgroundcolor',[0 0 0]);
    set(handles.seg_output_file_txt,'string',handles.params.destin_file,...
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



function seg_output_file_txt_Callback(hObject, eventdata, handles)
handles.params.destin_file = get(hObject,'string');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function seg_output_file_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = attempt_auto_pop(handles)
curr_dir = pwd;

segdir = [curr_dir,'/Segments/'];
segname = 'Segment_0_000.tif';
if isempty(dir([segdir,segname])) 
    display('missing seg file - specify manually');
    return
end


imgdir = [curr_dir,'/Outlines/'];
outline_name = 'Outline_0_000.tif';
if isempty(dir([imgdir,outline_name])) 
    display('missing background file - specify manually');
    return
end

outdir = [curr_dir,'/Conv/'];
mkdir(outdir);
handles.params.destin_base = outdir;
handles.params.destin_file = 'convgeom_T0001_new_Z0001';
handles.params.destin_full =[handles.params.destin_base,handles.params.destin_file];


handles.params.seg_source_base = segdir;
handles.params.seg_source_filename = segname;
handles.params.seg_source_full = [segdir,filesep,segname];

handles.params.proj_dir = imgdir;
handles.params.proj_filename = outline_name;
handles.params.proj_full = [imgdir,filesep,outline_name];

set(handles.exisiting_seg_base_txt,'string',segdir,...
    'foregroundcolor',[0 1 0],...
    'backgroundcolor',[0 0 0]);
set(handles.exisiting_seg_file_txt,'string',segname,...
    'foregroundcolor',[0 1 0],...
    'backgroundcolor',[0 0 0]);

set(handles.seg_output_base_txt,'string',handles.params.destin_base,...
    'foregroundcolor',[0 1 0],...
    'backgroundcolor',[0 0 0]);
set(handles.seg_output_file_txt,'string',handles.params.destin_file,...
    'foregroundcolor',[0 1 0],...
    'backgroundcolor',[0 0 0]);

set(handles.background_img_base_txt,'string',handles.params.proj_dir,...
    'foregroundcolor',[0 1 0],...
    'backgroundcolor',[0 0 0]);
set(handles.background_image_file_txt,'string',outline_name,...
    'foregroundcolor',[0 1 0],...
    'backgroundcolor',[0 0 0]);

guidata(handles.figure1, handles);


% --- Executes on button press in convert_series.
function convert_series_Callback(hObject, eventdata, handles)
output_params.start_seg = handles.params.seg_source_full;
output_params.start_img = handles.params.proj_full;
output_params.output_dir = handles.params.destin_base;
output_params.output_filename = handles.params.destin_file;

no_stop = true;
shift_nums = false;

[seg_dir,seg_file,~] = fileparts(output_params.start_seg);
[~, ~, t_ind] = get_file_nums_dlf(seg_file,no_stop);
seg_base = seg_file(1:t_ind);
all_segs = dir([seg_dir,filesep,seg_base,'*']);
seg_nums = nan(size(all_segs));
for i = 1:length(all_segs)
    [~, seg_nums(i)] = get_file_nums_dlf(all_segs(i).name,no_stop);
end

if sum(seg_nums==0)==1 && sum(seg_nums==1)==1
    shift_nums = true;
end
    

[backg_dir,backg_file,~] = fileparts(handles.params.proj_full);
[~, ~, t_ind] = get_file_nums_dlf(backg_file,no_stop);
backg_base = backg_file(1:t_ind);
all_backgrs = dir([backg_dir,filesep,backg_base,'*']);
all_backgr_nums = nan(size(all_segs));
for i = 1:length(all_segs)
    [~, all_backgr_nums(i)] = get_file_nums_dlf(all_backgrs(i).name,no_stop);
end
    

for i = 1:length(all_segs)    
    conv_series(i).seg_file = fullfile(seg_dir,all_segs(i).name);
    if any(seg_nums(i)==all_backgr_nums)
        %%% match background image to seg image if possible
        j = find(seg_nums(i)==all_backgr_nums,1,'first');
        conv_series(i).backgr_file = fullfile(backg_dir,all_backgrs(j).name);
    else
        conv_series(i).backgr_file = fullfile(seg_dir,all_segs(i).name);
    end
end    

conv_series(:).seg_file;
conv_series(:).backgr_file;


homedir = handles.params.seg_source_base;
autobool = true;
debugbool = false;
for i = 1:length(conv_series)
    output_params.start_seg = conv_series(i).seg_file;
    output_params.start_img = conv_series(i).backgr_file;
    output_params.output_dir = handles.params.destin_base;
    [~, fname_only] = fileparts(conv_series(i).seg_file);
    [z, t, t_ind] = get_file_nums_dlf(fname_only);
    if isempty(z)
        z = 1;
    end
    if isempty(t)
        t = 1;
    end
    if shift_nums
        t = t+1;
    end
    num_length = 4;
    fmt = sprintf('%%0%1dd', num_length); % = '%04d'
    output_params.output_filename = [fname_only(1:t_ind),...
                                     'T',num2str(t, fmt),'_Z',num2str(z, fmt)];
    try
        convert_pixelSeg_to_geomSeg(homedir,autobool,debugbool,output_params);
    catch
        display(['conv failed on file ',output_params.output_filename]);
    end
end
