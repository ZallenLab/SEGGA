function varargout = SEGGA_single_movie_analysis(varargin)
% SEGGA_SINGLE_MOVIE_ANALYSIS MATLAB code for SEGGA_single_movie_analysis.fig
%      SEGGA_SINGLE_MOVIE_ANALYSIS, by itself, creates a new SEGGA_SINGLE_MOVIE_ANALYSIS or raises the existing
%      singleton*.
%
%      H = SEGGA_SINGLE_MOVIE_ANALYSIS returns the handle to a new SEGGA_SINGLE_MOVIE_ANALYSIS or the handle to
%      the existing singleton*.
%
%      SEGGA_SINGLE_MOVIE_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_SINGLE_MOVIE_ANALYSIS.M with the given input arguments.
%
%      SEGGA_SINGLE_MOVIE_ANALYSIS('Property','Value',...) creates a new SEGGA_SINGLE_MOVIE_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_single_movie_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_single_movie_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_single_movie_analysis

% Last Modified by GUIDE v2.5 15-Mar-2017 17:10:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_single_movie_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_single_movie_analysis_OutputFcn, ...
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


% --- Executes just before SEGGA_single_movie_analysis is made visible.
function SEGGA_single_movie_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_single_movie_analysis (see VARARGIN)

% Choose default command line output for SEGGA_single_movie_analysis
handles.output = hObject;
currdir = pwd;
set(handles.curr_dir_disp_txt,'string',currdir);
if isempty(dir('poly_seq.mat'));
    display('not a segmentation directory. (Missing poly_seq.mat)');
    set(handles.analysis_prep_text,'string','poly_seq.mat not found',...
        'foregroundcolor','red');
    guidata(hObject, handles);
    return   
end
set(handles.analysis_prep_text,'string','searching for files...',...
        'foregroundcolor','white');
prepinfo = get_analysis_prep_info(currdir);
handles.prepinfo = prepinfo;

handles.seq = prepinfo.seq;
handles.data = prepinfo.data;

global seq
global data
seq = prepinfo.seq;
data = prepinfo.data;

if prepinfo.bools.all_files_found_Bool

    set(handles.analysis_prep_text,'string',prepinfo.text_out,...
        'foregroundcolor','green');
else if prepinfo.bools.essential_files_found_Bool
        set(handles.analysis_prep_text,'string',prepinfo.text_out,...
        'foregroundcolor','cyan');
    else
        set(handles.analysis_prep_text,'string',prepinfo.text_out,...
        'foregroundcolor','red');
    end
end

% Update handles structure
guidata(hObject, handles);

check_that_default_settings_files_exist();


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_single_movie_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_dir_button.
function select_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_dir_button (see GCBO)
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
    else
        display([analysis_action_dir,' is not a directory']);
    end
    set(handles.analysis_prep_text,'string','searching for files...',...
        'foregroundcolor','white');
    

    prepinfo = get_analysis_prep_info;
    if prepinfo.exist.polarity_filename
        %show polarity charts button
        set(handles.pol_charts,'visible','on')
    else
        set(handles.pol_charts,'visible','off')
    end
    
    handles.prepinfo = prepinfo;
%     set(handles.analysis_prep_text,'string',prepinfo.text_out);

    handles.seq = prepinfo.seq;
    handles.data = prepinfo.data;

    if isempty(whos('seq'))
        global seq
    end
    
	if isempty(whos('data'))
        global data
    end
    seq = prepinfo.seq;
    data = prepinfo.data;
    
    if prepinfo.bools.all_files_found_Bool
        
        set(handles.analysis_prep_text,'string',prepinfo.text_out,...
            'foregroundcolor','green');
    else if prepinfo.bools.essential_files_found_Bool
            set(handles.analysis_prep_text,'string',prepinfo.text_out,...
            'foregroundcolor','cyan');
        else
            set(handles.analysis_prep_text,'string',prepinfo.text_out,...
            'foregroundcolor','red');
        end
    end
    
    guidata(hObject, handles);

% --- Executes on button press in save_timestep_button.
function save_timestep_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_timestep_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'timestep'};
dlg_title = 'timestep.mat input dialog';
num_lines = 1;
def = {'15'};
timestep_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(timestep_uinput);

