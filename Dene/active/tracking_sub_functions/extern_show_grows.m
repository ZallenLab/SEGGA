function seq = extern_show_grows(handles,seq)


load analysis clusters_backwards;


cluster_grow_global_inds = [];
cluster_grow_global_inds = [cluster_grow_global_inds,clusters_backwards(:).edges];
cluster_grow_global_inds = unique(cluster_grow_global_inds, 'legacy');



for i = 1:length(seq.frames)
    %%%using 'edges' for growing edges
    seq.frames(i).edges = seq.edges_map(i,cluster_grow_global_inds);
end
update_frame(handles);
edges_color01 = [0 0 1];


prompt={'Enter RGB:'};
name='Growing Edge Color';
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

return
%%% FOR SHOWING BOTH TECHNIQUES

load shrinking_edges_info_new
load analysis clusters_backwards;
cluster_grow_global_inds = [];
cluster_grow_global_inds = [cluster_grow_global_inds,clusters_backwards(:).edges];
cluster_grow_global_inds = unique(cluster_grow_global_inds, 'legacy');

for i = 1:length(seq.frames)
    %%%using 'edges' for growing edges
    seq.frames(i).edges = seq.edges_map(i,edges_global_ind_growing);
    seq.frames(i).edges2 = seq.edges_map(i,cluster_grow_global_inds);
end
update_frame(handles);
edges_color01 = [0 0 1];
edges_color02 = [1 0 0];

prompt={'Enter RGB:'};
name='Growing Edge Color (from Grows)';
numlines=1;
defaultanswer={num2str(edges_color01)};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    display('user cancelled');
    return
else
    edges_color01 = str2num(answer{1});
end

prompt={'Enter RGB:'};
name='Growing Edge Color (from Clusters)';
numlines=1;
defaultanswer={num2str(edges_color02)};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    display('user cancelled');
    return
else
    edges_color02 = str2num(answer{1});
end

setappdata(handles.figure1,'edges_color01',edges_color01);
setappdata(handles.figure1,'edges_color02',edges_color02);
setappdata(handles.figure1,'edges_alpha01',0.5);
setappdata(handles.figure1,'edges_alpha02',0.2);

update_frame(handles);