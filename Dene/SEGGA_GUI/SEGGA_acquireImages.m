 function varargout = SEGGA_acquireImages(varargin)
% SEGGA_ACQUIREIMAGES M-file for SEGGA_acquireImages.fig
%      SEGGA_ACQUIREIMAGES, by itself, creates a new SEGGA_ACQUIREIMAGES or raises the existing
%      singleton*.
%
%      H = SEGGA_ACQUIREIMAGES returns the handle to a new SEGGA_ACQUIREIMAGES or the handle to
%      the existing singleton*.
%
%      SEGGA_ACQUIREIMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_ACQUIREIMAGES.M with the given input arguments.
%
%      SEGGA_ACQUIREIMAGES('Property','Value',...) creates a new SEGGA_ACQUIREIMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_acquireImages_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_acquireImages_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_acquireImages

% Last Modified by GUIDE v2.5 20-Jun-2016 13:31:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_acquireImages_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_acquireImages_OutputFcn, ...
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


% --- Executes just before SEGGA_acquireImages is made visible.
function SEGGA_acquireImages_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);


% defaults
%Parameters
% 1. sepBool = separate y/n
% 2. maxBool = max proj y/n
% 3. segBool = seg fold y/n
% 4. scriptsBool = script folder y/n (bug: cp permissions problem)
% 5. combinedBool = combo folder y/n
% 6. multi_settingsBool = make multi channel settings file y/n
% 7. colors_cherry = red is cherry y/n
% 8. figsBool = figures folder y/n
% 9. copy_script = copy this file to the 'destin_base' 
% 10. pe_volocityBool = does the file come from Volocity
% 11. rm_all_tog_bool = remove the tif stacks after duplicating separtes
% y/n
handles.param_pixel_size = 0.33;
handles.param_sepBool = 1;
handles.param_maxBool = 1;
handles.param_segBool = 1;
% handles.param_scriptsBool = 1;
% handles.param_combinedBool = 0;
% handles.param_multi_settingsBool = 0;
handles.param_colors_cherry = 1;
handles.param_figsBool = 1;
% handles.param_copy_script = 1;
% handles.param_pe_volocityBool = 0;
% handles.param_scripts_dir =[];
handles.param_keep_stacks = false;
handles.param_rm_all_tog_bool = true;


set(handles.pixel_size_input,'string',num2str(handles.param_pixel_size));
% set(handles.sepBool,'string',num2str(handles.param_sepBool));
% set(handles.maxBool,'string',num2str(handles.param_maxBool));
% set(handles.segBool,'string',num2str(handles.param_segBool));
% set(handles.keep_stacks,'string',num2str(handles.param_keep_stacks));
set(handles.sepBool,'value',handles.param_sepBool);
set(handles.maxBool,'value',handles.param_maxBool);
set(handles.segBool,'value',handles.param_segBool);
set(handles.keep_stacks,'value',handles.param_keep_stacks);
handles.advanced_on = get(handles.advanced_options,'Value');


% make sure all defaults exist in case they are not defined 
% during the process of selecitng settings for the transfer
% handles.params.mag = 40; % not used 
handles.params.pixel_size = 0.33;
handles.params.sepBool = 1;
handles.params.maxBool = 1;
handles.params.segBool = 1;
handles.params.scriptsBool = 0;
handles.params.combinedBool = 0;
handles.params.multi_settingsBool = 0;
handles.params.colors_cherry = 1;
handles.params.figsBool = 1;
handles.params.copy_settings = 0;
handles.params.rotation_angle = 0;
handles.params.pe_volocityBool = 0;
handles.params.scripts_dir =[];
handles.params.keep_stacks = false;
handles.params.rm_all_tog_bool = true;
handles.params.adaptMaxBool = false;
handles.params.PIVBool = false;
handles.params.showPIVelon = false;
handles.params.visualize_PIV = false;
handles.params.super_smplBool = false;
handles.params.denoisingBool = false;
handles.params.aniso_smthBool = false;

handles.params.transf_origs = true;

% % for batch processing
handles.params.batch_source_base = [];
handles.params.batch_destin_base = [];
handles.params.batch_fold_names = {};
handles.params.batch_fold_names_out = {};
handles.params.batch_on = false;

