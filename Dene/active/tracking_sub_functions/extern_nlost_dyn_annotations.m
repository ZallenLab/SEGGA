function seq = extern_nlost_dyn_annotations(handles,seq,orbit)


% orbit = get_orbit_frames(handles);

% global seq
data = seq2data(seq);
if isempty('topological_events_per_cell.mat')
    display('missing topological_events_per_cell file');
    return
end
try
    load topological_events_per_cell cells_lost_hist cells_to_anal
catch
    display('could not load nlost data from topological_events_per_cell file');
    return
end

    cells = cells_to_anal;

    min_lost = 0;
    max_lost = 4;
    
for i= orbit
	seq.frames(i).cells  = nonzeros(seq.cells_map(i,cells));
    takers = seq.cells_map(i,cells)~=0;
    numlost = cells_lost_hist(i,takers(:));

end

num_colors = (max_lost-min_lost+1);



if num_colors == 5
manyhsv = hsv(20*4);
convnums = [1,16,29,49,61];
% evenshsv = manyhsv(2:2:end,:);
evenshsv = manyhsv(convnums,:);
% evenshsv = evenshsv([end,1:end-1],:);
custom_color_list = evenshsv;
end
% 
% custom_color_list = hsv((max_lost-min_lost+1));


if num_colors == 8
    % tailored colormap for a list of 8 different topologies
    manyhsv = cool(20);
    evenshsv = manyhsv(2:2:end,:);
    evenshsv = evenshsv([1,2,4,6:end],:);
    evenshsv = evenshsv([end,1:end-1],:);
    evenshsv = evenshsv([1:2,4:end,3],:);
    
    evenshsv(1,:) = [1 0 0];
    evenshsv(2,:) = [1 0.4 0];
    custom_color_list = evenshsv;
end

custom_color_list = custom_color_list(end:-1:1,:);

display(['colorrange = ',num2str((max_lost-min_lost+1))]);
display(['min lost = ',num2str(min_lost),' max lost = ',num2str(max_lost)]);

for i= orbit
    tmp_sel_cells = logical(cells.*data.cells.selected(i,:));
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,tmp_sel_cells));
    takers = logical((seq.cells_map(i,cells)~=0).*data.cells.selected(i,cells));
    numlost = cells_lost_hist(i,takers(:));
    seq.frames(i).cells_colors(seq.frames(i).cells,:)  = custom_color_list(min(numlost,max_lost)+1,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .5;    
end

update_frame(handles);