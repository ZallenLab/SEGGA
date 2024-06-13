function varargout = tracking(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A global variable, seq, is used instead of storing it as application data
%% for performance reasons. One can't retrieve or change specific array
%% elements from application data (with getappdata and setappdata), only
%% entire arrays. When dealing with thousands of frames, seq becomes huge
%% and there is quite a delay everytime a local copy is made in the current
%% workspace.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TRACKING M-file for tracking.fig
%      TRACKING, by itself, creates a new TRACKING or raisesmovei the
%      existing
%      singleton*.
%
%      H = TRACKING returns the handle to a new TRACKING or the handle to
%      the existing singleton*.
%
%      TRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKING.M with the given input arguments.
%
%      TRACKING('Property','Value',...) creates a new TRACKING or raises
%      the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tracking_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tracking

% Last Modified by GUIDE v2.5 15-Dec-2016 16:57:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tracking_OpeningFcn, ...
                   'gui_OutputFcn',  @tracking_OutputFcn, ...
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


% --- Executes just before tracking is made visible.
function tracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tracking (see VARARGIN)

% Choose default command line output for tracking
handles.output = hObject;
set(handles.drawing_style, 'userdata', 3); %start with symbols
poly_filename = 'poly_seq.mat';

setappdata(handles.figure1,'on_off_poly_bool',true);
setappdata(handles.figure1,'poly_filename',poly_filename);
handles.axes1.XLimMode = 'manual';
handles.axes1.YLimMode = 'manual';
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes tracking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tracking_OutputFcn(hObject, eventdata, handles) 
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
global seq
[dummy ind] = min(abs(seq.valid_t_vals - get(hObject,'Value')));
set(hObject, 'Value', seq.valid_t_vals(ind));
update_frame(handles, get(hObject, 'Value'), -get(handles.slice_slider, 'Value'));

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

if ~get(hObject, 'value')
    return
end

%seq = getappdata(handles.figure1, 'seq');
global seq
user_lighted = getappdata(handles.figure1, 'user_cells');
user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');
edges = getappdata(handles.figure1, 'user_edges');





set(handles.play_backward, 'value', 0);
i = str2double(get(handles.frame_number, 'String'));
while get(hObject, 'value')
    i = str2double(get(handles.frame_number, 'String'));
    i = i + seq.t_jump;
    if i > get(handles.frame_slider, 'max')
        i = get(handles.frame_slider, 'min');
    end
    z = str2double(get(handles.slice_number, 'String'));
    update_frame(handles, i, z)
    if ~ishandle(hObject)
        break
    end
end




% --- Executes on button press in play_backward_old.
function play_backward_Callback(hObject, eventdata, handles)
% hObject    handle to play_backward_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seq
if ~get(hObject, 'value')
    return
end
set(handles.play_forward, 'value', 0);
i = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
while get(hObject, 'value')
    i = str2double(get(handles.frame_number, 'String'));
    i = i - seq.t_jump;
    if i < get(handles.frame_slider, 'min')
        i = get(handles.frame_slider, 'max');
    end
    update_frame(handles, i, z)
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
global seq
[dummy ind] = min(abs(seq.valid_t_vals - str2double(get(hObject,'String'))));
val = seq.valid_t_vals(ind);
% val = min(max(round(str2double(get(hObject,'String'))), ...
%     get(handles.frame_slider, 'Min')), get(handles.frame_slider, 'Max'));
set(hObject, 'String', val);
set(handles.frame_slider, 'Value', val);
z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, val, z);

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




% --------------------------------------------------------------------
function drawing_style_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to drawing_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.drawing_style, 'userdata', get(hObject, 'userdata'));
if get(hObject, 'userdata') == 3 %symbol
    draw_patch_dummy(handles.figure1, 'solid')
else
    if get(handles.drawing_method, 'userdata') == 1 %transparent
        draw_patch_dummy(handles.figure1, 'trans')
    end
end
z = str2double(get(handles.slice_number, 'String'));
if get(hObject, 'userdata') == 2 % clusters
    set_gui_clusters(handles, 1);
    global seq
    if ~isfield(seq, 'clusters_map');
        [seq.frames.clusters_data] = deal([]);
        seq.clusters_map = zeros(length(seq.frames), 1, 'uint16');
        seq.inv_clusters_map = uint16([]);
        seq.clusters_colors = [];

    end
end
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);




% --------------------------------------------------------------------
function drawing_method_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to drawing_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.drawing_method, 'userdata', get(hObject, 'userdata'));
if get(hObject, 'userdata') == 2 %solid
    draw_patch_dummy(handles.figure1, 'solid')
else
    if get(handles.drawing_style, 'userdata') ~= 3 %symbol
        draw_patch_dummy(handles.figure1, 'trans')
    end
end
z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);



% --- Executes on button press in draw_geometry.
function draw_geometry_Callback(hObject, eventdata, handles)
% hObject    handle to draw_geometry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of draw_geometry

z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);


function make_image_seq(handles)
drawingfig = handles.figure1;
if get(handles.newfig_check, 'value')
    drawingfig = getappdata(handles.figure1, 'drawingfig');
end

[FileName,PathName] = uiputfile({'*.tif';'*.pdf';'*.eps'},'save image sequence as (base filename)') ;
if FileName == 0 & PathName == 0
    return
end
[pathstr, name, ext] = fileparts(FileName);


global seq
img = imread(fullfile(seq.directory, seq.frames(1).img_file));

ax = get(drawingfig, 'CurrentAxes');
old_units = get(ax, 'units');
set(ax, 'units', 'pixels')
pos = get(ax, 'position');
old_pos = pos;
pos = round(pos);
pos([4 3]) = [size(img,1),size(img,2)];
% mod(size(img), 4)
set(ax, 'position', pos);
z = str2double(get(handles.slice_number, 'String'));
t_frames = str2double(get(handles.t_from, 'string')):str2double(get(handles.t_to, 'string'));
new_fig = [];
for i = 1:length(t_frames)
    update_frame(handles, t_frames(i), z);
    figure(drawingfig);
    movie_frame = getframe(ax);   
    dest = fullfile(PathName, sprintf('%s%04u%s', name, i, ext));
    if strcmp(ext,'.tif')
        imwrite(movie_frame.cdata,dest, 'Resolution',[2000,2000]);
    else if strcmp(ext,'.pdf') || strcmp(ext,'.eps')
            if isempty(new_fig)
                new_fig = figure;
                hardcode_pos = [298, 83, 1143, 902];
                set(new_fig,'position',hardcode_pos);
            else
                delete(get(new_fig,'children'));
            end
         
           copyobj(ax,new_fig);
           set(new_fig,'PaperpositionMode','Auto');
           fix_2016a_figure_output(new_fig);
           if strcmp(ext,'.pdf')
               saveas(new_fig,dest);
           end
           if strcmp(ext,'.eps')
               saveas(new_fig,dest,'epsc2');
           end
        else
            display(['unknown extension: ',ext]);
        end
    end
end
if ~isempty(whos('new_fig'))&&~isempty(new_fig)
    close(new_fig)
end
set(ax, 'position', old_pos);
set(ax, 'units', old_units);

%%%% Trying to improve resolution
%%%% Files are much larger without much improvement to res
%%%% ... to be continued
high_res_try_bool = false;
if high_res_try_bool
    if ~isdir([PathName, 'other',filesep])
        mkdir([PathName, 'other',filesep]);
    end
    for i = 1:length(t_frames)
        h = figure; image(movie_frame.cdata);
        axis off 
        dest2 = fullfile(PathName, 'other',filesep,sprintf('%s%04u%s', name, i, ext));
        print(gcf, '-painters', '-r600', '-dtiffn', dest2)       
        close(h);
    end
end

% --- Executes on button press in make_movie.
function make_movie_Callback(hObject, eventdata, handles)
% hObject    handle to make_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

make_image_seq(handles)
return

drawingfig = handles.figure1;
if get(handles.newfig_check, 'value')
    drawingfig = getappdata(handles.figure1, 'drawingfig');
end

[FileName,PathName] = uiputfile('*.avi','save movie as') ;
if FileName == 0 & PathName == 0
    return
end

dest = fullfile(PathName, FileName);
ax = get(drawingfig, 'CurrentAxes');
z = str2double(get(handles.slice_number, 'String'));
t_frames = str2double(get(handles.t_from, 'string')):str2double(get(handles.t_to, 'string'));
for i = 1:length(t_frames)
    update_frame(handles, t_frames(i), z);
    figure(drawingfig);
    movie_frames(i) = getframe(ax);
end
% global ori_movie
% ori_movie = movie_frames;
h = waitbar(0, 'Please wait...', 'WindowStyle', 'Modal');
movie2avi(movie_frames, dest, 'compression', 'none', 'fps', 10);
close(h);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% button = questdlg('do you want to save the dynamic highlighting?');
% if strcmp(button, 'Cancel')
%     return
% end
% set(handles.play_forward, 'value', 0);
% set(handles.play_backward_old, 'value', 0);
% if strcmp(button, 'Yes')
%     if ~save_dh(handles)
%         return
%     end
% end

set(handles.play_forward, 'value', 0);
set(handles.play_backward, 'value', 0);


%if necessary, save the current updates
%seq = getappdata(handles.figure1, 'seq');
global seq

old_readonly = get(handles.readonly_menu, 'Checked');
readonly = strcmp(lower(old_readonly), 'on');

num_frames_changed = sum([seq.frames.changed]);
num_frames_saved = sum([seq.frames.saved]);
if num_frames_changed > 0
    if seq.changed
        msg = 'Do you want to save the changes made to the geometry?\n %d frames will be saved.';
        msg = sprintf(msg, num_frames_changed);
        button = questdlg(msg);
        if strcmp(button, 'Cancel')
            return
        end
        if strcmp(button, 'Yes')
            set(handles.readonly_menu, 'Checked', 'off')
            readonly = false;
        end
        if strcmp(button, 'No')
            if num_frames_saved == 0
                seq.changed = false;
            end
            set(handles.readonly_menu, 'Checked', 'on')
            readonly = true;
            for i= 1:length(seq.frames)
                if isfield(seq.frames(i), 'changed') && seq.frames(i).changed                
                    seq.frames(i).cellgeom_edit = seq.frames(i).cellgeom;
                    seq.frames(i).changed = 0;
                    seq.frames(i).saved = 0;
                end
            end
        end
    end
end

save_changed_frames(handles)

set(handles.readonly_menu, 'Checked', old_readonly)



if seq.changed && ...
        (~isappdata(handles.figure1, 'quick_edit_mode') || ...
         ~getappdata(handles.figure1, 'quick_edit_mode'))

    msg = ['Changes were made to the geometry. Do you want to try and track' ...
        ' the highlighted cells in the new geometry and save the data?'...
        ' Pressing No will cause the highlighting data to be lost.'];
    button = questdlg(msg);
    if strcmp(button, 'Cancel')
        return
    end
    
    if strcmp(button, 'Yes')
        if readonly
            geom_changed = false;
        else
            geom_changed = true;
        end
        if ~save_dh(handles, geom_changed)
            return
        end
        for i = 1:length(seq.frames)
            if seq.frames(i).sticky_changed
                %need to create all data fields in clusters_data before
                %calling generate_data!!
%                 data = generate_data(seq.frames(i).cellgeom_edit, ...
%                                      seq.frames(i).clusters_data);
%                 [pathstr, name, ext, versn] = seq.frames(i).filename;
%                 new_filename = [name '_data.mat'];
%                 save(new_filename, 'data', '-v6');
            end
        end
    end
end


%update the seq copy in the calling window 
h = getappdata(handles.figure1, 'calling_window');
if ishandle(h)
    t = str2double(get(handles.frame_number, 'String'));
    z = str2double(get(handles.slice_number, 'String'));
    frame_num = seq.frames_num(t, z);
    
    % DLF DEBUG EDIT September 5 2013
    if frame_num == 0
        display('using dlf debug [line 454 inside tracking]');
        frame_num = nonzeros(seq.frames_num(t,:));
    end
    
    if seq.changed
        rmappdata(h, 'seq');
        setappdata(h, 'tracking_frame', seq.frames(frame_num).filename);        
        setappdata(h, 'tracking_dir', seq.directory);
    else
        setappdata(h, 'seq', seq);
        setappdata(h, 'tracking_frame', seq.frames(frame_num).filename);
        setappdata(h, 'tracking_dir', seq.directory);
    end
end


if ishandle(getappdata(handles.figure1, 'drawingfig'))
    %close(getappdata(handles.figure1, 'drawingfig'));
end
delete(hObject);
global changed
changed = 0;

function modified_clusters = add_cell_to_clusters(cell, frame_num)
global seq
cl_data = seq.frames(frame_num).clusters_data;
nodecellmap = seq.frames(frame_num).cellgeom.nodecellmap;
clusters_ind = false(1, length(cl_data));
for i = 1:length(cl_data)
    if ismember(cell, cl_data(i).cells, 'legacy');
        cl_data(i).cells = setdiff(cl_data(i).cells, cell, 'legacy');
            if length(cl_data) == 1
                cl_data = ...
                    build_cluster_data(cl_data(i).cells, ...
                    seq.frames(frame_num).cellgeom);
            else                
                cl_data(i) = ...
                    build_cluster_data(cl_data(i).cells, ...
                    seq.frames(frame_num).cellgeom);
            end
        clusters_ind(i) = true;
    end
end
if ~any(clusters_ind)
    mult_clstr = [];
    cell_ind = ismember(nodecellmap(:,1), cell, 'legacy');
    for i = 1:length(cl_data)
        cl_cells_ind = ismember(nodecellmap(:,1), cl_data(i).cells, 'legacy');
        if any(ismember(nodecellmap(cell_ind, 2), nodecellmap(cl_cells_ind, 2), 'legacy'));
            mult_clstr = [mult_clstr i];
        end
    end
    if length(mult_clstr)
        j = 1;
        if length(mult_clstr) > 1
            inpt = inputdlg('Which cluster do you want to add the cell to?', num2str(length(mult_clstr)));
            if length(inpt)
                eval(['j = [' inpt{1} '];']);
            else
                modified_clusters = clusters_ind;
                return
            end
        end
        if j == 0
            j = 1:length(mult_clstr);
        end
        for i = 1:length(j)
            cl_data(mult_clstr(j(i))).cells = [cl_data(mult_clstr(j(i))).cells cell];
            if length(cl_data) == 1
                cl_data = ...
                    build_cluster_data(cl_data(mult_clstr(j(i))).cells, ...
                    seq.frames(frame_num).cellgeom);
            else                
                cl_data(mult_clstr(j(i))) = ...
                    build_cluster_data(cl_data(mult_clstr(j(i))).cells, ...
                    seq.frames(frame_num).cellgeom);
            end
            clusters_ind(mult_clstr(j(i))) = true;
        end
    end
end

modified_clusters = clusters_ind;
if ~any(clusters_ind)
    if ~length(cl_data) 
        cl_data = ...
            build_cluster_data(cell, seq.frames(frame_num).cellgeom);
    else                
        cl_data(end + 1) = build_cluster_data(cell, ...
            seq.frames(frame_num).cellgeom);
    end
    modified_clusters(end + 1) = 1;
end
seq.frames(frame_num).clusters_data = cl_data;


% --- Executes on button press in user_select_button.
function user_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to user_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.newfig_check, 'value')
    figure(getappdata(handles.figure1, 'drawingfig'));
end

clusters = false;
if strcmp(lower(get(handles.files2cluster, 'Checked')), 'on');
    clusters = true;
end

%seq = getappdata(handles.figure1, 'seq');
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);  
cellgeom = seq.frames(frame_num).cellgeom;
user_lighted_ind = false(1, length(cellgeom.circles(:,1)));
user_lighted = getappdata(handles.figure1, 'user_cells');
if ~isempty(nonzeros(user_lighted))
    user_lighted_ind(nonzeros(user_lighted)) = true;
end

user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');


user_cells_alphas = reshape(user_cells_alphas, [], 1);
setappdata(handles.figure1, 'user_cells_alphas', user_cells_alphas);

touched_cells = getappdata(handles.figure1, 'touched_cells');
if clusters
    touched_cells(:) = false;    
    all_mod_clust = false(1, length(seq.frames(frame_num).clusters_data));
end


z = str2double(get(handles.slice_number, 'String'));
states = disable_all_controls(handles);
[y,x, button] = ginput(1);
enable_all_controls(handles, states);

