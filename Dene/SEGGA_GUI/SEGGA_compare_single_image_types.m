function varargout = SEGGA_compare_single_image_types(varargin)
% SEGGA_COMPARE_SINGLE_IMAGE_TYPES MATLAB code for SEGGA_compare_single_image_types.fig
%      SEGGA_COMPARE_SINGLE_IMAGE_TYPES, by itself, creates a new SEGGA_COMPARE_SINGLE_IMAGE_TYPES or raises the existing
%      singleton*.
%
%      H = SEGGA_COMPARE_SINGLE_IMAGE_TYPES returns the handle to a new SEGGA_COMPARE_SINGLE_IMAGE_TYPES or the handle to
%      the existing singleton*.
%
%      SEGGA_COMPARE_SINGLE_IMAGE_TYPES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_COMPARE_SINGLE_IMAGE_TYPES.M with the given input arguments.
%
%      SEGGA_COMPARE_SINGLE_IMAGE_TYPES('Property','Value',...) creates a new SEGGA_COMPARE_SINGLE_IMAGE_TYPES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_compare_single_image_types_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_compare_single_image_types_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_compare_single_image_types

% Last Modified by GUIDE v2.5 21-Dec-2016 13:45:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_compare_single_image_types_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_compare_single_image_types_OutputFcn, ...
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


% --- Executes just before SEGGA_compare_single_image_types is made visible.
function SEGGA_compare_single_image_types_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_compare_single_image_types (see VARARGIN)

% Choose default command line output for SEGGA_compare_single_image_types
handles.output = hObject;



default_settings.movie_base_dir = pwd;
default_settings.save_dir = pwd;
default_settings.analysis_name = 'default-cmprsn';
default_settings.dirnames = {};
default_settings.fullpath_dirnames = {};
% default_settings.groups.dirs = [];
% default_settings.groups.color = [];
% default_settings.groups.label = [];
default_settings.groups = [];
default_settings.labels = {};


default_settings.curr_group_number = 0;
default_settings.curr_group_name = 'none selected';

default_settings.curr_group_color = []; %blue
default_settings.curr_group_number = 0;
% default_settings.curr_group_number = get(handles.all_group_names_txt,'Value');

curr_subgroup_dirs = {};
% curr_subgroup_dirs = default_settings.dirnames{default_settings.groups(default_settings.curr_group_number).dirs};
default_settings.curr_subgroup_dirs = curr_subgroup_dirs;
display(default_settings.curr_subgroup_dirs);

% save('multicharts_defaultsettings','default_settings');
handles.default_settings = default_settings; %this one stays the same
handles.internal_settings = default_settings; %this one changes

currdir = pwd;
set(handles.curr_dir_txt,'string',currdir);
set(handles.save_dir_txt,'string',currdir);
set(handles.all_group_names_txt,'string',default_settings.labels);
set(handles.number_of_groups_text,'string',num2str(numel(default_settings.groups)));
set(handles.curr_group_num_txt,'string',num2str(default_settings.curr_group_number));
set(handles.curr_group_name_txt,'string',default_settings.curr_group_name);
set(handles.curr_group_subgroups_txt,'string',default_settings.curr_subgroup_dirs);
set(handles.curr_group_color_txt,'string',num2str(default_settings.curr_group_color));


update_select_groups_handles(hObject,handles,handles.internal_settings);

guidata(hObject, handles);



% UIWAIT makes SEGGA_compare_single_image_types wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_compare_single_image_types_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in save_settings.
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'settings file name'};
dlg_title = 'Save Settings';
num_lines = [1,100];
t = clock;
fulldate = strrep(datestr(t),{' '},'at');
fulldate = strrep(fulldate,{':'},'-');
def = {[fulldate{:},'_multi_chart_settings']};
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

internal_settings = handles.internal_settings;
save(fullsavepath,'internal_settings');
display(save_settings_name);    
    


% --- Executes on button press in load_settings.
function load_settings_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[settingsfile_to_load,settingsfile_fullpath,FilterIndex]  = uigetfile({'*.mat'});
display(settingsfile_fullpath);

if settingsfile_to_load ==0
    display('user cancelled');
    return
