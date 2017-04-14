function varargout = SEGGA_mult_movie_charts(varargin)
% SEGGA_MULT_MOVIE_CHARTS MATLAB code for SEGGA_mult_movie_charts.fig
%      SEGGA_MULT_MOVIE_CHARTS, by itself, creates a new SEGGA_MULT_MOVIE_CHARTS or raises the existing
%      singleton*.
%
%      H = SEGGA_MULT_MOVIE_CHARTS returns the handle to a new SEGGA_MULT_MOVIE_CHARTS or the handle to
%      the existing singleton*.
%
%      SEGGA_MULT_MOVIE_CHARTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_MULT_MOVIE_CHARTS.M with the given input arguments.
%
%      SEGGA_MULT_MOVIE_CHARTS('Property','Value',...) creates a new SEGGA_MULT_MOVIE_CHARTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_mult_movie_charts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_mult_movie_charts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_mult_movie_charts

% Last Modified by GUIDE v2.5 21-Mar-2017 16:36:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_mult_movie_charts_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_mult_movie_charts_OutputFcn, ...
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


% --- Executes just before SEGGA_mult_movie_charts is made visible.
function SEGGA_mult_movie_charts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_mult_movie_charts (see VARARGIN)

% Choose default command line output for SEGGA_mult_movie_charts
handles.output = hObject;
%%%  IF in Root move to Home
if strcmp(pwd,filesep)
    display('moving from root to home');
    cd('~');
end


default_settings.movie_base_dir = pwd;
default_settings.text_string = ''; 
default_settings.shift_hack = 0; 
default_settings.time_window = [-10 30];
default_settings.save_base_dir = pwd;
default_settings.analysis_name = 'default-cmprsn';
default_settings.vars = [];%current_vars_to_plot;
default_settings.vars_to_plot = {}; %names fed to 'set_var_for_plot
default_settings.dirnames = {};
default_settings.fullpath_dirnames = {};
default_settings.groups = [];
default_settings.labels = {};

% for polarity charts
default_settings.polarity_mode_bool = false;
default_settings.user_defined_pol_tag_list = {};
default_settings.data_defined_pol_tag_list = {};
default_settings.pol_tag_mapping = {};
default_settings.pol_combined_tag_mapping = {};

%plotting style
default_settings.plot_style = {'one_fig_per_var'};
default_settings.plot_style_ind = 2;
default_settings.errorbar_style = {'line'};
default_settings.errorbar_style_ind = 1;
default_settings.output_filetypes = {'tif'};
default_settings.figsH = [];
default_settings.target_time_step = [];
default_settings.unifydecimals = [];
default_settings.xtra_txt = [];
default_settings.ylim_input = [];
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
handles.settings = default_settings; %this one changes

currdir = pwd;
set(handles.curr_dir_txt,'string',currdir);
set(handles.all_group_names_txt,'string',default_settings.labels);
set(handles.number_of_groups_text,'string',num2str(numel(default_settings.groups)));
set(handles.curr_group_num_txt,'string',num2str(default_settings.curr_group_number));
set(handles.curr_group_name_txt,'string',default_settings.curr_group_name);
set(handles.curr_group_subgroups_txt,'string',default_settings.curr_subgroup_dirs);
set(handles.curr_group_color_txt,'string',num2str(default_settings.curr_group_color));

set(handles.tag_manage_btn,'visible','off');
set(handles.tag_manage_panel,'visible','off');
update_plot_style_handles(hObject,handles,handles.settings);
update_select_variables_handles(hObject,handles,handles.settings);
update_select_groups_handles(hObject,handles,handles.settings);


% creeating dropdown lists
% plot style
    plot_style_list{1} = 'one_fig_per_group'; %all vars per chart
    plot_style_list{2} = 'one_fig_per_var';  % all groups per chart
    plot_style_list{3} = 'single_movies_group'; %all singles per group per var
    plot_style_list{4} = 'single_movies_var'; %all singles per var
%     plot_style_list{5} = 'one_fig'; %one fig with all
    set(handles.curr_chart_plot_style,'String',plot_style_list);
%     error bar style
    ebar_style_list = {'line'};% (issues with the others) -- %;'solid';'transparent'}; 
    set(handles.error_bar_style_txt,'String',ebar_style_list);
    
% %     make ylim settings invisible
    set(handles.y_lim_text,'visible','off');
    set(handles.changeYlim_button,'visible','off');
    
%     set vars_type_ind
    setappdata(handles.figure1,'vars_type_ind',1);

