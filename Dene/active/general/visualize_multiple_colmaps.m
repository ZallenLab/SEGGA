function cmap_figH = visualize_multiple_colmaps(cmap_file,callingfig_handles,edgesBool)

if nargin <2 || isempty(callingfig_handles)
    incorp_tracking_win = false;
else
    incorp_tracking_win = true;
end

if nargin <2 || isempty(cmap_file)
    startdir = pwd;
    P = mfilename('fullpath');
    reversestr = fliplr(P);
    [~, justdirpath] = strtok(reversestr,filesep);
    base_dir = fliplr(justdirpath);
    cmapfilefold = base_dir;
    cmapfilename = 'SEGGA_default_cmaps.mat';
    cd(cmapfilefold);
    [filename, pathname] = uigetfile('*,mat','Choose a Colormap Database',cmapfilename);
    cmap_file = fullfile(pathname,filename);
    cd(startdir);
    if isempty(filename)
        display('user cancelled');
        return
    end    
end


try
    load(cmap_file);
catch
    display(['cant load cmap_file: ',cmap_file]);
    return
end
cmap_figH = figure;
pos = [680,367,824,700];
set(cmap_figH,'position',pos);


% create structure of handles
handles = guihandles(cmap_figH); 
handles.figure1 = cmap_figH;
if nargin <3 || isempty(edgesBool)
    setappdata(handles.figure1,'edgesBool',false);
end

if nargin > 1
    setappdata(handles.figure1,'callingfig_handles',callingfig_handles);
end
setappdata(handles.figure1,'incorp_tracking_win',incorp_tracking_win);
try
    setappdata(handles.figure1,'zlab_cmaps',zlab_cmaps);
catch
    setappdata(handles.figure1,'zlab_cmaps',SEGGA_default_cmaps);
end
setappdata(handles.figure1,'current_cmap_ind',0);
setappdata(handles.figure1,'cmap_file',cmap_file);
guidata(handles.figure1,handles);

create_continuous_maps(handles);
create_discrete_maps(handles);
handles = create_controls(handles);
guidata(handles.figure1,handles);



function create_continuous_maps(handles)
zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
pos = [0.2,0.95,0.1,0.025];
dis_ax = axes('position',pos,'units','normalized','parent',handles.figure1);
text(0,1,'continuous','fontweight','bold','parent',dis_ax);
axis off
pos = [0.7,0.95,0.1,0.025];
con_ax = axes('position',pos,'units','normalized','parent',handles.figure1);
text(0,1,'discrete','fontweight','bold','parent',con_ax);
axis off
discreteList = [zlab_cmaps(:).discrete_bool];
% maxnum = max(sum(discreteList),numel(discreteList) - sum(discreteList));

%%% show the continuous maps
numContin = sum(~discreteList);
contins = find(~discreteList);
startpos = [0.1,0.95,0.25,0.075];
for i = 1:numel(contins)
    
    y_shift = startpos(2)/(numContin+1);
    pos = [startpos(1),startpos(2)-i*y_shift,startpos(3),startpos(4)*min(1,7/numel(contins))];
    temp_ax = axes('position',pos,'units','normalized','parent',handles.figure1);
    
    ind = contins(i);
    cbH = image(1:size(zlab_cmaps(ind).contin_cmap,1),'parent',temp_ax);
    colormap(temp_ax,zlab_cmaps(ind).contin_cmap);
    title(zlab_cmaps(ind).cbar_txt);
    if ~isempty(zlab_cmaps(ind).xticklabels)
        if (numel(zlab_cmaps(ind).xticklabels)==3)
            temp_ax.XTick = [1,size(zlab_cmaps(ind).contin_cmap,1)/2,size(zlab_cmaps(ind).contin_cmap,1)];
            temp_ax.XTickLabel = zlab_cmaps(ind).xticklabels;
        else
            temp_ax.XTick = [1,size(zlab_cmaps(ind).contin_cmap,1)];
            temp_ax.XTickLabel = zlab_cmaps(ind).xticklabels;
        end
        temp_ax.YTick = [];
        set(temp_ax,'TickLength',[0,0]);
    else
        axis off
    end
    tempcb = @(hObject,eventdata) edit_cmap_callback(hObject,eventdata,guidata(hObject),ind);
%     set(temp_ax,'ButtonDownFcn',tempcb);
    set(cbH,'ButtonDownFcn',tempcb);
    zlab_cmaps(ind).imageH = cbH;
    zlab_cmaps(ind).callback = tempcb;
    setappdata(handles.figure1,'zlab_cmaps',zlab_cmaps);
end
guidata(handles.figure1,handles);

