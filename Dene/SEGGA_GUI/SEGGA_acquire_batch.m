function varargout = SEGGA_acquire_batch(varargin)
% SEGGA_ACQUIRE_BATCH MATLAB code for SEGGA_acquire_batch.fig
%      SEGGA_ACQUIRE_BATCH, by itself, creates a new SEGGA_ACQUIRE_BATCH or raises the existing
%      singleton*.
%
%      H = SEGGA_ACQUIRE_BATCH returns the handle to a new SEGGA_ACQUIRE_BATCH or the handle to
%      the existing singleton*.
%
%      SEGGA_ACQUIRE_BATCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_ACQUIRE_BATCH.M with the given input arguments.
%
%      SEGGA_ACQUIRE_BATCH('Property','Value',...) creates a new SEGGA_ACQUIRE_BATCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_acquire_batch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_acquire_batch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_acquire_batch

% Last Modified by GUIDE v2.5 24-Apr-2015 20:54:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_acquire_batch_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_acquire_batch_OutputFcn, ...
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


% --- Executes just before SEGGA_acquire_batch is made visible.
function SEGGA_acquire_batch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_acquire_batch (see VARARGIN)

% Choose default command line output for SEGGA_acquire_batch
handles.output = hObject;


if numel(varargin) > 0 && ~isempty(varargin{1})
    calling_fun_handle = varargin{1};
    handles.calling_fun_handle = calling_fun_handle;
else
    display('must call SEGGA_acquire_batch with the handle of the calling figure as an input variable');
    error('needs handle of calling function as input');
    return;
end
% Update handles structure


% UIWAIT makes SEGGA_acquireImages_advanced wait for user response (see UIRESUME)
% uiwait(handles.figure1);
IO_dirs_set_in_mainGUI = getappdata(handles.calling_fun_handle,'IO_dirs_set_in_mainGUI');
% output_settings.source_full = IO_dirs_set_in_mainGUI.source_full;
output_settings.source_base = [IO_dirs_set_in_mainGUI.source_base,filesep];
output_settings.source_folds = IO_dirs_set_in_mainGUI.fold_names;
% output_settings.destin_full = IO_dirs_set_in_mainGUI.destin_full;
output_settings.destin_base = [IO_dirs_set_in_mainGUI.destin_base,filesep];
output_settings.destin_folds = IO_dirs_set_in_mainGUI.fold_names_out;


output_settings.batch_folders = IO_dirs_set_in_mainGUI.fold_names;
output_settings.batch_folders_out = IO_dirs_set_in_mainGUI.fold_names_out;
output_settings.test_batch = false;

handles.output_settings = output_settings;



if isdir(IO_dirs_set_in_mainGUI.source_base)
    set(handles.batch_import_button,'foregroundcolor','green');
    set(handles.import_dir_text,'string',IO_dirs_set_in_mainGUI.source_base,'foregroundcolor','green');
else
    set(handles.batch_import_button,'foregroundcolor','red');
    set(handles.import_dir_text,'string',IO_dirs_set_in_mainGUI.source_base,'foregroundcolor','red');
end

if isdir(IO_dirs_set_in_mainGUI.destin_base)
    set(handles.batch_export_button,'foregroundcolor','green');
    set(handles.export_dir_text,'string',IO_dirs_set_in_mainGUI.destin_base,'foregroundcolor','green');
else
    set(handles.batch_export_button,'foregroundcolor','red');
    set(handles.export_dir_text,'string',IO_dirs_set_in_mainGUI.destin_base,'foregroundcolor','red');
end

if isdir([IO_dirs_set_in_mainGUI.source_base,[IO_dirs_set_in_mainGUI.fold_names{:}]])
    set(handles.mult_movies_txt,'string',IO_dirs_set_in_mainGUI.fold_names,'foregroundcolor','green');
else
    set(handles.mult_movies_txt,'string',IO_dirs_set_in_mainGUI.fold_names,'foregroundcolor','red');
end

if isdir([IO_dirs_set_in_mainGUI.source_base,[IO_dirs_set_in_mainGUI.fold_names{:}]])
    set(handles.export_names_text,'string',IO_dirs_set_in_mainGUI.fold_names,'foregroundcolor','green');
else
    set(handles.export_names_text,'string',IO_dirs_set_in_mainGUI.fold_names,'foregroundcolor','red');
end


guidata(hObject, handles);
setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_acquire_batch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function import_dir_text_Callback(hObject, eventdata, handles)
% hObject    handle to import_dir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import_base_entered = get(handles.import_dir_text,'string');

if isdir(import_base_entered)
    set(handles.batch_import_button,'foregroundcolor','green');
    set(handles.import_dir_text,'foregroundcolor','green');
    handles.output_settings.source_base = import_base_entered;
    setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
    setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings);    
