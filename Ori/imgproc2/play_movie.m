function varargout = play_movie(varargin)
% PLAY_MOVIE M-file for play_movie.fig
%      PLAY_MOVIE, by itself, creates a new PLAY_MOVIE or raises the existing
%      singleton*.
%
%      H = PLAY_MOVIE returns the handle to a new PLAY_MOVIE or the handle to
%      the existing singleton*.
%
%      PLAY_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAY_MOVIE.M with the given input arguments.
%
%      PLAY_MOVIE('Property','Value',...) creates a new PLAY_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before play_movie_OpeningFunction gets called.
%      An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to play_movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help play_movie

% Last Modified by GUIDE v2.5 11-Jan-2017 12:55:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @play_movie_OpeningFcn, ...
                   'gui_OutputFcn',  @play_movie_OutputFcn, ...
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


% --- Executes just before play_movie is made visible.
function play_movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to play_movie (see VARARGIN)

% Choose default command line output for play_movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes play_movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setup_dir(handles);





function setup_dir(handles, directory, wildcard)
setappdata(handles.figure1, 'channel_settings_filename', 'channel_image_settings.txt')
if nargin < 2
    directory = pwd;
end
cd(directory);
if nargin > 2 && ~isempty(wildcard)
    files = dir(wildcard);
else
    files = dir('*.tif');
end
if ~length(files)
    return
end
ind = true(1, length(files));
for i = 1:length(files)
    if isempty(strfind(files(i).name, '_T')) || isempty(strfind(files(i).name, '_Z'));
        ind(i) = 0;
    end
end
files = files(ind);
frames = [];


if isempty(files)
    cmd_w_str = 'no files found... quitting';
    cprintf('*[1,0.5,0]',[cmd_w_str,'\n']);
    cmd_w_str = 'files need pattern: ***_T***_Z***.tif';
    cprintf('*[0.7,0.3,0]',[cmd_w_str,'\n']);
    ST = dbstack;
    display(ST(1));
    return
end

for i = 1:length(files)
    [z t] = get_file_nums(files(i).name);
    frames(i).z = z;
    frames(i).t = t;
    frames(i).name = files(i).name;
    frame_num(t,z) = i;
end
inv_frame_num = [frames.t]';
inv_frame_num(:, 2) = [frames.z];

if ~length(frames)
    return
end

setappdata(handles.figure1, 'frames', frames);
setappdata(handles.figure1, 'frame_num', frame_num);
setappdata(handles.figure1, 'inv_frame_num', inv_frame_num);
setappdata(handles.figure1, 'directory', directory);
setappdata(handles.figure1, 'play_dir', directory);
setappdata(handles.figure1, 'first_time', true);
if ~isappdata(handles.figure1, 'image_nhood_radius')
    setappdata(handles.figure1, 'image_nhood_radius', 10);
end
if ~isappdata(handles.figure1, 'thresh_factor')
    setappdata(handles.figure1, 'thresh_factor', 1);
end
if ~isappdata(handles.figure1, 'limit_within')
    setappdata(handles.figure1, 'limit_within', false);
end
if ~isappdata(handles.figure1, 'guassian_size')
    setappdata(handles.figure1, 'guassian_size', 3);
end
if ~isappdata(handles.figure1, 'guassian_std')
    setappdata(handles.figure1, 'guassian_std', 3);
end
if ~isappdata(handles.figure1, 'intensity_percentile')
    setappdata(handles.figure1, 'intensity_percentile', 0.975);
end

proj_filename = fullfile(pwd, 'images_projection_info.mat');
setappdata(handles.figure1, 'proj_info_filename', proj_filename);

if length(dir(proj_filename))
    load(proj_filename)
    setappdata(handles.figure1, 'proj_options', proj_options)
    setappdata(handles.figure1, 'proj_meth', proj_meth)
else
    projection_details(handles, 'init')
end

setappdata(handles.figure1, 'channel1_factor', 1);
setappdata(handles.figure1, 'channel1_shift_factor', 0);

for ch = 1:3
    set(handles.(['channel' num2str(ch)]), 'value', 0)
end

% load_channel_tracking(handles, 1, frames(1).name, directory);
if nargin > 2 %ie, called from load_channel1_menu %% not used anymore
    return
end




min_t = min([frames(:).t]);
max_t = max([frames(:).t]);
min_z = min([frames(:).z]);
max_z = max([frames(:).z]);

for z = min_z:max_z
    if frame_num(min_t,z)
        break
    end
end
z_for_t = ones(1,  max_t) * z;

setappdata(handles.figure1, 'z_for_t', z_for_t);
z_shift_file = 'z_shift.txt';
setappdata(handles.figure1, 'z_shift_file', z_shift_file);
setappdata(handles.figure1, 'hide_poly', false);
if isappdata(handles.figure1, 'poly_seq')
    rmappdata(handles.figure1, 'poly_seq');
end
if isappdata(handles.figure1, 'poly_frame_ind')
    rmappdata(handles.figure1, 'poly_frame_ind');
end

z_shift_file = getappdata(handles.figure1, 'z_shift_file');
if length(dir(fullfile(directory, z_shift_file)))
    import_z_from_files(handles)
end

if max_t == min_t
    set(handles.frame_slider, 'enable', 'off')
else
    set(handles.frame_slider, 'enable', 'on')
    set(handles.frame_slider, 'max', max_t, 'min', min_t, 'value', min_t);
    set(handles.frame_slider, 'SliderStep', [min(1, 1/(max_t - min_t))  min(1, 10/(max_t - min_t))]);
end

z_for_t = getappdata(handles.figure1, 'z_for_t');

if min_z == max_z
    set(handles.z_slider, 'enable', 'off')
else
    set(handles.z_slider, 'enable', 'on')
    set(handles.z_slider, 'min', -max_z, 'max', -min_z, 'value', -z_for_t(min_t));
    set(handles.z_slider, 'SliderStep', [min(1, 1/(max_z - min_z))  min(1, 5/(max_z - min_z))]);
end
set(handles.current_dir, 'string', directory);

setappdata(handles.figure1, 'channel2_factor', 1);
setappdata(handles.figure1, 'channel2_shift_factor', 0);
setappdata(handles.figure1, 'channel3_factor', 1);
setappdata(handles.figure1, 'channel3_shift_factor', 0);


channel = cell(1, 3);
z_shift_channel(1:3) = {'0'};
if length(dir(fullfile(directory, 'play_movie_channels.m')))
	play_movie_channels %defines channel1, channel2 and channel3
end
for ch = 1:3
    set(handles.(['z_shift_ch' num2str(ch)]), 'string', z_shift_channel{ch});
end

multi = false;
for ch = 1:3
    multi = multi | set_multi_channel_from_file(handles, ch, channel, min_t, z_for_t(min_t));
end


% 
% set(handles.channel1, 'value', true);
% set(handles.channel2, 'value', false);
% set(handles.channel3, 'value', false);
set_multi_channel(handles, multi); %Calls up_fr. %Should be called after
% everything else is set up in setup_dir


% get_file_nums has its own separate file now

% function [z_num, t_num] = get_file_nums(filename)
% num_length = 4;
% c_ind = strfind(filename, '_T');
% if isempty(c_ind)
%     msg = ['File name format error. Could not find ''_T'' in file name ' ...
%         'and assign a frame number ' filename];
%     msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
%     waitfor(msgboxH)
%     return
% end
% i = 1;
% t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
% while isempty(t_num) && i < length(c_ind)
%     i = i+1;
%     t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
% end
% if isempty(t_num)
%     msg = ['could not parse numbers in filename, ' filename]
%     disp msg
% end
% 
% c_ind = strfind(filename, '_Z');
% if isempty(c_ind)
%     msg = ['File name format error. Could not find ''_Z'' in file name ' ...
%         'and assign a Z slice number'];
%     msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
% end
% i = 1;
% z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
% while isempty(z_num) && i < length(c_ind)
%     i = i+1;
%     z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
% end
% if isempty(t_num)
%     msg = ['could not parse numbers in filename, ' filename]
%     disp msg
% end

