function h = geom_edge_colorpicker(ncolors,callingfig,callingfig_handles,...
                            mapped_numbers,colorInput)
h = figure;
pos = [680,367,824,700];
set(h,'position',pos);
handles = guihandles(h); 
handles.figure1 = h;

if nargin <1 
    ncolors = 1;
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
setappdata(handles.figure1,'thickness',1);

        

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


setappdata(handles.figure1,'alpha',0.5);
setappdata(handles.figure1,'style','linear');
guidata(h,handles);
[ax1,rows,columns,midX,midY] = create_color_wheel(handles);
ax1.XLimMode = 'manual';
ax1.YLimMode = 'manual';

handles = auto_populate_figure_discrete(ncolors,handles,ax1,rows,columns,midX,midY);
handles = create_controls(handles);

guidata(h,handles);


%%% create control buttons
function handles = create_controls(handles)

h = handles.figure1;
pos = [0.795,0.945,0.2,0.03];
tempcb = @(hObject,eventdata) invert_background_image_callback(hObject,eventdata,guidata(hObject));
handles.invert_background_imageH = uicontrol('Parent',h,'Style', 'checkbox',...
        'string','invert background image',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback',tempcb);


    
pos = [0.8,0.80,0.1,0.025];
tempcb = @(hObject,eventdata) output_colormap_callback(hObject,eventdata,guidata(hObject));
handles.output_cmapH = uicontrol('Parent',h,'Style', 'pushbutton',...
        'string','output',...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    

pos = [0.8,0.725,0.05,0.03];
handles.thickness_staticH = uicontrol('Parent',h,'Style', 'text',...
        'string','thickness:',...
        'Unit', 'normalized',...
        'Position', pos);
pos = [0.85,0.73,0.05,0.03];
tempcb = @(hObject,eventdata) set_thickness_callback(hObject,eventdata,guidata(hObject));
thickness = getappdata(handles.figure1,'thickness');
handles.thickness_editH = uicontrol('Parent',h,'Style', 'edit',...
        'string',thickness,...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    
pos = [0.79,0.71,0.125,0.01];
tempcb = @(hObject,eventdata) thickness_sliderH_callback(hObject,eventdata,guidata(hObject));
handles.thickness_sliderH = uicontrol('Parent',h,'Style', 'slider',...
        'value',getappdata(handles.figure1,'thickness'),...
        'min',0,'max',10,'sliderstep',[0.1,1],...
        'Unit', 'normalized',...
        'Position', pos,...
        'Callback', tempcb);
    


tempcb = @(hObject,eventdata) thickness_sliderH_callback(hObject,eventdata,guidata(hObject));
try    % R2013b and older
   addlistener(handles.thickness_sliderH,'ActionEvent',tempcb );
catch  % R2014a and newer    
   addlistener(handles.thickness_sliderH,'ContinuousValueChange',tempcb);
end  

function invert_background_image_callback(hObject,eventdata,handles)
invertBool = get(hObject,'value');
% display(invertBool);


function thickness_sliderH_callback(hObject,eventdata,handles)
thickness = get(hObject,'value');
thickness = max(min(thickness,10),0);
set(handles.thickness_editH,'string',num2str(thickness));
setappdata(handles.figure1,'thickness',thickness);
update_thickness_value(handles,thickness);
    
function set_thickness_callback(hObject,eventdata,handles)
thickness = str2double(get(hObject,'string'));
thickness = max(min(thickness,10),0);
set(hObject,'string',num2str(thickness));
set(handles.thickness_sliderH,'value',thickness);
setappdata(handles.figure1,'thickness',thickness);
update_thickness_value(handles,thickness);
    


function geom_edge_settings = output_colormap_callback(hObject,eventdata,handles)

% geom_edge_settings.alpha = getappdata(handles.figure1,'alpha');
geom_edge_settings.thickness = getappdata(handles.figure1,'thickness');
geom_edge_settings.invertBool = get(handles.invert_background_imageH,'value');

tempax = handles.ch1(1).Parent;
col = colormap(tempax);
geom_edge_settings.color = col;

display(geom_edge_settings);
setappdata(handles.figure1,'geom_edge_settings',geom_edge_settings);
callingfig = getappdata(handles.figure1,'callingfig');
if isempty(callingfig)
    display('no calling fig')
    return
end
setappdata(callingfig,'geom_edge_settings',geom_edge_settings);
callingfig_handles = getappdata(handles.figure1,'callingfig_handles');
tracking('update_geom_edge_settings_Callback',callingfig_handles);





    
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
%         pos = [(i-1)*x_incr+offset*x_incr,0.025,x_incr*(1-x_incr),0.1];
        pos = [0.35,0.025,0.2,0.1];
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
end
% handles = update_thickness_value(handles);    
guidata(handles.figure1,handles);
for i = 1:ncolors
    add_listeners_to_sliders(sldH(i,:));
end
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

function handles = update_thickness_value(handles,thickness)
if nargin < 2
    thickness = getappdata(handles.figure1,'thickness');
end
set(handles.thickness_editH,'string',thickness);
set(handles.thickness_sliderH,'value',thickness);
guidata(handles.figure1,handles);

function second_sweep(handles)
allH1 =findobj(handles.figure1,'type','axes');
for i = 1:length(allH1)
    test = strcmp(allH1(i).Tag,'continuous_cbar');
    if test
        delete(allH1(i));
    end
end





