function seq_out = extern_show_div_cells(handles,seq,orbit)

% Clear all errors
% Draw back tracking error highlights at the end
% if those cells are not included in the dividing, disappearing, and
% appearing cells
seq_out = seq;
for fInd = 1:length(seq_out.frames)
    seq_out.frames(fInd).cells = [];
end


%%% Dividing Cells
div_exists = ~isempty(dir('dividing_cells.mat'));
if ~div_exists
    display('no dividing_cells file');    
else
    load dividing_cells %loads variable 'dividing_cells'

    [seq_out,dividing_cells] = refresh_division_cell_data(seq_out,dividing_cells);

    hl_win = 20; %highlight for 30 frames
    %%%wipe out tracking errors and cell colors for cells dividing
    pCells = [dividing_cells(:).parent];
    dCells = [dividing_cells(:).daughters];
    all_div_IDs = [pCells(:).global_ID,dCells(:).global_ID];

    for fInd = 1:length(seq_out.frames)
        divcells_local_IDs = nonzeros(seq_out.cells_map(fInd,all_div_IDs));
        divcells_bool = ismember(seq_out.frames(fInd).cells,divcells_local_IDs);
        seq_out.frames(fInd).cells = seq_out.frames(fInd).cells(~divcells_bool);
        seq_out.frames(fInd).cells_colors(divcells_local_IDs,:) = 0;
    end

    %%%color those dividing cells
    for i = 1:length(dividing_cells)
        parent_global_ID = dividing_cells(i).parent.global_ID;
        parent_frame_num = dividing_cells(i).parent.frame_num;
        for ii = 1:parent_frame_num
            parent_local_ID = seq_out.cells_map(ii,parent_global_ID);
            if parent_local_ID~=0
                prox2event = max(1-(parent_frame_num-ii)/min(hl_win,parent_frame_num),0);
                seq_out.frames(ii).cells = [seq_out.frames(ii).cells,parent_local_ID];
                seq_out.frames(ii).cells_colors(parent_local_ID,:) = min(seq_out.frames(ii).cells_colors(parent_local_ID,:)+[prox2event 0 0],1);
                seq_out.frames(ii).cells_alphas(parent_local_ID) = max(seq_out.frames(ii).cells_alphas(parent_local_ID),ii/parent_frame_num);
            end
        end
        daughters_global_IDs = dividing_cells(i).daughters.global_ID;
        daughters_frame_num = dividing_cells(i).daughters.frame_num;
        for ii = daughters_frame_num:length(seq_out.frames)
            daughters_local_IDs = nonzeros(seq_out.cells_map(ii,daughters_global_IDs))';
            if ~isempty(daughters_local_IDs)
                prox2event = max(1-(ii-daughters_frame_num)/hl_win,0);
                seq_out.frames(ii).cells = [seq_out.frames(ii).cells,daughters_local_IDs];
                seq_out.frames(ii).cells_colors(daughters_local_IDs,:) = seq_out.frames(ii).cells_colors(daughters_local_IDs,:)+repmat([0 0 1],length(daughters_local_IDs),1);
                seq_out.frames(ii).cells_alphas(daughters_local_IDs) = max(seq_out.frames(ii).cells_alphas(daughters_local_IDs),prox2event);
            end
        end
    end
end


%%% Disappearing cells
disappearing_exists = ~isempty(dir('disappearing_cells.mat'));
if disappearing_exists
    load disappearing_cells %loads variable 'disappearing_cells'
else
    display('no disappearing_cells file');
    disappearing_cells = [];
end
%%%need to refresh in case geom changed
[seq_out,disappearing_cells] = refresh_disappearance_cell_data(seq_out,disappearing_cells);

hl_win = 20; %highlight for 30 frames
%%%wipe out tracking errors and cell colors for cells disappearing
all_dis_IDs = unique([disappearing_cells(:).global_ID]);

for fInd = 1:length(seq_out.frames)
    dis_cells_local_IDs = nonzeros(seq_out.cells_map(fInd,all_dis_IDs));
    dis_cells_bool = ismember(seq_out.frames(fInd).cells,dis_cells_local_IDs);
    seq_out.frames(fInd).cells = seq_out.frames(fInd).cells(~dis_cells_bool);
    seq_out.frames(fInd).cells_colors(dis_cells_local_IDs,:) = 0;
