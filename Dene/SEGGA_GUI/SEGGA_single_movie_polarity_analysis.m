function varargout = SEGGA_single_movie_polarity_analysis(varargin)
% SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS MATLAB code for SEGGA_single_movie_polarity_analysis.fig
%      SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS, by itself, creates a new SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS or raises the existing
%      singleton*.
%
%      H = SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS returns the handle to a new SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS or the handle to
%      the existing singleton*.
%
%      SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS.M with the given input arguments.
%
%      SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS('Property','Value',...) creates a new SEGGA_SINGLE_MOVIE_POLARITY_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_single_movie_polarity_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_single_movie_polarity_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_single_movie_polarity_analysis

% Last Modified by GUIDE v2.5 09-Sep-2015 14:35:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_single_movie_polarity_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_single_movie_polarity_analysis_OutputFcn, ...
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


% --- Executes just before SEGGA_single_movie_polarity_analysis is made visible.
function SEGGA_single_movie_polarity_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_single_movie_polarity_analysis (see VARARGIN)

% Choose default command line output for SEGGA_single_movie_polarity_analysis
handles.output = hObject;
set(handles.curr_dir_disp_txt,'string',pwd);
handles.params.channel_info = [];
handles.params.options = [];
handles.params.analysis_type = 'basic';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SEGGA_single_movie_polarity_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_single_movie_polarity_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chan2_check.
function chan2_check_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chan2_check
chan2check_bool = get(hObject,'Value');
if chan2check_bool

   
[filename, source_dir] = uigetfile( ...
    {'*.TIF','Tagged Image File (*.TIF)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');

if filename==0
    display('no file selected');
    set(hObject,'value',false);
    return
end

    handles.params.channel_info(2).filename = fullfile(source_dir,filename);
    
    set(handles.chan2_file_text,'visible','on');
    set(handles.chan2_dir_text,'visible','on');
    set(handles.chan2_marker_name,'visible','on');
    set(handles.chan2_label,'visible','on');
    set(handles.chan3_check,'visible','on');




    set(handles.chan2_dir_text,'string',source_dir);
    set(handles.chan2_file_text,'string',filename);
    
    prompt = {'chan two (e.g. ecad):'};
    name = 'Name of Protein for Channel Two Image';
    numlines = 1;
    defaultanswer = {''};
    name_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.chan2_marker_name,'string',name_out);
    handles.params.channel_info(2).name = name_out{:};
    
    
	prompt = {'label (e.g. gfp):'};
    name = 'Name of Fluorophore for Channel Two Image';
    numlines = 1;
    defaultanswer = {''};
    label_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.chan2_label,'string',label_out);
    handles.params.channel_info(2).marker_type = label_out{:};

    
else
    set(handles.chan2_file_text,'visible','off');
    set(handles.chan2_dir_text,'visible','off');
	set(handles.chan2_marker_name,'visible','off');
    set(handles.chan2_label,'visible','off');
    set(handles.chan3_check,'visible','on');
    
%     clean up channel info
    len_chaninfo = length(handles.params.channel_info);
    if len_chaninfo > 1
        handles.params.channel_info(2:len_chaninfo) = [];
    end
            
end
guidata(hObject, handles);

% --- Executes on button press in chan3_check.
function chan3_check_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chan3_check
chan3check_bool = get(hObject,'Value');
if chan3check_bool

    
    
[filename, source_dir] = uigetfile( ...
    {'*.TIF','Tagged Image File (*.TIF)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');
if  filename==0
    display('no file selected');
    set(hObject,'value',false);
    return
end
    handles.params.channel_info(3).filename = fullfile(source_dir,filename);
    
    set(handles.chan3_file_text,'visible','on');
    set(handles.chan3_dir_text,'visible','on');
	set(handles.chan3_marker_name,'visible','on');
    set(handles.chan3_label,'visible','on');

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
    
    handles.params.chan3_base = source_dir_base;
    handles.params.chan3_fold_names = fold_names;
    handles.params.chan3_filename = filename;


    if isdir(source_dir_base)
        set(handles.chan3_dir_text,'string',source_dir);
        set(handles.chan3_file_text,'string',filename);
    end
    
    prompt = {'chan three (e.g. ecad):'};
    name = 'Name of Protein for Channel Three Image';
    numlines = 1;
    defaultanswer = {''};
    name_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.chan3_marker_name,'string',name_out);
    handles.params.channel_info(3).name = name_out{:};
    
    
	prompt = {'label (e.g. gfp):'};
    name = 'Name of Fluorophore for Channel Three Image';
    numlines = 1;
    defaultanswer = {''};
    label_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.chan3_label,'string',label_out);
    handles.params.channel_info(3).marker_type = label_out{:};
    
else
    set(handles.chan3_file_text,'visible','off');
    set(handles.chan3_dir_text,'visible','off');
	set(handles.chan3_marker_name,'visible','off');
    set(handles.chan3_label,'visible','off');
    
    %     clean up channel info
    len_chaninfo = length(handles.params.channel_info);
    if len_chaninfo > 2
        handles.params.channel_info(len_chaninfo) = [];
    end
end
guidata(hObject, handles);

