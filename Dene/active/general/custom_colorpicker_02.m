function h = custom_colorpicker_02(ncolors,callingfig,callingfig_handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input,outside_loop_expr,...
                            for_DB_bool,cmapDB,cmapDB_figH,edgesBool)
h = figure;
pos = [680,367,824,700];
set(h,'position',pos);
handles = guihandles(h); 
handles.figure1 = h;

if nargin <1 
    ncolors = 8;
end
setappdata(handles.figure1,'ncolors',ncolors);
if nargin > 2
    setappdata(handles.figure1,'callingfig',callingfig);
end
if nargin >3
    setappdata(handles.figure1,'callingfig_handles',callingfig_handles);
end
if nargin <4 || isempty(mapped_numbers)
    mapped_numbers = 1:ncolors;
end
setappdata(handles.figure1,'mapped_numbers',mapped_numbers);
if nargin <5 || isempty(colorInput)
    startcols = hsv(ncolors);
else
    startcols = colorInput;    
end
setappdata(handles.figure1,'startcols',startcols);
if nargin <6 || isempty(cbar_txt)
%     cbar_txt_bool = false;
    cbar_txt_bool = true;
    cbar_txt = 'none';
else
    cbar_txt_bool = true;
end
setappdata(handles.figure1,'cbar_txt_bool',cbar_txt_bool);
setappdata(handles.figure1,'cbar_txt',cbar_txt);
if nargin <7 || isempty(continuous_vals)
    discrete_bool = true;
else
    discrete_bool = false;
end
setappdata(handles.figure1,'discrete_bool',discrete_bool);
setappdata(handles.figure1,'alpha',0.6);
if exist('cmapDB','var')
    if isfield(cmapDB,'alpha')
        setappdata(handles.figure1,'alpha',cmapDB.alpha);
    end
end
        

if ~discrete_bool
    setappdata(handles.figure1,'continuous_vals',continuous_vals);
end
if nargin >7 && ~isempty(expr_input)
    setappdata(handles.figure1,'expr_input',expr_input);
    setappdata(handles.figure1,'use_expr_bool',true);
else
    setappdata(handles.figure1,'use_expr_bool',false);
end
if nargin >8 && ~isempty(outside_loop_expr)
    setappdata(handles.figure1,'outside_loop_expr',outside_loop_expr);
end

if nargin < 10 || isempty(for_DB_bool)
    for_DB_bool = false;
    setappdata(handles.figure1,'for_DB_bool',false);
else
    setappdata(handles.figure1,'for_DB_bool',for_DB_bool);
end

if nargin > 10 && ~isempty(cmapDB)
    setappdata(handles.figure1,'cmapDB',cmapDB);
    setappdata(handles.figure1,'original_cmapDB',cmapDB);
    setappdata(handles.figure1,'alpha',cmapDB.alpha);
    setappdata(handles.figure1,'style',cmapDB.style);
else
	setappdata(handles.figure1,'alpha',0.6);
    setappdata(handles.figure1,'style','linear');
end

if nargin < 12 || isempty(cmapDB_figH)
    if nargin < 2
        cmapDB_figH = [];
    else
        cmapDB_figH = callingfig;
    end
end
setappdata(handles.figure1,'cmapDB_figH',cmapDB_figH);

if nargin < 13 || isempty(edgesBool)
    edgesBool = false;
end
setappdata(handles.figure1,'edgesBool',edgesBool);

if nargin >=2 &&  ~isempty(callingfig)
    extrema = getappdata(callingfig,'curr_cmap_extrema');
    if ~isempty(extrema)
        minnum = extrema(1);
        maxnum = extrema(2);
        mapped_nums_from_tracking_bool = true;
        setappdata(handles.figure1,'extrema',extrema);
        setappdata(handles.figure1,'minMAPnum',minnum);
        setappdata(handles.figure1,'maxMAPnum',maxnum);
        setappdata(handles.figure1,'mapped_nums_from_tracking_bool',mapped_nums_from_tracking_bool);
        incr = (maxnum-minnum)/max((ncolors-1),1);
        mapped_numbers = minnum:incr:maxnum;
        setappdata(handles.figure1,'mapped_numbers',mapped_numbers);
    end
end

guidata(h,handles);
[ax1,rows,columns,midX,midY] = create_color_wheel(handles);
ax1.XLimMode = 'manual';
ax1.YLimMode = 'manual';

handles = auto_populate_figure_discrete(ncolors,handles,ax1,rows,columns,midX,midY);
handles = create_controls(handles);

if for_DB_bool
    handles = create_DB_output_controls(handles);
end
guidata(h,handles);


%%% create control buttons
function handles = create_controls(handles)
discrete_bool = getappdata(handles.figure1,'discrete_bool');
h = handles.figure1;
ncolors = getappdata(h,'ncolors');
pos = [0.795,0.945,0.05,0.03];
handles.ncol_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','n colors:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.85,0.95,0.05,0.03];
tempcb = @(hObject,eventdata) ncol_callback(hObject,eventdata,guidata(hObject));
handles.ncol_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',num2str(ncolors),...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
pos = [0.78,0.9,0.05,0.025];
tempcb = @(hObject,eventdata) discrete_colorstyle_callback(hObject,eventdata,guidata(hObject));
handles.discrete_col_style = uicontrol('Parent',h,'Style', 'togglebutton',...
        'string','discrete',...
        'value',discrete_bool,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.85,0.9,0.07,0.025];
tempcb = @(hObject,eventdata) continuous_colorstyle_callback(hObject,eventdata,guidata(hObject));
handles.continuous_col_style = uicontrol('Parent',h,'Style', 'togglebutton',...
        'string','continuous',...
        'value',~discrete_bool,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);

%%% Load Cmaps Button is still under construction
pos = [0.8,0.86,0.1,0.025];
tempcb = @(hObject,eventdata) loadcmap_callback(hObject,eventdata,guidata(hObject));
handles.load_cmapH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','load cmap',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'Visible','off');
    
pos = [0.8,0.83,0.1,0.025];
tempcb = @(hObject,eventdata) map_numbers_callback(hObject,eventdata,guidata(hObject));
handles.map_numbersH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','map numbers',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.8,0.80,0.1,0.025];
tempcb = @(hObject,eventdata) output_colormap_callback(hObject,eventdata,guidata(hObject));
handles.output_cmapH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','output',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.8,0.77,0.1,0.025];
tempcb = @(hObject,eventdata) make_extern_colorbar(hObject,eventdata,guidata(hObject));
handles.extern_cbarH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','colorbar',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.8,0.725,0.05,0.03];
handles.alpha_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','alpha:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.85,0.73,0.05,0.03];
tempcb = @(hObject,eventdata) setalpha_callback(hObject,eventdata,guidata(hObject));
alpha = getappdata(handles.figure1,'alpha');
handles.alpha_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',alpha,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.79,0.71,0.125,0.01];
tempcb = @(hObject,eventdata) alpha_sliderH_callback(hObject,eventdata,guidata(hObject));
handles.alpha_sliderH = uicontrol('Parent',h,'Style', 'slider',...
        'value',getappdata(handles.figure1,'alpha'),...
        'min',0,'max',1,'sliderstep',[0.01,0.1],...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.79,0.67,0.125,0.01];
