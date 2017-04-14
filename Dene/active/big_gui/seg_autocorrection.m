
function varargout = seg_autocorrection(varargin)
% SEG_AUTOCORRECTION M-file for seg_autocorrection.fig
%      SEG_AUTOCORRECTION, by itself, creates a new SEG_AUTOCORRECTION or raises the existing
%      singleton*.
%
%      H = SEG_AUTOCORRECTION returns the handle to a new SEG_AUTOCORRECTION or the handle to
%      the existing singleton*.
%
%      SEG_AUTOCORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEG_AUTOCORRECTION.M with the given input arguments.
%
%      SEG_AUTOCORRECTION('Property','Value',...) creates a new SEG_AUTOCORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seg_autocorrection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seg_autocorrection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seg_autocorrection

% Last Modified by GUIDE v2.5 29-May-2015 16:00:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seg_autocorrection_OpeningFcn, ...
                   'gui_OutputFcn',  @seg_autocorrection_OutputFcn, ...
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



% --- Executes just before seg_autocorrection is made visible.
function seg_autocorrection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seg_autocorrection (see VARARGIN)

% Choose default command line output for seg_autocorrection
handles.output = hObject;
handles.seq = [];
handles.key_frames =[];
handles.dir_loaded = false;
handles.keys_loaded = false;
handles.backup_found = false;
% handles.Directory_Status_str = {'';'-----No Dir Loaded-----';'';...
%     '----(0) Frames Total----';'';'---Start () ---- End ()---'};
handles.Directory_Status_str = {'';'      Nothing Loaded'};
handles.next_strs = {{'Next Step:';'1. Load Directory'},...
    {'Next Step:';'2. Enter Key Frames'},{'Next Step:';'3. Ready to Run'},{'','Done.'}};


set(handles.Directory_Status,'string',handles.Directory_Status_str,'foregroundcolor','red');
set(handles.key_frames,'string',num2str(handles.key_frames));
set(handles.keys_display,'string',{'';'Nothing Loaded'},'foregroundcolor','red');
set(handles.next_step,'string',handles.next_strs{1},'foregroundcolor','red');
set(handles.backup_text,'string',{'';'    Nothing Loaded'},'foregroundcolor','red');


set(handles.visualize_check,'Value',true);
handles.visualize_bool = get(handles.visualize_check,'Value');


guidata(hObject, handles);

% UIWAIT makes seg_autocorrection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = seg_autocorrection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function key_frames_Callback(hObject, eventdata, handles)
% hObject    handle to key_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of key_frames as text
%        str2double(get(hObject,'String')) returns contents of key_frames as a double

handles.key_frames =  double(str2num(get(hObject,'String')));
set(handles.keys_display,'string',{'';num2str(handles.key_frames)},'foregroundcolor','green');

if ~isempty(handles.key_frames)
    handles.keys_loaded = true;
else
     handles.keys_loaded = false;
    set(handles.keys_display,'string',{'';'  Nothing Loaded:';'  Invalid Entry'},...
        'foregroundcolor','red');
    
    if ~handles.dir_loaded
        set(handles.next_step,'string',handles.next_strs{1},...
        'foregroundcolor','red');
    else
        if ~handles.keys_loaded
        set(handles.next_step,'string',handles.next_strs{2},...
            'foregroundcolor','red');
        end
    end
end

if handles.dir_loaded && handles.keys_loaded
    set(handles.next_step,'string',handles.next_strs{3},...
        'foregroundcolor','green');
    set(handles.seg_correction,'foregroundcolor','green');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function key_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to key_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_keys.
function load_keys_Callback(hObject, eventdata, handles)
% hObject    handle to load_keys (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.keys_display,'string',{'';num2str(handles.key_frames)});
guidata(hObject, handles);

% --- Executes on button press in seg_correction.
function seg_correction_Callback(hObject, eventdata, handles)
% hObject    handle to seg_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keep_going = true;
it_worked = false;
while keep_going

    if isempty(handles.key_frames) 
       msgbox({'Missing key frames'},'ERROR');
       break
    end

    if isempty(handles.seq)
        msgbox({'Need to load directory'},'ERROR');
        break
    end
    
%   prepare seq for autocorrection:
    clear seq
    global seq
    seq = handles.seq;
    frame_nums_rel = seq.min_t:seq.max_t;
    keyframesrel = find(ismember(frame_nums_rel,handles.key_frames, 'legacy'));
    
    for i = 1:length(seq.frames)
        seq.frames(i).cellgeom.changed_by_user = false;
    end
    
    for i = keyframesrel
        seq.frames(i).cellgeom.changed_by_user = true;
    end
%   pass variables to stat viewing gui
    

    set(handles.next_step,'string','Running...','foregroundcolor','blue');


    if handles.visualize_bool
        view_autocorrection_stats;
    else
        rectify_seq(seq)
    end
    it_worked = true;
    keep_going = false;