% UIWAIT makes SEGGA_mult_movie_charts wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_mult_movie_charts_OutputFcn(hObject, eventdata, handles) 
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
cd(handles.settings.movie_base_dir);
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

saved_settings = handles.settings;
save(fullsavepath,'saved_settings');
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
    handles.settings = saved_settings;
end
cd(handles.settings.movie_base_dir);
set(handles.plot_vars_listbox,'string',handles.settings.vars_to_plot);
update_plot_style_handles(hObject,handles,handles.settings);
update_select_variables_handles(hObject,handles,handles.settings);
update_select_groups_handles(hObject,handles,handles.settings);
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
        
	new_ind = length(handles.settings.labels)+1;
    handles.settings.labels = {handles.settings.labels{:},new_group_name{:}};
    

        
        display(new_ind);
        handles.settings.groups(new_ind).dirs = [];
        handles.settings.groups(new_ind).color = str2num(ui_color{:});
        handles.settings.groups(new_ind).label = [new_group_name{:}];

        handles.settings.curr_group_color = str2num(ui_color{:});
        handles.settings.curr_group_number = new_ind;
        handles.settings.curr_group_name = new_group_name;
        
        handles.settings.curr_subgroup_dirs = {};

        set(handles.all_group_names_txt,'value',new_ind);
        update_select_groups_handles(hObject,handles,handles.settings);
        
    end
    
    
    guidata(hObject, handles);

% --- Executes on button press in add_subgroups.
function add_subgroups_Callback(hObject, eventdata, handles)
% hObject    handle to add_subgroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd(get(handles.curr_dir_txt,'string'));
curr_group_number = handles.settings.curr_group_number;
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

            handles.settings.dirnames = {handles.settings.dirnames{:},fold_name_add{:}};
            handles.settings.fullpath_dirnames = {handles.settings.fullpath_dirnames{:},add_subgroup_dir};
            handles.settings.groups(curr_group_number).dirs = ...
            [handles.settings.groups(curr_group_number).dirs, numel(handles.settings.dirnames)];
            
            display([handles.settings.groups(curr_group_number).dirs]);
            display(handles.settings.dirnames);
            handles.settings.curr_subgroup_dirs = {handles.settings.dirnames{handles.settings.groups(curr_group_number).dirs}};
            update_select_groups_handles(hObject,handles,handles.settings);
        else
            display([add_subgroup_dir,' is not a directory']);
            return
        end
    end
    
    if handles.settings.polarity_mode_bool
        [ud_tags,dd_tags,tag_map,combined_map] = reload_protein_tags_from_data(handles);
        handles.settings.data_defined_pol_tag_list = dd_tags;
        handles.settings.user_defined_pol_tag_list = ud_tags;
        handles.settings.pol_tag_mapping = tag_map;
        handles.settings.pol_combined_tag_mapping = combined_map;
    end
    guidata(hObject, handles);

% --- Executes on button press in select_variables_button.
function select_variables_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_variables_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(select_variables_for_SEGGA_multi_charts(handles.figure1));
vars_to_plot = getappdata(handles.figure1,'vars_to_plot');
display(vars_to_plot);
handles.settings.vars_to_plot = vars_to_plot;
set(handles.curr_chart_plot_style,'value',1);



% vars_type =	getappdata(handles.figure1,'vars_type');
% possible_var_types = getappdata(handles.figure1,'possible_var_types');
vars_type_ind = getappdata(handles.figure1,'vars_type_ind');

complete_vars = complete_varnames_for_plots(vars_to_plot);
display(complete_vars);
handles.settings.vars = complete_vars;
handles.settings.vars_type_ind = vars_type_ind;
% 0: sets all missing values to zero
% 1: sets all missing values to closest real value
% 2: sets all missing values to NaN
for i = 1:length(handles.settings.vars)
    handles.settings.vars(i).boundary_l = 2;
    handles.settings.vars(i).boundary_r = 2;
end

reg_time_series_list = {'one_fig_per_group','one_fig_per_var','single_movies_group',...
                  'single_movies_var'};
              %'one_fig'
barchart_list = {'binned_charts_together','binned_charts_separate'};              
pol_list = {'single_movies_var','one_fig_per_var'};
rot_list = {'single_movies_var','one_fig_per_var'};
                            
