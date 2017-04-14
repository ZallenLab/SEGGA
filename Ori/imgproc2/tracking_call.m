function tracking_call(calling_window, cells, cells_colors, cells_alphas)
if isappdata(calling_window, 'trackingH')
    trackingH = getappdata(calling_window, 'trackingH');
    if ishandle(trackingH)
        figure(trackingH)
        return
    end
end

pub_release = getappdata(calling_window,'public_release');
if ((~isempty(pub_release)) && pub_release)
    %%% public release settings
else
    pub_release = false;
end

cw_handles = guihandles(calling_window);
if strcmp(lower(get(cw_handles.quick_edit_menu, 'checked')), 'on')
    quick_edit_mode = true;
else
    quick_edit_mode = false;
end

global changed
if changed == 1
    if ~call_to_save
        return
    end
end

directory = cd;

    
    


global seq
    


if isappdata(calling_window, 'seq')
    seq = getappdata(calling_window, 'seq');
    
    if isdir(seq.directory)
        cd(seq.directory);
    end
end
if ~isappdata(calling_window, 'seq') || seq.changed
    seq = load_dir(directory);
    if isempty(seq)
        cmd_w_str = 'load_dir failed... quitting';
        cprintf('*[1,0.5,0]',[cmd_w_str,'\n']);
        ST = dbstack;
        display(ST(1));
        fprintf('\n');
        return
    end
    if isappdata(calling_window, 'seq_t_z')
        temp_var = getappdata(calling_window, 'seq_t_z');
        t = temp_var(1);
        z = temp_var(2);
        if t < length(seq.frames_num(:, 1)) && z < length(seq.frames_num(1, :))
            img_num = seq.frames_num(t, z);
        else
            img_num = 1;
        end
    else
        img_num = 1;
    end
    if img_num == 0
        img_num = 1;
    end
    
    seq.t = seq.frames(img_num).t;
    seq.z = seq.frames(img_num).z;
    seq.img_num = seq.frames_num(seq.t, seq.z);
%    seq.img_num = seq.frames_num(seq.frames(img_num).t, seq.frames(img_num).z);
%     seq.img_num = find(strcmp({seq.frames.img_file}, filename)); %changeorbit!!!
%     seq.img_num = find(seq.orbit == seq.img_num); %changeorbit!!!
    all_cells_colors = zeros(length(seq.frames(seq.img_num).cellgeom.circles(:,1)), 3);
    all_cells_alphas = zeros(length(seq.frames(seq.img_num).cellgeom.circles(:,1)), 1);
    if nargin == 1
        cells = [];
    else
        all_cells_colors(cells, :) = cells_colors;
        all_cells_alphas(cells) = cells_alphas;
    end
    
    cell_states = false(size(all_cells_alphas));
    cell_states(nonzeros(cells)) = 1;
    
    seq = update_orbit(seq, cells, all_cells_colors, all_cells_alphas, ...
        seq.t, seq.z, 1:length(seq.frames), [], cell_states, [], 1);
end
setappdata(calling_window, 'seq', seq);
% trackingH = tracking_paper_mod;
trackingH = tracking;
min_num = seq.min_t;
max_num = seq.max_t;
track_handles = guihandles(trackingH);
% display(track_handles);
set(track_handles.frame_slider, 'max', max_num, 'min', min_num, 'value', seq.t);
set(track_handles.frame_number, 'String', seq.t);

if seq.max_t - seq.min_t > 0
    set(track_handles.frame_slider, 'SliderStep', ...
        [min(1, seq.t_jump/(max_num - min_num))  min(1, 10*seq.t_jump/(max_num - min_num))]);    
    set(track_handles.frame_slider, 'Visible', 'on')
    set(track_handles.frame_number, 'Enable', 'on');
    set(track_handles.track_for, 'Enable', 'on');
    set(track_handles.track_back, 'Enable', 'on');
    set(track_handles.track_for, 'Value', 1);
    set(track_handles.track_back, 'Value', 1);
    set(track_handles.play_forward, 'Enable', 'on');
    set(track_handles.play_backward, 'Enable', 'on');
    set(track_handles.t_from, 'Enable', 'on');
    set(track_handles.t_to, 'Enable', 'on');
    set(track_handles.t_from, 'String', min_num);
    set(track_handles.t_to, 'String', max_num);
