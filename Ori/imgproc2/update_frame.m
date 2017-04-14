function update_frame(handles, t, z, trackingH)
if nargin <4 
    trackingH = handles.figure1;
end

% setappdata(handles.figure1, 'axes_x_lim', axes_x_lim);
% setappdata(handles.figure1, 'axes_y_lim', axes_y_lim);
start_x_lim = getappdata(handles.figure1,'start_x_lim');
start_y_lim = getappdata(handles.figure1,'start_y_lim');

persistent cellsH imageH currentfig 
persistent geomH edgesH poly_seqH vf_lineH
persistent extern_cellsH extern_imageH extern_geomH extern_edgesH extern_poly_seqH
persistent nLostH multiEdgesH
global seq
current_t = str2double(get(handles.frame_number, 'string'));
current_z = str2double(get(handles.slice_number, 'string'));

if nargin < 2
    t = current_t;
    z = current_z;
end

on_off_poly_bool = getappdata(handles.figure1,'on_off_poly_bool');
if isempty(on_off_poly_bool) 
    on_off_poly_bool = false;
end

% delete(nonzeros(cellsH(ishandle(cellsH))));
% delete(nonzeros(geomH(ishandle(geomH)))); 
% delete(nonzeros(edgesH(ishandle(edgesH)))); 
% delete(nonzeros(poly_seqH(ishandle(poly_seqH)))); 
% % DLF EDIT
% %  R2014b and after treats handles as objects and not as doubles
delete(cellsH(ishandle(cellsH)));
delete(geomH(ishandle(geomH))); 
delete(edgesH(ishandle(edgesH))); 
delete(poly_seqH(ishandle(poly_seqH)));
delete(vf_lineH(ishandle(vf_lineH)));
delete(nLostH(ishandle(nLostH)));

if t == 0 
    return
end

if isappdata(handles.figure1,'nlost_ephemeral_bool');
    nlost_ephemeral_bool = getappdata(handles.figure1,'nlost_ephemeral_bool');
else
    nlost_ephemeral_bool = false;
end



hide = get(handles.hide, 'value');
if isfield(handles,'view_vf_menu_chck')
    show_vf_bool = strcmp(get(handles.view_vf_menu_chck,'Checked'),'on');
end
current_t = str2double(get(handles.frame_number, 'string'));
current_z = str2double(get(handles.slice_number, 'string'));
% currentfig = handles.figure1;
currentfig = trackingH;
drawingfig = currentfig;
if get(handles.newfig_check, 'value')
    drawingfig = getappdata(handles.figure1, 'drawingfig');
    if ~ishandle(drawingfig)
        drawingfig = figure;
        setappdata(handles.figure1, 'drawingfig', drawingfig);
        setappdata(handles.figure1, 'first_time', 1);
    end
end


seq.t = t;
seq.z = z;
directory = seq.directory;
i = seq.frames_num(t,z);

% % DLF DEBUG EDIT September 5 2013
% if i == 0
%     display('using dlf debug [line 47 inside update_frame]');
%     i = nonzeros(seq.frames_num(t,:));
% end

current_frame = seq.frames_num(current_t, current_z);
filename = seq.frames(i).img_file;
%set(handles.frame_info, 'string', sprintf('t: %u\nz: %u',t,z));  
set(handles.frame_slider, 'value', t);
set(handles.frame_number, 'String', t);
set(handles.slice_slider, 'value', -z);
set(handles.slice_number, 'String', z);

if isfield(seq.frames(i), 'cellgeom_edit') && ~isempty(seq.frames(i).cellgeom_edit)
    cellgeom_edit = seq.frames(i).cellgeom_edit;
else
    cellgeom_edit = seq.frames(i).cellgeom;
end

if t ~= current_t | z ~= current_z;
    set(handles.undo, 'Enable', 'Off');
    update_celldata_tracking(handles, current_frame);
    setappdata(currentfig, 'touched_cells', ...
        false(length(seq.frames(i).cellgeom.circles(:,1)), 1));
    setappdata(currentfig, 'touched_edges', ...
        false(length(seq.frames(i).cellgeom.edges(:,1)), 1));
    if isappdata(handles.figure1, 'touched_clusters')
        setappdata(handles.figure1, 'touched_clusters', ...
            false(length(seq.frames(i).clusters_data), 1));
    end
    set(handles.undo, 'Enable', 'Off');
    set(handles.undo_menu, 'Enable', 'Off');
    tracking('update_orbit_frames', handles.slice_number, [], handles); 