tempcb = @(hObject,eventdata) interp_type_H_callback(hObject,eventdata,guidata(hObject));
interp_type_txt = {'nearest','next','previous','linear','spline','pchip','cubic','v5cubic'};
vistxt = {'on','off'};
style = getappdata(handles.figure1,'style');
style_ind = ismember(interp_type_txt,style);
if ~any(style_ind)
    display(['improper colormap specified: ',style]);
    style_ind = 4;
else
    style_ind = find(style_ind,1);
end
handles.interp_type_H = uicontrol('Parent',h,'Style', 'popup',...
        'string',interp_type_txt,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'visible',vistxt{discrete_bool+1},...
        'value',style_ind);

tempcb = @(hObject,eventdata) alpha_sliderH_callback(hObject,eventdata,guidata(hObject));
try    % R2013b and older
   addlistener(handles.alpha_sliderH,'ActionEvent',tempcb );
catch  % R2014a and newer    
   addlistener(handles.alpha_sliderH,'ContinuousValueChange',tempcb);
end  

function interp_type_H_callback(hObject,eventdata,handles)
delete(handles.contin_cbarH);
handles = create_contin_cbar(handles);          
guidata(handles.figure1,handles);

function alpha_sliderH_callback(hObject,eventdata,handles)
alpha = get(hObject,'value');
alpha = max(min(alpha,1),0);
set(handles.alpha_editH,'string',num2str(alpha));
setappdata(handles.figure1,'alpha',alpha);
update_alpha_value(handles,alpha);
    
function setalpha_callback(hObject,eventdata,handles)
alpha = str2double(get(hObject,'string'));
alpha = max(min(alpha,1),0);
set(hObject,'string',num2str(alpha));
set(handles.alpha_sliderH,'value',alpha);
setappdata(handles.figure1,'alpha',alpha);
update_alpha_value(handles,alpha);
    
