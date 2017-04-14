function varargout = SEGGA_get_protein_tag_map_from_user(varargin)
% SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER MATLAB code for SEGGA_get_protein_tag_map_from_user.fig
%      SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER, by itself, creates a new SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER or raises the existing
%      singleton*.
%
%      H = SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER returns the handle to a new SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER or the handle to
%      the existing singleton*.
%
%      SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER.M with the given input arguments.
%
%      SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER('Property','Value',...) creates a new SEGGA_GET_PROTEIN_TAG_MAP_FROM_USER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_get_protein_tag_map_from_user_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_get_protein_tag_map_from_user_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_get_protein_tag_map_from_user

% Last Modified by GUIDE v2.5 26-Sep-2016 13:39:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_get_protein_tag_map_from_user_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_get_protein_tag_map_from_user_OutputFcn, ...
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


% --- Executes just before SEGGA_get_protein_tag_map_from_user is made visible.
function SEGGA_get_protein_tag_map_from_user_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_get_protein_tag_map_from_user (see VARARGIN)

% Choose default command line output for SEGGA_get_protein_tag_map_from_user
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SEGGA_get_protein_tag_map_from_user wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_get_protein_tag_map_from_user_OutputFcn(hObject, eventdata, handles) 
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
%                       handles.settings.pol_tag_mapping,...
%                       handles.figure1};
handles.user_pol_tag_list = user_input{1};
handles.data_pol_tag_list = user_input{2};
handles.pol_tag_mapping = user_input{3};
handles.calling_figH = user_input{4};
handles.additional_maps = {'EXCLUDE','NEW'};
set(handles.select_map_popup,'string',{handles.user_pol_tag_list{:},handles.additional_maps{:}});

if length(handles.data_pol_tag_list) ~= length(handles.pol_tag_mapping)
    display('data generated tags and mapped name tags do not have equal lengths');
    set(handles.data_gen_listbox,'string',handles.data_pol_tag_list);
    set(handles.mapped_names_listbox,'string',handles.data_pol_tag_list);
    handles.pol_tag_mapping = handles.data_pol_tag_list;
    guidata(handles.figure1, handles);
    return
end

set(handles.data_gen_listbox,'string',handles.data_pol_tag_list);
if isempty(handles.data_pol_tag_list)
    set(handles.data_gen_listbox,'string',{'empty'});
end

set(handles.mapped_names_listbox,'string',handles.pol_tag_mapping);
if isempty(handles.pol_tag_mapping)
    set(handles.mapped_names_listbox,'string',{'empty'});
end

guidata(handles.figure1, handles);

% --- Executes on selection change in data_gen_listbox.
function data_gen_listbox_Callback(hObject, eventdata, handles)
if isempty(handles.data_pol_tag_list)
    display('empty');
    return
end

% contents = cellstr(get(hObject,'String'));
ind = get(hObject,'Value');
set(handles.mapped_names_listbox,'Value',ind);


% --- Executes during object creation, after setting all properties.
function data_gen_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mapped_names_listbox.
function mapped_names_listbox_Callback(hObject, eventdata, handles)
if isempty(handles.pol_tag_mapping)
    display('empty');
    return
end
ind = get(hObject,'Value');
set(handles.data_gen_listbox,'Value',ind);

% --- Executes during object creation, after setting all properties.
function mapped_names_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in submit_btn.
function submit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to submit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.calling_figH, 'user_defined_pol_tag_list_intermediary',handles.user_pol_tag_list)
setappdata(handles.calling_figH,'tag_mapping_intermediary',handles.pol_tag_mapping);

combined_map.legend_tags = unique(handles.pol_tag_mapping);
combined_map.collective_tag_map = combined_map.legend_tags;
for i = 1:length(combined_map.collective_tag_map)
    inds = strcmp(handles.pol_tag_mapping,combined_map.collective_tag_map{i});
    combined_map.collective_tag_map{i} = unique({combined_map.collective_tag_map{i},handles.data_pol_tag_list{inds}});
end
setappdata(handles.calling_figH,'combined_tag_map',combined_map);
setappdata(handles.calling_figH,'SEGGA_get_protein_tag_map_from_user_success',true);
close(handles.figure1);

% --- Executes on selection change in select_map_popup.
function select_map_popup_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
ind = get(hObject,'Value');

if (ind==length(contents)) && (strcmp(contents{ind},'new') || strcmp(contents{ind},'NEW'))
    [handles.pol_tag_mapping, handles.user_pol_tag_list] = create_new_map_name(handles);
else
    [handles.pol_tag_mapping] = modify_current_map_name(handles);
end
guidata(handles.figure1, handles);


function tag_map = modify_current_map_name(handles)
contents = cellstr(get(handles.select_map_popup,'string'));
ind = get(handles.select_map_popup,'Value');
ind2 = get(handles.mapped_names_listbox,'Value');
handles.pol_tag_mapping(ind2) = {contents{ind}};
set(handles.mapped_names_listbox,'string',handles.pol_tag_mapping);
tag_map = handles.pol_tag_mapping;

guidata(handles.figure1, handles);

function [tag_map, user_tagl] = create_new_map_name(handles)
display('create_new_map');

new_name = inputdlg('New tag name:',...
             'New Tag Name', [1 50]);
if isempty(new_name)
    display('empty output');
    return
else
    display({'start:',handles.user_pol_tag_list{:}});
    handles.user_pol_tag_list{end+1} = new_name{:};
end
set(handles.select_map_popup,'string',{handles.user_pol_tag_list{:},handles.additional_maps{:}});
ind = get(handles.data_gen_listbox,'Value');
handles.pol_tag_mapping(ind) = new_name;
set(handles.mapped_names_listbox,'string',handles.pol_tag_mapping);
user_tagl = handles.user_pol_tag_list;
tag_map = handles.pol_tag_mapping;
display(handles.user_pol_tag_list)
guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function select_map_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_map_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in mod_list_btn.
function mod_list_btn_Callback(hObject, eventdata, handles)
% hObject    handle to mod_list_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.figure1,'user_defined_pol_tag_list_intermediary',handles.user_pol_tag_list);
tmp_figH = SEGGA_get_protein_tag_list_from_user(); 
tmp_figHandles = guidata(tmp_figH);
tmp_input_data = {handles.user_pol_tag_list,...
                  handles.data_pol_tag_list,...
                  handles.figure1};
SEGGA_get_protein_tag_list_from_user('store_user_input_Callback',tmp_figH,tmp_input_data,tmp_figHandles);
uiwait(tmp_figH);
udp_tag_list = getappdata(handles.figure1,'user_defined_pol_tag_list_intermediary');
handles.user_pol_tag_list = udp_tag_list;
prev_val = get(handles.select_map_popup,'value');
set(handles.select_map_popup,'value',max(min(prev_val,length(handles.user_pol_tag_list)),1));
set(handles.select_map_popup,'string',{handles.user_pol_tag_list{:},handles.additional_maps{:}});

for i = 1:length(handles.pol_tag_mapping)
    tmp_map = handles.pol_tag_mapping{i};
    inds = cellfun(@(x) strcmp(tmp_map,x),handles.user_pol_tag_list);
    if isempty(handles.user_pol_tag_list) || sum(inds)==0
        handles.pol_tag_mapping(i) = {'EXCLUDE'};
    end
end
set(handles.mapped_names_listbox,'string',handles.pol_tag_mapping);
guidata(handles.figure1, handles);