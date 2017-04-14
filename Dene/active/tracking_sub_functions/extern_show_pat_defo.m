function seq = extern_show_pat_defo(handles,seq,orbit,smth_bool)
if nargin < 4 || isempty(smth_bool)
    smth_bool = false;
end
data = seq2data(seq);
outside_loop_expr = [...
'big_pat_defo = NaN(size(data.cells.selected));',...
'for i = 1:length(seq.frames) ',...
    'geom = seq.frames(i).cellgeom;',...
    'l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));',...
    '[~,pd]  = pattern_defo_graner(geom, l_cells'');',... 
    'temp_pat_defo  = pd'';',...           
    'globs = seq.inv_cells_map(i, l_cells);',...
    'big_pat_defo(i,globs) = temp_pat_defo;',...
'end;'];
if smth_bool
    outside_loop_expr = [outside_loop_expr,'big_pat_defo = smoothen(big_pat_defo);'];
end

eval(outside_loop_expr);
pat_defo_smooth_all = [];
for i = 1:length(seq.frames)
    l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :))); 
    globs = seq.inv_cells_map(i, l_cells);
    pat_defo_smooth_all = [pat_defo_smooth_all,squeeze(big_pat_defo(i,globs))];
end

choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');

switch choice
    case 'Default'

    case 'CustomOld'
        ncolors = 3;
        callingfig = handles.figure1;
        minnum = min(pat_defo_smooth_all(:));
        maxnum = max(pat_defo_smooth_all(:));
        midnum = (maxnum-minnum)/2;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [1 0 0; 0.75 0 0.75; 0 0 1];
        cbar_txt = 'Pattern Deformation';
        intrval = (maxnum-minnum)/100;
        continuous_vals = [minnum:intrval:maxnum];
        %outside_loop_expr was defined above
        expr_input = ['cell_cdata = min(max(round((squeeze(big_pat_defo(i,seq.inv_cells_map(i, nonzeros(seq.cells_map(i, data.cells.selected(i, :))))))-',...
                      num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];
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
        all_pd = pat_defo_smooth_all(~isnan(pat_defo_smooth_all));
        minnum = 1;
        %         minnum = mean(all_pd(:))-2*std(all_pd(:));
        maxnum = mean(all_pd(:))+2*std(all_pd(:));
        midnum = (maxnum-minnum)/2+minnum;

%         minnum = min(pat_defo_smooth_all(:));
%         maxnum = max(pat_defo_smooth_all(:));
%         midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
        return
    case 'Cancel'
        display('user cancelled');
        return        
end


all_pd = pat_defo_smooth_all(~isnan(pat_defo_smooth_all));
minnum = 1;
% minnum = mean(all_pd(:))-2*std(all_pd(:));
maxnum = mean(all_pd(:))+2*std(all_pd(:));
intrval = (maxnum-minnum)/100;

%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'Pat_Defo';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
% cmap_out.contin_cmap;


for i= orbit
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    seq.frames(i).cells  = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
    pat_defo_smooth = squeeze(big_pat_defo(i,seq.inv_cells_map(i, nonzeros(seq.cells_map(i, data.cells.selected(i, :))))));
%     seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(1-((pat_defo_smooth(takers)-minnum)./(maxnum-minnum)),1),0);
%     seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
%     seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(((pat_defo_smooth(takers)-minnum)./(maxnum-minnum)),1),0);
    cell_cdata =  min(max(round((pat_defo_smooth-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
    seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
end

update_frame(handles)