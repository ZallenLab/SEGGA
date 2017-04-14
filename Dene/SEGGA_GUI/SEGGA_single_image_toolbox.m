function varargout = SEGGA_single_image_toolbox(varargin)
% SEGGA_SINGLE_IMAGE_TOOLBOX MATLAB code for SEGGA_single_image_toolbox.fig
%      SEGGA_SINGLE_IMAGE_TOOLBOX, by itself, creates a new SEGGA_SINGLE_IMAGE_TOOLBOX or raises the existing
%      singleton*.
%
%      H = SEGGA_SINGLE_IMAGE_TOOLBOX returns the handle to a new SEGGA_SINGLE_IMAGE_TOOLBOX or the handle to
%      the existing singleton*.
%
%      SEGGA_SINGLE_IMAGE_TOOLBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGGA_SINGLE_IMAGE_TOOLBOX.M with the given input arguments.
%
%      SEGGA_SINGLE_IMAGE_TOOLBOX('Property','Value',...) creates a new SEGGA_SINGLE_IMAGE_TOOLBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SEGGA_single_image_toolbox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SEGGA_single_image_toolbox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SEGGA_single_image_toolbox

% Last Modified by GUIDE v2.5 30-Mar-2017 16:16:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SEGGA_single_image_toolbox_OpeningFcn, ...
                   'gui_OutputFcn',  @SEGGA_single_image_toolbox_OutputFcn, ...
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


% --- Executes just before SEGGA_single_image_toolbox is made visible.
function SEGGA_single_image_toolbox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SEGGA_single_image_toolbox (see VARARGIN)

% Choose default command line output for SEGGA_single_image_toolbox
handles.output = hObject;
set(handles.curr_dir_txt,'string',pwd);
analysis_dirs_fullpaths = {};
setappdata(handles.figure1,'analysis_dirs_fullpaths',analysis_dirs_fullpaths);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SEGGA_single_image_toolbox wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SEGGA_single_image_toolbox_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in single_acquire.
function single_acquire_Callback(hObject, eventdata, handles)
% hObject    handle to single_acquire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
source_base = pwd;
files_fullpaths = uipickfiles_DLF_mod('FilterSpec',source_base,'out','struct');
display(files_fullpaths);
if isempty(whos('files_fullpaths')) || isempty(files_fullpaths)
    display('no files selected');
    return
end
dest_fold = uigetdir(pwd,'select destination to place copy of files');
if isempty(dest_fold)
    display('no destination selected');
    return
end
cd(dest_fold)
set(handles.curr_dir_txt,'string',pwd);
for i = 1:length(files_fullpaths)
    temp_org = files_fullpaths(i).name;
    just_file = fliplr(strtok(fliplr(temp_org),filesep));
    temp_dest = [dest_fold,filesep,just_file];
    copyfile(temp_org,temp_dest);
end

% --- Executes on button press in imgs2foldrs_button.
function imgs2foldrs_button_Callback(hObject, eventdata, handles)
% hObject    handle to imgs2foldrs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
make_dittoname_folder_for_images(pwd)
set(handles.curr_dir_txt,'string',pwd);

% --- Executes on button press in splitChans_button.
function splitChans_button_Callback(hObject, eventdata, handles)
% hObject    handle to splitChans_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
search_dir = pwd;
d = dir(search_dir);
isub = [d(:).isdir]; % returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

keep_originals_bool = get(handles.keep_originals_chckbox,'Value');

for i = 1:length(nameFolds)
    in_dir = [search_dir,filesep,nameFolds{i}];
    single_image_to_sep_chans_for_analysis(in_dir,keep_originals_bool);
end
cd(search_dir);
 set(handles.curr_dir_txt,'string',pwd);   

% --- Executes on button press in imgproc_and_seg_button.
function imgproc_and_seg_button_Callback(hObject, eventdata, handles)
% hObject    handle to imgproc_and_seg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
play_movie;

% --- Executes on button press in corrections_button.
function corrections_button_Callback(hObject, eventdata, handles)
% hObject    handle to corrections_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
commandsui;
set(handles.curr_dir_txt,'string',pwd);

% --- Executes on button press in analyze_button.
function analyze_button_Callback(hObject, eventdata, handles)
startdir = pwd;

