function see_data_call(calling_window, cells_data, edges_data, img_num, z_num)
if isappdata(calling_window, 'see_dataH')
    see_dataH = getappdata(calling_window, 'see_dataH');
    if ishandle(see_dataH)
        figure(see_dataH)
        return
    end
end

global seq
%seq = getappdata(calling_window, 'seq');
see_dataH = see_data;
min_num = seq.min_t;
max_num = seq.max_t;
see_handles = guihandles(see_dataH);
set(see_handles.frame_slider, 'max', max_num, 'min', min_num, 'value', seq.t);
set(see_handles.frame_slider, 'SliderStep', [min(1, 1/(max_num - min_num))  min(1, 10/(max_num - min_num))]);


%setappdata(see_dataH, 'seq', seq);
setappdata(see_dataH, 'first_time', 1);
setappdata(see_dataH, 'edges_data', edges_data);
setappdata(see_dataH, 'cells_data', cells_data);
setappdata(see_dataH, 'edges', 1);

max_val = length(edges_data.len(1,:));
if max_val > 1
    slider_step = [1 / (max_val - 1) min(0.5, 10 / (max_val - 1))];
    set(see_handles.edges_slider, 'max', max_val, 'min', 1, 'value', 1, 'SliderStep', slider_step);
else
    set(see_handles.edges_slider, 'Enable', 'off');
end
sd_update_frame(see_handles, img_num, z_num);

setappdata(see_dataH, 'calling_window', calling_window);
setappdata(calling_window, 'see_dataH', see_dataH);