function make_extern_colorbar(hObject,eventdata,handles)
[FileName,PathName] = uiputfile({'*.pdf;*.fig;*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Save Colorbar',...
          [pwd,filesep,'cbar.tif']);
FileName = strtok(FileName,'.');
discrete_bool = getappdata(handles.figure1,'discrete_bool');
mapped_numbers = getappdata(handles.figure1,'mapped_numbers');
output_colormap.colors = zeros(numel(mapped_numbers),3);
for i = 1:length(mapped_numbers)
    tempax = handles.ch1(i).Parent;
    col = colormap(tempax);
    output_colormap.colors(i,:) = col;
end
cbar_txt_bool = getappdata(handles.figure1,'cbar_txt_bool');
ticknums = ((1:size(output_colormap.colors,1))-0.5).*1/size(output_colormap.colors,1);
ticktxt = num2str(mapped_numbers');
if discrete_bool
    if cbar_txt_bool
        cbar_txt = getappdata(handles.figure1,'cbar_txt');
        save_custom_cbar(output_colormap.colors,ticknums,ticktxt,PathName,FileName,cbar_txt);
    else
        save_custom_cbar(output_colormap.colors,ticknums,ticktxt,PathName,FileName);
    end
else
    contin_colors = colormap(handles.ax3);
    ticknums = (0:size(output_colormap.colors,1)/max(numel(mapped_numbers)-1,1):(size(output_colormap.colors,1))).*1/size(output_colormap.colors,1);

    if cbar_txt_bool
        cbar_txt = getappdata(handles.figure1,'cbar_txt');        
        save_custom_cbar(contin_colors,ticknums,ticktxt,PathName,FileName,cbar_txt);
    else
        save_custom_cbar(contin_colors,ticknums,ticktxt,PathName,FileName);
    end
end
    
save([PathName,'cmap_data'],'output_colormap');

function output_colormap = output_colormap_callback(hObject,eventdata,handles)
output_colormap.numbs = getappdata(handles.figure1,'mapped_numbers');
output_colormap.colors = zeros(numel(output_colormap.numbs),3);
output_colormap.discrete_bool = getappdata(handles.figure1,'discrete_bool');
if ~output_colormap.discrete_bool
    output_colormap.contin_numbs = getappdata(handles.figure1,'continuous_vals');
    output_colormap.contin_colors = colormap(handles.ax3);
end
output_colormap.alpha = getappdata(handles.figure1,'alpha');

if getappdata(handles.figure1,'use_expr_bool')
    output_colormap.expr_input = getappdata(handles.figure1,'expr_input');
end

if ~isempty(getappdata(handles.figure1,'outside_loop_expr'))
    output_colormap.outside_loop_expr = getappdata(handles.figure1,'outside_loop_expr');
end

for i = 1:length(output_colormap.numbs)
    tempax = handles.ch1(i).Parent;
    col = colormap(tempax);
    output_colormap.colors(i,:) = col;
end
display(output_colormap);
setappdata(handles.figure1,'output_colormap',output_colormap);
callingfig = getappdata(handles.figure1,'callingfig');
if isempty(callingfig)
    display('no calling fig')
    return
end
setappdata(callingfig,'output_colormap',output_colormap);
callingfig_handles = getappdata(handles.figure1,'callingfig_handles');


%%% For handling edge coloring
edgesBool = getappdata(handles.figure1,'edgesBool');
if isempty(edgesBool)
    cmapDB_figH = getappdata(handles.figure1,'cmapDB_figH');
    if ishandle(cmapDB_figH)
        edgesBool = getappdata(cmapDB_figH,'edgesBool');
    else
        edgesBool = false;
    end
end
%%% For handling edge coloring
if edgesBool
    tracking('coloredges_for_colorpicker_Callback',callingfig_handles);
else
    tracking('colorcells_for_colorpicker_Callback',callingfig_handles);
end


function map_numbers_callback(hobject, eventdata,handles)
curr_numbs = getappdata(handles.figure1,'mapped_numbers');
choose_map_numbers(handles);
if getappdata(handles.figure1,'continue_bool')
    style = getappdata(handles.figure1,'mapnumb_style');
    display(style);
    if strcmp(style,'set min');
       numbs_output = inputdlg('Enter minimum number:',...
             'map numbers', [1 50]);
       if isempty(numbs_output)
             display('user cancelled');
             return
       end

       if ~getappdata(handles.figure1,'discrete_bool')
            set(handles.discrete_col_style,'value',~getappdata(handles.figure1,'discrete_bool'));
            handles = discrete_colorstyle_callback(handles.discrete_col_style,[],handles);
       end
       newmin = str2num(numbs_output{1});
       newnumbs = newmin:(newmin+numel(handles.numtexH)-1);
       setappdata(handles.figure1,'mapped_numbers',newnumbs);

       delete(handles.numtexH);
       map_numbers_to_colors(handles,newnumbs);
    else
        numbs_output = inputdlg('Enter space-separated numbers:',...
             'map numbers', [1 50]);
         if isempty(numbs_output)
             display('user cancelled');
             return
         end
        newnumbs = str2num(numbs_output{:});
        setappdata(handles.figure1,'mapped_numbers',newnumbs);
        if ~getappdata(handles.figure1,'discrete_bool')
            set(handles.discrete_col_style,'value',~getappdata(handles.figure1,'discrete_bool'));            
        end
        if numel(newnumbs) ~= numel(curr_numbs)
            depopulate_color_picker(handles);
            auto_populate_figure_discrete(numel(newnumbs),handles);
            setappdata(handles.figure1,'ncolors',numel(newnumbs));
        else
            discrete_colorstyle_callback(handles.discrete_col_style,[],handles);
%             delete(handles.numtexH);
%             map_numbers_to_colors(handles,newnumbs);
        end
    end       
end

if getappdata(handles.figure1,'for_DB_bool')
    cmapDB = getappdata(handles.figure1,'cmapDB');
    cmapDB.mapped_numbers = newnumbs;
    set(handles.mappedNumbs_editH,'string',num2str(newnumbs'));
    
    
     answBtn = questdlg('change tick labels to match new mapped numbers?', ...
                         'change tick labels', ...
                         'Yes','No','Yes');
   switch answBtn
     case 'Yes'
         numxticks = size(cmapDB.xticklabels,1);
         if numxticks == 2
             cmapDB.xticklabels = num2str([newnumbs(1);newnumbs(end)]);
             set(handles.xticklabels_editH,'string',cmapDB.xticklabels);
         else if numxticks == numel(newnumbs)
                 cmapDB.xticklabels = num2str(newnumbs');
                 set(handles.xticklabels_editH,'string',cmapDB.xticklabels);
             else
                 display('number of xticks does not match expected numel');
                 return
             end
         end
     case 'No'      
   end
   setappdata(handles.figure1,'cmapDB',cmapDB);
end

    
function choose_map_numbers(handles)

d = dialog('Position',[300 300 250 150],'Name','Select One');
txt = uicontrol('Parent',d,...
       'Style','text',...
       'Position',[20 80 210 40],...
       'String','Select an option');
%%%just to initialize
setappdata(handles.figure1,'mapnumb_style','set min');

tempcb = @(hObject,eventdata) map_numb_popup_callback(hObject,eventdata,handles);    
popup = uicontrol('Parent',d,...
       'Style','popup',...
       'Position',[75 70 100 25],...
       'String',{'set min';'set all'},...
       'Callback',tempcb);
tempcb = @(hObject,eventdata) continue_btn_callback(hObject,eventdata,handles);   
continue_btn = uicontrol('Parent',d,...
       'Position',[50 20 60 25],...
       'String','continue',...
       'Callback',tempcb);
tempcb = @(hObject,eventdata) cancel_btn_callback(hObject,eventdata,handles);    
cancel_btn = uicontrol('Parent',d,...
       'Position',[130 20 60 25],...
       'String','cancel',...
       'Callback',tempcb);

uiwait(d);
    
function map_numb_popup_callback(popup,callbackdata,handles)
idx = popup.Value;
popup_items = popup.String;
userChoice = char(popup_items(idx,:));
setappdata(handles.figure1,'mapnumb_style',userChoice);
    
function loadcmap_callback(hobject, eventdata,handles)
choose_cmap_dialog(handles);
display(getappdata(handles.figure1,'cmapChoice'));
if getappdata(handles.figure1,'continue_bool')
    cbrewer;
end


function choose_cmap_dialog(handles)

d = dialog('Position',[300 300 250 150],'Name','Select One');
txt = uicontrol('Parent',d,...
       'Style','text',...
       'Position',[20 80 210 40],...
       'String','Select a set');
%%%just to initialize
setappdata(handles.figure1,'cmapChoice','cbrewer discrete');

tempcb = @(hObject,eventdata) popup_callback(hObject,eventdata,handles);   
popup = uicontrol('Parent',d,...
       'Style','popup',...
       'Position',[75 70 100 25],...
       'String',{'cbrewer discrete';'cbrewer continuous';'zlab discrete';'zlab continuous'},...
       'Callback',tempcb);
tempcb = @(hObject,eventdata) continue_btn_callback(hObject,eventdata,handles);   
continue_btn = uicontrol('Parent',d,...
       'Position',[50 20 60 25],...
       'String','continue',...
       'Callback',tempcb);
tempcb = @(hObject,eventdata) cancel_btn_callback(hObject,eventdata,handles);      
cancel_btn = uicontrol('Parent',d,...
       'Position',[130 20 60 25],...
       'String','cancel',...
       'Callback',tempcb);
uiwait(d);

    
function popup_callback(popup,callbackdata,handles)
  idx = popup.Value;
  popup_items = popup.String;
  userChoice = char(popup_items(idx,:));
  setappdata(handles.figure1,'cmapChoice',userChoice);


function continue_btn_callback(continue_btn,callbackdata,handles)
  setappdata(continue_btn.Parent,'continue_bool',true);
  setappdata(handles.figure1,'continue_bool',true);     
  close(continue_btn.Parent);


function cancel_btn_callback(cancel_btn,callbackdata,handles)
  setappdata(cancel_btn.Parent,'continue_bool',false);
  setappdata(handles.figure1,'continue_bool',false);     
  close(cancel_btn.Parent);

   
    
function handles = discrete_colorstyle_callback(hobject, eventdata,handles)
discrete_bool = get(hobject,'value');
set(handles.continuous_col_style,'value',~discrete_bool);
last_color_style = getappdata(handles.figure1,'discrete_bool');
if discrete_bool == last_color_style    
    return
end
setappdata(handles.figure1,'discrete_bool',discrete_bool);
if discrete_bool
    set(handles.interp_type_H,'visible','off');
    if isvalid(handles.contin_cbarH)
        delete(handles.contin_cbarH);
    end
    if isvalid(handles.ax3)
        delete(handles.ax3);
    end
    handles = create_bottom_colors(handles);
    if isvalid(handles.contin_cbarH)
        delete(handles.contin_cbarH);
    end
else
    set(handles.interp_type_H,'visible','on');
    if isvalid(handles.ch2)
        delete(handles.ch2);
    end
	if isvalid(handles.numtexH)
        delete(handles.numtexH);
    end
    handles = create_contin_cbar(handles);            
end
update_alpha_value(handles);
guidata(handles.figure1,handles);

function handles = create_contin_cbar(handles)
continuous_vals = getappdata(handles.figure1,'continuous_vals');
if isempty(continuous_vals)
    input_expr = inputdlg('Enter continuous numbers:',...
             'map numbers', [1 50],{'0:0.01:1'});
         if isempty(input_expr)
             display('user cancelled');
             return
         end
         eval(['continuous_vals = ',input_expr{:},';']);
end
setappdata(handles.figure1,'continuous_vals',continuous_vals);
m = numel(continuous_vals);
% contin_cmap = zeros(m,3);
ncolors = getappdata(handles.figure1,'ncolors');
% section_inds = [1,numel(continuous_vals) - numel(continuous_vals)./(ncolors:-1:1),numel(continuous_vals)];
startcols = zeros(ncolors,3);
for i = 1:min(length(handles.ch1),ncolors)
        tempax = handles.ch1(i).Parent;
        col = colormap(tempax);
        startcols(i,:) = col;
end
if isfield(handles,'interp_type_H')
    all_interp_types = get(handles.interp_type_H,'string');%'linear'; 
    interp = all_interp_types{get(handles.interp_type_H,'value')};
else
%     interp = 'linear';
    interp = getappdata(handles.figure1,'style');
end
if m ~= size(startcols, 1)
    xi = linspace(1, size(startcols, 1), m);
    cm = interp1(startcols, xi, interp);
end
cm = min(max(cm,0),1);
pos = [0.06,0.025,0.9,0.10];
handles.ax3 = axes('position',pos,'parent',handles.figure1);
handles.contin_cbarH = image(1:m,'parent',handles.ax3);
set(handles.ax3,'tag','continuous_cbar');
axes(handles.ax3)
axis off;
set(handles.ax3,'XTickLabel',[]);
set(handles.ax3,'YTickLabel',[]);
colormap(handles.ax3,cm);
update_alpha_value(handles);
guidata(handles.figure1,handles);


function handles = re_eval_continuous_cmap(handles)
if isvalid(handles.contin_cbarH)
    delete(handles.contin_cbarH);
end
if isvalid(handles.ax3)
    delete(handles.ax3);
end
handles = create_contin_cbar(handles);
guidata(handles.figure1,handles);

function continuous_colorstyle_callback(hobject, eventdata,handles)
discrete_bool = ~get(hobject,'value');
set(handles.discrete_col_style,'value',discrete_bool);
last_color_style = getappdata(handles.figure1,'discrete_bool');
if discrete_bool == last_color_style
    return
end
setappdata(handles.figure1,'discrete_bool',discrete_bool);
if discrete_bool
    set(handles.interp_type_H,'visible','off');
    if isvalid(handles.contin_cbarH)
        delete(handles.contin_cbarH);
    end
    if isvalid(handles.ax3)
        delete(handles.ax3);
    end
    handles = create_bottom_colors(handles);
else
    set(handles.interp_type_H,'visible','on');
    if isvalid(handles.ch2)
        delete(handles.ch2);
    end
	if isvalid(handles.numtexH)
        delete(handles.numtexH);
    end
    handles = create_contin_cbar(handles);            
end
handles = update_alpha_value(handles);
guidata(handles.figure1,handles);

%%%change number of colors     
function ncol_callback(hobject, eventdata,handles)
new_ncolors = str2num(get(hobject,'string'));
discrete_bool = getappdata(handles.figure1,'discrete_bool');
if new_ncolors ~= getappdata(handles.figure1,'ncolors');
    
    mapped_numbers = getappdata(handles.figure1,'mapped_numbers');
    if discrete_bool
        if new_ncolors < getappdata(handles.figure1,'ncolors')
            setappdata(handles.figure1,'mapped_numbers',mapped_numbers(1:new_ncolors));                       
            if getappdata(handles.figure1,'for_DB_bool')
                newnumbs_str = num2str(mapped_numbers(1:new_ncolors));
                set(handles.mappedNumbs_editH,'string',newnumbs_str);
                mapped_numbers_callback(handles.mappedNumbs_editH,eventdata,handles);
            end
        else
            setappdata(handles.figure1,'mapped_numbers',mapped_numbers(1):(mapped_numbers(1)+new_ncolors-1));
            if getappdata(handles.figure1,'for_DB_bool')
                newnumbs_str = num2str(mapped_numbers(1):(mapped_numbers(1)+new_ncolors-1));           
                set(handles.mappedNumbs_editH,'string',newnumbs_str);
                mapped_numbers_callback(handles.mappedNumbs_editH,eventdata,handles);
            end
        end
    else %continuous
        min_num = mapped_numbers(1);
        max_num = mapped_numbers(end);
        newmappednums = round(min_num:(max_num-min_num)/(new_ncolors-1):max_num);
        if mod(new_ncolors,2)~=0
            newmappednums(round(end/2)) = (max_num - min_num)/2;
        end
        newmappednums(end) = max_num;
        setappdata(handles.figure1,'mapped_numbers',newmappednums);
    end
    setappdata(handles.figure1,'ncolors',new_ncolors);
    startcols = zeros(new_ncolors,3);
    for i = 1:min(length(handles.ch1),new_ncolors)
        tempax = handles.ch1(i).Parent;
        col = colormap(tempax);
        startcols(i,:) = col;
    end
    if length(handles.ch1)< new_ncolors
        for i = (length(handles.ch1)+1):new_ncolors
            col = rand(1,3);
            startcols(i,:) = col;
        end
    end
    setappdata(handles.figure1,'startcols',startcols);
	depopulate_color_picker(handles);
    handles = auto_populate_figure_discrete(new_ncolors,handles);
    guidata(handles.figure1,handles);
    
end
    
%%%remove all stuff    
function depopulate_color_picker(handles)
delete(handles.ch1);
delete(handles.sldH);
delete(handles.txtH);
delete(handles.sh);
delete(handles.ph);

discrete_bool = getappdata(handles.figure1,'discrete_bool');
if discrete_bool
    if isvalid(handles.ch2)
        delete(handles.ch2);
    end
	if isvalid(handles.numtexH)
        delete(handles.numtexH);
    end
else
    if isvalid(handles.contin_cbarH)
        delete(handles.contin_cbarH);
    end
    if isvalid(handles.ax3)
        delete(handles.ax3);
    end
end
guidata(handles.figure1,handles);
%%%move scatter circle with impoint
% function change_scatter_with_impoint(sh1,ph1,ch1,midX,midY,sldH,txtH,ch2,handles)
function change_scatter_with_impoint(ph1,ind,handles)
sh1 = handles.sh(ind);
ch1 = handles.ch1(ind);
midX = getappdata(handles.figure1,'midX');
midY = getappdata(handles.figure1,'midY');
sldH = handles.sldH(ind,:);
txtH = handles.txtH(ind,:);


v = get(sldH(4),'value')/255;
set(sh1,'xdata',ph1(1),'ydata',ph1(2));
radius = sqrt((ph1(2) - midY)^2 + (ph1(1) - midX)^2) / min([midX, midY]);
s = min(1, radius); % Max out at 1
h = (180-atan2d((ph1(2) - midY), (ph1(1) - midX)))/360;
h = (h+0.5)-(h>0.5);
h = max(min(h,1),0);
rgbval = hsv2rgb([h,s,v]);
colormap(ch1.Parent,rgbval);

for i = 1:3
    set(sldH(i),'value',round(rgbval(i)*255),'BackgroundColor',rgbval);
    set(txtH(i),'string',num2str(round(rgbval(i)*255)));
end
set(sldH(4),'BackgroundColor',rgbval);

discrete_bool = getappdata(handles.figure1,'discrete_bool');
if discrete_bool
    ch2 = handles.ch2(ind);
	colormap(ch2.Parent,rgbval);
else
    handles = re_eval_continuous_cmap(handles);
end
startcols = getappdata(handles.figure1,'startcols');
startcols(ind,:) = rgbval;
setappdata(handles.figure1,'startcols',startcols);
guidata(handles.figure1,handles);
    

%%%construct slider (start without callbacks)
function sldH = construct_sliders(col_ax,handles)
axPos = get(col_ax,'position');
col = colormap(col_ax);
sldH = [];
y_incr = 0.15;
for i = 1:3
    ypos = (axPos(2)+axPos(4))*0.8-(axPos(4)*(i*y_incr));
    sldH = [sldH, uicontrol('Style', 'slider',...
        'Min',0,'Max',255,'Value',round(col(i)*255),...
        'Unit', 'normalized',...
        'Position', [axPos(1) ypos axPos(3) axPos(4)*y_incr],...
        'BackgroundColor',col)]; 
end

ypos = (axPos(2)+axPos(4))*0.8-(axPos(4)*(4*y_incr));
vval = getappdata(handles.figure1,'vval');
sldH = [sldH, uicontrol('Style', 'slider',...
        'Min',0,'Max',255,'Value',round(vval*255),...
        'Unit', 'normalized',...
        'Position', [axPos(1) ypos axPos(3) axPos(4)*y_incr],...
        'BackgroundColor',col)];


%%%create RGB text
function txtH = construct_text(col_ax,handles)
axPos = get(col_ax,'position');
col = colormap(col_ax);
bgcol = [1 1 1];
txtH = [];
y_incr = 0.15;
x_incr = 0.25;

x_shift = 0.25;
% edittxt
for i = 1:3 %RGB
    ypos = axPos(2)-(axPos(4)*y_incr);
    xpos = axPos(1)+(x_shift*axPos(3))+axPos(3)*x_incr*(i-1);
    txtH = [txtH, uicontrol('Style', 'edit',...
        'String',round(col(i)*255),...
        'Unit', 'normalized',...
        'Position', [xpos ypos axPos(3)*x_incr axPos(4)*y_incr],...
        'Callback', @(hObject,eventdata) textcallback(hObject,eventdata,guidata(hObject)),...
        'BackgroundColor',bgcol)]; 
end
txtH = [txtH, uicontrol('Style', 'text',...
        'String',{'';'RGB'},...
        'Unit', 'normalized',...
        'Position', [axPos(1) ypos axPos(3)*x_shift axPos(4)*y_incr],...
        'BackgroundColor',bgcol)]; 

%%%text callback for RGB values
function textcallback(hObject,~,handles) 
[ind,j] = find(handles.txtH==hObject);
inputNum = min(max(str2double(get(hObject,'string')),0),255);
set(handles.sldH(ind,j),'value',inputNum);
rgb_val = zeros(1,3);
for i = 1:3
   rgb_val(i) = get(handles.sldH(ind,i),'value')/255;   
end
hsv_val = rgb2hsv(rgb_val);
set(handles.sldH(ind,4),'value',round(hsv_val(3)*255));
handles =update_all_handles_post_slider(hObject,ind,rgb_val,handles);
guidata(handles.figure1,handles);
   
%%%add listeners to all sliders
function add_listeners_to_sliders(sldH)       
tempcb = @(hObject,eventdata) slider_Callback(hObject,eventdata,guidata(hObject));
for i = 1:3
    hSlider = sldH(i);
    try    % R2013b and older
       addlistener(hSlider,'ActionEvent',tempcb );
    catch  % R2014a and newer    
       addlistener(hSlider,'ContinuousValueChange',tempcb);
    end    
end
%%%for the last slider, the v in hsv
tempcb = @(hObject,eventdata) slider_hsv_Callback(hObject,eventdata,guidata(hObject));
hSlider = sldH(4);
try    % R2013b and older
   addlistener(hSlider,'ActionEvent',tempcb );
catch  % R2014a and newer    
   addlistener(hSlider,'ContinuousValueChange',tempcb);
end 

%%%update all handles, keep everything in sync
function handles = update_all_handles_post_slider(gcbo,ind,rgb_val,handles)
% handles = guidata(gcbo);
hsv_val = rgb2hsv(rgb_val);
h = hsv_val(1);
s = hsv_val(2);
radius = getappdata(handles.figure1,'radius');
midX = getappdata(handles.figure1,'midX');
midY = getappdata(handles.figure1,'midY');
rho = s*radius;
[x,y] = pol2cart(h*-2*pi,rho);
x = x+midX;
y = y+midY;
set(handles.sh(ind),'xdata',x,'ydata',y);
setPosition(handles.ph(ind),x,y);
for i = 1:3
    set(handles.txtH(ind,i),'string',num2str(round(rgb_val(i)*255)));
end
colormap(handles.ch1(ind).Parent,rgb_val);
discrete_bool = getappdata(handles.figure1,'discrete_bool');

if discrete_bool
    colormap(handles.ch2(ind).Parent,rgb_val);
else
	if isvalid(handles.contin_cbarH)
        delete(handles.contin_cbarH);
    end
    if isvalid(handles.ax3)
        delete(handles.ax3);
    end
    second_sweep(handles);
    handles = re_eval_continuous_cmap(handles);
end
guidata(handles.figure1,handles);


%%%slider callback for rgb slider listener
function slider_Callback(hObject,~,handles)
[ind,~] = find(handles.sldH==hObject);
% display(['slider ind: ',num2str(ind)]);
rgb_val = zeros(1,3);
for i = 1:3
   rgb_val(i) = get(handles.sldH(ind,i),'value')/255;
end
% display(['rgb_val: ',num2str(rgb_val)]);
hsv_val = rgb2hsv(rgb_val);
set(handles.sldH(ind,4),'value',round(hsv_val(3)*255));
handles = update_all_handles_post_slider(hObject,ind,rgb_val,handles);
guidata(handles.figure1,handles);

%%%slider callback for 'v' slider listener
function slider_hsv_Callback(hObject,~,handles)
[ind,~] = find(handles.sldH==hObject);
rgb_val = zeros(1,3);
for i = 1:3
   rgb_val(i) = get(handles.sldH(ind,i),'value')/255;
end
%%%modify rgb values based on 'v' modification
hsv_val = rgb2hsv(rgb_val);
v = get(hObject,'value')/255;
hsv_val(3) = v;
rgb_val = hsv2rgb(hsv_val);
handles = update_all_handles_post_slider(hObject,ind,rgb_val,handles);
guidata(handles.figure1,handles);

%%%create the color wheel, referenced to throughout
function [ax1,rows,columns,midX,midY] = create_color_wheel(handles)
%%%make axes for color wheel
ax1 = axes();
pos = [0.05,0.35,0.9,0.65];
set(ax1,'position',pos);
hold on
handles.ax1 = ax1;
rows = 500;
columns = 500;
midX = columns / 2;
midY = rows / 2;
vval = 0.95;
setappdata(handles.figure1,'rows',rows);
setappdata(handles.figure1,'columns',columns);
setappdata(handles.figure1,'midX',midX);
setappdata(handles.figure1,'midY',midY);
setappdata(handles.figure1,'vval',vval);

% Construct v image as uniform.
v = 0.95 * ones(rows, columns);
s = zeros(size(v)); % Initialize.
h = zeros(size(v)); % Initialize.
% Construct the h image as going from 0 to 1 as the angle goes from 0 to 360.
% Construct the S image going from 0 at the center to 1 at the edge.
for c = 1 : columns
	for r = 1 : rows
		% Radius goes from 0 to 1 at edge, a little more in the corners.
		radius = sqrt((r - midY)^2 + (c - midX)^2) / min([midX, midY]);
		s(r, c) = min(1, radius); % Max out at 1
		h(r, c) = atan2d((r - midY), (c - midX));
	end
end
% Flip h right to left.
h = fliplr(mat2gray(h));
% Construct the hsv image.
hsvmat = cat(3, h, s, v);
% Construct the RGB image.
rgbImage = hsv2rgb(hsvmat);
%%%create circular mask
imageSizeX = columns;
imageSizeY = rows;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = columns/2;
centerY = rows/2;
radius = min(rows,columns)/2;
setappdata(handles.figure1,'radius',radius);
mask = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
mask = repmat(mask,1,1,3);
rgbImage(~mask) = 0;
% Display the RGB image.
axes(ax1);
imshow(rgbImage, []);
title('RGB Image, with V = 0.95');
drawnow;
%save from data for use in other places
setappdata(handles.figure1,'ax1',ax1);
setappdata(handles.figure1,'rows',rows);
setappdata(handles.figure1,'columns',columns);
setappdata(handles.figure1,'midX',midX);
setappdata(handles.figure1,'midY',midY);
guidata(handles.figure1,handles);

%%%populate the figure with discrete colors
function handles = auto_populate_figure_discrete(ncolors,handles,ax1,rows,columns,midX,midY)

if nargin < 7
   ax1 =  getappdata(handles.figure1,'ax1');
   rows = getappdata(handles.figure1,'rows');
   columns = getappdata(handles.figure1,'columns');
   midX =  getappdata(handles.figure1,'midX');
   midY = getappdata(handles.figure1,'midY');
end
% setappdata(handles.figure1,'discrete_bool',true); %discrete by defualt
x_incr = 1/ncolors;
y_incr = 0.25;
sh = [];
ph = [];
ch1 = [];
sldH = [];
txtH = [];
startcols = getappdata(handles.figure1,'startcols');
for i = 1:ncolors
    %create initial colors
    new_ax = axes();
    pos = [(i-1)*x_incr,0.19,x_incr,y_incr];
    set(new_ax,'position',pos);
    col = startcols(i,:);
    ch1 = [ch1, image(1,1,1)];
    colormap(new_ax,col)
    axis off
    sldH = [sldH; construct_sliders(new_ax,handles)];
    txtH = [txtH; construct_text(new_ax,handles)];
    
    %create interactive points in color wheel
    axes(ax1);
    temphsv = rgb2hsv(col);
    h = temphsv(1);
    s = temphsv(2);
    radius = min(rows,columns)/2;
    rho = s*radius;
    [x,y] = pol2cart(h*-2*pi,rho);
    x = x+midX;
    y = y+midY;
	sh = [sh,scatter(x, y,150,'w')];
    ph = [ph,impoint(ax1,x, y)];
end



%%%make axes for color experiments %(second square below)
ax2 = axes();
pos = [0.0,0.0,1,0.15];
set(ax2,'position',pos);
hold on
handles.ax2 = ax2;
image([1;2;3]);
cmap = gray(3);
colormap(ax2,cmap);
axis off
handles.ch1 = ch1; %image handles
handles.sldH = sldH; %slider handles
handles.txtH = txtH; %text handles
handles.sh = sh; %scatter handles
handles.ph = ph; %point handles
guidata(handles.figure1,handles);

discrete_bool = getappdata(handles.figure1,'discrete_bool');
if discrete_bool
    offset = 0.1;
    ch2 = [];
    for i = 1:ncolors
        new_ax = axes();
        pos = [(i-1)*x_incr+offset*x_incr,0.025,x_incr*(1-x_incr),0.1];
        set(new_ax,'position',pos);
        col = startcols(i,:);
        ch2 = [ch2, image(1,1,1)];
        colormap(new_ax,col)
        axis off
        addNewPositionCallback(ph(i),...
            @(p) change_scatter_with_impoint(p,i,guidata(handles.figure1)));
    %@(p) change_scatter_with_impoint(sh(i),p,ch1(i),midX,midY,sldH(i,:),txtH(i,:),ch2(i),guidata(handles.figure1)));
    end
    handles.ch2 = ch2; %second color square
    numbs = getappdata(handles.figure1,'mapped_numbers');
    handles = map_numbers_to_colors(handles,numbs);
else
    for i = 1:ncolors
        addNewPositionCallback(ph(i),...
            @(p) change_scatter_with_impoint(p,i,guidata(handles.figure1)));
    end
    handles = create_contin_cbar(handles);
end
handles = update_alpha_value(handles);    
guidata(handles.figure1,handles);
for i = 1:ncolors
    add_listeners_to_sliders(sldH(i,:));
end
guidata(handles.figure1,handles);

%%% map numbers to colors
function handles = map_numbers_to_colors(handles,numbs)
numtexH = [];
if numel(numbs) ~= numel(handles.ch2)
    incr = (numbs(end)-numbs(1))/max(numel(handles.ch2) - 1,1);
    numbs = numbs(1):incr:numbs(end);
end
for i = 1:numel(numbs)
    posstart = get(handles.ch2(i).Parent,'position');
%     textpos = [posstart(1) + posstart(3)/3, posstart(2)+ posstart(4)/3, posstart(3)/3,posstart(4)/3];
    axes(handles.ch2(i).Parent);    
    numtexH = [numtexH, text(0.6,1,num2str(numbs(i)),...
            'fontweight','bold','fontsize',42/max(1,numel(numbs)/2 - 2))];
end
handles.numtexH = numtexH;
guidata(handles.figure1,handles); 

function handles = create_bottom_colors(handles)
%%%make axes for color experiments %(second square below)
ncolors = getappdata(handles.figure1,'ncolors');
startcols = getappdata(handles.figure1,'startcols');
x_incr = 1/ncolors;
offset = 0.1;
ch2 = [];
for i = 1:ncolors
    new_ax = axes();
    pos = [(i-1)*x_incr+offset*x_incr,0.025,x_incr*(1-x_incr),0.1];
    set(new_ax,'position',pos);
    col = startcols(i,:);
    ch2 = [ch2, image(1,1,1)];
    colormap(new_ax,col)
    axis off
    addNewPositionCallback(handles.ph(i),...
        @(p) change_scatter_with_impoint(p,i,guidata(handles.figure1)));
end
handles.ch2 = ch2; %second color square
guidata(handles.figure1,handles);
for i = 1:ncolors
    add_listeners_to_sliders(handles.sldH(i,:));
end

numbs = getappdata(handles.figure1,'mapped_numbers');
handles = map_numbers_to_colors(handles,numbs);
guidata(handles.figure1,handles);

function handles = update_alpha_value(handles,alpha)
if nargin < 2
    alpha = getappdata(handles.figure1,'alpha');
end
discrete_bool = getappdata(handles.figure1,'discrete_bool');
if discrete_bool
    set(handles.ch2,'AlphaData',alpha);
else
    set(handles.contin_cbarH,'AlphaData',alpha);
end
guidata(handles.figure1,handles);

function second_sweep(handles)
allH1 =findobj(handles.figure1,'type','axes');
for i = 1:length(allH1)
    test = strcmp(allH1(i).Tag,'continuous_cbar');
    if test
        delete(allH1(i));
    end
end



function handles = create_DB_output_controls(handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
h = handles.figure1;
%%%NAME
pos = [0.02,0.95,0.05,0.03];
handles.name_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','name:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.07,0.95,0.15,0.03];
tempcb = @(hObject,eventdata) cmap_name_callback(hObject,eventdata,guidata(hObject));
handles.name_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',cmapDB.name,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
%%%MAPPED  NUMBERS    
pos = [0.005,0.91,0.075,0.04];
handles.mappedNumbs_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','mapped numbers:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.07,0.91,0.15,0.04];
tempcb = @(hObject,eventdata) mapped_numbers_callback(hObject,eventdata,guidata(hObject));
handles.mappedNumbs_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',cmapDB.mapped_numbers',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'Max',numel(cmapDB.mapped_numbers));
%%%CBAR TXT    
pos = [0.005,0.87,0.075,0.04];
handles.cbar_txt_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','cbar txt:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.07,0.87,0.15,0.04];
tempcb = @(hObject,eventdata) cbar_txt_callback(hObject,eventdata,guidata(hObject));
handles.cbar_txt_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',cmapDB.cbar_txt,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);

%%%CONTINUOUS VALUES     
pos = [0.005,0.83,0.075,0.04];
handles.continuous_vals_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','continuous values:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.07,0.83,0.15,0.04];
tempcb = @(hObject,eventdata) continuous_vals_callback(hObject,eventdata,guidata(hObject));
handles.continuous_vals_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',cmapDB.contin_val_expr,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'Max',2);
    
