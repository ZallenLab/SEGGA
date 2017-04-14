function SEGGA_check_errors(key_frames_input,display_dlg_bool,figure_handle)
if nargin <3
    figure_handle = [];
end


if nargin <2
    display_dlg_bool = false;
end

if nargin <1
    key_frames_input = [];
end

display('running "check_errors"...');
mykeyframes = (key_frames_input);



% load from files, not from commandsui window
poly_found_bool = ~isempty(dir('poly_seq.mat'));
if poly_found_bool
    seq = load_dir(pwd);
    seq = get_mistake_cells(seq);
    data = seq2data(seq);
    len = length(seq.frames);
    errcells = nan(len,1);
    totalCellNums = nan(len,1);
    totalCellNums = sum(data.cells.selected,2);
    for i=1:len
        errcells(i) = length(seq.frames(i).cells);
    end
else
    display('no poly file found');
    return
end

if any(key_frames_input<seq.min_t)||any(key_frames_input>seq.max_t)
    display(['key frames out of bounds: ',num2str([seq.min_t,seq.max_t])]);
    return
end

frame_nums_rel = seq.min_t:seq.max_t;
myframes = [];
newerrorperframe = zeros(seq.max_t,1);
% time
for i = 1:length(seq.frames)

    if ~isempty(seq.frames(i).cells)
        myframes = [myframes,i];
        newerrorperframe(i+seq.min_t-1) = length(nonzeros(seq.frames(i).cells));
    end
    
end
total_txt = ['total errors: ', num2str(sum(newerrorperframe(:)))];
errframes_txt = ['frames with errors: ',num2str(frame_nums_rel(myframes))];



display(total_txt);
display(errframes_txt);

if ~isempty(mykeyframes)
    if any(newerrorperframe(mykeyframes))
        display('  !!errors found in key frames!!  ');
        keyframes_txt = ['key frames with errors: ',num2str(mykeyframes(newerrorperframe(mykeyframes)>0))];
        
        for i = 1:length(mykeyframes)
            display(['frame (',num2str(mykeyframes(i)),') --> ',num2str(newerrorperframe(mykeyframes(i))),' errors']);
        end
    else
        keyframes_txt = ['no errors found on key frames'];
    end
else
    keyframes_txt = ['no key frames entered'];
end
if isempty(figure_handle)
    f=figure('name','Check Errors Interface',...
        'numbertitle','off','MenuBar', 'None');
    set(f, 'units', 'normalized', 'position', [0.05 0.15 0.5 0.4])
else
    f = figure_handle;
end
setappdata(f,'seq',seq);
setappdata(f,'key_frames_input',mykeyframes);
setappdata(f,'f',f);

hold on
plot(frame_nums_rel,newerrorperframe(frame_nums_rel), 'r');
ylabel('num errs');
xlabel('frame num');
set(gca,'position',[0.1    0.3    0.8    0.65]);
c1 = uicontrol(f,'Style','text',...
                'String',total_txt,...
                'Position',[30 80 130 20]);
c2 = uicontrol(f,'Style','text',...
                'String',errframes_txt,...
                'Position',[30 50 200 20]);
c3 = uicontrol(f,'Style','text',...
                'String',keyframes_txt,...
                'Position',[30 20 200 20]);
            
c4 = uicontrol(f,'Style','pushbutton',...
                'String','manual corrections',...
                'Units','normalized',...
                'Position',[.7 .15 .1 .04],...
                'callback',@man_corr_callback);

c5 = uicontrol(f,'Style','pushbutton',...
                'String','reload check errors',...
                'Units','normalized',...
                'Position',[.7 .1 .1 .04],...
                'callback',@reload_check_errors_callback);
            
c6 = uicontrol(f,'Style','pushbutton',...
                'String','load auto corrections',...
                'Units','normalized',...
                'Position',[.7 .05 .1 .04],...
                'callback',@auto_corr_callback);
            
            c7 = uicontrol(f,'Style','pushbutton',...
                'String','change dir',...
                'Units','normalized',...
                'Position',[.4 .05 .1 .05]);
            
        


totalcells = sum(data.cells.selected(:));
totalerrors = sum(newerrorperframe);
display(['percent of possible errors: ',num2str(totalerrors/totalcells*100)]);
display(['errors on key frames: ',num2str(sum(newerrorperframe(mykeyframes)))]);
fprintf('\n \n') ;
if display_dlg_bool %display in popupwindow
    if totalerrors==0
        msgbox('no tracking errors found, ready for analysis!');
        return
    else if ~isempty(mykeyframes)
            if  sum(newerrorperframe(mykeyframes))==0
                msgbox('no tracking errors found on KEY FRAMES, ready for automatic corrections');
                return
            else
                msgbox([num2str(sum(newerrorperframe(mykeyframes))), ' tracking errors found on KEY FRAMES, please resolve before running automatic corrections']);
                return
            end
        else
            msgbox([num2str(totalerrors),' errors found, continue correcting!']);
            return
        end
    end
else %display in command window

    if totalerrors==0
        display('no tracking errors found, ready for analysis!');
        return
    else if ~isempty(mykeyframes)
            if  sum(newerrorperframe(mykeyframes))==0
                display('no tracking errors found on KEY FRAMES, ready for automatic corrections');
                return
            else
                display([num2str(sum(newerrorperframe(mykeyframes))), 'tracking errors found on KEY FRAMES, please resolve before running automatic corrections']);
                return
            end
        else
            display([num2str(totalerrors),' errors found, continue correcting!']);
            return
        end
    end
end

function man_corr_callback(hObj,event)
seq = getappdata(gcf,'seq');
calling_win = commandsui;
call_handles = guihandles(calling_win);
% if ~isempty(getappdata(calling_win,'seq'))
%     display('seq exists already... removing and reloading');
%     rmappdata(calling_win,'seq');
%     %maybe should pass seq from 'check_errors' instead of wiping it in
%     %commandsui and then reloading fresh (to save time)
% else
%     display('seq is not inside commandsui');
% end
seq = prep_seq_for_tracking(seq);
setappdata(calling_win,'seq',seq);
commandsui('tracking_btn_Callback',call_handles.figure1,[],call_handles);



function auto_corr_callback(hObj,event)
check_h = gcf;
seq = getappdata(check_h,'seq');
key_frames_input = getappdata(check_h,'key_frames_input');

auto_h = seg_autocorrection;
auto_handles = guihandles(auto_h);
auto_handles.keys_loaded = false;

passed_data.seq = seq;
passed_data.key_frames_input = key_frames_input;
setappdata(auto_h,'passed_from_check_errors',passed_data);
seg_autocorrection('pass_in_data_from_check_errors',auto_handles.figure1,[],auto_handles);


function reload_check_errors_callback(hObj,event)

key_frames_input = getappdata(gcf,'key_frames_input');
f = getappdata(gcf,'f');
SEGGA_check_errors(key_frames_input,true,f);

function change_dir_callback(hObj,event)
newdir = uigetdir;
if isempty(newdir)
    display('no directory selected');
    return
end
cd(newdir);
key_frames_input = getappdata(gcf,'key_frames_input');
f = getappdata(gcf,'f');
SEGGA_check_errors(key_frames_input,true,f);
