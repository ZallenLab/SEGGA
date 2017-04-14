function seq = extern_topology_annotations(handles,seq,orbit)
data = seq2data(seq);

    max_sides = 1;
    min_sides = 11;
    
for i= orbit
	seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    numsides = data.cells.num_sides(i,data.cells.selected(i,:));
    max_sides = max(max_sides,max(numsides));
    min_sides = min(min_sides,min(numsides));
end

% tailored colormap for a list of 8 different topologies
manyhsv = hsv(20);
evenshsv = manyhsv(2:2:end,:);
evenshsv = evenshsv([1,2,4,6:end],:);
evenshsv = evenshsv([end,1:end-1],:);

custom_color_list = hsv((max_sides-min_sides+1));

num_colors = (max_sides-min_sides+1);
if num_colors == 8
    % tailored colormap for a list of 8 different topologies
    manyhsv = hsv(20);
    evenshsv = manyhsv(2:2:end,:);
    evenshsv = evenshsv([1,2,4,6:end],:);
    evenshsv = evenshsv([end,1:end-1],:);
    evenshsv = evenshsv([1:2,4:end,3],:);
    
    evenshsv(1,:) = [1 0 0];
    evenshsv(2,:) = [1 0.4 0];
    custom_color_list = evenshsv;
end

display(['colorrange = ',num2str((max_sides-min_sides+1))]);
display(['min sides = ',num2str(min_sides),' max sides = ',num2str(max_sides)]);

% Construct a questdlg with three options
choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
% Handle response
switch choice
    case 'Default'
        display('continuing');
    case 'CustomOld'
        display('custom');
        
        ncolors = max_sides-min_sides+1;
        callingfig = handles.figure1;
        mapped_numbers = min_sides:max_sides;
        colorInput = [];
%         load(zallencolormaps,'topology');
        cbar_txt = 'topology';
        continuous_vals = [];
        expr_input = 'cell_cdata = data.cells.num_sides(i,data.cells.selected(i,:));';
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input);
        uiwait(cpickerH);
%         output_colormap = getappdata(handles.figure1,'output_colormap');
%         custom_color_list = output_colormap.colors;
        return
    case 'Custom'
        startdir = pwd;
        P = mfilename('fullpath');
        reversestr = fliplr(P);
        [~, justdirpath] = strtok(reversestr,filesep);
        base_dir = fliplr(justdirpath);
        cmapfilefold = [base_dir,'..',filesep,'general',filesep];
        cmapfilename = 'SEGGA_default_cmaps.mat';
        cd(cmapfilefold);
        [filename, pathname] = uigetfile('*,mat','Choose a Colormap Database',cmapfilename);
        fullcmapname = fullfile(pathname,filename);
        cd(startdir);
        if isempty(filename)
            display('user cancelled');
            return
        end
        cmap_figH = visualize_multiple_colmaps(fullcmapname,handles);
%         midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [];
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
        
        return
    case 'Cancel'
        display('user cancelled');
        return        
end

%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'Topology';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
custom_color_list = cmap_out.colorInput;
%%% cmap_out.contin_cmap %% continuous

for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    withzeros = seq.cells_map(i,data.cells.selected(i,:));
    numsides = data.cells.num_sides(i,data.cells.selected(i,:));
%     seq.frames(i).cells_colors(seq.frames(i).cells,:)  = custom_color_list(numsides(takers)-min_sides+1,:);
    seq.frames(i).cells_colors(seq.frames(i).cells,:)  = ...
        custom_color_list(max(min(numsides(takers)-min_sides,size(custom_color_list,1)),1),:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .5;
end

update_frame(handles)

return


%%% ECCENTRICITY

data = seq2data(seq);
outside_loop_expr = [...
'for i = 1:length(seq.frames)',...
    'geom = seq.frames(i).cellgeom;',...
    'l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));',...
	'faces = geom.faces(l_cells, :);',...
    'faces_for_area = faces2ffa(faces);',...
    '[cell_L1, cell_L2, cell_angle, ~] = cell_ellipse(geom.nodes, faces_for_area);',...           
    'ecc = realsqrt(1 - (cell_L2 ./ cell_L1).^2);',...
    'perframe(i).ecc = ecc;',...
'end;',...
'ecc_all = [];',...
'for i = 1:length(seq.frames) ',...
    'ecc_all = [ecc_all;perframe(i).ecc];',...
'end;',...
'minnum = mean(ecc_all(:))-2*std(ecc_all(:));',...
'maxnum = mean(ecc_all(:))+2*std(ecc_all(:));',...
'intrval = (maxnum-minnum)/100;'...
];
eval(outside_loop_expr);

continuous_vals = [minnum:intrval:maxnum];
setappdata(handles.figure1,'curr_cmap_extrema',[minnum,maxnum]);
expr_input = ['cell_cdata = min(max(round((perframe(i).ecc-',...
               num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];

choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');

switch choice
    case 'Default'
        display('automapping eccentricity to red and blue colormap');
    case 'CustomOld'
        ncolors = 3;
        callingfig = handles.figure1;
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [1 0 0; 0.75 0 0.75; 0 0 1];
        cbar_txt = 'Eccentricity';
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input,outside_loop_expr);
        uiwait(cpickerH);
        return
    case 'Custom'
        startdir = pwd;
        P = mfilename('fullpath');
        reversestr = fliplr(P);
        [~, justdirpath] = strtok(reversestr,filesep);
        base_dir = fliplr(justdirpath);
        cmapfilefold = [base_dir,'..',filesep,'general',filesep];
        cmapfilename = 'SEGGA_default_cmaps.mat';
        cd(cmapfilefold);
        [filename, pathname] = uigetfile('*,mat','Choose a Colormap Database',cmapfilename);
        fullcmapname = fullfile(pathname,filename);
        cd(startdir);
        if isempty(filename)
            display('user cancelled');
            return
        end
        cmap_figH = visualize_multiple_colmaps(fullcmapname,handles);
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
        rmappdata(handles.figure1,'curr_cmap_extrema');
        return
    case 'Cancel'
        display('user cancelled');
        return        
end


for i= orbit
%     takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    seq.frames(i).cells  = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(1-((perframe(i).ecc-minnum)./(maxnum-minnum)),1),0);
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(((perframe(i).ecc-minnum)./(maxnum-minnum)),1),0);    
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
end

update_frame(handles)