switch vars_type_ind
    case 1 %basic time series
        handles.settings.polarity_mode_bool = false;
        set(handles.curr_chart_plot_style,'String',reg_time_series_list);
        set(handles.tag_manage_btn,'visible','off');
        set(handles.tag_manage_panel,'visible','off');
    case 2 %bar charts
        handles.settings.polarity_mode_bool = false;
        set(handles.curr_chart_plot_style,'String',barchart_list);
        set(handles.tag_manage_btn,'visible','off');
        set(handles.tag_manage_panel,'visible','off');
    case 3 %polarity
        handles.settings.polarity_mode_bool = true;
        [ud_tags,dd_tags,tag_map,combined_map] = reload_protein_tags_from_data(handles);
        handles.settings.data_defined_pol_tag_list = dd_tags;
        handles.settings.user_defined_pol_tag_list = ud_tags;
        handles.settings.pol_tag_mapping = tag_map;
        handles.settings.pol_combined_tag_mapping = combined_map;
        set(handles.curr_chart_plot_style,'String',pol_list);
        set(handles.tag_manage_btn,'visible','on');
        set(handles.tag_manage_panel,'visible','on');
    case 4 %rotation
        handles.settings.polarity_mode_bool = false;
        set(handles.curr_chart_plot_style,'String',rot_list);
        set(handles.tag_manage_btn,'visible','off');
        set(handles.tag_manage_panel,'visible','off');
        
end

contents = cellstr(get(handles.curr_chart_plot_style,'String'));
handles.settings.plot_style = {contents{get(handles.curr_chart_plot_style,'Value')}};
% handles.settings.plot_style_ind = get(handles.curr_chart_plot_style,'Value');
guidata(hObject, handles);

set(handles.plot_vars_listbox,'string',vars_to_plot);
guidata(hObject, handles);
update_select_variables_handles(hObject,handles,handles.settings);


% --- Executes on button press in view_all_groups_button.
function view_all_groups_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_all_groups_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.settings.groups)
    msg_txt = {'groups data is empty'};
else
    msg_txt = {};
    for i = 1:length(handles.settings.groups)
        msg_txt = {msg_txt{:},...
            '###########################'...
            ['group (',num2str(i),')'],...
            ['---  name: ',handles.settings.groups(i).label],...
            ['---  color: ',num2str(handles.settings.groups(i).color)],...
            '---  subdirs: ',handles.settings.dirnames{handles.settings.groups(i).dirs},...
            '-------------------------------------'...
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
    else
        display([analysis_base_dir,' is not a directory']);
    end
    
    handles.settings.movie_base_dir = pwd;
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

handles.settings.save_base_dir = [save_dir_new,filesep];
set(handles.save_to_dir_txt,'string',handles.settings.save_base_dir);
guidata(hObject, handles);

% --- Executes on selection change in plot_vars_listbox.
function plot_vars_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to plot_vars_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_select_variables_handles(hObject,handles,handles.settings);
% Hints: contents = cellstr(get(hObject,'String')) returns plot_vars_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_vars_listbox


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

make_charts_from_settings(handles.settings);


function update_select_groups_handles(hObject,handles,settings)
currdir = pwd;
set(handles.curr_dir_txt,'string',currdir);
% groups
display(settings);
% update current group name
if settings.curr_group_number > 0
    settings.curr_group_name = {settings.groups(settings.curr_group_number).label};
    handles.settings.curr_group_color = settings.groups(settings.curr_group_number).color;
    settings.curr_group_color = settings.groups(settings.curr_group_number).color;
    set(handles.curr_group_color_txt,'string',num2str(settings.groups(settings.curr_group_number).color));
else
    settings.curr_group_name = 'empty';
end
display(settings.dirnames);
set(handles.number_of_groups_text,'string',num2str(numel(settings.labels)));
set(handles.curr_group_num_txt,'string',num2str(settings.curr_group_number));
set(handles.curr_group_name_txt,'string',settings.curr_group_name);
if ~isempty(handles.settings.groups)
    set(handles.all_group_names_txt,'string',{handles.settings.groups(:).label});
else
    set(handles.all_group_names_txt,'string',{'empty'});
end
% subgroups
if ~isempty(settings.curr_group_color)
    if all(isnumeric(settings.curr_group_color))
        set(handles.curr_group_color_txt,'string',num2str(settings.curr_group_color));
	else
        display('nonnumeric color entered');
        return
    end
else
    set(handles.curr_group_color_txt,'string',settings.curr_group_color);    
end

set(handles.curr_group_subgroups_txt,'string',settings.curr_subgroup_dirs);
set(handles.number_of_groups_text,'string',num2str(numel(settings.groups)));
guidata(hObject, handles);

% display(settings.curr_subgroup_dirs);



% --- Executes on selection change in all_group_names_txt.
function all_group_names_txt_Callback(hObject, eventdata, handles)
% hObject    handle to all_group_names_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns all_group_names_txt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from all_group_names_txt
contents = cellstr(get(hObject,'String'));
sel_group = contents{get(hObject,'Value')};
handles.settings.curr_group_number = get(hObject,'Value');


handles.settings.curr_group_name = sel_group;
handles.settings.curr_group_color = handles.settings.groups(handles.settings.curr_group_number).color;
% handles.settings.sel_group = sel_group;


subgrp_inds = handles.settings.groups(handles.settings.curr_group_number).dirs;
% display(subgrp_inds);
% display(handles.settings.dirnames);

curr_subgroup_dirs = {handles.settings.dirnames{subgrp_inds}};
handles.settings.curr_subgroup_dirs = curr_subgroup_dirs;
update_select_groups_handles(hObject,handles,handles.settings);
guidata(hObject, handles);
% display(sel_group);


% --- Executes on button press in remove_group_botton.
function remove_group_botton_Callback(hObject, eventdata, handles)
% hObject    handle to remove_group_botton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.settings.labels)
    display('no group to remove');    
    return
