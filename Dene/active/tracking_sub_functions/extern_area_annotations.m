function seq = extern_area_annotations(handles,seq,orbit,smth_bool)
if nargin < 4 || isempty(smth_bool)
    smth_bool = true;
end
data = seq2data(seq);

%%%PIXELS
% max_area = 1250;
% min_area = 50;
mean_area = mean(data.cells.area(data.cells.selected));
one_std = std(data.cells.area(data.cells.selected));
max_area = mean_area+2*one_std;
min_area = max(mean_area - 2*one_std,0);
intrval = (max_area-min_area)/100;

if smth_bool
    outside_loop_expr = ['areas_smooth = smoothen(data.cells.area);'];
    eval(outside_loop_expr);
end


choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
% Handle response
switch choice
    case 'Default'
        display('continuing');
    case 'CustomOld'
        display('custom');
        
        ncolors = 2;
        callingfig = handles.figure1;
        mapped_numbers = [min_area,max_area];
        colorInput = [];
%         load(zallencolormaps,'area');
        cbar_txt = 'area';
        continuous_vals = [min_area:max_area];
        expr_input = 'cell_cdata = data.cells.area(i,data.cells.selected(i,:));';
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input);
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
        minnum = min_area;
        maxnum = max_area;
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
        return
        
    case 'Cancel'
        display('user cancelled');
        return        
end

%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'Area';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
%%% custom_color_list = cmap_out.colorInput; %% discrete
%%% cmap_out.contin_cmap %% continuous


for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    areasofcells = data.cells.area(i,data.cells.selected(i,:));
    

    cell_cdata =  min(max(round((areasofcells-min_area)/intrval),1),size(cmap_out.contin_cmap,1));
    seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .6;

	if smth_bool
        big_area_smooth = squeeze(areas_smooth(i,seq.inv_cells_map(i, nonzeros(seq.cells_map(i, data.cells.selected(i, :))))));
        tmpvals = big_area_smooth(takers);
        cell_cdata =  min(max(round((tmpvals-min_area)/intrval),1),size(cmap_out.contin_cmap,1));
        seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
        seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .6;
    end
end


update_frame(handles)