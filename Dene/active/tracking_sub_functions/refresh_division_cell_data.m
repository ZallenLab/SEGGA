function [seq,dividing_cells] = refresh_division_cell_data(seq,dividing_cells)

if nargin<1
    seq = load_dir(pwd);
end

if nargin <2
    if ~isempty(dir('dividing_cells.mat'))
        load dividing_cells
    else
        display('missing ''dividing_cells'' file');
    end
end

size_scale = 1;
if seq.min_z == seq.max_z 
    [seq.inv_cells_map, seq.cells_map] = track_movie_no_z(seq, size_scale);
else
    [seq.inv_cells_map, seq.cells_map] = track_movie(seq);
end
[seq.inv_edges_map, seq.edges_map] = track_edges(seq);


%inv_cells_map local->global
%cells_map global-> local

    
for i = 1:length(dividing_cells)

    parent.frame_num = dividing_cells(i).parent.frame_num;
    tmp_geom = seq.frames(parent.frame_num).cellgeom;
    parent.local_ID = cell_from_pos(dividing_cells(i).parent.x_pos, dividing_cells(i).parent.y_pos, tmp_geom);
    parent.global_ID = seq.inv_cells_map(parent.frame_num,parent.local_ID);
    

    new_daughter_gID = size(seq.cells_map,2)+1;
        
    [iR,iC] = find(seq.inv_cells_map((parent.frame_num+1):end,:)==parent.global_ID);
    [iRs,sortInds] = sort(iR);
    iRs = iRs+ parent.frame_num;
    iCs = iC(sortInds);
    mapInds = sub2ind(size(seq.inv_cells_map),iRs,iCs);
    
    seq.inv_cells_map(mapInds) = new_daughter_gID;
    seq.cells_map((parent.frame_num+1):end,parent.global_ID) = 0;
    seq.cells_map(iRs,new_daughter_gID) = iCs;
    
	daughters.frame_num = dividing_cells(i).daughters.frame_num;
    tmp_geom = seq.frames(daughters.frame_num).cellgeom;
    daughters.local_ID = arrayfun(@(x,y) cell_from_pos(x,y,tmp_geom),dividing_cells(i).daughters.x_pos, dividing_cells(i).daughters.y_pos);
    daughters.global_ID = seq.inv_cells_map(daughters.frame_num,daughters.local_ID);
    
    dividing_cells(i).daughters.global_ID = daughters.global_ID;
    dividing_cells(i).parent.global_ID = parent.global_ID;
end