function create_discrete_maps(handles)
zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
discreteList = [zlab_cmaps(:).discrete_bool];
%%% show the discrete maps
numDisc = sum(discreteList);
discrts = find(discreteList);
startpos = [0.6,0.95,0.25,0.075];
for i = 1:numel(discrts)
    y_shift = startpos(2)/(numDisc+1);
    pos = [startpos(1),startpos(2)-i*y_shift,startpos(3),startpos(4)];
    temp_ax = axes('position',pos,'units','normalized','parent',handles.figure1);
    ind = discrts(i);
    cbH = image(1:size(zlab_cmaps(ind).colorInput,1),'parent',temp_ax);
    colormap(temp_ax,zlab_cmaps(ind).colorInput);
    title(zlab_cmaps(ind).cbar_txt);
    if ~isempty(zlab_cmaps(ind).xticklabels)
        temp_ax.XTick = [1:size(zlab_cmaps(ind).colorInput,1)];
        temp_ax.XTickLabel = zlab_cmaps(ind).xticklabels;
        temp_ax.YTick = [];
    else
        axis off
    end
    tempcb = @(hObject,eventdata) edit_cmap_callback(hObject,eventdata,guidata(hObject),ind);
    set(temp_ax,'ButtonDownFcn',tempcb);
    set(cbH,'ButtonDownFcn',tempcb);
	zlab_cmaps(ind).imageH = cbH;
    zlab_cmaps(ind).callback = tempcb;
    setappdata(handles.figure1,'zlab_cmaps',zlab_cmaps);
end
guidata(handles.figure1,handles);



%%% create control buttons
function handles = create_controls(handles)
discrete_bool = getappdata(handles.figure1,'discrete_bool');
h = handles.figure1;
ncolors = getappdata(h,'ncolors');
pos = [0.8,0.05,0.075,0.03];
tempcb = @(hObject,eventdata) addmap_callback(hObject,eventdata,guidata(hObject));
handles.addmapH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','add map',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
guidata(handles.figure1,handles);

pos = [0.7,0.05,0.075,0.03];
tempcb = @(hObject,eventdata) saveas_callback(hObject,eventdata,guidata(hObject));
handles.saveasH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','save as',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
guidata(handles.figure1,handles);

function saveas_callback(hObject,eventdata,handles)
cmap_file = getappdata(handles.figure1,'cmap_file');
FilterSpec = '*.mat';
DialogTitle = 'Save Colormap Set As';
[PATHSTR,NAME,EXT] = fileparts(cmap_file);
DefaultName = [PATHSTR,filesep,NAME,'mod'];
[FileName,PathName,FilterIndex] = uiputfile(FilterSpec,DialogTitle,DefaultName);
if isempty(FileName)
    display('user cancelled');
    return
end
zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
zlab_cmaps = rmfield(zlab_cmaps,'imageH');
zlab_cmaps = rmfield(zlab_cmaps,'callback');
save([PathName,filesep,FileName],'zlab_cmaps');

function addmap_callback(hObject,eventdata,handles)
choice = questdlg('New cmap', ...
	'options', ...
	'Text Input','Colorpicker','Cancel','Cancel');

switch choice
    case 'Text Input'
        addmap_start_from_text_input(handles);
    case 'Colorpicker'
        %%% need to program color picker to handle addition of colormap
        choice = questdlg('discrete or continuous', ...
                          'discrete or continuous', ...
                          'discrete','continuous','cancel','cancel');
        switch choice
            case 'discrete'
                discrete_bool = true;
                newcmap.discrete_bool = true;
                newcmap.continuous_vals = [];
            case 'continuous'
                discrete_bool = false;
                newcmap.discrete_bool = false;
            case 'cancel'
                display('user cancelled');
                return
        end
        newcmap = make_default_cmap(handles,discrete_bool);
        zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
        zlab_cmaps(end+1) = newcmap;
        setappdata(handles.figure1,'zlab_cmaps',zlab_cmaps);
        handles = depopulate_figure(handles);
        create_continuous_maps(handles);
        create_discrete_maps(handles);
        guidata(handles.figure1,handles);
        zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
%         tempcb = @(hObject,eventdata) edit_cmap_callback(hObject,eventdata,guidata(hObject),ind);
%         set(zlab_cmaps(end).imageH,'ButtonDownFcn',tempcb);
        edit_cmap_callback(zlab_cmaps(end).imageH,[],handles,numel(zlab_cmaps));
    case 'Cancel'
        disp('user cancelled');
        return
end

function addmap_start_from_text_input(handles)
zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
example_expr_input = 'cell_cdata = data.cells.num_sides(i,data.cells.selected(i,:));';
prompt = {'**name (name of colormap - no spaces):','**ncolors (number of colors):','**discrete_bool (discrete or continuous map):',...
          'mapped_numbers (numbers mapped to discrete colors):',...
          '**colorInput (colors, first dimension = number of colors):','**cbar_txt (text notes in colorbar figure output):',...
          'contin_val_expr (expression to evaluate for creating set of possible continuous values):','xticklabels (minimum and maximum labels for colormap):',...
          'expr_input (expression that generates the data used in applying color map to cells):','outside_loop_expr (expression to be evaluated before the frames loop):'};