% --- Executes on button press in seg_file_button.
function seg_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to seg_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, source_dir] = uigetfile( ...
    {'*.TIF','Tagged Image File (*.TIF)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');

[~, d] = strtok(fliplr(source_dir),filesep);
source_dir_base = fliplr(d);


    
    handles.params.seg_img_base_dir = source_dir;
    handles.params.seg_filename = filename;


    if isdir(source_dir_base)
        set(handles.seg_dir_text,'string',source_dir);
        set(handles.seg_filename_text,'string',filename);
        set(handles.seg_dir_text,'visible','on');
        set(handles.seg_filename_text,'visible','on');
        set(handles.seg_dir_column_text,'visible','on');
        set(handles.seg_file_column_text,'visible','on');
    end
    
%     prompt = {'seg proj protein (e.g. ecad):'};
%     name = 'Name of Protein for Seg Image';
%     numlines = 1;
%     defaultanswer = {''};
%     name_out=inputdlg(prompt,name,numlines,defaultanswer);
%     
%     set(handles.seg_marker_name,'string',name_out);
%     display('seg marker info not currently used for analysis');
%     
%     
% 	prompt = {'label (e.g. gfp):'};
%     name = 'Name of Fluorophore for Seg Image';
%     numlines = 1;
%     defaultanswer = {''};
%     label_out=inputdlg(prompt,name,numlines,defaultanswer);
%     
%     set(handles.seg_label,'string',label_out);
%     display('seg label info not currently used for analysis');
    
    guidata(hObject, handles);

% --- Executes on button press in select_working_dir_button.
function select_working_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_working_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[analysis_action_dir] = uigetdir(...
     pwd,...
    'Select a Dir to Analyze');
    if analysis_action_dir == 0
        display('no dir selected')
        return
    end
    if isdir(analysis_action_dir)
        cd(analysis_action_dir);
        set(handles.curr_dir_disp_txt,'string',analysis_action_dir);
        handles.params.base_dir = get(handles.curr_dir_disp_txt,'string');
    else
        display([analysis_action_dir,' is not a directory']);
    end

    guidata(hObject, handles);

% --- Executes on button press in unique_z_shift_checkbox.
function unique_z_shift_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to unique_z_shift_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unique_z_shift_bool = get(hObject,'Value');
if unique_z_shift_bool

   
    [filename, source_dir] = uigetfile( ...
        {'*.txt','Text File (*.txt)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select a z_shift.txt File', ...
        'MultiSelect', 'on');

    if filename==0
        display('no file selected');
        set(hObject,'value',false);
        return
    end

    set(handles.z_shift_filename_txt,'visible','on');
    set(handles.start_z_for_unique_shift_help,'visible','on');
    set(handles.start_z_for_unique_shift_checkbox,'visible','on');
    set(handles.start_z_for_unique_z_shift_input,'visible','on');
    
    set(handles.use_z_from_seg_checkbox,'value',false);
    set(handles.shift_from_seg_help,'visible','off');
    set(handles.shift_from_seg_checkbox,'visible','off');
    set(handles.shift_from_seg_input,'visible','off');
    
    set(handles.const_z_shift_quant_checkbox,'value',false);
    set(handles.const_z_for_t_input,'visible','off');

% [~, d] = strtok(fliplr(source_dir),filesep);
% source_dir_base = fliplr(d);


    
    
    handles.params.options.z_shift_file = fullfile(source_dir,filename);

    if isdir(source_dir)
        set(handles.z_shift_filename_txt,'string',handles.params.options.z_shift_file);
    end
    
	prompt = {'starting z for unique shift:'};
    name = 'starting z for unique shift';
    numlines = 1;
    defaultanswer = {''};
    starting_z_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.start_z_for_unique_z_shift_input,'string',starting_z_out{:});
    handles.params.options.const_z_shift = str2num(starting_z_out{:});
    
    if isfield(handles.params.options,'constant_z_for_t')
        handles.params.options = rmfield(handles.params.options,'constant_z_for_t');
    end
    
else
    set(handles.z_shift_filename_txt,'visible','off');
    set(handles.start_z_for_unique_shift_help,'visible','off');
    set(handles.start_z_for_unique_shift_checkbox,'visible','off');
    set(handles.start_z_for_unique_z_shift_input,'visible','off');
	if isfield(handles.params.options,'const_z_shift')
        handles.params.options = rmfield(handles.params.options,'const_z_shift');
    end
end
guidata(hObject, handles);


% --- Executes on button press in const_z_shift_quant_checkbox.
function const_z_shift_quant_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to const_z_shift_quant_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


const_z_shift_quant_bool = get(hObject,'Value');
if const_z_shift_quant_bool

    set(handles.z_shift_filename_txt,'visible','off');
    set(handles.start_z_for_unique_shift_help,'visible','off');
    set(handles.start_z_for_unique_shift_checkbox,'visible','off');
    set(handles.start_z_for_unique_z_shift_input,'visible','off');
    set(handles.unique_z_shift_checkbox,'value',false);
    

    set(handles.shift_from_seg_help,'visible','off');
    set(handles.shift_from_seg_checkbox,'visible','off');
    set(handles.shift_from_seg_input,'visible','off');
    set(handles.use_z_from_seg_checkbox,'value',false);
    
    
    set(handles.const_z_for_t_input,'visible','on');
    
    if isfield(handles.params, 'options') && isfield(handles.params.options,'z_shift_file');
        handles.params.options = rmfield(handles.params.options,'z_shift_file');
    end
    
    if isfield(handles.params, 'const_z_shift') && isfield(handles.params.options, 'const_z_shift');
        handles.params.options = rmfield(handles.params.options,'const_z_shift');
    end
    

	prompt = {'constant z for t:'};
    name = 'constant z:';
    numlines = 1;
    defaultanswer = {''};
    const_z_out=inputdlg(prompt,name,numlines,defaultanswer);
    if isempty(const_z_out)
        display('no z selected');
        set(handles.const_z_for_t_input,'visible','off');
        set(handles.const_z_shift_quant_checkbox,'value',false);
        guidata(hObject, handles);
        return
    end
        
    set(handles.const_z_for_t_input,'string',const_z_out{:});
    handles.params.options.const_z_for_t = str2num(const_z_out{:});
    
    
else

    handles.params.options.const_z_for_t = false;
	set(handles.const_z_for_t_input,'visible','off');
end
guidata(hObject, handles);


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
guidata(hObject, handles);


% --- Executes on button press in const_z_seg_button.
function const_z_seg_button_Callback(hObject, eventdata, handles)
% hObject    handle to const_z_seg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tempbool = get(hObject,'Value');
if tempbool
    set(handles.const_z_seg_input,'visible','on');
    
	prompt = {'z level:'};
    name = 'Constant Z for seg images';
    numlines = 1;
    defaultanswer = {'1'};
    z_out=inputdlg(prompt,name,numlines,defaultanswer);
    
    
    if isempty(z_out)
        set(handles.const_z_seg_input,'string','undefined');
        handles.params.options.const_z_seg = false;
    else
        set(handles.const_z_seg_input,'string',z_out);
        handles.params.options.const_z_seg = str2double(z_out{:});
    end
        
    
else
    set(handles.const_z_seg_input,'visible','off');
    handles.params.options.const_z_seg = false;
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of const_z_seg_button


% --- Executes on button press in chan1_button.
function chan1_button_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, source_dir] = uigetfile( ...
    {'*.TIF','Tagged Image File (*.TIF)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');

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
    
%     handles.params.chan1_base = source_dir_base;
%     handles.params.chan1_fold_names = fold_names;
%     handles.params.chan1_filename = filename;

    handles.params.channel_info(1).filename = fullfile(source_dir,filename);
    display(handles.params.channel_info(1).filename);
    

    set(handles.chan1_dir_text,'string',source_dir);
    set(handles.chan1_file_text,'string',filename);
	set(handles.chan1_dir_text,'visible','on');
    set(handles.chan1_file_text,'visible','on');
    set(handles.chan2_check,'visible','on');
    
    set(handles.chan_dir_column_text,'visible','on');
    set(handles.chan_file_column_text,'visible','on');
    set(handles.chan_name_column_text,'visible','on');
    set(handles.chan_label_column_text,'visible','on');

    set(handles.chan1_marker_name,'visible','on');
    set(handles.chan1_label,'visible','on');
    
    prompt = {'chan one (e.g. ecad):'};
    name = 'Name of Protein for Channel One Image';
    numlines = 1;
    defaultanswer = {''};
    name_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.chan1_marker_name,'string',name_out);
    handles.params.channel_info(1).name = name_out{:};
    
    
	prompt = {'label (e.g. gfp):'};
    name = 'Name of Fluorophore for Channel One Image';
    numlines = 1;
    defaultanswer = {''};
    label_out=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.chan1_label,'string',label_out);
    handles.params.channel_info(1).marker_type = label_out{:};
        

    
    guidata(hObject, handles);