end
if it_worked
        set(handles.next_step,'string',handles.next_strs{4},...
        'foregroundcolor','white');
end


% --- Executes on button press in load_dir.
function load_dir_Callback(hObject, eventdata, handles)
% hObject    handle to load_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = uigetdir;
if ~directory
    return
end

cd(directory);

% check if its a seg dir [only movie dirs have 'poly_seq.mat' files
bad_dir_bool = isempty(dir('poly_seq.mat'));

if bad_dir_bool
    handles.Directory_Status_str = {'';'         ERROR';...
        '';'  Not a Segmentation Directory'};

    set(handles.Directory_Status,'string',handles.Directory_Status_str,...
        'foregroundcolor','red');    
end

handles.dir_loaded = ~bad_dir_bool;

if handles.dir_loaded
    col = 'green';
    set(handles.load_dir,'string',pwd,'foregroundcolor',col);
else
    col = 'red';
    set(handles.next_step,'string',handles.next_strs{1},...
        'foregroundcolor','red');
    set(handles.backup_text,'string',{'';'    Not a Segmentation Directory'},...
        'foregroundcolor','red');
    set(handles.load_dir,'string',pwd,'foregroundcolor',col);
    guidata(hObject, handles);
    return
end

    
set(handles.backup_text,'string',{'';'  loading...'},'foregroundcolor','white');
set(handles.Directory_Status,'string',{''; '   loading...'},'foregroundcolor','white');
    


handles.seq = load_dir(pwd);
handles.seq = get_mistake_cells(handles.seq);
cells = cells_for_chart(handles.seq);
errors_str = [' Total Untracked Cells = ',num2str(sum(cells))];

if ~handles.keys_loaded
    set(handles.next_step,'string',handles.next_strs{2},...
        'foregroundcolor','red');
else
    set(handles.next_step,'string',handles.next_strs{3}',...
        'foregroundcolor','green');
    set(handles.seg_correction,'foregroundcolor','green');
end


% update display
cur_dir = pwd;
[C pos] = textscan(fliplr(cur_dir),'%[^/]');
fold = cur_dir(length(cur_dir) - pos + 1: end);
handles.fold = fold;

num_frames = num2str(length(handles.seq.frames));
t_min = num2str(handles.seq.min_t);
t_max = num2str(handles.seq.max_t);

handles.Directory_Status_str = {'';[' Dir Loaded: ''',fold,''''];'';...
    [' ( ',num_frames,' )  Frames Total'];''...
    ;[' Start ( ',t_min,' )    End ( ',t_max,' )'];...
    '';errors_str};

cur_dir = pwd;
cd ..
handles.backup_found = ~isempty(dir([fold,'_backup']));
cd(cur_dir);


if handles.backup_found
    backstr = {'';[' ''',fold,'_backup'' was found']};
    set(handles.backup_text,'string',backstr,'foregroundcolor','green');
else
    backstr ={'';[' warning: ''',fold,'_backup'' not found']};
    set(handles.backup_text,'string',backstr,'foregroundcolor','red');
end

set(handles.Directory_Status,'string',handles.Directory_Status_str,'foregroundcolor','green');


    




guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Directory_Status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Directory_Status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function keys_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to keys_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in visualize_check.
function visualize_check_Callback(hObject, eventdata, handles)
% hObject    handle to visualize_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of visualize_check
handles.visualize_bool = get(handles.visualize_check,'Value');

if handles.visualize_bool
    set(handles.visualize_check,'fontweight','bold')
else
    set(handles.visualize_check,'fontweight','normal')
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function visualize_check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visualize_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function load_keys_CreateFcn(hObject, eventdata, handles)
% hObject    handle to load_keys (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function next_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to next_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox({'Go From Top to Bottom:';'1. Pick A Directory. (Back it up for safety.)';'2. Enter Key Frames. (e.g. 1,2,3)';'3. Run The Autocorrection Code. (Only once.)'},'1, 2, 3');


% --- Executes on button press in backup_dir.
function backup_dir_Callback(hObject, eventdata, handles)
% hObject    handle to backup_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.dir_loaded
    errordlg('you must first load a segmentation directory','nothing to copy');
else
    

if handles.backup_found
    % Construct a questdlg with three options
    choice = questdlg([handles.fold,'_backup already exists:'], ...
     'Continue Making Backup?', ...
     'Continue Anyways','Cancel','Cancel');
    switch choice
        case 'Continue Anyways'
            backup_h = make_backup;
        case 'Cancel'
    end
    
               
else
    backup_h = make_backup;
end

uiwait(backup_h);

% reload the backup_dir text in the GUI
cur_dir = pwd;
[C pos] = textscan(fliplr(cur_dir),'%[^/]');
fold = cur_dir(length(cur_dir) - pos + 1: end);
handles.fold = fold;



% cd ..
handles.backup_found = ~isempty(dir([pwd,filesep,'..',filesep,'*_backup*']));
% cd(cur_dir);


if handles.backup_found
    backstr = {'';[' ''','*_backup*'' was found']};
    set(handles.backup_text,'string',backstr,'foregroundcolor','green');
else
    backstr ={'';[' warning: ''','*_backup*'' not found']};
    set(handles.backup_text,'string',backstr,'foregroundcolor','red');
end

set(handles.Directory_Status,'string',handles.Directory_Status_str,'foregroundcolor','green');




end



function cells = cells_for_chart(seq)


len = length(seq.frames);
cells = nan(len,1);
for i=1:len
    cells(i) = length(seq.frames(i).cells);
end


function pass_in_data_from_check_errors(hObject, eventdata, handles)


% hObject    handle to load_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.next_strs = {{'Next Step:';'1. Load Directory'},...
    {'Next Step:';'2. Enter Key Frames'},{'Next Step:';'3. Ready to Run'},{'','Done.'}};


directory = pwd;
bad_dir_bool = isempty(dir('poly_seq.mat'));

if bad_dir_bool
    handles.Directory_Status_str = {'';'         ERROR';...
        '';'  Not a Segmentation Directory'};

    set(handles.Directory_Status,'string',handles.Directory_Status_str,...
        'foregroundcolor','red');    
end

handles.dir_loaded = ~bad_dir_bool;

if handles.dir_loaded
    col = 'green';
    set(handles.load_dir,'string',pwd,'foregroundcolor',col);
else
    col = 'red';
    set(handles.next_step,'string',handles.next_strs{1},...
        'foregroundcolor','red');
    set(handles.backup_text,'string',{'';'    Not a Segmentation Directory'},...
        'foregroundcolor','red');
    set(handles.load_dir,'string',pwd,'foregroundcolor',col);
    guidata(hObject, handles);
    return
end

    
set(handles.backup_text,'string',{'';'  loading...'},'foregroundcolor','white');
set(handles.Directory_Status,'string',{''; '   loading...'},'foregroundcolor','white');
    

passed_data = getappdata(handles.figure1,'passed_from_check_errors');
key_frames_input = passed_data.key_frames_input;
handles.seq = passed_data.seq;
% handles.seq = load_dir(pwd);
% handles.seq = get_mistake_cells(handles.seq);

cells = cells_for_chart(handles.seq);
errors_str = [' Total Untracked Cells = ',num2str(sum(cells))];



% update display
cur_dir = pwd;
[C pos] = textscan(fliplr(cur_dir),'%[^/]');
fold = cur_dir(length(cur_dir) - pos + 1: end);
handles.fold = fold;

num_frames = num2str(length(handles.seq.frames));
t_min = num2str(handles.seq.min_t);
t_max = num2str(handles.seq.max_t);

handles.Directory_Status_str = {'';[' Dir Loaded: ''',fold,''''];'';...
    [' ( ',num_frames,' )  Frames Total'];''...
    ;[' Start ( ',t_min,' )    End ( ',t_max,' )'];...
    '';errors_str};

cur_dir = pwd;
cd ..
handles.backup_found = ~isempty(dir([fold,'_backup']));
cd(cur_dir);


if handles.backup_found
    backstr = {'';[' ''',fold,'_backup'' was found']};
    set(handles.backup_text,'string',backstr,'foregroundcolor','green');
else
    backstr ={'';[' warning: ''',fold,'_backup'' not found']};
    set(handles.backup_text,'string',backstr,'foregroundcolor','red');
end

set(handles.Directory_Status,'string',handles.Directory_Status_str,'foregroundcolor','green');




handles.key_frames =  key_frames_input;
set(handles.keys_display,'string',{'';num2str(handles.key_frames)},'foregroundcolor','green');

if ~isempty(handles.key_frames)
    handles.keys_loaded = true;
else
     handles.keys_loaded = false;
    set(handles.keys_display,'string',{'';'  Nothing Loaded:';'  Invalid Entry'},...
        'foregroundcolor','red');
    
    if ~handles.dir_loaded
        set(handles.next_step,'string',handles.next_strs{1},...
        'foregroundcolor','red');
    else
        if ~handles.keys_loaded
        set(handles.next_step,'string',handles.next_strs{2},...
            'foregroundcolor','red');
        end
    end
end

if handles.dir_loaded && handles.keys_loaded
    set(handles.next_step,'string',handles.next_strs{3},...
        'foregroundcolor','green');
    set(handles.seg_correction,'foregroundcolor','green');
end

guidata(hObject, handles);