end

subgrp_inds = handles.settings.groups(handles.settings.curr_group_number).dirs;
display(handles.settings.groups);
% make a list of all group inds
new_group_inds = 1:length(handles.settings.groups);
% remove the current group from that list
new_group_inds(handles.settings.curr_group_number) = [];
% use that to redefine the list of groups
handles.settings.groups = handles.settings.groups(new_group_inds);
handles.settings.labels = {handles.settings.labels{new_group_inds}};

if numel(handles.settings.labels)>0
    handles.settings.curr_group_number = 1;
    set(handles.all_group_names_txt,'string',handles.settings.labels{1});
    set(handles.all_group_names_txt,'value',1);
    handles.settings.curr_subgroup_dirs = {handles.settings.dirnames{handles.settings.groups(1).dirs}};
else
    handles.settings.curr_group_number = 0;
    set(handles.all_group_names_txt,'string',{'empty'});
    set(handles.all_group_names_txt,'value',1);
    handles.settings.curr_subgroup_dirs = {};
end

update_select_groups_handles(hObject,handles,handles.settings);
display(handles.settings.groups);

guidata(hObject, handles);

% --- Executes on button press in edit_group_button.
function edit_group_button_Callback(hObject, eventdata, handles)
% hObject    handle to edit_group_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.settings.labels)
    display('no group to edit');    
    return
end

    prompt={'Enter new group name:','Enter new group color:'};
    name='New Group';
    numlines=1;
    def_name = handles.settings.labels{handles.settings.curr_group_number};
    def_colr = handles.settings.groups(handles.settings.curr_group_number).color;
    new_group_name_full = inputdlg(prompt,name,numlines,[{def_name},num2str(def_colr)]);
    display(new_group_name_full);
    new_group_name = new_group_name_full(1);
    ui_color = new_group_name_full(2);

    if isempty(new_group_name)
        display('no data input');
        return
    else
        

    handles.settings.labels{handles.settings.curr_group_number} = new_group_name{:};
    
    handles.settings.groups(handles.settings.curr_group_number).color = str2num(ui_color{:});
    handles.settings.groups(handles.settings.curr_group_number).label = [new_group_name{:}];

    handles.settings.curr_group_color = str2num(ui_color{:});
    handles.settings.curr_group_name = new_group_name;

    update_select_groups_handles(hObject,handles,handles.settings);
        
    end
    
    
    guidata(hObject, handles);

% --- Executes on button press in clear_all_subgroups_button.
function clear_all_subgroups_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_all_subgroups_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removed_inds = handles.settings.groups(handles.settings.curr_group_number).dirs;
handles.settings.groups(handles.settings.curr_group_number).dirs = [];
handles.settings.curr_subgroup_dirs = {};
update_select_groups_handles(hObject,handles,handles.settings);
guidata(hObject, handles);

if isfield(handles.settings,'polarity_mode_bool') && handles.settings.polarity_mode_bool
    reload_protein_tags_from_data(handles);
end

% Remove from lists of dirs, and update indicies of groups.
% This is contrived because I am keeping the data similar to 
% how we structure it with scripts outside of SEGGA.
for i = 1:length(handles.settings.groups)
    tmp_dir_inds =  handles.settings.groups(i).dirs;
    new_dir_inds = tmp_dir_inds;
    for ii = 1:length(tmp_dir_inds)
        new_dir_inds(ii) = tmp_dir_inds(ii)-sum(tmp_dir_inds(ii)>removed_inds);
    end
    handles.settings.groups(i).dirs = new_dir_inds;