% --- Executes on button press in select_seg_help.
function select_seg_help_Callback(hObject, eventdata, handles)
% hObject    handle to select_seg_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Choose a representative segmentation optimization image file\n',...
            'to optimize edge positions with.']);
titlestring = 'explain Seg Files selection';
msgbox(msgstring,titlestring);

% --- Executes on button press in chan_one_select_help.
function chan_one_select_help_Callback(hObject, eventdata, handles)
% hObject    handle to chan_one_select_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Choose a representative maximum projection for the channel being analyzed.\n',...
            'Then give the name of the protein that is labeled and the fluorophore used to label it.\n\n']);
titlestring = 'explain Channel Quant Files selection';
msgbox(msgstring,titlestring);

% --- Executes on button press in seg_settings_help.
function seg_settings_help_Callback(hObject, eventdata, handles)
% hObject    handle to seg_settings_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['''Seg Img Files'' are the images used to optimize edges of the segmentation.\n',...
            'These can be the same projections used for manual corrections, or a different set of images\n\n',...
            'Segmentation files (.mat) are automatically loaded from the selected directory.\n']);
titlestring = 'explain Seg Files';
msgbox(msgstring,titlestring);

% --- Executes on button press in quant_proj_settings_help.
function quant_proj_settings_help_Callback(hObject, eventdata, handles)
% hObject    handle to quant_proj_settings_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['This panel specifies channels to which the polarity analysis is applied.\n\n',...
            'The intensity of edges for each channel will be taken from these images.\n\n',...
            '\n']);
titlestring = 'explain Quant Projections';
msgbox(msgstring,titlestring);

% --- Executes on button press in const_z_seg_help.
function const_z_seg_help_Callback(hObject, eventdata, handles)
% hObject    handle to const_z_seg_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Use this option if you want to adjust edges to an image on a plane that is different from the segmentation files.\n\n',...
            'You can specify the z plane that all images are in (constant z for all t).']);
titlestring = 'explain constant z for seg';
msgbox(msgstring,titlestring);

% --- Executes on button press in unique_z_shift_help.
function unique_z_shift_help_Callback(hObject, eventdata, handles)
% hObject    handle to unique_z_shift_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Use this option if all of the quant projections \n',...
                     'follow a z_shift that differs from that of  \n',...
                     'the segmentation. \n\n',...
                     'Specify the z layer that the images start on.']);
titlestring = 'explain unique z shift';
msgbox(msgstring,titlestring);

% --- Executes on button press in start_z_for_unique_shift_checkbox.
function start_z_for_unique_shift_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to start_z_for_unique_shift_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of start_z_for_unique_shift_checkbox



function start_z_for_unique_z_shift_input_Callback(hObject, eventdata, handles)
% hObject    handle to start_z_for_unique_z_shift_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.options.const_z_shift = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of start_z_for_unique_z_shift_input as text
%        str2double(get(hObject,'String')) returns contents of start_z_for_unique_z_shift_input as a double


% --- Executes during object creation, after setting all properties.
function start_z_for_unique_z_shift_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_z_for_unique_z_shift_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start_z_for_unique_shift_help.
function start_z_for_unique_shift_help_Callback(hObject, eventdata, handles)
% hObject    handle to start_z_for_unique_shift_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Enter the z layer that the projections for quants start on.']);
titlestring = 'explain start z for unique z_shift';
msgbox(msgstring,titlestring);

% --- Executes on button press in constant_z_help.
function constant_z_help_Callback(hObject, eventdata, handles)
% hObject    handle to constant_z_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Use this option if all channels are projected to a constant z plane \n',...
                     '(regardless of the segmentation z shift).']);
titlestring = 'explain constant z';
msgbox(msgstring,titlestring);


function const_z_shift_input_Callback(hObject, eventdata, handles)
% hObject    handle to const_z_shift_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of const_z_shift_input as text
%        str2double(get(hObject,'String')) returns contents of const_z_shift_input as a double


% --- Executes during object creation, after setting all properties.
function const_z_shift_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to const_z_shift_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_z_from_seg_checkbox.
function use_z_from_seg_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_z_from_seg_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

use_z_shift_from_seg_bool = get(hObject,'Value');
if use_z_shift_from_seg_bool

    set(handles.z_shift_filename_txt,'visible','off');
    set(handles.start_z_for_unique_shift_help,'visible','off');
    set(handles.start_z_for_unique_shift_checkbox,'visible','off');
    set(handles.start_z_for_unique_z_shift_input,'visible','off');
    set(handles.unique_z_shift_checkbox,'value',false);
    

    set(handles.shift_from_seg_help,'visible','on');
    set(handles.shift_from_seg_checkbox,'visible','on');
    set(handles.shift_from_seg_input,'visible','on');
    
    set(handles.const_z_shift_quant_checkbox,'value',false);
    set(handles.const_z_for_t_input,'visible','off');
    
    if isfield(handles.params,'options')&& isfield(handles.params.options,'z_shift_file');
        handles.params.options = rmfield(handles.params.options,'z_shift_file');
    end
    
    if isfield(handles.params,'options')&& isfield(handles.params.options,'constant_z_for_t');
        handles.params.options = rmfield(handles.params.options,'constant_z_for_t');
    end

    
else
	set(handles.shift_from_seg_help,'visible','off');
    set(handles.shift_from_seg_checkbox,'visible','off');
    set(handles.shift_from_seg_input,'visible','off');
end
guidata(hObject, handles);

% --- Executes on button press in z_shift_from_seg_help.
function z_shift_from_seg_help_Callback(hObject, eventdata, handles)
% hObject    handle to z_shift_from_seg_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Use this option if the z_shift of the projections \n',...
                      'of the channels being analyzed follows the segmentation. \n\n',...
                      'A constant difference in the z planes can be accounted for.']);
titlestring = 'explain using z shift from segmentation';
msgbox(msgstring,titlestring);


function shift_from_seg_input_Callback(hObject, eventdata, handles)
% hObject    handle to shift_from_seg_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.options.const_z_shift = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function shift_from_seg_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_from_seg_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shift_from_seg_help.
function shift_from_seg_help_Callback(hObject, eventdata, handles)
% hObject    handle to shift_from_seg_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['A constant difference in the z planes can be accounted for here. \n',...
                    'positive and negative integers can be given as input.']);
titlestring = 'explain additional constant shift';
msgbox(msgstring,titlestring);

% --- Executes on button press in run_from_scratch.
function run_from_scratch_Callback(hObject, eventdata, handles)
% hObject    handle to run_from_scratch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.params.previous_savename = [];
handles.params.load_existing = false;
display(handles.params);
SEGGA_run_pol_analysis(handles.params);

% --- Executes on button press in re_run_load_edges.
function re_run_load_edges_Callback(hObject, eventdata, handles)
% hObject    handle to re_run_load_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, source_dir] = uigetfile( ...
    {'*.mat','Matlab File (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select Previous Run Data to Load', ...
    'MultiSelect', 'on');
if ~isempty(filename)
    handles.params.previous_savename = filename;
    handles.params.load_existing = true;
else
    display('no file selected');
    return
end
guidata(hObject, handles);
display(handles.params);
SEGGA_run_pol_analysis(handles.params);





% --- Executes on button press in run_help.
function run_help_Callback(hObject, eventdata, handles)
% hObject    handle to run_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Run the analysis from scratch.']);
titlestring = 'explain Run';
msgbox(msgstring,titlestring);


% --- Executes on button press in re_run_help.
function re_run_help_Callback(hObject, eventdata, handles)
% hObject    handle to re_run_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Run the analysis using the edge positions already calculated. \n',...
                     'Use new projections for measuring edge intensities, but using the same edge positions. \n',...
                     '(need to locate file of previous polarity analysis)']);
titlestring = 'explain re-Run';
msgbox(msgstring,titlestring);

% --- Executes on button press in show_help_checkbox.
function show_help_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_help_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tempbool = get(hObject,'Value');
if tempbool
    set(handles.seg_settings_help , 'visible','on');
    set(handles.quant_proj_settings_help , 'visible','on');
    set(handles.select_seg_help , 'visible','on');
    set(handles.basedir_settings_help , 'visible','on');
    set(handles.const_z_seg_help , 'visible','on');
    set(handles.chan_one_select_help , 'visible','on');
    set(handles.unique_z_shift_help , 'visible','on');
    set(handles.z_shift_from_seg_help , 'visible','on');
    set(handles.constant_z_help , 'visible','on');
    set(handles.run_help,'visible','on');
    set(handles.re_run_help,'visible','on');
%     set(handles.help_gradient_method,'visible','on');
else
	set(handles.seg_settings_help , 'visible','off');
    set(handles.quant_proj_settings_help , 'visible','off');
    set(handles.select_seg_help , 'visible','off');
    set(handles.basedir_settings_help , 'visible','off');
    set(handles.const_z_seg_help , 'visible','off');
    set(handles.chan_one_select_help , 'visible','off');
    set(handles.unique_z_shift_help , 'visible','off');
    set(handles.z_shift_from_seg_help , 'visible','off');
    set(handles.constant_z_help , 'visible','off');
	set(handles.run_help,'visible','off');
    set(handles.re_run_help,'visible','off');
%     set(handles.help_gradient_method,'visible','off');
end
    
% Hint: get(hObject,'Value') returns toggle state of show_help_checkbox



function chan1_marker_name_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_marker_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.channel_info(1).name = get(hObject,'String');
guidata(hObject, handles);



function chan1_label_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.channel_info(1).marker_type = get(hObject,'String');
guidata(hObject, handles);


% --- Executes on button press in default_checkbox.
function default_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to default_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tempbool = get(hObject,'Value');
helpbool = get(handles.show_help_checkbox,'value');
if tempbool
    set(handles.unique_z_shift_checkbox,'value',false);
    set(handles.z_shift_filename_txt,'visible','off');
    set(handles.start_z_for_unique_shift_help,'visible','off');
    set(handles.start_z_for_unique_shift_checkbox,'visible','off');
    set(handles.start_z_for_unique_z_shift_input,'visible','off');
    set(handles.unique_z_shift_checkbox,'visible','off');
    set(handles.unique_z_shift_help,'visible','off');
    
    set(handles.use_z_from_seg_checkbox,'value',false);
    set(handles.shift_from_seg_help,'visible','off');
    set(handles.shift_from_seg_checkbox,'visible','off');
    set(handles.shift_from_seg_input,'visible','off');
    set(handles.use_z_from_seg_checkbox,'visible','off');
    set(handles.z_shift_from_seg_help,'visible','off');
    
    set(handles.const_z_shift_quant_checkbox,'value',false);
    set(handles.const_z_for_t_input,'visible','off');
    set(handles.const_z_shift_quant_checkbox,'visible','off');
    set(handles.constant_z_help,'visible','off');
    
    display('const_z_for_t = 1');
    handles.params.options.const_z_for_t = 1;
    
    display('const_z_shift = 0');
    handles.params.options.const_z_shift = 0;
    
else
	set(handles.unique_z_shift_checkbox,'value',false);
    set(handles.z_shift_filename_txt,'visible','off');
    set(handles.start_z_for_unique_shift_help,'visible','off');
    set(handles.start_z_for_unique_shift_checkbox,'visible','off');
    set(handles.start_z_for_unique_z_shift_input,'visible','off');
    set(handles.unique_z_shift_checkbox,'visible','on');
    if helpbool 
        set(handles.unique_z_shift_help,'visible','on');
    end
    
    set(handles.use_z_from_seg_checkbox,'value',false);
    set(handles.shift_from_seg_help,'visible','off');
    set(handles.shift_from_seg_checkbox,'visible','off');
    set(handles.shift_from_seg_input,'visible','off');
    set(handles.use_z_from_seg_checkbox,'visible','on');
    if helpbool
        set(handles.z_shift_from_seg_help,'visible','on');
    end
    
    set(handles.const_z_shift_quant_checkbox,'value',false);
    set(handles.const_z_for_t_input,'visible','off');
    set(handles.const_z_shift_quant_checkbox,'visible','on');
    if helpbool
        set(handles.constant_z_help,'visible','on');
    end
end

guidata(hObject, handles);
    
% Hint: get(hObject,'Value') returns toggle state of default_checkbox


% --- Executes on button press in shift_from_seg_checkbox.
function shift_from_seg_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to shift_from_seg_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tempbool = get(hObject,'Value');
if tempbool
    
	prompt = {'constant z shift from segmentation files:'};
    name = 'diff from seg layer:';
    numlines = 1;
    defaultanswer = {''};
    diff_from_seg=inputdlg(prompt,name,numlines,defaultanswer);
    set(handles.shift_from_seg_input,'string',diff_from_seg{:});
    if ~isempty(diff_from_seg)
        handles.params.options.const_z_shift = str2num(diff_from_seg{:});
    else
        set(handles.shift_from_seg_input,'string','0');
        handles.params.options.const_z_shift = 0;
    end
    
else
    set(handles.shift_from_seg_input,'string','0');
    handles.params.options.const_z_shift = 0;
end
guidata(hObject, handles);
    



function const_z_for_t_input_Callback(hObject, eventdata, handles)
% hObject    handle to const_z_for_t_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.params.options.const_z_for_t = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes on button press in save_settings.
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.working_dir = pwd;
prompt = {'settings file name'};
dlg_title = 'Save Settings';
num_lines = [1,100];
t = clock;
fulldate = strrep(datestr(t),{' '},'at');
fulldate = strrep(fulldate,{':'},'-');
def = {[fulldate{:},'_pol_analysis_settings']};
save_settings_name = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(save_settings_name)
    display('user cancelled')
    return
end

if ~isempty(dir([save_settings_name{:},'.mat']))
    taken_quest = ['that filename exists. Overwrite?'];
    taken_title = 'Settings File Exists';
    ui_overwrite_choice = questdlg(taken_quest, taken_title,'Yes','No','Yes');
    
    switch ui_overwrite_choice
        case 'Yes'
            display('continuing, overwriting existing settings file');
        case 'No'
            display('stopping due to pre existing file');
            return
        otherwise
            display('stopping due to pre existing file');
            return
            
    end
    
end

if isempty(dir('settings_files'))
    mkdir('settings_files')
end
fullsavepath = fullfile([pwd,filesep,'settings_files',filesep],save_settings_name{:});

settings_pol = handles.params;
save(fullsavepath,'settings_pol');
display(save_settings_name);    
    


% --- Executes on button press in load_setttings.
function load_setttings_Callback(hObject, eventdata, handles)
% hObject    handle to load_setttings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[settingsfile_to_load,settingsfile_fullpath,FilterIndex]  = uigetfile({'*.mat'});
display(settingsfile_fullpath);

if settingsfile_to_load ==0
    display('user cancelled');
    return
else
    load([settingsfile_fullpath,filesep,settingsfile_to_load]);
    display(settings_pol);
    handles.settings_pol = settings_pol;
    handles.params = settings_pol;
end
guidata(hObject, handles);
cd(handles.settings_pol.working_dir);
handles = update_seg_panel_from_settings_file(hObject,handles,settings_pol);
handles = update_quant_proj_panel_from_settings_file(hObject,handles,settings_pol);
handles = update_quant_zshift_panel_from_settings_file(hObject,handles,settings_pol);
guidata(hObject, handles);

function handles = update_seg_panel_from_settings_file(hObject,handles,settings_pol)

    exist_array = [isfield(settings_pol,'base_dir'),isfield(settings_pol,'seg_filename')];
    if ~all(exist_array)
        display('missing seg file settings panel info');
        return
    end
    
    nonempty_array = [~isempty(settings_pol.base_dir),~isempty(settings_pol.seg_filename)];
	if ~all(nonempty_array)
        display('emptys vars in Seg File Settings panel info');
        return
    end
    
    handles.params.seg_filename = settings_pol.seg_filename;
    handles.params.base_dir = settings_pol.base_dir;
    set(handles.seg_dir_text,'string',handles.params.base_dir);
    set(handles.seg_filename_text,'string',handles.params.seg_filename);
	set(handles.seg_dir_text,'visible','on');
	set(handles.seg_filename_text,'visible','on');
	set(handles.seg_dir_column_text,'visible','on');
	set(handles.seg_file_column_text,'visible','on');
    
    if isfield(settings_pol,'options') && isfield(settings_pol.options,'const_z_seg') ...
            && ~isempty(settings_pol.options.const_z_seg)
        handles.params.options.const_z_seg = settings_pol.options.const_z_seg;
        
        set(handles.const_z_seg_button,'value',true);
        set(handles.const_z_seg_input,'visible','on');
        set(handles.const_z_seg_input,'string',num2str(handles.params.options.const_z_seg));
    end
    guidata(hObject, handles);
    
function handles = update_quant_proj_panel_from_settings_file(hObject,handles,settings_pol)

    if ~isfield(settings_pol,'channel_info')
        display('missing channel_info in settings');
        return
    end

     exist_array = [isfield(settings_pol.channel_info,'filename')];
    if ~(exist_array)
        display('missing channel_info fields');
        return
    end
    
    for i = 1:length(settings_pol.channel_info)
        if isempty(settings_pol.channel_info(i).filename)
            display('channel_info filename is empty');
            guidata(hObject, handles);
            return
        end
        
        temp_fn = settings_pol.channel_info(i).filename;
        temp_name = settings_pol.channel_info(i).name;
        temp_marker_type = settings_pol.channel_info(i).marker_type;
        
        sep_fname = fliplr(strtok(fliplr(temp_fn),filesep));
        [~, sep_fdir] = strtok(fliplr(temp_fn),filesep);
        sep_fdir = fliplr(sep_fdir);
        
        switch i
            case 1
                set(handles.chan1_dir_text,'string',sep_fdir);
                set(handles.chan1_file_text,'string',sep_fname);
                set(handles.chan1_marker_name,'string',temp_name);
                set(handles.chan1_label,'string',temp_marker_type);
                set(handles.chan2_check,'visible','on');
            case 2
                set(handles.chan2_dir_text,'string',sep_fdir);
                set(handles.chan2_file_text,'string',sep_fname);
                set(handles.chan2_marker_name,'string',temp_name);
                set(handles.chan2_label,'string',temp_marker_type);
                set(handles.chan2_check,'value',true);
                set(handles.chan2_dir_text,'visible','on');
                set(handles.chan2_file_text,'visible','on');
                set(handles.chan2_marker_name,'visible','on');
                set(handles.chan2_label,'visible','on');
                set(handles.chan3_check,'visible','on');
            case 3
                set(handles.chan3_dir_text,'string',sep_fdir);
                set(handles.chan3_file_text,'string',sep_fname);
                set(handles.chan3_marker_name,'string',temp_name);
                set(handles.chan3_label,'string',temp_marker_type);
                set(handles.chan3_check,'value',true);
                set(handles.chan3_dir_text,'visible','on');
                set(handles.chan3_file_text,'visible','on');
                set(handles.chan3_marker_name,'visible','on');
                set(handles.chan3_label,'visible','on');
        end
        
        handles.params.channel_info(i).filename = settings_pol.channel_info(i).filename;
        handles.params.channel_info(i).name = settings_pol.channel_info(i).name;
        handles.params.channel_info(i).marker_type = settings_pol.channel_info(i).marker_type;
    end

guidata(hObject, handles);

function handles = update_quant_zshift_panel_from_settings_file(hObject,handles,settings_pol)

    if ~isfield(settings_pol,'options')
        display('options not a field in settings_pol');
        set(handles.use_z_from_seg_checkbox,'value',true);
        eventdata = [];
        use_z_from_seg_checkbox_Callback(handles.use_z_from_seg_checkbox, eventdata, handles);
        guidata(hObject, handles);
        return
    end
    
    exist_array = [isfield(settings_pol.options,'z_shift_file'),...
                   isfield(settings_pol.options,'const_z_shift'),...
                   isfield(settings_pol.options,'const_z_for_t')];
    
    if ~any(exist_array)
        display('no z shift options selected in settings file');
        return
    end
    
    if exist_array(3) && any(exist_array(1:2))
        display('conflict: constant z and mutually exclusive option selected');
        return
    end
          
%     zshift_choice = find(exist_array,1);
    
    if isfield(settings_pol.options,'z_shift_file')
%         first option -> unique z shift
        set(handles.unique_z_shift_checkbox,'value',true);
        set(handles.z_shift_filename_txt,'string',settings_pol.options.z_shift_file);
        set(handles.start_z_for_unique_z_shift_input,'string',settings_pol.options.const_z_shift);
        
        set(handles.z_shift_filename_txt,'visible','on');
        set(handles.start_z_for_unique_shift_help,'visible','on');
        set(handles.start_z_for_unique_shift_checkbox,'visible','on');
        set(handles.start_z_for_unique_z_shift_input,'visible','on');

        set(handles.use_z_from_seg_checkbox,'value',false);
        set(handles.shift_from_seg_help,'visible','off');
        set(handles.shift_from_seg_checkbox,'visible','off');
        set(handles.shift_from_seg_input,'visible','off');
        set(handles.const_z_shift_quant_checkbox,'value',false);
        set(handles.const_z_for_t_input,'visible','off');
        
        handles.params.options.z_shift_file = settings_pol.options.z_shift_file;
        handles.params.options.const_z_shift = settings_pol.options.const_z_shift;
        guidata(hObject, handles);
        return
    else
        if ~isfield(settings_pol.options,'z_shift_file') &&...
                ~isfield(settings_pol.options,'const_z_for_t')
            % second option -> use z shift for seg
            
            set(handles.z_shift_filename_txt,'visible','off');
            set(handles.start_z_for_unique_shift_help,'visible','off');
            set(handles.start_z_for_unique_shift_checkbox,'visible','off');
            set(handles.start_z_for_unique_z_shift_input,'visible','off');
            set(handles.unique_z_shift_checkbox,'value',false);

            set(handles.use_z_from_seg_checkbox,'value',true);
            set(handles.shift_from_seg_help,'visible','on');
            set(handles.shift_from_seg_checkbox,'visible','on');
            set(handles.shift_from_seg_checkbox,'value',true);
            set(handles.shift_from_seg_input,'visible','on');

            set(handles.const_z_shift_quant_checkbox,'value',false);
            set(handles.const_z_for_t_input,'visible','off');

            if isfield(handles.params, 'options') && isfield(handles.params.options,'z_shift_file');
                handles.params.options = rmfield(handles.params.options,'z_shift_file');
            end
            handles.params.options.const_z_shift = settings_pol.options.const_z_shift;
            guidata(hObject, handles);
            return
            
        else
            
            if isfield(settings_pol.options,'const_z_for_t')
            % third option -> constant z for all t
                set(handles.z_shift_filename_txt,'visible','off');
                set(handles.start_z_for_unique_shift_help,'visible','off');
                set(handles.start_z_for_unique_shift_checkbox,'visible','off');
                set(handles.start_z_for_unique_z_shift_input,'visible','off');
                set(handles.unique_z_shift_checkbox,'value',false);

                set(handles.shift_from_seg_help,'visible','off');
                set(handles.shift_from_seg_checkbox,'visible','off');
                set(handles.shift_from_seg_input,'visible','off');
                set(handles.shift_from_seg_checkbox,'value',false);

                set(handles.const_z_shift_quant_checkbox,'value',true);
                set(handles.const_z_for_t_input,'visible','on');

                if isfield(handles.params, 'options') && isfield(handles.params.options,'z_shift_file');
                    handles.params.options = rmfield(handles.params.options,'z_shift_file');
                end
                if isfield(handles.params, 'options') && isfield(handles.params.options,'const_z_shift');
                    handles.params.options = rmfield(handles.params.options,'const_z_shift');
                end
                
                handles.params.options.const_z_for_t = settings_pol.options.const_z_for_t;
                guidata(hObject, handles);
                return
            
            end
        end    
    end
        


% --- Executes on button press in run_gradient_method.
function run_gradient_method_Callback(hObject, eventdata, handles)
% hObject    handle to run_gradient_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
seperate_grad_bool = get(handles.grad_separate_button,'Value');
if seperate_grad_bool
    SEGGA_gradient_method_for_polarity;
else
    grad_pol_analysis_base_dir = [handles.params.base_dir,filesep,'gradient_polarity_analysis'];
    for i = 1:length(handles.params.channel_info)
        curr_chan = fileparts(handles.params.channel_info(i).filename);
        chan_save_dir = [grad_pol_analysis_base_dir,filesep,handles.params.channel_info(i).name];
        if ~isdir(chan_save_dir)
            mkdir(chan_save_dir)
        end
        poly_seq_file = [handles.params.base_dir,filesep,'seg',filesep,'poly_seq.mat'];
        seg_dir = [handles.params.base_dir,filesep,'seg'];
        run_polarity_grad_method_from_SEGGA_gui(curr_chan,...
                                                chan_save_dir,...
                                                poly_seq_file,...
                                                seg_dir);
    end
end

% --- Executes on button press in help_gradient_method.
function help_gradient_method_Callback(hObject, eventdata, handles)
% hObject    handle to help_gradient_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgstring = sprintf(['This runs code in beta stage of development \n',...
                     'The gradient method is based on code that Rodrigo Fernandez-Gonzalez wrote \n',...
                     'The same techniques might be accessible from the GUI that he created: SIESTA']);
titlestring = 'explain gradient method';
msgbox(msgstring,titlestring);


% --- Executes on button press in grad_separate_button.
function grad_separate_button_Callback(hObject, eventdata, handles)
% hObject    handle to grad_separate_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grad_separate_button
temp_bool = get(hObject,'Value');
if temp_bool
    set(handles.grad_use_settings_button,'Value',false);
else
    set(handles.grad_use_settings_button,'Value',true);
end

% --- Executes on button press in grad_use_settings_button.
function grad_use_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to grad_use_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp_bool = get(hObject,'Value');
if temp_bool
    set(handles.grad_separate_button,'Value',false);
else
    set(handles.grad_separate_button,'Value',true);
end
% Hint: get(hObject,'Value') returns toggle state of grad_use_settings_button


% --- Executes on button press in basedir_settings_help.
function basedir_settings_help_Callback(hObject, eventdata, handles)
% hObject    handle to basedir_settings_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgstring = sprintf(['Select Dir that is one level above ''seg'' folder .\n']);
titlestring = 'explain base dir selection';
msgbox(msgstring,titlestring);


% --- Executes on button press in basic_analysis_radbutton.
function basic_analysis_radbutton_Callback(hObject, eventdata, handles)
% hObject    handle to basic_analysis_radbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.analysis_type = 'basic';
set(handles.full_profile_radbutton,'value',false);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of basic_analysis_radbutton


% --- Executes on button press in full_profile_radbutton.
function full_profile_radbutton_Callback(hObject, eventdata, handles)
% hObject    handle to full_profile_radbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.analysis_type = 'full_profile';
set(handles.basic_analysis_radbutton,'value',false);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of full_profile_radbutton