% --- Outputs from this function are returned to the command line.
function varargout = play_movie_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(hObject, 'Value', round(get(hObject,'Value')));
up_fr(handles, get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in play_forward.
function play_forward_Callback(hObject, eventdata, handles)
% hObject    handle to play_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play_forward

if ~get(hObject, 'value')
    return
end
t1 = clock;
set(handles.play_backward, 'value', 0);
i = str2double(get(handles.frame_number, 'String'));
count = 0;
while get(hObject, 'value')
    i = str2double(get(handles.frame_number, 'String'));
    i = i + 1;
    if i > get(handles.frame_slider, 'max')
        i = get(handles.frame_slider, 'min');
    end
    time_diff = etime(clock, t1);
    pause(count*0.1 - time_diff)
    up_fr(handles, i)
    if ~ishandle(hObject)
        break
    end
    count = count + 1;
end


% --- Executes on button press in play_backward.
function play_backward_Callback(hObject, eventdata, handles)
% hObject    handle to play_backward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play_backward
if ~get(hObject, 'value')
    return
end
set(handles.play_forward, 'value', 0);
i = str2double(get(handles.frame_number, 'String'));
while get(hObject, 'value')
    i = str2double(get(handles.frame_number, 'String'));
    i = i - 1;
    if i < get(handles.frame_slider, 'min')
        i = get(handles.frame_slider, 'max');
    end
    up_fr(handles, i)
    if ~ishandle(hObject)
        break
    end
end


function frame_number_Callback(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_number as text
%        str2double(get(hObject,'String')) returns contents of frame_number as a double

val = min(max(round(str2double(get(hObject,'String'))), ...
    get(handles.frame_slider, 'Min')), get(handles.frame_slider, 'Max'));
set(hObject, 'String', val);
set(handles.frame_slider, 'Value', val);
up_fr(handles, val);

% --- Executes during object creation, after setting all properties.
function frame_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply_back.
function apply_back_Callback(hObject, eventdata, handles)
% hObject    handle to apply_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of apply_back
update_z(handles)

% --- Executes on button press in apply_for.
function apply_for_Callback(hObject, eventdata, handles)
% hObject    handle to apply_for (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of apply_for
update_z(handles)

% --- Executes on slider movement.
function z_slider_Callback(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(hObject, 'Value', round(get(hObject,'Value')));
set(handles.z_number, 'string', -get(hObject,'Value'));
update_z(handles)

function update_z(handles)
z_for_t = getappdata(handles.figure1, 'z_for_t');
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.z_number, 'string'));
z_for_t(t) = z;
if get(handles.apply_for, 'value')
    z_for_t(t:end) = z;
end
if get(handles.apply_back, 'value')
    z_for_t(1:t) = z;
end
setappdata(handles.figure1, 'z_for_t', z_for_t);
up_fr(handles, t);

% % % show z_for_t and z_shift
if false
    display(['z_for_t: ',num2str(z_for_t)]);
    min_t = get(handles.frame_slider, 'min');
    z_shift_for_t = z_for_t - z_for_t(min_t);
    display(['z_shift_for_t: ',num2str(z_shift_for_t)]);
end


% --- Executes during object creation, after setting all properties.
function z_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in batch_noise.
function yadda 
% hObject    handle to batch_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function batch_noise_Callback(hObject, eventdata, handles)
% hObject    handle to batch_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


home_dir = getappdata(handles.figure1, 'directory');
z_shift_file = getappdata(handles.figure1, 'z_shift_file');

z_shift = ~get(handles.no_z_shift, 'value');
z_shift_for_t = 0;
min_t = get(handles.frame_slider, 'min');
if get(handles.z_shift_apply_to_radio_button, 'value')
    min_t = str2double(get(handles.t_from, 'String'));
end

if z_shift 
%     if length(dir(fullfile(directory, z_shift_file)))
%         [aa bb] = textread(z_shift_file, '%d = %d', 'commentstyle', 'matlab');
%         z_shift_for_t(aa) = bb;
%     else
        z_shift_for_t = getappdata(handles.figure1, 'z_for_t');
        z_shift_for_t = z_shift_for_t - z_shift_for_t(min_t);
%     end
end

frames = getappdata(handles.figure1, 'frames');
frame_num = getappdata(handles.figure1, 'frame_num');
[i j] = find(frame_num);

min_t = str2double(get(handles.t_from, 'String'));
max_t = str2double(get(handles.t_to, 'String'));
min_z = str2double(get(handles.z_from, 'String'));
max_z = str2double(get(handles.z_to, 'String'));

tic
areas = getappdata(handles.figure1, 'areas');

drawnow
OVERWRITE = strcmpi(get(handles.overwrite_seg_menu, 'checked'), 'on');
OVERWRITE_images = strcmpi(get(handles.overwrite_bnr_menu, 'checked'), 'on');
save_images = strcmpi(get(handles.save_projected_images_menu, 'checked'), 'on');
const_z_copy = strcmpi(get(handles.const_z_copy_menu, 'checked'), 'on');
NO_LAYERS = strcmpi(get(handles.no_layers_menu, 'checked'), 'on');
options.update_positions = strcmpi(get(handles.reposition_nodes_menu, 'checked'), 'on');
options.local_mean = strcmpi(get(handles.subtract_background_during_menu, 'checked'), 'on');
options.thresh_factor = getappdata(handles.figure1, 'thresh_factor');
options.image_nhood_radius =  getappdata(handles.figure1, 'image_nhood_radius');
options.limit_within = getappdata(handles.figure1, 'limit_within');
options.intensity_percentile = getappdata(handles.figure1, 'intensity_percentile');
func_name = get(handles.thresh_function, 'string');
options.thresh_function = func_name{get(handles.thresh_function, 'value')};
func_name = get(handles.proj_func, 'string');
proj_method = func_name{get(handles.proj_func, 'value')};


if save_images && ~isdir(fullfile(home_dir,'bnr'))
    mkdir(fullfile(home_dir, 'bnr'))
end
if save_images && const_z_copy && ~isdir(fullfile(home_dir, '9999'))
    mkdir(fullfile(home_dir, '9999'))
end
im_written = false;
for t = min_t:max_t
    t
    toc
    for z_cnt = min_z : max_z 
        if any(z_shift_for_t)
            z = z_cnt + z_shift_for_t(t);
        else
            z = z_cnt;
        end
        if frame_num(t,z)
            if ~NO_LAYERS
                img = project_along_z(t,z, proj_method, frames, frame_num, handles);
                new_img_filename = fullfile(home_dir, 'bnr', frames(frame_num(t,z)).name);
                if save_images && (~length(dir(new_img_filename)) || OVERWRITE_images)
                   imwrite(img, new_img_filename, 'tiff');
                    if const_z_copy
                        const_z_filename = fullfile(home_dir, '9999', frames(frame_num(t,z)).name);
                        const_z_filename = put_file_nums(const_z_filename, [], 9999);
                        imwrite(img, const_z_filename, 'tiff');
                    end
                   projection_details(handles, 'write', t, z, proj_method)
                   im_written = true;
                end
            else
                img = imread(frames(frame_num(t,z)).name);
            end
            if strcmpi(get(handles.auto_limit_area_menu, 'checked'), 'on')
                wa = limit2embryo(img);
                areas(t,z).wa = wa;
                setappdata(handles.figure1, 'areas', areas);
            else
                if isappdata(handles.figure1, 'poly_seq');
                    poly_seq = getappdata(handles.figure1, 'poly_seq');
                    poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
%                     [dummy poly_ind] = min(abs(frame_num(t,z) - poly_frame_ind));
                    inv_frame_num = getappdata(handles.figure1,'inv_frame_num');
                    [poly dummy] = get_poly_for_frame(frame_num(t,z), poly_frame_ind, poly_seq, inv_frame_num);
                    X = poly.x;
                    Y = poly.y;
                    X = reshape(X, [], 1);
                    Y = reshape(Y, [], 1);
                    wa = [X Y];
                else
                    [imgx, imgy] = size(img);
                    wa = [1 1; imgx 1; imgx imgy; 1 imgy];
                end
            end
            options.workingarea = wa;
            options.frames = frames;
            options.frames_num = frame_num;
            options.z = z;
            options.t = t;
            
            
            filenames{1} = frames(frame_num(t,z)).name;
            [pathstr, name, ext] = fileparts(filenames{1});
            
            options.original_file = filenames{1};
            
            casename = [name '.mat'];
            if length(dir(fullfile(home_dir, casename))) && ~OVERWRITE
               continue
            end
            
            cellgeom = segment_image(img, options);
            save(fullfile(home_dir, casename), 'cellgeom', 'casename', 'filenames');            
            up_fr(handles, t, z, true)
        end
    end
end
toc
if im_written
    write_image_log([], fullfile(home_dir, 'bnr'), min_z, max_z, min_t, max_t, proj_method, ...
        handles)
end
figure(handles.figure1);
h = msgbox('Done!');
waitfor(h);

function up_fr(handles, t, z, geom)
persistent imageH wallH poly_seqH

currentfig = handles.figure1;
current_frame = str2double(get(handles.frame_number, 'string'));

frames = getappdata(handles.figure1, 'frames');
frame_num = getappdata(handles.figure1, 'frame_num');
z_for_t = getappdata(handles.figure1, 'z_for_t');
directory = getappdata(handles.figure1, 'play_dir');
home_dir = getappdata(handles.figure1, 'directory');
        
if nargin < 2
    t = get(handles.frame_slider, 'value');
end
if nargin < 3
    z = z_for_t(t);
end
if nargin < 4
    geom = false;
end
info_text_msg = '';
if t > 0 && z > 0 && t <= size(frame_num, 1) && z <= size(frame_num, 2) && frame_num(t,z)
    view_ch_proj = false;
    if getappdata(handles.figure1, 'multi_channel') && ...
            get(handles.view_multi_ch_proj, 'value')
        multi_ch_proj_filename = getappdata(handles.figure1, 'multi_ch_proj_filename');
        if ~isempty(multi_ch_proj_filename) && ~isempty(get_file_nums(multi_ch_proj_filename, 1))
            multi_ch_proj_filename = put_file_nums(multi_ch_proj_filename, t, z);
        end
        if ~isempty(get_file_nums(multi_ch_proj_filename, 1)) && ~isempty(dir(multi_ch_proj_filename))
            set(handles.view_multi_ch_proj, 'FontWeight', 'Normal');
            view_ch_proj = true;
            img = imread(multi_ch_proj_filename);
        else
            set(handles.view_multi_ch_proj, 'FontWeight', 'Bold');
        end
    else
        set(handles.view_multi_ch_proj, 'FontWeight', 'Normal');
    end
    
    filename = frames(frame_num(t,z)).name;
    setappdata(currentfig, 'filename', filename);
    
    img_filename = fullfile(directory, filename);
    
    if ~getappdata(handles.figure1, 'multi_channel')
        if length(dir(img_filename)) && ~view_ch_proj
            img = imread(img_filename);
            set(handles.Noise_check, 'FontWeight', 'normal');

        elseif ~view_ch_proj
            img = imread(fullfile(home_dir, filename));
            set(handles.Noise_check, 'FontWeight', 'bold');
        end
        if get(handles.Noise_check, 'value') && ~view_ch_proj
            info_text_msg = projection_details(handles, 'read', t, z);
        end
    end
    
    
    if getappdata(handles.figure1, 'multi_channel') && ~view_ch_proj
        img(:, :, 3) = 0;
        set(handles.Noise_check, 'FontWeight', 'normal');
    end
    for ch = 1:3
        if getappdata(handles.figure1, 'multi_channel') && ...
                get(handles.(['channel' num2str(ch)]), 'value') && ~view_ch_proj
            img = display_image_ch(handles, img, ch, t, z);
        else
            setup_no_image_channel(handles, ch)
        end
    end
elseif ishandle(imageH)
    img = get(imageH, 'cdata');
else
    filename = frames(1).name;
    img = imread(filename);
    img(:) = 0;
end

if getappdata(handles.figure1, 'multi_channel') && ~view_ch_proj && size(img, 3) < 3
    img(:, :, 3) = 0;
end
    
set(handles.help_info, 'string', info_text_msg);

if getappdata(handles.figure1, 'multi_channel') && ~view_ch_proj
    img = uint8(img);
end
if getappdata(currentfig, 'first_time')
    filename = frames(1).name;
    temp_img = uint8(imread(filename));
    img((end+1):size(temp_img, 1), :, :) = 0;
    img(:, (end+1):size(temp_img, 2), :) = 0;
    setappdata(currentfig, 'first_time', 0);    
    if ishandle(handles.axes1)
        axes(handles.axes1);
    end
    if ishandle(imageH)
        delete(imageH);
    end
    axes(handles.axes1);
    if getappdata(handles.figure1, 'multi_channel') && ~view_ch_proj
        imageH = image(img);
    else
        imageH = imagesc(img);
        colormap(gray);
    end

    axis off;
    axis image;
    hold on
else
    set(imageH, 'cdata', img);
end



set(handles.frame_slider, 'value', t);
set(handles.frame_number, 'String', t);
set(handles.z_number, 'String', z);
set(handles.z_slider, 'value', -z);

delete(poly_seqH(ishandle(poly_seqH)));
if isappdata(handles.figure1, 'poly_seq') & ~getappdata(handles.figure1, 'hide_poly') ...
        && frame_num(t,z)
    poly_seq = getappdata(handles.figure1, 'poly_seq');
    poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
%     [dummy poly_ind] = min(abs(frame_num(t,z) - poly_frame_ind));
    inv_frame_num = getappdata(handles.figure1,'inv_frame_num');
    [poly dummy] = get_poly_for_frame(frame_num(t,z), poly_frame_ind, poly_seq, inv_frame_num);
    if isempty(poly.x)
        display('poly is empty');
    else
        X = poly.x;
        Y = poly.y;
        poly_color = [1 0 0];
        if dummy == 0;
            poly_color = [0 0 1];
        end
        poly_seqH = patch(Y', X', [0 0.5 0], 'FaceAlpha', 0, 'EdgeColor', poly_color);
    end
end

% if isappdata(handles.figure1, 'areas');
%     areas = getappdata(handles.figure1, 'areas');
%     delete(areaH(ishandle(areaH)))
%     if all(size(areas) >= [t z]) && ~isempty(areas(t,z).wa)
%         workingarea = areas(t,z).wa;
%         areaH=plot(workingarea([1:end 1],2),workingarea([1:end 1],1), 'r');
%         setappdata(handles.figure1, 'areaH', areaH);
%     end
% end    
colormap(gray);

if ~get(handles.draw_geom_check, 'value') && exist('wallH')
    delete(wallH(ishandle(wallH)));  
end

if exist('filename') && (geom | get(handles.draw_geom_check, 'value'))
    [pathstr, name, ext] = fileparts(filename);
    filename = [name '.mat'];
    if length(dir(fullfile(home_dir, filename)));
        set(handles.draw_geom_check, 'FontWeight', 'normal');
        load(fullfile(home_dir, filename), 'cellgeom');
        delete(wallH(ishandle(wallH)));  
        X = [cellgeom.nodes(cellgeom.edges(:,1),2), cellgeom.nodes(cellgeom.edges(:,2),2)];
        Y = [cellgeom.nodes(cellgeom.edges(:,1),1), cellgeom.nodes(cellgeom.edges(:,2),1)];
        wallH = plot(get(handles.figure1,'CurrentAxes'), X', Y', 'g');
    %     figure(activefig);
    %     wallH = patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, 'EdgeColor', [0 1 0]);
    else
        set(handles.draw_geom_check, 'FontWeight', 'Bold');
    end
else
    set(handles.draw_geom_check, 'FontWeight', 'normal');
end

set_frame_num_limits(handles)


drawnow;





% --- Executes on button press in Noise_check.
function Noise_check_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Noise_check
home_dir = getappdata(handles.figure1, 'directory');
bnr_dir = fullfile(home_dir, 'bnr');
if get(hObject,'Value') %&& isdir(bnr_dir)
    setappdata(handles.figure1, 'play_dir', bnr_dir)
else
    setappdata(handles.figure1, 'play_dir', home_dir)
end
i = str2double(get(handles.frame_number, 'string'));
up_fr(handles, i)    
    




function z_number_Callback(hObject, eventdata, handles)
% hObject    handle to z_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_number as text
%        str2double(get(hObject,'String')) returns contents of z_number as a double

mn = -get(handles.z_slider, 'max');
mx = -get(handles.z_slider, 'min');
i = min(max(round(str2double(get(hObject,'String'))), mn), mx);
set(hObject, 'string', i);
set(handles.z_slider, 'Value', -i);
update_z(handles)


% --- Executes during object creation, after setting all properties.
function z_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in area_btn.
function area_btn_Callback(hObject, eventdata, handles)
% hObject    handle to area_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frame_num = getappdata(handles.figure1, 'frame_num');
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.z_number, 'string'));
hold on
x=[]; y=[]; l=[];
[yin,xin] = ginput(1);
while ~isempty(xin)
  l(end+1) = plot(yin,xin,'wx');
  if ~isempty(x)
    l(end+1) = plot([y(end) yin],[x(end) xin],'w');
  end
  x(end+1)=xin;
  y(end+1)=yin;
  [yin,xin] = ginput(1);