end
set(handles.zoom_btn, 'value', 0);
zoom off
set(handles.pan_btn, 'value', 0);
pan off

if get(handles.bnr, 'value') && isdir(fullfile(directory , seq.bnr_dir))
    directory = fullfile(directory , seq.bnr_dir);
end
if getappdata(handles.figure1, 'multi_channel')
    img_info = imfinfo(fullfile(directory, filename));
    img = zeros([img_info(1).Height img_info(1).Width 3], 'uint8');
    if get(handles.channel1, 'value')
        setup_image_channel(1);
    else
        setup_no_image_channel(1);
    end
else
    img = imread(fullfile(directory, filename));
    brightness = getappdata(currentfig, 'bright_fac');
    img = img * brightness;
end


if getappdata(handles.figure1, 'multi_channel') && get(handles.channel2, 'value')
    setup_image_channel(2);
else
    setup_no_image_channel(2);
end

if getappdata(handles.figure1, 'multi_channel') && get(handles.channel3, 'value')
    setup_image_channel(3);
else
    setup_no_image_channel(3);
end

geom_edge_settings = getappdata(trackingH,'geom_edge_settings');
if isempty(geom_edge_settings)
    invertBool = false;
else
    invertBool = geom_edge_settings.invertBool;
end
if invertBool
    for img_ind = 1:size(img,3)
        img(:,:,img_ind) = max(flatten(img(:,:,img_ind)))-img(:,:,img_ind);
    end
end


if getappdata(handles.figure1, 'multi_channel') && get(handles.chan2gray_btn, 'value')
    img = img(:,:,1)*(1/3)+img(:,:,2)*(1/3)+img(:,:,3)*(1/3);
    numchans_active = get(handles.channel1, 'value') +...
                      get(handles.channel2, 'value') +...
                      get(handles.channel3, 'value');
    img = img*(3/numchans_active);
end

if getappdata(currentfig, 'first_time')
    setappdata(currentfig, 'first_time', 0);    
    figure(drawingfig)
    if currentfig == drawingfig
        if ishandle(handles.axes1)
            axes(handles.axes1);
        end
    end
    if getappdata(currentfig, 'new_win')
        imageH = image(img,'Parent', handles.axes1);
        setappdata(currentfig, 'new_win', 0)
        colormap(gray(256));
        axis off;
        axis image;
        hold on
        
        %%%DLF ADDITITON 2015.12.4
        delete(extern_imageH);
        figure(drawingfig)
        extern_imageH = image(img);
        setappdata(currentfig, 'new_win', 0)
        colormap(gray(256));
        axis off;
        axis image;
        hold on
        set(extern_imageH.Parent,'YDir','reverse');

    else
        if ishandle(imageH)
            set(imageH, 'cdata', img); 
        else
            imageH = image(img,'Parent', handles.axes1);
            colormap(handles.axes1,gray(256));%colormap(gray(256));
            axis(handles.axes1,'off');%axis off;
            axis(handles.axes1,'image');%axis image;
            hold(handles.axes1,'on');%hold on
        end
    end
    draw_patch_dummy(drawingfig, 'trans')
else
    set(imageH, 'cdata', img);
end

%%% This can only revert back to the exisiting limits of a
%%% frame (at that frame), does not revert back to the initial
%%% limits at first loading
xlimStart = handles.axes1.XLim;
ylimStart = handles.axes1.YLim;

%%%DLF ADDITITON 2015.12.4
if handles.figure1 ~= drawingfig
    %%%DLF ADDITITON 2015.12.4
    delete(extern_imageH);
    figure(drawingfig)
    extern_imageH = image(img);
    setappdata(currentfig, 'new_win', 0)
    colormap(gray(256));
    axis off;
    axis image;
    set(gca,'xlim',get(handles.axes1,'xlim'),...
        'ylim',get(handles.axes1,'ylim'));
    hold on
    if get(handles.scaleBar_btn,'value');
        scaleBarH = getappdata(drawingfig,'scaleBarH');
        if ishandle(scaleBarH)
            uistack(scaleBarH,'top');
        end
    end        
end



cells = [];
cells_colors = zeros(length(seq.frames(i).cellgeom.circles), 3);
cells_alphas = zeros(length(seq.frames(i).cellgeom.circles), 1);
user_edges = [];
if isfield(seq.frames(i), 'cells')
    cells = seq.frames(i).cells;
end
if isfield(seq.frames(i), 'cells_colors')
    cells_colors = seq.frames(i).cells_colors;
end
if isfield(seq.frames(i), 'cells_alphas')
    cells_alphas = seq.frames(i).cells_alphas;