%%%XTICKLABELS     
pos = [0.005,0.79,0.075,0.04];
handles.xticklabels_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','xticklabels:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.07,0.79,0.15,0.04];
tempcb = @(hObject,eventdata) xticklabels_callback(hObject,eventdata,guidata(hObject));
handles.xticklabels_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',cmapDB.xticklabels',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'Max',2);
advanced_settings_exposed_bool = false;

%%%EXPR INPUT      
pos = [0.0025,0.745,0.0675,0.045];
tempcb = @(hObject,eventdata) expr_input_callback(hObject,eventdata,guidata(hObject));
handles.expr_input_pushbtnH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','expr input',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'Max',2);
pos = [0.07,0.69,0.15,0.1];
handles.expr_input_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string',cmapDB.expr_input,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Max',10);


%%%OUtside Loop EXPR INPUT    
pos = [0.0025,0.60,0.0675,0.07];
tempcb = @(hObject,eventdata) outloop_expr_input_callback(hObject,eventdata,guidata(hObject));
handles.outloop_expr_input_pushbtnH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','outside loop expr',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb,...
        'Max',3);
set(handles.outloop_expr_input_pushbtnH, 'String', '<html>outside<br>loop<br>expr');
pos = [0.07,0.59,0.15,0.1];
handles.outloop_expr_input_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string',cmapDB.outside_loop_expr,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Max',10);
if ~advanced_settings_exposed_bool
    handles.expr_input_pushbtnH.Visible = 'off';
    handles.expr_input_staticH.Visible = 'off';
    handles.outloop_expr_input_pushbtnH.Visible = 'off';
    handles.outloop_expr_input_staticH.Visible = 'off';        