end
delete(l);

if isappdata(handles.figure1, 'areas')
    areas = getappdata(handles.figure1, 'areas');
end
areas(t,z).wa = [x' y'];
if get(handles.ignore_z, 'value')
    z_for_t = getappdata(handles.figure1, 'z_for_t');
    min_t = get(handles.frame_slider, 'min');
    max_t = get(handles.frame_slider, 'max');
    if get(handles.apply_for, 'value')
        for i = t:max_t
            areas(i,z_for_t(i)).wa = [x' y'];
        end
    end
    if get(handles.apply_back, 'value')
        for i = min_t:t
            areas(i,z_for_t(i)).wa = [x' y'];
        end
    end
    
end
setappdata(handles.figure1, 'areas', areas);



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isappdata(handles.figure1, 'areas')
    waitfor(msgbox('No areas defined', '','error','modal'));
    return
end
areas = getappdata(handles.figure1, 'areas');
min_t = get(handles.frame_slider, 'min');
max_t = get(handles.frame_slider, 'max');
max_z = -get(handles.z_slider, 'min');
min_z = -get(handles.z_slider, 'max');

if get(handles.ignore_z, 'value')
    z_for_t = getappdata(handles.figure1, 'z_for_t');
    areas(max_t, max(z_for_t)) = areas(end);
    orbit = sub2ind(size(areas), min_t:max_t, z_for_t(min_t:max_t));
    areas = do_areas(areas, orbit);
    setappdata(handles.figure1, 'areas', areas);
    return
end


orbit = sub2ind(size(areas), min_t * ones(1, length(min_z:max_z)), min_z:max_z);
areas = do_areas(areas, orbit);
orbit = sub2ind(size(areas), max_t * ones(1, length(min_z:max_z)), min_z:max_z);
areas = do_areas(areas, orbit);
for z_cnt = min_z : max_z
    orbit = sub2ind(size(areas), min_t:max_t, z_cnt * ones(1, length(min_t:max_t)));
    areas = do_areas(areas, orbit);
end
setappdata(handles.figure1, 'areas', areas);

function areas = do_areas(areas, orbit, n)
n = length(orbit);
end_area = areas(orbit(end)).wa;
start_area = areas(orbit(1)).wa;
for i = 1:n
    current_area(:,1) = (i - 1) * end_area(:,1) + (n - i) * start_area(:,1);
    current_area(:,2) = (i - 1) * end_area(:,2) + (n - i) * start_area(:,2);
    current_area = current_area / (n - 1);
    areas(orbit(i)).wa = current_area;
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isappdata(handles.figure1, 'areas')
    waitfor(msgbox('No areas defined', '','error','modal'));
    return
end
areas = getappdata(handles.figure1, 'areas');
frames = getappdata(handles.figure1, 'frames');
for i = 1:length(frames)
    z = frames(i).z;
    t = frames(i).t;
    [pathstr, name, ext, versn] = fileparts(frames(i).name);
    filename = [name '.mat'];
    vars = load(filename, 'cellgeom', 'workingarea');
    cellgeom = vars.cellgeom;
    workingarea = vars.workingarea;
    x = areas(t,z).wa(:,1);
    y = areas(t,z).wa(:,2);
    cellgeom.selected_cells(:) = 0;
    new_selection = inpolygon(cellgeom.circles(:,1), cellgeom.circles(:,2), x, y);
    new_selection = new_selection & cellgeom.valid';
    cellgeom.selected_cells(new_selection) = 1;

    cen = mean(workingarea);
    inner_work = [];
    inner_work(:,1) = cen(1)*0.07 + workingarea(:,1) .* 0.93;
    inner_work(:,2) = cen(2)*0.07 + workingarea(:,2) .* 0.93;
    n_ind = ~inpolygon(cellgeom.nodes(:,1), cellgeom.nodes(:,2), inner_work(:,1), inner_work(:,2));
    c_ind = ismember(cellgeom.nodecellmap(:,2), find(n_ind), 'legacy');
    cellgeom.selected_cells(cellgeom.nodecellmap(c_ind,1)) = 0;
    % cellgeom.selected_cells(cellgeom.border_cells) = 0;
    cellgeom.selected_cells(~cellgeom.valid) = 0;

    save(filename, 'cellgeom', '-v6', '-append');
    disp 'done'
end


% --- Executes on button press in Ignore_z.
function Ignore_z_Callback(hObject, eventdata, handles)
% hObject    handle to Ignore_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Ignore_z




% --- Executes on button press in ignore_z.
function ignore_z_Callback(hObject, eventdata, handles)
% hObject    handle to ignore_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ignore_z




% --- Executes on button press in projection_along_z.
function projection_along_z_Callback(hObject, eventdata, handles)
% hObject    handle to projection_along_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


home_dir = getappdata(handles.figure1, 'directory');
z_shift_file = getappdata(handles.figure1, 'z_shift_file');

z_shift = ~get(handles.no_z_shift, 'value');
z_shift_for_t = 0;
min_t = get(handles.frame_slider, 'min');
if get(handles.z_shift_apply_to_radio_button, 'value')
    min_t = str2double(get(handles.t_from, 'String'));
end

if z_shift 
%     if length(dir(fullfile(directory, z_shift_file)))
%         [aa bb] = textread(z_shift_file, '%d = %d', 'commentstyle', 'matlab');
%         z_shift_for_t(aa) = bb;
%     else
        z_shift_for_t = getappdata(handles.figure1, 'z_for_t');
        z_shift_for_t = z_shift_for_t - z_shift_for_t(min_t);
%     end
end
z_for_t = getappdata(handles.figure1, 'z_for_t');
frames = getappdata(handles.figure1, 'frames');
frame_num = getappdata(handles.figure1, 'frame_num');
func_name = get(handles.proj_func, 'string');
proj_method = func_name{get(handles.proj_func, 'value')};
OVERWRITE = strcmpi(get(handles.overwrite_bnr_menu, 'checked'), 'on');
const_z_copy = strcmpi(get(handles.const_z_copy_menu, 'checked'), 'on');
 
[i j] = find(frame_num);
min_t = min(i);
max_t = max(i);
min_z = min(j);
max_z = max(j);

min_t = str2double(get(handles.t_from, 'String'));
max_t = str2double(get(handles.t_to, 'String'));
min_z = str2double(get(handles.z_from, 'String'));
max_z = str2double(get(handles.z_to, 'String'));



if ~isdir('bnr')
    mkdir(fullfile(home_dir), 'bnr') 
end
if const_z_copy && ~isdir(fullfile(home_dir, '9999'))
    mkdir(fullfile(home_dir, '9999'))
end

im_written = false;

for t = min_t:max_t
    cnt = 0;
    for z_cnt = min_z : max_z 
        if any(z_shift_for_t)
            z = z_cnt + z_shift_for_t(t);
        else
            z = z_cnt;
        end
        if frame_num(t,z)
            new_img_filename = fullfile(home_dir, 'bnr', frames(frame_num(t,z)).name);
            if length(dir(new_img_filename)) && ~OVERWRITE
               continue
            end
            
            new_img = project_along_z(t, z , ...
                proj_method, frames, frame_num, handles);
            imwrite(new_img, new_img_filename, 'tiff');
            if const_z_copy
                const_z_filename = fullfile(home_dir, '9999', frames(frame_num(t,z)).name);
                const_z_filename = put_file_nums(const_z_filename, [], 9999);
                imwrite(new_img, const_z_filename, 'tiff');
            end
            projection_details(handles, 'write', t, z, proj_method);
            im_written = true;
        end
    end

end
if im_written
    write_image_log([], fullfile(home_dir, 'bnr'), min_z, max_z, min_t, max_t, proj_method, ...
        handles)
end
set(handles.Noise_check, 'value', 1);
Noise_check_Callback(handles.Noise_check, [], handles)
% up_fr(handles);

function write_image_log(filename, directory, min_z, max_z, min_t, max_t, proj_method, ...
        handles)

if isempty(filename)
    filename = 'projection_method.txt';
end
if isempty(directory)
    directory = pwd;
end
subtract_background_before = get(handles.subtract_background_before_menu, 'checked');
subtract_background_after = (get(handles.subtract_background_after_menu, 'checked'));
rad = getappdata(handles.figure1, 'image_nhood_radius');
stretch_limits = get(handles.stretch_limits_menu, 'checked');
equalize = get(handles.equal_hist_menu, 'checked');
smth = get(handles.smoothen_image_menu, 'checked');
guassian_size = getappdata(handles.figure1, 'guassian_size');
guassian_std = getappdata(handles.figure1, 'guassian_std');
external_proj = get(handles.external_proj_menu, 'checked');
custom_proj = get(handles.custom_img_proc, 'checked');
minus_z = str2double(get(handles.minus_z_for_bnr_b4_seg, 'string'));
plus_z = str2double(get(handles.plus_z_for_bnr_b4_seg, 'string'));
minus_t = str2double(get(handles.minus_t_for_bnr_b4_seg, 'string'));
plus_t = str2double(get(handles.plus_t_for_bnr_b4_seg, 'string'));

