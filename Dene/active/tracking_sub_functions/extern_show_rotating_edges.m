function seq = extern_show_rotating_edges(handles,seq)
if isempty(dir('edges_info_cell_background.mat'))
    cmd_w_str = 'no ''edges_info_cell_background'' file found... (attempting alternative)';
    cprintf('*[1,0.5,0]',[cmd_w_str,'\n']);
    ST = dbstack;
    display(ST(1));
    
    if isempty(dir('rotating_edge_info.mat'))
        rotating_edge_analysis_v03();
    end
    
    
    if isempty(dir('rotating_edge_info.mat'))
        display('could not find or create rotating_edge_info');
        return
    else
        load rotating_edge_info
        load analysis data
        edges = find(any(data.edges.selected));
    end
    
else
    load edges_info_cell_background edges
    load analysis data
end



% len = smoothen(data.edges.len(:, edges));
% len(~data.edges.selected(:, edges)) = nan; 
ang = (data.edges.angles(:, edges));
ang(ang > 90) = 180 - ang(ang > 90);
ang = smoothen(ang);


start_ap = 70;
start_dv = 45;
end_ap = 70;
end_dv = 45;

ang_params.start_ap = start_ap;
ang_params.start_dv = start_dv;
ang_params.end_ap = end_ap;
ang_params.end_dv = end_dv;

[dv_to_ap, dv_to_ap_times, ap_to_dv, ap_to_dv_times] =  rotating_edges(ang,ang_params);
ROImin = 5;
dv_to_ap = dv_to_ap(sum(data.edges.selected(:,edges(dv_to_ap)))>ROImin);
for i = 1:length(seq.frames)
%     tmp_edges = dv_to_ap(data.edges.selected(i,dv_to_ap));
    seq.frames(i).edges = seq.edges_map(i,edges(dv_to_ap));
end
update_frame(handles);
edges_color01 = [1 0.5 0];
prompt={'Enter RGB:'};
name='DV->AP Edge Color';
numlines=1;
defaultanswer={num2str(edges_color01)};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    display('user cancelled');
    return
else
    edges_color01 = str2num(answer{1});
end
setappdata(handles.figure1,'edges_color01',edges_color01);
update_frame(handles);