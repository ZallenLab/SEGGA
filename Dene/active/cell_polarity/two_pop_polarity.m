function varargout = two_pop_polarity(varargin)
% TWO_POP_POLARITY MATLAB code for two_pop_polarity.fig
%      TWO_POP_POLARITY, by itself, creates a new TWO_POP_POLARITY or raises the existing
%      singleton*.
%
%      H = TWO_POP_POLARITY returns the handle to a new TWO_POP_POLARITY or the handle to
%      the existing singleton*.
%
%      TWO_POP_POLARITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TWO_POP_POLARITY.M with the given input arguments.
%
%      TWO_POP_POLARITY('Property','Value',...) creates a new TWO_POP_POLARITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before two_pop_polarity_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to two_pop_polarity_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help two_pop_polarity

% Last Modified by GUIDE v2.5 03-Jan-2017 19:15:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @two_pop_polarity_OpeningFcn, ...
                   'gui_OutputFcn',  @two_pop_polarity_OutputFcn, ...
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


% --- Executes just before two_pop_polarity is made visible.
function two_pop_polarity_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to two_pop_polarity (see VARARGIN)

% Choose default command line output for two_pop_polarity
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
clearvars -global pop_two_cells pop_one_cells
% UIWAIT makes two_pop_polarity wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = two_pop_polarity_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_one.
function select_one_Callback(hObject, eventdata, handles)

tracking_handles = handles.from_tracking_all;
if get(tracking_handles.newfig_check, 'value')
    figure(getappdata(tracking_handles.figure1, 'drawingfig'));
end

pop_one_color = [0 0 1];
pop_one_alpha = 0.3;





set(tracking_handles.user_select_c, 'BackgroundColor',pop_one_color);
set(tracking_handles.user_select_c, 'userdata',pop_one_alpha);

clusters = false;
if strcmp(lower(get(tracking_handles.files2cluster, 'Checked')), 'on');
    clusters = true;
end

%seq = getappdata(tracking_handles.figure1, 'seq');
global seq
global pop_one_cells
global pop_two_cells

% Starting fresh instead of loading previous cells
% if ~isempty(dir('cells_for_two_pops.mat'));
%     load('cells_for_two_pops');
% end