else
    load([settingsfile_fullpath,filesep,settingsfile_to_load]);
    handles.internal_settings = internal_settings;
end
cd(handles.internal_settings.movie_base_dir);

update_select_groups_handles(hObject,handles,handles.internal_settings);
guidata(hObject, handles);
    
    

% --- Executes on button press in add_group_button.
function add_group_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_group_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    cd(get(handles.curr_dir_txt,'string'));
    prompt={'Enter new group name:','Enter new group color:'};
    name='New Group';
    numlines=1;
    new_group_name_full = inputdlg(prompt,name,numlines);
    display(new_group_name_full);
    if isempty(new_group_name_full)
        return
    end
    new_group_name = new_group_name_full(1);
    ui_color = new_group_name_full(2);

    if isempty(new_group_name)
        display('no data input');
        return
    else
        
    if isempty(ui_color)
        ui_color = [0 0 0];
    end
        
	new_ind = length(handles.internal_settings.labels)+1;
    handles.internal_settings.labels = {handles.internal_settings.labels{:},new_group_name{:}};
    

        
        display(new_ind);
        handles.internal_settings.groups(new_ind).dirs = [];
        handles.internal_settings.groups(new_ind).color = str2num(ui_color{:});
        handles.internal_settings.groups(new_ind).label = [new_group_name{:}];

        handles.internal_settings.curr_group_color = str2num(ui_color{:});
        handles.internal_settings.curr_group_number = new_ind;
        handles.internal_settings.curr_group_name = new_group_name;
        
        handles.internal_settings.curr_subgroup_dirs = {};

        set(handles.all_group_names_txt,'value',new_ind);
        update_select_groups_handles(hObject,handles,handles.internal_settings);
        
    end
    
    
    guidata(hObject, handles);

% --- Executes on button press in add_subgroups.
function add_subgroups_Callback(hObject, eventdata, handles)
% hObject    handle to add_subgroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd(get(handles.curr_dir_txt,'string'));
curr_group_number = handles.internal_settings.curr_group_number;
% display(curr_group_number);

[add_subgroup_dirs_many] = uipickfiles_DLF_mod(...
     'FilterSpec',pwd,...
    'Prompt','Select a Sub Groups');
    if isempty(add_subgroup_dirs_many) || (~iscell(add_subgroup_dirs_many) && add_subgroup_dirs_many==0)
        display('no dir selected')
        return
    end
    for i = 1:length(add_subgroup_dirs_many)
        add_subgroup_dir = add_subgroup_dirs_many{i};
        if isdir(add_subgroup_dir)
            fold_name_add = {fliplr(strtok(fliplr(add_subgroup_dir),filesep))};
%             [~, d] = strtok(fliplr(add_group_dir),filesep);
%             new_fold_name_base = fliplr(d);

            handles.internal_settings.dirnames = {handles.internal_settings.dirnames{:},fold_name_add{:}};
            handles.internal_settings.fullpath_dirnames = {handles.internal_settings.fullpath_dirnames{:},add_subgroup_dir};
            handles.internal_settings.groups(curr_group_number).dirs = ...
            [handles.internal_settings.groups(curr_group_number).dirs, numel(handles.internal_settings.dirnames)];
            
            display([handles.internal_settings.groups(curr_group_number).dirs]);
            display(handles.internal_settings.dirnames);
            handles.internal_settings.curr_subgroup_dirs = {handles.internal_settings.dirnames{handles.internal_settings.groups(curr_group_number).dirs}};
            update_select_groups_handles(hObject,handles,handles.internal_settings);
        else
            display([add_subgroup_dir,' is not a directory']);
            return
        end
    end
    
    guidata(hObject, handles);



% --- Executes on button press in view_all_groups_button.
function view_all_groups_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_all_groups_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.internal_settings.groups)
    msg_txt = {'groups data is empty'};
else
    msg_txt = {};
    for i = 1:length(handles.internal_settings.groups)
        msg_txt = {msg_txt{:},...
            ['group (',num2str(i),')'],...
            ['---  name: ',handles.internal_settings.groups(i).label],...
            ['---  color: ',num2str(handles.internal_settings.groups(i).color)],...
            ['---  subdirs: ',handles.internal_settings.dirnames{handles.internal_settings.groups(i).dirs}],...
            ''...
            };
    end