end
handles.settings.dirnames(removed_inds) = [];
handles.settings.fullpath_dirnames(removed_inds) = [];
guidata(hObject, handles);    


function update_select_variables_handles(hObject,handles,settings)
if isempty(settings.vars)
    display('handles.setings.vars is empty');
    return
end
var_contents = cellstr(get(handles.plot_vars_listbox,'String'));
if isempty(var_contents)
    set(handles.curr_var_name,'string','empty');
    set(handles.curr_var_function,'string','empty');
    set(handles.curr_var_post_func,'string','empty');
    set(handles.curr_var_boundary,'string','empty');
    set(handles.var_filename_text,'string','empty');
    set(handles.var_title_text,'string','empty');
    return
end
var_ind = min(length(var_contents),get(handles.plot_vars_listbox,'Value'));
set(handles.plot_vars_listbox,'Value',var_ind);
sel_var_name = var_contents{var_ind};
sel_var_ind = get(handles.plot_vars_listbox,'Value');

display(sel_var_ind);
display(settings);
display(settings.vars);

% variable name
set(handles.curr_var_name,'string',sel_var_name);
% function
if isfield(settings.vars,'func')
    if ~isempty(settings.vars(sel_var_ind).func)
        currfun = func2str(settings.vars(sel_var_ind).func);
    else
        currfun = [];
    end
else
    currfun = [];    
end
    display(currfun);
    set(handles.curr_var_function,'string',currfun);

    %  post function
if isfield(settings.vars,'post_func')
    if ~isempty(settings.vars(sel_var_ind).post_func)
        currpostfun = func2str(settings.vars(sel_var_ind).post_func);
    else
        currpostfun = [];
    end
else
    currpostfun = [];
end
set(handles.curr_var_post_func,'string',currpostfun);

% bounds
currbounds = {num2str(settings.vars(sel_var_ind).boundary_l),num2str(settings.vars(sel_var_ind).boundary_r)};
set(handles.curr_var_boundary,'string',currbounds);


currfilename = {settings.vars(sel_var_ind).file_name};
set(handles.var_filename_text,'string',currfilename);

currtitle = {settings.vars(sel_var_ind).title};
set(handles.var_title_text,'string',currtitle);



% --- Executes on button press in add_smth_to_all.
function add_smth_to_all_Callback(hObject, eventdata, handles)
% hObject    handle to add_smth_to_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_pos = 1:length(handles.settings.vars);
inds_without_post(all_pos) = ~isfield(handles.settings.vars(all_pos),'post_func');
display(inds_without_post);
[handles.settings.vars(inds_without_post).post_func] = deal(@(x)smoothen(x));
guidata(hObject, handles);
update_select_variables_handles(hObject,handles,handles.settings);



function curr_var_boundary_Callback(hObject, eventdata, handles)
% hObject    handle to curr_var_boundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of curr_var_boundary as text
%        str2double(get(hObject,'String')) returns contents of curr_var_boundary as a double



% --- Executes on button press in boundaries_button.
function boundaries_button_Callback(hObject, eventdata, handles)

fprintf('\n 0: missing vals -> 0 \n');
fprintf('\n 1: missing vals -> copy last existing value \n');
fprintf('\n 2: missing vals -> nans \n');

prompt = {'boundary_l','boundary_r'};
dlg_title = 'Set Boundary Conditions';
num_lines = 1;
def = {'2','2'};
boundaries_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(boundaries_uinput);
sel_var_ind = get(handles.plot_vars_listbox,'value');
if ~isempty(handles.settings.vars)
    handles.settings.vars(sel_var_ind).boundary_l = boundaries_uinput{1};
    handles.settings.vars(sel_var_ind).boundary_r = boundaries_uinput{2};
end
guidata(hObject, handles);
update_select_variables_handles(hObject,handles,handles.settings);



function update_plot_style_handles(hObject,handles,settings)
set(handles.curr_chart_plot_style,'value',settings.plot_style_ind);
set(handles.error_bar_style_txt,'value',settings.errorbar_style_ind);
set(handles.filetype_txt,'string',settings.output_filetypes);
set(handles.xlim_text,'string',settings.time_window);
set(handles.y_lim_text,'string',settings.ylim_input);
set(handles.save_to_dir_txt,'string',settings.save_base_dir);



% --- Executes on button press in update_plot_style_panel.
function update_plot_style_panel_Callback(hObject, eventdata, handles)
% hObject    handle to update_plot_style_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_plot_style_handles(hObject,handles,handles.settings)


