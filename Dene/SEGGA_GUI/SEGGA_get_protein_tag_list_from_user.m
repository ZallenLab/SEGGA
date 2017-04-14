function varargout = SEGGA_get_protein_tag_list_from_user(varargin)
% SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER MATLAB code for SEGGA_get_protein_tag_list_from_user.fig
%      SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER, by itself, creates a new SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER or raises the existing
%      singleton*.
%
%      H = SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER returns the handle to a new SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER or the handle to
%      the existing singleton*.
%
%      SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER.M with the given input arguments.
%
%      SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER('Property','Value',...) creates a new SEGGA_GET_PROTEIN_TAG_LIST_FROM_USER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_get_protein_tag_list_from_user_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_get_protein_tag_list_from_user_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_get_protein_tag_list_from_user

% Last Modified by GUIDE v2.5 22-Sep-2016 12:18:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_get_protein_tag_list_from_user_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_get_protein_tag_list_from_user_OutputFcn, ...
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


% --- Executes just before SEGGA_get_protein_tag_list_from_user is made visible.
function SEGGA_get_protein_tag_list_from_user_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_get_protein_tag_list_from_user (see VARARGIN)


if nargin>3 && ~isempty(varargin)
    display('working on vargin in OpeningFcn');
    display(['nargin: ',num2str(nargin)]);
    display(varargin);
else
    display('varargin not given or empty')
end

% Choose default command line output for SEGGA_get_protein_tag_list_from_user
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SEGGA_get_protein_tag_list_from_user wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_get_protein_tag_list_from_user_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function store_user_input_Callback(hObject, user_input, handles)
% This is a hack that uses the 'eventdata' variable to pull in data
% passed to the GUI, the 'eventdata' variable has been repurposed and
% renamed to 'user_input', but the function, 'store_user_input_Callback',
% is called through the normal referencing as if it it were
% a graphically oriented callback associated with a button.
% 

%     tmp_input_data = {handles.settings.user_defined_pol_tag_list,...
%                       handles.settings.data_defined_pol_tag_list,...
%                       handles.figure1};
handles.user_pol_tag_list = user_input{1};
handles.data_pol_tag_list = user_input{2};
handles.calling_figH = user_input{3};
guidata(handles.figure1, handles);
if isempty(handles.user_pol_tag_list)
    set(handles.tag_list_dropdown,'string',{'empty'});
else
    set(handles.tag_list_dropdown,'string',handles.user_pol_tag_list);
end
guidata(hObject, handles);


% --- Executes on selection change in tag_list_dropdown.
function tag_list_dropdown_Callback(hObject, eventdata, handles)
display('drop');
contents = cellstr(get(hObject,'String'));
ind = get(hObject,'Value');
selection = contents{ind};
setappdata(handles.figure1,'current_tag_ind',ind);
setappdata(handles.figure1,'current_tag_name',selection);


function tag_list_dropdown_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_new_protein_tag_btn.
function add_new_protein_tag_btn_Callback(hObject, eventdata, handles)
display('add new');
new_name = inputdlg('Enter new tag name:',...
             'Add New Tag', [1 50]);
if isempty(new_name)
    display('empty output');
    return
else
    handles.user_pol_tag_list = {handles.user_pol_tag_list{:},new_name{:}};
end
guidata(hObject, handles);
update_drop_down_tag_selection(handles);

% --- Executes on button press in remove_protein_tag_btn.
function remove_protein_tag_btn_Callback(hObject, eventdata, handles)
% hObject    handle to remove_protein_tag_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.user_pol_tag_list)
    display('remove');
%     contents = cellstr(get(handles.tag_list_dropdown,'String'));
    ind = get(handles.tag_list_dropdown,'Value');
    handles.user_pol_tag_list(ind) = [];
    update_drop_down_tag_selection(handles);
end
guidata(hObject, handles);

% --- Executes on button press in edit_protein_tag_btn.
function edit_protein_tag_btn_Callback(hObject, eventdata, handles)
display('edit');
if isempty(handles.user_pol_tag_list)
    set(handles.tag_list_dropdown,'string',{'empty'});
    return
end
contents = cellstr(get(handles.tag_list_dropdown,'String'));
ind = get(handles.tag_list_dropdown,'Value');
new_name = inputdlg('Edit tag name:',...
             'Edit Tag', [1 50],{contents{ind}});
if isempty(new_name)
    display('empty output');
    return
else
    handles.user_pol_tag_list(ind) = new_name;
end
guidata(hObject, handles);
update_drop_down_tag_selection(handles);



% --- Executes on button press in submit_btn.
function submit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to submit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.calling_figH, 'user_defined_pol_tag_list_intermediary',handles.user_pol_tag_list)
close(handles.figure1);

% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --- Executes on button press in add_all_from_data_btn.
function add_all_from_data_btn_Callback(hObject, eventdata, handles)
display('add all data');
handles.user_pol_tag_list = handles.data_pol_tag_list;
guidata(hObject, handles);
update_drop_down_tag_selection(handles);

% --- Executes on button press in clear_all_btn.
function clear_all_btn_Callback(hObject, eventdata, handles)
display('add clear all');
handles.user_pol_tag_list = {};
guidata(hObject, handles);
update_drop_down_tag_selection(handles);

function update_drop_down_tag_selection(handles)
if isempty(handles.user_pol_tag_list)
    set(handles.tag_list_dropdown,'value',1);
    set(handles.tag_list_dropdown,'string',{'empty'});
else
    set(handles.tag_list_dropdown,'value',min(get(handles.tag_list_dropdown,'value'),length(handles.user_pol_tag_list)));
    set(handles.tag_list_dropdown,'string',handles.user_pol_tag_list);
end