end
if isfield(seq.frames(i), 'edges')
    user_edges = seq.frames(i).edges;
    define_edges = true;
else
    define_edges = false;
end

% DLF EDIT
if isfield(seq.frames(i), 'edges_colors')
    edges_colors = seq.frames(i).edges_colors;    
else
    edges_colors = [0 0 1];
end


data_filename = seq.frames(i).filename;

setappdata(currentfig, 'user_edges', user_edges);
setappdata(currentfig, 'user_cells', cells);
setappdata(currentfig, 'user_cells_alphas', cells_alphas);
setappdata(currentfig, 'user_cells_colors', cells_colors);
setappdata(currentfig, 'user_edge_colors', edges_colors);
setappdata(currentfig, 'filename', data_filename);

if hide
    drawnow;
    return
end

if gcf ~= drawingfig
    figure(drawingfig)
end

cells_colors = cells_colors(nonzeros(cells),:);
if get(handles.drawing_method, 'userdata') == 1
    alphas = cells_alphas(nonzeros(cells));
else
    alphas = 1;
end
if any(cells) 
    switch get(handles.drawing_style, 'userdata')
        case 1 %entire cell
            fac = seq.frames(i).cellgeom.faces(nonzeros(cells), :);
            vert = [seq.frames(i).cellgeom.nodes(:,2) seq.frames(i).cellgeom.nodes(:,1)];
            if length(nonzeros(cells)) == 1
                arg1 = [];
                arg2 = cells_colors;
            else
                arg1 = cells_colors;
                arg2 = 'flat';
            end
            cellsH = patch('Faces', fac, 'Vertices', vert, ...
                'FaceVertexCData', arg1, 'FaceColor', arg2, ...
                'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
                'AlphaDataMapping', 'none', 'edgecolor', 'none',...
                'Parent',handles.axes1);
%             cellsH = patch('Faces', fac, 'Vertices', vert, ...
%                 'FaceVertexCData', cells_colors, 'FaceColor', 'flat', ...
%                 'facealpha', 'flat', 'FaceVertexAlphaData', alphas, 'edgealpha', 0, ...
%                 'AlphaDataMapping', 'none', 'EdgeColor', 'none', 'AmbientStrength', 0);
%             
            
            
%             cell_nodes = cell2struct({seq.frames(i).celldata(nonzeros(cells)).nodes}, 'nodes', 1);
%             draw_patches;

%         case 2 %cell interior
%             cell_nodes = cell2struct({seq.frames(i).celldata(nonzeros(cells)).nodes_inside}, 'nodes', 1);
%             draw_patches;
        case 3 %symbol
            cellsH = patch('xdata', ...
                seq.frames(i).cellgeom.circles(nonzeros(cells),2),...
                'ydata',  seq.frames(i).cellgeom.circles(nonzeros(cells),1), ...
                'linestyle', 'none', 'facecolor', 'none', 'markersize', 8, ...
                'marker', 'd', 'markerfacecolor', 'flat', 'cdata', ...
                reshape(cells_colors, [], 1, 3),...
                'Parent',handles.axes1);
%             cellsH = scatter(get(drawingfig,'CurrentAxes'), ...
%                 seq.frames(i).cellgeom.circles(nonzeros(cells),2), ...
%                 seq.frames(i).cellgeom.circles(nonzeros(cells),1), ...
%                 64, cells_colors, 'd');
        case 2 %clusters
            clusters = seq.frames(i).clusters_data;
            %the order the clusters are drawn changes the way the colors of
            %overlapping clusters are blended. Therefore we follow the
            %order as it is in the global clusters map
            for j = nonzeros(seq.clusters_map(i,:))'
                if ~strcmp(class(clusters(j).boundary), 'single') %this isn't needed anymore
                    %it was used when the boundary of a single cell cluster
                    %was given by its celldata.nodes
                    cluster_nodes = seq.frames(i).cellgeom.nodes(clusters(j).boundary,:);
                else
                    cluster_nodes = clusters(j).boundary;
                end
                if ~isempty(clusters(j).cells)
                    current_color = get_cluster_colors(seq.clusters_colors(seq.inv_clusters_map(i, j)));
                    cellsH = [cellsH patch(cluster_nodes(:,2), cluster_nodes(:,1), current_color,...
                        'EdgeAlpha', 1, 'EdgeColor', [.35 .35 .35] .* current_color,...
                        'LineWidth', 2, 'FaceColor', current_color, 'FaceAlpha', 0.1,...
                        'Parent',handles.axes1)];
                end
            end
    end