% % for single movie processing
handles.params.source_base = [];
handles.params.destin_base = [];
handles.params.fold_names = {};
handles.params.fold_names_out = {};

handles.params.source_full =[handles.params.source_base,filesep,handles.params.fold_names{:}];
handles.params.destin_full =[handles.params.destin_base,filesep,handles.params.fold_names_out{:}];

set(handles.import_dir_txt,'string','--NEED-SOURCE--','foregroundcolor',[1 0 0]);
set(handles.export_dir_text,'string','--NEED-DESTINATION--','foregroundcolor',[1 0 0]);
set(handles.single_mov_name_imp,'string',handles.params.fold_names);
set(handles.single_mov_name_exp,'string',handles.params.fold_names_out);
setappdata(handles.figure1,'t_o_bool',get(handles.transf_origs,'value'));

guidata(hObject, handles);

%%% Group some buttons together that are being difficult in the visual GUI
%%% editor
% set(handles.import_movie_static_title_txt,'Parent',handles.import_panel);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_acquireImages_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% Get default command line output from handles structure
varargout{1} = handles.output;



function def_seg_opts_filename_display_Callback(hObject, eventdata, handles)

function def_seg_opts_filename_display_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function export_dir_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

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
            t_o_bool = getappdata(handles.figure1,'t_o_bool');
            
            set(handles.export_dir,'ForegroundColor','green');
            handles.params.destin_base = destin_base;
            if t_o_bool
                handles.params.destin_full =[handles.params.destin_base,handles.params.fold_names_out{:}];
                set(handles.export_dir_text,'string',handles.params.destin_full,'foregroundcolor','green');
            else
                handles.params.destin_full = handles.params.destin_base;
                set(handles.export_dir_text,'string',handles.params.destin_full,'foregroundcolor','green');
                [a,b,~] = fileparts(handles.params.destin_full);
                if isempty(b)
                    [~,b,~] = fileparts(a);
                end
                handles.params.fold_names = {b};
                handles.params.fold_names_out = {b};
%                 set(handles.export_dir_text,'string',b);
            end
                
        end
    end
    

    guidata(hObject, handles);
    

function export_dir_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in transf.
function transf_Callback(hObject, eventdata, handles)
% hObject    handle to transf (see GCBO)

% handles.params.mag = str2num(get(handles.mag,'string'));
handles.params.sepBool = get(handles.sepBool,'value');
handles.params.maxBool = get(handles.maxBool,'value');
handles.params.segBool = get(handles.segBool,'value');
handles.params.figsBool = get(handles.figsBool,'value');
handles.params.keep_stacks = get(handles.keep_stacks,'value');
handles.params.rm_all_tog_bool = logical(1-handles.params.keep_stacks);
handles.params.transf_origs = get(handles.transf_origs,'value');

if handles.advanced_on
    if ishandle(handles.adv_handle)
%         again this only works if the window is still open
        handles = get_settings_from_advanced_gui(handles.adv_handle,hObject,handles);
    else
%         do this if that window is not open
%         params changed in the advanced GUI
%         are saved and used regardless of submitting or closing window
    handles.advanced_settings_pushed = getappdata(handles.figure1,'advanced_settings_pushed');
%   polarity stuff
    handles.params.scriptsBool = handles.advanced_settings_pushed.scriptsBool;
    handles.params.combinedBool = handles.advanced_settings_pushed.combinedBool;
    handles.params.multi_settingsBool = handles.advanced_settings_pushed.multi_settingsBool;
%   PIV stuff
    handles.params.adaptMaxBool = handles.advanced_settings_pushed.adaptMaxBool;
    handles.params.PIVBool = handles.advanced_settings_pushed.PIVBool;
    handles.params.showPIVelon = handles.advanced_settings_pushed.showPIVelon;
    handles.params.visualize_PIV = handles.advanced_settings_pushed.visualize_PIV;
%   IMG PROC stuff
    handles.params.super_smplBool = handles.advanced_settings_pushed.super_smplBool;
    handles.params.denoisingBool = handles.advanced_settings_pushed.denoisingBool;
    handles.params.aniso_smthBool = handles.advanced_settings_pushed.aniso_smthBool;
    end