ex_list = {...
    'min z',                    num2str(min_z);
    'max z',                    num2str(max_z);
    'min t',                    num2str(min_t);
    'max t',                    num2str(max_t);
    'projection method',        proj_method;
    'z below',                  num2str(minus_z);
    'z above',                  num2str(plus_z);
    't before',                 num2str(minus_t);
    't after',                  num2str(plus_t);
    'subtract background before projection',   subtract_background_before;    
    'subtract background after projection',   subtract_background_after;    
    'neighborhood radius',      num2str(rad);
    'stretch limits',           stretch_limits;
    'equalize',                 equalize;
    'smoothening',              smth;
    'gaussuan size',            num2str(guassian_size);
    'gaussuan std',             num2str(guassian_std);
    'external code',            external_proj;
    'custom proc',              custom_proj};

fid = fopen(fullfile(directory, filename), 'w');
if fid == -1
    msg_string = sprintf(['There was an error opening the log file.\n'...
        'Make sure %s is not open in another application and try again.'], filename);
    h = msgbox(msg_string, '', 'warn', 'modal');
    waitfor(h)
    return
end
for i = 1:length(ex_list)
    fprintf(fid, '%s = %s\r\n', ex_list{i, 1}, ex_list{i, 2});
end

if  ~get(handles.no_z_shift, 'value');
    fprintf(fid, '\r\n\r\nZ shift info\r\n============\r\n\r\n');
    z_for_t = getappdata(handles.figure1, 'z_for_t');
    min_t_for_z = get(handles.frame_slider, 'min');
    z_for_t = z_for_t - z_for_t(min_t_for_z);
    for t = min_t:max_t
        fprintf(fid, '%d = %d\r\n', t, z_for_t(t));
    end
end
fclose(fid);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in z_shift_files_btn.


% --- Executes on button press in no_z_shift.
function no_z_shift_Callback(hObject, eventdata, handles)
% hObject    handle to no_z_shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of no_z_shift

if ~get(hObject,'Value') 
    set(handles.z_shift_entire_movie_radio_button, 'enable', 'on')
    set(handles.z_shift_apply_to_radio_button, 'enable', 'on')
else
    set(handles.z_shift_entire_movie_radio_button, 'enable', 'off')
    set(handles.z_shift_apply_to_radio_button, 'enable', 'off')
end

% --- Executes on button press in auto_area.
function auto_area_Callback(hObject, eventdata, handles)
% hObject    handle to auto_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_area




% --- Executes on button press in change_dir.
function change_dir_Callback(hObject, eventdata, handles)
% hObject    handle to change_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directory = uigetdir;
if directory == 0
    return
end
setup_dir(handles, directory);






% --- Executes on button press in overwrite.
function overwrite_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of overwrite




% --- Executes on button press in import_z_btn.
function import_z_btn_Callback(hObject, eventdata, handles)
% hObject    handle to import_z_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function import_z_from_files(handles)
frames = getappdata(handles.figure1, 'frames');
min_z = min([frames(:).z]);
max_z = max([frames(:).z]);

min_t = get(handles.frame_slider, 'min');

directory = getappdata(handles.figure1, 'directory');
z_shift_file = getappdata(handles.figure1, 'z_shift_file');

z_shift_for_t = 0;
if length(dir(fullfile(directory, z_shift_file)))
    [aa bb] = textread(z_shift_file, '%d = %d', 'commentstyle', 'matlab');
    z_shift_for_t(aa) = bb;
    z_for_t = getappdata(handles.figure1, 'z_for_t');
    z_for_t = repmat(z_for_t(min_t), 1, length(z_for_t)) + z_shift_for_t;
    z_for_t = max(min_z, min(max_z, z_for_t));
    setappdata(handles.figure1, 'z_for_t', z_for_t);
else
    msg = [z_shift_file ' not found.'];
    msgboxH = msgbox(msg, '', 'warn', 'modal');
    waitfor(msgboxH);
end



% --- Executes on button press in Import_from_files.
function Import_from_files_Callback(hObject, eventdata, handles)
% hObject    handle to Import_from_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in no_layers_mult.
function no_layers_mult_Callback(hObject, eventdata, handles)
% hObject    handle to no_layers_mult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of no_layers_mult




% --- Executes on selection change in proj_func.
function proj_func_Callback(hObject, eventdata, handles)
% hObject    handle to proj_func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns proj_func contents as cell array
%        contents{get(hObject,'Value')} returns selected item from proj_func


% --- Executes during object creation, after setting all properties.
function proj_func_CreateFcn(hObject, eventdata, handles)
% hObject    handle to proj_func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in im_adjust.
function im_adjust_Callback(hObject, eventdata, handles)
% hObject    handle to im_adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of im_adjust




% --- Executes on button press in draw_geom_check.
function draw_geom_check_Callback(hObject, eventdata, handles)
% hObject    handle to draw_geom_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of draw_geom_check

up_fr(handles)



function shift_all_z_Callback(hObject, eventdata, handles)
% hObject    handle to shift_all_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shift_all_z as text
%        str2double(get(hObject,'String')) returns contents of shift_all_z as a double


% --- Executes during object creation, after setting all properties.
function shift_all_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_all_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom_btn.
function zoom_btn_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoom_btn

axes(handles.axes1)
if get(hObject,'Value') 
    zoom on
    set(handles.pan_btn, 'value', 0);
    pan off
else
    zoom off
end


function new_img = project_along_z(t,z, method, frames,...
    frame_num, handles,demo_bool)
if (nargin < 7) || isempty(demo_bool)
    demo_bool = false;
end

min_z = str2double(get(handles.minus_z_for_bnr_b4_seg, 'string'));
min_z = -min_z;
max_z = str2double(get(handles.plus_z_for_bnr_b4_seg, 'string'));
min_t = str2double(get(handles.minus_t_for_bnr_b4_seg, 'string'));
min_t = -min_t;
max_t = str2double(get(handles.plus_t_for_bnr_b4_seg, 'string'));
cnt = 0;

if demo_bool
    demo_str = 'min_z = %d \n max_z = %d \n min_t = %d \n max_t  = %d \n';
    fprintf(demo_str,[min_z,max_z,min_t,max_t]);
end

for z_cnt = z + (min_z : max_z)
    for t_cnt = t + (min_t : max_t)
        if t_cnt > 0 && t_cnt <= size(frame_num, 1) && z_cnt > 0 && z_cnt <= size(frame_num, 2) && frame_num(t_cnt,z_cnt)
            cnt = cnt + 1;
            old_class = class(imread(frames(frame_num(t_cnt,z_cnt)).name));
            tmp_img_one_layer = double(imread(frames(frame_num(t_cnt,z_cnt)).name));
            
            if size(tmp_img_one_layer,3) > 1
            
                tmp_img(:, :, cnt) = max(double(imread(frames(frame_num(t_cnt,z_cnt)).name)),[],3);
            else
                tmp_img(:, :, cnt) = double(imread(frames(frame_num(t_cnt,z_cnt)).name));
            end
            
            if strcmpi(get(handles.subtract_background_before_menu, 'checked'), 'on')
                rad = getappdata(handles.figure1, 'image_nhood_radius');
                tmp_img(:, :, cnt) = tmp_img(:, :, cnt) - local_background_of_image(tmp_img(:, :, cnt), rad);
                tmp_img(:, :, cnt) = tmp_img(:, :, cnt) - min(min(tmp_img(:, :, cnt)));
            end
        else
            fprintf('missing image at t = %d   z = %d\n', t, z)
    %         tmp_img(:, :, cnt) = 1;
        end
    end
end

new_img = project_3_dim_img(handles, tmp_img, method, old_class);


function new_img = combine_channels(t, z, filenames, weights, shifts, method, handles)
for cnt = 1:length(filenames)
    if isempty(filenames{cnt})
        continue
    end
%     dlf edit
%     old_class = class(imread(frames(frame_num(t_cnt,z_cnt)).name));
    old_class = class(imread(put_file_nums(filenames{cnt}, t, z + shifts(cnt))));
    tmp_img(:, :, cnt) = double(imread(put_file_nums(filenames{cnt}, t, z + shifts(cnt))));
    if get(handles.apply_brightness_check, 'value')
        %get scaling values from figure
        i = min(3, cnt); %scaling info is only available for 3 channels.
        fac = getappdata(handles.figure1, ['channel' num2str(i) '_factor']);
        shift_fac = getappdata(handles.figure1, ['channel' num2str(i) '_shift_factor']);
    else
        %no scaling
        fac = 1;
        shift_fac = 0;
    end
    tmp_img(:, :, cnt) = (tmp_img(:, :, cnt) - shift_fac) * fac;
    if strcmpi(get(handles.subtract_background_before_menu, 'checked'), 'on')
        rad = getappdata(handles.figure1, 'image_nhood_radius');
        tmp_img(:, :, cnt) = tmp_img(:, :, cnt) - local_background_of_image(tmp_img(:, :, cnt), rad);
%         tmp_img(:, :, cnt) = tmp_img(:, :, cnt) - min(min(tmp_img(:, :, cnt)));
    end
end
if strcmpi(get(handles.rescale_proj_image, 'checked'), 'on') && get(handles.apply_brightness_check, 'value')
    tmp_img = max(1, min(255, tmp_img));
end

new_img = project_3_dim_img(handles, tmp_img, method, old_class, weights(1:size(tmp_img, 3)));

function new_img = project_3_dim_img(handles, tmp_img, method, old_class, weights)
if nargin < 4 || isempty(old_class)
    old_class = 'uint8';
end
if nargin < 5 || isempty(weights)
    weights = ones(1, size(tmp_img, 3));
end

rescale = strcmpi(get(handles.rescale_proj_image, 'checked'), 'on');
if strcmp(method, 'max')
    a = feval(method, tmp_img, [], 3);
elseif strcmp(method, 'max * prod')
    a = feval('max', tmp_img, [], 3);
    a = max(0, a);
    weights = weights/sum(weights);
    for img_cnt = 1:length(weights)
        tmp_img(:, :, img_cnt) = tmp_img(:, :, img_cnt) .^ weights(img_cnt);
    end
    a = a.* feval('prod', tmp_img, 3);
elseif strcmp(method, 'max * mean')
    a = feval('max', tmp_img, [], 3);
    weights = weights/mean(weights);
    for img_cnt = 1:length(weights)
        tmp_img(:, :, img_cnt) = tmp_img(:, :, img_cnt) .* weights(img_cnt);
    end
    a = a.* feval('mean', tmp_img, 3);
elseif strcmp(method, 'prod')
    tmp_img = max(0, tmp_img);
    weights = weights/sum(weights);
    for img_cnt = 1:length(weights)
        tmp_img(:, :, img_cnt) = tmp_img(:, :, img_cnt).^ weights(img_cnt);
    end
    a = feval('prod', tmp_img, 3);
elseif strcmp(method, 'mean')
    weights = weights/sum(weights);
    for img_cnt = 1:length(weights)
        tmp_img(:, :, img_cnt) = tmp_img(:, :, img_cnt) .* weights(img_cnt);
    end
    a = feval('mean', tmp_img, 3);
end

if rescale
    a = a ./ max(a(:));
end



if strcmpi(get(handles.stretch_limits_menu, 'checked'), 'on')
    a = imadjust(a, stretchlim(a(a>0)), [0, 1]);
end
if strcmpi(get(handles.equal_hist_menu, 'checked'), 'on')
    a = adapthisteq(a);
end

if strcmpi(get(handles.subtract_background_after_menu, 'checked'), 'on');
    rad = getappdata(handles.figure1, 'image_nhood_radius');
    a = a - local_background_of_image(a, rad);
    a = a - min(a(:));
