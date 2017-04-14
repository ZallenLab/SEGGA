function varargout = view_autocorrection_stats(varargin)
% VIEW_AUTOCORRECTION_STATS M-file for view_autocorrection_stats.fig
%      VIEW_AUTOCORRECTION_STATS, by itself, creates a new VIEW_AUTOCORRECTION_STATS or raises the existing
%      singleton*.
%
%      H = VIEW_AUTOCORRECTION_STATS returns the handle to a new VIEW_AUTOCORRECTION_STATS or the handle to
%      the existing singleton*.
%
%      VIEW_AUTOCORRECTION_STATS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_AUTOCORRECTION_STATS.M with the given input arguments.
%
%      VIEW_AUTOCORRECTION_STATS('Property','Value',...) creates a new VIEW_AUTOCORRECTION_STATS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_autocorrection_stats_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_autocorrection_stats_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_autocorrection_stats

% Last Modified by GUIDE v2.5 14-Apr-2010 19:29:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_autocorrection_stats_OpeningFcn, ...
                   'gui_OutputFcn',  @view_autocorrection_stats_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before view_autocorrection_stats is made visible.
function view_autocorrection_stats_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_autocorrection_stats (see VARARGIN)


% Choose default command line output for view_autocorrection_stats
handles.output = hObject;

    global seq
    old_seq = seq;
    old_seq = get_mistake_cells(seq);
    rectify_seq(seq);
    seq = load_dir(pwd);
    new_seq = get_mistake_cells(seq);
    
    
    handles.old_seq = old_seq;
    handles.new_seq = new_seq;
    
    
    old_cells = cells_for_chart(old_seq);
    new_cells = cells_for_chart(new_seq);


    bar(handles.axes1,old_cells);
%     text(max(xlim)/2,max(ylim)*9/10,['total new = ',num2str(sum(old_cells))]);
    left = max(find(old_cells,1,'first')-1,1);
    if isempty(left)
        left = 1;
    end
    right = max(find(old_cells,1,'last')+1,1);
    if isempty(right)
        right = length(old_cells);
    end
    set(handles.axes1,'xlim',[left,right]);
    bar(handles.axes2,[old_cells,new_cells],1.5);
    set(handles.axes2,'xlim',[find(new_cells,1,'first')-1,find(new_cells,1,'last')+1]);
    legend(handles.axes2,{'old','new'});
%     text(max(xlim)/2,max(ylim)*9/10,['total new = ',num2str(sum(new_cells))]);
    
    set(handles.dir_autocorrected,'string',pwd);
    set(handles.sum_old,'string',{'';['Sum Errors Old = ',num2str(sum(old_cells))]});
    set(handles.sum_new,'string',{'';['Sum Errors New = ',num2str(sum(new_cells))]});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view_autocorrection_stats wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_autocorrection_stats_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

if true
end
% --- Executes during object creation, after setting all properties.
function dir_autocorrected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dir_autocorrected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1




% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2




function cells = cells_for_chart(seq)


len = length(seq.frames);
cells = nan(len,1);
for i=1:len
    cells(i) = length(seq.frames(i).cells);
end


% --- Executes during object creation, after setting all properties.
function sum_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sum_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function sum_old_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sum_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