while ~isempty(x) & button ~= 27 & button ~= 3;
    I1 = cell_from_pos(y, x, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end
    seq.inv_cells_map(frame_num, I1)
    user_lighted_ind(I1) = ~user_lighted_ind(I1);
    user_cells_colors(I1,:) = get(handles.user_select_c, 'BackgroundColor');
%     user_cells_alphas(I1,:) = get(handles.user_select_c, 'userdata');
    
    % DLF (2016-Dec-30) TO-DO: MODIFY ALPHAS
%     user_cells_alphas(I1,:) = 0.4;
    
    
    if clusters
        user_cells_alphas(I1,:) = 0.2;
        mod_clust = add_cell_to_clusters(I1, frame_num);
        if length(mod_clust) > max(seq.clusters_map(frame_num, :))
            seq.inv_clusters_map(frame_num, length(mod_clust)) = length(seq.clusters_map(frame_num, :)) + 1;
            seq.clusters_map(frame_num, end + 1) = length(mod_clust);
        end
        if length(seq.clusters_colors) < length(seq.clusters_map(1,:))
            seq.clusters_colors = [seq.clusters_colors ...
                length(seq.clusters_colors) + 1:length(seq.clusters_map(1,:))];
        end
        cluster_colors = get_cluster_colors(seq.clusters_colors(...
            seq.inv_clusters_map(frame_num, mod_clust)));    
        user_cells_colors(I1,:) = mean(cluster_colors, 1);
        all_mod_clust = mod_clust(1:length(all_mod_clust)) | all_mod_clust;
        if length(mod_clust) > length(all_mod_clust)
            all_mod_clust(length(mod_clust)) = mod_clust(end);
        end
        
    end

    touched_cells(I1) = 1;
    user_lighted = find(user_lighted_ind);
    seq.frames(frame_num).cells = user_lighted;
    seq.frames(frame_num).cells_colors = user_cells_colors;
    seq.frames(frame_num).cells_alphas = reshape(user_cells_alphas, [], 1);
    %setappdata(handles.figure1, 'seq', seq);
    setappdata(handles.figure1, 'first_time', 1);

    update_frame(handles, str2double(get(handles.frame_number, 'string')), z);

    states = disable_all_controls(handles);
    [y,x, button] = ginput(1);
    enable_all_controls(handles, states);

end
if clusters
    for clst_cnt = find(all_mod_clust)
%         if isempty(seq.frames(frame_num).clusters_data(clst_cnt).cells)
%             seq.frames(frame_num).clusters_data(clst_cnt).boundary = [];
%             seq.frames(frame_num).clusters_data(clst_cnt).center = [];
%         else
        if length(seq.frames(frame_num).clusters_data) == 1
            seq.frames(frame_num).clusters_data = ...
                build_cluster_data(seq.frames(frame_num).clusters_data(clst_cnt).cells, ...
                seq.frames(frame_num).cellgeom);
        else                
            seq.frames(frame_num).clusters_data(clst_cnt) = ...
                build_cluster_data(seq.frames(frame_num).clusters_data(clst_cnt).cells, ...
                seq.frames(frame_num).cellgeom);
        end
%             seq.frames(frame_num).clusters_data(clst_cnt).boundary = ...
%                 cluster_outer_nodes(seq.frames(frame_num).clusters_data(clst_cnt).cells, ...
%                 seq.frames(frame_num).cellgeom);
%             seq.frames(frame_num).clusters_data(clst_cnt).center = ...
%                 centroid(seq.frames(frame_num).cellgeom.nodes(seq.frames(frame_num).clusters_data(clst_cnt).boundary, :));
%         end
    end
    setappdata(handles.figure1, 'touched_clusters', all_mod_clust);
    update_clusters_orbit(handles, find(touched_cells), all_mod_clust)
    color_clusters(1:length(seq.frames), 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters');
else
    edges = getappdata(handles.figure1, 'user_edges');
    setappdata(handles.figure1, 'touched_cells', touched_cells);
    call_update_orbit(handles, user_lighted, user_cells_colors, ...
        user_cells_alphas, edges)
end

function update_clusters_orbit(handles, touched_cells, mod_clust)
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);
orbit = get_orbit_frames(handles);
orbit = setdiff(orbit(:)', frame_num, 'legacy');
orbit = [orbit frame_num]; %we want the current frame to be the last one updated so
%the old informatio will not be lost before updatding all the other frames.

mod_clust = reshape(mod_clust, 1, length(mod_clust));
if ~islogical(mod_clust)
    ind = false(1, length(seq.frames(frame_num).clusters_data));
    ind(mod_clust) = true;
    mod_clust = ind;
end
for j = find(mod_clust)

    min_t = max([seq.frames(orbit).t]); %the first/last frame in which new selected cells 
    min_z = max([seq.frames(orbit).z]); %intersect existing selected cells. Here we set the 
    max_t = min([seq.frames(orbit).t]); %default to none.
    max_z = min([seq.frames(orbit).z]);
    
    o_cells = double(seq.frames(frame_num).clusters_data(j).cells);    
    if seq.inv_clusters_map(frame_num, j)
        o_cells = seq.inv_cells_map(frame_num, intersect(touched_cells, o_cells, 'legacy'));
        f_on = true(size(orbit));
        for i = 1:length(orbit)
            n_cells = nonzeros(double(seq.cells_map(orbit(i), o_cells)))';
            if (isempty(seq.frames(orbit(i)).clusters_data) || ...
                         isempty(intersect(n_cells, [seq.frames(orbit(i)).clusters_data.cells], 'legacy')))
                f_on(i) = 0;
            end
        end
        f_on = f_on | reshape(seq.clusters_map(orbit, seq.inv_clusters_map(frame_num, j)) > 0, ...
                              size(f_on));
        f_on = orbit(f_on);
        f_on  = setdiff(f_on, frame_num, 'legacy');
        min_t = min([seq.frames(f_on).t min_t]);
        max_t = max([seq.frames(f_on).t max_t]);
        min_z = min([seq.frames(f_on).z min_z]);
        max_z = max([seq.frames(f_on).z max_z]);
        
    end
        
    for i = orbit
        clstr = 0;
        if seq.inv_clusters_map(frame_num, j)
            clstr = seq.clusters_map(i, seq.inv_clusters_map(frame_num, j));
        end
        n_cells = nonzeros(double(seq.cells_map(i, o_cells)))';
        n_touched = nonzeros(double(seq.cells_map(i, ...
            seq.inv_cells_map(frame_num, touched_cells))))';        

        if clstr
            cells = ...
                setdiff(seq.frames(i).clusters_data(clstr).cells, n_touched, 'legacy');
            cells = union(cells, n_cells, 'legacy');
%             seq.frames(i).clusters_data(clstr).cells = ...
%                 setdiff(seq.frames(i).clusters_data(clstr).cells, n_touched);
%             seq.frames(i).clusters_data(clstr).cells = ...
%                 union(seq.frames(i).clusters_data(clstr).cells, n_cells);
        else
            t = seq.frames(i).t;
            z = seq.frames(i).z;
            ori_t = seq.frames(frame_num).t;
            ori_z = seq.frames(frame_num).z;
            if ~isempty(n_cells) && seq.inv_clusters_map(frame_num, j) > 0 && ...
                    ((ori_t < min_t && t < min_t) || (max_t < t && max_t < ori_t) || ...
                    (ori_z < min_z && z < min_z) || (max_z < z && max_z < ori_z)) && ...
                    (isempty(seq.frames(i).clusters_data) || ...
                     isempty(intersect(n_cells, [seq.frames(i).clusters_data.cells], 'legacy')))
                cells = n_cells;
                clstr = length(seq.frames(i).clusters_data) + 1;
%                 seq.frames(i).clusters_data(end + 1).cells = n_cells;
%                 clstr = length(seq.frames(i).clusters_data);
                seq.inv_clusters_map(i, clstr) = seq.inv_clusters_map(frame_num, j);
                seq.clusters_map(i, seq.inv_clusters_map(frame_num, j)) = clstr;
            end
        end

        %outernodes and center
        if clstr %clstr value will change if a new cluster is added.
            if (length(seq.frames(i).clusters_data) < 2) && clstr == 1
                seq.frames(i).clusters_data = ...
                    build_cluster_data(cells, seq.frames(i).cellgeom);
            else                    
                seq.frames(i).clusters_data(clstr) = ...
                    build_cluster_data(cells, seq.frames(i).cellgeom);
            end
            if isempty(cells)
                seq.clusters_map(i, seq.inv_clusters_map(i,clstr)) = 0;
                seq.inv_clusters_map(i,clstr) = 0;
            end
        end
    end    
end
if length(seq.clusters_colors) < length(seq.clusters_map(1,:))
    seq.clusters_colors = [seq.clusters_colors ...
        length(seq.clusters_colors) + 1:length(seq.clusters_map(1,:))];
end


function remove_clusters(handles, mod_clust)
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);
orbit = get_orbit_frames(handles);
orbit = setdiff(orbit(:)', frame_num, 'legacy');
orbit = [orbit frame_num]; %we want the current frame to be the last one updated so
%the old informatio will not be lost before updatding all the other frames.
mod_clust = reshape(mod_clust, 1, length(mod_clust));
if ~islogical(mod_clust)
    ind = false(1, length(seq.frames(frame_num).clusters_data));
    ind(mod_clust) = true;
    mod_clust = ind;
end
empty_cluster = build_cluster_data([], seq.frames(frame_num).cellgeom);
g_cl = seq.inv_clusters_map(frame_num, mod_clust);
for i = orbit
    cl_ind = nonzeros(seq.clusters_map(i, g_cl));
    seq.clusters_map(i, g_cl) = 0;
    seq.inv_clusters_map(i, cl_ind) = 0;
    if length(seq.frames(i).clusters_data) == 1 && length(cl_ind)
        seq.frames(i).clusters_data = empty_cluster;
    elseif length(cl_ind)
        seq.frames(i).clusters_data(cl_ind) = empty_cluster;
    end
end


function ind = select_clusters_from_input(frame_num, cellgeom, handles)
global seq
ind_on = find(cellfun(@length, {seq.frames(frame_num).clusters_data.cells}));
ind_ind = false(size(ind_on));
h = nan(size(ind_on));
centers = cat(1, seq.frames(frame_num).clusters_data.center);
states = disable_all_controls(handles);
[y,x, button] = ginput(1);
enable_all_controls(handles, states);

while ~isempty(x) & button ~= 27 & button ~= 3;
    I1 = cell_from_pos(y, x, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        button = 27; %
        break
    end
    for j = 1:length(ind_on)
        III(j) = ismember(I1, seq.frames(frame_num).clusters_data(ind_on(j)).cells, 'legacy');
    end
    ind_ind(III) = ~ind_ind(III);
    if any(ishandle(h))
        delete(h(ishandle(h)))
    end
    if any(ind_ind)
        
        cells = [seq.frames(frame_num).clusters_data(ind_on(ind_ind)).cells];
        fac = seq.frames(frame_num).cellgeom.faces(nonzeros(cells), :);
        vert = [seq.frames(frame_num).cellgeom.nodes(:,2) seq.frames(frame_num).cellgeom.nodes(:,1)];
        cells_colors = zeros(length(cells), 3);
        if length(nonzeros(cells)) == 1
            arg1 = [];
            arg2 = cells_colors;
        else
            arg1 = cells_colors;
            arg2 = 'flat';
        end

        h(III) = patch('Faces', fac, 'Vertices', vert, ...
            'FaceVertexCData', arg1, 'FaceColor', arg2, ...
            'facealpha', 'flat', 'FaceVertexAlphaData', 0.5, ...
            'AlphaDataMapping', 'none', 'edgecolor', 'none');
        
%         cluster_nodes = cellgeom.nodes(seq.frames(frame_num).clusters_data(ind_on(III)).boundary,:);
%         h(III) = patch(cluster_nodes(:,2), cluster_nodes(:,1), [0 0 0],...
%         'EdgeAlpha', 1, 'EdgeColor', [0 0 0] ,...
%         'LineWidth', 3, 'FaceColor', 'None');
    end
    states = disable_all_controls(handles);
    [y,x, button] = ginput(1);
    enable_all_controls(handles, states);

end
delete(h(ishandle(h)));
if button == 27
    ind = [];
    return
else
    ind = ind_on(ind_ind);
end
% --- Executes on button press in poly_select_button.
function poly_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to poly_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%seq = getappdata(handles.figure1, 'seq');
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
cellgeom = seq.frames(frame_num).cellgeom;
if strcmp(lower(get(handles.files2cluster, 'Checked')), 'on');
    clusters = true;
else
    clusters = false;
end

if clusters
    ind = select_clusters_from_input(frame_num, cellgeom, handles);
    if length(ind)
        touched_cells = [seq.frames(frame_num).clusters_data(ind).cells];
        seq.frames(frame_num).clusters_data(ind) = deal(...
            build_cluster_data([], cellgeom));
        if get(handles.apply_to_all, 'value');
            remove_clusters(handles, ind)
        else 
            update_clusters_orbit(handles, touched_cells, ind)
        end
        color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
            'cluster_tracking_f', 'ghost_clusters');
        update_frame(handles, img_num, z_num);
    end
else %%%%%%% select cells in normal (non clusters) mode.
    user_lighted_ind = false(1, length(cellgeom.circles(:,1)));
    user_lighted = getappdata(handles.figure1, 'user_cells');
    if ~isempty(nonzeros(user_lighted))
        user_lighted_ind(nonzeros(user_lighted)) = true;
    end

    user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
    user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');
    touched_cells = getappdata(handles.figure1, 'touched_cells');

    msg = sprintf(['Click to create the selection area.\n' ...
                   'Pressing d will deselect cells in the polygon.\n' ...
                   'Hit Return when done.']);
    update_info_msg(handles, msg);
    
    hold on
    x=[]; y=[]; l=[];
    d_pressed = false;
    states = disable_all_controls(handles);
    [yin,xin, b] = ginput(1);


    while ~isempty(xin) & b ~= 27 & b ~= 3;
      l(end+1) = plot(yin,xin,'wx');
      if ~isempty(x) 
        l(end+1) = plot([y(end) yin],[x(end) xin],'w');
      end
      x(end+1)=xin;
      y(end+1)=yin;
      if b == 100
        d_pressed = true;
      end
      [yin,xin, b] = ginput(1);


    end
    enable_all_controls(handles, states);
    delete(l);
    update_info_msg(handles, [], true);
    if isempty(x)
        return
    end
    new_selection = inpolygon(cellgeom.circles(:,1), cellgeom.circles(:,2), x, y);
    touched_cells(new_selection) = 1;

    user_lighted_ind = false(1, length(cellgeom.circles(:,1)));
    if ~isempty(user_lighted)
        user_lighted_ind(nonzeros(user_lighted)) = true;
    end
    if d_pressed % 
        user_lighted_ind(new_selection) = false;
    else %otherwise, select cells
        user_lighted_ind(new_selection) = true;
        c = get(handles.user_select_c, 'BackgroundColor');
        user_cells_colors(new_selection,:) = repmat(c, [sum(new_selection) ,1]);
        user_cells_alphas(new_selection) = get(handles.user_select_c, 'userdata');
    end

    
%   DLF-TODO: incorporate alpha value into user interface
    user_cells_alphas(new_selection) = 0.4;
    
    
    user_lighted = find(user_lighted_ind);
    seq.frames(frame_num).cells = user_lighted;
    seq.frames(frame_num).cells_colors = user_cells_colors;
    seq.frames(frame_num).cells_alphas = user_cells_alphas;
    %setappdata(handles.figure1, 'seq', seq);
    setappdata(handles.figure1, 'first_time', 1);
    setappdata(handles.figure1, 'touched_cells', touched_cells);

    edges = getappdata(handles.figure1, 'user_edges');

    call_update_orbit(handles, user_lighted, user_cells_colors, ...
        user_cells_alphas, edges)
end


% --- Executes on button press in newfig_check.
function newfig_check_Callback(hObject, eventdata, handles)
% hObject    handle to newfig_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of newfig_check
z = str2double(get(handles.slice_number, 'String'));
if get(hObject,'Value')
    set(handles.scaleBar_btn,'visible','on');
    set(handles.scaleBar_btn,'value',false);
    h = figure;
    setappdata(handles.figure1, 'drawingfig', h);
    setappdata(handles.figure1, 'first_time', 1);
    setappdata(handles.figure1, 'new_win', 1);
    update_frame(handles, str2double(get(handles.frame_number, 'string')), z);
else
    set(handles.scaleBar_btn,'visible','off');
    set(handles.scaleBar_btn,'value',false);
    setappdata(handles.figure1, 'first_time', 1);
    update_frame(handles, str2double(get(handles.frame_number, 'string')), z);
end

% --- Executes on button press in track_back.
function track_back_Callback(hObject, eventdata, handles)
% hObject    handle to track_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of track_back

update_orbit_frames(hObject, eventdata, handles)


function update_orbit_frames(hObject, eventdata, handles)
global seq


img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
r = img_num; l = img_num; t = z_num; b = z_num;


if get(handles.track_for, 'value')
    r = seq.max_t;
end
if get(handles.track_back, 'value')
    l = seq.min_t;
end
if get(handles.track_up, 'value')
    t = seq.max_z;
end
if get(handles.track_down, 'value')
    b = seq.min_z;
end

if ~get(handles.t_from_lock, 'value')
    set(handles.t_from, 'string', l); 
end
if ~get(handles.t_to_lock, 'value')
    set(handles.t_to, 'string', r);
end
if ~get(handles.z_from_lock, 'value')
    set(handles.z_from, 'string', b);
end
if ~get(handles.z_to_lock, 'value')
    set(handles.z_to, 'string', t);
end

function orbit = get_orbit_frames(handles)
global seq
l = str2double(get(handles.t_from, 'string')); 
r = str2double(get(handles.t_to, 'string'));
b = str2double(get(handles.z_from, 'string'));
t = str2double(get(handles.z_to, 'string'));


orbit = nonzeros(seq.frames_num(l:r, b:t))';



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over user_select_c.
function user_select_c_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to user_select_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


c = get(hObject, 'BackgroundColor');
c = uisetcolor(c);
if c == get(hObject, 'BackgroundColor');
    return
end
set(hObject, 'BackgroundColor', c);
set(handles.user_select_c, 'userdata', 0.2);

user_select_button_Callback(handles.user_select_button, eventdata, handles)


% --- Executes on button press in pick_color.
function pick_color_Callback(hObject, eventdata, handles)
% hObject    handle to pick_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.newfig_check, 'value')
    figure(getappdata(handles.figure1, 'drawingfig'));
end

%seq = getappdata(handles.figure1, 'seq');
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
cellgeom = seq.frames(frame_num).cellgeom;

user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');

states = disable_all_controls(handles);
[y,x, button] = ginput(1);
enable_all_controls(handles, states);


while ~isempty(x) & button ~= 27 & button ~= 3;
    I1 = cell_from_pos(y, x, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end
    c = user_cells_colors(I1,:);
    a = user_cells_alphas(I1);
    set(handles.user_select_c, 'BackgroundColor', c);
    set(handles.user_select_c, 'userdata', a);
    states = disable_all_controls(handles);
    [y,x, button] = ginput(1);
    enable_all_controls(handles, states);

end



% --------------------------------------------------------------------
function load_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_cd = 'dh';
old_cd = cd;
if ~isdir(save_cd)
    mkdir(save_cd);
end
cd(save_cd);

global seq
[filename,pathname] = uigetfile('*.mat','Pick a case file to load');
cd(old_cd);
if isequal(filename,0)
    return
end
temp_var = load(fullfile(pathname,filename));
for i = 1:length(seq.frames)  
    seq.frames(i).cells = temp_var.frames_cells(i).cells ;
    seq.frames(i).cells_colors = temp_var.frames_cells(i).cells_colors ;
    seq.frames(i).cells_alphas = temp_var.frames_cells(i).cells_alphas ;
    seq.frames(i).edges = temp_var.frames_cells(i).edges ;
end
if isfield(temp_var.frames_cells(1), 'clusters_data')
    for i = 1:length(seq.frames)
        seq.frames(i).clusters_data = temp_var.frames_cells(i).clusters_data;
    end
    seq.clusters_map = temp_var.clusters_map;
    seq.inv_clusters_map = temp_var.inv_clusters_map;
    seq.clusters_colors = temp_var.clusters_colors;
end


%setappdata(handles.figure1, 'seq', seq);
setappdata(handles.figure1, 'first_time', 1);
z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);

% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
geom_changed = false;
global seq
if seq.changed
    msg = ['Changes were made to the geometry. Do you want to try and track' ...
        ' the highlighted cells in the new geometry and save the data?'];
    button = questdlg(msg);
    if strcmp(button, 'Cancel')
        return
    end
    if strcmp(button, 'Yes')
        geom_changed = true;
    end
end


dummy = save_dh(handles, geom_changed);

function not_cancelled = save_dh(handles, changed_geom)
save_cd = 'dh';
old_cd = cd;
if ~isdir(save_cd)
    mkdir(save_cd);
end
cd(save_cd);
[filename, pathname] = uiputfile('dynamic_highlighting','Save case file to');
cd(old_cd);
if isequal(filename,0)|isequal(pathname,0)
    not_cancelled = 0;
else
    if exist(fullfile(pathname,filename), 'file') == 2
        delete(fullfile(pathname,filename));
    end
    global seq
    frames_cells = [];
    for i = 1:length(seq.frames)  
        if isfield(seq.frames(i), 'sticky_changed') && seq.frames(i).sticky_changed; 
            a = seq.frames(i).cellgeom.circles(:,1:2)';
            if changed_geom
                b = seq.frames(i).cellgeom_edit.circles(:,1:2)';
            else  %
                b = a;
            end
            [cells_map inv_cell_map] = track(a,b);
            if ~isempty(seq.frames(i).cells)
                seq.frames(i).cells = nonzeros(cells_map(seq.frames(i).cells));

                cells_colors = zeros(length(seq.frames(i).cellgeom_edit.circles(:,1)), 3);
                cells_alphas = zeros(length(seq.frames(i).cellgeom_edit.circles(:,1)), 1);
                cells_colors(seq.frames(i).cells, :) = ...
                    seq.frames(i).cells_colors(inv_cell_map(seq.frames(i).cells), :);
                cells_alphas(seq.frames(i).cells) = ...
                    seq.frames(i).cells_alphas(inv_cell_map(seq.frames(i).cells));
                seq.frames(i).cells_colors = cells_colors;
                seq.frames(i).cells_alphas = cells_alphas;
            end            
            if ~isempty(seq.frames(i).edges)
                old_frame = edges_2_cells(seq.frames(i).cellgeom);
                new_frame = edges_2_cells(seq.frames(i).cellgeom_edit);
                old_edges_cells = old_frame.edge2cells(nonzeros(...
                old_frame.edges_ind(seq.frames(i).edges)), :);
                new_edges_cells = sort(cells_map(old_edges_cells), 2, 'descend');
                new_edges_cells = new_edges_cells(new_edges_cells(:,2) ~= 0, :);
                seq.frames(i).edges = new_frame.cells2edge(...
                    sub2ind(size(new_frame.cells2edge), new_edges_cells(:,1), new_edges_cells(:,2)));
            end
        end
            
            
            
        frames_cells(i).cells = seq.frames(i).cells ;
        frames_cells(i).cells_colors = seq.frames(i).cells_colors ;
        frames_cells(i).cells_alphas = seq.frames(i).cells_alphas ;
        frames_cells(i).edges = seq.frames(i).edges ;
        if isfield(seq.frames(1), 'clusters_data')
            if seq.frames(i).sticky_changed
                for clst_cnt = 1:length(seq.frames(i).clusters_data)
                    if ~isempty(seq.frames(i).clusters_data(clst_cnt).cells) 
                            frames_cells(i).clusters_data(clst_cnt).cells = ...
                            nonzeros(cells_map(seq.frames(i).clusters_data(clst_cnt).cells))';
                        if clst_cnt == 1
                            frames_cells(i).clusters_data = ...
                                build_cluster_data(frames_cells(i).clusters_data(clst_cnt).cells, ...
                                seq.frames(i).cellgeom_edit);
                        else
                            frames_cells(i).clusters_data(clst_cnt) = ...
                                build_cluster_data(frames_cells(i).clusters_data(clst_cnt).cells, ...
                                seq.frames(i).cellgeom_edit);
                        end
%                         frames_cells(i).clusters_data(clst_cnt).boundary = ...
%                             cluster_outer_nodes(frames_cells(i).clusters_data(clst_cnt).cells, ...
%                             seq.frames(i).cellgeom_edit);
%                         frames_cells(i).clusters_data(clst_cnt).center = ...
%                             centroid(seq.frames(i).cellgeom_edit.nodes(...
%                             frames_cells(i).clusters_data(clst_cnt).boundary, :));
                    end
                end
                seq.frames(i).clusters_data = frames_cells(i).clusters_data; 
                %seq.frames needs to be updated because we use its clusters
                %data in generate_data.m when we close the tracking window.
            else
                frames_cells(i).clusters_data = seq.frames(i).clusters_data;
            end
        end
    end

    cd(pathname);
    if isfield(seq.frames(1), 'clusters_data')
        clusters_map = seq.clusters_map;
        inv_clusters_map = seq.inv_clusters_map;
        clusters_colors = seq.clusters_colors;
        save(fullfile(pathname,filename), 'frames_cells', 'clusters_map', ...
            'inv_clusters_map', 'clusters_colors', '-v6');
    else
        save(fullfile(pathname,filename), 'frames_cells', '-v6');
    end
    
    not_cancelled = 1;
    cd(old_cd);
end



function f = edges_2_cells(cellgeom)
    map = sortrows(cellgeom.edgecellmap, 2);
    [a b c] = unique(map(:,2), 'legacy');
    ind = find((b - [0 b(1:end-1)']') == 2);
    
    numcells = length(cellgeom.circles(:,1));
    s_map = sort([map(b(ind), 1) map(b(ind) - 1, 1)], 2, 'descend');    
    
    if sum(ind ~= map(b(ind), 2))
        disp('ind = map(b(ind), 2) was needed???');
        ind = map(b(ind), 2);
    end
    inv_ind = zeros(1,length(cellgeom.edges(:,1)));
    inv_ind(ind) = 1:length(ind);
    f.edge2cells = int16(s_map);
    f.cells2edge = zeros(numcells, 'int16');
    f.cells2edge(sub2ind(size(f.cells2edge), s_map(:,1), s_map(:,2))) = ind;
    %f.cells2edge = sparse(s_map(:,1), s_map(:,2), ind, numcells, numcells);
    f.ind = ind;
    f.edges_ind = inv_ind;
    
    
% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmp(lower(get(hObject, 'Enable')), 'on')
    return
end
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.slice_number, 'String'));
%seq = getappdata(handles.figure1, 'seq');
global seq
readonly = strcmp(lower(get(handles.readonly_menu, 'Checked')), 'on');

frame_num = seq.frames_num(t, z);
temp_cellgeom = seq.frames(frame_num).cellgeom_edit;
seq.frames(frame_num).cellgeom_edit = getappdata(handles.figure1, 'old_cellgeom');
%setappdata(handles.figure1, 'seq', seq);
setappdata(handles.figure1, 'old_cellgeom', temp_cellgeom);
cellgeom = seq.frames(frame_num).cellgeom_edit;

if isappdata(handles.figure1, 'old_selected_edges_for_undo')
    old_selected_edges_for_undo = ...
        getappdata(handles.figure1, 'old_selected_edges_for_undo');
    setappdata(handles.figure1, 'old_selected_edges_for_undo', seq.frames(frame_num).edges);
    seq.frames(frame_num).edges = old_selected_edges_for_undo;
end


if ~readonly
    filename = getappdata(handles.figure1, 'filename');
    save(filename, 'cellgeom', '-v6', '-append');
end

setappdata(handles.figure1, 'first_time', 1);
update_frame(handles, t, z);

function save_undo_t(handles)
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.slice_number, 'String'));
global seq
%seq = getappdata(handles.figure1, 'seq');
frame_num = seq.frames_num(t, z);
old_cellgeom = seq.frames(frame_num).cellgeom_edit;
setappdata(handles.figure1, 'old_cellgeom', old_cellgeom);

if ~isempty(seq.frames(frame_num).edges)
    old_selected_edges_for_undo = seq.frames(frame_num).edges;
    setappdata(handles.figure1, 'old_selected_edges_for_undo', old_selected_edges_for_undo);
end


set(handles.undo, 'Enable', 'On');
set(handles.undo_menu, 'Enable', 'On');

function pos = center_of_edges(geom, edges)
if nargin < 2 || isempty(edges)
    edges = true(1, length(geom.edges(:, 1)));
end
if ~islogical(edges)
    pos = zeros(length(edges), 2);
else
    pos = zeros(sum(edges), 2);
end
pos = (geom.nodes(geom.edges(edges, 1), :) + (geom.nodes(geom.edges(edges, 2), :))) / 2;

function edit_t(handles, cmd, loop)
if nargin < 3 || isempty(loop)
    loop = 0;
end
global seq
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(t, z);

%find positions of highlighted edges
if ~isempty(seq.frames(frame_num).edges)
    edges_old_positions = center_of_edges(seq.frames(frame_num).cellgeom_edit, ...
        seq.frames(frame_num).edges);
    old_selected_edges_for_undo = seq.frames(frame_num).edges;
   %uncommented July 29, 2009. Not clear why it was commented.
   setappdata(handles.figure1, 'old_selected_edges_for_undo', old_selected_edges_for_undo);
end

save_undo_t(handles)
while 1
    drawingfig = handles.figure1;
    if get(handles.newfig_check, 'value')
        drawingfig = getappdata(handles.figure1, 'drawingfig');
    end
    readonly = strcmpi(get(handles.readonly_menu, 'Checked'), 'on');
    cellgeom = seq.frames(frame_num).cellgeom_edit;
    states = disable_all_controls(handles);
    if strcmp(cmd,'classifytrack')
        class_stage_bool = isappdata(handles.figure1,'track_classification_stage');
        if class_stage_bool
            classification_stage = getappdata(handles.figure1,'track_classification_stage');
        else
            classification_stage = 0;
        end
        
        class_type_bool = isappdata(handles.figure1,'track_classification_type');
        if class_type_bool
            classification_type = getappdata(handles.figure1,'track_classification_type');
        else
            classification_type = [];
        end
        
        %%%The same function is called for multiple steps in the process
        [class_seq, class_type, success, class_stage, classification_complete_bool] =...
        classifytrack(seq, drawingfig, handles,...
        states, classification_stage, classification_type);

        if success
            if class_stage_bool||class_type_bool
                if classification_complete_bool
                    seq = class_seq;
                    rmappdata(handles.figure1,'track_classification_stage');
                    rmappdata(handles.figure1,'track_classification_type');
                end
            else
                setappdata(handles.figure1,'track_classification_stage',class_stage);
                setappdata(handles.figure1,'track_classification_type',class_type);
            end
        else
            if isappdata(handles.figure1,'track_classification_stage')
                rmappdata(handles.figure1,'track_classification_stage');
            end
            if isappdata(handles.figure1,'track_classification_type')
                rmappdata(handles.figure1,'track_classification_type');
            end
        end
        enable_all_controls(handles, states);
        update_frame(handles, t, z);
        
        %%% This is to make the interface immediately active again.
        %%% Running the listdlg causes some issue requiring this workaround
        %%% of simulating a mouse click on the main axis 'axis1'
        if class_stage==1
            figure(drawingfig);
%             pos = getpixelposition(drawingfig);
            axes(handles.axes1);
            mpos = get(0,'PointerLocation');
            import java.awt.Robot;
            import java.awt.event.*;
            mouse = Robot;
%           mouse.mouseMove(pos(1)+pos(3)/2, pos(2)+pos(4)/2);
            mouse.mouseMove(mpos(1),mpos(2));
            mouse.mousePress(InputEvent.BUTTON2_MASK);    %left click press
            mouse.mouseRelease(InputEvent.BUTTON2_MASK);   %left click release
        end
        return
    end
    
    [cellgeom, success] = feval(cmd, cellgeom, drawingfig, 1);
    enable_all_controls(handles, states);
    if ~success
        return
    end
    seq.frames(frame_num).saved = false;
    seq.frames(frame_num).changed = 1;
    seq.frames(frame_num).sticky_changed = 1;
    seq.changed = 1;
    seq.frames(frame_num).cellgeom_edit = cellgeom;
    if ~readonly
        filename = getappdata(handles.figure1, 'filename');
        save(filename, 'cellgeom', '-v6', '-append');
        seq.frames(frame_num).saved = true;
    end
    setappdata(handles.figure1, 'first_time', 1);
    setappdata(handles.figure1, 'update_celldata', 1);
    if ~loop %loop is on only for move nodes, so the user will be able move 
        %nodes until he quits the operations. movenodes can not change the
        %topolgy and therefore the frame can be updated even if there are
        %highlighted edges. Other operations might change the topolgy and
        %render highlighted edges indices to be out of bound in the new
        %topology. This will cause an error in update_frame.
        break
    else
        update_frame(handles, t, z);
    end
end

%Try to match highilghted edges to edges in the new geom
if ~isempty(seq.frames(frame_num).edges)
    edges_new_positions = center_of_edges(cellgeom);
    user_edges = track_positions_forward(edges_old_positions', edges_new_positions');
    user_edges_ind = false(1, length(cellgeom.edges(:,1)));
    if ~isempty(nonzeros(user_edges))
        user_edges_ind(nonzeros(user_edges)) = true;
    end
    seq.frames(frame_num).edges = find(user_edges_ind);
end
update_frame(handles, t, z);


% --- Executes on button press in movenodes.
function movenodes_Callback(hObject, eventdata, handles)
% hObject    handle to movenodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'movenodes', 1);


% --- Executes on button press in collapse.
function collapse_Callback(hObject, eventdata, handles)
% hObject    handle to collapse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'call_collapse_edge');


% --- Executes on button press in merge.
function merge_Callback(hObject, eventdata, handles)
% hObject    handle to merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'merge_cells');



% --- Executes on button press in addedge.
function addedge_Callback(hObject, eventdata, handles)
% hObject    handle to addedge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'addedge');



% --- Executes on button press in associate.
function associate_Callback(hObject, eventdata, handles)
% hObject    handle to associate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'associate_node');



% --- Executes on button press in track_for.
function track_for_Callback(hObject, eventdata, handles)
% hObject    handle to track_for (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of track_for

update_orbit_frames(hObject, eventdata, handles)

function update_direction(handles)
global seq
%seq = getappdata(handles.figure1, 'seq');
user_lighted = getappdata(handles.figure1, 'user_cells');
user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');
edges = getappdata(handles.figure1, 'user_edges');


call_update_orbit(handles, user_lighted, user_cells_colors, ...
    user_cells_alphas, edges)



% --- Executes on key press over undo with no controls selected.
function undo_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_edges.
function select_edges_Callback(hObject, eventdata, handles)
% hObject    handle to select_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.newfig_check, 'value')
    figure(getappdata(handles.figure1, 'drawingfig'));
end

t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
global seq
%seq = getappdata(handles.figure1, 'seq');
img_num = seq.frames_num(t, z);  
cellgeom = seq.frames(img_num).cellgeom;
user_edges_ind = false(1, length(cellgeom.edges(:,1)));
user_edges = getappdata(handles.figure1, 'user_edges');
if ~isempty(nonzeros(user_edges))
    user_edges_ind(nonzeros(user_edges)) = true;
end

touched_edges = getappdata(handles.figure1, 'touched_edges');


states = disable_all_controls(handles);
[y,x, button] = ginput(1);
enable_all_controls(handles, states);


while ~isempty(x) & button ~= 27 & button ~= 3;
    I1 = nearest_edge(cellgeom, x, y)
    touched_edges(I1) = 1;
    user_edges_ind(I1) = ~user_edges_ind(I1);
    user_edges = find(user_edges_ind);
    seq.frames(img_num).edges = user_edges;
    %setappdata(handles.figure1, 'seq', seq);
    setappdata(handles.figure1, 'first_time', 1);
    update_frame(handles, t, z);

    states = disable_all_controls(handles);
    [y,x, button] = ginput(1);
    enable_all_controls(handles, states);

end



user_cells = getappdata(handles.figure1, 'user_cells');
user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');

setappdata(handles.figure1, 'touched_edges', touched_edges);

call_update_orbit(handles, user_cells, user_cells_colors, ...
    user_cells_alphas, user_edges)

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function keypress(hObject, eventdata, handles)
if isappdata(handles.figure1, 'disabled_mode') && ...
        getappdata(handles.figure1, 'disabled_mode')
    return
end

global seq
k = lower(get(handles.figure1, 'CurrentKey'));
z = str2double(get(handles.slice_number, 'String'));
i = str2double(get(handles.frame_number, 'String'));