if isempty(timestep_uinput)
    
    display('no input received');
    return;
else
    timestep = str2num(timestep_uinput{1});
    save('timestep','timestep');
    display('timestep.mat file created');
    timestepfileID = fopen('timestep.txt','w');
    fprintf(timestepfileID,'timestep = %d; \n',timestep);
    fprintf(timestepfileID,'this file is not used, only for reference \n');
    fclose(timestepfileID);
    display('timestep.txt file created');
end
guidata(hObject, handles);

% --- Executes on button press in save_shift_info_button.
function save_shift_info_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_shift_info_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'shift_info'};
dlg_title = 'shift_info.mat input dialog';
num_lines = 1;
def = {'0'};
shift_info_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(shift_info_uinput);

if isempty(shift_info_uinput)
    
    display('no input received');
    return;
else
    shift_info = str2num(shift_info_uinput{1});
    save('shift_info','shift_info');
    display('shift_info.mat file created');
    shift_infofileID = fopen('shift_info.txt','w');
    fprintf(shift_infofileID,'shift_info = %d; \n',shift_info);
    fprintf(shift_infofileID,'this file is not used, only for reference \n');
    fclose(shift_infofileID);
    display('shift_info.txt file created');
    
	tzerofileID = fopen('tzero.txt','w');
    fprintf(tzerofileID,'tzero = %d; \n',-shift_info+1);
    fprintf(shift_infofileID,'this file is not used, only for reference \n');
    fclose(tzerofileID);
    display('tzero.txt file created');
end
guidata(hObject, handles);

% --- Executes on button press in select_topo_cells.
function select_topo_cells_Callback(hObject, eventdata, handles)
% hObject    handle to select_topo_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

options.Interpreter = 'none';
% Include the desired Default answer
options.Default = 'CANCEL';
 mssgtxt={'"HERE" to select now (no visualization).';...
    'Otherwise "VISUAL" and use the corrections/annotations interface:';...
    '1. SEGGA_corrections->(follow user guide to select cells)';...
    '2. while in SEGGA_corrections -> menu bar -> Display cells -> "Get Cells for T1s and Rosettes"'};
choice = questdlg(mssgtxt,'CELLS FOR TOPO EVENTS','HERE','VISUAL','CANCEL',options);
display(choice);
switch choice
    case 'HERE'
        display('caculating cells_for_t1_and_ros (no visual)');
    case 'VISUAL'
        commandsui;
        return
    case 'CANCEL'
        display('user canceled');
        return
    otherwise
        display('no user input provided');
        return
end

if ~isempty(whos('seq'))
    
else if isfield(handles,'seq')
        seq = handles.seq;
    else
        seq = load_dir(pwd);
    end
    handles.seq = seq;
end

orbit = 1:length(seq.frames);
prompt = {'Enter Minimum Frames Selected After Zero'};
dlg_title = 'Cell Selection';
num_lines = 1;
def = {'50'};
frm_min = inputdlg(prompt,dlg_title,num_lines,def);
frm_min = str2num(frm_min{1});

% frm_min = 40;

if isempty(dir('shift_info*'))
    errordlg('missing shift info')
    return
end

load shift_info

if ~isempty(whos('data'))
    
else if isfield(handles,'data')
        data = handles.data;
    else
        data = seq2data(seq);
        
    end
    handles.data = data;
end




cells_sel = sum(data.cells.selected(max(-shift_info,1):end,:))>frm_min;


for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,cells_sel));
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = 1;
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .2;
end



ans_str = questdlg('Save Cells','Saving','Yes','No','Yes');

switch(ans_str)
    case 'Yes'
        cells = cells_sel;
        only_internal_t1_ros_cells = false;
        save cells_for_t1_ros cells only_internal_t1_ros_cells;
    case 'No'
        return
end

guidata(hObject, handles);

% --- Executes on button press in update_tracking_options.
function update_tracking_options_Callback(hObject, eventdata, handles)
% hObject    handle to update_tracking_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'t_min','t_max'};
dlg_title = 'tracking_options.txt input dialog';
num_lines = 1;
def = {'0','1000'};
tracking_options_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(tracking_options_uinput);

