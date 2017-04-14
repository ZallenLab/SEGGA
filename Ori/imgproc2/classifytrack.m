function [seq_out, type_out, success, class_stage_out, classification_complete_bool] =...
    classifytrack(seq_in, activefig, activefig_handles,...
    activefig_states, classification_stage, type_in)

%%%DESCRIPTION
% classifytrack is called from 'tracking'. It is called more than once, to
% go through a process that classifies tracking errors as appearing,
% disappearing, and dividing cells

%%%OUTPUTS
% seq_out: modified seq
% type_out: integer index of type of classification
% success: if the last action occured succesfully
% class_stage_out: the stage in the process 
% (how many times this function has been called)
% classification_complete_bool: if the entire process is finished

%%%INPUTS
% seq_in: seq from tracking
% activefig: the figure where cells are selected
% activefig_handles: all handles in the tracking window
% activefig_states: the state of the controls in the tracking window enabled/disabled
% classification_stage: the stage in the process before this function was called
% type_in: the type of classification (if it was already specified at a previous call)


figure(activefig);
seq_out = seq_in;
type_out = type_in;
classification_complete_bool = false;
success = false;
startCol = 240/255.*[1,1,1];

if classification_stage == 0 
    pstr = 'classification type';
    typelist = {'auto-classify','add appearing','add disappearing','add dividing',...
                'remove appearing','remove disappearing','remove dividing'};
    fprintf('Select classification category \n');
    [type_out,success] = listdlg('PromptString',pstr,...
                    'SelectionMode','single',...
                    'ListString',typelist,...
                    'OKString','classify',...
                    'CancelString','cancel');
    if success
        class_stage_out = classification_stage+1;
        set(activefig_handles.classifytrack,'BackgroundColor',[0.9,0.4,0]);
    else
        class_stage_out = 0;
        set(activefig_handles.classifytrack,'BackgroundColor',startCol);
    end
    return
end

% classification_stage > 0, doing classification action
if classification_stage == 1
%     class_stage_out = classification_stage;
    switch type_in
        case 1 %'auto_classify'
            [seq_out, success] = auto_classify_cell(seq_in, activefig_handles, startCol);       
        case 2 %'add appearing'
            [seq_out, success] = classify_appearing_cell(seq_in, activefig_handles, startCol);
        case 3 %'add disappearing'
            [seq_out, success] = classify_disappearing_cell(seq_in, activefig_handles, startCol);
        case 4 %'add dividing'
            [seq_out, success] = classify_dividing_cell(seq_in, activefig_handles, startCol);
        case 5 %'remove appearing'
            [seq_out, success] = remove_appearing_cell(seq_in, activefig_handles, startCol);
        case 6 %'remove disappearing'
            [seq_out, success] = remove_disappearing_cell(seq_in, activefig_handles, startCol);
        case 7 %'remove dividing'
            [seq_out, success] = remove_dividing_cell(seq_in, activefig_handles, startCol);
    end
end
    

% success = true;
class_stage_out = classification_stage+1;
classification_complete_bool = true;
if success
    actn_str = 'Action finished... updating annotations... \n';
    fprintf(actn_str);
    orbit = get_orbit_frames(activefig_handles,seq_out);
    seq_out = extern_show_div_cells(activefig_handles,seq_out,orbit);
end
fprintf('\n');


function orbit = get_orbit_frames(handles,seq)
l = str2double(get(handles.t_from, 'string')); 
r = str2double(get(handles.t_to, 'string'));
b = str2double(get(handles.z_from, 'string'));
t = str2double(get(handles.z_to, 'string'));
orbit = nonzeros(seq.frames_num(l:r, b:t))';

function [seq_out, success] = ...
    auto_classify_cell(seq_in, activefig_handles, startCol)
success = false;
seq_out = seq_in;
% startCol = get(activefig_handles.classifytrack,'BackgroundColor');
actn_str = 'Identify cell marked as tracking error for autoclassification \n';
fprintf(actn_str);



t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == 1 || frame_num == length(seq_in.frames)
    display('cannot classify cells on first or last frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;


% fprintf('Select dividing cell to classify \n');
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);

