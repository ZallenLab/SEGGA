function get_expr_input_dialog(start_expr,calling_fig,calling_fig_handles)
if nargin < 1
    start_expr = '';
end

d = dialog('Position',[300 300 500 500],'Name','Input Expression');
handles = guihandles(d);
handles.figure1 = d;
guidata(d,handles);
setappdata(handles.figure1,'calling_fig',calling_fig);
setappdata(handles.figure1,'calling_fig_handles',calling_fig_handles);

handles.txtH = uicontrol('Parent',d,...
       'Style','text',...
       'Position',[130 400 210 40],...
       'String','Input Expression');

handles.input_editH = uicontrol('Parent',d,...
       'Style','edit',...
       'Position',[50 100 400 250],...
       'String',start_expr);

tempcb = @(hObject,eventdata) input_expr_callback(guidata(hObject));   
handles.ok_btnH = uicontrol('Parent',d,...
       'Position',[150 20 70 25],...
       'String','OK',...
       'Callback',tempcb);

handles.cancel_btnH = uicontrol('Parent',d,...
       'Position',[250 20 70 25],...
       'String','Cancel',...
       'Callback','delete(gcf)');
guidata(d,handles);


% Wait for d to close before running to completion
uiwait(d);

   
function input_expr_callback(handles)
expr_input = handles.input_editH.String;
calling_fig = getappdata(handles.figure1,'calling_fig');
calling_fig_handles = getappdata(handles.figure1,'calling_fig_handles');
% setappdata(calling_fig,'new_expr_input',expr_input);
cmapDB = getappdata(calling_fig,'cmapDB');
cmapDB.expr_input = expr_input;
set(calling_fig_handles.expr_input_staticH,'string',expr_input);
setappdata(calling_fig,'cmapDB',cmapDB);
delete(handles.figure1);

 