else %if not checked, then removed advanced settings	
%   polarity stuff
    handles.params.scriptsBool = false;
    handles.params.combinedBool = false;
    handles.params.multi_settingsBool = false;
%   PIV stuff
    handles.params.adaptMaxBool = false;
    handles.params.PIVBool = false;
    handles.params.showPIVelon = false;
    handles.params.visualize_PIV = false;
%   IMG PROC stuff
    handles.params.super_smplBool = false;
    handles.params.denoisingBool = false;
    handles.params.aniso_smthBool = false;
    
end

handles.batch_on = get(handles.batch_import_check,'Value');
if  handles.batch_on
    if ishandle(handles.batch_handle)
%         again this only works if the window is still open
        handles = get_settings_from_batch_gui(handles.batch_handle,hObject,handles);
    else
        handles.batch_settings_pushed = getappdata(handles.figure1,'batch_settings_pushed');
        handles.params.batch_source_base = handles.batch_settings_pushed.source_base;
        handles.params.batch_destin_base = handles.batch_settings_pushed.destin_base;
        handles.params.batch_fold_names = handles.batch_settings_pushed.batch_folders;
        handles.params.batch_fold_names_out = handles.batch_settings_pushed.batch_folders_out;
        handles.params.batch_on = get(handles.batch_import_check,'Value');
        handles.params.test_batch = handles.batch_settings_pushed.test_batch;
    end
    if ~handles.params.test_batch
        msgbox('please test batch');
        display('batch not tested');
        return
    end
end

    handles.params.rotation_angle = getappdata(handles.figure1,'updated_alpha');
    params_for_action = handles.params;
    SEGGA_acquireImages_action(params_for_action);

function sepBool_Callback(hObject, eventdata, handles)
% hObject    handle to sepBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sepBool as text
%        str2double(get(hObject,'String')) returns contents of sepBool as a double


% --- Executes during object creation, after setting all properties.
function sepBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sepBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxBool_Callback(hObject, eventdata, handles)
% hObject    handle to maxBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxBool as text
%        str2double(get(hObject,'String')) returns contents of maxBool as a double


% --- Executes during object creation, after setting all properties.
function maxBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function segBool_Callback(hObject, eventdata, handles)
% hObject    handle to segBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of segBool as text
%        str2double(get(hObject,'String')) returns contents of segBool as a double


% --- Executes during object creation, after setting all properties.
function segBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function keep_stacks_Callback(hObject, eventdata, handles)

v =  get(hObject,'Value');
t_o_bool = getappdata(handles.figure1,'t_o_bool');
if ~t_o_bool && ~v
    uiwait(warndlg('Unchecking removes original tif stacks'));
end


