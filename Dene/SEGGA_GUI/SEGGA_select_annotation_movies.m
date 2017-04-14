function varargout = SEGGA_select_annotation_movies(varargin)
% SEGGA_SELECT_ANNOTATION_MOVIES MATLAB code for SEGGA_select_annotation_movies.fig
%      SEGGA_SELECT_ANNOTATION_MOVIES, by itself, creates a new SEGGA_SELECT_ANNOTATION_MOVIES or raises the existing
%      singleton*.
%
%      H = SEGGA_SELECT_ANNOTATION_MOVIES returns the handle to a new SEGGA_SELECT_ANNOTATION_MOVIES or the handle to
%      the existing singleton*.
%
%      SEGGA_SELECT_ANNOTATION_MOVIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_SELECT_ANNOTATION_MOVIES.M with the given input arguments.
%
%      SEGGA_SELECT_ANNOTATION_MOVIES('Property','Value',...) creates a new SEGGA_SELECT_ANNOTATION_MOVIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_select_annotation_movies_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_select_annotation_movies_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_select_annotation_movies

% Last Modified by GUIDE v2.5 12-Apr-2017 12:11:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_select_annotation_movies_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_select_annotation_movies_OutputFcn, ...
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


% --- Executes just before SEGGA_select_annotation_movies is made visible.
function SEGGA_select_annotation_movies_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_select_annotation_movies (see VARARGIN)

% Choose default command line output for SEGGA_select_annotation_movies
handles.output = hObject;

if ~isempty(varargin)
    handles.callingapp_h = varargin{1};
    display(['window calling SEGGA_select_annotation_movies: ',varargin{1}.Name]);
    display(varargin);
else
    display('needs handle of calling window as input');
    return    
end

use_cmap_bool = false;
setappdata(handles.figure1,'use_cmap_bool',use_cmap_bool);
cmap_file = [];
setappdata(handles.figure1,'cmap_file',cmap_file);

pol_cmap_opts.type = 'Adaptive';
pol_cmap_opts.val = 0;
pol_cmap_opts.bounds = [];
setappdata(handles.figure1,'pol_cmap_opts',pol_cmap_opts);

% Update handles structure
guidata(hObject, handles);



if get(handles.hor_ver_chkbx,'value')
    set(handles.lw_smooth_bool_chkbox,'visible','on');
else
    set(handles.lw_smooth_bool_chkbox,'visible','off');
end

if get(handles.ecc_chkbx,'value')
    set(handles.ecc_smooth_bool_chkbox,'visible','on');
else
    set(handles.ecc_smooth_bool_chkbox,'visible','off');
end

if get(handles.cellarea_chkbx,'value')
    set(handles.area_smooth_bool_chkbox,'visible','on');
else
    set(handles.area_smooth_bool_chkbox,'visible','off');
end

if get(handles.pat_defo_chkbx,'value')
    set(handles.pat_defo_smooth_bool_chkbox,'visible','on');
else
    set(handles.pat_defo_smooth_bool_chkbox,'visible','off');
end


% UIWAIT makes SEGGA_select_annotation_movies wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_select_annotation_movies_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in nlost_t0_chkbx.
function nlost_t0_chkbx_Callback(hObject, eventdata, handles)
% hObject    handle to nlost_t0_chkbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nlost_t0_chkbx


% --- Executes on button press in nsides_chkbx.
function nsides_chkbx_Callback(hObject, eventdata, handles)
% hObject    handle to nsides_chkbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nsides_chkbx


% --- Executes on button press in ecc_chkbx.
function ecc_chkbx_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v
    set(handles.ecc_smooth_bool_chkbox,'visible','on');
else
    set(handles.ecc_smooth_bool_chkbox,'visible','off');
end


% --- Executes on button press in hor_ver_chkbx.
function hor_ver_chkbx_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v
    set(handles.lw_smooth_bool_chkbox,'visible','on');
else
    set(handles.lw_smooth_bool_chkbox,'visible','off');
end


% --- Executes on button press in ros_all_chkbx.
function ros_all_chkbx_Callback(hObject, eventdata, handles)
% hObject    handle to ros_all_chkbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ros_all_chkbx