else
    set(track_handles.t_from, 'Enable', 'off');
    set(track_handles.t_to, 'Enable', 'off');
    set(track_handles.t_from, 'String', seq.t);
    set(track_handles.t_to, 'String', seq.t);
end

set(track_handles.slice_slider, 'value', -seq.z, 'max', -seq.min_z, 'min', -seq.max_z);
set(track_handles.slice_number, 'String', seq.z);
if seq.max_z - seq.min_z > 0
    if length(seq.valid_z_vals) > 1
        small_step = abs(seq.valid_z_vals(1) - seq.valid_z_vals(2));
    else
        small_step = 1;
    end
    large_step = min(10, 5 * small_step);
    small_step = min(1 , small_step/(seq.max_z - seq.min_z)); 
    large_step = min(1 , large_step/(seq.max_z - seq.min_z)); 
    set(track_handles.slice_slider, 'SliderStep', [small_step  large_step]);    
    set(track_handles.slice_slider, 'Visible', 'on');
    set(track_handles.slice_number, 'Enable', 'on');
    set(track_handles.track_up, 'Enable', 'on');
    set(track_handles.track_down, 'Enable', 'on');
    set(track_handles.z_from, 'Enable', 'on');
    set(track_handles.z_to, 'Enable', 'on');
    set(track_handles.z_from, 'String', seq.min_z);
    set(track_handles.z_to, 'String', seq.max_z);
else
    set(track_handles.z_from, 'Enable', 'off');
    set(track_handles.z_to, 'Enable', 'off');
    set(track_handles.z_from, 'String', seq.z);
    set(track_handles.z_to, 'String', seq.z);
end

i = seq.frames_num(seq.t,seq.z);

% DLF DEBUG EDIT September 5 2013
if i == 0
    display('using dlf debug [line 140 inside tracking_call]');
    i = nonzeros(seq.frames_num(seq.t,:));
end


filename = seq.frames(i).img_file;
if length(dir(fullfile(directory, seq.bnr_dir, filename)))
    set(track_handles.bnr, 'value', 1)
end

fcn = get(track_handles.figure1, 'KeyPressFcn');


names = fieldnames(track_handles);
for i = 1:length(names)
    ctrl = getfield(track_handles, names{i});
    if isprop(ctrl, 'KeyPressFcn')
        if isprop(ctrl, 'Style') && strcmpi(get(ctrl, 'style'), 'edit')
            continue
        end
        set(ctrl, 'KeyPressFcn', fcn);
    end
%     set(track_handles.frame_number, 'KeyPressFcn', []);
%     set(track_handles.slice_number, 'KeyPressFcn', []);
end

%setappdata(trackingH, 'seq', seq);
setappdata(trackingH, 'first_time', 1);
setappdata(trackingH, 'bright_fac', 1);
setappdata(trackingH, 'channel_settings_filename', 'channel_image_settings.txt')
multi = false;
for ch = 1:3
    multi = multi | set_seq_channel(seq, track_handles, ch);
end
set_multi_channel_tracking(track_handles, multi);
figure(trackingH);
% display(['trackingH: ',num2str(trackingH)]);
% display(['track_handles.axes1 :',num2str(track_handles.axes1)]);
% display(['track_handles.figure1 :',num2str(track_handles.figure1)]);

% display(track_handles);
update_frame(track_handles, seq.t, seq.z);
start_x_lim = get(track_handles.axes1,'xlim');
start_y_lim = get(track_handles.axes1,'ylim');

try
    ftemp = fopen('seg_ax_lims.txt','w' );
    fprintf(ftemp, 'start_x_lim=[%g,%g];\n',start_x_lim);
    fprintf(ftemp, 'start_y_lim=[%g,%g];\n',start_y_lim);
    
    fclose(ftemp);
catch
    print('could not write to seg_ax_lims file');
end

setappdata(track_handles.figure1,'start_x_lim',start_x_lim);
setappdata(track_handles.figure1,'start_y_lim',start_y_lim);