switch k
    case {'m', 'e'}
        tracking('movenodes_Callback',handles.movenodes,eventdata,handles); 
    case 't'
        tracking('associate_Callback',handles.associate,eventdata,handles); 
    case 'u'
        tracking('undo_Callback',handles.undo,eventdata,handles); 
    case 'a'
        tracking('addedge_Callback',handles.addedge,eventdata,handles); 
    case 'x'
        tracking('node2edge_Callback',handles.node2edge,eventdata,handles);         
    case 'c'
        tracking('collapse_Callback',handles.collapse,eventdata,handles);
    case 'd'
        tracking('merge_Callback',handles.merge,eventdata,handles); 
    case {'2', 'l'}
        tracking('hole2cell_Callback',handles.hole2cell,eventdata,handles); 
    case 'q'
        tracking('remove_cell_Callback',handles.remove_cell,eventdata,handles);
	case 's'
        tracking('classifytrack_Callback',handles.classifytrack,eventdata,handles); 
    case 'n'
        tracking('delineate_cell_btn_Callback',handles.delineate_cell_btn,eventdata,handles); 
    case 'h'
        set(handles.hide, 'Value', ~get(handles.hide,'Value'));
        tracking('hide_Callback',handles.hide,eventdata,handles);
    case 'g'
        set(handles.draw_geometry, 'Value', ~get(handles.draw_geometry,'Value'));
        tracking('draw_geometry_Callback',handles.draw_geometry,eventdata,handles);
    case 'z'
        set(handles.zoom_btn, 'Value', ~get(handles.zoom_btn,'Value'));
        tracking('zoom_btn_Callback',handles.zoom_btn,eventdata,handles);
    case 'p'
        set(handles.pan_btn, 'Value', ~get(handles.pan_btn,'Value'));
        tracking('pan_btn_Callback',handles.pan_btn,eventdata,handles);
    case 'backquote'
        set(handles.thick_edges_check, 'Value', ~get(handles.thick_edges_check,'Value'));
        tracking('thick_edges_check_Callback',handles.thick_edges_check,eventdata,handles);
end
    
if isprop(hObject, 'style') && strcmp('slider', get(hObject, 'style'))
    return
end
switch k
    case 'home'
        update_frame(handles, get(handles.frame_slider, 'min'), z);
    case 'end'
        update_frame(handles, get(handles.frame_slider, 'max'), z);
    case 'pagedown'
%        update_frame(handles, i, -get(handles.slice_slider, 'min'));
        update_frame(handles, min(get(handles.frame_slider, 'max'), i + 10), z);
    case 'pageup'
%        update_frame(handles, i, -get(handles.slice_slider, 'max'));
        update_frame(handles, max(get(handles.frame_slider, 'min'), i - 10), z);
    case 'downarrow'
        if z == -get(handles.slice_slider, 'min')
            z = -get(handles.slice_slider, 'max');
        else 
            [dummy ind] = min(abs(seq.valid_z_vals - z));
            z = seq.valid_z_vals(ind + 1); %z_jump
            %z = z + 1; %z_jump
        end
        update_frame(handles, i, z);        
    case 'uparrow'
        if z == -get(handles.slice_slider, 'max')
            z = -get(handles.slice_slider, 'min');
        else 
            [dummy ind] = min(abs(seq.valid_z_vals - z));
            z = seq.valid_z_vals(ind - 1);%z_jump
            %z = z - 1; %z_jump
        end
        update_frame(handles, i, z);        
    case {'leftarrow', 'w'}
        if i < get(handles.frame_slider, 'min') + seq.t_jump
            i = get(handles.frame_slider, 'max');
        else
            i = i - seq.t_jump;
        end
        update_frame(handles, i, z)
    case {'rightarrow', 'r'}
        if i > get(handles.frame_slider, 'max') - seq.t_jump
            i = get(handles.frame_slider, 'min');
        else 
            i = i + seq.t_jump;
        end
        update_frame(handles, i, z);    
%     case {'1'}
%         draw_clusters(handles, 1);
%     case {'2'}
%         draw_clusters(handles, 0);
end



% --------------------------------------------------------------------
function undo_menu_Callback(hObject, eventdata, handles)
% hObject    handle to undo_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking('undo_Callback',handles.undo,eventdata,handles); 

% --------------------------------------------------------------------
function movenodes_menu_Callback(hObject, eventdata, handles)
% hObject    handle to movenodes_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracking('movenodes_Callback',handles.movenodes,eventdata,handles); 

% --------------------------------------------------------------------
function collapse_menu_Callback(hObject, eventdata, handles)
% hObject    handle to collapse_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracking('collapse_Callback',handles.collapse,eventdata,handles); 

% --------------------------------------------------------------------
function merge_menu_Callback(hObject, eventdata, handles)
% hObject    handle to merge_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracking('merge_cells_Callback',handles.merge_cells,eventdata,handles);

% --------------------------------------------------------------------
function addedge_menu_Callback(hObject, eventdata, handles)
% hObject    handle to addedge_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracking('addedge_Callback',handles.addedge,eventdata,handles);

% --------------------------------------------------------------------
function associate_menu_Callback(hObject, eventdata, handles)
% hObject    handle to associate_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracking('associate_Callback',handles.associate,eventdata,handles); 

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function random_cells_Callback(hObject, eventdata, handles)
% hObject    handle to random_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
color_all_cells(handles, 'random')

% --------------------------------------------------------------------
function grad_2d_Callback(hObject, eventdata, handles)
% hObject    handle to grad_2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

color_all_cells(handles, 'grad_2d')


% --------------------------------------------------------------------
function hor_cells_Callback(hObject, eventdata, handles)
% hObject    handle to hor_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

color_all_cells(handles, 'hor')



% --------------------------------------------------------------------
function vert_cells_Callback(hObject, eventdata, handles)
% hObject    handle to vert_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

color_all_cells(handles, 'vert')

function color_all_cells(handles, action)
t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
%seq = getappdata(handles.figure1, 'seq');
global seq
img_num = seq.frames_num(t, z);  
cellgeom = seq.frames(img_num).cellgeom;
user_cells_colors = zeros(length(cellgeom.circles(:,1)), 3);
user_cells_alphas = ones(length(cellgeom.circles(:,1)), 1);
if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
    cells = false(1,length(cellgeom.circles(:,1)));
    cells(seq.frames(img_num).cells) = true;
else
    cells = true(1,length(cellgeom.circles(:,1)));
end
    
if isfield(cellgeom, 'border_cells')
    cells(cellgeom.border_cells) = 0;
end
if isfield(cellgeom, 'valid')
    cells(~cellgeom.valid) = 0;
end
cells = find(cells);
y = cellgeom.circles(cells, 1);
x = cellgeom.circles(cells, 2);
switch action
    case 'random'
        user_cells_colors(cells,:) = rand(length(cells), 3);
    case 'grad_2d'
        x = (x - min(x))/ (max(x) - min(x));
        y = (y - min(y))/ (max(y) - min(y));
        user_cells_colors(cells,:) = [x zeros(length(x),1) y];
    case 'hor'
        total_area = (max(y) - min(y))*(max(x) - min(x));
        cell_length = sqrt(total_area / length(cells));
        num_of_rows = ceil((max(y) - min(y)) / cell_length);
    case 'vert'
        x = cellgeom.circles(cells, 1); %x is y and vice versa
        y = cellgeom.circles(cells, 2);
        total_area = (max(y) - min(y))*(max(x) - min(x));
        cell_length = 0.9*sqrt(total_area / length(cells));
        num_of_rows = ceil((max(y) - min(y)) / cell_length);
end
switch action
    case {'vert', 'hor'}
        hsv_colormap = hsv(64);
        colors = hsv_colormap(mod((1:num_of_rows)*19, length(hsv_colormap)) + 1 ,:);
        y = (y - min(y))/ (max(y) - min(y));
        y = 1 + floor((num_of_rows-1)*y);
        user_cells_colors(cells,:) = [colors(y,1) colors(y,2) colors(y,3)];
end

user_cells_alphas(cells,:) = get(handles.user_select_c, 'userdata');
seq.frames(img_num).cells = cells;
seq.frames(img_num).cells_colors = user_cells_colors;


user_cells_alphas(cells,:) = 0.4;

    

seq.frames(img_num).cells_alphas = user_cells_alphas;
edges = getappdata(handles.figure1, 'user_edges');

touched_cells = true(length(cellgeom.circles(:,1)), 1);
setappdata(handles.figure1, 'touched_cells', touched_cells);

call_update_orbit(handles, cells, user_cells_colors, ...
    user_cells_alphas, edges)

% DLF HARDCODE REMOVE LATER -5-5-2014-
if ~isempty(dir('poly_embryo*'))
    load('poly_embryo')
    globcells = seq.inv_cells_map(img_num,cells);
    for i = 1:length(seq.frames)
        currcells = nonzeros(seq.cells_map(i,globcells));
        cellgeom = seq.frames(i).cellgeom;
        new_selection = inpolygon(cellgeom.circles(currcells,1), cellgeom.circles(currcells,2), poly_seq.x, poly_seq.y);
        seq.frames(i).cells = currcells(new_selection);
    end
end

update_frame(handles)

% --------------------------------------------------------------------
function shift_axes_with_cells_Callback(hObject, eventdata, handles)
% hObject    handle to shift_axes_with_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
%     DLF DEBUG STOP SHIFT for browse_data 13-Nov-2014
% return
% DEBUG REMOVED
    
    set(handles.zoom_and_track_cells, 'Checked', 'off')
    set(hObject, 'Checked', 'on')
    global seq
    ax_x = get(handles.axes1, 'xlim');
    ax_y = get(handles.axes1, 'ylim');
    for i = 1:length(seq.frames)
        x_center(i) = mean(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 2));
        y_center(i) = mean(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 1));
    end
    x_center = fill_nans_linear(x_center);
    y_center = fill_nans_linear(y_center);
    t = str2double(get(handles.frame_number, 'String'));
    z = str2double(get(handles.slice_number, 'String'));
    frame_num = seq.frames_num(t, z);
    x_center = smoothen(x_center, 5) - x_center(frame_num);
    y_center = smoothen(y_center, 5) - y_center(frame_num);
    for i = 1:length(seq.frames)
        axes_x_lim(i, :) = ax_x + x_center(i);
        axes_y_lim(i, :) = ax_y + y_center(i);
    end
    setappdata(handles.figure1, 'axes_x_lim', axes_x_lim);
    setappdata(handles.figure1, 'axes_y_lim', axes_y_lim);
end



% --------------------------------------------------------------------
function zoom_and_track_cells_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_and_track_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
    
    start_x_lim = getappdata(handles.figure1,'start_x_lim');
    start_y_lim = getappdata(handles.figure1,'start_y_lim');
    setappdata(handles.figure1, 'axes_x_lim', start_x_lim);
    setappdata(handles.figure1, 'axes_y_lim', start_y_lim);
    set(handles.axes1,'xlim',start_x_lim);
    set(handles.axes1,'ylim',start_y_lim);
else
    set(handles.shift_axes_with_cells, 'Checked', 'off')
    set(handles.zoom_track_const, 'Checked', 'off')
    set(hObject, 'Checked', 'on')
    global seq
    for i = 1:length(seq.frames)
        if isempty(seq.frames(i).cells)
            x_max(i) = nan; x_min(i) = nan; y_max(i) = nan; y_min(i) = nan;
        else
            x_max(i) = max(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 2));
            x_min(i) = min(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 2));
            y_max(i) = max(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 1));
            y_min(i) = min(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 1));
        end
    end
    x_max = fill_nans_linear(x_max);
    x_min = fill_nans_linear(x_min);
    y_max = fill_nans_linear(y_max);
    y_min = fill_nans_linear(y_min);

    x_max = smoothen(x_max');
    y_max = smoothen(y_max');
    x_min = smoothen(x_min');
    y_min = smoothen(y_min');

    pad = 50;
    axes_x_lim = [x_min-pad x_max+pad];
    axes_y_lim = [y_min-pad y_max+pad];

    setappdata(handles.figure1, 'axes_x_lim', axes_x_lim);
    setappdata(handles.figure1, 'axes_y_lim', axes_y_lim);
end


% --------------------------------------------------------------------
function cells2edges_menu_Callback(hObject, eventdata, handles)
% hObject    handle to cells2edges_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
global seq
edges2 = [];

if strcmp(get(handles.static_edges, 'Checked'), 'on')
    orbit = get_orbit_frames(handles);
    for img_num = orbit
        edgecellmap = seq.frames(img_num).cellgeom.edgecellmap;
        cells = nonzeros(seq.frames(img_num).cells);
        edges = unique(edgecellmap(ismember(edgecellmap(:,1), cells, 'legacy'), 2), 'legacy');
        old_edges = seq.frames(img_num).edges;
        if isfield(seq.frames(img_num), 'edges2')
            old_edges2 = seq.frames(img_num).edges2;
        else
            old_edges2 = [];
        end
        if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
            edges2 = intersect(edges, old_edges2, 'legacy');
            edges = intersect(edges, old_edges, 'legacy');            
        end
        seq.frames(img_num).edges = edges;
        seq.frames(img_num).edges2 = edges2;
    end        
    setappdata(handles.figure1, 'touched_edges', []);
    setappdata(handles.figure1, 'first_time', 1);
    update_frame(handles);
else

        
    img_num = seq.frames_num(t, z);  
    edgecellmap = seq.frames(img_num).cellgeom.edgecellmap;
    cells = nonzeros(getappdata(handles.figure1, 'user_cells'));
    edges = unique(edgecellmap(ismember(edgecellmap(:,1), cells, 'legacy'), 2), 'legacy');
    old_edges = getappdata(handles.figure1, 'user_edges');
    if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
        edges = intersect(edges, old_edges, 'legacy');
    end
    seq.frames(img_num).edges = edges;

    touched_edges = getappdata(handles.figure1, 'touched_edges');
    touched_edges(edges) = 1;

    setappdata(handles.figure1, 'first_time', 1);
    user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
    user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');

    setappdata(handles.figure1, 'touched_edges', touched_edges);
    call_update_orbit(handles, cells, user_cells_colors, ...
        user_cells_alphas, edges)
end

% --------------------------------------------------------------------
function hor_edges_Callback(hObject, eventdata, handles)
% hObject    handle to hor_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
select_by_angle(handles, 0, 15)

% --------------------------------------------------------------------
function vert_edges_Callback(hObject, eventdata, handles)
% hObject    handle to vert_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
select_by_angle(handles, 75, 105)


% --------------------------------------------------------------------
function angles_Callback(hObject, eventdata, handles)
% hObject    handle to angles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = show_angles;
setappdata(h, 'calling_window', handles.figure1);
waitfor(h);
angles_range = sort(getappdata(handles.figure1, 'angles'));
select_by_angle(handles, angles_range(1), angles_range(2))



function select_by_angle(handles, angle1, angle2)
t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
global seq
%seq = getappdata(handles.figure1, 'seq');
img_num = seq.frames_num(t, z);  
cellgeom = seq.frames(img_num).cellgeom;

cells = true(1,length(cellgeom.circles(:,1)));
if isfield(cellgeom, 'border')
    cells(cellgeom.border_cells) = 0;
end
if isfield(cellgeom, 'valid')
    cells(~cellgeom.valid) = 0;
end
cells = find(cells);
nodecellmap_cells = ismember(cellgeom.nodecellmap(:,1), cells, 'legacy');
edges = ismember(cellgeom.edges(:,1), cellgeom.nodecellmap(nodecellmap_cells,2), 'legacy') ...
    & ismember(cellgeom.edges(:,2), cellgeom.nodecellmap(nodecellmap_cells,2), 'legacy');



x1 = cellgeom.nodes(cellgeom.edges(edges,1),2);
x2 = cellgeom.nodes(cellgeom.edges(edges,2),2);
y1 = cellgeom.nodes(cellgeom.edges(edges,1),1);
y2 = cellgeom.nodes(cellgeom.edges(edges,2),1);
angles = mod((atan2((y2-y1) , (x2 - x1))), pi);
angles = 180 * angles / pi;


ee = (angles <= angle2 & angles >= angle1) | ...
    ((180 - angles) <= angle2 & (180 - angles) >= angle1);

user_edges_ind = false(1, length(cellgeom.edges(:,1)));
old_user_edges_ind = false(1, length(cellgeom.edges(:,1)));
user_edges = getappdata(handles.figure1, 'user_edges');


if ~isempty(nonzeros(user_edges))
    old_user_edges_ind(nonzeros(user_edges)) = true;
end



edges = find(edges);
if ~isempty(nonzeros(ee))
    user_edges_ind(edges(ee)) = true;
end
if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
    user_edges_ind = user_edges_ind & old_user_edges_ind;
else
    user_edges_ind = user_edges_ind | old_user_edges_ind;
end

user_edges = find(user_edges_ind);
seq.frames(img_num).edges = user_edges;

setappdata(handles.figure1, 'first_time', 1);

user_cells = getappdata(handles.figure1, 'user_cells');
user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');

touched_edges = getappdata(handles.figure1, 'touched_edges');
touched_edges(xor(user_edges_ind, old_user_edges_ind)) = 1;
setappdata(handles.figure1, 'touched_edges', touched_edges);
call_update_orbit(handles, user_cells, user_cells_colors, ...
    user_cells_alphas, user_edges)


% --------------------------------------------------------------------
function anal_edges_Callback(hObject, eventdata, handles)
% hObject    handle to anal_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.track_for, 'value', 1);
set(handles.track_back, 'value', 1);
%set(handles.track_up, 'value', 1);
%set(handles.track_down, 'value', 1);
set(handles.apply_to_all, 'value', 1);
%update_direction(handles)

global seq
%seq = getappdata(handles.figure1, 'seq');
t_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
edges = getappdata(handles.figure1, 'user_edges');



len = -ones(length(seq.frames), length(edges));
angles = len;
x = len;
y = len;
len_vel = len;
ang_vel = len;
for i = 1:length(seq.frames)
    e_ind = find(seq.inv_edges_map(i,:));
    len(i, seq.inv_edges_map(i,e_ind)) = seq.frames(i).cellgeom.edges_length(e_ind);
    x1 = seq.frames(i).cellgeom.nodes(seq.frames(i).cellgeom.edges(e_ind,1),2);
    x2 = seq.frames(i).cellgeom.nodes(seq.frames(i).cellgeom.edges(e_ind,2),2);
    y1 = seq.frames(i).cellgeom.nodes(seq.frames(i).cellgeom.edges(e_ind,1),1);
    y2 = seq.frames(i).cellgeom.nodes(seq.frames(i).cellgeom.edges(e_ind,2),1);
    angles(i, seq.inv_edges_map(i,e_ind)) = 180 * mod((atan2((y2-y1) , (x2 - x1))), pi) / pi;
    x(i, seq.inv_edges_map(i,e_ind)) = abs(x1 - x2);
    y(i, seq.inv_edges_map(i,e_ind)) = abs(y1 - y2);
end    
% for i = 2:length(angles(:,1))
%     ind = find(angles(i,:) == -1);
%     angles(i, ind) = angles(i-1, ind);
%     len(i, ind) = len(i - 1, ind);
%     x(i, ind) = x(i - 1, ind);
%     y(i, ind) = y(i - 1, ind);
% end
w = 2;

edges_data.len = len;
edges_data.ang = angles;
smooth_len = smoothen(len, w);
edges_data.len_vel = smooth_len(1:end,:) - [repmat(smooth_len(1,:), 2*w +1, 1) ; smooth_len(1:end - 2*w - 1,:)];
%edges_data.len_vel = (len(1:end, :) - [len(1,:) ; len(1:end - 1, :)]);
%edges_data.ang_vel = (angles(1:end, :) - [angles(1, :) ; angles(1:end - 1, :)]);
% edges_data.len_vel = smoothen(len(1:end, :) - [len(1,:) ; len(1:end - 1, :)], 2);
% edges_data.ang_vel = smoothen(angles(1:end, :) - [angles(1, :) ; angles(1:end - 1, :)], 2);
setappdata(getappdata(handles.figure1, 'calling_window'), 'edges_data', edges_data);
img_num = seq.frames_num(t_num, z_num);
see_data_call(handles.figure1, [], edges_data, t_num, z_num);

return 
global ori
t = 2;
ori.len = smoothen(len ,t);
ori.angles = smoothen(angles, t);
ori.x = smoothen(x, t);
ori.y = smoothen(y, t);
ori.vel = ori.len(2*t + 2:end, :) - ori.len(1:end -(2*t) - 1,:);
ori.vel_x = ori.x(2*t + 2:end, :) - ori.x(1:end -(2*t) - 1,:);
ori.vel_y = ori.y(2*t + 2:end, :) - ori.y(1:end -(2*t) - 1,:);





% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function call_update_orbit(handles, user_lighted, user_cells_colors, user_cells_alphas, edges)
global seq
t_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
img_num = seq.frames_num(t_num, z_num);
% 

% return

% directions = 0;
% directions = bitset(directions, 1, get(handles.track_for, 'value'));
% directions = bitset(directions, 2, get(handles.track_back, 'value'));
% directions = bitset(directions, 3, get(handles.track_up, 'value'));
% directions = bitset(directions, 4, get(handles.track_down, 'value'));

orbit = get_orbit_frames(handles);

% if get(handles.track_for, 'value');
%     seq = update_orbit(seq, user_lighted, user_cells_colors, ...
%         user_cells_alphas, t_num, z_num, 0, edges);
% end
% if get(handles.track_back, 'value');
%     seq = update_orbit(seq, user_lighted, user_cells_colors, ...
%         user_cells_alphas, t_num, z_num, 1, edges);
% end

%seq.frames(img_num).edges_by_cells = ...
%    seq.frames(img_num).edge2cells(nonzeros(seq.frames(img_num).edges_ind(nonzeros(edges))), :);
seq.frames(img_num).edges = edges;
%seq.frames(img_num).on_edges = false(length(seq.frames(img_num).edges_ind));
%seq.frames(img_num).on_edges(nonzeros(edges)) = true;


seq.frames(img_num).cells = user_lighted;
if ~isempty(user_lighted)
    if isempty(user_cells_colors) || ...
            length(user_cells_colors(:, 1)) < max(user_lighted)
        user_cells_colors((end + 1):max(user_lighted), 3) = 1;
    end
    if length(user_cells_alphas) < max(user_lighted)
        user_cells_alphas((end + 1):max(user_lighted), 1) = 0.2;
    end    
    seq.frames(img_num).cells_colors = ...
        zeros(length(seq.frames(img_num).cellgeom.circles(:,1)),3);
    seq.frames(img_num).cells_colors(nonzeros(user_lighted),:) = user_cells_colors(nonzeros(user_lighted),:);
    seq.frames(img_num).cells_alphas = 0.2 * ...
        zeros(length(seq.frames(img_num).cellgeom.circles(:,1)),1);
    seq.frames(img_num).cells_alphas(nonzeros(user_lighted),1) = user_cells_alphas(nonzeros(user_lighted),1); 
    %seq.frames(img_num).on_cells = false(length(seq.frames(img_num).cellgeom.circles(:,1)), 1);
    %seq.frames(img_num).on_cells(nonzeros(user_lighted)) = true;
end
    
cell_states = false(length(seq.frames(img_num).cellgeom.circles(:,1)),1);
cell_states(nonzeros(user_lighted)) = 1;
edge_states = false(length(seq.frames(img_num).cellgeom.edges(:,1)),1);
edge_states(nonzeros(edges)) = 1;


apply_all_cells = get(handles.apply_to_all, 'value');
if ~apply_all_cells
    user_lighted = find(getappdata(handles.figure1, 'touched_cells'));
    touched_edges = find(getappdata(handles.figure1, 'touched_edges'));
    
    edges = touched_edges;
else
    edges = nonzeros(edges);
    edge_states = true(length(edges), 1);
end

seq = update_orbit(seq, user_lighted, user_cells_colors, ...
     user_cells_alphas, t_num, z_num, orbit, edges, ...
     cell_states, edge_states, apply_all_cells, ...
     strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on'));

 
setappdata(handles.figure1, 'touched_cells', ...
    false(length(seq.frames(img_num).cellgeom.circles(:,1)), 1));
setappdata(handles.figure1, 'touched_edges', ...
    false(length(seq.frames(img_num).cellgeom.edges(:,1)), 1));


setappdata(handles.figure1, 'first_time', 1);
%setappdata(handles.figure1, 'seq', seq);
update_frame(handles, t_num, z_num);


% --------------------------------------------------------------------
function cells_none_menu_Callback(hObject, eventdata, handles)
% hObject    handle to cells_none_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
global seq
img_num = seq.frames_num(t, z);

if strcmp(lower(get(handles.files2cluster, 'Checked')), 'on');
    clusters = true;
else
    clusters = false;
end

if clusters
    apply_all = get(handles.apply_to_all, 'value');
    if apply_all
        seq.frames(img_num).clusters_data = zeros(1,0);
        seq.clusters_map(img_num, :) = 0;
        seq.inv_clusters_map(img_num, :) = 0;
        create_clusters_orbit(handles);
        color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
            'cluster_tracking_f', 'ghost_clusters');
    else
        old_cells = [seq.frames(img_num).clusters_data.cells];
        touched_cells = getappdata(handles.figure1, 'touched_cells');
        touched_cells(old_cells) = true;
        all_mod_clust = find(seq.inv_clusters_map(img_num,:));
        [seq.frames(img_num).clusters_data.cells] = deal([]);
        update_clusters_orbit(handles, find(touched_cells), all_mod_clust)
        color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
            'cluster_tracking_f', 'ghost_clusters');
    end
    z = str2double(get(handles.slice_number, 'String'));
    update_frame(handles, str2double(get(handles.frame_number, 'string')), z);
    return
end


touched_cells = getappdata(handles.figure1, 'touched_cells');
touched_cells(nonzeros(seq.frames(img_num).cells)) = 1;

user_lighted = [];
user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_colors(:) = 0;
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');
edges = getappdata(handles.figure1, 'user_edges');
seq.frames(img_num).cells = user_lighted;
seq.frames(img_num).cells_colors = user_cells_colors;
seq.frames(img_num).cells_alphas = user_cells_alphas;

setappdata(handles.figure1, 'touched_cells', touched_cells);
call_update_orbit(handles, user_lighted, user_cells_colors, user_cells_alphas, edges)

% --------------------------------------------------------------------
function Edges_none_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Edges_none_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
global seq
%seq = getappdata(handles.figure1, 'seq');
img_num = seq.frames_num(t, z);  
touched_edges = getappdata(handles.figure1, 'touched_edges');
touched_edges(nonzeros(seq.frames(img_num).edges)) = 1;
setappdata(handles.figure1, 'touched_edges', touched_edges);

user_lighted = getappdata(handles.figure1, 'user_cells');
user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');
edges = [];
seq.frames(img_num).edges = edges;



call_update_orbit(handles, user_lighted, user_cells_colors, user_cells_alphas, edges)



% --- Executes on button press in hide.
function hide_Callback(hObject, eventdata, handles)
% hObject    handle to hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide
z = str2double(get(handles.slice_number, 'String'));
if get(hObject,'Value')
    update_frame(handles, 0, z);
else
    update_frame(handles, str2double(get(handles.frame_number, 'String')), z);
end



% --- Executes on button press in zoom_btn.
function zoom_btn_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoom_btn
pan off
set(handles.pan_btn, 'Value', 0)

if get(hObject,'Value')
    set(handles.zoom_and_track_cells, 'Checked', 'off');
%     h = zoom(handles.figure1);
%     set(h,'ActionPostCallback',@mypostcallback);
    zoom on

else
    zoom off
end

function mypostcallback(obj,evd)
% zoom(handles.figure1, 'off')



% --- Executes on slider movement.
function slice_slider_Callback(hObject, eventdata, handles)
% hObject    handle to slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global seq
%z_jump
[dummy ind] = min(abs(-seq.valid_z_vals - get(hObject,'Value')));
set(hObject, 'Value', -seq.valid_z_vals(ind));
update_frame(handles, get(handles.frame_slider, 'Value'), -get(hObject, 'Value'));

% --- Executes during object creation, after setting all properties.
function slice_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function slice_number_Callback(hObject, eventdata, handles)
% hObject    handle to slice_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slice_number as text
%        str2double(get(hObject,'String')) returns contents of slice_number as a double

global seq
%z_jump
[dummy ind] = min(abs(seq.valid_z_vals - str2double(get(hObject,'String'))));
z = seq.valid_z_vals(ind);

% z = min(max(round(str2double(get(hObject,'String'))), ...
%     -get(handles.slice_slider, 'max')), -get(handles.slice_slider, 'min'));
set(hObject, 'String', z);
val = str2double(get(handles.frame_number, 'String'));
update_frame(handles, val, z);


% --- Executes during object creation, after setting all properties.
function slice_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in track_up.
function track_up_Callback(hObject, eventdata, handles)
% hObject    handle to track_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_orbit_frames(hObject, eventdata, handles)

% --- Executes on button press in track_down.
function track_down_Callback(hObject, eventdata, handles)
% hObject    handle to track_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_orbit_frames(hObject, eventdata, handles)



% --------------------------------------------------------------------
function select_cells_from_files_Callback(hObject, eventdata, handles)
% hObject    handle to select_cells_from_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%selected_in_files
%selected in files


t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
global seq
orbit = get_orbit_frames(handles);
%seq = getappdata(handles.figure1, 'seq');
for img_num = orbit
    if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
        cells = false(1,length(seq.frames(img_num).cellgeom.circles(:,1)));
        cells(seq.frames(img_num).cells) = true;
    else
        cells = true(1,length(seq.frames(img_num).cellgeom.circles(:,1)));
    end
    user_cells_colors = zeros(length(seq.frames(img_num).cellgeom.circles(:,1)), 3);
    user_cells_alphas = ones(length(seq.frames(img_num).cellgeom.circles(:,1)), 1);
    cells = find(seq.frames(img_num).cellgeom.selected_cells & cells);
    c = get(handles.user_select_c, 'BackgroundColor');
    user_cells_colors(cells,:) = repmat(c, length(cells), 1);
    user_cells_alphas(cells,:) = get(handles.user_select_c, 'userdata');
    seq.frames(img_num).cells = cells;
    seq.frames(img_num).cells_colors = user_cells_colors;
    seq.frames(img_num).cells_alphas = user_cells_alphas;
end
%setappdata(handles.figure1, 'seq', seq);
update_frame(handles, t, z);


% --------------------------------------------------------------------
function select_cells_in_files_Callback(hObject, eventdata, handles)
% hObject    handle to select_cells_in_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


readonly = strcmp(lower(get(handles.readonly_menu, 'Checked')), 'on');
if readonly
    h = msgbox('I''m in read only mode.', '','warn','modal');
    waitfor(h)
    return
end
orbit = get_orbit_frames(handles);
global seq
for img_num = orbit
    new_sel = false(size(seq.frames(img_num).cellgeom.selected_cells));
    cellgeom = seq.frames(img_num).cellgeom;
    new_sel(seq.frames(img_num).cells) = true;
    %%new_sel = reshape(new_sel, 1, length(new_sel)); %%%%%%%%%%%%%%%%%
    filename = seq.frames(img_num).filename;    
    %vars = load(filename, 'cellgeom');
    cellgeom.selected_cells = new_sel;
    save(filename, 'cellgeom', '-v6', '-append');
end

msgbox('Done.', '','none','modal')



% --------------------------------------------------------------------
function track_menu_Callback(hObject, eventdata, handles)
% hObject    handle to track_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(lower(get(handles.files2cluster, 'Checked')), 'on');
    clusters = true;
else
    clusters = false;
end

if clusters
    global seq
    apply_all = get(handles.apply_to_all, 'value');
    if apply_all
        create_clusters_orbit(handles);
        color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
            'cluster_tracking_f', 'ghost_clusters');
    else
        touched_cells = getappdata(handles.figure1, 'touched_cells');
        all_mod_clust = getappdata(handles.figure1, 'touched_clusters');
        if any(all_mod_clust)
            update_clusters_orbit(handles, find(touched_cells), all_mod_clust)
        end
        color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
            'cluster_tracking_f', 'ghost_clusters');
    end