% --- Executes on button press in cellarea_chkbx.
function cellarea_chkbx_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v
    set(handles.area_smooth_bool_chkbox,'visible','on');
else
    set(handles.area_smooth_bool_chkbox,'visible','off');
end


% --- Executes on button press in ros_6plus_chkbx.
function ros_6plus_chkbx_Callback(hObject, eventdata, handles)
% hObject    handle to ros_6plus_chkbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ros_6plus_chkbx


% --- Executes on button press in pat_defo_chkbx.
function pat_defo_chkbx_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v
    set(handles.pat_defo_smooth_bool_chkbox,'visible','on');
else
    set(handles.pat_defo_smooth_bool_chkbox,'visible','off');
end


% --- Executes on button press in polarity_chkbx.
function polarity_chkbx_Callback(hObject, eventdata, handles)
% hObject    handle to polarity_chkbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of polarity_chkbx


% --- Executes on button press in submit_button.
function submit_button_Callback(hObject, eventdata, handles)
% hObject    handle to submit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % defaults
    anntn_sel.names = {...
        'nlost_t0';...
        'nsides';...
        'len_width';...%hor/vert
        'eccentricity';...
        'cell_area';...
        'ros_all';...
%         'ros_6+';...
        'pat_defo';...
        'polarity';...
        'q_value'... 
        };
	anntn_sel.sel_vals = {...
        true;...%'nlost_t0';...
        true;...%'nsides';...
        true;...%'len_width (hor/vert)';...
        false;...%'eccentricity';...
        false;...%'cell_area';...
        true;...%'ros_all';...
        false;...%'pat_defo';...
        false;...%'polarity'...
        false;...%'q_value'...
        };
    
    anntn_sel.cmap_names = {...
        'NLost';...%'nlost_t0';...
        'Topology';...%'nsides';...
        'LW_ratio';...%'len_width';...
        'Eccentricity';...%'eccentricity';...
        'Area';...%'cell_size';...
        [];...%'ros_all';...
        'Pat_Defo';...%'pat_defo';...
        'Polarity';...%'polarity'...        
        };

   
%     modify defualts based on GUI
	anntn_sel.sel_vals = {...
        logical(get(handles.nlost_t0_chkbx,'value'));...%'nlost_t0';...
        logical(get(handles.nsides_chkbx,'value'));...%'nsides';...
        logical(get(handles.hor_ver_chkbx,'value'));...%'len_width';...
        logical(get(handles.ecc_chkbx,'value'));...%'eccentricity';...
        logical(get(handles.cellarea_chkbx,'value'));...%'cell_size';...
        logical(get(handles.ros_all_chkbx,'value'));...%'ros_all';...
        logical(get(handles.pat_defo_chkbx,'value'));...%'pat_defo';...
        logical(get(handles.polarity_chkbx,'value'));...%'polarity'...        
        };
    
	anntn_sel.smth_vals = {...
        false;...%'nlost_t0';...
        false;...%'nsides';...
        logical(get(handles.lw_smooth_bool_chkbox,'value'));...%'len_width (hor/vert)';...
        logical(get(handles.ecc_smooth_bool_chkbox,'value'));...%'eccentricity';...
        logical(get(handles.area_smooth_bool_chkbox,'value'));...%'cell_area';...
        false;...%'ros_all';...
        logical(get(handles.pat_defo_smooth_bool_chkbox,'value'));...%'pat_defo';...
        false;...%'polarity'...
        };
    
    setappdata(handles.callingapp_h,'anntn_sel',anntn_sel);
    
    
    use_cmap_bool = getappdata(handles.figure1,'use_cmap_bool');
    
    pol_cmap_opts = getappdata(handles.figure1,'pol_cmap_opts');
    %%% polarity might not have been selected, but just pass this along
    %%% either way for simplicity's sake.
    
    
    if use_cmap_bool
        fullcmapname = getappdata(handles.figure1,'cmap_file');
        close(handles.figure1);
        SEGGA_create_many_annotation_movies(pwd,false,anntn_sel,...
                                            fullcmapname,pol_cmap_opts);       
    else
        close(handles.figure1);
%         fullcmapname = [];
        SEGGA_create_many_annotation_movies(pwd,false,anntn_sel,[],pol_cmap_opts);
    end
    return

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