[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end



%%% check that it is a tracking error
%%% find out if it's appearing or disappearing
%%% save into appropriate list

cell_GID = seq_in.inv_cells_map(frame_num,cell_id);
appearance_found_bool = false;
disappearance_found_bool = false;
if sum(seq_in.frames(frame_num).cells==cell_id)>0
    f_prev = frame_num-1;
    f_next = frame_num+1;
    locID_prev = nonzeros(seq_in.cells_map(f_prev,cell_GID));
    locID_next = nonzeros(seq_in.cells_map(f_next,cell_GID));
    if isempty(locID_prev) && isempty(locID_next)
        display('cell exists only in given frame, cannot classify');
    else
        if isempty(locID_prev) && ~isempty(locID_next)
            display('cell recognized as appearing in frame selected');
            appearance_found_bool = true;
        end
        if ~isempty(locID_prev) && isempty(locID_next)
            display('cell recognized as disappearing in frame selected');
            disappearance_found_bool = true;
        end
    end
else
    display('cell NOT recognized as a tracking error in frame selected');
end
    
    
autoclass_cell.t = t;
autoclass_cell.frame_num = frame_num;
autoclass_cell.x_pos = tmp_geom.circles(cell_id,2);
autoclass_cell.y_pos = tmp_geom.circles(cell_id,1);
autoclass_cell.local_ID = cell_id;
autoclass_cell.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
autoclass_cell.click_x_pos = x;
autoclass_cell.click_y_pos = y;


if appearance_found_bool && ~disappearance_found_bool
    appear_exists = ~isempty(dir('appearing_cells.mat'));
    if appear_exists
        load appearing_cells %loads variable 'dividing_cells'
        appearing_cells(end+1) = autoclass_cell;
    else
        appearing_cells = autoclass_cell;
    end
    save appearing_cells appearing_cells
end

if ~appearance_found_bool && disappearance_found_bool
    disappear_exists = ~isempty(dir('disappearing_cells.mat'));
    if disappear_exists
        load disappearing_cells %loads variable 'dividing_cells'
        disappearing_cells(end+1) = autoclass_cell;
    else
        disappearing_cells = autoclass_cell;
    end
    save disappearing_cells disappearing_cells
end
success = true;


function [seq_out, success] = ...
    classify_appearing_cell(seq_in, activefig_handles, startCol)
success = false;
seq_out = seq_in;
% startCol = get(activefig_handles.classifytrack,'BackgroundColor');
actn_str = 'Identify appearing cell in first frame that it appears \n';
fprintf(actn_str);



t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == 1
    display('cannot classify cells appearing on first frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;


% fprintf('Select dividing cell to classify \n');
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);

[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end



%%% check that it is appearing in the frame that is selected
%%% if not then check that it appears when already in the ROI
%%% if not then it cannot be classified as an appearing cell

cell_GID = seq_in.inv_cells_map(frame_num,cell_id);
appearance_found_bool = false;
if sum(seq_in.frames(frame_num).cells==cell_id)>0
    f_prev = frame_num-1;
    locID = nonzeros(seq_in.cells_map(f_prev,cell_GID));
    if ~isempty(locID)
        display('cell exists in previous frame, it is disappearing, not appearing');
    else
        display('cell recognized as appearing in frame selected');
        appearance_found_bool = true;
    end
else
    display('cell NOT recognized as appearing in frame selected, searching for appearance inside ROI');
    
    
%     for fI = frame_num:-1:1
    fI = frame_num;
    while (fI>=1)&&~appearance_found_bool
        locID = nonzeros(seq_in.cells_map(fI,cell_GID));
        if ~isempty(locID)
            if sum(seq_in.frames(fI).cells==locID)>0
                display('cell recognized as appearing in an earlier frame');
                appearance_found_bool = true;
                continue
            end
        end
        fI = fI - 1;
    end
    
end

if ~appearance_found_bool
    display('cell NOT recognized as appearing in selected frame or at any earlier frame');
end


appearing_cell.t = t;
appearing_cell.frame_num = frame_num;
appearing_cell.x_pos = tmp_geom.circles(cell_id,2);
appearing_cell.y_pos = tmp_geom.circles(cell_id,1);
appearing_cell.local_ID = cell_id;
appearing_cell.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
appearing_cell.click_x_pos = x;
appearing_cell.click_y_pos = y;

appear_exists = ~isempty(dir('appearing_cells.mat'));
if appear_exists
    load appearing_cells %loads variable 'dividing_cells'
    appearing_cells(end+1) = appearing_cell;
else
    appearing_cells = appearing_cell;
end
save appearing_cells appearing_cells
success = true;



function [seq_out, success] = ...
    classify_disappearing_cell(seq_in, activefig_handles, startCol)

success = false;
seq_out = seq_in;
% startCol = get(activefig_handles.classifytrack,'BackgroundColor');
actn_str = 'Identify dividing cell in last frame before division \n';
fprintf(actn_str);
% ttl_str = 'Classification Instructions';
% uiwait(msgbox(actn_str,ttl_str,'modal'));
% enable_all_controls(activefig_handles, activefig_states);

t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == 1
    display('cannot classify cells appearing on first frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;


% fprintf('Select dividing cell to classify \n');
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);

[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end

%%% check that it is disappearing in the frame that is selected
%%% if not then check that it disappears when already in the ROI
%%% if not then it cannot be classified as an disappearing cell
cell_GID = seq_in.inv_cells_map(frame_num,cell_id);
disappearance_found_bool = false;
if sum(seq_in.frames(frame_num).cells==cell_id)>0
	f_next = frame_num+1;
    locID = nonzeros(seq_in.cells_map(f_next,cell_GID));
    if ~isempty(locID)
        display('cell exists in next frame, it is appearing, not disappearing');
    else
        display('cell recognized as disappearing in frame selected');
        disappearance_found_bool = true;
    end
else
    display('cell NOT recognized as disappearing in frame selected, searching for disappearance inside ROI');
	fI = frame_num;
    while (fI<=length(seq_in.frames))&&~disappearance_found_bool
        locID = nonzeros(seq_in.cells_map(fI,cell_GID));
        if ~isempty(locID)
            if sum(seq_in.frames(fI).cells==locID)>0
                display('cell recognized as disappearing in a later frame');
                disappearance_found_bool = true;                
            end
        end
        fI = fI+1;
    end
end

if ~disappearance_found_bool
    display('cell NOT recognized as disappearing in selected frame or at any later frame');
end


disappearing_cell.t = t;
disappearing_cell.frame_num = frame_num;
disappearing_cell.x_pos = tmp_geom.circles(cell_id,2);
disappearing_cell.y_pos = tmp_geom.circles(cell_id,1);
disappearing_cell.local_ID = cell_id;
disappearing_cell.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
disappearing_cell.click_x_pos = x;
disappearing_cell.click_y_pos = y;

disappear_exists = ~isempty(dir('disappearing_cells.mat'));
if disappear_exists
    load disappearing_cells %loads variable 'dividing_cells'
    disappearing_cells(end+1) = disappearing_cell;
else
    disappearing_cells = disappearing_cell;
end
save disappearing_cells disappearing_cells
success = true;


function [seq_out, success] = ...
    classify_dividing_cell(seq_in, activefig_handles, startCol)
% 1. identify dividing cell in last frame before division
% 2. identify 2 daughter cells in next frame
%%%NOTES: (use local IDs)
%%% how to maintain division maps when geometry changes:
%%% save data about the spatial and temporal locations of the cells
%%% rather than the cell id numbers, which can change with changes to geom.
success = false;
seq_out = seq_in;
% startCol = get(activefig_handles.classifytrack,'BackgroundColor');
actn_str = 'Identify dividing cell in last frame before division \n';
fprintf(actn_str);
% ttl_str = 'Classification Instructions';
% uiwait(msgbox(actn_str,ttl_str,'modal'));
% enable_all_controls(activefig_handles, activefig_states);

t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == length(seq_in.frames)
    display('cannot classify cells dividing on last frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;


% fprintf('Select dividing cell to classify \n');
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);

[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end


dividing_cell.parent.t = t;
dividing_cell.parent.frame_num = frame_num;
dividing_cell.parent.x_pos = tmp_geom.circles(cell_id,2);
dividing_cell.parent.y_pos = tmp_geom.circles(cell_id,1);
dividing_cell.parent.local_ID = cell_id;
dividing_cell.parent.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
dividing_cell.parent.click_x_pos = x;
dividing_cell.parent.click_y_pos = y;


%%%Move the frame up to the next time point

set(activefig_handles.frame_number, 'string',num2str(frame_num+1));
update_frame(activefig_handles);
t = str2double(get(activefig_handles.frame_number, 'string'));
frame_num = seq_in.frames_num(t, z);
tmp_geom = seq_in.frames(frame_num).cellgeom;
dividing_cell.daughters.t = t;
dividing_cell.daughters.frame_num = frame_num;
prevID = 0;
for i=1:2
    fprintf(['Select daughter cell #',num2str(i),'\n']);
    set(activefig_handles.classifytrack,'BackgroundColor',[0 (i-1) 1]);
    [x,y, button] = ginput(1);
    set(activefig_handles.classifytrack,'BackgroundColor',startCol);
    set(activefig_handles.classifytrack,'BackgroundColor',startCol);
    if isempty(x) || button == 27 || button == 3
        return
    end

    cell_id = cell_from_pos(x, y, tmp_geom);
    if cell_id == 0
        h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
        waitfor(h);
        return
    end
    
	if cell_id == prevID
        h = msgbox('Selected same daughter cell twice', '', 'none', 'modal');
        waitfor(h);
        return
    end
    
    dividing_cell.daughters.x_pos(i) = tmp_geom.circles(cell_id,2);
    dividing_cell.daughters.y_pos(i) = tmp_geom.circles(cell_id,1);
    dividing_cell.daughters.local_ID(i) = cell_id;
    dividing_cell.daughters.global_ID(i) = seq_in.inv_cells_map(frame_num,cell_id);
    dividing_cell.daughters.click_x_pos(i) = x;
    dividing_cell.daughters.click_y_pos(i) = y;
    prevID = cell_id;
end

success = true;

if ~isfield(seq_out.frames(frame_num),'dividing_cells')
    seq_out.frames(frame_num).dividing_cells = dividing_cell;
else
    seq_out.frames(frame_num).dividing_cells(end+1) = dividing_cell;
end


div_exists = ~isempty(dir('dividing_cells.mat'));
if div_exists
    load dividing_cells %loads variable 'dividing_cells'
    dividing_cells(end+1) = dividing_cell;
else
    dividing_cells = dividing_cell;
end
save dividing_cells dividing_cells


function [seq_out, success] = ...
    remove_disappearing_cell(seq_in, activefig_handles, startCol)

success = false;
seq_out = seq_in;
actn_str = 'Identify disappearing cell \n';
fprintf(actn_str);


t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == length(seq_in.frames)
    display('cannot classify cells disappearing on last frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);
[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end


disappearing_cell.t = t;
disappearing_cell.frame_num = frame_num;
disappearing_cell.x_pos = tmp_geom.circles(cell_id,2);
disappearing_cell.y_pos = tmp_geom.circles(cell_id,1);
disappearing_cell.local_ID = cell_id;
disappearing_cell.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
disappearing_cell.click_x_pos = x;
disappearing_cell.click_y_pos = y;

starting_dis_cells = load_and_clean_disappearing_cells(seq_in);


if any(disappearing_cell.global_ID==[starting_dis_cells(:).global_ID])
    display('disappearing cell found... deleting from list');
else
    display('disappearing cell NOT found... exiting');
    return
end

remove_ind = disappearing_cell.global_ID==[starting_dis_cells(:).global_ID];
disappearing_cells = starting_dis_cells(~remove_ind);
save disappearing_cells disappearing_cells
success = true;


function [seq_out, success] = ...
    remove_appearing_cell(seq_in, activefig_handles, startCol)

success = false;
seq_out = seq_in;
actn_str = 'Identify appearing cell \n';
fprintf(actn_str);


t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == 1
    display('cannot classify cells appearing on first frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);
[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end


appearing_cell.t = t;
appearing_cell.frame_num = frame_num;
appearing_cell.x_pos = tmp_geom.circles(cell_id,2);
appearing_cell.y_pos = tmp_geom.circles(cell_id,1);
appearing_cell.local_ID = cell_id;
appearing_cell.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
appearing_cell.click_x_pos = x;
appearing_cell.click_y_pos = y;

starting_app_cells = load_and_clean_appearing_cells(seq_in);


if any(appearing_cell.global_ID==[starting_app_cells(:).global_ID])
    display('appearing cell found... deleting from list');
else
    display('appearing cell NOT found... exiting');
    return
end

remove_ind = appearing_cell.global_ID==[starting_app_cells(:).global_ID];
appearing_cells = starting_app_cells(~remove_ind);
save appearing_cells appearing_cells
success = true;


function [seq_out, success] = ...
    remove_dividing_cell(seq_in, activefig_handles, startCol)
success = false;
seq_out = seq_in;
actn_str = 'Identify dividing cell in last frame before division \n';
fprintf(actn_str);

t = str2double(get(activefig_handles.frame_number, 'string'));
z = str2double(get(activefig_handles.slice_number, 'String'));
frame_num = seq_in.frames_num(t, z);
if frame_num == length(seq_in.frames)
    display('cannot classify cells dividing on last frame');
    return
end
tmp_geom = seq_in.frames(frame_num).cellgeom;
set(activefig_handles.classifytrack,'BackgroundColor',[1 0 0]);
[x,y, button] = ginput(1);
set(activefig_handles.classifytrack,'BackgroundColor',startCol);
if isempty(x) || button == 27 || button == 3
    return
end

cell_id = cell_from_pos(x, y, tmp_geom);
if cell_id == 0
    h = msgbox('Failed to find a cell where you clicked', '', 'none', 'modal');
    waitfor(h);
    return
end

dividing_cell.parent.t = t;
dividing_cell.parent.frame_num = frame_num;
dividing_cell.parent.x_pos = tmp_geom.circles(cell_id,2);
dividing_cell.parent.y_pos = tmp_geom.circles(cell_id,1);
dividing_cell.parent.local_ID = cell_id;
dividing_cell.parent.global_ID = seq_in.inv_cells_map(frame_num,cell_id);
dividing_cell.parent.click_x_pos = x;
dividing_cell.parent.click_y_pos = y;


starting_div_cells = load_and_clean_div_cells(seq_in);
pCells = [starting_div_cells(:).parent];
if any(dividing_cell.parent.global_ID==[pCells(:).global_ID])
    display('dividing cell found... deleting from list');
else
    display('dividing cell NOT found... exiting');
    return
end

remove_ind = dividing_cell.parent.global_ID==[pCells(:).global_ID];
dividing_cells = starting_div_cells(~remove_ind);
save dividing_cells dividing_cells
success = true;

function div_cells = load_and_clean_div_cells(seq)
load('dividing_cells');
[~,dividing_cells] = refresh_division_cell_data(seq,dividing_cells);
pCells = [dividing_cells(:).parent];
[~,keeps,~] = unique([pCells(:).global_ID]);
% [C,IA,IC] = unique(A)
% C = A(IA)
% A = C(IC)
div_cells = dividing_cells(keeps);


function disappearing_cells_out = load_and_clean_disappearing_cells(seq)
load('disappearing_cells');
[~,disappearing_cells] = refresh_disappearance_cell_data(seq,disappearing_cells);
[~,keeps,~] = unique([disappearing_cells(:).global_ID]);
disappearing_cells_out = disappearing_cells(keeps);

function appearing_cells_out = load_and_clean_appearing_cells(seq)
load('appearing_cells');
[~,appearing_cells] = refresh_disappearance_cell_data(seq,appearing_cells);
[~,keeps,~] = unique([appearing_cells(:).global_ID]);
appearing_cells_out = appearing_cells(keeps);



