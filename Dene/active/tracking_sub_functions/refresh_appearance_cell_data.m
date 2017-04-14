function [seq,appearing_cells] = refresh_appearance_cell_data(seq,appearing_cells)

if nargin<1
    seq = load_dir(pwd);
end

if nargin <2
    if ~isempty(dir('appearing_cells_cells.mat'))
        load appearing_cells_cells
    else
        display('missing ''appearing_cells_cells'' file');
    end
end

size_scale = 1;
if seq.min_z == seq.max_z 
    [seq.inv_cells_map,seq.cells_map] = track_movie_no_z(seq, size_scale);
else
    [seq.inv_cells_map,seq.cells_map] = track_movie(seq);
end
[seq.inv_edges_map,seq.edges_map] = track_edges(seq);


%inv_cells_map local->global
%cells_map global-> local

    
for i = 1:length(appearing_cells)

    frame_num = appearing_cells(i).frame_num;
    tmp_geom = seq.frames(frame_num).cellgeom;
    local_ID = cell_from_pos(appearing_cells(i).x_pos, appearing_cells(i).y_pos, tmp_geom);
    global_ID = seq.inv_cells_map(frame_num,local_ID);
    appearing_cells(i).global_ID = global_ID;
end