else
    update_direction(handles)
end

function create_clusters_orbit(handles)
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);
clusters = seq.frames(frame_num).clusters_data;
orbit = get_orbit_frames(handles);
orbit = setdiff(orbit(:)', frame_num, 'legacy');
%seq.clusters_map = repmat(1:length(clusters), length(seq.frames), 1);
%seq.inv_clusters_map = seq.clusters_map;

for i = orbit
    seq.frames(i).clusters_data = clusters;
    seq.clusters_map(i,:) = seq.clusters_map(frame_num,:);
    seq.inv_clusters_map(i,:) = seq.inv_clusters_map(frame_num,:);
    for j = 1:length(clusters)
        o_cells = seq.inv_cells_map(frame_num, clusters(j).cells);
        n_cells = nonzeros(uint16(full(seq.cells_map(i, o_cells))))';
        seq.frames(i).clusters_data(j).cells = n_cells;
        if isempty(n_cells)
            seq.frames(i).clusters_data(j).boundary = [];
            seq.frames(i).clusters_data(j).center = [];
        else
            seq.frames(i).clusters_data(j) = ...
                build_cluster_data(seq.frames(i).clusters_data(j).cells, ...
                seq.frames(i).cellgeom);

%             seq.frames(i).clusters_data(j).boundary = ...
%                 cluster_outer_nodes(seq.frames(i).clusters_data(j).cells, ...
%                 seq.frames(i).cellgeom);
%             seq.frames(i).clusters_data(j).center = ...
%                 centroid(seq.frames(i).cellgeom.nodes(seq.frames(i).clusters_data(j).boundary, :));
        end
    end
end
setappdata(handles.figure1, 'touched_clusters', ...
    false(length(seq.frames(frame_num).clusters_data), 1));



% --- Executes on button press in apply_to_all.
function apply_to_all_Callback(hObject, eventdata, handles)
% hObject    handle to apply_to_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of apply_to_all


% --- Executes on button press in apply_to_changed.
function apply_to_changed_Callback(hObject, eventdata, handles)
% hObject    handle to apply_to_changed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of apply_to_changed


% --- Executes on button press in whole_cell_btn.
function whole_cell_btn_Callback(hObject, eventdata, handles)
% hObject    handle to whole_cell_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of whole_cell_btn




% --------------------------------------------------------------------
function clust2files_Callback(hObject, eventdata, handles)
% hObject    handle to clust2files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
readonly = strcmp(lower(get(handles.readonly_menu, 'Checked')), 'on');
if readonly
    msgbox('I''m in read only mode', '','','modal')
    return
end

global seq
orbit = get_orbit_frames(handles);
msg = sprintf(['About to save clusters in %d frames. Do yo want to continue?'], ...
    length(orbit));
button = questdlg(msg);

if strcmp(button, 'Cancel')
    return
end
for i = orbit
    save_clusters(i)
end

% --------------------------------------------------------------------
function save_clusters(i)
global seq
cellgeom = seq.frames(i).cellgeom_edit;
first = true;
for clst_cnt = 1:length(seq.frames(i).clusters_data)
    if ~isempty(seq.frames(i).clusters_data(clst_cnt).cells)
        cells = seq.frames(i).clusters_data(clst_cnt).cells;
        if first
            first = false;
            clusters_data(1) = build_cluster_data(cells, cellgeom);
        else
            clusters_data(end + 1) = build_cluster_data(cells, cellgeom);
        end
    end
end
if first
    clusters_data = [];
end
seq.frames(i).clusters_data = clusters_data;
filename = seq.frames(i).filename;
% clusters_data = seq.frames(i).clusters_data(ind);
% clusters_data = reshape(clusters_data, length(clusters_data), 1);
save(filename, 'clusters_data', '-v6', '-append');

function set_gui_clusters(handles, clusters)
if clusters
    set(handles.drawing_style, 'userdata', 2);
    set(handles.cell_interior_btn, 'value', 1);
    set(handles.user_select_button, 'string', 'Edit Clusters')
    set(handles.poly_select_button, 'string', 'Remove Clst')
    set(handles.files2cluster, 'Checked', 'on')
    
else
    set(handles.files2cluster, 'Checked', 'off')
    set(handles.user_select_button, 'string', 'Select Cells')
    set(handles.poly_select_button, 'string', 'Poly Select')
    set(handles.drawing_style, 'userdata', 1);
    set(handles.whole_cell_btn, 'value', 1);
end
% --------------------------------------------------------------------
function files2cluster_Callback(hObject, eventdata, handles)
% hObject    handle to files2cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'Checked'), 'on')
    set_gui_clusters(handles, 0)
    return
else
    global seq
    if isfield(seq.frames, 'clusters_data')
        button = questdlg('Clusters already read from files. Do you want to reload data?');
        if strcmp(button, 'Yes')
            track_clusters(true);
            clusters = 1:length(seq.clusters_map(1,:));
%            extend_clusters(10, clusters)
            color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
                'cluster_tracking_f', 'ghost_clusters');
        elseif strcmp(button, 'No')
            track_clusters
            color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
                'cluster_tracking_f', 'ghost_clusters');

%             color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
%                 'cluster_tracking_f', 'ghost_clusters');
        else
            return
        end
    else
        track_clusters(true);
        clusters = 1:length(seq.clusters_map(1,:));
%        extend_clusters(10, clusters)
        color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
            'cluster_tracking_f', 'ghost_clusters');
    end
    set_gui_clusters(handles, 1);
    update_frame(handles, str2double(get(handles.frame_number, 'string')), -get(handles.slice_slider, 'Value'));
end



% --- Executes on button press in bnr.
function bnr_Callback(hObject, eventdata, handles)
% hObject    handle to bnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bnr


z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);


% --- Executes on button press in clstr_color.
function clstr_color_Callback(hObject, eventdata, handles)
% hObject    handle to clstr_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seq
t_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(t_num, z_num);
clrs = reshape(get_cluster_colors(1:100), [100, 1 3]);
for i = 1:10
    for j = 1:10
        img(1 + 30*(i-1): 30*i, 1 + 30*(j-1): 30*j, :) = repmat(clrs(10*(i-1) + j, 1,:), [30,30,1]);
    end
end
% states = disable_all_controls(handles);
[y,x, button] = ginput(1);
% enable_all_controls(handles, states);


