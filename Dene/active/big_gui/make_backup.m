function varargout = make_backup(varargin)
% MAKE_BACKUP M-file for make_backup.fig
%      MAKE_BACKUP, by itself, creates a new MAKE_BACKUP or raises the existing
%      singleton*.
%
%      H = MAKE_BACKUP returns the handle to a new MAKE_BACKUP or the handle to
%      the existing singleton*.
%
%      MAKE_BACKUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKE_BACKUP.M with the given input arguments.
%
%      MAKE_BACKUP('Property','Value',...) creates a new MAKE_BACKUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before make_backup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to make_backup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help make_backup

% Last Modified by GUIDE v2.5 14-Apr-2010 22:22:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @make_backup_OpeningFcn, ...
                   'gui_OutputFcn',  @make_backup_OutputFcn, ...
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


% --- Executes just before make_backup is made visible.
function make_backup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to make_backup (see VARARGIN)

% Choose default command line output for make_backup
handles.output = hObject;

% Update handles structure

set(handles.backup_name,'string',[pwd,'_backup']);
guidata(hObject, handles);

% UIWAIT makes make_backup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = make_backup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in make_copy.
function make_copy_Callback(hObject, eventdata, handles)
% hObject    handle to make_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

org_fold = pwd;
end_fold = get(handles.backup_name,'string');

if isdir(org_fold)
    if ~isdir(end_fold)
        copy_h = msgbox('copying files...');
        child = get(copy_h,'Children');
        set(child(2),'visible','off');
        pause(0.1);
%         delete(child(2));
        copyfile(org_fold,end_fold);
        close(copy_h);
        close(handles.figure1);
    else
            choice = questdlg([end_fold,' already exists:'], ...
                'Overwrite Existing Folder?', ...
     'Overwrite','Cancel','Cancel');
    switch choice
        case 'Overwrite'
             copy_h = msgbox('copying files...');
            child = get(copy_h,'Children');
            set(child(2),'visible','off');
            pause(0.1);
             copyfile(org_fold,end_fold);
             close(copy_h);
             close(handles.figure1);
        case 'Cancel'
            close
    end
    end
    
    
end

% --- Executes on button press in cancel_op.
function cancel_op_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_op (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close

function backup_name_Callback(hObject, eventdata, handles)
% hObject    handle to backup_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backup_name as text
%        str2double(get(hObject,'String')) returns contents of backup_name as a double

handles.backup_str = get(handles.backup_name,'string');



% --- Executes during object creation, after setting all properties.
function backup_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backup_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