dlg_title = 'Input';
num_lines = [1, 100];
defaultans = {'Topology','5','true','4,5,6,7,8',...
          '[0,0.6,0.035;0.94,0.93,0.094;0.35,0.36,0.33;0.13,0.31,0.89;0.63,0.22,1]',...
          'Topology','[]','4,8',...
          example_expr_input,'[]'};
      
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if isempty(answer)
    display('user cancelled');
    return
end

newcmap.name = answer{1};
newcmap.ncolors = str2num(answer{2});
newcmap.discrete_bool = str2num(answer{3});
newcmap.mapped_numbers = str2num(answer{4});
newcmap.callingfig = [];
newcmap.handles = [];
newcmap.colorInput = str2num(answer{5});
newcmap.cbar_txt = answer{6};
newcmap.contin_val_expr = answer{7};
eval(['newcmap.continuous_vals = ',newcmap.contin_val_expr,';']);
newcmap.xticklabels = strsplit(answer{8},',');
newcmap.expr_input = answer{9};
newcmap.outside_loop_expr = answer{10};

if ~newcmap.discrete_bool
    interp = 'linear';
    m = numel(newcmap.continuous_vals);
    if m ~= size(newcmap.colorInput, 1)
        xi = linspace(1, size(newcmap.colorInput, 1), m);
        cm = interp1(newcmap.colorInput, xi, interp);
    end
    newcmap.contin_cmap = cm;
else
    newcmap.contin_cmap = [];
end
newcmap.imageH = [];

% zlab_cmaps(end+1) = zlab_cmaps(end);
% all_fnames = fieldnames(zlab_cmaps(end));
% for i = 1:length(all_fnames)
%     temp_val = getfield(newcmap, all_fnames{i});
%     test_cmap = setfield(zlab_cmaps(end),all_fnames{i},temp_val);
% end
zlab_cmaps(end+1) = newcmap;
setappdata(handles.figure1,'zlab_cmaps',zlab_cmaps);
handles = depopulate_figure(handles);
create_continuous_maps(handles);
create_discrete_maps(handles);
guidata(handles.figure1,handles);

function handles = depopulate_figure(handles)
 hAllAxes = findobj(gcf,'type','axes');
 delete(hAllAxes);
                            
function edit_cmap_callback(hObject,eventdata,handles,ind)
incorp_tracking_win = getappdata(handles.figure1,'incorp_tracking_win');
zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
setappdata(handles.figure1,'current_cmap_ind',ind);
cmapInput = zlab_cmaps(ind);
if incorp_tracking_win
    eval('callingfig_handles = getappdata(handles.figure1,''callingfig_handles'');');
    if isempty(whos('callingfig_handles')) || isempty(callingfig_handles)
        callingfig_handles = getappdata(handles.figure1,'callingfig_handles');
    end
    callingfig = callingfig_handles.figure1;
else
	callingfig = handles.figure1;
    callingfig_handles = [];
end

cmapDB_figH = handles.figure1;
for_DB_bool = true;
setappdata(handles.figure1,'full_handles',handles);
%%%check if mapped numbers were passed from tracking window
mapped_numbers = getappdata(handles.figure1,'mapped_numbers');
if ~isempty(mapped_numbers)
    cmapInput.mapped_numbers = mapped_numbers;
end

if ~isfield(cmapInput,'continuous_vals')
    incr_val = (cmapInput.mapped_numbers(end) - cmapInput.mapped_numbers(1))/101;
    cmapInput.continuous_vals = cmapInput.mapped_numbers(1):incr_val:cmapInput.mapped_numbers(end);
end

h = custom_colorpicker_02(cmapInput.ncolors,callingfig,callingfig_handles,...
                            cmapInput.mapped_numbers,cmapInput.colorInput,cmapInput.cbar_txt,...
                            cmapInput.continuous_vals,cmapInput.expr_input,cmapInput.outside_loop_expr,...
                            for_DB_bool,cmapInput,cmapDB_figH);
uiwait(h);

function cmapout = make_default_cmap(handles,discrete_bool)
zlab_cmaps = getappdata(handles.figure1,'zlab_cmaps');
cmapout = zlab_cmaps(1);
cmapout.name = 'new map';
cmapout.cbar_txt = 'new map';

if discrete_bool
    cmapout.discrete_bool = true;
    cmapout.continuous_vals = [];
    cmapout.xticklabels = num2str((1:size(cmapout.colorInput,1))');
else
    cmapout.discrete_bool = false;
end