else
    set(handles.batch_import_button,'foregroundcolor','red');
    set(handles.import_dir_text,'foregroundcolor','red');
    msgbox(['''',import_base_entered,'''', ' is not a directory']);
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function import_dir_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to import_dir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in batch_import_button.
function batch_import_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_import_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     [filename, source_dir] = uigetfile( ...
%     {'*.TIF','Tagged Image File (*.TIF)'; ...
%     '*.*',  'All Files (*.*)'}, ...
%     'Select a Representative File', ...
%     'MultiSelect', 'on');
%     fold_names = {fliplr(strtok(fliplr(source_dir),filesep))};
%     [~, d] = strtok(fliplr(source_dir),filesep);
%     source_base_from_user = fliplr(d);

    [source_base_from_user] = uigetdir(...
     pwd,...
    'Select a Base Source Dir');
    source_base_from_user = [source_base_from_user,filesep];


    if (source_base_from_user==0)
        set(handles.batch_import_button,'foregroundcolor','red');
        set(handles.import_dir_text,'string','---SOURCE-NEEDED----','foregroundcolor','red');    
    end


    if isdir(source_base_from_user)
        handles.output_settings.source_base = source_base_from_user;
%         handles.output_settings.fold_names = fold_names;
        
        set(handles.batch_import_button,'ForegroundColor','green');
        set(handles.import_dir_text,'string',source_base_from_user,'foregroundcolor',[0 1 0]);
%         set(handles.single_movie_name,'string',fold_names,'foregroundcolor',[0 1 0]);
        set(handles.single_movie_name,'foregroundcolor',[0 1 0]);
        
        setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
        setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings); 
    else
        set(handles.batch_import_button,'foregroundcolor','red');
        set(handles.import_dir_text,'foregroundcolor','red');
    end
    

    guidata(hObject, handles);



function export_dir_text_Callback(hObject, eventdata, handles)
% hObject    handle to export_dir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_base_entered = get(handles.export_dir_text,'string');

if isdir(export_base_entered)
    set(handles.batch_export_button,'foregroundcolor','green');
    set(handles.export_dir_text,'foregroundcolor','green');
    handles.output_settings.destin_base = export_base_entered;
    setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
    setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings);    
else
    set(handles.batch_export_button,'foregroundcolor','red');
    set(handles.export_dir_text,'foregroundcolor','red');
    msgbox(['''',export_base_entered,'''', ' is not a directory']);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function export_dir_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to export_dir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in batch_export_button.
function batch_export_button_Callback(hObject, eventdata, handles)
% hObject    handle to batch_export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[export_base_from_user] = uigetdir( ...
     pwd,...
    'Select a Base Export Dir');


    if (export_base_from_user==0)
        set(handles.batch_export_button,'foregroundcolor','red');
        set(handles.export_dir_text,'string','---DESTINATION-NEEDED----','foregroundcolor','red');    
    end


    if isdir(export_base_from_user)
        handles.output_settings.destin_base = export_base_from_user;
        
        set(handles.batch_export_button,'ForegroundColor','green');
        set(handles.export_dir_text,'string',export_base_from_user,'foregroundcolor',[0 1 0]);
        
        setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
        setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings); 
    else
        set(handles.batch_export_button,'foregroundcolor','red');
        set(handles.export_dir_text,'foregroundcolor','red');
    end
    

    guidata(hObject, handles);

function single_movie_name_Callback(hObject, eventdata, handles)
% hObject    handle to single_movie_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of single_movie_name as text
%        str2double(get(hObject,'String')) returns contents of single_movie_name as a double


% --- Executes during object creation, after setting all properties.
function single_movie_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to single_movie_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_mult_button.
function select_mult_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_mult_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output_settings.batch_folders_fullpaths = {};
if isdir(handles.output_settings.source_base)
    cd(handles.output_settings.source_base);
    handles.output_settings.batch_folders_fullpaths = uipickfiles_DLF_mod('FilterSpec',handles.output_settings.source_base,'out','struct');
else
    handles.output_settings.batch_folders_fullpaths = uipickfiles_DLF_mod('FilterSpec',pwd,'out','struct');
end

    handles.output_settings.batch_folders_fullpaths = {handles.output_settings.batch_folders_fullpaths(:).name};
%     display(handles.output_settings.batch_folders);
if ~isempty(handles.output_settings.batch_folders_fullpaths)
    for i = 1:numel(handles.output_settings.batch_folders_fullpaths)
        tempfullpath = handles.output_settings.batch_folders_fullpaths{i};
        handles.output_settings.batch_folders{i} = fliplr(strtok(fliplr(tempfullpath),filesep));
    end
    handles.output_settings.batch_folders_out = handles.output_settings.batch_folders;
    
    set(handles.mult_movies_txt,'string',handles.output_settings.batch_folders);
    set(handles.export_names_text,'string',handles.output_settings.batch_folders_out);
    
    handles.output_settings.source_folds = handles.output_settings.batch_folders;
    handles.output_settings.destin_folds = handles.output_settings.batch_folders;
    
end
    
guidata(hObject, handles);

% --- Executes on button press in select_mult_movs.
function select_mult_movs_Callback(hObject, eventdata, handles)
% hObject    handle to select_mult_movs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this is a checkbox that is invisible



function mult_movies_txt_Callback(hObject, eventdata, handles)
% hObject    handle to mult_movies_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.output_settings.batch_folders = get(handles.mult_movies_txt,'string');
handles.output_settings.batch_folders_out = get(handles.mult_movies_txt,'string');

% --- Executes during object creation, after setting all properties.
function mult_movies_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mult_movies_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in submit.
function submit_Callback(hObject, eventdata, handles)
% hObject    handle to submit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output_settings.batch_folders = get(handles.mult_movies_txt,'string');
handles.output_settings.batch_folders_out = get(handles.export_names_text,'string');

guidata(hObject, handles);
setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings);
close(handles.figure1);