else
    cellsH = [];
    figure(drawingfig);
end

%%%DLF ADDITITON 2015.12.4
if handles.figure1 ~= drawingfig
    delete(extern_cellsH);
    figure(drawingfig)
    extern_cellsH = copyobj(cellsH,drawingfig.Children);
end


if get(handles.thick_edges_check, 'value')
    edge_thickness = 2;
else
    edge_thickness = 1;
end


axesH = get(drawingfig,'CurrentAxes');
edgesH = [];
edges = cellgeom_edit.edges;
ind = true(1,length(edges(:,1)));
all_ind = ind;
if isfield(seq.frames(i), 'edges') && ~isempty(seq.frames(i).edges) ...
    && ~isempty(nonzeros(seq.frames(i).edges))
    ind(nonzeros(seq.frames(i).edges)) = false;
    X = [cellgeom_edit.nodes(edges(~ind,1),2), ...
        cellgeom_edit.nodes(edges(~ind,2),2)];
    Y = [cellgeom_edit.nodes(edges(~ind,1),1), ...
        cellgeom_edit.nodes(edges(~ind,2),1)];
    
%      DLF EDIT ('edge_colors')


% if define_edges
%     
%     edge_thickness = 2;
% 
%     edgesH = [edgesH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
%         'LineWidth', edge_thickness, 'FaceVertexCData',[edges_colors;edges_colors],...
%         'EdgeColor', 'flat')];
%     
% else
%     
%     
%     edgesH = [edgesH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
%         'LineWidth', edge_thickness, 'EdgeColor', edges_colors)];
%     all_ind(~ind) = false;
%     
% end

    
    
    edgesH = [edgesH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
        'LineWidth', edge_thickness, 'EdgeColor', [0 0.2 0.8],'Parent',handles.axes1)];
    all_ind(~ind) = false;
    
    %%% color is specified inside 'tracking.m' for this
    if ~isempty(edgesH)
        edges_color_external_01 = getappdata(edgesH(end).Parent.Parent,'edges_color01');
        if ~isempty(edges_color_external_01)
            edgesH(end).EdgeColor = edges_color_external_01;
        end
        
        edges_alpha_external_01 = getappdata(edgesH(end).Parent.Parent,'edges_alpha01');
        if ~isempty(edges_alpha_external_01)
            edgesH(end).EdgeAlpha = edges_alpha_external_01;
        end
    end
       
    
%     DEBUG
    %%%%%%%%%%%%%%%%%%%%
 
% %     
%     X = [ORI_X12(i, eds_ori)', ORI_X22(i, eds_ori)'];
%     Y = [ORI_Y12(i, eds_ori)', ORI_Y22(i, eds_ori)'];
%     edgesH = [edgesH patch(Y', X', [0 0.5 0], 'FaceAlpha', 0, ...
%         'LineWidth', edge_thickness, 'EdgeColor', [1 1 0])];
%     
    %%%%%%%%%%%%%%%%%%%
       
end

if ~isempty(whos('multiEdgesH'))
    if ishandle(multiEdgesH)
        delete(multiEdgesH);
    end
end

if isfield(seq.frames(i),'edges_individual_colors') && ...
        ~isempty(seq.frames(i).edges_individual_colors)
    
    %%%Showing Edge Contraction Velocities
    edgeInds =  seq.frames(i).edges_velocity_inds;
    X = [cellgeom_edit.nodes(edges(edgeInds,1),2), ...
        cellgeom_edit.nodes(edges(edgeInds,2),2)];
    Y = [cellgeom_edit.nodes(edges(edgeInds,1),1), ...
        cellgeom_edit.nodes(edges(edgeInds,2),1)];
    edgeCols = seq.frames(i).edges_individual_colors;
    matCols = mat2cell(edgeCols,ones(size(edgeCols,1),1),3);
    multiEdgesH = plot(X', Y','Parent',handles.axes1,'LineWidth',3);
    [multiEdgesH(:).Color] = deal(matCols{:});

end