% --- Executes during object creation, after setting all properties.
function keep_stacks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to keep_stacks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in imprt_dir.
function imprt_dir_Callback(hObject, eventdata, handles)
% hObject    handle to imprt_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, source_dir] = uigetfile( ...
    {'*.TIF','Tagged Image File (*.TIF)'; ...
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
    
    handles.params.source_base = source_dir_base;
    handles.params.fold_names = fold_names;
    handles.params.fold_names_out = fold_names;
%     set(handles.imprt_dir,'string',source_dir);

    if isdir(source_dir_base)
        handles.params.source_full = source_dir;
        
        set(handles.imprt_dir,'ForegroundColor','green');
        set(handles.import_dir_txt,'string',source_dir,'foregroundcolor',[0 1 0]);
        if ~isempty(handles.params.destin_base)
            handles.params.destin_full = [handles.params.destin_base,filesep,[handles.params.fold_names_out{:}]];
            set(handles.export_dir_text,'string',handles.params.destin_full);
        end
        
        
        set(handles.single_mov_name_imp,'string',handles.params.fold_names);
        set(handles.single_mov_name_exp,'string',handles.params.fold_names_out);
    end
    
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function imprt_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imprt_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function transf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




function figsBool_Callback(hObject, eventdata, handles)
% hObject    handle to figsBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of figsBool as text
%        str2double(get(hObject,'String')) returns contents of figsBool as a double


% --- Executes during object creation, after setting all properties.
function figsBool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figsBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in advanced_options.
function advanced_options_Callback(hObject, eventdata, handles)
% hObject    handle to advanced_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.handle_of_SEGGA_acquire = handles.figure1;
handles.advanced_on = get(handles.advanced_options,'Value');
if handles.advanced_on
%     display('advanced on');
    handles.adv_handle = SEGGA_acquireImages_advanced(handles.handle_of_SEGGA_acquire);
    %this get the advanced settings from the SEGGA_acquireImages_advanced
    %GUI, which would work fine, unless someone makes changes, and then
    %closes the app, leaving no way to extract values later    
    handles = get_settings_from_advanced_gui(handles.adv_handle,hObject,handles);
    
end


% this is the same advanced settings, but it's been pushed into this
% GUI from the advanced one, so if the advanced window is closed, this info is not lost
handles.advanced_settings_pushed = getappdata(handles.figure1,'advanced_settings_pushed');

guidata(hObject, handles);



function handles = get_settings_from_advanced_gui(handle_of_adv_gui,hObject,handles)
    mainh = handle_of_adv_gui;
    advanced_handles = getappdata(mainh,'output_settings_togo');
%   Polarity stuff
    handles.params.scriptsBool = advanced_handles.scriptsBool;
    handles.params.combinedBool = advanced_handles.combinedBool;
    handles.params.multi_settingsBool = advanced_handles.multi_settingsBool;
    
%   PIV stuff
	handles.params.adaptMaxBool = advanced_handles.adaptMaxBool;
    handles.params.PIVBool = advanced_handles.PIVBool;
    handles.params.showPIVelon = advanced_handles.showPIVelon;
    handles.params.visualize_PIV = advanced_handles.visualize_PIV;
%   IMG PROC stuff
    handles.params.super_smplBool = advanced_handles.super_smplBool;
    handles.params.denoisingBool = advanced_handles.denoisingBool;
    handles.params.aniso_smthBool = advanced_handles.aniso_smthBool;
    
    guidata(hObject, handles);
    
function handles = get_settings_from_batch_gui(handle_of_batch_gui,hObject,handles)
    
    mainh = handle_of_batch_gui;
    
    batch_handles = getappdata(mainh,'output_settings_togo');
    handles.params.batch_source_base = batch_handles.source_base;
    handles.params.batch_destin_base = batch_handles.destin_base;
    handles.params.batch_source_folds = batch_handles.source_folds;
    handles.params.batch_destin_folds = batch_handles.destin_folds;
    handles.params.batch_fold_names = batch_handles.batch_folders;
    handles.params.batch_fold_names_out = batch_handles.batch_folders_out;
    handles.params.test_batch = batch_handles.test_batch;
    guidata(hObject, handles);
   

function timestep_Callback(hObject, eventdata, handles)
% hObject    handle to timestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timestep as text
%        str2double(get(hObject,'String')) returns contents of timestep as a double
handles.params.timestep = str2num(get(handles.timestep,'string'));
timestep = handles.params.timestep;
% save('timestep','timestep');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function timestep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transf_origs_Callback(hObject, eventdata, handles)
% contents = get(hObject,'String');
t_o_bool = get(hObject,'Value');
setappdata(handles.figure1,'t_o_bool',t_o_bool);
handles.params.transf_origs = false;
set_interface_functionality(t_o_bool, handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function transf_origs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transf_origs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function single_mov_name_imp_Callback(hObject, eventdata, handles)
% hObject    handle to single_mov_name_imp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of single_mov_name_imp as text
%        str2double(get(hObject,'String')) returns contents of single_mov_name_imp as a double
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function single_mov_name_imp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to single_mov_name_imp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function export_dir_text_Callback(hObject, eventdata, handles)
% hObject    handle to export_dir_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of export_dir_text as text
%        str2double(get(hObject,'String')) returns contents of export_dir_text as a double

        destin_full = get(handles.export_dir_text,'string');
        destin_full = [destin_full,filesep];
        
        fold_names_out = {fliplr(strtok(fliplr(destin_full),filesep))};
        [~, d] = strtok(fliplr(destin_full),filesep);
        destin_base = fliplr(d);

        if ~isdir(destin_base)
            h = msgbox(['The directory ','''',destin_base(1:(end-1)),'''','does not exist']);
            set(handles.export_dir,'ForegroundColor','red');
            set(handles.export_dir_text,'ForegroundColor','red');
            set(handles.single_mov_name_exp,'ForegroundColor','red');
            error('The directory %s does not exist', destin_base(1:(end-1)));

            handles.params.destin_base = [];
            handles.params.destin_full = [];
            return;
        else
            handles.params.fold_names_out = {fliplr(strtok(fliplr(destin_full),filesep))};
            [~, d] = strtok(fliplr(destin_full),filesep);
            destin_base = fliplr(d);
            set(handles.export_dir,'ForegroundColor','green');
            set(handles.export_dir_text,'ForegroundColor','green');
            handles.params.destin_base = destin_base;
            handles.params.destin_full = destin_full;
            set(handles.export_dir_text,'ForegroundColor','green');
            set(handles.single_mov_name_exp,'string',handles.params.fold_names_out,'ForegroundColor','green');
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



function import_dir_txt_Callback(hObject, eventdata, handles)
% hObject    handle to import_dir_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of import_dir_txt as text
%        str2double(get(hObject,'String')) returns contents of import_dir_txt as a double
        
        handles.params.source_full = get(handles.import_dir_txt,'string'); 
        if ~isdir(handles.params.source_full)
            set(handles.imprt_dir,'ForegroundColor','red');
            set(handles.import_dir_txt,'ForegroundColor','red');
            set(handles.single_mov_name_imp,'ForegroundColor','red');
            h = msgbox(['The directory:  ','''',handles.params.source_full,'''', '  does not exist']);
            error('The directory %s does not exist', handles.params.source_full);
            handles.params.source_base = [];
            handles.params.source_full = [];
            return
        else if isempty(dir([handles.params.source_full,filesep,'*TIF'])) &&...
                    isempty(dir([source_dir_full,'*tif']))
                    h = msgbox(['No tif files found in ', '''',source_dir_full,'''']);
                    error('No TIF and no tif files found in dir: \n %s', handles.params.source_full);
                    handles.params.source_base = [];
                    handles.params.fold_names = {};
                    set(handles.imprt_dir,'ForegroundColor','red');
            else
                    fold_names = {fliplr(strtok(fliplr(handles.params.source_full),filesep))};
                    [~, d] = strtok(fliplr(handles.params.source_full),filesep);
                    source_base = fliplr(d);
                    handles.params.source_base = source_base;
                    handles.params.source_full = [source_base,[fold_names{:}]];
                    handles.params.fold_names_out = fold_names;
                    handles.params.destin_full = [handles.params.destin_base,[fold_names{:}]];
                    set(handles.imprt_dir,'ForegroundColor','green');
                    set(handles.single_mov_name_imp,'string',fold_names,'ForegroundColor','white');
                    set(handles.import_dir_txt,'ForegroundColor','green');
                    set(handles.export_dir_text,'string',handles.params.destin_full);
                    set(handles.single_mov_name_exp,'string',fold_names);
                    
            end
        end

% --- Executes during object creation, after setting all properties.
function import_dir_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to import_dir_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function single_mov_name_exp_Callback(hObject, eventdata, handles)
% hObject    handle to single_mov_name_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of single_mov_name_exp as text
%        str2double(get(hObject,'String')) returns contents of single_mov_name_exp as a double
        new_fold_out = get(handles.single_mov_name_exp,'string');
        handles.params.fold_names_out = new_fold_out;
        
        if ~isempty(handles.params.destin_base)
            destin_full = [handles.params.destin_base,[new_fold_out{:}]];
            [~, d] = strtok(fliplr(destin_full),filesep);
            destin_base = fliplr(d);
    
            if ~isdir(destin_base)
                h = msgbox('The directory %s does not exist', destin_base);
                error('The directory %s does not exist', destin_base);
                set(handles.export_dir,'ForegroundColor','red');
                handles.params.destin_base = [];
                return;
            else
                set(handles.export_dir,'ForegroundColor','green');
                handles.params.destin_base = destin_base;
                handles.params.destin_full = [handles.params.destin_base,new_fold_out,filesep];
                set(handles.export_dir_text,'string',handles.params.destin_full,'ForegroundColor','green');
            end
        end

 
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function single_mov_name_exp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to single_mov_name_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in batch_import_check.
function batch_import_check_Callback(hObject, eventdata, handles)
% hObject    handle to batch_import_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% create a variable with all directory info to pass to the batch GUI
IO_dirs_set_in_mainGUI.source_full = handles.params.source_full;
IO_dirs_set_in_mainGUI.source_base = handles.params.source_base;
IO_dirs_set_in_mainGUI.fold_names = handles.params.fold_names;
IO_dirs_set_in_mainGUI.destin_full = handles.params.destin_full;
IO_dirs_set_in_mainGUI.destin_base = handles.params.destin_base;
IO_dirs_set_in_mainGUI.fold_names_out = handles.params.fold_names_out;

setappdata(handles.figure1,'IO_dirs_set_in_mainGUI',IO_dirs_set_in_mainGUI);

handles_in_mainGUI.import_dir_txt = handles.import_dir_txt;
handles_in_mainGUI.export_dir_text = handles.export_dir_text;
handles_in_mainGUI.single_mov_name_imp = handles.single_mov_name_imp;
handles_in_mainGUI.single_mov_name_exp = handles.single_mov_name_exp;
handles_in_mainGUI.imprt_dir = handles.imprt_dir;
handles_in_mainGUI.export_dir = handles.export_dir;
setappdata(handles.figure1,'handles_in_mainGUI',handles_in_mainGUI);

handles.handle_of_SEGGA_acquire = handles.figure1;
handles.batch_on = get(handles.batch_import_check,'Value');


%     if batch is checked then load new batch info
if handles.batch_on
%     display('batch on');

    handles.batch_handle = SEGGA_acquire_batch(handles.handle_of_SEGGA_acquire);  
    handles = get_settings_from_batch_gui(handles.batch_handle,hObject,handles);
    handles.params.batch_on = true;

    
    %reload old info if 'batch' is unchecked
else
    handles.params.batch_on = false;
    if ~isempty(handles.params.source_base) &&...
            ~isempty(handles.params.fold_names) &&...
            isdir([handles.params.source_base,[handles.params.fold_names{:}]])
        handles.params.source_full = [handles.params.source_base,[handles.params.fold_names{:}]];
        set(handles.import_dir_txt,'string',handles.params.source_full,'foregroundcolor','green');
        set(handles.single_mov_name_imp,'string',[handles.params.fold_names{:}],'foregroundcolor','white');
        handles.params.fold_names_out = handles.params.fold_names;
        
        if ~isempty(handles.params.destin_base) &&...
            ~isempty(handles.params.fold_names) &&...
            isdir([handles.params.destin_base])
            handles.params.destin_full = [handles.params.destin_base,[handles.params.fold_names{:}]];
            set(handles.export_dir_text,'string',handles.params.destin_full,'foregroundcolor','green');
            set(handles.single_mov_name_exp,'string',[handles.params.fold_names{:}],'foregroundcolor','white');
        else
            set(handles.export_dir_text,'string','--NEED-DESTINATION--','foregroundcolor','red');
            set(handles.single_mov_name_exp,'string',{''},'foregroundcolor','white');
            
            handles.params.destin_base = [];
            handles.params.fold_names_out = {};
            
        end
    else
        set(handles.import_dir_txt,'string','--NEED-SOURCE--','foregroundcolor','red');
        set(handles.single_mov_name_imp,'string',{''},'foregroundcolor','white');
        set(handles.export_dir_text,'string','--NEED-DESTINATION--','foregroundcolor','red');
        set(handles.single_mov_name_exp,'string',{''},'foregroundcolor','white');
        
        handles.params.source_base = [];
        handles.params.destin_base = [];
        handles.params.fold_names = {};
        handles.params.fold_names_out = {};
    end
    
end




% this is the same batch settings, but it's been pushed into this
% GUI from the batch one, so if the batch window is closed, this info is not lost
handles.batch_settings_pushed = getappdata(handles.figure1,'batch_settings_pushed');

guidata(hObject, handles);



function pixel_size_input_Callback(hObject, eventdata, handles)
% hObject    handle to pixel_size_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixel_size_input as text
%        str2double(get(hObject,'String')) returns contents of pixel_size_input as a double


% --- Executes during object creation, after setting all properties.
function pixel_size_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_size_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotation_input_Callback(hObject, eventdata, handles)
% hObject    handle to rotation_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotation_input as text
%        str2double(get(hObject,'String')) returns contents of rotation_input as a double


% --- Executes during object creation, after setting all properties.
function rotation_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotation_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in view_rotation.
function view_rotation_Callback(hObject, eventdata, handles)
% hObject    handle to view_rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.batch_on = get(handles.batch_import_check,'Value');
if  handles.batch_on
    display('cannot rotate in batch mode');
    return
else

    
    t_o_bool = getappdata(handles.figure1,'t_o_bool');
    if t_o_bool
        import_dir = [handles.params.source_base,filesep,handles.params.fold_names{1}];
        testfile = dir([import_dir,filesep,'*','.tif']);
        display(testfile);
        if isempty(testfile)
            testfile = dir([import_dir,filesep,'*','.TIF']);
        end
        if isempty(testfile)
            display(['no tifs found in ',import_dir]);
        end
        f = [import_dir,filesep,testfile(1).name];
    else
        ex_list = {'.','..','.DS_Store','seg'};
        tmp_fun = @(x) ~(any(strcmp(x,ex_list)));
        all_dirs = dir(handles.export_dir_text.String);
        inds = logical([all_dirs.isdir]) & logical(cellfun(tmp_fun,{all_dirs(:).name}));
        
        if isempty(all_dirs(inds))
            display(['no possible originals folder found under ',handles.export_dir_text.String]);
        else
            possible_dirs = all_dirs(inds);
            import_dir = [handles.export_dir_text.String,filesep,possible_dirs(1).name];
            new_subs = dir(import_dir);
            tmp_fun = @(x) ~(any(strcmp(x,'all_layers_together')));
            if any(cellfun(tmp_fun,{new_subs(:).name}))
                import_dir = [import_dir,filesep,'all_layers_together',filesep];
            end
            
            testfile = dir([import_dir,filesep,'*','.tif']);
            display(testfile);
            if isempty(testfile)
                testfile = dir([import_dir,filesep,'*','.TIF']);
            end
        end
        if isempty(testfile)
            display(['no tifs found in ',import_dir]);
            msgbox(['no tifs found in ',import_dir]);
            return
        end
        f = [import_dir,filesep,testfile(1).name];
    end

    img = read_tif_fast(f,'uint8');    
    updated_alpha = handles.params.rotation_angle;
    rotH = SEGGA_rotation_interface;
    calling_fig = handles.figure1;
    setappdata(rotH,'rot_ang',handles.params.rotation_angle);
    setappdata(rotH,'z',1);
    setappdata(rotH,'img',img);
    setappdata(rotH,'calling_fig',calling_fig);
    setappdata(rotH,'calling_fig_rot_txt_handle',handles.rotation_input);
    rotHandles = guidata(rotH);
    set(rotHandles.z_slider,'Min',1,'Max',size(img,3),'SliderStep',[1/(size(img,3)-1),5/(size(img,3)-1)]);
	set(rotHandles.rot_slider,'Min',0,'Max',360,'SliderStep',[1/360,10/360]);    
    update_rotation_interface(rotHandles);
    uiwait(rotH);
    handles.params.rotation_angle = getappdata(handles.figure1,'updated_alpha');
    set(handles.rotation_input,'string',num2str(handles.params.rotation_angle));
    guidata(hObject, handles);
    
end


function set_interface_functionality(t_o_bool,handles)
setappdata(handles.figure1,'t_o_bool',t_o_bool);

if t_o_bool
    set(handles.import_panel,'visible','on');
    handles.export_panel.Title = 'Export';
    handles.action_dir_txt_one.String = 'dir to receive export';
    handles.export_dir.String = 'export dir (one above movie)';
    handles.export_name_static_txt.Visible = 'on';
    handles.single_mov_name_exp.Visible = 'on';
    handles.keep_stacks.Value = false;
    handles.param_keep_stacks = false;
else
    set(handles.import_panel,'visible','off');
    handles.export_panel.Title = 'Action Dir';
    handles.action_dir_txt_one.String = 'Manually Prepared Directory';
    handles.export_dir.String = 'export dir (movie name)';
    handles.export_name_static_txt.Visible = 'off';
    handles.single_mov_name_exp.Visible = 'off';
    handles.keep_stacks.Value = true;
    handles.param_keep_stacks = true;
end