if ~isempty(x) & button ~= 27 ;
    I1 = cell_from_pos(y, x, seq.frames(frame_num).cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end

    clstrs = false(1, length(seq.frames(frame_num).clusters_data));
    for clst_num = 1:length(seq.frames(frame_num).clusters_data)
        clstrs(clst_num) = ismember(I1, seq.frames(frame_num).clusters_data(clst_num).cells, 'legacy');
    end
    clstrs = seq.inv_clusters_map(frame_num, find(clstrs));
    h=figure; image(img);
%     states = disable_all_controls(handles);
    [x2,y2, button2] = ginput(1);
%     enable_all_controls(handles, states);
    
    
    if ~isempty(x2) & button2 ~= 27; 
        seq.clusters_colors(clstrs) = 10*floor(y2/30) + ceil(x2/30);
    end
    close(h)
end
color_clusters(get_orbit_frames(handles), 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters');
%color_clusters(1:length(seq.frames), 'cluster_tracking_b', 'cluster_tracking_f', ...
%    'ghost_clusters');
update_frame(handles, t_num, z_num);


% --------------------------------------------------------------------
function find_clusters_menu_Callback(hObject, eventdata, handles)
% hObject    handle to find_clusters_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global seq
% prompt = {'Enter minimal cluster size', ...
%     'Enter maximal cluster size'};
% dlg_title = 'Input for cluster highlighting';
% num_lines = 1;
% def = {'5', 'inf'};
% answer = cellfun(@str2num, inputdlg(prompt,dlg_title,num_lines,def));
% if isempty(answer)
%     return
% end
% 
% global seq
% load('clusters_vars', 'clusters_cells', 'clusters_num_cells', 'orbit');
% 
% clusters_cells = clusters_cells(clusters_num_cells >= answer(1) & ... 
%     clusters_num_cells <= answer(2), :); 
% seq.clusters_map = zeros(length(seq.cells_map(:, 1)), length(clusters_cells(:,1)));
% seq.inv_clusters_map = zeros(length(seq.cells_map(:, 1)), length(clusters_cells(:,1)));
% max_cnt = 0;
% for j = orbit
%     seq.frames(j).clusters_data = [];
%     cnt = 0;
%     for i = 1:length(clusters_cells(:, j));
%         if length(clusters_cells(i, j).cells) >= answer(1)
%             cnt = cnt + 1;
%             if cnt == 1
%                 seq.frames(j).clusters_data = build_cluster_data(...
%                     clusters_cells(i, j).cells, seq.frames(j).cellgeom, 1);
%             else
%                 seq.frames(j).clusters_data(cnt) = build_cluster_data(...
%                     clusters_cells(i, j).cells, seq.frames(j).cellgeom, 1);
%             end
%             seq.clusters_map(j, i) = cnt;
%             seq.inv_clusters_map(j, cnt) = i;
%         end
%     end
%     max_cnt = max(cnt, max_cnt);
% end
% seq.clusters_colors = 1:length(seq.clusters_map(orbit, :));
% seq.inv_clusters_map = seq.inv_clusters_map(1:length(seq.cells_map(:, 1)), 1:max_cnt);
% color_clusters(orbit, 'cluster_tracking_b', 'cluster_tracking_f', ...
%     'ghost_clusters');
% set_gui_clusters(handles, 1);
% update_frame(handles);
% 
% return


global seq
prompt = {'Enter minimal edge length', 'Enter maximal edge length', 'Enter minimal cluster size', ...
    'Enter maximal cluster size'};
dlg_title = 'Input for cluster highlighting';
num_lines = 1;
def = {'0','5', '6', 'inf'};
answer = cellfun(@str2num, inputdlg(prompt,dlg_title,num_lines,def));
if isempty(answer)
    return
end


orbit = get_orbit_frames(handles);
readonly = strcmp(lower(get(handles.readonly_menu, 'Checked')), 'on');
if readonly
    save_to_file_flag = false;
else
    msg = sprintf(['About to find clusters in %d frames. ' ...
        'Do yo want to save the clusters information to the case files as well?'], ...
        length(orbit));
    button = questdlg(msg);
    switch button
        case 'Yes'
            save_to_file_flag = true;
        case 'No'
            save_to_file_flag = false;
        otherwise
            return
    end
end
% 
% button = questdlg('Which frame''s file do you want to update?',...
%                   '', 'All frames', 'Current frame', 'Cancel', 'All frames');
% switch button 
%     case 'All frames'
%         orbit = 1:length(seq.frames);
%     case 'Current frame'
%         t = str2double(get(handles.frame_number, 'String'));
%         z = str2double(get(handles.slice_number, 'String'));
%         orbit = seq.frames_num(t, z);
%     otherwise
%         return
% end
    
touched_cells = getappdata(handles.figure1, 'touched_cells');
for i = orbit
    clusters_data = [];
    clusters_lighted = select_clusters_nodes(seq.frames(i).cellgeom, ...
	answer(2), answer(1), answer(3), answer(4), true);
    if length(clusters_lighted) > 0
        clusters_data = build_cluster_data(clusters_lighted{1}, seq.frames(i).cellgeom);
        touched_cells(clusters_data.cells) = 1;
        for clst_cnt=2:length(clusters_lighted)
            clusters_data(clst_cnt) = ...
                build_cluster_data(clusters_lighted{clst_cnt}, seq.frames(i).cellgeom);
            touched_cells(clusters_data(clst_cnt).cells) = 1;
        end
    end
    seq.frames(i).clusters_data = clusters_data;
    if save_to_file_flag
        save(seq.frames(i).filename, 'clusters_data', '-v6', '-append');
    end
end

setappdata(handles.figure1, 'touched_clusters', 1:length(clusters_data));
setappdata(handles.figure1, 'touched_cells', touched_cells);

    
if length(orbit) > 1
    track_clusters;
    clusters = 1:length(seq.clusters_map(1,:));
    %extend_clusters(10, clusters)
    color_clusters(1:length(seq.frames), 'cluster_tracking_b', ...
        'cluster_tracking_f', 'ghost_clusters');
else
    if ~isfield(seq, 'clusters_map')
        seq.clusters_map = zeros(length(seq.frames), length(clusters_data), 'uint8');
    end
    seq.clusters_map(orbit, :) = 0;
    old_num = length(seq.clusters_map(orbit,:));
    seq.clusters_map(orbit, old_num + 1 : old_num + length(clusters_data)) = 1:length(clusters_data);
    seq.inv_clusters_map(orbit, 1:length(clusters_data)) = old_num + (1:length(clusters_data));
    if isfield(seq, 'clusters_colors')
        seq.clusters_colors(old_num + 1 : old_num + length(clusters_data)) = ...
            (1:length(clusters_data)) +  old_num;
    else
        seq.clusters_colors = 1:length(seq.clusters_map(orbit, :));
    end
end
color_clusters(orbit, 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters');
set_gui_clusters(handles, 1);
update_frame(handles, str2double(get(handles.frame_number, 'string')), -get(handles.slice_slider, 'Value'));



function t_from_Callback(hObject, eventdata, handles)
% hObject    handle to t_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_from as text
%        str2double(get(hObject,'String')) returns contents of t_from as a double
val = min(max(round(str2double(get(hObject,'String'))), ...
    get(handles.frame_slider, 'Min')), get(handles.frame_slider, 'Max'));
set(hObject,'String', val)

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



function t_to_Callback(hObject, eventdata, handles)
% hObject    handle to t_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_to as text
%        str2double(get(hObject,'String')) returns contents of t_to as a double
val = min(max(round(str2double(get(hObject,'String'))), ...
    get(handles.frame_slider, 'Min')), get(handles.frame_slider, 'Max'));
set(hObject,'String', val)

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



function z_from_Callback(hObject, eventdata, handles)
% hObject    handle to z_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_from as text
%        str2double(get(hObject,'String')) returns contents of z_from as a double
val = min(max(round(str2double(get(hObject,'String'))), ...
    get(handles.frame_slider, 'Min')), get(handles.frame_slider, 'Max'));
set(hObject,'String', val)

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



function edit6_Callback(hObject, eventdata, handles)
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





function z_to_Callback(hObject, eventdata, handles)
% hObject    handle to z_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_to as text
%        str2double(get(hObject,'String')) returns contents of z_to as a double
val = min(max(round(str2double(get(hObject,'String'))), ...
    get(handles.frame_slider, 'Min')), get(handles.frame_slider, 'Max'));
set(hObject,'String', val)



% --------------------------------------------------------------------
function extend_clusters_menu_Callback(hObject, eventdata, handles)
% hObject    handle to extend_clusters_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seq
t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(t, z);
data = ext_clusters_dlg;
switch data.clusters
    case 0 %cancel
        return
    case 1 %all clusters
        clusters = 1:length(seq.clusters_map(1,:));
    case 2 %clusters in frame
        clusters = nonzeros(seq.inv_clusters_map(frame_num,:));
    case 3 %select clusters
        clusters = seq.inv_clusters_map(frame_num, ...
            select_clusters_from_input(frame_num, seq.frames(frame_num).cellgeom, handles));
end
extend_clusters(data.span, clusters);
color_clusters(1:length(seq.frames), 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters');


% --------------------------------------------------------------------
function select_by_poly_seq_menu_Callback(hObject, eventdata, handles)
% hObject    handle to select_by_poly_seq_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Highlight by poly sequence

% if ishandle(handles.figure1)
%     disp('It''s a handle!');
% else
%     disp('It is not a handle');
% end

poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');

highlight_by_poly_seq(handles, poly_seq, poly_frame_ind)
return

%OBSOLETE
return
%function select_by_poly_seq_menu_Callback(hObject, eventdata, handles)
% global seq
% orbit = get_orbit_frames(handles);
% msg = sprintf('%d frames selected. Do you want to recalculate data files?', ...
%     length(orbit));
% button = questdlg(msg);
% if strcmp(button, 'Cancel')
%     return
% end
% if strcmp(button, 'Yes')
%     for i = orbit
%         data = generate_data(seq.frames(i).cellgeom, seq.frames(i).clusters_data);
%         [pathstr, name, ext, versn] = fileparts(seq.frames(i).filename);
%         new_filename = [name '_data.mat'];
%         save(new_filename, 'data', '-v6');
%     end
% end
% 
data = data_tracking(seq, orbit);
setappdata(getappdata(handles.figure1, 'calling_window'), 'tracked_data', data);
setappdata(getappdata(handles.figure1, 'calling_window'), 'tracked_data_dir', seq.directory);
% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --------------------------------------------------------------------
function fix_geom_menu_Callback(hObject, eventdata, handles)
% hObject    handle to fix_geom_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


readonly = strcmp(lower(get(handles.readonly_menu, 'Checked')), 'on');
if readonly
    msgbox('I''m in read only mode', '','none','modal')
    return
end

orbit = get_orbit_frames(handles);
msg = sprintf(['About to fix geom in %d frames. You will need to reload'...
    ' for this to take effect. Continue?'], length(orbit));
answer = questdlg(msg);
if strcmp(answer, 'Yes')
    global seq
    for i = orbit
        frame_num = i;
        cellgeom = fix_geom(seq.frames(frame_num).cellgeom_edit);
        filename = seq.frames(frame_num).filename;
        save(filename, 'cellgeom', '-v6', '-append');
        seq.changed = 1;
        seq.frames(frame_num).saved = true;
        seq.frames(frame_num).changed = 0;
        seq.frames(frame_num).sticky_changed = 1;
    end
end




% --------------------------------------------------------------------
function z_track_Callback(hObject, eventdata, handles)
% hObject    handle to z_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
z = str2double(get(handles.slice_number, 'String'));

l = str2double(get(handles.t_from, 'string')); 
r = str2double(get(handles.t_to, 'string'));
b = str2double(get(handles.z_from, 'string'));
t = str2double(get(handles.z_to, 'string'));


orbit = nonzeros(seq.frames_num(l:r, b:t))';

apply_to_all = get(handles.apply_to_all, 'value');

seq.valid_z_vals = reshape(seq.valid_z_vals, 1, length(seq.valid_z_vals));
for j = l:r
    src_frame = seq.frames_num(j,z);
    src_cells = seq.frames(src_frame).cells;
    cells = seq.inv_cells_map(src_frame, src_cells);
    cells_colors = seq.frames(src_frame).cells_colors(src_cells, :);
    cells_alphas = seq.frames(src_frame).cells_alphas(src_cells);
    for k = seq.valid_z_vals
        new_frame = seq.frames_num(j,k);
        if apply_to_all
            seq.frames(new_frame).cells = nonzeros(seq.cells_map(new_frame, cells));
            seq.frames(new_frame).cells_colors = ...
                zeros(length(seq.frames(new_frame).cellgeom.circles(:,1)),3);
            seq.frames(new_frame).cells_alphas = 0.2 * ...
                ones(length(seq.frames(new_frame).cellgeom.circles(:,1)),1);

            seq.frames(new_frame).cells_colors(seq.frames(new_frame).cells, :) = ...
                cells_colors(find(seq.cells_map(new_frame, cells)), :);
            seq.frames(new_frame).cells_alphas(seq.frames(new_frame).cells) = ...
                cells_alphas(find(seq.cells_map(new_frame, cells))); 
        else
            temp_cells = false(1, length(seq.frames(new_frame).cellgeom.circles(:,1)));
            temp_cells(seq.frames(new_frame).cells) = true;
            frame_cells = seq.cells_map(new_frame, cells);
            temp_cells(nonzeros(frame_cells)) = true;
            seq.frames(new_frame).cells = find(temp_cells);
            seq.frames(new_frame).cells_colors(nonzeros(frame_cells), :) = ...
                cells_colors(find(frame_cells), :);
            seq.frames(new_frame).cells_alphas(nonzeros(frame_cells)) = ...
                cells_alphas(find(frame_cells)); 
        end
    end
end


% --------------------------------------------------------------------
function static_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to static_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
cellgeom = seq.frames(frame_num).cellgeom;

%hold on
x=[]; y=[]; l=[];
states = disable_all_controls(handles);
[yin,xin, b] = ginput(1);
enable_all_controls(handles, states);
    
while ~isempty(xin) & b ~= 27 & b ~= 3;
  l(end+1) = plot(yin,xin,'wx');
  if ~isempty(x) 
    l(end+1) = plot([y(end) yin],[x(end) xin],'w');
  end
  x(end+1)=xin;
  y(end+1)=yin;
  last_b = b;
  states = disable_all_controls(handles);
  [yin,xin, b] = ginput(1);
  enable_all_controls(handles, states);

end
delete(l);
orbit = get_orbit_frames(handles);
c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');
for i = orbit
    new_selection = inpolygon(seq.frames(i).cellgeom.circles(:,1), ...
        seq.frames(i).cellgeom.circles(:,2), x, y);
    seq.frames(i).cells = find(new_selection);
    seq.frames(i).cells_colors(:,1) = c(1);
    seq.frames(i).cells_colors(:,2) = c(2);
    seq.frames(i).cells_colors(:,3) = c(3);
    seq.frames(i).cells_alphas(:, 1) = a;
end
z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);


% --------------------------------------------------------------------
function bnr_menu_Callback(hObject, eventdata, handles)
% hObject    handle to bnr_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
orbit = get_orbit_frames(handles);
bnr_dir = fullfile(seq.directory, seq.bnr_dir);
if ~isdir(bnr_dir)
    mkdir(bnr_dir)
end
%d = [seq.directory '\' seq.bnr_dir];
for i = orbit
    filename = seq.frames(i).img_file
    [z t] = get_file_nums(filename);
    a1 = double(imread(fullfile(seq.directory, filename)));
    filename = put_file_nums(filename, t, z+1);
    if length(dir(fullfile(seq.directory, filename)))
        a2 = double(imread(fullfile(seq.directory, filename)));
    else
        a2 = a1;
    end
    filename = put_file_nums(filename, t, z-1);
    if length(dir(fullfile(seq.directory, filename)))
        a3 = double(imread(fullfile(seq.directory, filename)));
    else
        a3 = a1;
    end
    if ~all(size(a1) == size(a2))
        a2 = a1;
    end
    if ~all(size(a1) == size(a3))
        a3 = a1;
    end
    a = (a1.*a2.*a3);
    a = (a ./ max(max(a)))*255;
    a = uint8(round(a));
    a = imadjust(a, stretchlim(a(a>0)), [0, 1]);
    
    filename = fullfile(seq.directory, seq.bnr_dir, seq.frames(i).img_file);
    imwrite(a, filename, 'tiff');
end


% --- Executes on button press in z_from_lock.
function z_from_lock_Callback(hObject, eventdata, handles)
% hObject    handle to z_from_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of z_from_lock




% --- Executes on button press in z_to_lock.
function z_to_lock_Callback(hObject, eventdata, handles)
% hObject    handle to z_to_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of z_to_lock


% --- Executes on button press in t_from_lock.
function t_from_lock_Callback(hObject, eventdata, handles)
% hObject    handle to t_from_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of t_from_lock


% --- Executes on button press in t_to_lock.
function t_to_lock_Callback(hObject, eventdata, handles)
% hObject    handle to t_to_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of t_to_lock




% --------------------------------------------------------------------
function brightness_menu_Callback(hObject, eventdata, handles)
% hObject    handle to brightness_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if getappdata(handles.figure1, 'multi_channel')
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
    update_frame(handles)
else
    fac = getappdata(handles.figure1, 'bright_fac');
    fac = inputdlg('Set brightness factor', '',1, {num2str(fac)});
    fac = str2double(fac);
    if isempty(fac) || ~isfinite(fac) || ~isnumeric(fac)
        return
    end
    fac = real(fac);
    setappdata(handles.figure1, 'bright_fac', fac);
    update_frame(handles)
end

% --------------------------------------------------------------------
function load_poly_seq_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_poly_seq_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Load poly sequence
load_saved_polys(handles)



return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OBSOLETE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function load_poly_seq_menu_Callback(hObject, eventdata, handles)
% success = false;
% if isappdata(getappdata(handles.figure1, 'calling_window'), 'tracked_data_dir');
%     data_dir = ...
%         getappdata(getappdata(handles.figure1, 'calling_window'), 'tracked_data_dir');
%     if strcmp(data_dir, pwd)
%         success = true;
%     end
% end
% if ~success
%     h = msgbox('please generate data first.', '', 'warn', 'modal');
%     waitfor(h)
%     return
% end
% 
% options = view_mean_data_dlg;
% if options.cancel == true
%     return
% end
% cells_lim_to_sel = options.cells_lim_to_sel;
% edges_lim_to_sel = options.edges_lim_to_sel;
% nodes_lim_to_sel = options.nodes_lim_to_sel;
% 
% 
% 
% 
% 
% global seq
% cells_to_anal = false(size(seq.cells_map));
% edges_to_anal = true(size(seq.edges_map));
% high_edges_to_anal = false(size(seq.edges_map));
% edges_to_anal_from_cells = false(size(seq.edges_map));
% orbit = get_orbit_frames(handles);
% for i = orbit
%     cells = seq.frames(i).cells;
%     cells_to_anal(i, seq.inv_cells_map(i, cells)) = true;
%     edges = seq.frames(i).cellgeom.edgecellmap(ismember(seq.frames(i).cellgeom.edgecellmap(:,1), cells), 2);
%     nodes_high_cells(i, seq.frames(i).cellgeom.edges(edges, :)) = true;
%     nodes_high_edges(i, seq.frames(i).cellgeom.edges(seq.frames(i).edges, :)) = true;
%     edges = edges(edges < length(seq.inv_edges_map(i, :)));
%     g_edges = nonzeros(seq.inv_edges_map(i, edges)); % nonzeros in case an edge
%     %% associated with only one cell is part of edges.
%     edges_to_anal_from_cells(i, g_edges) = true;
%     g_edges = nonzeros(seq.inv_edges_map(i, seq.frames(i).edges));
%     high_edges_to_anal(i, g_edges) = true;
% end
% if ~options.lim_cells_to_high
%     cells_to_anal(:) = 1;
% end
% 
% if options.lim_edges_to_high
%     edges_to_anal = edges_to_anal & high_edges_to_anal;
% end
% if options.lim_edges_to_cells
%     edges_to_anal = edges_to_anal & edges_to_anal_from_cells;
% end
% 
% nodes_high_edges(:, end + 1: length(nodes_high_cells)) = 0; 
% nodes_high_cells(:, end + 1: length(nodes_high_edges)) = 0;
% nodes_to_anal = true(max(size(nodes_high_cells), size(nodes_high_edges)));
% if options.lim_nodes_to_cells
%     nodes_to_anal = nodes_to_anal & nodes_high_cells;
% end
% if options.lim_nodes_to_edges
%     nodes_to_anal = nodes_to_anal & nodes_high_edges;
% end
% 
% 
% cells_to_anal = cells_to_anal(orbit, :);
% edges_to_anal = edges_to_anal(orbit, :);
% nodes_to_anal = nodes_to_anal(orbit, :);
% 
% if nnz(cells_to_anal) == 0 && nnz(edges_to_anal) == 0
%     msgbox('Nothing to analyze');
%     return
% end
% 
% 
% pathname = pwd;
% c = strfind(pathname, '\');
% filename = pathname(c(end)+1:end);
% filename = ['md_' filename '.mat'];
% if length(dir(filename))
%     vars_in_file = whos( '-file', filename);
% else
%     vars_in_file = [];
% end
% str = '';
% for i = 1:length(vars_in_file)
%     str = sprintf([str vars_in_file(i).name '\n']);
% end
% str = sprintf(['These variables already exist in %s :\n\n' str ...
%     '\nType a new name (no spaces, must start with a letter):\n'], filename);
% new_var = inputdlg(str, '', 1, {sprintf('z_%d', seq.frames(orbit(1)).z)});
% if isempty(new_var)
%     return
% end
% 
% 
% 
% data = getappdata(getappdata(handles.figure1, 'calling_window'), 'tracked_data');
% %cells = nonzeros(getappdata(handles.figure1, 'user_cells'));
% mean_data = ex_data(data, cells_lim_to_sel, edges_lim_to_sel, ...
%     cells_to_anal, edges_to_anal, nodes_lim_to_sel, nodes_to_anal);
% eval([new_var{1} ' = mean_data;']);
% if length(dir(filename))
%     save(filename, new_var{1}, '-append');
% else
%     save(filename, new_var{1});
% end
% view_data


% --------------------------------------------------------------------
function Complement_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Complement_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq

orbit = get_orbit_frames(handles);
c = get(handles.user_select_c, 'BackgroundColor');
for i = orbit
    new_selection = true(size(seq.frames(i).cellgeom.circles(:,1)));
    new_selection(seq.frames(i).cells) = false;
    seq.frames(i).cells = find(new_selection);
    seq.frames(i).cells_colors(:,1) = c(1);
    seq.frames(i).cells_colors(:,2) = c(2);
    seq.frames(i).cells_colors(:,3) = c(3);
    seq.frames(i).cells_alphas(:, 1) = 0.2;
end
z = str2double(get(handles.slice_number, 'String'));
update_frame(handles, str2double(get(handles.frame_number, 'string')), z);


% --------------------------------------------------------------------
function length_menu_Callback(hObject, eventdata, handles)
% hObject    handle to length_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function lim_to_sel_edges_menu_Callback(hObject, eventdata, handles)
% hObject    handle to lim_to_sel_edges_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end



% --------------------------------------------------------------------
function edges_changes_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edges_changes_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

window_size = 10;
global seq
e = full(seq.edges_map > 0);
c = double(xor(e(1:end-1,:), e(2:end,:)));
%on_edges = conv2(ones(1, 1 + window_size), 1, c) > 0;
orbit = get_orbit_frames(handles);
max_t = max(orbit);
min_t = min(orbit);
for i = orbit(1:end-1);
    for edge = find(c(i, :))
        pl = 0;
        nl = 0;
        for j = max(min_t, i - window_size):i
            if seq.edges_map(j, edge)
                pl = pl + seq.frames(j).cellgeom.edges_length(seq.edges_map(j, edge));
            end
        end
        for j = i:min(max_t, i + window_size)
            if seq.edges_map(j, edge)
                nl = nl + seq.frames(j).cellgeom.edges_length(seq.edges_map(j, edge));
            end
        end
        c(i, edge) = sign(round((pl - nl)/(2*window_size)));
    end
end
on_edges = conv2(ones(1, 1 + 4*window_size), 1, c);

for i = orbit(1:end -1)
    seq.frames(i).edges = seq.edges_map(i, on_edges(i + floor(2*window_size), :) > 0);
    seq.frames(i).edges2 = seq.edges_map(i, on_edges(i + floor(2*window_size), :) < 0);
end
update_frame(handles)


% --------------------------------------------------------------------
function static_edges_Callback(hObject, eventdata, handles)
% hObject    handle to static_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end




% --------------------------------------------------------------------
function add_poly_to_seq_menu_Callback(hObject, eventdata, handles)
% hObject    handle to add_poly_to_seq_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Add new poly to poly seq
draw_and_add_poly_to_poly_seq(handles)

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OBSOLETE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function add_poly_to_seq_menu_Callback(hObject, eventdata, handles)

% options.check = {'count_gain'};
% options.hide = {'uipanel2', 'count_loss', 'count_gain', 'upper_lim', 'lower_lim'};
% options.text = 'Calculate neighbors change';
% options = change_in_nghbrs_dlg(options);
% if options.cancel == true
%     return
% end
% 
% global seq
% cells_to_anal = false(size(seq.cells_map));
% orbit = get_orbit_frames(handles);
% for i = orbit
%     if options.lim_cells_to_high
%         cells = seq.frames(i).cells;
%         cells_to_anal(i, seq.inv_cells_map(i, cells)) = true;
%     else
%         cells_to_anal(i,:) = 1;
%     end
% 
%     if options.cells_lim_to_sel;
%         %temp = global numbers for non selected cells
%         temp = true(size(seq.cells_map(1, :)));
%         temp(seq.inv_cells_map(i, seq.frames(i).cellgeom.selected_cells)) = 0;
%         cells_to_anal(i, temp) = false;
%     end
%         
% end
% 
% 
% i = orbit(1);
% if options.edge_nghbrs
%     [new_map fc] = new_edgecellmap(seq.frames(i).cellgeom);
%     border_cells = false(1, length(seq.cells_map(1,:)));
%     border_cells(seq.inv_cells_map(i, new_map(isnan(new_map(:, 2)), 1))) = true;
%     border_cells(seq.inv_cells_map(i, fc)) = true;
%     new_map = new_map(all(~isnan(new_map), 2), :);
%     nmap = false(length(seq.frames(i).cellgeom.circles(:,1)));
%     nmap(sub2ind(size(nmap), new_map(:, 1), new_map(:, 2))) = 1;
%     nmap = nmap | nmap';
%     border_cells(seq.inv_cells_map(i, any(nmap(seq.cells_map(i, border_cells), :)))) = 1;
%     cells = nonzeros(seq.cells_map(i,cells_to_anal(i, :) & ~border_cells))';
%     cells_to_anal(i, :) = 0;
%     cells_to_anal(i, seq.inv_cells_map(i, cells)) = 1;
% else %% then node neighbors
%     nmap = node_nghbrs_map(seq.frames(i).cellgeom);
%     cells = nonzeros(seq.cells_map(i,cells_to_anal(i, :)))';
%     [new_map fc] = new_edgecellmap(seq.frames(i).cellgeom);
%     border_cells = false(1, length(seq.cells_map(1,:)));
%     border_cells(seq.inv_cells_map(i, new_map(isnan(new_map(:, 2)), 1))) = true;
%     border_cells(seq.inv_cells_map(i, fc)) = true;
%     border_cells(seq.inv_cells_map(i, any(nmap(seq.cells_map(i, border_cells), :)))) = 1;
% 
% end
% for j = cells
%     glob_cell = seq.inv_cells_map(i, j);
%     ncn = seq.inv_cells_map(i, nmap(j, :));
%     pcn{glob_cell} = ncn;
% end
% sum_change(1:length(seq.cells_map(i,:))) = 0;
% [lost{1: length(seq.cells_map(i,:))}] = deal([]);
% found = lost;
% found2 = lost;
% found_first = lost;
% for frm_cnt = 2:length(orbit)
%     i = orbit(frm_cnt);
%     i_minus_1 = orbit(frm_cnt - 1);
%     prev_border_cells = border_cells;
%     if options.edge_nghbrs
%         [new_map fc]= new_edgecellmap(seq.frames(i).cellgeom);
%         border_cells = false(1, length(seq.cells_map(1,:)));
%         border_cells(seq.inv_cells_map(i, new_map(isnan(new_map(:, 2)), 1))) = true;
%         border_cells(seq.inv_cells_map(i, fc)) = true;
%         new_map = new_map(all(~isnan(new_map), 2), :);
%         nmap = false(length(seq.frames(i).cellgeom.circles(:,1)));
%         nmap(sub2ind(size(nmap), new_map(:, 1), new_map(:, 2))) = 1;
%         nmap = nmap | nmap';
%         border_cells(seq.inv_cells_map(i, any(nmap(seq.cells_map(i, border_cells), :)))) = 1;
%         cells = nonzeros(seq.cells_map(i,cells_to_anal(i, :) & ~border_cells))';
%         cells_to_anal(i, :) = 0;
%         cells_to_anal(i, seq.inv_cells_map(i, cells)) = 1;
%     else % then do by node neighbors
%         nmap = node_nghbrs_map(seq.frames(i).cellgeom);
%         cells = nonzeros(seq.cells_map(i,cells_to_anal(i, :)))';
%         [new_map fc] = new_edgecellmap(seq.frames(i).cellgeom);
%         border_cells = false(1, length(seq.cells_map(1,:)));
%         border_cells(seq.inv_cells_map(i, new_map(isnan(new_map(:, 2)), 1))) = true;
%         border_cells(seq.inv_cells_map(i, fc)) = true;
%         border_cells(seq.inv_cells_map(i, any(nmap(seq.cells_map(i, border_cells), :)))) = 1;
% 
%     end
%     for j = cells
%         glob_cell = seq.inv_cells_map(i, j);
%         ncn = seq.inv_cells_map(i, nmap(j, :));
%         if cells_to_anal(i_minus_1, glob_cell) & seq.cells_map(i_minus_1, glob_cell)
%             %%% GAINED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             gained_cells = setdiff(ncn, pcn{glob_cell});      %%% GAINED %%%%%
%             if isempty(found{glob_cell})                      %%% GAINED %%%%%
%                 found{glob_cell} = pcn{glob_cell};            %%% GAINED %%%%%
%                 found2{glob_cell} = pcn{glob_cell};           %%% GAINED %%%%%
%                 found_first{glob_cell} = pcn{glob_cell};      %%% GAINED %%%%%
%             end                                               %%% GAINED %%%%%
%             if ~isempty(gained_cells)
%                 gained_cells = gained_cells(~ismember(gained_cells, found2{glob_cell}));
%                 found2{glob_cell} = [found2{glob_cell} gained_cells];
%             end
%             if ~isempty(gained_cells)
%                 gained_cells = gained_cells(...
%                     seq.cells_map(i, gained_cells) & ...
%                     seq.cells_map(i_minus_1, gained_cells) & ...
%                     ~border_cells(gained_cells) & ~prev_border_cells(gained_cells));
%                 found{glob_cell} = [found{glob_cell} gained_cells];
%             end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             %%% LOST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             lost_cells = setxor(pcn{glob_cell}, ncn);         %%% LOST %%%%
%             if ~isempty(lost_cells)                           %%% LOST %%%%
%                 lost_cells = lost_cells(~ismember(lost_cells, lost{glob_cell}));
%             end
%             if ~isempty(lost_cells)
%                 lost_cells = lost_cells(...
%                     seq.cells_map(i, lost_cells) & ...
%                     seq.cells_map(i_minus_1, lost_cells) & ...
%                     ~border_cells(lost_cells) & ~prev_border_cells(lost_cells));
%                 lost{glob_cell} = [lost{glob_cell} lost_cells];
%             end
%             %%% LOST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         end
%         pcn{glob_cell} = ncn;
%     end
% end
% sum_lost = zeros(size(lost));
% sum_gained = sum_lost;
% for i = 1:length(pcn)
%     found{i} = setdiff(found{i}, found_first{i});
%     lost{i} = setdiff(lost{i}, pcn{i}); % after the previous loop, pcn = ncn = 
%                                        % list of neighbors at the last frame.    
%     sum_lost(i) = length(lost{i});
%     sum_gained(i) = length(found{i});
% end
% 
% dc_data.found = found;
% dc_data.lost = lost;
% dc_data.sum_lost = sum_lost;
% dc_data.sum_gained = sum_gained;
% dc_data.cells_to_anal = cells_to_anal;
% dc_data.draw_change_min_max = [min(min([sum_lost sum_gained])) ...
%     max(max([sum_lost sum_gained]))];
% 
% setappdata(handles.figure1, 'detect_changes', dc_data);
% draw_changes(handles);


function draw_changes(handles)
global seq
dc_data = getappdata(handles.figure1, 'detect_changes');
sum_gained = dc_data.sum_gained;
sum_lost = dc_data.sum_lost;
options.check = {'sel_cells', 'count_gain'};
options.hide = {'node_nghbrs'};
options.text = 'Display results';
options.upper_lim = max(sum_lost + sum_gained);
options.lower_lim = min(sum_gained + sum_lost);
options = change_in_nghbrs_dlg(options);
if options.cancel == true
    return
end
sum_change = options.count_gain * sum_gained + options.count_loss * sum_lost;
lim_cells = sum_change <= options.upper_lim & sum_change >= options.lower_lim;
cells_to_anal = false(size(seq.cells_map));
orbit = get_orbit_frames(handles);
for i = orbit
    if options.lim_cells_to_high
        cells = seq.frames(i).cells;
        cells_to_anal(i, seq.inv_cells_map(i, cells)) = true;
    else
        cells_to_anal(i,:) = 1;
    end

    if options.cells_lim_to_sel;
        %temp = global numbers for non selected cells
        temp = true(size(seq.cells_map(1, :)));
        temp(seq.inv_cells_map(i, seq.frames(i).cellgeom.selected_cells)) = 0;
        cells_to_anal(i, temp) = false;
    end
        cells_to_anal(i, ~lim_cells) = false;
end

%cells_to_anal = cells_to_anal(orbit, :);
min_color = min(sum_change(any(cells_to_anal(:, :), 1)));
max_color = max(sum_change(any(cells_to_anal(:, :), 1)));
cmap = colormap(jet(max_color - min_color + 1));
for i = get_orbit_frames(handles)
    %cells = sum_change > 2 | cells_to_anal(i, :);
    cells = cells_to_anal(i, :);
    seq.frames(i).cells = nonzeros(seq.cells_map(i, cells));
    seq.frames(i).cells_colors(seq.frames(i).cells, :) = ...
        cmap(sum_change(seq.inv_cells_map(i, seq.frames(i).cells)) + 1 - min_color, :);
    seq.frames(i).cells_alphas(:, 1) = 0.3;
end
cmap = cmap * 0.5 + 0.3;
h = colorbar('west');
set(h, 'ytick', (min_color:max_color) + 1 - min_color, 'ycolor', [0 1 0], 'box', 'off', ...
       'color', cmap(1,:), 'yticklabel', min_color:max_color);
cmap_img = findobj('parent', h, 'type', 'image');
cdata = get(cmap_img, 'cdata');
set(cmap_img, 'cdata', reshape(cmap(cdata, :), ...
    ([size(get(cmap_img, 'cdata')) 3])), 'alphadata', 1)
colormap(gray(256));
if get(handles.newfig_check, 'value') 
    drawingfig = getappdata(handles.figure1, 'drawingfig');
    figure(drawingfig);
    nh = copyobj(h, drawingfig);
    set(nh, 'units', 'normalized', 'outerposition', [0 0 .1 .91]);
    delete(h)
end
setappdata(handles.figure1, 'draw_change_min_max', [min_color max_color]);
update_frame(handles)

function show_ngbhrs(handles)
global seq
dc_data = getappdata(handles.figure1, 'detect_changes');
dc_data = getappdata(handles.figure1, 'detect_changes');

options.hide = {'node_nghbrs', 'lower_lim', 'upper_lim'};
options.check = {'high_cells', 'count_gain'};
options.text = 'Click ok to highlight gained or lost neighbors';
options = change_in_nghbrs_dlg(options);
if options.cancel == true
    return
end


cells_to_anal = false(size(seq.cells_map));
orbit = get_orbit_frames(handles);
for i = orbit
    if options.lim_cells_to_high
        cells = seq.frames(i).cells;
        cells_to_anal(i, seq.inv_cells_map(i, cells)) = true;
    else
        cells_to_anal(i,:) = 1;
    end

    if options.cells_lim_to_sel;
        %temp = global numbers for non selected cells
        temp = true(size(seq.cells_map(1, :)));
        temp(seq.inv_cells_map(i, seq.frames(i).cellgeom.selected_cells)) = 0;
        cells_to_anal(i, temp) = false;
    end
       
end

lost = dc_data.lost;
found = dc_data.found;

[lost_n_found{1:length(lost)}] = deal([]);

for i = 1:length(found)
    if options.count_loss 
        lost_n_found{i} = lost{i};
    end
    if options.count_gain
        lost_n_found{i} = union(lost_n_found{i}, found{i}, 'legacy');
    end
end

for i = orbit
    seq.frames(i).cells_colors(:) = 0;
    seq.frames(i).cells_alphas(:) = 0.3;

    seq.frames(i).cells = nonzeros(seq.cells_map(i, unique([lost_n_found{cells_to_anal(i, :)}], 'legacy')));
    glob_cells_nums = find(cells_to_anal(i, :));
    cells = {lost_n_found{cells_to_anal(i, :)}};
    for j = 1:length(cells)
        cls = nonzeros(seq.cells_map(i, cells{j}));
        seq.frames(i).cells_colors(cls, :) = ...
            seq.frames(i).cells_colors(cls, :) + ...
            repmat(get_cluster_colors(glob_cells_nums(j)), [length(cls) 1]);
    end
end        
update_frame(handles);



function high_cells_change(handles, options)
global seq
dc_data = getappdata(handles.figure1, 'detect_changes');
val = options.val;
sum_change = options.count_gain * dc_data.sum_gained + ...
    options.count_loss * dc_data.sum_lost;

min_max = getappdata(handles.figure1, 'draw_change_min_max');
min_color = min_max(1);
max_color = min_max(2);
cells_to_anal = getappdata(handles.figure1, 'cells_to_anal');
cells = sum_change == val ;
cmap = colormap(jet(max_color - min_color + 1));
c = cmap(val - min_color + 1, :);
for i = get_orbit_frames(handles)
    local_cells = nonzeros(full(seq.cells_map(i, cells & cells_to_anal(i,:))));
    if strcmp(get(handles.secret_option, 'checked'), 'on')
        seq.frames(i).cells = union(seq.frames(i).cells, local_cells, 'legacy');
    else
        seq.frames(i).cells = local_cells;
    end
    seq.frames(i).cells_colors(local_cells, 1) = c(1);
    seq.frames(i).cells_colors(local_cells, 2) = c(2);
    seq.frames(i).cells_colors(local_cells, 3) = c(3);
    seq.frames(i).cells_alphas(:, 1) = 0.2;
end
update_frame(handles)

function old_detect_changes(hObject, eventdata, handles)
window_size = 4;
orbit = get_orbit_frames(handles);
global seq
e = full(seq.edges_map > 0);
%c = xor(e(1:end-1,:), e(2:end,:));
c = xor(e(1:end-1,:), e(2:end,:));
orbit = get_orbit_frames(handles);
max_t = max(orbit);
min_t = min(orbit);
for i = orbit(1:end-1);
    for edge = find(c(i, :))
        pl = 0;
        nl = 0;
        for j = max(min_t, i - window_size):i
            if seq.edges_map(j, edge)
                pl = pl + seq.frames(j).cellgeom.edges_length(seq.edges_map(j, edge));
            end
        end
        for j = i:min(max_t, i + window_size)
            if seq.edges_map(j, edge)
                nl = nl + seq.frames(j).cellgeom.edges_length(seq.edges_map(j, edge));
            end
        end
        c(i, edge) = abs(pl - nl) > 10;
    end
end
c(end + 1, :) = c(end, :);

cells_count = zeros(size(seq.inv_cells_map));
for i = orbit
    old_cells{i} = seq.frames(i).cells;
    seq.frames(i).cells = [];
    seq.frames(i).cells_colors(:) = 0;
    edges = full(seq.edges_map(i, c(i, :)));
    for j = nonzeros(edges)';
        ind = seq.frames(i).cellgeom.edgecellmap(:, 2) == j;
        cells = seq.frames(i).cellgeom.edgecellmap(ind, 1);
        seq.frames(i).cells = [seq.frames(i).cells cells'];
        seq.frames(i).cells_colors(cells(1), :) = ...
            seq.frames(i).cells_colors(cells(1), :) + get_cluster_colors(double(seq.inv_edges_map(i, j)));
        cells_count(i, cells(1)) = cells_count(i, cells(1)) + 1;
        seq.frames(i).cells_colors(cells(end), :) = ...
            seq.frames(i).cells_colors(cells(end), :) + get_cluster_colors(double(seq.inv_edges_map(i, j)));
        cells_count(i, cells(end)) = cells_count(i, cells(end)) + 1;
    end
    seq.frames(i).cells_alphas(:) = 0.2;
%     seq.frames(i).cells_colors(cells_count(i, :) > 0, :) = ...
%         seq.frames(i).cells_colors(cells_count(i, :) > 0, 1) ./ ...
%         repmat(nonzeros(cells_count(i, :), [1 3]));
end
% for i = orbit
%     seq.frames(i).cells = unique(seq.frames(i).cells);
% end
new_cells_count = zeros(size(seq.cells_map));
new_cells_colors = zeros([size(seq.cells_map) 3]);
%max_t = max([seq.frames(orbit).t]);
max_t = max(orbit);
min_t = min(orbit);
for i = orbit
    if sum(cells_count(i, :) > 0)
        for j = max(min_t, i - window_size):min(max_t, i + window_size)
            new_cells_count(j, seq.inv_cells_map(i, find(cells_count(i, :)))) = ...
                new_cells_count(j, seq.inv_cells_map(i, find(cells_count(i, :)))) + nonzeros(cells_count(i, :))';
            new_cells_colors(j, seq.inv_cells_map(i, find(cells_count(i, :))), :) = ...
                new_cells_colors(j, seq.inv_cells_map(i, find(cells_count(i, :))), :) ...
                + reshape(seq.frames(i).cells_colors(find(cells_count(i, :)), :), ...
                [1 size(seq.frames(i).cells_colors(find(cells_count(i, :)), :))]);
        end
    end
end
for i = orbit
    seq.frames(i).cells = nonzeros(seq.cells_map(i, new_cells_count(i, :)>0));
    seq.frames(i).cells_colors(seq.frames(i).cells, :) = ...
        new_cells_colors(i, seq.inv_cells_map(i, seq.frames(i).cells), :) ./ ...
        repmat(new_cells_count(i, seq.inv_cells_map(i, seq.frames(i).cells)), [1 1 3]);
end


if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
    for i = orbit
        seq.frames(i).cells = intersect(seq.frames(i).cells, old_cells{i}, 'legacy');
    end
end
    
update_frame(handles)




% --------------------------------------------------------------------
function edges_invert_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edges_invert_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq

if strcmp(get(handles.static_edges, 'checked'), 'on')
    orbit = get_orbit_frames(handles);
    for i = orbit
        edges_ind = true(1, length(seq.frames(i).cellgeom.edges(:,1)));
        edges = seq.frames(i).edges;
        edges_ind(nonzeros(edges)) = 0;
        seq.frames(i).edges = find(edges_ind);
    end
    update_frame(handles)
else
    img_num = str2double(get(handles.frame_number, 'String'));
    z_num = str2double(get(handles.slice_number, 'String'));
    i = seq.frames_num(img_num, z_num);  
    edges_ind = true(1, length(seq.frames(i).cellgeom.edges(:,1)));
    edges = seq.frames(i).edges;
    edges_ind(nonzeros(edges)) = 0;
    edges = find(edges_ind);
    seq.frames(i).edges = edges;
    setappdata(handles.figure1, 'first_time', 1);

    user_cells = getappdata(handles.figure1, 'user_cells');
    user_cells_colors = getappdata(handles.figure1, 'user_cells_colors');
    user_cells_alphas = getappdata(handles.figure1, 'user_cells_alphas');

    touched_edges = getappdata(handles.figure1, 'touched_edges');
    touched_edges(:) = 1;
    setappdata(handles.figure1, 'touched_edges', touched_edges);
    call_update_orbit(handles, user_cells, user_cells_colors, ...
    user_cells_alphas, edges)


end


% --------------------------------------------------------------------
function export_trajectories_menu_Callback(hObject, eventdata, handles)
% hObject    handle to export_trajectories_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

orbit = get_orbit_frames(handles);
global seq trajec
cells = seq.inv_cells_map(orbit(1), nonzeros(seq.frames(orbit(1)).cells));
trajec = zeros([length(cells) 2 length(orbit)]);

for i = 1:length(orbit)
    local_cells = seq.cells_map(orbit(i), cells);
    trajec(:, :, i) = seq.frames(orbit(i)).cellgeom.circles(local_cells, [2 1]);
    trajec(:, 1, i) = trajec(:, 1, i) - mean(trajec(:, 1, i));
    trajec(:, 2, i) = trajec(:, 2, i) - mean(trajec(:, 2, i));
end


% --------------------------------------------------------------------
function secret_option_Callback(hObject, eventdata, handles)
% hObject    handle to secret_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off');
else
    set(hObject, 'checked', 'on');
end


% --------------------------------------------------------------------
function intersect_along_time_Callback(hObject, eventdata, handles)
% hObject    handle to intersect_along_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
all_cells = true(1, length(seq.cells_map(1, :)));
cells_ind = all_cells;
orbit = get_orbit_frames(handles);
for i= orbit
    cells = seq.inv_cells_map(i, seq.frames(i).cells);
    cells_ind(:) = false;
    cells_ind(cells) = true;
    all_cells = all_cells & cells_ind;
end
for i= orbit
    seq.frames(i).cells = seq.cells_map(i, all_cells);
end
update_frame(handles)



return
draw_changes(handles); %obsolete color by neighbor changes

% --------------------------------------------------------------------
function jit_cells_menu_Callback(hObject, eventdata, handles)
% hObject    handle to jit_cells_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Jittery cells
area_thresh = inputdlg('Find cells that change in area (in percents) by more than:', '', 1, {'50'})
area_thresh = str2num(area_thresh{1});
if isempty(area_thresh)
    return
end
find_jittery_cells(handles, area_thresh/100)

update_frame(handles)


return

%% OBSOLETE
%function jit_cells_menu_Callback(hObject, eventdata, handles)
%%% this calls the window that highlights cells with a specific value %%% 
dc_data = getappdata(handles.figure1, 'detect_changes');
min_max = getappdata(handles.figure1, 'draw_change_min_max');
h = select_integral_value;
hh = guihandles(h);
set(hh.slider1, 'min', min_max(1), 'max', min_max(2), ...
    'sliderstep', [1/(min_max(2) - min_max(1)) 2/(min_max(2) - min_max(1))], ...
    'value', min_max(1)); 
set(hh. edit1, 'string', '0');
setappdata(h, 'calling_window', handles.figure1);
setappdata(h, 'function_to_call', @(x) high_cells_change(handles, x));


% --------------------------------------------------------------------
function boundary_cells_menu_Callback(hObject, eventdata, handles)
% hObject    handle to boundary_cells_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

c = get(handles.user_select_c, 'BackgroundColor');
global seq
orbit = get_orbit_frames(handles);
for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);
    cells = find(seq.frames(i).cellgeom.border_cells);
    seq.frames(i).cells = cells;
    seq.frames(i).cells_colors(cells, 1) = c(1);
    seq.frames(i).cells_colors(cells, 2) = c(2);
    seq.frames(i).cells_colors(cells, 3) = c(3);
    

%     new_map = new_edgecellmap(seq.frames(i).cellgeom);
%     border_cells = false(1, length(seq.cells_map(1,:)));
%     border_cells(seq.inv_cells_map(i, new_map(isnan(new_map(:, 2)), 1))) = true;
%     new_map = new_map(all(~isnan(new_map), 2), :);
%     nmap = false(length(seq.frames(i).cellgeom.circles(:,1)));
%     nmap(sub2ind(size(nmap), new_map(:, 1), new_map(:, 2))) = 1;
%     nmap = nmap | nmap';
%     seq.frames(i).cells_colors(:) = 0;
%     seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 1) = 2*c(1) - 1;
%     seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 2) = 2*c(2) - 1;
%     seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 3) = 2*c(3) - 1;
%     border_cells(seq.inv_cells_map(i, any(nmap(seq.cells_map(i, border_cells), :)))) = 1;
%     seq.frames(i).cells = seq.cells_map(i, border_cells);
%     seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 1) = ...
%         seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 1) + 1 - c(1);
%     seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 2) = ...
%         seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 2) + 1 - c(2);
%     seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 3) = ...
%         seq.frames(i).cells_colors(seq.cells_map(i, border_cells), 3) + 1 - c(3);
end
update_frame(handles);