if isfield(seq.frames(i), 'edges2') && ~isempty(seq.frames(i).edges2) ...
    && ~isempty(nonzeros(seq.frames(i).edges2))
    ind(nonzeros(seq.frames(i).edges)) = true;
    ind(nonzeros(seq.frames(i).edges2)) = false;
    X = [cellgeom_edit.nodes(edges(~ind,1),2), ...
        cellgeom_edit.nodes(edges(~ind,2),2)];
    Y = [cellgeom_edit.nodes(edges(~ind,1),1), ...
        cellgeom_edit.nodes(edges(~ind,2),1)];
    edgesH = [edgesH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
        'LineWidth', edge_thickness, 'EdgeColor', [1 0 0],'Parent',handles.axes1)];
    all_ind(~ind) = false; 
    
    
    
	%%% color is specified inside 'tracking.m' for this
    edges_color_external_02 = getappdata(edgesH(end).Parent.Parent,'edges_color02');
    if ~isempty(edges_color_external_02)
        edgesH(end).EdgeColor = edges_color_external_02;
    end
    edges_alpha_external_02 = getappdata(edgesH(end).Parent.Parent,'edges_alpha02');
	if ~isempty(edges_alpha_external_02)
        edgesH(end).EdgeAlpha = edges_alpha_external_02;
    end
end
if isfield(seq.frames(i), 'edges3') && ~isempty(seq.frames(i).edges3) ...
    && ~isempty(nonzeros(seq.frames(i).edges3))
    ind(nonzeros(seq.frames(i).edges)) = true;
    ind(nonzeros(seq.frames(i).edges2)) = true;
    ind(nonzeros(seq.frames(i).edges3)) = false;
    X = [cellgeom_edit.nodes(edges(~ind,1),2), ...
        cellgeom_edit.nodes(edges(~ind,2),2)];
    Y = [cellgeom_edit.nodes(edges(~ind,1),1), ...
        cellgeom_edit.nodes(edges(~ind,2),1)];
    edgesH = [edgesH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
        'LineWidth', edge_thickness, 'EdgeColor', [1 0 1],'Parent',handles.axes1)];
    all_ind(~ind) = false;
	%%% color is specified inside 'tracking.m' for this
    edges_color_external_03 = getappdata(edgesH(end).Parent.Parent,'edges_color03');
    if ~isempty(edges_color_external_03)
        edgesH(end).EdgeColor = edges_color_external_03;
    end
end
if isfield(seq.frames(i), 'edges4') && ~isempty(seq.frames(i).edges4) ...
    && ~isempty(nonzeros(seq.frames(i).edges4))
    ind(nonzeros(seq.frames(i).edges)) = true;
    ind(nonzeros(seq.frames(i).edges2)) = true;
    ind(nonzeros(seq.frames(i).edges3)) = true;
    ind(nonzeros(seq.frames(i).edges4)) = false;
    X = [cellgeom_edit.nodes(edges(~ind,1),2), ...
        cellgeom_edit.nodes(edges(~ind,2),2)];
    Y = [cellgeom_edit.nodes(edges(~ind,1),1), ...
        cellgeom_edit.nodes(edges(~ind,2),1)];
    edgesH = [edgesH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
        'LineWidth', edge_thickness, 'EdgeColor', [1 1 0],'Parent',handles.axes1)];
    all_ind(~ind) = false;
end
geom_edge_settings = getappdata(trackingH,'geom_edge_settings');
if isempty(geom_edge_settings)
    geom_color = [0 1 0];
    geom_thickness = 1;
    invertBool = false;
else
    geom_color  = geom_edge_settings.color;
    geom_thickness = geom_edge_settings.thickness;
    invertBool = geom_edge_settings.invertBool;
end


if get(handles.draw_geometry, 'value')
    draw_changes = strcmpi(get(handles.show_edit_changes_menu, 'Checked'), 'on') ;
    if draw_changes


        
        temp_edges = seq.frames(i).cellgeom.edges;
        X = [seq.frames(i).cellgeom.nodes(temp_edges(:,1),2), ...
            seq.frames(i).cellgeom.nodes(temp_edges(:,2),2)];
        Y = [seq.frames(i).cellgeom.nodes(temp_edges(:,1),1), ...
            seq.frames(i).cellgeom.nodes(temp_edges(:,2),1)];
        geomH = [geomH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0, ...
             'EdgeColor', [1 0 0],'Parent',handles.axes1)];    
    end
    
    geomH = [];
%     geom_edge_settings = getappdata(trackingH,'geom_edge_settings');
%     if isempty(geom_edge_settings)
%         geom_color = [0 1 0];
%         geom_thickness = 1;
%         invertBool = false;
%     else
%         geom_color  = geom_edge_settings.color;
%         geom_thickness = geom_edge_settings.thickness;
%         invertBool = geom_edge_settings.invertBool;
%     end
    X = [cellgeom_edit.nodes(edges(all_ind,1),2), ...
        cellgeom_edit.nodes(edges(all_ind,2),2)];
    Y = [cellgeom_edit.nodes(edges(all_ind,1),1), ...
        cellgeom_edit.nodes(edges(all_ind,2),1)];
    geomH = [geomH patch(X', Y', [0 0.5 0], 'FaceAlpha', 0,...
        'LineWidth', geom_thickness, 'EdgeColor', geom_color,'Parent',handles.axes1)];
    