display('user cancelled');
close(handles.figure1);
return


% --- Executes on selection change in cmap_dev_popup.
function cmap_dev_popup_Callback(hObject, eventdata, handles)
% hObject    handle to cmap_dev_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cmap_nm = 'SEGGA_default_cmaps.mat';
fold = [fileparts(mfilename('fullpath')),filesep,'..',filesep,'active',filesep,'general',filesep];
% if isdeployed()
%     display('application is deployed, using different search path.');
%     fold = [ctfroot(),filesep,'cmap_files',filesep];
% end

display('--- running cmap_dev_popup_Callback in SEGGA_select_annotation_movies ---');
display(['folder containing acting file: ' fold,' -- isdir: ',num2str(isdir(fold))]);
display(['current directory: ', pwd,' -- isdir: ',num2str(isdir(pwd))]);
if ~isdir(fold)
    display('could not find containing folder of m file');
end

def_cmap_exists_bool = ~isempty(dir([fold,filesep,cmap_nm]));
if ~def_cmap_exists_bool
    uiwait(msgbox('default colormap data missing, generating now'));
    generate_SEGGA_default_cmaps([fold,filesep,cmap_nm]);
end

contents = cellstr(get(hObject,'String'));
selection = contents{get(hObject,'Value')};
switch selection
    case 'Default'
        set(handles.preview_cmap_btn,'visible','off');
        set(handles.load_cmap_btn,'visible','off');
        set(handles.cmap_filenameH,'visible','off');
        use_cmap_bool = false;
        setappdata(handles.figure1,'use_cmap_bool',use_cmap_bool);
        cmap_file = [];
        setappdata(handles.figure1,'cmap_file',cmap_file);
        
    case 'Custom'
        set(handles.preview_cmap_btn,'visible','on');
        set(handles.load_cmap_btn,'visible','on');
        set(handles.cmap_filenameH,'visible','on');
        
        startdir = pwd;
        P = mfilename('fullpath');
        reversestr = fliplr(P);
        [~, justdirpath] = strtok(reversestr,filesep);
        base_dir = fliplr(justdirpath);
        
        cmapfilename = 'SEGGA_default_cmaps.mat';
        % cmapfilefold = [base_dir,'..',filesep,'active',filesep,'general',filesep];
        % cd(cmapfilefold);        
        % file should exist in same folder as current .m file
        cd(fold);
        [filename, pathname] = uigetfile([fold,'*,mat'],'Choose a Colormap Database',cmapfilename);
        fullcmapname = fullfile(pathname,filename);
        cd(startdir);
        if isempty(filename)
            display('user cancelled');
            set(handles.preview_cmap_btn,'visible','off');
            set(handles.load_cmap_btn,'visible','off');
            set(handles.cmap_filenameH,'visible','off');
            set(handles.cmap_dev_popup,'Value',1);
            use_cmap_bool = false;
            setappdata(handles.figure1,'use_cmap_bool',use_cmap_bool);
            cmap_file = [];
            setappdata(handles.figure1,'cmap_file',cmap_file);
            return
        end
        use_cmap_bool = true;
        setappdata(handles.figure1,'use_cmap_bool',use_cmap_bool);
        setappdata(handles.figure1,'cmap_file',fullcmapname);
        set(handles.cmap_filenameH,'string',filename);
        
end



% --- Executes during object creation, after setting all properties.
function cmap_dev_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmap_dev_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in preview_cmap_btn.
function preview_cmap_btn_Callback(hObject, eventdata, handles)
% hObject    handle to preview_cmap_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if getappdata(handles.figure1,'use_cmap_bool');
        cmap_file = getappdata(handles.figure1,'cmap_file');
        visualize_multiple_colmaps(cmap_file);