function find_jittery_edges(handles, len_thresh)
if nargin < 2 || isempty(len_thresh)
    len_thresh = 5;
end
global seq
orbit = get_orbit_frames(handles);
g_lengths = zeros(size(seq.edges_map));
for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);
    all_edges = nonzeros(seq.inv_edges_map(i, :));
    edges_len = edges_len_from_geom(seq.frames(i).cellgeom);
    g_lengths(i, nonzeros(seq.inv_edges_map(i, :))) = edges_len(find(seq.inv_edges_map(i, :)));
end

poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');


for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);

    
    all_edges = nonzeros(seq.inv_edges_map(i, :));
    n_edges = false(size(seq.edges_map(i, all_edges)));
    p_edges = false(size(seq.edges_map(i, all_edges)));

    n = seq.frames(i).next_frame;
    if ~isempty(n)
        n_edges = abs(g_lengths(i, all_edges) - g_lengths(n, all_edges)) > len_thresh;
    end
    p = seq.frames(i).prev_frame; 
    if ~isempty(p)
        p_edges = abs(g_lengths(i, all_edges) - g_lengths(p, all_edges)) > len_thresh;
    end
    

    fe = full(seq.edges_map(i, all_edges(p_edges | n_edges)));

    [dummy poly_ind] = min(abs(i - poly_frame_ind));
    if ~isempty(poly_ind)
        x = poly_seq(poly_ind).x; 
        y = poly_seq(poly_ind).y;
        fe = highlight_edges_inside_poly(nonzeros(fe), x, y, seq.frames(i).cellgeom);
    end
    seq.frames(i).edges = fe;
end

function edges = highlight_edges_inside_poly(edges, x, y, geom);

edges1 = inpolygon(geom.nodes(geom.edges(edges,1), 1), ...
    geom.nodes(geom.edges(edges, 1), 2), x, y);

edges2 = inpolygon(geom.nodes(geom.edges(edges,2), 1), ...
    geom.nodes(geom.edges(edges, 2), 2), x, y);

if islogical(edges)
    edges = find(edges);
    edges = edges(edges1 | edges2);
else
    edges = edges(edges1 | edges2);
% if nargin > 5 && ~isempty(limit_to)
%     edges = edges & limit_to;
% end
end

function find_jittery_cells(handles, area_thresh)
if nargin <2 || isempty(area_thresh)
    area_thresh = 0.5;
end

c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');

global seq
orbit = get_orbit_frames(handles);
g_areas = zeros(size(seq.cells_map));
for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);
    all_cells = nonzeros(seq.inv_cells_map(i, :));
    geom = seq.frames(i).cellgeom;

    faces_for_area = faces2ffa(geom.faces(find(seq.inv_cells_map(i, :)), :));
    ny = geom.nodes(:, 1);
    nx = geom.nodes(:, 2);
    x = nx(faces_for_area);
    y = ny(faces_for_area);
    areas = polyarea(x, y, 2);
    g_areas(i, nonzeros(seq.inv_cells_map(i, :))) = areas;
end

for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);
   
    all_cells = nonzeros(seq.inv_cells_map(i, :));
    n_cells = false(size(seq.cells_map(i, all_cells)));
    p_cells = false(size(seq.cells_map(i, all_cells)));

    n = seq.frames(i).next_frame;
    if ~isempty(n)
        n_cells = abs(g_areas(i, all_cells) - g_areas(n, all_cells)) > (g_areas(i, all_cells) * area_thresh);
    end
    p = seq.frames(i).prev_frame; 
    if ~isempty(p)
        p_cells = abs(g_areas(i, all_cells) - g_areas(p, all_cells)) > (g_areas(i, all_cells) * area_thresh);
    end
    fc = full(seq.cells_map(i, all_cells(p_cells | n_cells)));
    seq.frames(i).cells = fc;
    seq.frames(i).cells_colors(fc, 1) = c(1);
    seq.frames(i).cells_colors(fc, 2) = c(2);
    seq.frames(i).cells_colors(fc, 3) = c(3);
    seq.frames(i).cells_alphas(fc) = a;
end

function find_untracked_cells(handles)
c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');

global seq
orbit = get_orbit_frames(handles);

if length(seq.frames) >1 % don't do it for a single image, only a movie
    for frm_cnt = 1:length(orbit)
        i = orbit(frm_cnt);
        all_cells = nonzeros(seq.inv_cells_map(i, :));
        n = seq.frames(i).next_frame;
        n_cells = false(size(seq.cells_map(i, all_cells)));
        p_cells = false(size(seq.cells_map(i, all_cells)));
        if ~isempty(n)
            n_cells = full(seq.cells_map(n, all_cells)) == 0;
        end
        p = seq.frames(i).prev_frame; 
        if ~isempty(p)
            p_cells = full(seq.cells_map(p, all_cells)) == 0;
        end
        fc = full(seq.cells_map(i, all_cells(p_cells | n_cells)));
        if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
            temp_fc = false(1, length(seq.frames(i).cellgeom.circles(:, 1)));
            temp_fc2 = temp_fc;
            temp_fc(fc) = true;
            temp_fc2(seq.frames(i).cells) = true;
            fc = find(temp_fc & temp_fc2);
        end

        seq.frames(i).cells = fc;
        seq.frames(i).cells_colors(fc, 1) = c(1);
        seq.frames(i).cells_colors(fc, 2) = c(2);
        seq.frames(i).cells_colors(fc, 3) = c(3);
        seq.frames(i).cells_alphas(fc) = a;
    end
end
update_frame(handles);

function find_3_celled_edges(handles)
c = get(handles.user_select_c, 'BackgroundColor');
global seq
orbit = get_orbit_frames(handles);
for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);
    [new_map fc] = new_edgecellmap(seq.frames(i).cellgeom);
    if ~isempty(fc)
        disp(['frame ' num2str(i)]);
    end
    seq.frames(i).cells = fc;
    seq.frames(i).cells_colors(fc, 1) = c(1);
    seq.frames(i).cells_colors(fc, 2) = c(2);
    seq.frames(i).cells_colors(fc, 3) = c(3);
    seq.frames(i).cells_alphas(fc) = 0.6;
end
update_frame(handles);


% --------------------------------------------------------------------
function faulty_cells_menu_Callback(hObject, eventdata, handles)
% hObject    handle to faulty_cells_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%find_3_celled_edges(handles)

find_untracked_cells(handles)

% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function show_nghbrs_menu_Callback(hObject, eventdata, handles)
% hObject    handle to show_nghbrs_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

show_ngbhrs(handles)


% --------------------------------------------------------------------
function click_nghbrs_menu_Callback(hObject, eventdata, handles)
% hObject    handle to click_nghbrs_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if get(handles.newfig_check, 'value')
    figure(getappdata(handles.figure1, 'drawingfig'));
end

%seq = getappdata(handles.figure1, 'seq');
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
cellgeom = seq.frames(frame_num).cellgeom;


states = disable_all_controls(handles);
[y,x, button] = ginput(1);
enable_all_controls(handles, states);


while ~isempty(x) & button ~= 27;
    I1 = cell_from_pos(y, x, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end
    glob_cell = seq.inv_cells_map(frame_num, I1);
    show_nghbrs_change_per_cell(handles, glob_cell, button == 3)
    states = disable_all_controls(handles);
    [y,x, button] = ginput(1);
    enable_all_controls(handles, states);

end

function show_nghbrs_change_per_cell(handles, glob_cell, remove)
global seq
dc_data = getappdata(handles.figure1, 'detect_changes');
glob_lost = dc_data.lost{glob_cell};
glob_found = dc_data.found{glob_cell};
glob_lost_n_found = unique([glob_found glob_lost], 'legacy');
orbit = get_orbit_frames(handles);
for i = orbit
    lost = nonzeros(seq.cells_map(i, glob_lost));
    found = nonzeros(seq.cells_map(i, glob_found));
    lost_n_found = nonzeros(seq.cells_map(i, glob_lost_n_found))';
    cell = nonzeros(seq.cells_map(i, glob_cell));
    if ~strcmp(get(handles.secret_option, 'checked'), 'on')
        seq.frames(i).cells_colors(:) = 0;
    end
    seq.frames(i).cells_alphas(:) = 0.3;
    seq.frames(i).cells_colors(lost, :) = ...
        seq.frames(i).cells_colors(lost, :) + ...
        (1 - 2*remove) * repmat([1 0 0], [length(lost) 1]);
    seq.frames(i).cells_colors(found, :) = ...
        seq.frames(i).cells_colors(found, :) + ...
        (1 - 2*remove) * repmat([0 0 1], [length(found) 1]);
    if ~isempty(cell)
        seq.frames(i).cells_colors(cell, :) = ...
            seq.frames(i).cells_colors(cell, :) + (1 - 2*remove) * [0 1 0];
    end
    seq.frames(i).cells_colors(:) = min(1, max(0, seq.frames(i).cells_colors(:)));
    if strcmp(get(handles.secret_option, 'checked'), 'on')
        seq.frames(i).cells = find(any(seq.frames(i).cells_colors, 2));
    else
        seq.frames(i).cells = [cell lost_n_found];
    end

end
update_frame(handles);


% --------------------------------------------------------------------
function readonly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to readonly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
    global seq
    if seq.changed
        seq.changed_and_read_only = true;
    end
end



% --------------------------------------------------------------------
function ex_compucell_Callback(hObject, eventdata, handles)
% hObject    handle to ex_compucell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
t_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
i = seq.frames_num(t_num, z_num);  
cells = seq.frames(i).cells;
types_temp = round(seq.frames(i).cells_colors(cells, :)*256);
types = types_temp(:, 1) + 256*types_temp(:, 2) + types_temp(:, 3)*65536;
[dummy ix types] = unique(types, 'legacy');
directory = seq.directory;
filename = seq.frames(i).img_file;
img = double(imread(fullfile(directory, filename)));
old_dir = pwd;
cd('..')
[filename pathname] = uiputfile('*.pif');
if filename == 0 & pathname == 0
    return
end
suc =  export_to_compucell(seq.frames(i).cellgeom, cells, types, [], [], img, ...
    fullfile(pathname, filename));
    
if suc
    h = msgbox('Done.', 'modal');
    waitfor(h)
end
cd(old_dir)


% --------------------------------------------------------------------
function do_some_menu_Callback(hObject, eventdata, handles)
% hObject    handle to do_some_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



update_frame(handles)
return

global seq
cc = zeros(1, length(seq.cells_map(1, :)));
orbit = get_orbit_frames(handles);
for frm_num = orbit
    cc(seq.inv_cells_map(frm_num, seq.frames(frm_num).cells)) = ...
        cc(seq.inv_cells_map(frm_num, seq.frames(frm_num).cells)) + 1;
end
cells = find(cc == length(orbit));
for frm_num = orbit
    seq.frames(frm_num).cells = seq.cells_map(frm_num, cells);
end
update_frame(handles)
return

global seq
for frame_num = get_orbit_frames(handles)
    for clst_cnt = 1:length(seq.frames(frame_num).clusters_data)
        if length(seq.frames(frame_num).clusters_data) == 1
            seq.frames(frame_num).clusters_data = ...
                build_cluster_data(seq.frames(frame_num).clusters_data(clst_cnt).cells, ...
                seq.frames(frame_num).cellgeom, 1);
        else                
            seq.frames(frame_num).clusters_data(clst_cnt) = ...
                build_cluster_data(seq.frames(frame_num).clusters_data(clst_cnt).cells, ...
                seq.frames(frame_num).cellgeom, 1);
        end
    end
end
return

% --- Executes on button press in node2edge.
function node2edge_Callback(hObject, eventdata, handles)
% hObject    handle to node2edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'node2edge');

function states = disable_all_controls(handles)
zoom off
pan off
set(handles.zoom_btn, 'Value', 0)
set(handles.pan_btn, 'Value', 0)
states = [];
names = fieldnames(handles);
for i = 1:length(names)
    ctrl = getfield(handles, names{i});
    if isprop(ctrl, 'Enable') & ctrl ~= handles.figure1 ...
            & ctrl ~= handles.axes1
        states.(names{i}) = get(ctrl, 'Enable');
        set(ctrl, 'Enable', 'Off');
    end
end
set(handles.dummy_for_focus, 'Enable', 'on');
set(handles.frame_info, 'Enable', 'on');
uicontrol(handles.dummy_for_focus);
setappdata(handles.figure1, 'disabled_mode', 1);


function enable_all_controls(handles, states)
names = fieldnames(states);
for i = 1:length(names)
    ctrl = names{i};
    if isprop(handles.(ctrl), 'Enable')
        set(handles.(ctrl), 'Enable', states.(ctrl));
    end
end
setappdata(handles.figure1, 'disabled_mode', 0);

% --------------------------------------------------------------------
function all_cells_menu_Callback(hObject, eventdata, handles)
% hObject    handle to all_cells_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
cellgeom = seq.frames(frame_num).cellgeom;
user_lighted = 1:length(cellgeom.circles(:, 1));
touched_cells = user_lighted;
c = get(handles.user_select_c, 'BackgroundColor');
user_cells_colors(user_lighted,:) = repmat(c, [length(user_lighted) ,1]);
user_cells_alphas(user_lighted, 1) = get(handles.user_select_c, 'userdata');


seq.frames(frame_num).cells = user_lighted;
seq.frames(frame_num).cells_colors = user_cells_colors;
seq.frames(frame_num).cells_alphas = user_cells_alphas;
setappdata(handles.figure1, 'first_time', 1);
setappdata(handles.figure1, 'touched_cells', touched_cells);

edges = getappdata(handles.figure1, 'user_edges');

call_update_orbit(handles, user_lighted, user_cells_colors, ...
    user_cells_alphas, edges)


% --------------------------------------------------------------------
function set_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to set_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fac = get(handles.user_select_c, 'userData');
fac = inputdlg('Set alpha factor between 0 and 1 (0 = transparent, 1 = opaque)', '',1, {num2str(fac)});
fac = str2double(fac);
if isempty(fac) || ~isfinite(fac) || ~isnumeric(fac)
    return
end
fac = real(fac);
set(handles.user_select_c, 'userData', fac);
global seq
for i = 1:length(seq.frames)
    seq.frames(i).cells_alphas(:) = fac;
end
update_frame(handles)


% --------------------------------------------------------------------
function new_find_clusters_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_find_clusters_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%% NEW VERSION. based on tracking info %%%%%%%%%%%%%%%
orbit = get_orbit_frames(handles);  %currently orbit has to be all frames
global seq
NO_4_FROM_START = false;
script_create_light_data
script_track_nodes
script_find_num_shrank_edges

color_clusters(orbit, 'cluster_tracking_b', 'cluster_tracking_f', ...
    'ghost_clusters');