end
            

h = msgbox(msg_txt);


% --- Executes on button press in change_home_dir_button.
function change_home_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_home_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[analysis_base_dir] = uigetdir(...
     pwd,...
    'Select a Base Dir for Analysis');
    if analysis_base_dir == 0
        display('no dir selected')
        return
    end
    if isdir(analysis_base_dir)
        cd(analysis_base_dir);
        set(handles.curr_dir_txt,'string',analysis_base_dir);
        set(handles.save_dir_txt,'string',analysis_base_dir);
    else
        display([analysis_base_dir,' is not a directory']);
    end
    
    handles.internal_settings.movie_base_dir = pwd;
    handles.internal_settings.save_dir = pwd;
    guidata(hObject, handles);

% --- Executes on button press in chang_save_dir_button.
function chang_save_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to chang_save_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_dir_new = uigetdir(pwd,'choose dir to save figures');
display(save_dir_new);
if isempty(save_dir_new)
    display('no dir selected');
    return
end

handles.internal_settings.save_base_dir = [save_dir_new,filesep];
set(handles.save_to_dir_txt,'string',handles.internal_settings.save_base_dir);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function plot_vars_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_vars_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in make_charts_button.
function make_charts_button_Callback(hObject, eventdata, handles)
% hObject    handle to make_charts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

compare_single_images_from_settings(handles.internal_settings);


function update_select_groups_handles(hObject,handles,internal_settings)
currdir = pwd;
set(handles.curr_dir_txt,'string',currdir);
% groups
display(internal_settings);
% update current group name
if internal_settings.curr_group_number > 0
    internal_settings.curr_group_name = {internal_settings.groups(internal_settings.curr_group_number).label};
    handles.internal_settings.curr_group_color = internal_settings.groups(internal_settings.curr_group_number).color;
    internal_settings.curr_group_color = internal_settings.groups(internal_settings.curr_group_number).color;
    set(handles.curr_group_color_txt,'string',num2str(internal_settings.groups(internal_settings.curr_group_number).color));
else
    internal_settings.curr_group_name = 'empty';
end
display(internal_settings.dirnames);
set(handles.number_of_groups_text,'string',num2str(numel(internal_settings.labels)));
set(handles.curr_group_num_txt,'string',num2str(internal_settings.curr_group_number));
set(handles.curr_group_name_txt,'string',internal_settings.curr_group_name);
if ~isempty(handles.internal_settings.groups)
    set(handles.all_group_names_txt,'string',{handles.internal_settings.groups(:).label});
else
    set(handles.all_group_names_txt,'string',{'empty'});
end
% subgroups
if ~isempty(internal_settings.curr_group_color)
    if all(isnumeric(internal_settings.curr_group_color))
        set(handles.curr_group_color_txt,'string',num2str(internal_settings.curr_group_color));
	else
        display('nonnumeric color entered');
        return
    end
else
    set(handles.curr_group_color_txt,'string',internal_settings.curr_group_color);    
end

set(handles.curr_group_subgroups_txt,'string',internal_settings.curr_subgroup_dirs);
set(handles.number_of_groups_text,'string',num2str(numel(internal_settings.groups)));
guidata(hObject, handles);

% display(internal_settings.curr_subgroup_dirs);



% --- Executes on selection change in all_group_names_txt.
function all_group_names_txt_Callback(hObject, eventdata, handles)
% hObject    handle to all_group_names_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns all_group_names_txt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from all_group_names_txt
contents = cellstr(get(hObject,'String'));
sel_group = contents{get(hObject,'Value')};
handles.internal_settings.curr_group_number = get(hObject,'Value');


handles.internal_settings.curr_group_name = sel_group;
handles.internal_settings.curr_group_color = handles.internal_settings.groups(handles.internal_settings.curr_group_number).color;
% handles.internal_settings.sel_group = sel_group;


subgrp_inds = handles.internal_settings.groups(handles.internal_settings.curr_group_number).dirs;
% display(subgrp_inds);
% display(handles.internal_settings.dirnames);