%%% prepare batch analysis
batch_bool = get(handles.batch_chckbox,'value');
if batch_bool
    
    analysis_dirs = getappdata(handles.figure1,'analysis_dirs_fullpaths');
    display(['--- +++ analyzing ',num2str(length(analysis_dirs)),' images +++ ---']);
    if isempty(analysis_dirs)
        analysis_dirs = {[pwd,filesep,'..',filesep]};
    end
else
    analysis_dirs = {[pwd,filesep,'..',filesep]};
end

for j = 1:length(analysis_dirs)
    cd(analysis_dirs{j});
    [~, deepestFolder, ~] = fileparts(pwd);
    display(['currdir: ',deepestFolder]);
    search_dir = pwd;

    if ~strcmp(deepestFolder,'seg')
        %for many dirs (above the seg location) -> must go in
        d = dir(search_dir);
        isub = [d(:).isdir]; % returns logical vector
        nameFolds = {d(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
    else
        %for one dir (inside the seg location) -> must go up
        cd('..');
        d = dir(search_dir);
        isub = [d(:).isdir]; % returns logical vector
        nameFolds = {d(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
    end

    pol_bool = get(handles.pol_analysis_btn,'Value');
    edge_opt_bool = get(handles.edge_opt_chckbox,'value');
    
    if any(strcmp(nameFolds,'seg'))
        cd('seg');
    else
        %try going up one directory if seg not found
        cd('..');
        [~, deepestFolder, ~] = fileparts(pwd);
        if ~strcmp(deepestFolder,'seg')
            display('seg folder not found - analyze dirs one at a time if batch mode is not working');
            continue
        end
    end
    
    analyze_single_image;
    
    if ~pol_bool        
        continue
    end
    display('continuing with polarity analysis...');    
    fixed_image_polarity_analysis_script_extern(pwd,pol_bool,edge_opt_bool);
    clear('seq', 'levels_all', 'background_levels',  ...
     'channel_info', 'edges', 'x1', 'x2', 'y1', 'y2',...
     'data','save_name');
    cd('..');

    for i = 1:length(nameFolds)

        % duplicate files for other folders
        % (not efficient, need to recode so 'seg' folder files
        %  can map to other images - to do at a later time.)
        color_search_dir = pwd;
        d_colors = dir(color_search_dir);
        isub = [d_colors(:).isdir]; % returns logical vector
        nameFoldsColors = {d_colors(isub).name}';
        allpossible_colors = {'red','green','blue'};
        color_dirs = intersect(nameFoldsColors,allpossible_colors);


        source_seg_dir = [pwd,filesep,'seg'];
        for c_i = 1:length(color_dirs)
            color_ind = color_dirs{c_i};
            dest_color_dir = [pwd,filesep,color_ind];
            distribute_seg_files_to_monochrome_dir(source_seg_dir, dest_color_dir, color_ind)
        end

    end
    cd(search_dir);
    set(handles.curr_dir_txt,'string',pwd);
end
cd(startdir);
display('+++ --- finished analysis --- +++');


% --- Executes on button press in change_dir_button.
function change_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
home_fold = uigetdir(pwd,'select destination to place copy of files');
if isempty(home_fold)
    display('no destination selected');
    return
end
cd(home_fold);
set(handles.curr_dir_txt,'string',pwd);


% --- Executes during object creation, after setting all properties.
function single_acquire_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgs2foldrs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function imgs2foldrs_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgs2foldrs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.curr_dir_txt,'string',pwd);


% --- Executes on button press in charts_and_imgs_button.
function charts_and_imgs_button_Callback(hObject, eventdata, handles)
% hObject    handle to charts_and_imgs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_bool = get(handles.batch_chckbox,'value');
if batch_bool
    
    analysis_dirs = getappdata(handles.figure1,'analysis_dirs_fullpaths');
    display(['--- +++ analyzing ',num2str(length(analysis_dirs)),' images +++ ---']);
    if isempty(analysis_dirs)
        analysis_dirs = {[pwd,filesep,'..',filesep]};
    end
else
    analysis_dirs = {[pwd,filesep,'..',filesep]};
end

for j = 1:length(analysis_dirs)
    cd(analysis_dirs{j});
    [~, deepestFolder, ~] = fileparts(pwd);
    display(['currdir: ',deepestFolder]);
    search_dir = pwd;

    if ~strcmp(deepestFolder,'seg')
        %for many dirs (above the seg location) -> must go in
        d = dir(search_dir);
        isub = [d(:).isdir]; % returns logical vector
        nameFolds = {d(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
    else
        %for one dir (inside the seg location) -> must go up
        cd('..');
        d = dir(search_dir);
        isub = [d(:).isdir]; % returns logical vector
        nameFolds = {d(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
    end


    
    colornames = {'*red','*green','*blue'};
    % colornames = {'*blue'};


%     for foldind = 1:length(nameFolds)
%         startdir = pwd;
%         cd(nameFolds{foldind});
%         homedir = pwd;
        for colorind = 1:length(colornames)
            alldirsrun = dir(colornames{colorind});
            if ~isempty(alldirsrun) && isdir(alldirsrun.name)
                for i = 1:length(alldirsrun)
                    cd(alldirsrun(i).name)
                    display(pwd);

                    try
                        %%% initialize polarity colormap range options
                        pol_cmap_opts.type = 'Adaptive';
                        pol_cmap_opts.val = 0;
                        pol_cmap_opts.bounds = [];
                        setappdata(handles.figure1,'p_opts',pol_cmap_opts);

                        %%% Uncomment these lines to allow the user to choose
                        %%% method
    %                     choose_cmap_range_opts_dialog(handles.figure1);
    %                     pol_cmap_opts = getappdata(handles.figure1,'p_opts');
    %                     display(pol_cmap_opts);

                        add_on_analysis_fixed_polarity_image(pol_cmap_opts);
                    catch
                        warning(['could not run analysis on dir: ',pwd]);
    %                 add_on_analysis_fixed_polarity_image_in_situ;
                    end
                    cd(search_dir);
                end
            end
        end

        cd(search_dir);
end
% end


% --- Executes on button press in compare_types_button.
function compare_types_button_Callback(hObject, eventdata, handles)
% hObject    handle to compare_types_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SEGGA_compare_single_image_types;


% --- Executes on button press in check_list_button.
function check_list_button_Callback(hObject, eventdata, handles)
% hObject    handle to check_list_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
P = mfilename('fullpath');
reversestr = fliplr(P);
[justfile, justdirpath] = strtok(reversestr,filesep);
justfile = fliplr(justfile);
base_dir = fliplr(justdirpath);
popupmessage('SEGGA_fixed_analysis_checklist.txt');


% --- Executes on button press in pol_analysis_btn.
function pol_analysis_btn_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
set(handles.basic_analysis_btn,'Value',1-v);
if v
    set(handles.edge_opt_chckbox,'Visible','on');
else
    set(handles.edge_opt_chckbox,'Visible','off');
end
guidata(hObject, handles);

% --- Executes on button press in basic_analysis_btn.
function basic_analysis_btn_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
set(handles.pol_analysis_btn,'Value',1-v);
if v
    set(handles.edge_opt_chckbox,'Visible','off');
else
    set(handles.edge_opt_chckbox,'Visible','on');
end
guidata(hObject, handles);

% --- Executes on button press in edge_opt_chckbox.
function edge_opt_chckbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in batch_chckbox.
function batch_chckbox_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v
    set(handles.sel_dirs_for_batch_btn,'Visible','on');
else
    set(handles.sel_dirs_for_batch_btn,'Visible','off');
end


% --- Executes on button press in sel_dirs_for_batch_btn.
function sel_dirs_for_batch_btn_Callback(hObject, eventdata, handles)
analysis_dirs_fullpaths = uipickfiles_DLF_mod('FilterSpec',pwd,'out','struct');
% display(analysis_dirs_fullpaths);
if isempty(analysis_dirs_fullpaths) || ~isfield(analysis_dirs_fullpaths(1),'name')
    display('user cancelled, quitting');
    setappdata(handles.figure1,'analysis_dirs_fullpaths',analysis_dirs_fullpaths);
else
    analysis_dirs_fullpaths = {analysis_dirs_fullpaths(:).name};
%     % check if current dir is a segmentation dir
%     if ~isempty(dir('poly_seq.mat'))
%         analysis_dirs_fullpaths = {analysis_dirs_fullpaths{:},pwd};
%     end
%     display(analysis_dirs_fullpaths);
    setappdata(handles.figure1,'analysis_dirs_fullpaths',analysis_dirs_fullpaths);
end


% --- Executes on button press in keep_originals_chckbox.
function keep_originals_chckbox_Callback(hObject, eventdata, handles)
% hObject    handle to keep_originals_chckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keep_originals_chckbox
