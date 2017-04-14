function seq = extern_show_cell_squareness(handles,seq,orbit)

data = seq2data(seq);
% qVal = data.cells.peri./realsqrt(data.cells.area);
outside_loop_expr = [...
...%'[sqrness_full, sqrness_cells] = calc_int_ang_squareness(geom,sel_cells);',...
'sqrVal_all = [];',...
'for i = 1:length(seq.frames)',...
    'l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));',...
    '[~,temp_sqrVal] = calc_int_ang_squareness(seq.frames(i).cellgeom,l_cells);',...
	'sqrVal_all = [sqrVal_all;temp_sqrVal];',...
    'perframe(i).sqr = temp_sqrVal;',...
'end;',...
'minnum = min(sqrVal_all);',...
'maxnum = max(sqrVal_all);',...
'stdnum = std(sqrVal_all);',...
'meannum = mean(sqrVal_all);',...
'minnum = meannum - stdnum;',...
'maxnum = meannum + stdnum;',...
'intrval = (maxnum-minnum)/100;'...

];
eval(outside_loop_expr);

continuous_vals = [minnum:intrval:maxnum];
setappdata(handles.figure1,'curr_cmap_extrema',[minnum,maxnum]);
expr_input = ['cell_cdata = min(max(round((qVal(i,data.cells.selected(i,:))-',...
               num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];

choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');

switch choice
    case 'Default'

    case 'CustomOld'
        ncolors = 2;
        callingfig = handles.figure1;
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [0 0 0;
                      0 1 1];
        cbar_txt = 'Cell Orientation';
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


for i= orbit
%     takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    seq.frames(i).cells  = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(1-((perframe(i).sqr-minnum)./(maxnum-minnum)),1),0);
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(((perframe(i).sqr-minnum)./(maxnum-minnum)),1),0);    
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
end

update_frame(handles)