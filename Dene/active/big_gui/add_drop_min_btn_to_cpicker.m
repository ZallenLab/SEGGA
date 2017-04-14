function add_drop_min_btn_to_cpicker(cpickerH)


handles = guidata(cpickerH);


pos = [0.85,0.5,0.05,0.1];
tempcb = @(hObject,eventdata) drop_mid_callback(hObject,eventdata,guidata(hObject));
handles.drop_midsH = uicontrol('Parent',handles.figure1,'Style', 'pushbutton',...
        'String', 'Drop Mids',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
guidata(cpickerH,handles);
    
function drop_mid_callback(hObject,eventdata,handles)
display('working');

callingfig_handles = getappdata(handles.figure1,'callingfig_handles');
seq = getappdata(handles.figure1,'seq');
data = seq2data(seq);


allareas = data.cells.area(data.cells.selected);
a_mean = mean(allareas);
a_min = min(allareas);
a_max = max(allareas);
a_std = std(allareas);
display({['a_mean: ',num2str(a_mean)],...
         [' a_min: ',num2str(a_min)],...
         [' a_max: ',num2str(a_max)],...
         [' a_std: ',num2str(a_std)]});

low_bound = max((a_mean-a_std),a_mean/2);
high_bound = (a_mean+a_std);
tmpmin = max(0,a_mean - 2*a_std);
tmpmax = min(a_max,a_mean+2*a_std);

figure; hist(allareas);
     
x = inputdlg({'Min','MinInner','MaxInner','Max'},...
              'Set Bounds', [1 15; 1 15;1 15; 1 15],...
              {num2str(tmpmin),num2str(low_bound),...
              num2str(high_bound),...
              num2str(tmpmax)}); 
          
display(x);

user_min = str2num(x{2});
user_max = str2num(x{3});
min_area = str2num(x{1});
max_area = str2num(x{4});

orbit = get_orbit_frames(callingfig_handles);
for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    areasofcells = data.cells.area(i,data.cells.selected(i,:));   
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = min(1,max(0,(areasofcells(takers)-min_area)./(max_area-min_area)));
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = min(1,max(0,1-(areasofcells(takers)-min_area)./(max_area-min_area)));
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .6;
    
%     cond = ((areasofcells(takers)>(mean_area+one_std)) | (areasofcells(takers)<(max((mean_area-one_std),mean_area/2))));
%     seq.frames(i).cells = seq.frames(i).cells(cond);
    cond = (areasofcells(takers)>user_max) | (areasofcells(takers)<user_min);
    seq.frames(i).cells = seq.frames(i).cells(cond);
end

global seq
update_frame(callingfig_handles);

function orbit = get_orbit_frames(handles)
global seq
l = str2double(get(handles.t_from, 'string')); 
r = str2double(get(handles.t_to, 'string'));
b = str2double(get(handles.z_from, 'string'));
t = str2double(get(handles.z_to, 'string'));


orbit = nonzeros(seq.frames_num(l:r, b:t))';