handles_in_mainGUI = getappdata(handles.calling_fun_handle,'handles_in_mainGUI');
set(handles_in_mainGUI.import_dir_txt,'string',['BATCH: ',handles.output_settings.source_base],'foregroundcolor',[1 .5 0]);
set(handles_in_mainGUI.export_dir_text,'string',['BATCH: ',handles.output_settings.destin_base],'foregroundcolor',[1 .5 0]);
set(handles_in_mainGUI.single_mov_name_imp,'string','BATCH','foregroundcolor',[1 .5 0]);
set(handles_in_mainGUI.single_mov_name_exp,'string','BATCH','foregroundcolor',[1 .5 0]);

if handles.output_settings.test_batch
    set(handles_in_mainGUI.imprt_dir,'foregroundcolor','green');
    set(handles_in_mainGUI.export_dir,'foregroundcolor','green');
end

% --- Executes on button press in test_source_dirs.
function test_source_dirs_Callback(hObject, eventdata, handles)
% hObject    handle to test_source_dirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output_settings.test_batch = false;
handles.output_settings.batch_folders = get(handles.mult_movies_txt,'string');
handles.output_settings.batch_folders_out = get(handles.export_names_text,'string');


if ~iscell(handles.output_settings.batch_folders)
    handles.output_settings.batch_folders = {handles.output_settings.batch_folders};
end

if ~isempty(handles.output_settings.batch_folders) && ...
    ~isempty(handles.output_settings.source_base)
    
    set(handles.tested_batch_folds_disp,'string',{})
    for i = 1:numel(handles.output_settings.batch_folders)
        tempfullpath = [handles.output_settings.source_base,handles.output_settings.batch_folders{i}];
        temptestdisp = get(handles.tested_batch_folds_disp,'string');
        txt_to_appnd = [handles.output_settings.batch_folders{i}];
        if isdir(tempfullpath)
            if (numel(handles.output_settings.batch_folders_out)>=i) && ~isempty(handles.output_settings.batch_folders_out{i})
                display(handles.output_settings.batch_folders_out);
                txt_to_appnd = [txt_to_appnd, '  (INPUT found) --> ',handles.output_settings.batch_folders_out{i}, '  (OUPUT confirmed)'];
                set(handles.tested_batch_folds_disp,'string',{temptestdisp{:},txt_to_appnd},'foregroundcolor','green');
                set(handles.mult_movies_txt,'foregroundcolor','green');
                set(handles.export_names_text,'foregroundcolor','green');
            else
                txt_to_appnd = [txt_to_appnd, '  (INPUT found) ->-< ', '  (missing OUTPUT name)'];
                set(handles.tested_batch_folds_disp,'string',{temptestdisp{:},txt_to_appnd},'foregroundcolor','red');
                set(handles.mult_movies_txt,'foregroundcolor','green');
                set(handles.export_names_text,'foregroundcolor','red');
            end
        else
            if (numel(handles.output_settings.batch_folders_out)>=i)
               txt_to_appnd = [txt_to_appnd, ' (INPUT NOT found) |--> ',handles.output_settings.batch_folders_out{i}, ' (OUPUT confirmed)'];
               set(handles.tested_batch_folds_disp,'string',{temptestdisp{:},txt_to_appnd},'foregroundcolor','red');
            else
                txt_to_appnd = [txt_to_appnd, ' (INPUT >NOT< found) |--| ', '  (AND missing OUTPUT name)'];
                set(handles.tested_batch_folds_disp,'string',{temptestdisp{:},txt_to_appnd},'foregroundcolor','red');
            end
            currtxt = get(handles.tested_batch_folds_disp,'string');
            set(handles.tested_batch_folds_disp,'string',{currtxt{:},'--- stopped testing after first fail ---'});
            set(handles.mult_movies_txt,'foregroundcolor','red');
            set(handles.export_names_text,'foregroundcolor','red');
           return
        end
    end
end
% if it got to this point then everything tested out okay
handles.output_settings.test_batch = true;
guidata(hObject, handles);
setappdata(handles.figure1,'output_settings_togo',handles.output_settings);
setappdata(handles.calling_fun_handle,'batch_settings_pushed',handles.output_settings); 
    


% --- Executes during object creation, after setting all properties.
function tested_batch_folds_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tested_batch_folds_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function export_names_text_Callback(hObject, eventdata, handles)
% hObject    handle to export_names_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of export_names_text as text
%        str2double(get(hObject,'String')) returns contents of export_names_text as a double


% --- Executes during object creation, after setting all properties.
function export_names_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to export_names_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