img_num = str2double(get(tracking_handles.frame_number, 'String'));
z_num = str2double(get(tracking_handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);  
cellgeom = seq.frames(frame_num).cellgeom;
user_lighted_ind = false(1, length(cellgeom.circles(:,1)));
user_lighted = getappdata(tracking_handles.figure1, 'user_cells');
if ~isempty(nonzeros(user_lighted))
    user_lighted_ind(nonzeros(user_lighted)) = true;
end

user_cells_colors = getappdata(tracking_handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(tracking_handles.figure1, 'user_cells_alphas');


user_cells_alphas = reshape(user_cells_alphas, [], 1);
setappdata(tracking_handles.figure1, 'user_cells_alphas', user_cells_alphas);

touched_cells = getappdata(tracking_handles.figure1, 'touched_cells');
if clusters
    touched_cells(:) = false;    
    all_mod_clust = false(1, length(seq.frames(frame_num).clusters_data));
end


z = str2double(get(tracking_handles.slice_number, 'String'));
states = disable_all_controls(tracking_handles);
states_local = disable_all_controls_local(handles);
[y,x, button] = ginput(1);
enable_all_controls(tracking_handles, states);

while ~isempty(x) & button ~= 27 & button ~= 3;
    I1 = cell_from_pos(y, x, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end
    seq.inv_cells_map(frame_num, I1)
    user_lighted_ind(I1) = ~user_lighted_ind(I1);
    user_cells_colors(I1,:) = get(tracking_handles.user_select_c, 'BackgroundColor');
    user_cells_alphas(I1,:) = get(tracking_handles.user_select_c, 'userdata');
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
    %setappdata(tracking_handles.figure1, 'seq', seq);
    setappdata(tracking_handles.figure1, 'first_time', 1);

    update_frame(tracking_handles, str2double(get(tracking_handles.frame_number, 'string')), z);

    states = disable_all_controls(tracking_handles);
    [y,x, button] = ginput(1);


end

    enable_all_controls(tracking_handles, states);
    enable_all_controls_local(handles, states_local);




% save the cells
img_num = str2double(get(tracking_handles.frame_number, 'String'));
z_num = str2double(get(tracking_handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);
cells = false(size(seq.cells_map(1, :)));
cells(seq.inv_cells_map(frame_num,nonzeros(seq.frames(frame_num).cells))) = true;
% pop_one_cells = cells;
% 
%     
%     
%     if ~isempty(whos('pop_two_cells'))
%         pop_one_cells_linear = find(pop_one_cells);
%         pop_two_cells_linear = find(pop_two_cells);
% 
%         
%         
%         pop_two_cells_linear = pop_two_cells_linear(~ismember(pop_two_cells_linear,pop_one_cells_linear));
%         cells = false(size(seq.cells_map(1, :)));
%         cells(pop_two_cells_linear) = true;
%         pop_two_cells = cells;
%         
%         pop_one_cells_linear = pop_one_cells_linear(~ismember(pop_one_cells_linear,pop_two_cells_linear));
%         cells = false(size(seq.cells_map(1, :)));
%         cells(pop_one_cells_linear) = true;
%         pop_one_cells = cells;
%     else
%         pop_two_cells = [];
%         
%     end
% 
% 
% if ~isempty(dir('cells_for_two_pops.mat'))
%     save('cells_for_two_pops','pop_one_cells','pop_two_cells','-append');
% else
%     save('cells_for_two_pops','pop_one_cells','pop_two_cells');
% end


save_shown_separate(handles);

clear('tracking_handles');




% --- Executes on button press in select_two.
function select_two_Callback(hObject, eventdata, handles)
% hObject    handle to select_two (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking_handles = handles.from_tracking_all;
if get(tracking_handles.newfig_check, 'value')
    figure(getappdata(tracking_handles.figure1, 'drawingfig'));
end

pop_two_color = [0 1 0];

set(tracking_handles.user_select_c, 'BackgroundColor',pop_two_color);

clusters = false;
if strcmp(lower(get(tracking_handles.files2cluster, 'Checked')), 'on');
    clusters = true;
end

%seq = getappdata(tracking_handles.figure1, 'seq');
global seq
global pop_one_cells
global pop_two_cells

if ~isempty(dir('cells_for_two_pops.mat'));
    load('cells_for_two_pops');
end

img_num = str2double(get(tracking_handles.frame_number, 'String'));
z_num = str2double(get(tracking_handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);  
cellgeom = seq.frames(frame_num).cellgeom;
user_lighted_ind = false(1, length(cellgeom.circles(:,1)));
user_lighted = getappdata(tracking_handles.figure1, 'user_cells');
if ~isempty(nonzeros(user_lighted))
    user_lighted_ind(nonzeros(user_lighted)) = true;
end

user_cells_colors = getappdata(tracking_handles.figure1, 'user_cells_colors');
user_cells_alphas = getappdata(tracking_handles.figure1, 'user_cells_alphas');

user_cells_alphas = reshape(user_cells_alphas, [], 1);
setappdata(tracking_handles.figure1, 'user_cells_alphas', user_cells_alphas);

touched_cells = getappdata(tracking_handles.figure1, 'touched_cells');
if clusters
    touched_cells(:) = false;    
    all_mod_clust = false(1, length(seq.frames(frame_num).clusters_data));
end


z = str2double(get(tracking_handles.slice_number, 'String'));
states = disable_all_controls(tracking_handles);
states_local = disable_all_controls_local(handles);
[y,x, button] = ginput(1);



while ~isempty(x) & button ~= 27 & button ~= 3;
    I1 = cell_from_pos(y, x, cellgeom);
    if I1 == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end
    seq.inv_cells_map(frame_num, I1)
    user_lighted_ind(I1) = ~user_lighted_ind(I1);
    user_cells_colors(I1,:) = get(tracking_handles.user_select_c, 'BackgroundColor');
    user_cells_alphas(I1,:) = get(tracking_handles.user_select_c, 'userdata');
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
    %setappdata(tracking_handles.figure1, 'seq', seq);
    setappdata(tracking_handles.figure1, 'first_time', 1);

    update_frame(tracking_handles, str2double(get(tracking_handles.frame_number, 'string')), z);

%     states = disable_all_controls(tracking_handles);
%     states_local = disable_all_controls_local(handles);
    [y,x, button] = ginput(1);


end

    enable_all_controls(tracking_handles, states);
    enable_all_controls_local(handles, states_local);





% save the cells
img_num = str2double(get(tracking_handles.frame_number, 'String'));
z_num = str2double(get(tracking_handles.slice_number, 'String'));
frame_num = seq.frames_num(img_num, z_num);
cells = false(size(seq.cells_map(1, :)));
cells(seq.inv_cells_map(frame_num,nonzeros(seq.frames(frame_num).cells))) = true;
% pop_two_cells = cells;
% 
% % load('cells_for_two_pops','pop_one_cells');
% if ~isempty(whos('pop_one_cells'))
% 	pop_two_cells_linear = find(pop_two_cells);
%     pop_one_cells_linear = find(pop_one_cells);
% 
%      
%    	pop_one_cells_linear = pop_one_cells_linear(~ismember(pop_one_cells_linear,pop_two_cells_linear));
%     cells = false(size(seq.cells_map(1, :)));
% 	cells(pop_one_cells_linear) = true;
% 	pop_one_cells = cells;
%     
% 	pop_two_cells_linear = pop_two_cells_linear(~ismember(pop_two_cells_linear,pop_one_cells_linear));
%     cells = false(size(seq.cells_map(1, :)));
%     cells(pop_two_cells_linear) = true;
%     pop_two_cells = cells;
%     
% else
%     
%     pop_one_cells = [];
%     
% end
% 
% if ~isempty(dir('cells_for_two_pops.mat'))
% %     
%     
% %     pop_two_cells = find(pop_two_cells);
% %     pop_one_cells = find(pop_one_cells);
% %     pop_two_cells = pop_two_cells(~ismember(pop_two_cells,pop_one_cells));
% %     
% %     
% %     cells = false(size(seq.cells_map(1, :)));
% %     cells(pop_two_cells) = true;
% %     pop_two_cells = cells;
% %     
%     save('cells_for_two_pops','pop_two_cells','pop_one_cells','-append');
% else
%     save('cells_for_two_pops','pop_two_cells','pop_one_cells');
% end

save_shown_separate(handles)

% num_frames = length(seq.frames);
% local_cells = zeros(num_frames,length(find(cells))); % redefined below
% 
%     for i = 1:num_frames
%         
%         local_cells(i,:) = seq.cells_map(i,cells(:));
%         seq.frames(i).cells_colors(local_cells(i,:), 1) = pop_two_color(1);
%         seq.frames(i).cells_colors(local_cells(i,:), 2) = pop_two_color(2);
%         seq.frames(i).cells_colors(local_cells(i,:), 3) = pop_two_color(3);
%         seq.frames(i).cells_alphas(local_cells(i,:)) = 0.3;
%     end
%     
%     update_frame(tracking_handles);




clear('tracking_handles');




% --- Executes on button press in cancel_op.
function cancel_op_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_op (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracking_handles = handles.from_tracking_all;
close(tracking_handles.subgui_handle);
clear('tracking_handles');

% --- Executes on button press in restart_op.
function restart_op_Callback(hObject, eventdata, handles)
% hObject    handle to restart_op (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking_handles = handles.from_tracking_all;
if get(tracking_handles.newfig_check, 'value')
    figure(getappdata(tracking_handles.figure1, 'drawingfig'));
end

global seq
global pop_one_cells
global pop_two_cells
pop_one_cells = [];
pop_two_cells = [];

num_frames = length(seq.frames);


    for i = 1:num_frames
       
        seq.frames(i).cells = [];
    end
    
    
    update_frame(tracking_handles);
    clear('tracking_handles');

% --- Executes on button press in load_prev.
function load_prev_Callback(hObject, eventdata, handles)
% hObject    handle to load_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking_handles = handles.from_tracking_all;
if get(tracking_handles.newfig_check, 'value')
    figure(getappdata(tracking_handles.figure1, 'drawingfig'));
end

global seq
global pop_one_cells
global pop_two_cells
pop_two_color = [0 1 0];
pop_one_color = [0 0 1];


if ~isempty(dir('cells_for_two_pops.mat'))
    
    load('cells_for_two_pops','pop_one_cells');
    load('cells_for_two_pops','pop_two_cells');
end

if isempty(who('pop_one_cells','pop_two_cells'))
    display('no data found');
    return
end

oneexists = false;
twoexists = false;
if ~isempty(who('pop_one_cells'))
    oneexists = true;
else
    pop_one_cells = [];
end
if ~isempty(who('pop_two_cells'))
    twoexists = true;
else
    pop_two_cells = [];
end

num_frames = length(seq.frames);
if oneexists;  local_popone_cells = zeros(num_frames,length(find(pop_one_cells))); end;% redefined below
if twoexists; local_poptwo_cells = zeros(num_frames,length(find(pop_two_cells))); end;% redefined below

    for i = 1:num_frames
        
        if oneexists
        local_popone_cells(i,:) = seq.cells_map(i,pop_one_cells(:));
        seq.frames(i).cells_colors(local_popone_cells(i,:), 1) = pop_one_color(1);
        seq.frames(i).cells_colors(local_popone_cells(i,:), 2) = pop_one_color(2);
        seq.frames(i).cells_colors(local_popone_cells(i,:), 3) = pop_one_color(3);
        seq.frames(i).cells_alphas(local_popone_cells(i,:)) = 0.3;
        end
        
        if twoexists
        local_poptwo_cells(i,:) = seq.cells_map(i,pop_two_cells(:));
        seq.frames(i).cells_colors(local_poptwo_cells(i,:), 1) = pop_two_color(1);
        seq.frames(i).cells_colors(local_poptwo_cells(i,:), 2) = pop_two_color(2);
        seq.frames(i).cells_colors(local_poptwo_cells(i,:), 3) = pop_two_color(3);
        seq.frames(i).cells_alphas(local_poptwo_cells(i,:)) = 0.3;
        end
        
        both_pops = seq.cells_map(i,[find(pop_one_cells),find(pop_two_cells)]);
        seq.frames(i).cells = both_pops;
    end
    
    
    update_frame(tracking_handles);
    
        
        
%         display('pop_one_cells');
%         display(num2str(find(pop_one_cells)));
%         display('pop_two_cells');
%         display(num2str(find(pop_two_cells)));


% --- Executes on button press in calc_current.
function calc_current_Callback(hObject, eventdata, handles)
% hObject    handle to calc_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        fullpolfilename = dir('edges_info*');
        if isempty(fullpolfilename)
            display('missing polarity analysis file');
            msgbox({'missing polarity analysis file (''edges_info*.mat'')';...
                '';...
                'Did you run the analysis first?';...
                'If not you need to:';...
                '1. Finish corrections.';...
                '2. Run analysis by clicking on the ''Analyze'' button in the';...
                '   Single Image Toolbox interface'});
            return
        end
        fullpolfilename = fullpolfilename(1).name;
        load(fullpolfilename);
        
        savedir = [pwd,filesep,'..',filesep,'two-pop-stats'];
        if ~isdir(savedir)
            mkdir(savedir)
        end
        
        savefilename_both = 'two-pop-stats-both.csv';
        fullfilename_both = [savedir,filesep,savefilename_both];
        
        
%         allcells_savefilename_both = 'two-pop-stats-both-all-cells.csv';
%         allcells_fullfilename_both = [savedir,filesep,allcells_savefilename_both];
        
        
        

        chanlist = 1:length(channel_info);
        for chan_num = chanlist

            [combined_output_cells combined_output_edges] = output_two_pop_analysis(pwd,[],chan_num);
            
            
            channel_info(chan_num).combined_output_cells = combined_output_cells;
            channel_info(chan_num).combined_output_edges = combined_output_edges;
            
%             save([savedir,filesep,'two-pop-stats-',channel_info(chan_num).name],'combined_output_cells','combined_output_edges');
%             save([savedir,filesep,'two-pop-stats-gen'],'combined_output_cells','combined_output_edges');
            
%%% Was Combining Channels Output Data - Just for convenience
            combined_output_cells = reshape(combined_output_cells,1,size(combined_output_cells,1),size(combined_output_cells,2));
            combined_output_edges = reshape(combined_output_edges,1,size(combined_output_edges,1),size(combined_output_edges,2));
%             writecustomcsv_nonames(combined_output_cells,fullfilename_both);
%             writecustomcsv_nonames(combined_output_edges,fullfilename_both);
            
            
            savefilename_spec = ['two-pop-stats-',channel_info(chan_num).name,'.csv'];
            fullfilename_spec = [savedir,filesep,savefilename_spec];

            writecustomcsv_nonames(combined_output_cells,fullfilename_spec);
%             writecustomcsv_nonames(combined_output_edges,fullfilename_spec);
            
            
%             creating the full list of all cell polarities
            full_combined_output_cells = fulllength_output_two_pop_analysis(pwd,[],chan_num);
            full_combined_output_cells = reshape(full_combined_output_cells,1,size(full_combined_output_cells,1),size(full_combined_output_cells,2));
            allcells_savefilename_spec = ['two-pop-stats-allcells-',channel_info(chan_num).name,'.csv'];
            allcells_fullfilename_spec = [savedir,filesep,allcells_savefilename_spec];
            writecustomcsv_nonames(full_combined_output_cells,allcells_fullfilename_spec);
            
%             save([savedir,filesep,'two-pop-stats-allcells-',channel_info(chan_num).name],'full_combined_output_cells');
            
            
        end
        
            
        
        
        
%         save([savedir,filesep,'two-pop-stats'],'combined_output_cells','combined_output_edges');
% 
%         combined_output_cells = reshape(combined_output_cells,1,size(combined_output_cells,1),size(combined_output_cells,2));
%         combined_output_edges = reshape(combined_output_edges,1,size(combined_output_edges,1),size(combined_output_edges,2));
%         writecustomcsv_nonames(combined_output_cells,fullfilename);
%         writecustomcsv_nonames(combined_output_edges,fullfilename);
        
        load('cells_for_two_pops','pop_one_cells','pop_two_cells');
        timestr = datestr(now,'mmmm dd, yyyy HH:MM:SS');
        timestr = strrep(timestr, ':', '_');
        timestr = strrep(timestr, ' ', '-');
        timestr = strrep(timestr, ',', '-');
        save([savedir,filesep,'cells_for_two_pops-',timestr],'pop_one_cells','pop_two_cells');
        

        

% --- Executes during object creation, after setting all properties.
function cancel_op_CreateFcn(hObject, eventdata, handles)
setbgcolor(hObject,[1 0 0])
test = 1;
% hObject    handle to cancel_op (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function states = disable_all_controls_local(handles)

names = fieldnames(handles);
for i = 1:length(names)
    ctrl = getfield(handles, names{i});
    if isprop(ctrl, 'Enable') && ctrl ~= handles.figure1 
        states.(names{i}) = get(ctrl, 'Enable');
        set(ctrl, 'Enable', 'Off');
    end
end
setappdata(handles.figure1, 'disabled_mode', 1);



function states = enable_all_controls_local(handles, states)

names = fieldnames(states);
for i = 1:length(names)
    ctrl = names{i};
    if isprop(handles.(ctrl), 'Enable')
        set(handles.(ctrl), 'Enable', states.(ctrl));
    end
end
setappdata(handles.figure1, 'disabled_mode', 0);


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


function orbit = get_orbit_frames(handles)
global seq
l = str2double(get(handles.t_from, 'string')); 
r = str2double(get(handles.t_to, 'string'));
b = str2double(get(handles.z_from, 'string'));
t = str2double(get(handles.z_to, 'string'));


orbit = nonzeros(seq.frames_num(l:r, b:t))';


% --- Executes on button press in flipLR_18.
function flipLR_18_Callback(hObject, eventdata, handles)
% hObject    handle to flipLR_18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startdir = pwd;
fix_flip_image_dirs({[pwd,filesep,'..',filesep,'blue']});
display('re-open interfaces');
close all;
cd(startdir);
evalin('base','commandsui');


% --- Executes on button press in blue2gray.
function blue2gray_Callback(hObject, eventdata, handles)
indir = pwd;
changebackbool_seg = false;
change_seg_background_to_blue_chan(indir,changebackbool_seg);

changebackbool_trackopts = false;
deactivate_tracking_opts(indir,changebackbool_trackopts);

display('re-open interfaces');
close all;
cd(indir);
evalin('base','commandsui');


% --- Executes on button press in back_to_original_max_proj.
function back_to_original_max_proj_Callback(hObject, eventdata, handles)
% hObject    handle to back_to_original_max_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indir = pwd;
changebackbool_seg = true;
change_seg_background_to_blue_chan(indir,changebackbool_seg);

changebackbool_trackopts = false;
deactivate_tracking_opts(indir,changebackbool_trackopts);
display('re-open interfaces');
close all;
cd(indir);
evalin('base','commandsui');


% --- Executes on button press in multi_channel_setup.
function multi_channel_setup_Callback(hObject, eventdata, handles)
% hObject    handle to multi_channel_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indir = pwd;
changebackbool_trackopts = true;
deactivate_tracking_opts(indir,changebackbool_trackopts);
display('re-open interfaces');
close all;
cd(indir);
evalin('base','commandsui');


% --- Executes on button press in save_shown.
function save_shown_separate(handles)
% hObject    handle to save_shown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tracking_handles = handles.from_tracking_all;
pop_two_color = [0 1 0];
pop_one_color = [0 0 1];


%seq = getappdata(tracking_handles.figure1, 'seq');
global seq
global pop_one_cells
global pop_two_cells

t = str2double(get(tracking_handles.frame_number, 'String'));
z = str2double(get(tracking_handles.slice_number, 'String'));
img_num = seq.frames_num(t, z); 
allcells = seq.frames(img_num).cells;

onecellsinds = seq.frames(img_num).cells_colors(:,1)==pop_one_color(1);
onecellsinds = onecellsinds&seq.frames(img_num).cells_colors(:,2)==pop_one_color(2);
onecellsinds = onecellsinds&seq.frames(img_num).cells_colors(:,3)==pop_one_color(3);

onecells = allcells(ismember(allcells,find(onecellsinds), 'legacy'));

twocellsinds = seq.frames(img_num).cells_colors(:,1)==pop_two_color(1);
twocellsinds = twocellsinds&seq.frames(img_num).cells_colors(:,2)==pop_two_color(2);
twocellsinds = twocellsinds&seq.frames(img_num).cells_colors(:,3)==pop_two_color(3);


twocells = allcells(ismember(allcells,find(twocellsinds), 'legacy'));

display('pop_one_cells');
pop_one_cells = onecellsinds';
display(num2str(find(pop_one_cells)));
display('pop_two_cells');
pop_two_cells = twocellsinds';
display(num2str(find(pop_two_cells)));


display('pop one by visual (color search)');
display(num2str(onecells));
display('pop two by visual (color search)');
display(num2str(twocells));




oneexists = false;
twoexists = false;
if ~isempty(who('pop_one_cells'))
    oneexists = true;
else
    pop_one_cells = [];
end
if ~isempty(who('pop_two_cells'))
    twoexists = true;
else
    pop_two_cells = [];
end

% save('cells_for_two_pops','pop_one_cells','pop_two_cells');



if ~(all(ismember(twocells,find(pop_two_cells), 'legacy')))||~(all(ismember(onecells,find(pop_one_cells), 'legacy')))||...
        ~(all(ismember(find(pop_two_cells),twocells, 'legacy')))||~(all(ismember(find(pop_one_cells),onecells,'legacy')))
    display('visualization does not match up to local data for saving');
    display('saving both');
    
    save('cells_for_two_pops_global','pop_one_cells','pop_two_cells');
    
    pop_one_cells(:) = false;
    pop_one_cells(onecells) = true;
    pop_one_cells = logical(pop_one_cells);
    
    pop_two_cells(:) = false;
    pop_two_cells(twocells) = true;
    pop_two_cells = logical(pop_two_cells);
    
    save('cells_for_two_pops_from_colors','pop_one_cells','pop_two_cells');
end


save('cells_for_two_pops','pop_one_cells','pop_two_cells');



% --- Executes on button press in save_shown.
function save_shown_Callback(hObject, eventdata, handles)
% hObject    handle to save_shown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tracking_handles = handles.from_tracking_all;
pop_two_color = [0 1 0];
pop_one_color = [0 0 1];


%seq = getappdata(tracking_handles.figure1, 'seq');
global seq
global pop_one_cells
global pop_two_cells

t = str2double(get(tracking_handles.frame_number, 'String'));
z = str2double(get(tracking_handles.slice_number, 'String'));
img_num = seq.frames_num(t, z); 
allcells = seq.frames(img_num).cells;

onecellsinds = seq.frames(img_num).cells_colors(:,1)==pop_one_color(1);
onecellsinds = onecellsinds&seq.frames(img_num).cells_colors(:,2)==pop_one_color(2);
onecellsinds = onecellsinds&seq.frames(img_num).cells_colors(:,3)==pop_one_color(3);

onecells = allcells(ismember(allcells,find(onecellsinds), 'legacy'));

twocellsinds = seq.frames(img_num).cells_colors(:,1)==pop_two_color(1);
twocellsinds = twocellsinds&seq.frames(img_num).cells_colors(:,2)==pop_two_color(2);
twocellsinds = twocellsinds&seq.frames(img_num).cells_colors(:,3)==pop_two_color(3);


twocells = allcells(ismember(allcells,find(twocellsinds), 'legacy'));

display('pop_one_cells');
display(num2str(find(pop_one_cells)));
display('pop_two_cells');
display(num2str(find(pop_two_cells)));


display('pop one by visual (color search)');
display(num2str(onecells));
display('pop two by visual (color search)');
display(num2str(twocells));




oneexists = false;
twoexists = false;
if ~isempty(who('pop_one_cells'))
    oneexists = true;
else
    pop_one_cells = [];
end
if ~isempty(who('pop_two_cells'))
    twoexists = true;
else
    pop_two_cells = [];
end

% save('cells_for_two_pops','pop_one_cells','pop_two_cells');



if ~(all(ismember(twocells,find(pop_two_cells), 'legacy')))||~(all(ismember(onecells,find(pop_one_cells), 'legacy')))||...
        ~(all(ismember(find(pop_two_cells),twocells, 'legacy')))||~(all(ismember(find(pop_one_cells), onecells,'legacy')))
    display('visualization does not match up to local data for saving');
    display('saving both');
    
    save('cells_for_two_pops_global','pop_one_cells','pop_two_cells');
    
    pop_one_cells(:) = false;
    pop_one_cells(onecells) = true;
    pop_one_cells = logical(pop_one_cells);
    
    pop_two_cells(:) = false;
    pop_two_cells(twocells) = true;
    pop_two_cells = logical(pop_two_cells);
    
    save('cells_for_two_pops_from_colors','pop_one_cells','pop_two_cells');
end


save('cells_for_two_pops','pop_one_cells','pop_two_cells');


% --- Executes on button press in green2gray.
function green2gray_Callback(hObject, eventdata, handles)
% hObject    handle to green2gray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indir = pwd;
changebackbool_seg = false;
change_seg_background_to_green_chan(indir,changebackbool_seg);

changebackbool_trackopts = false;
deactivate_tracking_opts(indir,changebackbool_trackopts);

display('re-open interfaces');
close all;
cd(indir);
evalin('base','commandsui');

% --- Executes on button press in red2grey.
function red2grey_Callback(hObject, eventdata, handles)
% hObject    handle to red2grey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indir = pwd;
changebackbool_seg = false;
success = change_seg_background_to_red_chan(indir,changebackbool_seg);
if ~success
    display('failed to re-map background image, file may not exist');
end

changebackbool_trackopts = false;
deactivate_tracking_opts(indir,changebackbool_trackopts);

display('re-open interfaces');
close all;
cd(indir);
evalin('base','commandsui');