end

if strcmpi(get(handles.smoothen_image_menu, 'checked'), 'on')
    guassian_size = getappdata(handles.figure1, 'guassian_size');
    guassian_std = getappdata(handles.figure1, 'guassian_std');
    PSF = fspecial('gaussian', guassian_size, guassian_std);
    a = imfilter(double(a),PSF,'conv');
end


if strcmpi(get(handles.external_proj_menu, 'checked'), 'on')
    a = proc_cell_image(a);
end

if strcmpi(get(handles.custom_img_proc, 'checked'), 'on')
    a = proc_cell_image_custom(a);
end


if strcmpi(get(handles.grad_methd, 'checked'), 'on')
    a = proc_cell_image_grad(a);
end


if strcmpi(get(handles.piv_temp_proj, 'checked'), 'on')
    a = proc_cell_image_piv_temp(a);
end


if rescale
    a = (a ./ max(a(:)))*255;
    new_img = uint8(round(a));
else
    new_img = a;
    new_img = eval([old_class '(new_img)']);
end


% --- Executes on button press in update_positions.
function update_positions_Callback(hObject, eventdata, handles)
% hObject    handle to update_positions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of update_positions


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14



function minus_z_for_bnr_b4_seg_Callback(hObject, eventdata, handles)
% hObject    handle to minus_z_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minus_z_for_bnr_b4_seg as text
%        str2double(get(hObject,'String')) returns contents of minus_z_for_bnr_b4_seg as a double


% --- Executes during object creation, after setting all properties.
function minus_z_for_bnr_b4_seg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minus_z_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plus_z_for_bnr_b4_seg_Callback(hObject, eventdata, handles)
% hObject    handle to plus_z_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plus_z_for_bnr_b4_seg as text
%        str2double(get(hObject,'String')) returns contents of plus_z_for_bnr_b4_seg as a double


% --- Executes during object creation, after setting all properties.
function plus_z_for_bnr_b4_seg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plus_z_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in thresh_function.
function thresh_function_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns thresh_function contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thresh_function


% --- Executes during object creation, after setting all properties.
function thresh_function_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in im_histeq.
function im_histeq_Callback(hObject, eventdata, handles)
% hObject    handle to im_histeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of im_histeq




% --- Executes on button press in subtract_background.
function subtract_background_Callback(hObject, eventdata, handles)
% hObject    handle to subtract_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subtract_background


% --- Executes on button press in substrct_bck_segmentation.
function substrct_bck_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to substrct_bck_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of substrct_bck_segmentation




% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function untitled_Callback(hObject, eventdata, handles)
% hObject    handle to untitled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_z_list_menu_Callback(hObject, eventdata, handles)
% hObject    handle to export_z_list_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
z_for_t = getappdata(handles.figure1, 'z_for_t');
min_t = get(handles.frame_slider, 'min');

[z_shift_file, pathname] = uiputfile('*.txt');
if isequal(z_shift_file,0) &&  isequal(pathname,0)
    return
end

fid = fopen(fullfile(pathname, z_shift_file), 'w');
if fid == -1
    msg_string = sprintf(['There was an error opening the file. '...
        'Make sure %s is not open in another application and try again.'], z_shift_file);
    h = msgbox(msg_string, '', 'warn', 'modal');
    waitfor(h)
    return
end
for t = min_t:length(z_for_t)
    fprintf(fid, '%d = %d\r\n', t, z_for_t(t));
end

fclose(fid);



% --------------------------------------------------------------------
function copy_files_menu_Callback(hObject, eventdata, handles)
% hObject    handle to copy_files_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
z_for_t = getappdata(handles.figure1, 'z_for_t');

min_t = get(handles.frame_slider, 'min');
z_shift_for_t = z_for_t - z_for_t(min_t);



directory = getappdata(handles.figure1, 'play_dir');
home_dir = getappdata(handles.figure1, 'directory');
% z_shift_file = getappdata(handles.figure1, 'z_shift_file');
% 
% z_shift = ~get(handles.no_z_shift, 'value');
% z_shift_for_t = 0;
% if z_shift & length(dir(fullfile(directory, z_shift_file)))
%     [aa bb] = textread(z_shift_file, '%d = %d', 'commentstyle', 'matlab');
%     z_shift_for_t(aa) = bb;
% end

frames = getappdata(handles.figure1, 'frames');
frame_num = getappdata(handles.figure1, 'frame_num');
min_t = str2double(get(handles.t_from, 'String'));
max_t = str2double(get(handles.t_to, 'String'));
min_z = str2double(get(handles.z_from, 'String'));
max_z = str2double(get(handles.z_to, 'String'));

%CHANGE THIS TO BE AN OPTION IN THE GUI.
mat_files_as_well = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

newdir = uigetdir(pwd, 'Select destination directory');
if newdir == 0
    return
end

cnt = 0;
for t = min_t:max_t
    for z_cnt = min_z : max_z 
        if any(z_shift_for_t)
            z = z_cnt + z_shift_for_t(t);
        else
            z = z_cnt;
        end
        success = true;
        if frame_num(t,z)
            src = fullfile(directory, frames(frame_num(t,z)).name);
            dest = fullfile(newdir, frames(frame_num(t,z)).name);
            success = success & copyfile(src, dest);
            if mat_files_as_well
                mat_file_src = fullfile(home_dir, frames(frame_num(t,z)).name);
                mat_file_src = [mat_file_src(1:end-3) 'mat'];
                if ~isempty(dir(mat_file_src))
                    mat_file_dest = [dest(1:end-3) 'mat'];
                    success = success & copyfile(mat_file_src, mat_file_dest);
                end
            end
            cnt = cnt + 1;
        end
    end
end
if ~success
    msg = 'There was an error copying the files';
    h = msgbox(msg, '', 'error', 'modal');
else
    save_z_shift(handles, newdir, 1)
    msg = sprintf('Copied %d files', cnt);
    h = msgbox(msg, '', 'help', 'modal');
end
waitfor(h);


% --------------------------------------------------------------------
function add_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to add_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
states = disable_all_controls(handles);
[x y] = get_poly_from_user_input;
enable_all_controls(handles, states);
if isempty(x)
    return
end
poly.x = x;
poly.y = y;

t = get(handles.frame_slider, 'value');
z_for_t = getappdata(handles.figure1, 'z_for_t');
z = z_for_t(t);
frame_num = getappdata(handles.figure1, 'frame_num');
current_frame_num = frame_num(t, z);

add_poly_to_poly_seq(handles, poly, current_frame_num);

up_fr(handles);

function add_poly_to_poly_seq(handles, poly, i)

poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');

[poly_seq poly_frame_ind] = add_poly_to_poly_seq_inter(poly_seq, poly_frame_ind, poly, i);

setappdata(handles.figure1, 'poly_seq', poly_seq);
setappdata(handles.figure1, 'poly_frame_ind', poly_frame_ind);

% --------------------------------------------------------------------
function edit_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edit_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the existing poly for the current frame

t = get(handles.frame_slider, 'value');
z_for_t = getappdata(handles.figure1, 'z_for_t');
z = z_for_t(t);
frame_num = getappdata(handles.figure1, 'frame_num');
inv_frame_num  = getappdata(handles.figure1, 'inv_frame_num');
current_frame_num = frame_num(t, z);
poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
poly = get_poly_for_frame(current_frame_num, poly_frame_ind, poly_seq,inv_frame_num);

if isempty(poly)
    add_poly_menu_Callback(handles.add_poly_menu, eventdata, handles);
    return
end
%Interactively edit poly
poly = edit_poly(handles, poly);

%Update poly list
add_poly_to_poly_seq(handles, poly, current_frame_num);

%Redraw image
up_fr(handles);

function poly = edit_poly(handles, poly);
%set mode to hide all
% hide = get(handles.hide, 'value');
% set(handles.hide, 'value', 1);

%redraw image
setappdata(handles.figure1, 'hide_poly', true);
up_fr(handles);
setappdata(handles.figure1, 'hide_poly', false);

%edit poly
states = disable_all_controls(handles);
poly = edit_poly_inter(poly, handles.help_info);
enable_all_controls(handles, states);

%set hide mode to old hide mode
% set(handles.hide, 'value', hide);

% --------------------------------------------------------------------
function delete_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to delete_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');

t = get(handles.frame_slider, 'value');
z_for_t = getappdata(handles.figure1, 'z_for_t');
z = z_for_t(t);
frame_num = getappdata(handles.figure1, 'frame_num');
current_frame_num = frame_num(t, z);
[poly_seq poly_frame_ind suc] = delete_poly_from_seq(poly_seq, poly_frame_ind, current_frame_num);

if suc
    setappdata(handles.figure1, 'poly_seq', poly_seq);
    setappdata(handles.figure1, 'poly_frame_ind', poly_frame_ind);
    up_fr(handles)
else
    msg = 'No polygon found. Polygons can only be deleted from key frames (blue polygons).';
    h = msgbox(msg, '', 'warn', 'modal');
end

% --------------------------------------------------------------------
function load_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = 'limit_area_poly.mat';
if ~length(dir(filename))
    h = msgbox('could not find limit_area_poly.mat in current directory', '', 'warn', 'modal');
    waitfor(h)
    return
end
s = load(filename);
setappdata(handles.figure1, 'poly_seq', s.poly_seq);
setappdata(handles.figure1, 'poly_frame_ind', s.poly_frame_ind);
up_fr(handles)

% --------------------------------------------------------------------
function save_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');




filename = 'limit_area_poly.mat';
save(filename, 'poly_seq', 'poly_frame_ind');


% --------------------------------------------------------------------
function no_layers_menu_Callback(hObject, eventdata, handles)
% hObject    handle to no_layers_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function reposition_nodes_menu_Callback(hObject, eventdata, handles)
% hObject    handle to reposition_nodes_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function auto_limit_area_menu_Callback(hObject, eventdata, handles)
% hObject    handle to auto_limit_area_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function subtract_background_before_menu_Callback(hObject, eventdata, handles)
% hObject    handle to subtract_background_before_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function subtract_background_during_menu_Callback(hObject, eventdata, handles)
% hObject    handle to subtract_background_during_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function z_from_images_menu_Callback(hObject, eventdata, handles)
% hObject    handle to z_from_images_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
min_t = get(handles.frame_slider, 'min');
z_for_t = getappdata(handles.figure1, 'z_for_t');
z_for_t = z_for_t(min_t) + create_z_shift_from_files('tif');
setappdata(handles.figure1, 'z_for_t', z_for_t);
msgboxH = msgbox('Created Z shift info from tif files.', '', 'help', 'modal');
waitfor(msgboxH)

% --------------------------------------------------------------------
function load_z_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_z_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
import_z_from_files(handles)


% --------------------------------------------------------------------
function save_z_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_z_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_z_shift(handles, pwd);


function save_z_shift(handles, dest_dir, quiet_mode)
if nargin < 3
    quiet_mode = 0;
end
z_for_t = getappdata(handles.figure1, 'z_for_t');

min_t = get(handles.frame_slider, 'min');
z_for_t = z_for_t - z_for_t(min_t);

z_shift_file = getappdata(handles.figure1, 'z_shift_file');
fid = fopen(fullfile(dest_dir, z_shift_file), 'w');
if fid == -1
    msg_string = sprintf(['There was an error opening the file. '...
        'Make sure %s is not open in another application and try again.'], z_shift_file);
    h = msgbox(msg_string, '', 'warn', 'modal');
    waitfor(h)
    return
