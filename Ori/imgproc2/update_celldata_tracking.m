function success = update_celldata_tracking(handles, current_frame)
global seq
success = true;
readonly = strcmp(lower(get(handles.readonly_menu, 'Checked')), 'on');
if readonly
    return
end
try 
    if isappdata(handles.figure1, 'update_celldata') && ...
        getappdata(handles.figure1, 'update_celldata')
        disp (['updating celldata ' num2str(current_frame)]);
        cellgeom = fix_geom(seq.frames(current_frame).cellgeom_edit);
        a = seq.frames(current_frame).cellgeom.circles(:,1:2)';
        b = cellgeom.circles(:,1:2)';
        [cells_map inv_cell_map] = track(a,b);
        cellgeom.selected_cells(:) = false;
        cellgeom.selected_cells(nonzeros(...
            cells_map(seq.frames(current_frame).cellgeom.selected_cells))) = true;
        filename = seq.frames(current_frame).filename;
        save(filename, 'cellgeom', '-v6', '-append');
        seq.frames(current_frame).cellgeom_edit = cellgeom;
        seq.frames(current_frame).changed = 0;
        seq.frames(current_frame).saved = true;
        setappdata(handles.figure1, 'update_celldata', 0)
    end
catch
    success = false;
    filename = [datestr(now, 30) '.mat'];
    try 
        save(filename, 'seq');
    catch
        str = sprintf('Error. \nUnable to save and unable to dump change to disk. \nDO NOT CONTINUE.');
        h = msgbox(str, 'Error while saving', 'error');
        waitfor(h);
    end
    str = sprintf('Error. \nUnable to save. \nChanges dumped to %s',  filename);
    h = msgbox(str, 'Error while saving', 'error');
    waitfor(h);
end