curr_subgroup_dirs = {handles.internal_settings.dirnames{subgrp_inds}};
handles.internal_settings.curr_subgroup_dirs = curr_subgroup_dirs;
update_select_groups_handles(hObject,handles,handles.internal_settings);
guidata(hObject, handles);
% display(sel_group);


% --- Executes on button press in remove_group_botton.
function remove_group_botton_Callback(hObject, eventdata, handles)
% hObject    handle to remove_group_botton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.internal_settings.labels)
    display('no group to remove');    
    return
end

subgrp_inds = handles.internal_settings.groups(handles.internal_settings.curr_group_number).dirs;
display(handles.internal_settings.groups);
% make a list of all group inds
new_group_inds = 1:length(handles.internal_settings.groups);
% remove the current group from that list
new_group_inds(handles.internal_settings.curr_group_number) = [];
% use that to redefine the list of groups
handles.internal_settings.groups = handles.internal_settings.groups(new_group_inds);
handles.internal_settings.labels = {handles.internal_settings.labels{new_group_inds}};

if numel(handles.internal_settings.labels)>0
    handles.internal_settings.curr_group_number = 1;
    set(handles.all_group_names_txt,'string',handles.internal_settings.labels{1});
    set(handles.all_group_names_txt,'value',1);
    handles.internal_settings.curr_subgroup_dirs = {handles.internal_settings.dirnames{handles.internal_settings.groups(1).dirs}};
else
    handles.internal_settings.curr_group_number = 0;
    set(handles.all_group_names_txt,'string',{'empty'});
    set(handles.all_group_names_txt,'value',1);
    handles.internal_settings.curr_subgroup_dirs = {};
end

update_select_groups_handles(hObject,handles,handles.internal_settings);
display(handles.internal_settings.groups);

guidata(hObject, handles);

% --- Executes on button press in edit_group_button.
function edit_group_button_Callback(hObject, eventdata, handles)
% hObject    handle to edit_group_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.internal_settings.labels)
    display('no group to edit');    
    return
end

    prompt={'Enter new group name:','Enter new group color:'};
    name='New Group';
    numlines=1;
    def_name = handles.internal_settings.labels{handles.internal_settings.curr_group_number};
    def_colr = handles.internal_settings.groups(handles.internal_settings.curr_group_number).color;
    new_group_name_full = inputdlg(prompt,name,numlines,[{def_name},num2str(def_colr)]);
    display(new_group_name_full);
    new_group_name = new_group_name_full(1);
    ui_color = new_group_name_full(2);

    if isempty(new_group_name)
        display('no data input');
        return
    else
        

    handles.internal_settings.labels{handles.internal_settings.curr_group_number} = new_group_name{:};
    
    handles.internal_settings.groups(handles.internal_settings.curr_group_number).color = str2num(ui_color{:});
    handles.internal_settings.groups(handles.internal_settings.curr_group_number).label = [new_group_name{:}];

    handles.internal_settings.curr_group_color = str2num(ui_color{:});
    handles.internal_settings.curr_group_name = new_group_name;

    update_select_groups_handles(hObject,handles,handles.internal_settings);
        
    end
    
    
    guidata(hObject, handles);

% --- Executes on button press in clear_all_subgroups_button.
function clear_all_subgroups_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_all_subgroups_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.internal_settings.groups(handles.internal_settings.curr_group_number).dirs = [];
handles.internal_settings.curr_subgroup_dirs = {};
update_select_groups_handles(hObject,handles,handles.internal_settings);
guidata(hObject, handles);



% --- Executes on button press in chng_save_dir_btn.
function chng_save_dir_btn_Callback(hObject, eventdata, handles)
% hObject    handle to chng_save_dir_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[save_dir] = uigetdir(...
     pwd,...
    'Select a Base Dir for Analysis');
    if save_dir == 0
        display('no dir selected')
        return
    end
    if isdir(save_dir)
        set(handles.save_dir_txt,'string',save_dir);
    else
        display([save_dir,' is not a directory']);
    end
    
    handles.internal_settings.save_dir = save_dir;
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function curr_group_subgroups_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curr_group_subgroups_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