end

%%%color those disappearing cells
for i = 1:length(disappearing_cells)
    global_ID = disappearing_cells(i).global_ID;
    frame_num = disappearing_cells(i).frame_num;
    for ii = 1:length(seq_out.frames)
        local_ID = seq_out.cells_map(ii,global_ID);
        if local_ID~=0
            prox2event = max(1-(frame_num-ii)/min(hl_win,frame_num),0);
            seq_out.frames(ii).cells = [seq_out.frames(ii).cells,local_ID];
            seq_out.frames(ii).cells_colors(local_ID,:) = min(seq_out.frames(ii).cells_colors(local_ID,:)+[prox2event prox2event/2 0],1);
            tmpmax =  max(seq_out.frames(ii).cells_colors(local_ID,:));
            seq_out.frames(ii).cells_colors(local_ID,:) = [tmpmax,tmpmax/2,0];
            seq_out.frames(ii).cells_alphas(local_ID) = max(seq_out.frames(ii).cells_alphas(local_ID),prox2event);
        end
    end
end


%%% Appearing cells
appearing_exists = ~isempty(dir('appearing_cells.mat'));
if appearing_exists
    load appearing_cells %loads variable 'dividing_cells'
else
    display('no appearing_cells file');
    appearing_cells = [];
end
%%%need to refresh in case geom changed
[seq_out,appearing_cells] = refresh_appearance_cell_data(seq_out,appearing_cells);

hl_win = 20; %highlight for 30 frames
%%%wipe out tracking errors and cell colors for cells appearing
all_app_IDs = unique([appearing_cells(:).global_ID]);

for fInd = 1:length(seq_out.frames)
    app_cells_local_IDs = nonzeros(seq_out.cells_map(fInd,all_app_IDs));
    app_cells_bool = ismember(seq_out.frames(fInd).cells,app_cells_local_IDs);
    seq_out.frames(fInd).cells = seq_out.frames(fInd).cells(~app_cells_bool);
    seq_out.frames(fInd).cells_colors(app_cells_local_IDs,:) = 0;
end

%%%color those appearing cells
for i = 1:length(appearing_cells)
    global_ID = appearing_cells(i).global_ID;
    frame_num = appearing_cells(i).frame_num;
    for ii = 1:length(seq_out.frames)
        local_ID = seq_out.cells_map(ii,global_ID);
        if local_ID~=0
            prox2event = max(1-abs(frame_num-ii)/hl_win,0);
            seq_out.frames(ii).cells = [seq_out.frames(ii).cells,local_ID];
            seq_out.frames(ii).cells_colors(local_ID,:) = min(seq_out.frames(ii).cells_colors(local_ID,:)+[0 prox2event prox2event/2],1);
            tmpmax =  max(seq_out.frames(ii).cells_colors(local_ID,:));
            seq_out.frames(ii).cells_colors(local_ID,:) = [0, tmpmax,tmpmax/2];
            seq_out.frames(ii).cells_alphas(local_ID) = max(seq_out.frames(ii).cells_alphas(local_ID),prox2event);
        end
    end
end

% Add tracking error highlighting back in
% only for cells that were not otherwise highlighted
c = get(handles.user_select_c, 'BackgroundColor');
a = get(handles.user_select_c, 'userData');
untracked = extern_find_untracked_cells(seq_out);
for fInd = 1:length(seq_out.frames)
     new_cells = unique([seq_out.frames(fInd).cells,untracked(fInd).fc]);
     faulty_cells = ~ismember(new_cells,seq_out.frames(fInd).cells);
     seq_out.frames(fInd).cells = new_cells;
     seq_out.frames(fInd).cells_colors(new_cells(faulty_cells),1) = c(1);
     seq_out.frames(fInd).cells_colors(new_cells(faulty_cells),2) = c(2);
     seq_out.frames(fInd).cells_colors(new_cells(faulty_cells),3) = c(3);
     seq_out.frames(fInd).cells_alphas(new_cells(faulty_cells)) = a;
end

update_frame(handles);