%%%%%% fast editing mode only %%%%%%%%%% 
if quick_edit_mode
    setappdata(trackingH, 'quick_edit_mode', true);
    filename = 'poly_seq.mat';
    if length(dir(filename))
        tracking('load_poly_seq_menu_Callback', track_handles.load_poly_seq_menu, [], track_handles);
        tracking('select_by_poly_seq_menu_Callback', track_handles.select_by_poly_seq_menu, [], track_handles);
    end
    set(track_handles.lim_to_sel_edges_menu, 'checked', 'on');
    tracking('faulty_cells_menu_Callback', track_handles.faulty_cells_menu, [], track_handles);
    set(track_handles.lim_to_sel_edges_menu, 'checked', 'off');
else
    setappdata(trackingH, 'quick_edit_mode', false);
end
setappdata(trackingH, 'chan2gray_sub_btns_bool', false);


global activefig
old_activefig = activefig;
activefig = trackingH;
setappdata(trackingH, 'calling_window', calling_window);
setappdata(calling_window, 'trackingH', trackingH);
if isappdata(calling_window, 'browse_data_window')
    bd_window = getappdata(calling_window, 'browse_data_window');
    setappdata(trackingH, 'browse_data_window', bd_window)
end


setappdata(trackingH, 'touched_cells', ...
    false(length(seq.frames(seq.img_num).cellgeom.circles(:,1)), 1));
setappdata(trackingH, 'touched_edges', ...
    false(length(seq.frames(seq.img_num).cellgeom.edges(:,1)), 1));

% %%%%
% global oriori
% setappdata(trackingH, 'sum_change', oriori);
% setappdata(trackingH, 'cells_to_anal', true(size(seq.cells_map)));
% %%%%
if pub_release
    set(track_handles.img_orientation, 'Visible', 'off')
    set(track_handles.locate_vf, 'Visible', 'off')
    set(track_handles.view_vf_menu_chck, 'Visible', 'off')
    set(track_handles.polarity_covariance_annotation, 'Visible', 'off')
    set(track_handles.area_drop_mid, 'Visible', 'off')
    
end

%     DLF EDIT 2014Feb10 % tried to remove the 'wait'
waitfor(trackingH);
activefig=old_activefig;
if ishandle(calling_window) && isappdata(calling_window, 'trackingH')
    rmappdata(calling_window, 'trackingH')
end
t = seq.t;
z = seq.z;
clear global seq
global commandsuiH changed casename
if calling_window == commandsuiH
    changed = 0;
    try
        setappdata(commandsuiH, 'called_from_tracking', 1)
        close(activefig(ishandle(activefig)));
        setappdata(commandsuiH, 'seq_t_z',  [t z]);
    catch
        display('commandsui window missing');
    end
end
if ishandle(calling_window)
	figure(calling_window);
end

function flag = call_to_save
msg = ['File must be saved before tracking. Do you want to continue?'];
answer = questdlg(msg);
if ~strcmp('Yes', answer)
    flag = 0;
    return
end
savecase
if cancelled
    flag = 0;
    return
end
flag = 1;

function multi = set_seq_channel(seq, handles, ch)
multi = false;
fn = ['channel' num2str(ch)];
if isfield(seq, fn) && ~isempty(seq.(fn))
    
    [pathname filename ext] = fileparts(seq.(fn));
    
    
%     DLF EDIT 2013July15
    if isempty(pathname)
        display('pathname is empty!')
        display('trying to improvise.');
        currdir = pwd;
        [pathname filename ext] = fileparts([currdir,seq.(fn)]);
        
    end
    
     try   
        pathname = relative_dir(seq.directory, pathname);
        filename = [filename ext];
        img_filename = put_file_nums(fullfile(pathname, filename), seq.frames(1).t, seq.frames(1).z);
        if length(dir(img_filename))
            load_channel_tracking(handles, ch, filename, pathname);
            multi = true;
        else
            sprintf('File %s for channel %d not found. Not loading channel.', img_filename, ch);
        end
     catch
         display(['missing channel: ',pathname]);
         display('attempting to plug in seg dir img');
         try 
            pathname = ['..',filesep,'seg'];
            pathname = relative_dir(seq.directory, pathname);
            filename = seq.frames(1).img_file;
            img_filename = fullfile(pathname, seq.frames(1).img_file);
            if length(dir(img_filename))
                load_channel_tracking(handles, ch, filename, pathname);
                multi = true;
            else
                sprintf('File %s for channel %d not found. Not loading channel.', img_filename, ch);
            end
         catch
             display('seg not available either, leaving channel blank');
         end
     end
end