end

if exist('show_vf_bool') && show_vf_bool
    if ~isempty(dir('embryo_orientation.mat'))
        load('embryo_orientation','ventral_line');
        if ~isempty(whos('ventral_line'))
            if ishandle(vf_lineH)
                delete(vf_lineH);
            end
            line_color = [1 0 1];
%             ventral_line_seq = getappdata(handles.figure1, 'ventral_line_seq');
%             ventral_line_frame_ind = getappdata(handles.figure1, 'ventral_line_frame_ind');
            ventral_line_seq = ventral_line;
            ventral_line_frame_ind = [ventral_line(:).t]; 
            [~, vf_ind] = min(abs(i - ventral_line_frame_ind));
            X = ventral_line_seq(vf_ind).y;
            Y = ventral_line_seq(vf_ind).x;
            vf_lineH = line(Y', X', ...
                'Color', line_color,'Parent',handles.axes1);
        end
    end
else
    if ishandle(vf_lineH)
        delete(vf_lineH);
	end
end



if nlost_ephemeral_bool
    if ~isempty(dir('time_localized_events_per_cell.mat'))
%         load('time_localized_events_per_cell','edgeBased_activityData');
        edgeBased_activityData = getappdata(handles.figure1,'edgeBased_activityData');
        if ~isempty(whos('edgeBased_activityData'))
            if ishandle(nLostH)
                delete(nLostH);
            end
            [nLostH] = visualize_nlost_activity(handles.axes1,edgeBased_activityData,i);            
        end
    end
else
    if ishandle(nLostH)
        delete(nLostH);
    end
end


%%%DLF ADDITITON 2015.12.4
if handles.figure1 ~= drawingfig
    delete(extern_geomH);
    figure(drawingfig);
    if ishandle(geomH)
        extern_geomH = copyobj(geomH,drawingfig.Children);
    end
    if get(handles.scaleBar_btn,'value');
        scaleBarH = getappdata(drawingfig,'scaleBarH');
        if ishandle(scaleBarH)
            uistack(scaleBarH,'top');
        end
    end
end


if any(strcmp('draw_edge_opt_bool',fieldnames(seq)))
    if seq.draw_edge_opt_bool
        var_checklist = {'edges', 'x1', 'y1', 'x2', 'y2'};
        for var_ind = 1:length(var_checklist)
            if ~exist(var_checklist{var_ind},'var')
%                 global edges x1 y1 x2 y2

                polarityfiletype = 0;
                if ~isempty(dir('edges_info_cell_background*'))
                    load('edges_info_cell_background', 'edges','x1','y1','x2','y2');

                    polarityfiletype = 1;
                else if ~isempty(dir('edges_info_max_proj_single_given*'))
                        load('edges_info_max_proj_single_given', 'edges','x1','y1','x2','y2');
                        polarityfiletype = 2;
                    else
                        display('no polarity file found');
                    end

                end

%                 load('edges_info_cell_background','edges','x1','y1','x2','y2')
                global ORI_X1 ORI_X2 ORI_Y1 ORI_Y2 inv_edges
                ORI_Y1 = y1;   
                ORI_Y2 = y2;
                ORI_X2 = x2;
                ORI_X1 = x1;
                inverse_edges_map = zeros(1, length(seq.edges_map(1, :)));
                inverse_edges_map(edges) = 1:length(edges);
            end
        end
        
        
    edge_thickness = 1;
	
%     global ORI_X12 ORI_X22 ORI_Y12 ORI_Y22 
    eds_ori = inv_edges(seq.inv_edges_map(i, ~ind));
    eds_ori = true(1, length(ORI_X1));
    X = [ORI_X1(i, eds_ori)', ORI_X2(i, eds_ori)'];
    Y = [ORI_Y1(i, eds_ori)', ORI_Y2(i, eds_ori)'];
    edgesH = [edgesH patch(Y', X', [0 0.1 0.8], 'FaceAlpha', 0, ...
        'LineWidth', geom_thickness, 'EdgeColor', 'c','Parent',handles.axes1)];
    end
end

if handles.figure1 ~= drawingfig
    delete(extern_edgesH);
    figure(drawingfig)
    extern_edgesH = copyobj(edgesH,drawingfig.Children);
end

