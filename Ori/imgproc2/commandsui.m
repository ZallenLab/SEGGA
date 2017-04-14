function varargout = commandsui(varargin)
% COMMANDSUI Application M-file for commandsui.fig
%    FIG = COMMANDSUI launch commandsui GUI.
%    COMMANDSUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 04-Dec-2015 11:29:58

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
	
	% Setup a pointer to this interface
	declareglobs
	guihandle = handles;
% 	setuicolors
	global commandsuiH
	commandsuiH = handles.figure1;
	% check if dir is root
    if all(strcmp(filesep,pwd))
        display('changing to home dir from root dir');
        cd('~');
    end
    set(handles.dir_info_txt, 'string', pwd)

	% Fix font sizes
	for I = fieldnames(handles)'
	  if ~strcmp(I,'figure1')
	    %set(getfield(handles,char(I)),'FontSize',10);
	  end
	end
	
	if nargout > 0
		varargout{1} = fig;
    end
    %     for running automatically


elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    global commandsuiH activefig quickeditH
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
end




%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


function Untitled_23_Callback(hObject, eventdata, handles)
%%%'tools' dropdown

% --------------------------------------------------------------------
function quick_edit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to quick_edit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

c = get(hObject, 'checked');
if strcmp(lower(c), 'off')
    set(hObject, 'checked', 'on');
else
    set(hObject, 'checked', 'off');
end



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function track_menu_Callback(hObject, eventdata, handles)
% hObject    handle to track_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking_call(handles.figure1)


% --------------------------------------------------------------------
function close_case_menu_Callback(hObject, eventdata, handles)
% hObject    handle to close_case_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close_case(handles)

function close_case(handles)
declareglobs
cancelled = false;
promptsave
if cancelled == true
    return
end

if isappdata(commandsuiH, 'seq');
  if isappdata(commandsuiH, 'called_from_tracking') && getappdata(commandsuiH, 'called_from_tracking')
      setappdata(commandsuiH, 'called_from_tracking', false)
  else
      if isappdata(commandsuiH, 'seq')
          rmappdata(commandsuiH, 'seq');
      end
      if isappdata(commandsuiH, 'tracking_frame')
        rmappdata(commandsuiH, 'tracking_frame');
      end
  end
end
clearstring='';
for I=1:length(clearlist)
clearstring=[clearstring ' ' char(clearlist(I))];
end
clear I;
eval(['clear global' clearstring]);
declareglobs;  
setdefaults;
delete(activefig(ishandle(activefig)));
% setuicolors;



% --- Executes on button press in tracking_btn.
function tracking_btn_Callback(hObject, eventdata, handles)

%Tracking
% display(hObject);
% display(eventdata);
% display(handles);
% figure(handles.figure1);
tracking_call(handles.figure1);

% --- Executes on button press in dir_info_txt.
function dir_info_txt_Callback(hObject, eventdata, handles)
% hObject    handle to dir_info_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Change Dir Tracking

directory = uigetdir;
if ~directory
    return
end
close_case(handles);
cd(directory);
if isappdata(handles.figure1, 'seq')
    rmappdata(handles.figure1, 'seq')
end
set(handles.dir_info_txt, 'string', pwd);
tracking_call(handles.figure1);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tracking_btn.
function tracking_btn_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tracking_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function varargout = figure1_CreateFcn(h, eventdata, handles, varargin)
% Stub for CreateFcn of the figure handles.figure1.
%disp('figure1 CreateFcn not implemented yet.')
