function seq = extern_show_shrinks(handles,seq)

choice = questdlg('differentiate between rosettes and t1s?', ...
	'options:', ...
	'Yes','No','Cancel','Cancel');

switch choice
    case 'Yes'
        load('where_shrinks_go','shrink_global_inds','shrink_to_ros');
        rosInds = shrink_global_inds(logical(shrink_to_ros));
        t1Inds = shrink_global_inds(~logical(shrink_to_ros));
        for i = 1:length(seq.frames)
            %%%using 'edges2' for t1s
            seq.frames(i).edges2 = seq.edges_map(i,t1Inds);
            seq.frames(i).edges3 = seq.edges_map(i,rosInds);
        end
        edges_color02 = [1 0 0.8];
        edges_color03 = [1 0.5 0];
%         setappdata(handles.figure1,'edges_color02',edges_color02);
%         setappdata(handles.figure1,'edges_color03',edges_color03);
        
        prompt={'Enter RGB:'};
        name='Shrinking Edge (T1) Color';
        numlines=1;
        defaultanswer={num2str(edges_color02)};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            display('user cancelled');
        else
            edges_color02 = str2num(answer{1});
        end
        setappdata(handles.figure1,'edges_color02',edges_color02);
        
        
        prompt={'Enter RGB:'};
        name='Shrinking Edge (Rosettes) Color';
        numlines=1;
        defaultanswer={num2str(edges_color03)};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            display('user cancelled');
            return
        else
            edges_color03 = str2num(answer{1});
        end
        setappdata(handles.figure1,'edges_color03',edges_color03);
        
    case 'No'
        load shrinking_edges_info_new
        for i = 1:length(seq.frames)
            %%%using 'edges2' for shrinks
            seq.frames(i).edges2 = seq.edges_map(i,edges_global_ind);
        end
        edges_color02 = [1 0 0.8];
        prompt={'Enter RGB:'};
        name='Shrinking Edge Color';
        numlines=1;
        defaultanswer={num2str(edges_color02)};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            display('user cancelled');
            return
        else
            edges_color02 = str2num(answer{1});
        end
        setappdata(handles.figure1,'edges_color02',edges_color02);
    case 'Cancel'
        return
end
update_frame(handles);