end
for t = min_t:length(z_for_t)
    fprintf(fid, '%d = %d\r\n', t, z_for_t(t));
end

fclose(fid);

if ~quiet_mode
    msgboxH = msgbox('Created Z shift info from user info.', '', 'help', 'modal');
    waitfor(msgboxH)
end


% --------------------------------------------------------------------
function shift_all_z_menu_Callback(hObject, eventdata, handles)
% hObject    handle to shift_all_z_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function options_menu_Callback(hObject, eventdata, handles)
% hObject    handle to options_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


thresh_factor = getappdata(handles.figure1, 'thresh_factor');
image_nhood_radius = getappdata(handles.figure1, 'image_nhood_radius');
% limit_within = getappdata(handles.figure1, 'limit_within');
guassian_size = getappdata(handles.figure1, 'guassian_size');
guassian_std = getappdata(handles.figure1, 'guassian_std');
intensity_percentile = getappdata(handles.figure1, 'intensity_percentile');

def = {num2str(thresh_factor), num2str(image_nhood_radius),  ...  num2str(limit_within),
       num2str(guassian_size), num2str(guassian_std), num2str(intensity_percentile)};

prompt = {'Threshold factor', 'Neighborhood radius', ... 'Image cropped within embryo', 
    'Smoothing radius', 'Smoothing std', 'Fraction of intensities used for determining threshold value'};
dlg_title = 'options passed to segment image and projection';
num_lines = 1;
answer = cellfun(@str2num, inputdlg(prompt,dlg_title,num_lines,def));
if isempty(answer)
    return
end
thresh_factor = answer(1);
image_nhood_radius = answer(2);
% limit_within = answer(3);
guassian_size = answer(3);
guassian_std = answer(4);
intensity_percentile = answer(5);

setappdata(handles.figure1, 'thresh_factor', thresh_factor);
setappdata(handles.figure1, 'image_nhood_radius', image_nhood_radius);
% setappdata(handles.figure1, 'limit_within', limit_within);
setappdata(handles.figure1, 'guassian_size', guassian_size);
setappdata(handles.figure1, 'guassian_std', guassian_std);
setappdata(handles.figure1, 'intensity_percentile', intensity_percentile);





% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function stretch_limits_menu_Callback(hObject, eventdata, handles)
% hObject    handle to stretch_limits_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function equal_hist_menu_Callback(hObject, eventdata, handles)
% hObject    handle to equal_hist_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end




% --------------------------------------------------------------------
function overwrite_seg_menu_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite_seg_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function overwrite_bnr_menu_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite_bnr_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function save_projected_images_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_projected_images_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end






function t_from_Callback(hObject, eventdata, handles)
% hObject    handle to t_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_from as text
%        str2double(get(hObject,'String')) returns contents of t_from as a double


% --- Executes during object creation, after setting all properties.
function t_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_from_Callback(hObject, eventdata, handles)
% hObject    handle to z_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_from as text
%        str2double(get(hObject,'String')) returns contents of z_from as a double


% --- Executes during object creation, after setting all properties.
function z_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_to_Callback(hObject, eventdata, handles)
% hObject    handle to t_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_to as text
%        str2double(get(hObject,'String')) returns contents of t_to as a double


% --- Executes during object creation, after setting all properties.
function t_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_to_Callback(hObject, eventdata, handles)
% hObject    handle to z_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_to as text
%        str2double(get(hObject,'String')) returns contents of z_to as a double


% --- Executes during object creation, after setting all properties.
function z_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function release_frame_push_btns(handles, hObject)
h = [handles.single_frame_btn handles.all_t_btn handles.all_z_btn handles.all_frames_btn];
h = setdiff(h, hObject, 'legacy');
set(h, 'value', 0);

    
% --- Executes on button press in single_frame_btn.
function single_frame_btn_Callback(hObject, eventdata, handles)
% hObject    handle to single_frame_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'value')
    release_frame_push_btns(handles, hObject);
    set_frame_num_limits(handles)
end

% --- Executes on button press in all_t_btn.
function all_t_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_t_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'value')
    release_frame_push_btns(handles, hObject);
    set_frame_num_limits(handles)
end

% --- Executes on button press in all_z_btn.
function all_z_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_z_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'value')
    release_frame_push_btns(handles, hObject);
    set_frame_num_limits(handles)
end

% --- Executes on button press in all_frames_btn.
function all_frames_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_frames_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'value')
    release_frame_push_btns(handles, hObject);
    set_frame_num_limits(handles)
end

function set_frame_num_limits(handles)
frame_num = getappdata(handles.figure1, 'frame_num');
[i j] = find(frame_num);
min_t = num2str(min(i));
max_t = num2str(max(i));
min_z = num2str(min(j));
max_z = num2str(max(j));
t = get(handles.frame_slider, 'value');
z_for_t = getappdata(handles.figure1, 'z_for_t');
z = num2str(z_for_t(t));
t = num2str(t);

h = [handles.single_frame_btn handles.all_t_btn handles.all_z_btn handles.all_frames_btn];
temp_ver = get(h, 'value');
action = find([temp_ver{:}]);
if isempty(action)
    return
end
switch action
    case 1 % current frame
        set(handles.t_from, 'string', t);
        set(handles.t_to, 'string', t);
        set(handles.z_from, 'string', z);
        set(handles.z_to, 'string', z);
    case 2 % all t values at current z
        set(handles.t_from, 'string', min_t);
        set(handles.t_to, 'string', max_t);
        set(handles.z_from, 'string', z);
        set(handles.z_to, 'string', z);
    case 3 %all z valuesat current
        set(handles.t_from, 'string', t);
        set(handles.t_to, 'string', t);
        set(handles.z_from, 'string', min_z);
        set(handles.z_to, 'string', max_z);        
    case 4 %all frames
        set(handles.t_from, 'string', min_t);
        set(handles.t_to, 'string', max_t);
        set(handles.z_from, 'string', min_z);
        set(handles.z_to, 'string', max_z);
end

%----------------------------------------------
function states = disable_all_controls(handles)
zoom off
pan off
set(handles.zoom_btn, 'Value', 0)
set(handles.pan_btn, 'Value', 0)
states = [];
names = fieldnames(handles);
for i = 1:length(names)
    ctrl = getfield(handles, names{i});
    if isprop(ctrl, 'Enable') && ctrl ~= handles.figure1 ...
            && ctrl ~= handles.axes1
        states.(names{i}) = get(ctrl, 'Enable');
        set(ctrl, 'Enable', 'Off');
    end
end
set(handles.help_info, 'Enable', 'on');
set(handles.dummy_for_focus, 'Enable', 'on');
uicontrol(handles.dummy_for_focus);
setappdata(handles.figure1, 'disabled_mode', 1);

%--------------------------------------------
function enable_all_controls(handles, states)
names = fieldnames(states);
for i = 1:length(names)
    ctrl = names{i};
    if isprop(handles.(ctrl), 'Enable')
        set(handles.(ctrl), 'Enable', states.(ctrl));
    end
end
setappdata(handles.figure1, 'disabled_mode', 0);


% --- Executes on button press in pan_btn.
function pan_btn_Callback(hObject, eventdata, handles)
% hObject    handle to pan_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pan_btn

axes(handles.axes1)
if get(hObject,'Value') 
    pan on
    set(handles.zoom_btn, 'value', 0);
    zoom off
else
    pan off
end

% --- Executes on button press in dummy_for_focus.
function dummy_for_focus_Callback(hObject, eventdata, handles)
% hObject    handle to dummy_for_focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function channel1_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.tif');
if isequal(filename,0) &&  isequal(pathname,0)
    return
end

set(handles.channel1, 'value', true);
% filename = filename_wildcard(filename); %MATLAB DOESN'T RECOGNIZE THE ? WILDTYPE CHARACTER! need to fix this.
% setup_dir(handles, pathname, filename);
load_channel_tracking(handles, 1, filename, pathname);
set_multi_channel(handles, 1)



% --------------------------------------------------------------------
function channel2_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.tif');
if isequal(filename,0) &&  isequal(pathname,0)
    return
end
load_channel_tracking(handles, 2, filename, pathname);
% set(handles.channel2, 'value', true);
% set(handles.channel2, 'enable', 'on');
% set(handles.z_shift_ch2, 'enable', 'on');
% set(handles.wt_ch2, 'enable', 'on');
% setappdata(handles.figure1, 'dir_channel2', pathname);
% setappdata(handles.figure1, 'filename_channel2', filename);
set_multi_channel(handles, 1)

% --------------------------------------------------------------------
function channel3_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel3_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.tif');
if isequal(filename,0) &&  isequal(pathname,0)
    return
end
load_channel_tracking(handles, 3, filename, pathname);
% set(handles.channel3, 'value', true);
% set(handles.channel3, 'enable', 'on');
% set(handles.z_shift_ch3, 'enable', 'on');
% set(handles.wt_ch3, 'enable', 'on');
% setappdata(handles.figure1, 'dir_channel3', pathname);
% setappdata(handles.figure1, 'filename_channel3', filename);
set_multi_channel(handles, 1)

function set_multi_channel(handles, multi)
if multi 
%     setappdata(handles.figure1, 'channel1', true);
    setappdata(handles.figure1, 'multi_channel', true)
    set(handles.multi_channel_menu, 'enable', 'on')
    set(handles.multi_channel_menu, 'checked', 'on')
    set(handles.channel1, 'visible', 'on')
    set(handles.channel2, 'visible', 'on')
    set(handles.channel3, 'visible', 'on')
    set(handles.multichannel_panel, 'visible', 'on');
else
    setappdata(handles.figure1, 'multi_channel', false)
    set(handles.multi_channel_menu, 'checked', 'off')
    set(handles.channel1, 'visible', 'off')
    set(handles.channel2, 'visible', 'off')
    set(handles.channel3, 'visible', 'off')
    set(handles.multichannel_panel, 'visible', 'off');
end
up_fr(handles)


% --- Executes on button press in channel3.
function channel3_Callback(hObject, eventdata, handles)
% hObject    handle to channel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel3
up_fr(handles)

% --- Executes on button press in channel1.
function channel1_Callback(hObject, eventdata, handles)
% hObject    handle to channel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel1
up_fr(handles)

% --- Executes on button press in channel2.
function channel2_Callback(hObject, eventdata, handles)
% hObject    handle to channel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel2
up_fr(handles)

% --------------------------------------------------------------------
function multi_channel_menu_Callback(hObject, eventdata, handles)
% hObject    handle to multi_channel_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(lower(get(hObject, 'checked')), 'on')
    set(hObject, 'checked', 'off');
    set_multi_channel(handles, 0)
else
    set(hObject, 'checked', 'on');
    set_multi_channel(handles, 1)
end


% --------------------------------------------------------------------
function subtract_background_after_menu_Callback(hObject, eventdata, handles)
% hObject    handle to subtract_background_after_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end



function minus_t_for_bnr_b4_seg_Callback(hObject, eventdata, handles)
% hObject    handle to minus_t_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minus_t_for_bnr_b4_seg as text
%        str2double(get(hObject,'String')) returns contents of minus_t_for_bnr_b4_seg as a double


% --- Executes during object creation, after setting all properties.
function minus_t_for_bnr_b4_seg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minus_t_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plus_t_for_bnr_b4_seg_Callback(hObject, eventdata, handles)
% hObject    handle to plus_t_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plus_t_for_bnr_b4_seg as text
%        str2double(get(hObject,'String')) returns contents of plus_t_for_bnr_b4_seg as a double


