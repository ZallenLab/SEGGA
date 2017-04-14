function seq = extern_eccentricity_annotations(handles,seq,orbit,smooth_bool)
%%%for use inside 'tracking.m'
if nargin <4 || isempty(smooth_bool)
    smooth_bool = true;
end
data = seq2data(seq);


outside_loop_expr = [...
'big_ecc = NaN(size(data.cells.selected));',...
'for i = 1:length(seq.frames)',...
    'geom = seq.frames(i).cellgeom;',...
    'l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));',...
	'faces = geom.faces(l_cells, :);',...
    'faces_for_area = faces2ffa(faces);',...
    '[cell_L1, cell_L2, cell_angle, ~] = cell_ellipse(geom.nodes, faces_for_area);',...           
    'ecc = realsqrt(1 - (cell_L2 ./ cell_L1).^2);',...
    'perframe(i).ecc = ecc;',...
    'globs = seq.inv_cells_map(i, l_cells);',...
    'big_ecc(i,globs) = ecc;',...
'end;',...
'ecc_all = [];',...
'for i = 1:length(seq.frames) ',...
    'ecc_all = [ecc_all;perframe(i).ecc];',...
'end;',...
'minnum = 0;',...
'maxnum = mean(ecc_all(:))+2*std(ecc_all(:));',...
'intrval = (maxnum-minnum)/100;'...
'big_ecc = smoothen(big_ecc);'];


eval(outside_loop_expr);
if smooth_bool
    ecc_all = big_ecc(data.cells.selected);
else
    ecc_all = [];
    for i = 1:length(seq.frames)
        ecc_all = [ecc_all;perframe(i).ecc];
    end
end
minnum = mean(ecc_all(:))-2*std(ecc_all(:));
maxnum = mean(ecc_all(:))+2*std(ecc_all(:));
intrval = (maxnum-minnum)/100;
continuous_vals = [minnum:intrval:maxnum];
if smooth_bool
    expr_input = ['print(''smoothing ecc data'');',...
                   'tmp_ecc = big_ecc(i,data.cells.selected(i,:));',...
                   'cell_cdata = min(max(round((tmp_ecc-',...
                       num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];    
else
    expr_input = ['cell_cdata = min(max(round((perframe(i).ecc-',...
               num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];
end



setappdata(handles.figure1,'curr_cmap_extrema',[minnum,maxnum]);


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
        return
    case 'Cancel'
        display('user cancelled');
        return        
end

%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'Eccentricity';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
% cmap_out.contin_cmap;


for i= orbit
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    seq.frames(i).cells  = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
    big_ecc_smooth = squeeze(big_ecc(i,seq.inv_cells_map(i, nonzeros(seq.cells_map(i, data.cells.selected(i, :))))));
   
    cell_cdata =  min(max(round((perframe(i).ecc-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
    seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
    
    if smooth_bool
        tmpvals = big_ecc_smooth(takers);
        cell_cdata =  min(max(round((tmpvals-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
        seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
        seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
    end
    
end


% 
% for i= orbit
% %     takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
%     seq.frames(i).cells  = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
% %     seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(1-((perframe(i).ecc-minnum)./(maxnum-minnum)),1),0);
% %     seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
% %     seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(((perframe(i).ecc-minnum)./(maxnum-minnum)),1),0);    
%     cell_cdata =  min(max(round((perframe(i).ecc-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
%     seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);    
%     seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
% end

update_frame(handles)