if isempty(tracking_options_uinput)
    
    display('no input received');
    return;
else
    t_min = str2num(tracking_options_uinput{1});
    t_max = str2num(tracking_options_uinput{2});
    trackfileID = fopen('tracking_options.txt','w');
    fprintf(trackfileID,'t_min = %d; \n',t_min);
    fprintf(trackfileID,'t_max = %d; \n',t_max);
    fclose(trackfileID);
    display('tracking_options.txt file created');
    
    
end

guidata(hObject, handles);

% --- Executes on button press in show_checklist_button.
function show_checklist_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_checklist_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
P = mfilename('fullpath');
reversestr = fliplr(P);
[justfile, justdirpath] = strtok(reversestr,filesep);
justfile = fliplr(justfile);
base_dir = fliplr(justdirpath);
popupmessage('SEGGA_analysis_checklist.txt');

% --- Executes on button press in run_analysis.
function run_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to run_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_call = true;
analyze_dir_new([],SEGGA_call);

% --- Executes on button press in create_charts.
function create_charts_Callback(hObject, eventdata, handles)
% hObject    handle to create_charts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
singlemovie_charts_code;

% --- Executes on button press in make_text_output.
function make_text_output_Callback(hObject, eventdata, handles)
% hObject    handle to make_text_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% csv_output_of_seg_analysis(pwd);
csv_output_of_seg_analysis_bigger(pwd);


% --- Executes on button press in run_PIV.
function run_PIV_Callback(hObject, eventdata, handles)
% hObject    handle to run_PIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PIVlab_script_02_t;


% --- Executes on button press in create_annotations.
function create_annotations_Callback(hObject, eventdata, handles)
% hObject    handle to create_annotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    anntn_sel.names = {...
        'nlost_t0';...
        'nsides';...
        'len_width';...
        'eccentricity';...
        'cell_area';...
        'ros_all';...
        'pat_defo';...
        'polarity';...
        'hor_ver'...
        };
	anntn_sel.sel_vals = {...
        true;...%'nlost_t0';...
        true;...%'nsides';...
        true;...%'len_width';...
        false;...%'eccentricity';...
        false;...%'cell_size';...
        true;...%'ros_all';...
        false;...%'pat_defo';...
        false;...%'polarity'... 
        false;...%'hor_ver'... 
        };
    setappdata(handles.figure1,'anntn_sel',anntn_sel);

    display(anntn_sel.sel_vals);
    anntn_sel_h = SEGGA_select_annotation_movies(handles.figure1);
    uiwait(anntn_sel_h);
    display(anntn_sel.sel_vals);


% --- Executes on button press in do_all.
function do_all_Callback(hObject, eventdata, handles)

% analyze_dir_new;
% singlemovie_charts_code;
% make_csvfiles_output_from_seg(indir)
% PIVlab_script_02_t;
% process_piv_data;
% 
% load('piv_procd_data','rel_elon_mean');
% pivfig = figure;
% plot(rel_elon_mean);
% xlabel('frame number')
% ylabel('relative horizontal elongation');
% title('elongation from PIV');
% saveas(gcf,[figsdir,'piv-elon.pdf']);
% close(pivfig);
% 
% create_many_annotation_movies;

function select_elon_cells_CreateFcn(hObject, eventdata, handles)
% --- Executes on button press in select_elon_cells.


function select_elon_cells_Callback(hObject, eventdata, handles)
% hObject    handle to select_elon_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

options.Interpreter = 'none';
% Include the desired Default answer
options.Default = 'CANCEL';
 mssgtxt={'Use the corrections/annotations interface:';...
    '1. SEGGA_corrections->(follow user guide to select cells)';...
    '2. while in SEGGA_corrections -> menu bar -> cells -> "select cells for elongation"'};