% --- Executes during object creation, after setting all properties.
function plus_t_for_bnr_b4_seg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plus_t_for_bnr_b4_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function smoothen_image_menu_Callback(hObject, eventdata, handles)
% hObject    handle to smoothen_image_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end




% --------------------------------------------------------------------
function external_proj_menu_Callback(hObject, eventdata, handles)
% hObject    handle to external_proj_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end

function output_string = projection_details(handles, action, t, z, projection_method)

subtract_background_before = strcmpi('on', get(handles.subtract_background_before_menu, 'checked'));
subtract_background_after = strcmpi('on', get(handles.subtract_background_after_menu, 'checked'));
rad = getappdata(handles.figure1, 'image_nhood_radius');
stretch_limits = strcmpi('on', get(handles.stretch_limits_menu, 'checked'));
equalize = strcmpi('on', get(handles.equal_hist_menu, 'checked'));
smth = strcmpi('on', get(handles.smoothen_image_menu, 'checked'));
guassian_size = getappdata(handles.figure1, 'guassian_size');
guassian_std = getappdata(handles.figure1, 'guassian_std');
external_proj = strcmpi('on', get(handles.external_proj_menu, 'checked'));
custom = strcmpi('on', get(handles.custom_img_proc, 'checked'));
grad_mthd = strcmpi('on', get(handles.grad_methd, 'checked'));
piv_temp = strcmpi('on', get(handles.piv_temp_proj, 'checked'));
minus_z = str2double(get(handles.minus_z_for_bnr_b4_seg, 'string'));
plus_z = str2double(get(handles.plus_z_for_bnr_b4_seg, 'string'));
minus_t = str2double(get(handles.minus_t_for_bnr_b4_seg, 'string'));
plus_t = str2double(get(handles.plus_t_for_bnr_b4_seg, 'string'));



options = {...
    'z below',                  minus_z,                                        1;       
    'z above',                  plus_z,                                         1;
    't before',                 minus_t,                                        1;
    't after',                  plus_t,                                         1;
    'subtract before proj',     subtract_background_before,                     1;    
    'subtract after proj',      subtract_background_after,                      1;    
    'neighborhood radius',      rad,                                            1;    
    'stretch limits',           stretch_limits,                                 1;
    'equalize',                 equalize,                                       1;
    'smoothening',              smth,                                           1;
    'gaussuan size',            guassian_size,                                  1;
    'gaussuan std',             guassian_std,                                   1;
    'external code',            external_proj,                                  1;
    'custom',                   custom                                          1;
    'gradient method',          grad_mthd                                       1;
    'PIV temp proj',            piv_temp                                        1};
    

if strcmpi(action, 'init')
    frame_num = getappdata(handles.figure1, 'frame_num');
    proj_options = nan([size(frame_num) length(options)]);
    proj_meth = cell(size(frame_num));
    setappdata(handles.figure1, 'proj_options', proj_options)
    setappdata(handles.figure1, 'proj_meth', proj_meth)
    proj_filename = getappdata(handles.figure1, 'proj_info_filename');
    save(proj_filename, 'proj_options', 'proj_meth');
    return
end

proj_options = getappdata(handles.figure1, 'proj_options');
proj_meth = getappdata(handles.figure1, 'proj_meth');


if strcmpi(action, 'read')
    output_string = sprintf('projection method = %s\r\n', proj_meth{t, z});
    for i = 1:min(length(options), size(proj_options, 3))
        if options{i, 3}
            str = '%s = %s\r\n';
        else
            str = '%s = %s             ';
        end
        output_string  = [output_string sprintf(str, options{i, 1}, num2str(proj_options(t, z, i)))];
    end
elseif strcmpi(action, 'write')
    proj_meth(t, z) = {projection_method};
    for i = 1:length(options)
        proj_options(t, z, i) = options{i, 2};
    end
    proj_filename = getappdata(handles.figure1, 'proj_info_filename');
    save(proj_filename, 'proj_options', 'proj_meth');
    setappdata(handles.figure1, 'proj_options', proj_options)
    setappdata(handles.figure1, 'proj_meth', proj_meth)
end



function z_shift_ch1_Callback(hObject, eventdata, handles)
% hObject    handle to z_shift_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_shift_ch1 as text
%        str2double(get(hObject,'String')) returns contents of z_shift_ch1 as a double


% --- Executes during object creation, after setting all properties.
function z_shift_ch1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_shift_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_shift_ch2_Callback(hObject, eventdata, handles)
% hObject    handle to z_shift_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_shift_ch2 as text
%        str2double(get(hObject,'String')) returns contents of z_shift_ch2 as a double


% --- Executes during object creation, after setting all properties.
function z_shift_ch2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_shift_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_shift_ch3_Callback(hObject, eventdata, handles)
% hObject    handle to z_shift_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_shift_ch3 as text
%        str2double(get(hObject,'String')) returns contents of z_shift_ch3 as a double


% --- Executes during object creation, after setting all properties.
function z_shift_ch3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_shift_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wt_ch1_Callback(hObject, eventdata, handles)
% hObject    handle to wt_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wt_ch1 as text
%        str2double(get(hObject,'String')) returns contents of wt_ch1 as a double


% --- Executes during object creation, after setting all properties.
function wt_ch1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wt_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wt_ch2_Callback(hObject, eventdata, handles)
% hObject    handle to wt_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wt_ch2 as text
%        str2double(get(hObject,'String')) returns contents of wt_ch2 as a double


% --- Executes during object creation, after setting all properties.
function wt_ch2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wt_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wt_ch3_Callback(hObject, eventdata, handles)
% hObject    handle to wt_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wt_ch3 as text
%        str2double(get(hObject,'String')) returns contents of wt_ch3 as a double


% --- Executes during object creation, after setting all properties.
function wt_ch3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wt_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in multi_ch_target_button.
function multi_ch_target_button_Callback(hObject, eventdata, handles)
% hObject    handle to multi_ch_target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = getappdata(handles.figure1, 'home_dir');
[filename pathname] = uiputfile('*.tif', '', directory); 
if any(filename)
    set(handles.multi_ch_target_filename, 'string', fullfile(pathname, filename));
    setappdata(handles.figure1, 'multi_ch_proj_filename', fullfile(pathname, filename));
    up_fr(handles)
end

% --- Executes on button press in combine_button.
function combine_button_Callback(hObject, eventdata, handles)
% hObject    handle to combine_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

target_filename = get(handles.multi_ch_target_filename, 'string');
if isempty(target_filename)
    msg = 'Target filename not set';
    h = msgbox(msg, '', 'error', 'modal');
    waitfor(h)
    return
end
[pathname filename ext] = fileparts(target_filename);
if ~isdir(pathname)
    mkdir(pathname);
end
test_z = get_file_nums(filename, 1);
if isempty(test_z)
    filename = [filename '_T0000_Z0000'];
end
target_filename = fullfile(pathname, [filename ext]);
setappdata(handles.figure1, 'multi_ch_proj_filename', target_filename);
z_shift = ~get(handles.no_z_shift, 'value');
z_shift_for_t = 0;
min_t = get(handles.frame_slider, 'min');
if get(handles.z_shift_apply_to_radio_button, 'value')
    min_t = str2double(get(handles.t_from, 'String'));
end

if z_shift 
    z_shift_for_t = getappdata(handles.figure1, 'z_for_t');
    z_shift_for_t = z_shift_for_t - z_shift_for_t(min_t);
end

frames = getappdata(handles.figure1, 'frames');
frame_num = getappdata(handles.figure1, 'frame_num');
func_name = get(handles.proj_func, 'string');
proj_method = func_name{get(handles.proj_func, 'value')};
OVERWRITE = get(handles.multi_ch_overwrite, 'value');

min_t = str2double(get(handles.t_from, 'String'));
max_t = str2double(get(handles.t_to, 'String'));
min_z = str2double(get(handles.z_from, 'String'));
max_z = str2double(get(handles.z_to, 'String'));



weights = [1 1 1];
for ch = 1:3
    w = str2double(get(handles.(['wt_ch' num2str(ch)]), 'string'));
    if ~isempty(w)
        weights(ch) = w;
    end
end

shifts = [0 0 0];
for ch = 1:3
    w = str2double(get(handles.(['z_shift_ch' num2str(ch)]), 'string'));
    if ~isempty(w)
        shifts(ch) = w;
    end
end

for ch = 1:3
    ch_dir_name = getappdata(handles.figure1, ['dir_channel' num2str(ch)]);
    ch_base_name = getappdata(handles.figure1, ['filename_channel' num2str(ch)]);
    if isempty(ch_base_name) || ~get(handles.(['channel' num2str(ch)]), 'value')
        continue
    end
    filenames{ch} = fullfile(ch_dir_name , ch_base_name);
end


for t = min_t:max_t
    for z_cnt = min_z : max_z 
        if any(z_shift_for_t)
            z = z_cnt + z_shift_for_t(t);
        else
            z = z_cnt;
        end
        if frame_num(t,z)
            new_img_filename = put_file_nums(target_filename, t, z);
            if ~isempty(dir(new_img_filename)) && ~OVERWRITE
               continue
            end

            new_img = combine_channels(t, z, filenames, weights, shifts, proj_method, handles);
            if ~strcmpi(class(new_img), 'uint8')
                new_img = uint16(new_img);
            end
            imwrite(new_img, new_img_filename, 'tiff');
%             projection_details(handles, 'write', t, z, proj_method);
        end
    end

end
set(handles.view_multi_ch_proj, 'value', 1);
view_multi_ch_proj_Callback(handles.view_multi_ch_proj, [], handles)


% --------------------------------------------------------------------
function multi_ch_brightness_menu_Callback(hObject, eventdata, handles)
% hObject    handle to multi_ch_brightness_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fac1 = num2str(getappdata(handles.figure1, 'channel1_factor'));
shift_fac1 = num2str(getappdata(handles.figure1, 'channel1_shift_factor'));
fac2 = num2str(getappdata(handles.figure1, 'channel2_factor'));
shift_fac2 = num2str(getappdata(handles.figure1, 'channel2_shift_factor'));
fac3 = num2str(getappdata(handles.figure1, 'channel3_factor'));
shift_fac3 = num2str(getappdata(handles.figure1, 'channel3_shift_factor'));

prompt = {'Channel1 shift factor', 'Channel1 scale factor', ...
    'Channel2 shift factor', 'Channel2 scale factor', ...
    'Channel3 shift factor', 'Channel3 scale factor',};
dlg_title = 'new image values = (image - shift) * scale';
num_lines = 1;
def = {shift_fac1, fac1, shift_fac2, fac2, shift_fac3, fac3};
answer = cellfun(@str2num, inputdlg(prompt,dlg_title,num_lines,def));
if isempty(answer)
    return
end

shift_fac1 = answer(1);
fac1 = answer(2);
shift_fac2 = answer(3);
fac2 = answer(4);
shift_fac3 = answer(5);
fac3 = answer(6);

setappdata(handles.figure1, 'channel1_factor', fac1);
setappdata(handles.figure1, 'channel1_shift_factor', shift_fac1);
setappdata(handles.figure1, 'channel2_factor', fac2);
setappdata(handles.figure1, 'channel2_shift_factor', shift_fac2);
setappdata(handles.figure1, 'channel3_factor', fac3);
setappdata(handles.figure1, 'channel3_shift_factor', shift_fac3);
up_fr(handles)