% --- Executes during object creation, after setting all properties.
function curr_chart_plot_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curr_chart_plot_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%     val = get(handles.curr_chart_plot_style,'Value');
%     plot_style_list = get(Scenario_Lister,'String');
    plot_style_list{1} = 'one_fig_per_group'; %all vars per chart
    plot_style_list{2} = 'one_fig_per_var';  % all groups per chart
    plot_style_list{3} = 'single_movies_group'; %all singles per group per var
    plot_style_list{4} = 'single_movies_var'; %all singles per var
%     plot_style_list{5} = 'one_fig'; %one fig with all
    set(hObject,'String',plot_style_list);
    
    %%not sure why this doesn't work, doing it above in the startup
    %%function as an alternative.


% --- Executes during object creation, after setting all properties.
function error_bar_style_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to error_bar_style_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    ebar_style_list = {'line'}; %% graphics issue with 'solid';'transparent'
    set(hObject,'String',ebar_style_list);


% --- Executes on button press in file_types_button.
function file_types_button_Callback(hObject, eventdata, handles)
% hObject    handle to file_types_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(select_filetypes_for_SEGGA_multi_charts(handles.figure1));
handles.settings.output_filetypes = getappdata(handles.figure1,'output_filetypes');
set(handles.filetype_txt,'string',handles.settings.output_filetypes);
guidata(hObject, handles);


% --- Executes on button press in xlim_button.
function xlim_button_Callback(hObject, eventdata, handles)
% hObject    handle to xlim_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'x_min','x_max'};
dlg_title = 'x axis limits input dialog';
num_lines = 1;
def = {'-10','30'};
xlim_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(xlim_uinput);

if isempty(xlim_uinput)
    
    display('no input received');
    return;
else
    x_min = str2num(xlim_uinput{1});
    x_max = str2num(xlim_uinput{2});
    handles.settings.time_window = [x_min,x_max];
    set(handles.xlim_text,'String',handles.settings.time_window);
end

guidata(hObject, handles);


% --- Executes on button press in changeYlim_button.
function changeYlim_button_Callback(hObject, eventdata, handles)
% hObject    handle to changeYlim_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'y_min','y_max'};
dlg_title = 'y axis limits input dialog';
num_lines = 1;
def = {'0','1'};
ylim_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(ylim_uinput);

if isempty(ylim_uinput)
    
    display('no input received');
    return;
else
    y_min = str2num(ylim_uinput{1});
    y_max = str2num(ylim_uinput{2});
    handles.settings.ylim_input = [y_min,y_max];
    set(handles.y_lim_text,'String',handles.settings.ylim_input);
end
guidata(hObject, handles);

% --- Executes on button press in ylim_checkbox.
function ylim_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ylim_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ylim_checkbox
ylim_on = get(hObject,'Value');
if ylim_on
    if isempty(handles.settings.ylim_input)
        handles.settings.ylim_input = [0,1];
    end
    set(handles.y_lim_text,'String',handles.settings.ylim_input,'visible','on');
    set(handles.changeYlim_button,'visible','on');
else
    handles.settings.ylim_input = [];
    set(handles.y_lim_text,'String',handles.settings.ylim_input,'visible','off');
    set(handles.changeYlim_button,'visible','off');
end    
guidata(hObject, handles);

% --- Executes on selection change in curr_chart_plot_style.
function curr_chart_plot_style_Callback(hObject, eventdata, handles)
% full_style_list = {'one_fig_per_group','one_fig_per_var','single_movies_group',...
%                   'single_movies_var','one_fig','binned_charts_together','binned_charts_separate'};

%%% These sets should already have been updated
%%% When the user selected the variables to plot
%%% Essentially, from here to 'guidata(hObject, handles)'
%%% is redudant. To Do: test functionality without and remove code.
vars_type_ind = getappdata(handles.figure1,'vars_type_ind');
reg_time_series_list = {'one_fig_per_group','one_fig_per_var','single_movies_group',...
                  'single_movies_var'};
              %'one_fig'
barchart_list = {'binned_charts_together','binned_charts_separate'};
pol_list = {'single_movies_var','one_fig_per_var'};
rot_list = {'single_movies_var','one_fig_per_var'};

switch vars_type_ind
    case 1 %basic
        set(handles.curr_chart_plot_style,'String',reg_time_series_list);
    case 2 %barcharts
         set(handles.curr_chart_plot_style,'String',barchart_list);
    case 3 %polarity
         set(handles.curr_chart_plot_style,'String',pol_list);
    case 4 %rotating edges
        set(handles.curr_chart_plot_style,'String',rot_list);
end
guidata(hObject, handles);