choice = questdlg(mssgtxt,'CELLS FOR ELON','MANUAL','CANCEL',options);
display(choice);
switch choice
    case 'AUTO'
        if ~isempty('cells_for_elon.mat')
             mssgtxt={'cells_for_elon already exists, continue and overwrite?'};
             ovrwrtchoice = questdlg(mssgtxt,'Overwrite?','yes','no','CANCEL');
             switch ovrwrtchoice
                 case 'yes'
                     display('continuing');
                 case 'no'
                     display('canceling');
                     return
                 otherwise
                     return
             end
        end
                 
            
        varspreloaded = whos('data','seq');
        if length(varspreloaded) <1
            select_elon_cells_auto(pwd,seq,data)
        else
            select_elon_cells_auto;
%         select_elon_cells_auto(indir,seq,data) can pass the dir, seq, and
%         data to speed it up if it's already loaded
        end
    case 'MANUAL'
        commandsui;
    case 'CANCEL'
        display('user canceled')
    otherwise
        display('no user input provided');
end
guidata(hObject, handles);

% --- Executes on button press in view_elon.
function view_elon_Callback(hObject, eventdata, handles)
% hObject    handle to view_elon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if ~isempty(whos('seq'))
    display('found preloaded "seq"');
else
    display('did not find seq as a global variable');
    if isfield(handles,'seq')
        seq = handles.seq;
    else
        display('did not find seq as a field in the handles structure');
        seq = load_dir(pwd);
    end
    handles.seq = seq;
end

if ~isempty(whos('data'))
    display('found preloaded "data"');
else
    display('did not find "data" as a global variable');
    if isfield(handles,'data')
        data = handles.data;
    else
        display('did not find "data" as a field in the handles structure');
        data = seq2data(seq);
    end
    handles.data = data;
end

if ~isempty(dir('cells_for_elon.mat'))
    load cells_for_elon
else
    display('missing cells_for_elon.mat');
    return
end

len = calc_embryo_elon(seq,data,0,length(seq.frames),cells);
figure; plot(smoothen(len)./min(smoothen(len)));

guidata(hObject, handles);


% --- Executes on button press in elon_from_PIV.
function elon_from_PIV_Callback(hObject, eventdata, handles)

dir_str_inds = strfind(pwd,filesep);
currdir = pwd;
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));

if isempty(dir('piv_data.mat'))
    display('need to run PIV analysis, no "piv_data" found');
    return 
   
else if isempty(dir('piv_procd_data.mat'))
        display('processing PIV data');
        process_piv_data;
    end
end

figsdir = ([pwd,filesep,'..',filesep,container_dir,'_figs',filesep]);
load('piv_procd_data','rel_elon_mean');
pivfig = figure;
plot(rel_elon_mean);
xlabel('frame number')
ylabel('relative horizontal elongation');
title('elongation from PIV');
if isdir(figsdir)
    saveas(gcf,[figsdir,'piv-elon.pdf']);
    close(pivfig);
end


% --- Executes on button press in z_shift.
function z_shift_Callback(hObject, eventdata, handles)
% hObject    handle to z_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(dir('poly_seq.mat'))
    display('directory is missing poly_seq file')
    display('canceling z_shift action');
else if ~isempty(dir('z_shift.txt'))
        mssgtxt={'z_shift.txt already exists, continue and overwrite?'};
             ovrwrtchoice = questdlg(mssgtxt,'Overwrite?','yes','no','CANCEL');
             switch ovrwrtchoice
                 case 'yes'
                     datestr = date();
                     display('continuing');
                     copyfile('z_shift.txt',['z_shift-backupfromSEGGA-',datestr,'.txt']);
                 case 'no'
                     display('canceling');
                     return
                 otherwise
                     return
             end
    end
    create_z_shift_from_files;
end
    
    

        


% --- Executes during object creation, after setting all properties.
function create_charts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to create_charts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in polarity_analysis_button.
function polarity_analysis_button_Callback(hObject, eventdata, handles)
% hObject    handle to polarity_analysis_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_single_movie_polarity_analysis;


% --- Executes on button press in node_res_btn.
function node_res_btn_Callback(hObject, eventdata, handles)
SEGGA_node_res_single_dir();


% --- Executes on button press in pol_charts.
function pol_charts_Callback(hObject, eventdata, handles)
SEGGA_single_dir_pol_charts();
