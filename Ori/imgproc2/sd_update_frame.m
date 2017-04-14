function sd_update_frame(handles, t, z)
persistent cellsH imageH currentfig 
persistent geomH edgesH


delete(cellsH(ishandle(cellsH)));
%delete(geomH(ishandle(geomH))); 
delete(edgesH(ishandle(edgesH))); 
% if i == 0 
%     return
% end

%hide = get(handles.hide, 'value');
hide = false;
current_frame = str2double(get(handles.frame_number, 'string'));
currentfig = handles.figure1;
drawingfig = currentfig;
% if get(handles.newfig_check, 'value')
%     drawingfig = getappdata(handles.figure1, 'drawingfig');
% end

global seq
%seq = getappdata(currentfig, 'seq');
sd_frames = getappdata(currentfig, 'sd_frames');
i = seq.frames_num(t,z);
directory = seq.directory;
filename = seq.frames(i).img_file;
img = imread(fullfile(directory, filename));
 
if getappdata(currentfig, 'first_time')
    setappdata(currentfig, 'first_time', 0);    
    figure(drawingfig)
    if currentfig == drawingfig
        if ishandle(handles.image_axes)
            axes(handles.image_axes);
        end
    end
    if getappdata(currentfig, 'new_win')
        imageH = imagesc(img);
        setappdata(currentfig, 'new_win', 0)
        colormap(gray);
        axis off;
        axis image;
        hold on

    else
        if ishandle(imageH)
            set(imageH, 'cdata', img); 
        else
            axes(handles.image_axes);
            imageH = imagesc(img);
            colormap(gray);
            axis off;
            axis image;
            hold on
        end
    end
    draw_patch_dummy(drawingfig, 'solid');
else
    set(imageH, 'cdata', img);
end

cells = seq.frames(i).cells(getappdata(currentfig, 'cells'));
cells_colors = seq.frames(i).cells_colors;
cells_alphas = seq.frames(i).cells_alphas;
data_filename = seq.frames(i).filename;
user_edges = getappdata(currentfig, 'edges');
setappdata(currentfig, 'filename', data_filename);

t = seq.frames(i).t;
z = seq.frames(i).z;
set(handles.frame_info, 'string', sprintf('t: %u\nz: %u',t,z));  
set(handles.frame_slider, 'value', t);
set(handles.frame_number, 'String', t);

if hide
    return
end


cells_colors = cells_colors(nonzeros(cells),:);
% if get(handles.drawing_method, 'userdata') == 1
%     alphas = cells_alphas(nonzeros(cells));
% else
%     alphas = 1;
% end
alphas = 1;
if any(cells) 
    switch 2%get(handles.drawing_style, 'userdata')
        case 1 %entire cell
            cell_nodes = cell2struct({seq.frames(i).celldata(nonzeros(cells)).nodes}, 'nodes', 1);
            draw_patches;
        case 2 %cell interior
            cell_nodes = cell2struct({seq.frames(i).celldata(nonzeros(cells)).nodes_inside}, 'nodes', 1);
            draw_patches
        case 3 %symbol
            cellsH = scatter(get(drawingfig,'CurrentAxes'), ...
                seq.frames(i).cellgeom.circles(nonzeros(cells),2), ...
                seq.frames(i).cellgeom.circles(nonzeros(cells),1), ...
                64, cells_colors, 'x');
    end
else
    cellsH = [];
    figure(drawingfig);
end




if gca ~= handles.image_axes
    axes(handles.image_axes);
end
edges = seq.frames(i).cellgeom_edit.edges(nonzeros(seq.edges_map(i, user_edges)), :);
if ~isempty(edges)
    X = [seq.frames(i).cellgeom_edit.nodes(edges(:,1),2), ...
        seq.frames(i).cellgeom_edit.nodes(edges(:,2),2)];
    Y = [seq.frames(i).cellgeom_edit.nodes(edges(:,1),1), ...
        seq.frames(i).cellgeom_edit.nodes(edges(:,2),1)];
    edgesH = patch(X', Y', [0 0.5 0], 'FaceAlpha', 1, ...
        'LineWidth', 2, 'EdgeColor', [1 0 0]);
end
if 0 %get(handles.draw_geometry, 'value')
    X = [seq.frames(i).cellgeom_edit.nodes(edges(ind,1),2), ...
        seq.frames(i).cellgeom_edit.nodes(edges(ind,2),2)];
    Y = [seq.frames(i).cellgeom_edit.nodes(edges(ind,1),1), ...
        seq.frames(i).cellgeom_edit.nodes(edges(ind,2),1)];
    geomH = patch(X', Y', [0 0.5 0], 'FaceAlpha', 1, 'EdgeColor', [0 1 0]);
end
drawnow;

    
    function draw_patches
        axes(handles.image_axes);
        cellsH = draw_highlighted_cells(drawingfig, cell_nodes, ...
            cells_colors, alphas);
    end
end