set_gui_clusters(handles, 1);
update_frame(handles, str2double(get(handles.frame_number, 'string')), -get(handles.slice_slider, 'Value'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count_edges_rosettes
clear seq

clear nodelist2 temp_node_mult ans full_clusters_cells d done_nodes done_nodes2
clear nmap geom2 geom max_frame_cells min_frame_cells max_edge max_mult min_mult
setappdata(handles.figure1, 'temp_data_storage', data);
clear data
if length(dir('clusters_vars.mat'))
    delete('clusters_vars.mat');
end
save('clusters_vars');
data = getappdata(handles.figure1, 'temp_data_storage');
rmappdata(handles.figure1, 'temp_data_storage');
hist_sh = hist_shrinks(:, 1);
hist_sh(:, 2) = sum(hist_shrinks(:, 2:end), 2);
% global seq
num_selected_edges = sum(data.edges.selected > 0, 2);
mean_data.frac_edges_t1 = hist_sh(: , 1) ./ num_selected_edges ;
mean_data.frac_edges_rosettes = hist_sh(: , 2) ./ num_selected_edges ;

hist_sh = history(:, 1) ./ num_selected_edges;
hist_sh(:, 2) = sum(history(:, 2:end), 2) ./ num_selected_edges;
mean_data.frac_edges_t1_cumsum = cumsum(hist_sh(: , 1));
mean_data.frac_edges_rosettes_cumsum = cumsum(hist_sh(: , 2));

mean_data.t1_lifetimes = lifetimes(lifetimes(:, 2) == 4, 1);
mean_data.rosettes_lifetimes = lifetimes(lifetimes(:, 2) > 4, 1);

mean_data.frames_t = [seq.frames(orbit).t];
mean_data.frames_z = [seq.frames(orbit).z];


save('new_edges_data', 'mean_data');


% --------------------------------------------------------------------
function menu_area_changes_Callback(hObject, eventdata, handles)
% hObject    handle to menu_area_changes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
cells_area = track_cells_area();
vel_areas = vel_deriv(smoothen(double(cells_area), 3), 10);
v = sort(vel_areas(abs(vel_areas) > eps('single')));
bot100 = v(round(length(v)/1000));
top100 = v(end-round(length(v)/1000));
vel_areas(vel_areas>0) = vel_areas(vel_areas>0) * 128 / top100;
vel_areas(vel_areas<0) = vel_areas(vel_areas<0) * -128 / bot100;

a = autumn(256);
b = winter(256);
c = [a(1:128, :); [0 0 0]; flipud(b(1:128, :))];
for i = get_orbit_frames(handles)
    seq.frames(i).cells_alphas(find(seq.inv_cells_map(i, :))) = min(1, abs(vel_areas(i, nonzeros(seq.inv_cells_map(i, :)), 1))/10);
    seq.frames(i).cells_colors(find(seq.inv_cells_map(i, :)), :) = c(129 + max(-128, min(128, round(vel_areas(i, nonzeros(seq.inv_cells_map(i, :)))))), :);
    if ~strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
        seq.frames(i).cells = nonzeros(seq.cells_map(i, :));
    end
end
update_frame(handles);

function cells_area = track_cells_area()
global seq
cells_area = zeros(size(seq.cells_map));
for frm_num = 1:length(seq.cells_map(:, 1))
    geom = seq.frames(frm_num).cellgeom;
    fac = geom.faces;
    fac(isnan(fac)) = 0;
    ind = fac(:, 1) == 0;
    fac(ind, 1) = fac(ind, end);
    for i = 2:length(fac(1,:))
        ind = fac(:, i) == 0;
        fac(ind, i) = fac(ind, i - 1);
    end

    ind = fac(:, end) == 0;
    fac(ind, end) = fac(ind, 1);
    for i = (length(fac(1,:)) - 1):-1:1
        ind = fac(:, i) == 0;
        fac(ind, i) = fac(ind, i + 1);
    end
    x = geom.nodes(:, 1);
    y = geom.nodes(:, 2);
    
    ind = fac(:, 1) ~= 0;
    cells_area(frm_num, seq.inv_cells_map(frm_num, ind)) = polyarea(x(fac(ind, :)), y(fac(ind, :)), 2);    
end


function load_saved_polys(handles)
global seq
poly_filename = getappdata(handles.figure1,'poly_filename');
if isempty(poly_filename)
    poly_filename = 'poly_seq.mat';
end
if ~length(dir(char(poly_filename)))
    h = msgbox(['could not find ''',poly_filename,''' in current directory'], '', 'warn', 'modal');
    waitfor(h)
    return
end
s = load(poly_filename);

%%% Handle shifts to the starting frame
poly_frame_ind = s.poly_frame_ind;
if isfield(s,'t_min')
    t_min_old = s.t_min;
    t_min_new = seq.min_t;
    s.poly_frame_ind = poly_frame_ind - (t_min_new-t_min_old );
else
    display(['did not find the field, ''t_min'' in ',poly_filename]);
end

setappdata(handles.figure1, 'poly_seq', s.poly_seq);
setappdata(handles.figure1, 'poly_frame_ind', s.poly_frame_ind);
update_frame(handles)

%s.poly_frame_ind(i) = the frame in which poly i was drawn.
%highlight_by_poly_seq(handles, s.poly_seq, s.poly_frame_ind);

function highlight_by_poly_seq(handles, poly_seq, poly_frame_ind)
%poly_frame_ind(i) = the frame in which poly i was drawn.
%poly_ind(i) = index of poly to be used in frame i
orbit = get_orbit_frames(handles);
frame_ind = orbit;
for i = orbit
    %assuming frame numbers are sorted. the poly/frame with the closest t and z
    %indices should be used, not the one with the closest frame index. 
    [dummy poly_ind(i)] = min(abs(i - poly_frame_ind));
end


c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');
global seq
for i = orbit
    x = poly_seq(poly_ind(i)).x; 
    y = poly_seq(poly_ind(i)).y;
    if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
        limit_to = false(length(seq.frames(i).cellgeom.circles(:, 1)), 1);
        limit_to(seq.frames(i).cells) = true;
    else
        limit_to = [];
    end
    highlight_inside_poly(x, y, i, c, a, limit_to);
end
update_frame(handles);

function highlight_inside_poly(x, y, i, c, a, limit_to)
global seq
new_selection = cells_in_poly(seq.frames(i).cellgeom, y, x);
if nargin > 5 && ~isempty(limit_to)
    new_selection = new_selection & limit_to;
end
    
seq.frames(i).cells = find(new_selection);
seq.frames(i).cells_colors(seq.frames(i).cells, 1) = c(1);
seq.frames(i).cells_colors(seq.frames(i).cells, 2) = c(2);
seq.frames(i).cells_colors(seq.frames(i).cells, 3) = c(3);
seq.frames(i).cells_alphas(seq.frames(i).cells, 1) = a;


function add_poly_to_poly_seq(handles, poly, i)

poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');

[poly_seq poly_frame_ind] = add_poly_to_poly_seq_inter(poly_seq, poly_frame_ind, poly, i);

setappdata(handles.figure1, 'poly_seq', poly_seq);
setappdata(handles.figure1, 'poly_frame_ind', poly_frame_ind);

function draw_and_add_poly_to_poly_seq(handles)
global seq
states = disable_all_controls(handles);
[x y] = get_poly_from_user_input;
enable_all_controls(handles, states);
if isempty(x)
    return
end
poly.x = x;
poly.y = y;

t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(t, z);

add_poly_to_poly_seq(handles, poly, frame_num);

c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');
highlight_inside_poly(poly.x, poly.y, frame_num, c, a);

update_frame(handles);

% --------------------------------------------------------------------
function save_poly_seq_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_poly_seq_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Save poly sequence
global seq

poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
poly_filename = getappdata(handles.figure1,'poly_filename');

% filename = 'poly_seq.mat';
% filename = 'cephalic.mat';
% if length(dir(filename));
%     filename = 'ventral.mat';
% end

%%% ISSUE
%%% when moving the t_min to the left (to a lower value) 
%%% in the tracking_options file, this disrupts the indexing of the
%%% poly_seq in time
%%% FIX
%%% record the t_min when saving and account for difference when loading

orbit = get_orbit_frames(handles);
abs_poly_frame_ind = [seq.frames(orbit).t];
t_min = seq.min_t;

save(poly_filename, 'poly_seq', 'poly_frame_ind','t_min');

function save_changed_frames(handles)
global seq
success = false;
num_frames_saved = 0;
for i = 1:length(seq.frames)
    if isfield(seq.frames(i), 'changed') && seq.frames(i).changed  && ...
        isfield(seq.frames(i), 'saved') && ~seq.frames(i).saved

        setappdata(handles.figure1, 'update_celldata', 1);
        success = update_celldata_tracking(handles, i);
        if ~success
            break
        end
        num_frames_saved = num_frames_saved + 1;
    end
end
if success %failure is handled within update_celldata_tracking
    msg = 'Saved %d frames.';
    msg = sprintf(msg, num_frames_saved);
    h = msgbox(msg,'', 'help');
    waitfor(h);
end

% --------------------------------------------------------------------
function save_geom_files_Callback(hObject, eventdata, handles)
% hObject    handle to save_geom_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Save geometry changes
states = disable_all_controls(handles);
pause(0.1)    

old_readonly = get(handles.readonly_menu, 'Checked');
set(handles.readonly_menu, 'Checked', 'off')
save_changed_frames(handles)
set(handles.readonly_menu, 'Checked', old_readonly)

enable_all_controls(handles, states);

% --- Executes on button press in pan_btn.
function pan_btn_Callback(hObject, eventdata, handles)
% hObject    handle to pan_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pan_btn
zoom off
set(handles.zoom_btn, 'Value', 0)

if get(hObject,'Value')
    pan on
else
    pan off
end




% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%select edges or cells for browse data
if ~isappdata(handles.figure1, 'browse_data_window') 
    return
end
browse_data_win = getappdata(handles.figure1, 'browse_data_window');
if ~ishandle(browse_data_win)
    return
end

global seq
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(t, z);
geom = seq.frames(frame_num).cellgeom;

items_type = getappdata(browse_data_win, 'items_type');
states = disable_all_controls(handles);
[y,x, button] = ginput(1);
enable_all_controls(handles, states);
while ~(button == 13 || button == 27 || button == 3)
    switch items_type
        case 'cells'
            %select cell
            item = cell_from_pos(y, x, geom);
            item = seq.inv_cells_map(frame_num, item);
            if item == 0
                h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
                waitfor(h);
                return
            end
            err_msg = 'No data for this cell in browse_data';
        case 'edges'
            item = nearest_edge(geom, x, y);
            item = seq.inv_edges_map(frame_num, item);
            err_msg = 'No data for this edge in browse_data';
            if button == 2 
%                 zoom_and_follow_edge(handles, item)
            end
    end
    %convert global item index to browse_data index
    bd_map = getappdata(browse_data_win, 'inverse_list');
    if item > length(bd_map)
        item = 0;
    else
        item = bd_map(item);
    end
    

    %send info to browse_data
    if item == 0
        h = msgbox(err_msg, '', 'none', 'modal');
        waitfor(h);
        states = disable_all_controls(handles);
        [y,x, button] = ginput(1);
        enable_all_controls(handles, states);        
        continue
    end
    bd_handles = guihandles(browse_data_win);
    update_bd_axis(bd_handles, item, true);
    states = disable_all_controls(handles);
    update_frame(handles);
    [y,x, button] = ginput(1);
    enable_all_controls(handles, states);
end


return

global seq
orbit = get_orbit_frames(handles);
cmap = hot(256);
for i= orbit
    [dummy full_data]= static_data_function(seq.frames(i).cellgeom, seq.frames(i).cells, 1);
    vals = full_data.circ;
%     vals = vals - min(vals);
%     vals = vals / max(vals);
    vals = round(1 + vals);
    vals = min(vals, 256);
    seq.frames(i).cells_colors(seq.frames(i).cells, :) = cmap(vals, :);
    seq.frames(i).cells_alphas(seq.frames(i).cells) = 0.8;
end
% return


return

global seq
t = str2double(get(handles.frame_number, 'string'));
z = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(t, z);


[y,x, button] = ginput(1);
global dror
clusters = dror;
while ~(isempty(x) | button == 27 | button == 3) 
    edge = nearest_edge(seq.frames(frame_num).cellgeom, x, y);
    gl_edge = seq.inv_edges_map(frame_num, edge);
    none_found = true;
    for j = 1:length(clusters)
        if ismember(gl_edge, clusters(j).edges)
            seq = color_by_clusters(seq, clusters, j);
            for i = 1:length(seq.frames)
                seq.frames(i).edges = nonzeros(seq.edges_map(i, clusters(j).all_edges));
                seq.frames(i).edges2 = nonzeros(seq.edges_map(i, clusters(j).edges));
            end
            update_frame(handles);
            none_found = false;
            break
        end
    end
    if none_found
        for i = 1:length(seq.frames)
            seq.frames(i).cells = [];
        end
        update_frame(handles)
    end
    gl_edge
    global data_de misc_de
%     figure;
%     plot(data_de.edges.len(:, gl_edge));
%     hold on
%     plot(deriv(data_de.edges.len(:, gl_edge)*10), 'r');
%     max(data_de.edges.len(data_de.edges.selected(:, gl_edge), gl_edge))
%     sum(data_de.edges.selected(:, gl_edge))
%     misc_de.sep_times(clusters(j).edges)
%     clusters(j).edges
%     break 
    [y,x, button] = ginput(1);
end

function draw_clusters(handles, forward)
global seq oriori
if isempty(oriori)
    return
end
clusters = oriori;
persistent ind
if isempty(ind)
    ind = -10;
end
if forward
    ind = ind + 1;
else
    ind = ind - 1;
end
if ind < 1 
    ind = length(clusters);
end
if ind > length(clusters)
    ind = 1;
end
seq = color_by_clusters(seq, clusters, ind);
update_frame(handles);



% --- Executes on button press in thick_edges_check.
function thick_edges_check_Callback(hObject, eventdata, handles)
% hObject    handle to thick_edges_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of thick_edges_check

update_frame(handles)


% --------------------------------------------------------------------
function jit_edges_menu_Callback(hObject, eventdata, handles)
% hObject    handle to jit_edges_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Jittery edges

len_thresh = inputdlg('Find edges that change in length (in pixels) more than:', '', 1, {'5'})
len_thresh = str2num(len_thresh{1});
if isempty(len_thresh)
    return
end
find_jittery_edges(handles, len_thresh)
update_frame(handles)





% --------------------------------------------------------------------
function edit_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edit_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Edit poly

%get the existing poly for the current frame
global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
poly = get_poly_for_frame(frame_num, poly_frame_ind, poly_seq);

if isempty(poly)
    draw_and_add_poly_to_poly_seq(handles);
    return
end

%Interactively edit poly
poly = edit_poly(handles, poly);

%Update poly list
add_poly_to_poly_seq(handles, poly, frame_num);

%highlight by poly
c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');
highlight_inside_poly(poly.x, poly.y, frame_num, c, a);

%Redraw image
update_frame(handles);

function poly = edit_poly(handles, poly);
%set mode to hide all
hide = get(handles.hide, 'value');

set(handles.hide, 'value', 1);

%redraw image
update_frame(handles);

%edit poly
states = disable_all_controls(handles);
poly = edit_poly_inter(poly, handles.frame_info);
enable_all_controls(handles, states);

%set hide mode to old hide mode
set(handles.hide, 'value', hide);






% --------------------------------------------------------------------
function delete_poly_menu_Callback(hObject, eventdata, handles)
% hObject    handle to delete_poly_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Delete poly

poly_seq = getappdata(handles.figure1, 'poly_seq');
poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');

global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
[poly_seq poly_frame_ind suc] = delete_poly_from_seq(poly_seq, poly_frame_ind, frame_num);

if suc
    setappdata(handles.figure1, 'poly_seq', poly_seq);
    setappdata(handles.figure1, 'poly_frame_ind', poly_frame_ind);
    update_frame(handles)
else
    msg = 'No polygon found. Polygons can only be deleted from key frames (blue polygons).';
    h = msgbox(msg, '', 'warn', 'modal');
end



function dummy_for_focus_Callback(hObject, eventdata, handles)
% hObject    handle to dummy_for_focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dummy_for_focus as text
%        str2double(get(hObject,'String')) returns contents of dummy_for_focus as a double






% --- Executes on button press in channel3.
function channel3_Callback(hObject, eventdata, handles)
% hObject    handle to channel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel3
update_frame(handles)

% --- Executes on button press in channel1.
function channel1_Callback(hObject, eventdata, handles)
% hObject    handle to channel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel1
update_frame(handles)

% --- Executes on button press in channel2.
function channel2_Callback(hObject, eventdata, handles)
% hObject    handle to channel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_frame(handles)

% Hint: get(hObject,'Value') returns toggle state of channel2


% --------------------------------------------------------------------
function channel2_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_channel(handles, 2)

function load_channel(handles, ch)
[filename, pathname] = uigetfile('*.tif');
if isequal(filename,0) &&  isequal(pathname,0)
    return
end
load_channel_tracking(handles, ch, filename, pathname);
set_multi_channel(handles, 1)

% --------------------------------------------------------------------
function channel3_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel3_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_channel(handles, 3)


function set_multi_channel(handles, multi)
set_multi_channel_tracking(handles, multi)
update_frame(handles)


% --------------------------------------------------------------------
function multi_channel_menu_Callback(hObject, eventdata, handles)
% hObject    handle to multi_channel_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off');
    set_multi_channel(handles, 0)
else
    set(hObject, 'checked', 'on');
    set_multi_channel(handles, 1)
end



% --------------------------------------------------------------------
function channel1_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_channel(handles, 1)



% --------------------------------------------------------------------
function show_edit_changes_menu_Callback(hObject, eventdata, handles)
% hObject    handle to show_edit_changes_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
else
    set(hObject, 'Checked', 'on')
end
update_frame(handles);

function update_info_msg(handles, msg, re)
persistent old_msg
if nargin < 2
    msg = '';
end
if nargin > 2 && re
    msg = old_msg;
else
    old_msg = get(handles.frame_info, 'string');
end
set(handles.frame_info, 'string', msg)



% --- Executes on button press in hole2cell.
function hole2cell_Callback(hObject, eventdata, handles)
% hObject    handle to hole2cell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hoLe 2 cell
edit_t(handles, 'hole2cell');


% --- Executes on button press in remove_cell.
function remove_cell_Callback(hObject, eventdata, handles)
% hObject    handle to remove_cell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 'Qill cell'
edit_t(handles, 'remove_cell');


% --- Executes on button press in delineate_cell_btn.
function delineate_cell_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delineate_cell_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_t(handles, 'delineate_cell');



% --------------------------------------------------------------------
function visualize_rosettes_Callback(hObject, eventdata, handles)
% hObject    handle to visualize_rosettes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function cells_for_elon_Callback(hObject, eventdata, handles)
% hObject    handle to cells_for_elon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);
cells = false(size(seq.cells_map(1, :)));
cells(seq.inv_cells_map(frame_num,nonzeros(seq.frames(frame_num).cells))) = true;
save cells_for_elon cells;


% --------------------------------------------------------------------
function cells_for_t1s_and_ros_Callback(hObject, eventdata, handles)
% hObject    handle to cells_for_t1s_and_ros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% select_cells_for_t1s_and_ros

orbit = get_orbit_frames(handles);
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

global seq
data = seq2data(seq);
cells_sel = sum(data.cells.selected(max(-shift_info,1):end,:))>frm_min;


for i= orbit
    tmp_cells = cells_sel & data.cells.selected(i,:);
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,tmp_cells));
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = 1;
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .2;
end

update_frame(handles)

ans_str = questdlg('Save Cells','Saving','Yes','No','Yes');

switch(ans_str)
    case 'Yes'
        cells = cells_sel;
        only_internal_t1_ros_cells = false;
        save cells_for_t1_ros cells only_internal_t1_ros_cells;
    case 'No'
        return
end



% --------------------------------------------------------------------
function save_cells_for_t1s_and_rosettes_Callback(hObject, eventdata, handles)
% hObject    handle to save_cells_for_t1s_and_rosettes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global seq
img_num = str2double(get(handles.frame_number, 'String'));
z_num = str2double(get(handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num); 
% cells = false(size(seq.cells_map(1, :)));
% cells(seq.inv_cells_map(frame_num,nonzeros(seq.frames(frame_num).cells))) = true;


cells =[];
orbit = get_orbit_frames(handles);
for i= orbit
    cells = union(cells,nonzeros(seq.inv_cells_map(i,seq.frames(i).cells)), 'legacy');
end
only_internal_t1_ros_cells = false;
save cells_for_t1_ros cells only_internal_t1_ros_cells;




% --------------------------------------------------------------------
function display_cells_Callback(hObject, eventdata, handles)
% hObject    handle to display_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_cells_for_elon_Callback(hObject, eventdata, handles)
% hObject    handle to load_cells_for_elon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global seq
load cells_for_elon

orbit = get_orbit_frames(handles);

for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,cells));
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = 1;
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .2;
end

update_frame(handles)


% --------------------------------------------------------------------
function display_rosettes_with_selected_cells_Callback(hObject, eventdata, handles)
% hObject    handle to display_rosettes_with_selected_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(whos('seq')) || isempty(whos('clusters')) || isempty(whos('data'))
global seq
if isempty(dir('analysis*'))
    errordlg('missing analysis');
    return
end
load('analysis', 'clusters', 'seq', 'data');
end
    load('cells_for_t1_ros');
    if length(cells) < length(data.cells.selected(1,:))
       cells_update = false(1,length(data.cells.selected(1, :)));
       cells_update(cells) = true;
       cells = cells_update;
    end
    all_cells = cells;
seq = update_seq_dir(seq);

ind_t1 = false(size(clusters));
ind_ros = ind_t1;

for i = 1:length(ind_t1);
    
%     if ~any(all_cells(clusters(i).cells))
    if length(clusters(i).cells) > 4
        ind_ros(i) = true;
    else
        ind_t1(i) = true;
    end
%     end
end

%%%%
% highlight all clusters at once
% seq = color_by_clusters(seq, clusters);
% % highlight all t1 clusters at once
% seq = color_by_clusters(seq, clusters, ind_t1);
% load_seq(seq); 
% highlight all rosettes clusters at once
seq = color_by_clusters(seq, clusters, ind_ros);
update_frame(handles)
%MAKE SURE quick_edit IS UNCHECKED UNDER TOOLS 
%IN THE commandsui WINDOW.

for i = 1:length(seq.frames)
    selected_but_not_clusters = setdiff(nonzeros(seq.cells_map(i,cells)),seq.frames(i).cells, 'legacy');
    seq.frames(i).cells  =nonzeros(seq.cells_map(i,cells));
    seq.frames(i).cells_colors(selected_but_not_clusters,3)  = 1;
    seq.frames(i).cells_alphas(selected_but_not_clusters,1)  = .2;
    
    
end

%%% only within ROI
orbit = get_orbit_frames(handles);
for i= orbit
    tmp_glob_cells = seq.inv_cells_map(i,seq.frames(i).cells);
    tmp_sel_cells = data.cells.selected(i,tmp_glob_cells);
    seq.frames(i).cells  = seq.frames(i).cells(tmp_sel_cells);
end


update_frame(handles)
return


% --------------------------------------------------------------------
function display_vert_edges_Callback(hObject, eventdata, handles)
% hObject    handle to display_vert_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if isempty(whos('seq')) || isempty(whos('clusters')) isempty(whos('data'))
% global seq
% if isempty(dir('analysis*'))
%     errordlg('missing analysis');
%     return
% end
% load('analysis', 'clusters', 'seq', 'data');
% end

global seq
load('analysis','data');
load('aligned_edges_info_linkage','v_linked','vertical_edges');

for i = 1:length(seq.frames)
    for j = intersect(find(any(vertical_edges)),find(data.edges.selected(i,:)), 'legacy')
    vertical_edges(i,j) = mean(vertical_edges(max(1,i-3):min(length(seq.frames),i+3),j))>0.3;
    end

%     selected_but_not_linked = setdiff(nonzeros(seq.cells_map(i,cells)),seq.frames(i).cells);
    seq.frames(i).edges  =nonzeros(seq.edges_map(i,find(vertical_edges(i,:))));
     
end
update_frame(handles)


% --------------------------------------------------------------------
function show_t_nodes_Callback(hObject, eventdata, handles)
% hObject    handle to show_t_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seq
 ptH = plot(cellgeom.nodes(:,2),cellgeom.nodes(:,1),'rx');


% --------------------------------------------------------------------
function show_high_ros_Callback(hObject, eventdata, handles)
% hObject    handle to show_high_ros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(whos('seq')) || isempty(whos('clusters')) || isempty(whos('data'))
global seq
if isempty(dir('analysis*'))
    errordlg('missing analysis');
    return
end
load('analysis', 'clusters', 'seq', 'data');
end
    load('cells_for_t1_ros');
    if length(cells) < length(data.cells.selected(1,:))
       cells_update = false(1,length(data.cells.selected(1, :)));
       cells_update(cells) = true;
       cells = cells_update;
    end
    all_cells = cells;
seq = update_seq_dir(seq);

ind_t1 = false(size(clusters));
ind_ros = ind_t1;

for i = 1:length(ind_t1);
    
%     if ~any(all_cells(clusters(i).cells))
    if length(clusters(i).cells) > 5
        ind_ros(i) = true;
    else
        ind_t1(i) = true;
    end
%     end
end

%%%%
% highlight all clusters at once
% seq = color_by_clusters(seq, clusters);
% % highlight all t1 clusters at once
% seq = color_by_clusters(seq, clusters, ind_t1);
% load_seq(seq); 
% highlight all rosettes clusters at once
seq = color_by_clusters(seq, clusters, ind_ros);
%%% only within ROI
orbit = get_orbit_frames(handles);
for i= orbit
    tmp_glob_cells = seq.inv_cells_map(i,seq.frames(i).cells);
    tmp_sel_cells = data.cells.selected(i,tmp_glob_cells);
    seq.frames(i).cells  = seq.frames(i).cells(tmp_sel_cells);
end
update_frame(handles)


% --------------------------------------------------------------------
function show_all_ros_Callback(hObject, eventdata, handles)
% hObject    handle to show_all_ros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(whos('seq')) || isempty(whos('clusters')) || isempty(whos('data'))
global seq
if isempty(dir('analysis*'))
    errordlg('missing analysis');
    return
end
load('analysis', 'clusters', 'seq', 'data');
end
    load('cells_for_t1_ros');
    if length(cells) < length(data.cells.selected(1,:))
       cells_update = false(1,length(data.cells.selected(1, :)));
       cells_update(cells) = true;
       cells = cells_update;
    end
    all_cells = cells;
seq = update_seq_dir(seq);

ind_t1 = false(size(clusters));
ind_ros = ind_t1;

for i = 1:length(ind_t1);
    
%     if ~any(all_cells(clusters(i).cells))
    if length(clusters(i).cells) > 4
        ind_ros(i) = true;
    else
        ind_t1(i) = true;
    end
%     end
end

%%%%
% highlight all clusters at once
% seq = color_by_clusters(seq, clusters);
% % highlight all t1 clusters at once
% seq = color_by_clusters(seq, clusters, ind_t1);
% load_seq(seq); 
% highlight all rosettes clusters at once
strs=char('Cell Partiality','Cluster Exclusive','Cluster Inclusive');
def=[1 0 0 ];
title='Partiality Choice';
partiality_choice = radiodlg(strs,title,def,true);
partiality_choice = find(partiality_choice)-1;

seq = color_by_clusters(seq, clusters, ind_ros, data, partiality_choice);

%%% only within ROI -- doing this in color by clusters now
% orbit = get_orbit_frames(handles);
% for i= orbit
%     tmp_glob_cells = seq.inv_cells_map(i,seq.frames(i).cells);
%     tmp_sel_cells = data.cells.selected(i,tmp_glob_cells);
%     seq.frames(i).cells  = seq.frames(i).cells(tmp_sel_cells);
% end

update_frame(handles)



% --------------------------------------------------------------------
function highlight_nonactive_Callback(hObject, eventdata, handles)
% hObject    handle to highlight_nonactive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




if isempty(whos('seq')) || isempty(whos('clusters')) || isempty(whos('data'))
global seq
if isempty(dir('analysis*'))
    errordlg('missing analysis');
    return
end
load('analysis', 'clusters', 'seq', 'data');
end
load cellsbyevent
for i = 1:length(seq.frames)
    seq.frames(i).cells = nonzeros(seq.cells_map(i,cellspertype.noevents));
    seq.frames(i).cells_colors(nonzeros(seq.cells_map(i,cellspertype.noevents)),3)  = 1;
    seq.frames(i).cells_alphas(nonzeros(seq.cells_map(i,cellspertype.noevents)),1)  = .2;
end

update_frame(handles)



% --------------------------------------------------------------------
function highlight_sixfive_inclusive_Callback(hObject, eventdata, handles)
% hObject    handle to highlight_sixfive_inclusive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(whos('seq')) || isempty(whos('clusters')) || isempty(whos('data'))
global seq
if isempty(dir('analysis*'))
    errordlg('missing analysis');
    return
end
load('analysis', 'clusters', 'seq', 'data');
end
load cellsbyevent
for i = 1:length(seq.frames)
    seq.frames(i).cells = nonzeros(seq.cells_map(i,cellspertype.fiveandsixplusrosette_inclusiveall));
    seq.frames(i).cells_colors(nonzeros(seq.cells_map(i,cellspertype.fiveandsixplusrosette_inclusiveall)),3)  = 1;
    seq.frames(i).cells_alphas(nonzeros(seq.cells_map(i,cellspertype.fiveandsixplusrosette_inclusiveall)),1)  = .2;
end

update_frame(handles)


% --------------------------------------------------------------------
function atleast_two_ros_Callback(hObject, eventdata, handles)
% hObject    handle to atleast_two_ros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(whos('seq')) || isempty(whos('clusters')) || isempty(whos('data'))
global seq
if isempty(dir('analysis*'))
    errordlg('missing analysis');
    return
end
load('analysis', 'clusters', 'seq', 'data');
end
load cellsbyevent
for i = 1:length(seq.frames)
    seq.frames(i).cells = nonzeros(seq.cells_map(i,cellspertype.anytworose));
    seq.frames(i).cells_colors(nonzeros(seq.cells_map(i,cellspertype.anytworose)),3)  = 1;
    seq.frames(i).cells_alphas(nonzeros(seq.cells_map(i,cellspertype.anytworose)),1)  = .2;
end

update_frame(handles)


% --------------------------------------------------------------------
function color_topology_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_topology_annotations(handles,seq,orbit);
return


function colorcells_for_colorpicker_Callback(handles)
orbit = get_orbit_frames(handles);
global seq
data = seq2data(seq);
seq  = extern_colorcells_for_colorpicker_Callback(handles,seq,orbit,data);
update_frame(handles);

function coloredges_for_colorpicker_Callback(handles)
orbit = get_orbit_frames(handles);
global seq
data = seq2data(seq);
seq  = extern_coloredges_for_colorpicker_Callback(handles,seq,orbit,data);
update_frame(handles);


% --------------------------------------------------------------------
function color_area_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
qstring = 'Apply Smoothing?';
title = 'Smooth Data';
str1 = 'Yes';
str2 = 'No';
str3 = 'Cancel';
default = str1;
btn = questdlg(qstring,title,str1,str2,str3,default);
smth_bool = false;
switch btn
    case 'Yes'
        smth_bool = true;
    case 'No'
        smth_bool = false;
    otherwise
        return
end
seq = extern_area_annotations(handles,seq,orbit,smth_bool);
update_frame(handles)


% --------------------------------------------------------------------
function area_deriv_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_area_deriv_annotations(handles,seq,orbit);
update_frame(handles);
return

% --------------------------------------------------------------------
function ngbrs_lost_static_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
data = seq2data(seq);
load topological_events_per_cell cells_lost_hist cells_to_anal
cells = cells_to_anal;

    min_lost = 0;
    max_lost = 4;
    
for i= orbit
	seq.frames(i).cells  = nonzeros(seq.cells_map(i,cells));
    takers = seq.cells_map(i,cells)~=0;
    numlost = cells_lost_hist(i,takers(:));
%     max_lost = max(max_lost,max(numlost));
%     min_lost = min(min_lost,min(numlost));
end

num_colors = (max_lost-min_lost+1);

% tailored colormap for a list of 6 different colors
% if num_colors == 6
% manyhsv = hsv(20);
% % evenshsv = manyhsv(2:2:end,:);
% evenshsv = manyhsv([1,4,8,12,15,20],:);
% evenshsv = evenshsv([end,1:end-1],:);
% custom_color_list = evenshsv;
% end

if num_colors == 5
manyhsv = hsv(20*4);
convnums = [1,16,29,49,61];
% evenshsv = manyhsv(2:2:end,:);
evenshsv = manyhsv(convnums,:);
% evenshsv = evenshsv([end,1:end-1],:);
custom_color_list = evenshsv;
end
% 
% custom_color_list = hsv((max_lost-min_lost+1));


if num_colors == 8
    % tailored colormap for a list of 8 different topologies
    manyhsv = cool(20);
    evenshsv = manyhsv(2:2:end,:);
    evenshsv = evenshsv([1,2,4,6:end],:);
    evenshsv = evenshsv([end,1:end-1],:);
    evenshsv = evenshsv([1:2,4:end,3],:);
    
    evenshsv(1,:) = [1 0 0];
    evenshsv(2,:) = [1 0.4 0];
    custom_color_list = evenshsv;
end

custom_color_list = custom_color_list(end:-1:1,:);

display(['colorrange = ',num2str((max_lost-min_lost+1))]);
display(['min lost = ',num2str(min_lost),' max lost = ',num2str(max_lost)]);

for i= orbit
    tmp_sel_cells = logical(cells.*data.cells.selected(i,:));
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,tmp_sel_cells));
    takers = logical((seq.cells_map(i,cells)~=0).*data.cells.selected(i,cells));   
    numlost = cells_lost_hist(end,takers(:));
    seq.frames(i).cells_colors(seq.frames(i).cells,:)  = custom_color_list(min(numlost,max_lost)+1,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .5;
end

update_frame(handles)


% --------------------------------------------------------------------
function lim_to_embryo_Callback(hObject, eventdata, handles)
% hObject    handle to lim_to_embryo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t = str2double(get(handles.frame_number, 'String'));
z = str2double(get(handles.slice_number, 'String'));
%seq = getappdata(handles.figure1, 'seq');
global seq
img_num = seq.frames_num(t, z);  
cellgeom = seq.frames(img_num).cellgeom;
highlighted_cells = seq.frames(img_num).cells;
user_cells_colors = zeros(length(cellgeom.circles(:,1)), 3);
user_cells_alphas = ones(length(cellgeom.circles(:,1)), 1);
% if strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
%     cells = false(1,length(cellgeom.circles(:,1)));
%     cells(seq.frames(img_num).cells) = true;
% else
%     cells = true(1,length(cellgeom.circles(:,1)));
% end
%     
% if isfield(cellgeom, 'border_cells')
%     cells(cellgeom.border_cells) = 0;
% end
% if isfield(cellgeom, 'valid')
%     cells(~cellgeom.valid) = 0;
% end
% cells = find(cells);

load('cells_for_t1_ros','cells');
% allcells = union(find(cells),highlighted_cells);
% y = cellgeom.circles(cells, 1);
% x = cellgeom.circles(cells, 2);



% DLF HARDCODE REMOVE LATER -5-5-2014-
if ~isempty(dir('poly_embryo*'))
    load('poly_embryo')
    orbit = get_orbit_frames(handles);
    frame_ind = orbit;
    for i = orbit
        %assuming frame numbers are sorted. the poly/frame with the closest t and z
        %indices should be used, not the one with the closest frame index. 
        [dummy poly_ind(i)] = min(abs(i - poly_frame_ind));
    end
%     globcells = seq.inv_cells_map(img_num,cells);
    globcells = cells;
    for i = orbit
        currcells = nonzeros(seq.cells_map(i,globcells));
        cellgeom = seq.frames(i).cellgeom;
        new_selection = inpolygon(cellgeom.circles(currcells,1), cellgeom.circles(currcells,2), poly_seq(poly_ind(i)).x, poly_seq(poly_ind(i)).y);
        seq.frames(i).cells = currcells(new_selection);
    end
    
else
    display('missing poly_embryo.mat');
end

update_frame(handles)


% --------------------------------------------------------------------
function drw_opt_edges_Callback(hObject, eventdata, handles)
                
global seq
global edges 
global x1 y1 x2 y2
polarityfiletype = 0;
                
if ~isempty(dir('edges_info_cell_background*'))
    load('edges_info_cell_background','edges','x1','y1','x2','y2');

    polarityfiletype = 1;
else if ~isempty(dir('edges_info_max_proj_single_given*'))
        load('edges_info_max_proj_single_given','edges','x1','y1','x2','y2');
        polarityfiletype = 2;
    else
        display('no polarity file found');
    end

end
global ORI_X1 ORI_X2 ORI_Y1 ORI_Y2 inv_edges
ORI_Y1 = y1;   
ORI_Y2 = y2;
ORI_X2 = x2;
ORI_X1 = x1;
inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
inverse_edges_map(edges) = 1:length(edges);

startval = strcmp(get(handles.drw_opt_edges,'checked'),'on');
if startval
    set(handles.drw_opt_edges,'checked','off');
else
    set(handles.drw_opt_edges,'checked','on');
end
seq.draw_edge_opt_bool = ~startval;
update_frame(handles);
% seq.draw_edge_opt_bool = false;
% hObject    handle to drw_opt_edges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function pol_colr_map_Callback(hObject, eventdata, handles)
% hObject    handle to pol_colr_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seq
[~, seq] =update_polarity_annotations_in_tracking_window(handles,seq);
update_frame(handles)

% --------------------------------------------------------------------
function polarity_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to polarity_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function two_pops_Callback(hObject, eventdata, handles)
% hObject    handle to two_pops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subgui_handle = two_pop_polarity;
subgui_data_handle = guidata(subgui_handle);
handles.subgui_handle = subgui_handle;
subgui_data_handle.from_tracking_all = handles;

% subgui_handle=subgui; %opens the subgui
% subgui_data_handle=guidata(subgui_handle); %points to the handles of the subgui
subgui_data_handle.main_gui_handle=hObject; %hObject=handle to main gui
guidata(subgui_handle, subgui_data_handle); %update subgui's handles


% --- Executes during object creation, after setting all properties.
function user_select_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to user_select_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function nlost_after_t0_Callback(hObject, eventdata, handles)
% hObject    handle to nlost_after_t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

orbit = get_orbit_frames(handles);

global seq
data = seq2data(seq);
load topological_events_per_cell cells_lost_hist cells_to_anal
nlost_after_t0 = create_nlost_for_visual(pwd);  
cells = cells_to_anal;

    min_lost = 0;
    max_lost = 4;
    
for i= orbit
	seq.frames(i).cells  = nonzeros(seq.cells_map(i,cells));
    takers = seq.cells_map(i,cells)~=0;
    numlost = nlost_after_t0(i,takers(:));

end

num_colors = (max_lost-min_lost+1);



if num_colors == 5
    manyhsv = hsv(20*4);
    convnums = [1,16,29,49,61];
    evenshsv = manyhsv(convnums,:);
    custom_color_list = evenshsv;
end

if num_colors == 8
    % tailored colormap for a list of 8 different topologies
    manyhsv = cool(20);
    evenshsv = manyhsv(2:2:end,:);
    evenshsv = evenshsv([1,2,4,6:end],:);
    evenshsv = evenshsv([end,1:end-1],:);
    evenshsv = evenshsv([1:2,4:end,3],:);
    
    evenshsv(1,:) = [1 0 0];
    evenshsv(2,:) = [1 0.4 0];
    custom_color_list = evenshsv;
end

custom_color_list = custom_color_list(end:-1:1,:);

display(['colorrange = ',num2str((max_lost-min_lost+1))]);
display(['min lost = ',num2str(min_lost),' max lost = ',num2str(max_lost)]);

for i= orbit
    tmp_sel_cells = logical(cells.*data.cells.selected(i,:));
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,tmp_sel_cells));
    takers = logical((seq.cells_map(i,cells)~=0).*data.cells.selected(i,cells));
    numlost = nlost_after_t0(i,takers(:));
    seq.frames(i).cells_colors(seq.frames(i).cells,:)  = custom_color_list(min(numlost,max_lost)+1,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .5;
end

update_frame(handles)


% --------------------------------------------------------------------
function nlost_dyn_Callback(hObject, eventdata, handles)

orbit = get_orbit_frames(handles);

global seq
seq = extern_nlost_dyn_annotations(handles,seq,orbit);
update_frame(handles);


% --------------------------------------------------------------------
function save_cell_annot_Callback(hObject, eventdata, handles)

global seq
save('annotation_cells_to_seq','seq');

function load_cell_annot_Callback(hObject, eventdata, handles)
% hObject    handle to cells_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
global seq
if ~isempty(dir('annotation_cells_to_seq.mat'))
    oldseq = load('annotation_cells_to_seq');
else
    display('missing annotation file');
    return
end

nframes = length(seq.frames);
for i = 1:nframes
    seq.frames(i).cells = oldseq.seq.frames(i).cells;
    seq.frames(i).cells_colors = oldseq.seq.frames(i).cells_colors;
    seq.frames(i).cells_alphas = oldseq.seq.frames(i).cells_alphas;
end
    

update_frame(handles);

% --------------------------------------------------------------------
function cells_new_Callback(hObject, eventdata, handles)
% hObject    handle to cells_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 


% doing nothing, guide interface demanding this call back


% --------------------------------------------------------------------
function pol_cor_Callback(hObject, eventdata, handles)
% hObject    handle to pol_cor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
orbit = get_orbit_frames(handles);
global seq
seq = extern_polarity_correlation_annotations(handles,seq,orbit);
update_frame(handles);


function symbol_radio_btn_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function multichannel_menu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function show_pat_defo_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
qstring = 'Apply Smoothing?';
title = 'Smooth Data';
str1 = 'Yes';
str2 = 'No';
str3 = 'Cancel';
default = str1;
btn = questdlg(qstring,title,str1,str2,str3,default);
smth_bool = false;
switch btn
    case 'Yes'
        smth_bool = true;
    case 'No'
        smth_bool = false;
    otherwise
        return
end
seq = extern_show_pat_defo(handles,seq,orbit,smth_bool);
update_frame(handles);

% --------------------------------------------------------------------
function len_width_ratio_annotations_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
qstring = 'Apply Smoothing?';
title = 'Smooth Data';
str1 = 'Yes';
str2 = 'No';
str3 = 'Cancel';
default = str1;
btn = questdlg(qstring,title,str1,str2,str3,default);
smth_bool = false;
switch btn
    case 'Yes'
        smth_bool = true;
    case 'No'
        smth_bool = false;
    otherwise
        return
end
seq = extern_len_width_ratio_annotations(handles,seq,orbit, smth_bool);
update_frame(handles);

% --------------------------------------------------------------------
function show_shrinks_Callback(hObject, eventdata, handles)
global seq
seq = extern_show_shrinks(handles,seq);
update_frame(handles);
% --------------------------------------------------------------------
function show_grows_Callback(hObject, eventdata, handles)
global seq
seq = extern_show_grows(handles,seq);
update_frame(handles);
% --------------------------------------------------------------------
function eccentricity_annotations_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
qstring = 'Apply Smoothing?';
title = 'Smooth Data';
str1 = 'Yes';
str2 = 'No';
str3 = 'Cancel';
default = str1;
btn = questdlg(qstring,title,str1,str2,str3,default);
smth_bool = false;
switch btn
    case 'Yes'
        smth_bool = true;
    case 'No'
        smth_bool = false;
    otherwise
        return
end
seq = extern_eccentricity_annotations(handles,seq,orbit,smth_bool);


% --------------------------------------------------------------------
function cell_orientation_annotation_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
qstring = 'Apply Smoothing?';
title = 'Smooth Data';
str1 = 'Yes';
str2 = 'No';
str3 = 'Cancel';
default = str1;
btn = questdlg(qstring,title,str1,str2,str3,default);
smth_bool = false;
switch btn
    case 'Yes'
        smth_bool = true;
    case 'No'
        smth_bool = false;
    otherwise
        return
end
seq = extern_show_cell_orientation(handles,seq,orbit,smth_bool);


% --- Executes on button press in chan2gray_btn.
function chan2gray_btn_Callback(hObject, eventdata, handles)
update_frame(handles);


% --------------------------------------------------------------------
function instant_ros_annotation_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
[min_ros,max_len] = instant_ros_setup();
if isempty(min_ros) || isempty(max_len)
    return
end
seq = extern_show_instant_ros(handles,seq,orbit,min_ros,max_len);

% --------------------------------------------------------------------
function struct_order_annot_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_show_cell_structural_order(handles,seq,orbit);
update_frame(handles);

% --- Executes on button press in scaleBar_btn.
function scaleBar_btn_Callback(hObject, eventdata, handles)
drawingfig = getappdata(handles.figure1, 'drawingfig');
if get(hObject,'value')    
    scaleBarH = add_scale_bar_to_single_img([],[],[],[],[],[],drawingfig);
    setappdata(drawingfig,'scaleBarH',scaleBarH);
else
    scaleBarH = getappdata(drawingfig,'scaleBarH');
    delete(scaleBarH);
end


% --------------------------------------------------------------------
function img_orientation_Callback(hObject, eventdata, handles)
orientH = embryo_orientation_UI;
uiwait(orientH);
original_draw_geom_val = get(handles.draw_geometry,'value');
set(handles.draw_geometry,'value',false);
update_frame(handles);
mH = msgbox('draw approximate curve(s) of embryo');
uiwait(mH);
qA = questdlg('draw once, or throughout?','drawing options','once','throughout','once');
embryoLineH = [];
switch qA
    case 'once'
        states = disable_all_controls(handles);
        [y,x] = get_poly_from_user_input;
        enable_all_controls(handles, states);
        if isempty(x)
            return
        end
        tempXlim = handles.axes1.XLim;
        tempYlim = handles.axes1.YLim;
        p = polyfit(x,y,3);
        xvals = 0:tempXlim(2);
        f1 = polyval(p,xvals);
        embryoLineH = line(xvals,f1);

        dp = [p(1)*3,p(2)*2,p(3)];
        norms = -1./polyval(dp,xvals);


        handles.axes1.XLim = tempXlim;
        handles.axes1.YLim  = tempYlim;  
        embryo_line.x = x;
        embryo_line.y = y;
        embryo_line.p = p;
        embryo_line.dp = dp;
        embryo_line.t = get(handles.frame_slider, 'Value');
        if ishandle(embryoLineH)
                delete(embryoLineH);
        end
    case 'throughout'
        orbit = get_orbit_frames(handles);
        global seq
        drawing_frames = [orbit(1):min(10,orbit(end)):orbit(end),orbit(end)];
        original_draw_geom_val = get(handles.draw_geometry,'value');
        set(handles.draw_geometry,'value',false);
        for i = 1:length(drawing_frames)
            [dummy ind] = min(abs(seq.valid_t_vals - drawing_frames(i)));
            set(handles.frame_slider, 'Value', seq.valid_t_vals(ind));
            update_frame(handles, get(handles.frame_slider, 'Value'), -get(handles.slice_slider, 'Value'));
            if ishandle(embryoLineH)
                delete(embryoLineH);
            end
            states = disable_all_controls(handles);
            [y,x] = get_poly_from_user_input;
            enable_all_controls(handles, states);
            if isempty(x)
                return
            end
            tempXlim = handles.axes1.XLim;
            tempYlim = handles.axes1.YLim;
            if numel(x)>3
                p = polyfit(x,y,3);
            else if numel(x)>2
                    p = polyfit(x,y,2);
                else
                    p = polyfit(x,y,1);
                end
            end
            xvals = 0:tempXlim(2);
            f1 = polyval(p,xvals);
            embryoLineH = line(xvals,f1,'color','c');
            handles.axes1.XLim = tempXlim;
            handles.axes1.YLim  = tempYlim; 
            embryo_line(i).x = x;
            embryo_line(i).y = y;
            embryo_line(i).p = p;
            embryo_line(i).t = drawing_frames(i);
%             embryo_line_frame_ind(i) = i;
        end
end
save('embryo_orientation','embryo_line','-append');
if ishandle(embryoLineH)
        delete(embryoLineH);
end
set(handles.draw_geometry,'value',original_draw_geom_val);
update_frame(handles);
        


% --------------------------------------------------------------------
function locate_vf_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
drawing_frames = [orbit(1):min(10,orbit(end)):orbit(end),orbit(end)];
vfH = [];
% current_frame = 1;
mH = msgbox('draw approximate curves of ventral furrow');
uiwait(mH);
original_draw_geom_val = get(handles.draw_geometry,'value');
set(handles.draw_geometry,'value',false);
for i = 1:length(drawing_frames)
    [dummy ind] = min(abs(seq.valid_t_vals - drawing_frames(i)));
    set(handles.frame_slider, 'Value', seq.valid_t_vals(ind));
    update_frame(handles, get(handles.frame_slider, 'Value'), -get(handles.slice_slider, 'Value'));
	if ishandle(vfH)
        delete(vfH);
    end
    states = disable_all_controls(handles);
    [y,x] = get_poly_from_user_input;
    enable_all_controls(handles, states);
    if isempty(x)
        return
    end
    tempXlim = handles.axes1.XLim;
    tempYlim = handles.axes1.YLim;
    if numel(x)>3
        p = polyfit(x,y,3);
    else if numel(x)>2
            p = polyfit(x,y,2);
        else
            p = polyfit(x,y,1);
        end
    end
    xvals = 0:tempXlim(2);
    f1 = polyval(p,xvals);
    vfH = line(xvals,f1,'color','c');
    handles.axes1.XLim = tempXlim;
    handles.axes1.YLim  = tempYlim; 
    ventral_line(i).x = x;
    ventral_line(i).y = y;
    ventral_line(i).p = p;
    ventral_line(i).t = drawing_frames(i);
end
ventral_line_seq = ventral_line;
ventral_line_frame_ind = [ventral_line(:).t];
% setappdata(handles.figure1,'ventral_line_seq',ventral_line_seq);
% setappdata(handles.figure1,'ventral_line_frame_ind','ventral_line_frame_ind');
save('embryo_orientation','ventral_line','-append');
if ishandle(vfH)
        delete(vfH);
end
set(handles.draw_geometry,'value',original_draw_geom_val);
update_frame(handles);


% --------------------------------------------------------------------
function poly_define_menu_Callback(hObject, eventdata, handles)
switch get(hObject,'Checked')
    case 'on'
        set(hObject,'Checked','off')
        poly_filename = 'embryo_poly.mat';
    case 'off'
        set(hObject,'Checked','on')
        poly_filename = 'poly_seq.mat';        
end
setappdata(handles.figure1,'poly_filename',poly_filename);
if isappdata(handles.figure1, 'poly_seq')
    rmappdata(handles.figure1, 'poly_seq');
end
if isappdata(handles.figure1,'poly_frame_ind')
    rmappdata(handles.figure1, 'poly_frame_ind');
end
load_saved_polys(handles);
update_frame(handles)
% --------------------------------------------------------------------
function clear_poly_seq_menu_Callback(hObject, eventdata, handles)
rmappdata(handles.figure1, 'poly_seq');
rmappdata(handles.figure1, 'poly_frame_ind');
update_frame(handles)


% --------------------------------------------------------------------
function view_vf_menu_chck_Callback(hObject, eventdata, handles)
switch get(hObject,'Checked')
    case 'on'
        set(hObject,'Checked','off');
        setappdata(handles.figure1,'show_vf_bool',true);
    case 'off'
        set(hObject,'Checked','on');
        setappdata(handles.figure1,'show_vf_bool',false);
end
update_frame(handles)


% --------------------------------------------------------------------
function nlost_ephemeral_Callback(hObject, eventdata, handles)
% hObject    handle to nlost_ephemeral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'off'
        set(hObject,'Checked','on');
        load('time_localized_events_per_cell','edgeBased_activityData');
        setappdata(handles.figure1,'edgeBased_activityData',edgeBased_activityData);
        setappdata(handles.figure1,'nlost_ephemeral_bool',true);
    case 'on'
        set(hObject,'Checked','off');
        setappdata(handles.figure1,'nlost_ephemeral_bool',false);
end
update_frame(handles)


% --------------------------------------------------------------------
function polarity_covariance_annotation_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_polarity_covariance_annotations(handles,seq,orbit);


% --------------------------------------------------------------------
function edge_contraction_rates_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_edge_contraction_rate_annotations(handles,seq,orbit);
update_frame(handles);

function classifytrack_Callback(hObject, eventdata, handles)
edit_t(handles, 'classifytrack', 1);
update_frame(handles);

function show_div_cells_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_show_div_cells(handles,seq,orbit);
update_frame(handles);


% --------------------------------------------------------------------
function rotating_edges_Callback(hObject, eventdata, handles)
global seq
seq = extern_show_rotating_edges(handles,seq);
update_frame(handles);




% --------------------------------------------------------------------
function show_cell_squareness_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_show_cell_squareness(handles,seq,orbit);
update_frame(handles);
% extern_show_cell_structural_order(handles,seq,orbit);


% --- Executes on button press in seg_edge_color_btn.
function seg_edge_color_btn_Callback(hObject, eventdata, handles)
ncolors = 1;
callingfig = handles.figure1;
callingfig_handles = handles;
mapped_numbers = 1;
geom_edge_settings = getappdata(handles.figure1,'geom_edge_settings');
if isempty(geom_edge_settings)
    geom_color = [0 1 0];
else
    geom_color  = geom_edge_settings.color;
end
edge_cpH = geom_edge_colorpicker(ncolors,callingfig,callingfig_handles,...
                            mapped_numbers,geom_color);
update_frame(handles);
                        
                        
function update_geom_edge_settings_Callback(handles)
update_frame(handles);
geom_edge_settings = getappdata(handles.figure1,'geom_edge_settings');
if isempty(geom_edge_settings)
    geom_color = [0 1 0];
else
    geom_color  = geom_edge_settings.color;
end
set(handles.seg_edge_color_btn,'foregroundcolor',geom_color,'backgroundcolor',geom_color);


% --------------------------------------------------------------------
function show_poly_bool_Callback(hObject, eventdata, handles)
poly_bool =  strcmp(get(handles.show_poly_bool,'checked'),'on');
setlist = {'on','off'};
set(handles.show_poly_bool,'checked',setlist{poly_bool+1});
setappdata(handles.figure1,'on_off_poly_bool',~poly_bool);
update_frame(handles);





% --------------------------------------------------------------------
function area_drop_mid_Callback(hObject, eventdata, handles)
orbit = get_orbit_frames(handles);
global seq
seq = extern_area_drop_mid_annotations(handles,seq,orbit);
update_frame(handles)


% --------------------------------------------------------------------
function zoom_track_const_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_track_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(hObject, 'Checked'), 'on')
    set(hObject, 'Checked', 'off')
    
	start_x_lim = getappdata(handles.figure1,'start_x_lim');
    start_y_lim = getappdata(handles.figure1,'start_y_lim');
    setappdata(handles.figure1, 'axes_x_lim', start_x_lim);
    setappdata(handles.figure1, 'axes_y_lim', start_y_lim);
    set(handles.axes1,'xlim',start_x_lim);
    set(handles.axes1,'ylim',start_y_lim);
    
else
    set(handles.shift_axes_with_cells, 'Checked', 'off')
    set(handles.zoom_and_track_cells, 'Checked', 'off')
    set(hObject, 'Checked', 'on')
    global seq
    for i = 1:length(seq.frames)
        if isempty(seq.frames(i).cells)
            x_cent(i) = nan; x_rad(i) = nan; y_cent(i) = nan; y_rad(i) = nan;
        else
            x_max = max(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 2));
            x_min = min(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 2));
            x_cent(i) = mean(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 2));
            x_rad(i) = (x_max-x_min)/2;
            
            y_max = max(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 1));
            y_min = min(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 1));
            y_cent(i) = mean(seq.frames(i).cellgeom.circles(seq.frames(i).cells, 1));
            y_rad(i) = (y_max-y_min)/2;
        end
    end
    
    padval = 40;
    x_cent = fill_nans_linear(x_cent);
    x_cent(~isnan(x_cent)) = smoothen(x_cent(~isnan(x_cent))');
    x_rad = fill_nans_linear(x_rad);
    x_rad(~isnan(x_rad)) = smoothen(x_rad(~isnan(x_rad))');
    x_rad_final = mean(x_rad(~isnan(x_rad)))+padval;
    
	y_cent = fill_nans_linear(y_cent);
    y_cent(~isnan(y_cent)) = smoothen( y_cent(~isnan(y_cent))');
    y_rad = fill_nans_linear(y_rad);
    y_rad(~isnan(y_rad)) = smoothen(y_rad(~isnan(y_rad))');
    y_rad_final = mean(y_rad(~isnan(y_rad)))+padval;

    pad = 50;
    axes_x_lim = [(x_cent-x_rad_final)' (x_cent+x_rad_final)'];
    axes_y_lim = [(y_cent-y_rad_final)' (y_cent+y_rad_final)'];

    setappdata(handles.figure1, 'axes_x_lim', axes_x_lim);
    setappdata(handles.figure1, 'axes_y_lim', axes_y_lim);
end
update_frame(handles);