end %advanced_settings_exposed_bool

    tempcb = @(hObject,eventdata) output_new_cmap_callback(hObject,eventdata,guidata(hObject));    
    pos = [0.05,0.45,0.1,0.05];
    handles.apply_cmap_changeH = uicontrol('Parent',h,'Style', 'pushbutton',...
            'string','apply',...
            'Unit', 'normalized',...
            'Position', pos,...
            'Callback', tempcb,...
            'Max',10);

    
guidata(handles.figure1,handles);
    
function cmap_name_callback(hObject,eventdata,handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
cmapDB.name = get(hObject,'string');
setappdata(handles.figure1,'cmapDB',cmapDB);

function mapped_numbers_callback(hObject,eventdata,handles)
oldnumbs = getappdata(handles.figure1,'mapped_numbers');
cmapDB = getappdata(handles.figure1,'cmapDB');
cmapDB.mapped_numbers = flatten(str2num(get(hObject,'string')))';
setappdata(handles.figure1,'cmapDB',cmapDB);
setappdata(handles.figure1,'mapped_numbers',cmapDB.mapped_numbers);

newnumbs = cmapDB.mapped_numbers;
% if ~getappdata(handles.figure1,'discrete_bool')
%     set(handles.discrete_col_style,'value',true);
%     set(handles.continuous_col_style,'value',false);
%     setappdata(handles.figure1,'discrete_bool',true);
% end
if numel(newnumbs) ~= numel(oldnumbs)
    new_ncolors = numel(newnumbs);
    set(handles.ncol_editH,'string',num2str(new_ncolors));
    setappdata(handles.figure1,'ncolors',new_ncolors);
    startcols = zeros(new_ncolors,3);
    for i = 1:min(length(handles.ch1),new_ncolors)
        tempax = handles.ch1(i).Parent;
        col = colormap(tempax);
        startcols(i,:) = col;
    end
    if length(handles.ch1)< new_ncolors
        for i = (length(handles.ch1)+1):new_ncolors
            col = rand(1,3);
            startcols(i,:) = col;
        end
    end
    setappdata(handles.figure1,'startcols',startcols);
    depopulate_color_picker(handles);
    auto_populate_figure_discrete(numel(newnumbs),handles);
%     setappdata(handles.figure1,'ncolors',numel(newnumbs));
else
    discrete_colorstyle_callback(handles.discrete_col_style,[],handles);
end

cmapDB = getappdata(handles.figure1,'cmapDB');
cmapDB.mapped_numbers = newnumbs;
setappdata(handles.figure1,'cmapDB',cmapDB);
set(handles.mappedNumbs_editH,'string',num2str(newnumbs'));
answBtn = questdlg('change tick labels to match new mapped numbers?', ...
                     'change tick labels', ...
                     'Yes','No','Yes');
switch answBtn
 case 'Yes'
     numxticks = numel(cmapDB.xticklabels);
     if numxticks == 2
         cmapDB.xticklabels = {num2str(newnumbs(1));num2str(newnumbs(end))};
         set(handles.xticklabels_editH,'string',cmapDB.xticklabels);
     else if numxticks == numel(newnumbs)
             cmapDB.xticklabels = cellfun(@num2str,num2cell(newnumbs(:)),'UniformOutput',false);
             set(handles.xticklabels_editH,'string',cmapDB.xticklabels);
         else
             display('number of xticks does not match expected numel');
             cmapDB = getappdata(handles.figure1,'cmapDB');
             cmapDB.mapped_numbers = newnumbs;
             set(handles.mappedNumbs_editH,'string',num2str(newnumbs'));
             answBtn2 = questdlg('ALSO: change # of tick labels to match new mapped numbers?', ...
                                 'change # of tick labels', ...
                                 'Yes','No','Yes');
             switch answBtn2
                 case 'Yes'
                     cmapDB.xticklabels = cellfun(@num2str,num2cell(newnumbs(:)),'UniformOutput',false);
                     set(handles.xticklabels_editH,'string',cmapDB.xticklabels);
                 case 'No'
                     return
             end             
         end
     end
 case 'No'
     return
end
setappdata(handles.figure1,'cmapDB',cmapDB); 
    


function cbar_txt_callback(hObject,eventdata,handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
cmapDB.cbar_txt = get(hObject,'string');
setappdata(handles.figure1,'cmapDB',cmapDB);

function continuous_vals_callback(hObject,eventdata,handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
cmapDB.contin_val_expr = get(hObject,'string');
eval(['cmapDB.continuous_vals = ',cmapDB.contin_val_expr,';']);
setappdata(handles.figure1,'cmapDB',cmapDB);

function xticklabels_callback(hObject,eventdata,handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
cmapDB.xticklabels = get(hObject,'string');
setappdata(handles.figure1,'cmapDB',cmapDB);

function expr_input_callback(hObject,eventdata,handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
get_expr_input_dialog(cmapDB.expr_input,handles.figure1,handles)
setappdata(handles.figure1,'cmapDB',cmapDB);

function outloop_expr_input_callback(hObject,eventdata,handles)
cmapDB = getappdata(handles.figure1,'cmapDB');
get_outloop_expr_input_dialog(cmapDB.outside_loop_expr,handles.figure1,handles)
setappdata(handles.figure1,'cmapDB',cmapDB);

function output_new_cmap_callback(hObject,eventdata,handles)
% callingfig = getappdata(handles.figure1,'callingfig');
cmapDB_figH = getappdata(handles.figure1,'cmapDB_figH');
if ishandle(cmapDB_figH)
    zlab_cmaps_full = getappdata(cmapDB_figH,'zlab_cmaps');
else
    display('missing cmapDB_figH');
    return
end
cmap_single = getappdata(handles.figure1,'cmapDB');

original_cmapDB = getappdata(handles.figure1,'original_cmapDB');
if (original_cmapDB.discrete_bool ~= getappdata(handles.figure1,'discrete_bool'))
    switch getappdata(handles.figure1,'discrete_bool')
        case true
            distxt = 'false';
        case false
            distxt = 'true';
    end
    err_txt = sprintf(['cannot change ''discrete_bool'' when editing existing cmap',...
        '\n ... setting ''discrete_bool'' to ',distxt]);
    errH = errordlg(err_txt);
    set(handles.discrete_col_style,'value',~getappdata(handles.figure1,'discrete_bool'));
    discrete_colorstyle_callback(handles.discrete_col_style,[],handles);
    figure(errH);
    return
end

cmap_single.colorInput = getappdata(handles.figure1,'startcols');
cmap_single.name = handles.name_editH.String;
cmap_single.ncolors = getappdata(handles.figure1,'ncolors');
cmap_single.discrete_bool = getappdata(handles.figure1,'discrete_bool');
cmap_single.mapped_numbers = getappdata(handles.figure1,'mapped_numbers');
cmap_single.callingfig = [];
cmap_single.handles = [];
cmap_single.cbar_txt = handles.cbar_txt_editH.String;
cmap_single.xticklabels = handles.xticklabels_editH.String;
cmap_single.expr_input = handles.expr_input_staticH.String;
cmap_single.outside_loop_expr = handles.outloop_expr_input_staticH.String;
cmap_single.alpha = getappdata(handles.figure1,'alpha');

% ind = getappdata(callingfig,'current_cmap_ind');
ind = getappdata(cmapDB_figH,'current_cmap_ind');

if getappdata(handles.figure1,'discrete_bool')
    startcols = getappdata(handles.figure1,'startcols');
    colormap(cmap_single.imageH.Parent,startcols);
    axes(cmap_single.imageH.Parent);
    mapped_numbers = getappdata(handles.figure1,'mapped_numbers');
    cmap_single.imageH = image(1:numel(mapped_numbers),...
        'Parent',cmap_single.imageH.Parent);
    cmap_single.imageH.Parent.YTick = [];
    set(cmap_single.imageH,'ButtonDownFcn',cmap_single.callback);
else
    colormap(cmap_single.imageH.Parent,colormap(handles.ax3));
    cmap_single.contin_val_expr = handles.continuous_vals_editH.String;
    eval(['cmap_single.continuous_vals = ',handles.continuous_vals_editH.String,';']);
    cmap_single.contin_cmap = colormap(handles.ax3);
    axes(cmap_single.imageH.Parent);
    cmap_single.imageH = image(1:numel(cmap_single.continuous_vals),...
        'Parent',cmap_single.imageH.Parent);
	if ~isempty(cmap_single.xticklabels)
        cmap_single.imageH.Parent.XTick = [1,size(cmap_single.contin_cmap,1)];
        cmap_single.imageH.Parent.XTickLabel = cmap_single.xticklabels;
        cmap_single.imageH.Parent.YTick = [];
        set(cmap_single.imageH.Parent,'TickLength',[0,0]);
    else
        axis off
    end
    set(cmap_single.imageH,'ButtonDownFcn',cmap_single.callback);
end

title(cmap_single.imageH.Parent,cmap_single.cbar_txt);
if ~isempty(cmap_single.xticklabels)
    cmap_single.imageH.Parent.XTickLabel = cmap_single.xticklabels;
end

cmapDB_figH = getappdata(handles.figure1,'cmapDB_figH');

zlab_cmaps_full(ind) = cmap_single;
setappdata(cmapDB_figH,'cmapDB',cmap_single);
setappdata(cmapDB_figH,'zlab_cmaps',zlab_cmaps_full);

