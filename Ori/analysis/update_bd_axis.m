function update_bd_axis(handles, value, called_from_tracking)
if nargin < 3 || isempty(called_from_tracking) 
    called_from_tracking = false;
end
set(handles.slider1, 'value', value);

%pddH = plot(handles.axes1, reshape(pdd(:, 1, :), [], n));
dataset = getappdata(handles.figure1, 'dataset');
pdd = getappdata(handles.figure1, 'pdd');
pddH = getappdata(handles.figure1, 'pddH');
n = length(pdd(1,1, :, 1));
%edge_edge_map hack *******************
% pddH2 = getappdata(handles.figure1, 'pddH2');
%edge_edge_map hack *******************

for i = 1:n
    set(pddH(i), 'ydata', reshape(pdd(:, value, i, dataset), [], 1));
    %edge_edge_map hack *******************
    %set(pddH2(i), 'ydata', reshape(pdd(:, round(get(hObject,'Value')), i, 2), [], 1));
    %edge_edge_map hack *******************
end



%% highlight plotted cell/edge in tracking window
if get(handles.draw_tracking, 'value') || called_from_tracking
    calling_window = getappdata(handles.figure1, 'calling_window');
    global seq 
else
    calling_window = [];
end
if ~isempty(calling_window) && calling_window && ishandle(calling_window) ...
        && isappdata(calling_window, 'trackingH') ...
        && ~isempty(getappdata(calling_window, 'trackingH'))
    trackingH = getappdata(calling_window, 'trackingH');
else
    trackingH =[];
end
if ~isempty(trackingH) && ishandle(trackingH)
    track_handles = guihandles(trackingH);
    items_for_tracking = getappdata(handles.figure1, 'items_for_tracking');
    items_type = getappdata(handles.figure1, 'items_type');

        

        if strcmp(items_type, 'edges')
            edge = items_for_tracking(value);
            for i = 1:length(seq.edges_map(:, 1))
                seq.frames(i).edges = nonzeros(seq.edges_map(i, edge));
            end
%             zoom_and_follow_edge(track_handles, edge)
        elseif strcmp(items_type, 'cells')
            cell = items_for_tracking(value);
            for i = 1:length(seq.cells_map(:, 1))
                seq.frames(i).cells = nonzeros(seq.cells_map(i, cell));
                seq.frames(i).cells_colors(seq.frames(i).cells, 3) = 0.0;
                seq.frames(i).cells_colors(seq.frames(i).cells, 2) = 1;
                seq.frames(i).cells_colors(seq.frames(i).cells, 1) = 1;
                seq.frames(i).cells_alphas(seq.frames(i).cells) = 0.3;
            end
        end
        if ~called_from_tracking
            update_frame(track_handles)
            figure(handles.figure1)
        end
        

% global nnn nodes_for_pdd nodelist_for_pdd
% 
%     nnn = nodelist_for_pdd(nodes_for_pdd(round(get(hObject,'Value'))), :);
end