else
    display(['''use_cmap_bool'' is set to false']);
end


% --- Executes on button press in load_cmap_btn.
function load_cmap_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_cmap_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startdir = pwd;
P = mfilename('fullpath');
reversestr = fliplr(P);
[~, justdirpath] = strtok(reversestr,filesep);
base_dir = fliplr(justdirpath);
cmapfilefold = [base_dir,'..',filesep,'active',filesep,'general',filesep];
cmapfilename = 'SEGGA_default_cmaps.mat';
cd(cmapfilefold);
[filename, pathname] = uigetfile('*,mat','Choose a Colormap Database',cmapfilename);
fullcmapname = fullfile(pathname,filename);
cd(startdir);
if isempty(filename)
    display('user cancelled');
    set(handles.preview_cmap_btn,'visible','off');
    set(handles.load_cmap_btn,'visible','off');
    set(handles.cmap_filenameH,'visible','off');
    set(handles.cmap_dev_popup,'Value',1);
    use_cmap_bool = false;
    setappdata(handles.figure1,'use_cmap_bool',use_cmap_bool);
    cmap_file = [];
    setappdata(handles.figure1,'cmap_file',cmap_file);
    return
end
use_cmap_bool = true;
setappdata(handles.figure1,'use_cmap_bool',use_cmap_bool);
setappdata(handles.figure1,'cmap_file',fullcmapname);
set(handles.cmap_filenameH,'string',filename);


% --- Executes on button press in lw_smooth_bool_chkbox.
function lw_smooth_bool_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to lw_smooth_bool_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lw_smooth_bool_chkbox


% --- Executes on button press in ecc_smooth_bool_chkbox.
function ecc_smooth_bool_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ecc_smooth_bool_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ecc_smooth_bool_chkbox


% --- Executes on button press in area_smooth_bool_chkbox.
function area_smooth_bool_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to area_smooth_bool_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of area_smooth_bool_chkbox


% --- Executes on button press in pat_defo_smooth_bool_chkbox.
function pat_defo_smooth_bool_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to pat_defo_smooth_bool_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pat_defo_smooth_bool_chkbox


% --- Executes on selection change in pol_cmap_bound_opt.
function pol_cmap_bound_opt_Callback(hObject, eventdata, handles)

pol_cmap_opts.bounds = []; 
% 'bounds' get's saved later and might be modified below depending 
%  on the options selected

contents = cellstr(get(hObject,'String'));
pol_cmap.type = contents{get(hObject,'Value')};
switch pol_cmap.type
    case 'Adaptive'
        pol_cmap.val = 0;
    case 'User Defined'
        pol_cmap.val = 1;
        prompt = {'pol_min','pol_max'};
        dlg_title = '(log2) polarity cmap limits input dialog';
        num_lines = 1;
        def = {'-1','1'};
        pol_lim_uinput = inputdlg(prompt,dlg_title,num_lines,def);
        display(pol_lim_uinput);

        if isempty(pol_lim_uinput)
            display('no input received, setting cmap bounds technique to default: Adaptive');
            pol_cmap.type = 'Adaptive';
            pol_cmap.val = 0;
            return;
        else
            p_min = str2num(pol_lim_uinput{1});
            p_max = str2num(pol_lim_uinput{2});
            p_bounds = [p_min,p_max];
            pol_cmap_opts.bounds = p_bounds;
            %%% add this value to settings.
        end
    case 'Hard Coded'
        pol_cmap.val = 2;
        %%% just using whatevers already in the code
    otherwise
        display(['pol_cmap type unknown [',pol_cmap.type,']']);
        return
end


pol_cmap_opts.type = pol_cmap.type;
pol_cmap_opts.val = pol_cmap.val;
setappdata(handles.figure1,'pol_cmap_opts',pol_cmap_opts);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pol_cmap_bound_opt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pol_cmap_bound_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in regen_cmap_defaults.
function regen_cmap_defaults_Callback(hObject, eventdata, handles)
cmap_nm = 'SEGGA_default_cmaps.mat';
[fold, ~] = fileparts(mfilename('fullpath'));
if isdeployed()
    display('application is deployed, using different search path.');
    fold = ctfroot();
end

display('--- running cmap_dev_popup_Callback in SEGGA_select_annotation_movies ---');
display(['folder containing acting file: ' fold,' -- isdir: ',num2str(isdir(fold))]);
display(['current directory: ', pwd,' -- isdir: ',num2str(isdir(pwd))]);
if ~isdir(fold)
    display('could not find containing folder of m file');
end

generate_SEGGA_default_cmaps([fold,filesep,cmap_nm]);
