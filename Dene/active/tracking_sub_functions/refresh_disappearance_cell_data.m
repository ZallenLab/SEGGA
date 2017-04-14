function [seq,disappearing_cells] = refresh_disappearance_cell_data(seq,disappearing_cells)

if nargin<1
    seq = load_dir(pwd);
end

if nargin <2
    if ~isempty(dir('disappearing_cells.mat'))
        load disappearing_cells
    else
        display('missing ''disappearing_cells'' file');
    end
end

size_scale = 1;
if seq.min_z == seq.max_z 
    [seq.inv_cells_map seq.cells_map] = track_movie_no_z(seq, size_scale);
else
    [seq.inv_cells_map seq.cells_map] = track_movie(seq);
end
[seq.inv_edges_map seq.edges_map] = track_edges(seq);


%inv_cells_map local->global
%cells_map global-> local

    
for i = 1:length(disappearing_cells)

    frame_num = disappearing_cells(i).frame_num;
    tmp_geom = seq.frames(frame_num).cellgeom;
    local_ID = cell_from_pos(disappearing_cells(i).x_pos, disappearing_cells(i).y_pos, tmp_geom);
    global_ID = seq.inv_cells_map(frame_num,local_ID);
    disappearing_cells(i).global_ID = global_ID;
end