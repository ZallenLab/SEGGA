function out=radiodlg(strs,title,def_out,solitary_mode)
% RADIODLG RadioButton dialog box.
% Answer = radiodlg(Strs) creates a modal dialog box that returns
% user yes/no choices for the strings Strs in the vector Answer.
% Strs is a cell array or a char array. Each cell or row will 
% result in a radio button, and the 1/0 values will be returned in
% Answer
% 
% Answer = radiodlg(Strs,Title) specifies the Title for the dialog.
% 
% Answer = inputdlg(Strs,Title,def_out) specifies the default
% answer to display for each Str. def_out must contain the same
% number of elements as Strs and must be a double or int vector.
%
% solitary_mode -> only allow one selection at a time
% Answer = inputdlg(Strs,Title,def_out,true) 
% Answer contains only one nonzero value
% 
% Example:
% strs=char('Use me','Use me too','Do not use me','If you dare','Go away');
% def=[1 1 0 0 0];
% title='Which ones to use?';
% answer=radiodlg(strs,title,def);
% 
% See also INPUTDLG,HELPDLG.

% Adapted from Matti Picus matti@tx.technion.ac.il, licensed for general use
% under the GPL license. 
% 

out = zeros(size(strs,1),1);

if nargin < 4 || isempty(solitary_mode)
    solitary_mode = false;
end

% Error checking
if nargin<1
    strs=3;
end

if ischar(strs)
   strs=cellstr(strs);
end

if ~ iscellstr(strs)
   error('The first argument must be a cell array of chars or a char array');
end

if nargin<2
    title='';
end

if iscell(title)
    title=title{1};
end

if ~ischar(title)
    warning('Title must be a char array, ignoring'); title='';
end;


n=prod(size(strs));
if nargin<3
    def_out=ones(n,1);
end

if iscell(def_out)
    def_out=[def_out{:}];
end

if n>prod(size(def_out))
    error('def_out has too few values');
end

fig_props = { ...
    'resize' 'off' ...
    'units' 'pixels' ...
    'numbertitle' 'off' ...
    'name' title ...
    'createfcn' '' ...
    'closerequestfcn' 'set(gcf,''userdata'',''cancel'')' ...
    'visible' 'on' ...
};

fig = figure(fig_props{:});
handles = guihandles(fig); 
handles.figure1 = fig;
guidata(fig,handles);

% Find the size of a text object with all the strings inside
q=uicontrol('Units','Pixels','Style','Text','String',...
         {strs{:},'Cancel'},'Visible','on');
e=get(q,'extent'); delete(q);
% P is the possible area, e is the uicontrol extent. Calculate the number
% of columns and row to make the whole thing a square. If each uicontrol
% is h by w, and I tile with y by x of them, I know that y*x>n, y*h<w*x,
h=e(4)/(1+n)+5; w=e(3)+17; x=ceil(sqrt(h/w*n)); y=ceil(n/x);
x0=5; % Change these to leave more of a margin...
y0=2*h+5;
hndl=zeros(n,1);
for i=1:n,
   hndl(i)=uicontrol('Style','Radio','string',strs(i,:),...
            'Position',[x0+floor((i-1)/y)*w y0+mod(-i,y)*h w-2 h-2],...
            'Value',def_out(i));
   if solitary_mode
       set(hndl(i),'Callback',@solitary_callback);
   end
end

function solitary_callback(handles,event,button_handle)
    set(hndl,'Value',0);
    set(event.Source,'Value',1);
end
    

ok=uicontrol('Style','Push','String','OK','Call',...
      'set(gcbo,''String'',''DONE'');','Pos',...
      [x0+x*w/2-w, y0-h,w,h]);
  
cancl=uicontrol('Style','Push','String','Cancel','Pos',...
      [x0+x*w/2, y0-h,w,h],'User',ok,'Call',...
      'set(get(gcbo,''User''),''String'',''QUIT'');');
  
% Resize the figure to include the uicontrols.
fp=get(fig,'position');
fp=[fp(1)+fp(3)/2-x*w/2-10 fp(2)+fp(4)/2-y*h/2-10 max(x,2)*w+20 (y+1)*h+20];
set(fig,'Visible','on','Position',fp,'windowstyle' ,'modal');
waitfor(ok,'String');

if strcmp('DONE',get(ok,'String')),
   q=get(hndl,'Value');
   out=[q{:}]';
else
   out=[];
end;

delete(fig);

end