contents = cellstr(get(handles.curr_chart_plot_style,'String'));
handles.settings.plot_style = {contents{get(handles.curr_chart_plot_style,'Value')}};
handles.settings.plot_style_ind = get(handles.curr_chart_plot_style,'Value');
guidata(hObject, handles);


% --- Executes on selection change in error_bar_style_txt.
function error_bar_style_txt_Callback(hObject, eventdata, handles)
% hObject    handle to error_bar_style_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns error_bar_style_txt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from error_bar_style_txt
    contents = cellstr(get(hObject,'String'));
    handles.settings.errorbar_style = {contents{get(hObject,'Value')}};
    handles.settings.errorbar_style_ind = get(hObject,'Value');
    guidata(hObject, handles);


% --- Executes on button press in make_stats_button.
function make_stats_button_Callback(hObject, eventdata, handles)
% hObject    handle to make_stats_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'control index','start time','end times'};
dlg_title = 'stat parameters';
num_lines = 1;
def = {'1','0','30'};
stat_params = inputdlg(prompt,dlg_title,num_lines,def);
% figure;
% uicontrol('Parent', gcf,'units','normalized','position',[0.1,0.2,0.3,0.05],...
%     'style','popup','string',{handles.settings.groups(:).label},...
%     'value',1,'callback',@changetype);


if isempty(stat_params)
    
    display('no input received');
    return;
else
    control_ind = str2num(stat_params{1});
    t_start = str2num(stat_params{2});
    t_end = str2num(stat_params{3});
    
    handles.settings.stats_settings.control_ind = control_ind;
    handles.settings.stats_settings.t_start = t_start;
    handles.settings.stats_settings.t_end = t_end;
    
    display('generating stat files');
    SEGGA_script_to_get_pvals(handles.settings);
    display('storing NVals');
    all_dirs_separated = give_structured_dir_list(filesep,handles.settings.fullpath_dirnames,handles.settings.groups); 
    savedir = [handles.settings.save_base_dir,filesep,'stats-and-point-vals',filesep];
    n_values_script_many_dirs(all_dirs_separated,[savedir,'dirNVals.csv'])
end
guidata(hObject, handles);



% --- Executes on button press in node_res_button.
function node_res_button_Callback(hObject, eventdata, handles)
prompt = {'control index'};
dlg_title = 'node resolution parameters';
num_lines = 1;
def = {'1'};
noderes_params = inputdlg(prompt,dlg_title,num_lines,def);
% ftypes = handles.settings.output_filetypes;

if isempty(noderes_params)
    
    display('no input received');
    return;
else
    control_ind = str2num(noderes_params{1});
    handles.settings.control_ind = control_ind;    
    display('generating node resolution files');
    SEGGA_node_res(handles.settings)
end
guidata(hObject, handles);


% --- Executes on button press in shrinks_dist_button.
function shrinks_dist_button_Callback(hObject, eventdata, handles)
SEGGA_shrink_ang_dist(handles.settings)



% --- Executes on button press in compr_vars_button.
function compr_vars_button_Callback(hObject, eventdata, handles)
display('not active (should be hidden)');
return
display('generating phase space files');
SEGGA_compare_vars(handles.settings)


% --- Executes on button press in grow_dist_button.
function grow_dist_button_Callback(hObject, eventdata, handles)
SEGGA_grow_ang_dist(handles.settings)


% --- Executes on button press in tag_manage_btn.
function tag_manage_btn_Callback(hObject, eventdata, handles)
[ud_tags,dd_tags,tag_map,combined_map] = reload_protein_tags_from_data(handles);
handles.settings.data_defined_pol_tag_list = dd_tags;
handles.settings.user_defined_pol_tag_list = ud_tags;
handles.settings.pol_tag_mapping = tag_map;
handles.settings.pol_combined_tag_mapping = combined_map;

[tag_map,combined_tag_map] = get_protein_tags_mapping_from_user(handles);
handles.settings.pol_tag_mapping = tag_map;
handles.settings.pol_combined_tag_mapping = combined_tag_map;
guidata(handles.figure1, handles);

function [ud_tags,dd_tags,tag_map,combined_map] = reload_protein_tags_from_data(handles)

if handles.settings.polarity_mode_bool %this should be true if function is called    
    %%%% Get all the tags that are in the data
    handles.settings.data_defined_pol_tag_list = {};
	all_tags = {};
    if ~isfield(handles.settings.groups,'dirs')
        dirnums = [];
    else
        dirnums = [handles.settings.groups(:).dirs];
    end
    startdir = pwd;
    for ii = dirnums
        cd(handles.settings.fullpath_dirnames{ii});
        sub_dir = pwd;
        dir_names = dir;
        for j = 3:length(dir_names)
            if dir_names(j).isdir
                cd(sub_dir);
                cd(dir_names(j).name)
                if ~isdir('seg')
                    continue
                end
                cd('seg')