% %%%%
% % DEBUG
%%%%
% edge_thickness = 1;
%            global ORI_X1 ORI_X2 ORI_Y1 ORI_Y2 inv_edges
%     global ORI_X12 ORI_X22 ORI_Y12 ORI_Y22 
%     eds_ori = inv_edges(seq.inv_edges_map(i, ~ind));
%     eds_ori = true(1, length(ORI_X1));
%     X = [ORI_X1(i, eds_ori)', ORI_X2(i, eds_ori)'];
%     Y = [ORI_Y1(i, eds_ori)', ORI_Y2(i, eds_ori)'];
%     edgesH = [edgesH patch(Y', X', [0 0.5 0], 'FaceAlpha', 0, ...
%         'LineWidth', edge_thickness, 'EdgeColor', 'c')];

%%%%
% % DEBUG
% %%%%%%%    
%     a = false(size(img));
%     frame = i;
% 
%     for ii = 1:length(ORI_X1(frame,:));
%         if ORI_X1(frame,ii) > 4 && ORI_X2(frame,ii) > 4 &&...
%                 ORI_Y1(frame,ii) > 4 && ORI_Y2(frame,ii) > 4
%         linepoints = connect_line([ORI_X1(frame,ii),ORI_Y1(frame,ii)],...
%             [ORI_X2(frame,ii),ORI_Y2(frame,ii)]);
%         for iii = 1:length(linepoints)
%             a(linepoints(1,iii),linepoints(2,iii)) = true;
%         end
%         end
%     end
% 
%     a_dil = imdilate(a,strel('disk',1));
%     b = uint16(img);
%     maxintsty =  uint16(max(img(:)));
%     b(a_dil) = (b(a_dil).*2 + maxintsty)./3;
%     b(a) = (b(a) + maxintsty)./2;
%     new_img_fold = fullfile([directory,'/images_reseg']);
%     if ~isdir(new_img_fold)
%         mkdir(new_img_fold);
%     end
%     b = uint8(b);
%     
%     imwrite(b,fullfile([directory,'/images_reseg'], filename),'tif');
% 
%     


if isappdata(handles.figure1, 'poly_seq') && on_off_poly_bool
    poly_seq = getappdata(handles.figure1, 'poly_seq');
    poly_frame_ind = getappdata(handles.figure1, 'poly_frame_ind');
    [dummy poly_ind] = min(abs(i - poly_frame_ind));
    X = poly_seq(poly_ind).x;
    Y = poly_seq(poly_ind).y;
    poly_color = [1 0 0];
    if dummy == 0;
        poly_color = [0 0 1];
    end
    poly_seqH = patch(Y', X', [0 0.5 0], 'FaceAlpha', 0,...
        'EdgeColor', poly_color,'Parent',handles.axes1);
end

%%%DLF ADDITITON 2015.12.4
if handles.figure1 ~= drawingfig
    delete(extern_poly_seqH);
    figure(drawingfig);
    if ishandle(poly_seqH)
        extern_poly_seqH = copyobj(poly_seqH,drawingfig.Children);
    end
end


if strcmp(get(handles.zoom_and_track_cells, 'Checked'), 'on') || ...
    strcmp(get(handles.shift_axes_with_cells, 'Checked'), 'on') || ...
    strcmp(get(handles.zoom_track_const, 'Checked'), 'on')
    axes_x_lim = getappdata(handles.figure1, 'axes_x_lim');
    axes_y_lim = getappdata(handles.figure1, 'axes_y_lim');
    [m n] = size(img);
%     x_max = max(1, axes_x_lim(i, 2));
%     x_min = min(n, axes_x_lim(i, 1));
%     y_max = max(1, axes_y_lim(i, 2));
%     y_min = min(n, axes_y_lim(i, 1));
    x_max = axes_x_lim(i, 2);
    x_min = axes_x_lim(i, 1);
    y_max = axes_y_lim(i, 2);
    y_min = axes_y_lim(i, 1);
    if ~any(isnan([axes_x_lim(i, :) axes_y_lim(i, :)])) && ...
            isfield(handles, 'axes1') && ishandle(handles.axes1)
        set(handles.axes1, 'xlim', [x_min x_max]);
        set(handles.axes1, 'ylim', [y_min y_max]);
    else
        handles.axes1.XLim = xlimStart;
        handles.axes1.YLim = ylimStart;
    end
else
    handles.axes1.XLim = xlimStart;
    handles.axes1.YLim = ylimStart;
end