% --- Executes on button press in multi_ch_overwrite.
function multi_ch_overwrite_Callback(hObject, eventdata, handles)
% hObject    handle to multi_ch_overwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multi_ch_overwrite


% --- Executes on button press in apply_brightness_check.
function apply_brightness_check_Callback(hObject, eventdata, handles)
% hObject    handle to apply_brightness_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of apply_brightness_check


% --- Executes on button press in view_multi_ch_proj.
function view_multi_ch_proj_Callback(hObject, eventdata, handles)
% hObject    handle to view_multi_ch_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of view_multi_ch_proj

set(handles.Noise_check, 'FontWeight', 'normal');
set(handles.channel2, 'FontWeight', 'normal');
set(handles.channel2, 'ForegroundColor', [0 1 0]);
set(handles.channel3, 'FontWeight', 'normal');
set(handles.channel3, 'ForegroundColor', [0 0 1]);
set(handles.view_multi_ch_proj, 'FontWeight', 'Normal');
up_fr(handles)

function multi = set_multi_channel_from_file(handles, ch, channel_file, t, z)
multi = false;
if isempty(channel_file{ch})
    setappdata(handles.figure1, ['dir_channel' num2str(ch)], '');
    setappdata(handles.figure1, ['filename_channel' num2str(ch)], '');
    set(handles.(['channel' num2str(ch)]), 'enable', 'off')
    return
end
[pathname filename ext] = fileparts(channel_file{ch});
home_dir = getappdata(handles.figure1, 'directory');
pathname = relative_dir(home_dir, pathname);
filename = [filename ext];
wildcard_filename = fullfile(pathname, filename_wildcard(filename));
if ~isempty(dir(wildcard_filename))
    load_channel_tracking(handles, ch, filename, pathname);
    multi = true;
else
    sprintf('File %s for channel %d not found. Not loading channel.', wildcard_filename, ch);
end
ctrl = ['channel' num2str(ch)];
set(handles.(ctrl), 'value', multi);



% --------------------------------------------------------------------
function rescale_proj_image_Callback(hObject, eventdata, handles)
% hObject    handle to rescale_proj_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --- Executes on button press in reset_combine_options.
function reset_combine_options_Callback(hObject, eventdata, handles)
% hObject    handle to reset_combine_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menu_checked_list = {'subtract_background_before_menu', 'rescale_proj_image'};
menu_unchecked_list = {...
    'subtract_background_after_menu', 'stretch_limits_menu', 'equal_hist_menu', ...
    'smoothen_image_menu', 'external_proj_menu'};
controls_checked_list = {'apply_brightness_check', 'multi_ch_overwrite', 'view_multi_ch_proj'};
controls_unchecked_list = {};
for i = 1:length(menu_checked_list)
    set(handles.(menu_checked_list{i}), 'checked', 'on');
end
for i = 1:length(menu_unchecked_list)
    set(handles.(menu_unchecked_list{i}), 'checked', 'off');
end
for i = 1:length(controls_checked_list)
    set(handles.(controls_checked_list{i}), 'value', 1)
end
for i = 1:length(controls_unchecked_list)
    set(handles.(controls_unchecked_list{i}), 'value', 0)
end

set(handles.minus_z_for_bnr_b4_seg, 'string', 0);
set(handles.plus_z_for_bnr_b4_seg, 'string', 0);
set(handles.minus_t_for_bnr_b4_seg, 'string', 0);
set(handles.plus_t_for_bnr_b4_seg, 'string', 0);
set(handles.proj_func, 'value', 2);
set(handles.wt_ch1, 'string', 1);
set(handles.wt_ch2, 'string', 1);
set(handles.wt_ch3, 'string', 1);

function setup_no_image_channel(handles, ch)
ctrl = handles.(['channel' num2str(ch)]);
set(ctrl, 'FontWeight', 'normal');
temp_color = [0 0 0];
temp_color(ch) = 1;
set(ctrl, 'ForegroundColor', temp_color)        

function img = display_image_ch(handles, img, ch, t, z)
channel_dir = getappdata(handles.figure1, ['dir_channel' num2str(ch)]);
base_name = getappdata(handles.figure1, ['filename_channel' num2str(ch)]);
shift_z = str2double(get(handles.(['z_shift_ch' num2str(ch)]), 'string'));
img_filename = fullfile(channel_dir, put_file_nums(base_name, t, z + shift_z));
ctrl = handles.(['channel' num2str(ch)]);
if ~isempty(dir(img_filename))
    set(ctrl, 'FontWeight', 'normal');
    temp_color = [0 0 0];
    temp_color(ch) = 1;
    set(ctrl, 'ForegroundColor', temp_color);
    temp_img = imread(img_filename);
    fac = getappdata(handles.figure1, ['channel' num2str(ch) '_factor']);
    shift_fac = getappdata(handles.figure1, ['channel' num2str(ch) '_shift_factor']);
    img(1:size(temp_img, 1), 1:size(temp_img, 2), ch) = ...
        max(1, min(255, round((temp_img - shift_fac)* fac)));
else
    img(:, :, ch) = 0;
    set(ctrl, 'FontWeight', 'bold');
    temp_color = [0 0 0];
    temp_color(ch) = 0.4;
    set(ctrl, 'ForegroundColor', temp_color) 
end
    
        


% --- Executes when uipanel3 is resized.
function uipanel3_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function const_z_copy_menu_Callback(hObject, eventdata, handles)
% hObject    handle to const_z_copy_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Make z=9999 copy

if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end



% --------------------------------------------------------------------
function grad_methd_Callback(hObject, eventdata, handles)
% hObject    handle to grad_methd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --------------------------------------------------------------------
function piv_temp_proj_Callback(hObject, eventdata, handles)
% hObject    handle to piv_temp_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end


% --- Executes on button press in demo_btn.
function demo_btn_Callback(hObject, eventdata, handles)
%%%Graphically Show User What is Happening When They Segment
demo_bool = true;
home_dir = getappdata(handles.figure1, 'directory');
z_shift_file = getappdata(handles.figure1, 'z_shift_file');

z_shift = ~get(handles.no_z_shift, 'value');
z_shift_for_t = 0;
min_t = get(handles.frame_slider, 'min');
if get(handles.z_shift_apply_to_radio_button, 'value')
    min_t = str2double(get(handles.t_from, 'String'));
end

if z_shift 
        z_shift_for_t = getappdata(handles.figure1, 'z_for_t');
        z_shift_for_t = z_shift_for_t - z_shift_for_t(min_t);
end

frames = getappdata(handles.figure1, 'frames');
frame_num = getappdata(handles.figure1, 'frame_num');
[i j] = find(frame_num);

min_t = str2double(get(handles.t_from, 'String'));
max_t = str2double(get(handles.t_to, 'String'));
min_z = str2double(get(handles.z_from, 'String'));
max_z = str2double(get(handles.z_to, 'String'));


areas = getappdata(handles.figure1, 'areas');

drawnow
OVERWRITE = strcmpi(get(handles.overwrite_seg_menu, 'checked'), 'on');
OVERWRITE_images = strcmpi(get(handles.overwrite_bnr_menu, 'checked'), 'on');
save_images = strcmpi(get(handles.save_projected_images_menu, 'checked'), 'on');
const_z_copy = strcmpi(get(handles.const_z_copy_menu, 'checked'), 'on');
NO_LAYERS = strcmpi(get(handles.no_layers_menu, 'checked'), 'on');
options.update_positions = strcmpi(get(handles.reposition_nodes_menu, 'checked'), 'on');
options.local_mean = strcmpi(get(handles.subtract_background_during_menu, 'checked'), 'on');
options.thresh_factor = getappdata(handles.figure1, 'thresh_factor');
options.image_nhood_radius =  getappdata(handles.figure1, 'image_nhood_radius');
options.limit_within = getappdata(handles.figure1, 'limit_within');
options.intensity_percentile = getappdata(handles.figure1, 'intensity_percentile');
func_name = get(handles.thresh_function, 'string');
options.thresh_function = func_name{get(handles.thresh_function, 'value')};
func_name = get(handles.proj_func, 'string');
proj_method = func_name{get(handles.proj_func, 'value')};


if save_images && ~isdir(fullfile(home_dir,'bnr'))
    mkdir(fullfile(home_dir, 'bnr'))
end
if save_images && const_z_copy && ~isdir(fullfile(home_dir, '9999'))
    mkdir(fullfile(home_dir, '9999'))
end
im_written = false;
for t = min_t:max_t
    for z_cnt = min_z : max_z 
        if any(z_shift_for_t)
            z = z_cnt + z_shift_for_t(t);
        else
            z = z_cnt;
        end
        if frame_num(t,z)
            if ~NO_LAYERS
                
                %%%%%%%% DEMO STUFF %%%%%%%%%
                disp_str = '--------(DEMO) - PROJECTION-------------------';
                fprintf(['\n ',disp_str,' \n']);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                img = project_along_z(t,z, proj_method, frames, frame_num, handles,demo_bool);
                
                new_img_filename = fullfile(home_dir, 'bnr', frames(frame_num(t,z)).name);
                if save_images && (~length(dir(new_img_filename)) || OVERWRITE_images)
                   imwrite(img, new_img_filename, 'tiff');
                    if const_z_copy
                        const_z_filename = fullfile(home_dir, '9999', frames(frame_num(t,z)).name);
                        const_z_filename = put_file_nums(const_z_filename, [], 9999);
                        imwrite(img, const_z_filename, 'tiff');
                    end
                   projection_details(handles, 'write', t, z, proj_method)
                   im_written = true;
                end
            else
                img = imread(frames(frame_num(t,z)).name);
            end
            if strcmpi(get(handles.auto_limit_area_menu, 'checked'), 'on')
                wa = limit2embryo(img);
                areas(t,z).wa = wa;
                setappdata(handles.figure1, 'areas', areas);
            else
                if isappdata(handles.figure1, 'poly_seq');
                    poly_seq = getappdata(handles.figure1, 'poly_seq');
                    poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
%                     [dummy poly_ind] = min(abs(frame_num(t,z) - poly_frame_ind));
                    inv_frame_num = getappdata(handles.figure1,'inv_frame_num');
                    [poly dummy] = get_poly_for_frame(frame_num(t,z), poly_frame_ind, poly_seq, inv_frame_num);
                    X = poly.x;
                    Y = poly.y;
                    X = reshape(X, [], 1);
                    Y = reshape(Y, [], 1);
                    wa = [X Y];
                else
                    [imgx, imgy] = size(img);
                    wa = [1 1; imgx 1; imgx imgy; 1 imgy];
                end
            end
            options.workingarea = wa;
            options.frames = frames;
            options.frames_num = frame_num;
            options.z = z;
            options.t = t;
            
            
            filenames{1} = frames(frame_num(t,z)).name;
            [pathstr, name, ext] = fileparts(filenames{1});
            
            options.original_file = filenames{1};
            
            casename = [name '.mat'];
            if length(dir(fullfile(home_dir, casename))) && ~OVERWRITE
               continue
            end
            
            cellgeom = segment_image(img, options);
            save(fullfile(home_dir, casename), 'cellgeom', 'casename', 'filenames');            
            up_fr(handles, t, z, true)
        end
    end
end
toc
if im_written
    write_image_log([], fullfile(home_dir, 'bnr'), min_z, max_z, min_t, max_t, proj_method, ...
        handles)
end
figure(handles.figure1);
h = msgbox('Done!');
waitfor(h);


% --------------------------------------------------------------------
function custom_img_proc_Callback(hObject, eventdata, handles)
if strcmpi(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end
