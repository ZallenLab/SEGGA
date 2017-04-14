function seq = extern_len_width_ratio_annotations(handles,seq,orbit,smooth_bool)
%%%for use inside 'tracking.m'
if nargin < 4 || isempty(smooth_bool)
    smooth_bool = true;
end
data = seq2data(seq);
% same expression as that used in the cmap builder
% (generate_SEGGA_default_cmaps)

% because the group of cells used starts from the global list, i.e. the
% local indicies are derived from the global indicies, and the size and 
% order are maintained, we
% can move back and forth between global and local without worrying about
% ordering as long as the group of cells remains the same size, the same
% group

outside_loop_expr = [...
'big_len_width = NaN(size(data.cells.selected));',...
'for i = 1:length(seq.frames)',...
    'geom = seq.frames(i).cellgeom;',...
    'l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));',...
	'faces = geom.faces(l_cells, :);',...
    'faces_for_area = faces2ffa(faces);',...
    '[cell_L1, cell_L2, cell_angle, ~] = cell_ellipse(geom.nodes, faces_for_area);',...           
    'hor = sqrt((cell_L1 .* cosd(cell_angle)).^2 + (cell_L2 .* sind(cell_angle)).^2);',...
    'ver = sqrt((cell_L1 .* sind(cell_angle)).^2 + (cell_L2 .* cosd(cell_angle)).^2);',...
    'hor_ver_ratio = log2(hor./ver);',...
    'perframe(i).hor_ver_ratio = hor_ver_ratio;',...
    'globs = seq.inv_cells_map(i, l_cells);',...
    'big_len_width(i,globs) = hor_ver_ratio;',...
'end;',...
'big_len_width = smoothen(big_len_width);'];

eval(outside_loop_expr);
if smooth_bool
    hor_ver_ratio_all = big_len_width(data.cells.selected);
else
    hor_ver_ratio_all = [];
    for i = 1:length(seq.frames)
        hor_ver_ratio_all = [hor_ver_ratio_all;perframe(i).hor_ver_ratio];
    end
end
minnum = mean(hor_ver_ratio_all(:))-2*std(hor_ver_ratio_all(:));
maxnum = mean(hor_ver_ratio_all(:))+2*std(hor_ver_ratio_all(:));
intrval = (maxnum-minnum)/100;
continuous_vals = [minnum:intrval:maxnum];
if smooth_bool
    expr_input = ['print(''smoothing L/W data'');',...
                   'tmp_hv = big_len_width(i,data.cells.selected(i,:));',...
                   'cell_cdata = min(max(round((tmp_hv-',...
                       num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];    
else
    expr_input = ['cell_cdata = min(max(round((perframe(i).hor_ver_ratio-',...
                   num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];
end
choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');

switch choice
    case 'Default'

    case 'CustomOld'
        ncolors = 3;
        callingfig = handles.figure1;
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [1 0 0; 0.75 0 0.75; 0 0 1];
        cbar_txt = 'Length Width Ratio';
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
        cmapfilefold = [base_dir,'..',filesep,'..',...
            filesep,'active',filesep,'general',filesep];
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
        mapped_numbers = [minnum,midnum,maxnum]-midnum;
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
        return
    case 'Cancel'
        display('user cancelled');
        return        
end


% cmapfilefold = [base_dir,'..',filesep,'..',...
%             filesep,'active',filesep,'general',filesep];
% cmapfilename = 'SEGGA_default_cmaps.mat';

%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'LW_ratio';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
% cmap_out.contin_cmap;


for i= orbit
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    seq.frames(i).cells  = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
    big_len_width_smooth = squeeze(big_len_width(i,seq.inv_cells_map(i, nonzeros(seq.cells_map(i, data.cells.selected(i, :))))));
%     seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(1-((perframe(i).hor_ver_ratio-minnum)./(maxnum-minnum)),1),0);
%     seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
%     seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(((perframe(i).hor_ver_ratio-minnum)./(maxnum-minnum)),1),0); 
    
    cell_cdata =  min(max(round((perframe(i).hor_ver_ratio-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
    seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
    
    if smooth_bool
%         seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(1-((big_len_width_smooth(takers)-minnum)./(maxnum-minnum)),1),0);
%         seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
%         seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(((big_len_width_smooth(takers)-minnum)./(maxnum-minnum)),1),0);
        tmpvals = big_len_width_smooth(takers);
        cell_cdata =  min(max(round((tmpvals-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
        seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
        seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
    end
    
end

update_frame(handles);