%%%%%%%%%%%%%%%%%%%% TRACK NODES DEBUG %%%%%%%%%%%%%%%
%%%%%%%%%%%%%
% global ori ori_mult
% persistent oriH
% if oriH == 0
%     oriH = [];
% end
% delete(oriH(ishandle(oriH)));
% %sc = find(ori(:, i));
% nind = nonzeros(ori(i, :));
% nind2 = find(ori(i, :));
% oriH = patch('xdata', ...
%                 seq.frames(i).cellgeom.nodes(nind ,2),...
%                 'ydata',  seq.frames(i).cellgeom.nodes(nind ,1), ...
%                 'linestyle', 'none', 'facecolor', 'none', 'markersize', 8, ...
%                 'marker', 'd', 'markerfacecolor', 'flat', 'cdata', ...
%                 reshape(get_cluster_colors(nind2), [], 1, 3));
%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
% 
% global nnn
% persistent oriH
% if oriH == 0
%     oriH = [];
% end
% delete(oriH(ishandle(oriH)));
% if nnn(i)
%     oriH = patch('xdata', ...
%                 seq.frames(i).cellgeom.nodes(nnn(i),2),...
%                 'ydata',  seq.frames(i).cellgeom.nodes(nnn(i),1), ...
%                 'linestyle', 'none', 'facecolor', 'none', 'markersize', 8, ...
%                 'marker', 'd', 'markerfacecolor', 'flat', 'cdata', ...
%                 reshape([1 0 0], [], 1, 3));
% end



% global blahh
% persistent oriH
% if oriH == 0
%     oriH = [];
% end
% delete(oriH(ishandle(oriH)));
% %if all(blahh(i, :) > 0)
%     oriH = patch('xdata', ...
%                 squeeze(blahh(i, :, 2)),...
%                 'ydata', squeeze( blahh(i, :, 1)), ...
%                 'linestyle', 'none', 'facecolor', 'none', 'markersize', 8, ...
%                 'marker', 'd', 'markerfacecolor', 'flat', 'cdata', ...
%                 repmat(reshape([1 1 0], [], 1, 3), [length(blahh(i, :, 1)), 1, 1]));
% %end

% global blahh hhhhh
% if length(blahh) > i
%     if ~isempty(cells)
%       xc = seq.frames(i).cellgeom.circles(nonzeros(cells), 2);
%       yc = seq.frames(i).cellgeom.circles(nonzeros(cells), 1);  
%       [xx yy] = ellipse(xc, yc, blahh(i+10, 2), blahh(i+10, 3), 20, blahh(i+10, 1));
%       blahh(i+10, :);
%       if hhhhh > 0 & ishandle(hhhhh)
%           delete(hhhhh)
%       end
%       hhhhh = line(xx, yy);
%     end
% end






drawnow;



% display(['handles.figure1 at bottom of update_frame: ',num2str(handles.figure1)]);


    
    function draw_patches
        cellsH = draw_highlighted_cells(drawingfig, cell_nodes, ...
            cells_colors, alphas);
    end


    function setup_image_channel(ch)
    channel_dir = getappdata(handles.figure1, ['dir_channel' num2str(ch)]);
    base_name = getappdata(handles.figure1, ['filename_channel' num2str(ch)]);
    ch_z_val = getappdata(handles.figure1, ['z_channel' num2str(ch)]);
    img_filename = seq.frames(i).img_file;
    [img_z img_t] = get_file_nums(img_filename);
    img_filename = fullfile(channel_dir, put_file_nums(base_name, img_t, ch_z_val));
    ctrl = handles.(['channel' num2str(ch)]);
    if length(dir(img_filename))
        set(ctrl, 'FontWeight', 'normal');
        temp_color = [0 0 0];
        temp_color(ch) = 1;
        set(ctrl, 'ForegroundColor', temp_color);
        temp_img = imread(img_filename);
        fac = getappdata(handles.figure1, ['channel' num2str(ch) '_factor']);
        shift_fac = getappdata(handles.figure1, ['channel' num2str(ch) '_shift_factor']);
        img(:, :, ch) = max(1, min(255, round((temp_img - shift_fac)* fac)));
    else
        set(ctrl, 'FontWeight', 'bold');
        temp_color = [0 0 0];
        temp_color(ch) = 0.4;
        set(ctrl, 'ForegroundColor', temp_color) 
    end
    end

    function setup_no_image_channel(ch)
        ctrl = handles.(['channel' num2str(ch)]);
        set(ctrl, 'FontWeight', 'normal');
        temp_color = [0 0 0];
        temp_color(ch) = 1;
        set(ctrl, 'ForegroundColor', temp_color)        
    end
end