%                 display(pwd);
                if ~isempty(dir('edges_info_cell_background.mat'))
                    load edges_info_cell_background channel_info
                    all_tags = unique({channel_info(:).name,all_tags{:}});
                end
            end
        end
    end
    cd(startdir);
    display(all_tags);
    handles.settings.data_defined_pol_tag_list = all_tags;
    if isempty(handles.settings.user_defined_pol_tag_list)
        handles.settings.user_defined_pol_tag_list = all_tags;
    end
    if isempty(handles.settings.pol_tag_mapping) || ...
            (length(handles.settings.pol_tag_mapping)<length(all_tags))
        handles.settings.pol_tag_mapping = all_tags;
    end
end

if (~isfield(handles.settings.pol_combined_tag_mapping,'legend_tags')) ||...
    length(handles.settings.pol_combined_tag_mapping.legend_tags)<length(handles.settings.pol_tag_mapping)
    combined_map.legend_tags = unique(handles.settings.pol_tag_mapping);
    combined_map.collective_tag_map = combined_map.legend_tags;
    for i = 1:length(combined_map.collective_tag_map)
        inds = strcmp(handles.settings.pol_tag_mapping,combined_map.collective_tag_map{i});
        combined_map.collective_tag_map{i} = unique({combined_map.collective_tag_map{i},handles.settings.data_defined_pol_tag_list{inds}});
    end
    handles.settings.pol_combined_tag_mapping = combined_map;
end

ud_tags = handles.settings.user_defined_pol_tag_list;
dd_tags = handles.settings.data_defined_pol_tag_list;
tag_map = handles.settings.pol_tag_mapping;
combined_map = handles.settings.pol_combined_tag_mapping;

guidata(handles.figure1, handles);

    
function [tag_map,combined_tag_map] = get_protein_tags_mapping_from_user(handles)
    %%% Specify the mapping
    setappdata(handles.figure1,'tag_mapping_intermediary',handles.settings.pol_tag_mapping);
    setappdata(handles.figure1,'SEGGA_get_protein_tag_map_from_user_success',false);
    tmp_figH = SEGGA_get_protein_tag_map_from_user();
    tmp_figHandles = guidata(tmp_figH);
    tmp_input_data = {handles.settings.user_defined_pol_tag_list,...
                      handles.settings.data_defined_pol_tag_list,...
                      handles.settings.pol_tag_mapping,...
                      handles.figure1};
    SEGGA_get_protein_tag_map_from_user('store_user_input_Callback',tmp_figH,tmp_input_data,tmp_figHandles);
    uiwait(tmp_figH);
    tag_map = handles.settings.pol_tag_mapping;
    combined_tag_map = handles.settings.pol_combined_tag_mapping;
    if getappdata(handles.figure1,'SEGGA_get_protein_tag_map_from_user_success');
        tag_map = getappdata(handles.figure1,'tag_mapping_intermediary');
        combined_tag_map = getappdata(handles.figure1,'combined_tag_map');    
        handles.settings.pol_tag_mapping = tag_map;
        handles.settings.pol_combined_tag_mapping = combined_tag_map;
        guidata(handles.figure1, handles);
    end


% --- Executes during object creation, after setting all properties.
function node_res_button_CreateFcn(hObject, eventdata, handles)



% --- Executes on button press in bound_conds_all_btn.
function bound_conds_all_btn_Callback(hObject, eventdata, handles)
%Set Boundary Conditions for all
fprintf('\n 0: missing vals -> 0 \n');
fprintf('\n 1: missing vals -> copy last existing value \n');
fprintf('\n 2: missing vals -> nans \n');
prompt = {'boundary_l','boundary_r'};
dlg_title = 'Set Boundary Conditions';
num_lines = 1;
def = {'2','2'};
boundaries_uinput = inputdlg(prompt,dlg_title,num_lines,def);
display(boundaries_uinput);
if ~isempty(handles.settings.vars)
    for i = 1:length(handles.settings.vars)
        handles.settings.vars(i).boundary_l = boundaries_uinput{1};
        handles.settings.vars(i).boundary_r = boundaries_uinput{2};
    end
end
guidata(hObject, handles);
update_select_variables_handles(hObject,handles,handles.settings);
