function [success, seq] = update_polarity_annotations_in_tracking_window(handles,seq)

success = false;

%%% initialize polarity colormap range options
pol_cmap_opts.type = 'Adaptive';
pol_cmap_opts.val = 0;
pol_cmap_opts.bounds = [];
setappdata(handles.figure1,'p_opts',pol_cmap_opts);

choose_cmap_range_opts_dialog(handles.figure1);
pol_cmap_opts = getappdata(handles.figure1,'p_opts');
display(pol_cmap_opts);
%%% TO DO: NEED to incorporate pol_cmap_opts in subsequent steps

[initial_success, incrvals, pol_cells, polarityfiletype, chan_num] = ...
    polarity_annotation_initial_step([], pol_cmap_opts);
if ~initial_success
    display('initial setup did not work');
    return
end

data = seq2data(seq);
num_frames = length(seq.frames);
if size(data.cells.selected,1)>1
    cells = find(any(data.cells.selected));
else
    cells = find(data.cells.selected);
end

choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
% Handle response
switch choice
    case 'Default'
%         display('continuing');
    case 'CustomOld'
        ncolors = 3;
        callingfig = handles.figure1;
        minnum = incrvals(2);
        maxnum = incrvals(end-1);
        midnum = 0;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [0 1 1; 1 1 1; 1 0 1];

        cbar_txt = 'Polarity';
        intrval = (maxnum-minnum)/100;
        continuous_vals = [incrvals(1),minnum:intrval:maxnum,incrvals(end)];
%         outside_loop_expr = 'area_derivs = smoothen(deriv(data.cells.area));';
        outside_loop_expr =['[initial_success, incrvals, pol_cells, polarityfiletype, chan_num] = ',...
            'polarity_annotation_initial_step(',num2str(chan_num),');',...
                            'if ~initial_success ',...
                            'display(''initial setup did not work'');',...
                            'return;',...
                            'end;',...
                            'cells = find(any(data.cells.selected));',...
                            'setappdata(handles.figure1,''running_polarity_bool'',true);',...
                            'minnum = incrvals(2);',...
                            'maxnum = incrvals(end-1);',...
                            'midnum = 0;',...
                            'mapped_numbers = [minnum,midnum,maxnum];',...
                            'intrval = (maxnum-minnum)/100;',...
                            'continuous_vals = [incrvals(1),minnum:intrval:maxnum,incrvals(end)];'];
        expr_input = ['temp_local_cells = seq.cells_map(i,cells(:));',...
                      'pos_inds = find(temp_local_cells);',...
                      'tempcellpols = pol_cells(i, pos_inds);',...
                      'temp_pol_inds = ~isnan(tempcellpols);',...
                      '[~,bin] = histc(tempcellpols(temp_pol_inds),continuous_vals);',...
                      'bin(bin==0) = floor(length(continuous_vals)/2);',...
                      'cell_passed_thru = pos_inds(temp_pol_inds);',...
                      'cell_did_not_pass = pos_inds(~temp_pol_inds);'];
         setappdata(handles.figure1,'running_polarity_bool',true);
%         expr_input =    ['cell_cdata = min(max(round((area_derivs(i,data.cells.selected(i,:))-',...
%             num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input,outside_loop_expr);
        uiwait(cpickerH);
        return
    case 'Custom'
        startdir = pwd;
        if isdeployed()
            base_dir = ctfroot();
            cmapfilefold = [base_dir,'..',filesep,'cmap_files',filesep];
        else
            base_dir = fileparts(mfilename('fullpath'));
            cmapfilefold = [base_dir,'..',filesep,'general',filesep];
        end
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
        maxnum = incrvals(2);
        minnum = incrvals(end-1);
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
%         visualize_multiple_colmaps(fullcmapname,handles);
        return
    case 'Cancel'
        display('user cancelled');
        return        
end


%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'Polarity #1';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
specialcolormap =  cmap_out.contin_cmap;


for i = 1:num_frames
    
    temp_local_cells = seq.cells_map(i,cells(:));
    pos_inds = find(temp_local_cells);

%     buffsizetop = 3;
%     buffsizebottom = 8;
%     total_buff = buffsizetop +buffsizebottom;
%     specialcolormap = jet(length(incrvals)+buffsizetop+buffsizebottom);
%     specialcolormap = specialcolormap((buffsizebottom+1):(length(incrvals)+(total_buff-buffsizetop)),:);

    
    tempcellpols = pol_cells(i, pos_inds);
    temp_pol_inds = ~isnan(tempcellpols);
    [~,bin] = histc(tempcellpols(temp_pol_inds),incrvals);
    bin(bin==0) = floor(length(incrvals)/2);
    
    cell_passed_thru = pos_inds(temp_pol_inds);
    cell_did_not_pass = pos_inds(~temp_pol_inds);
    
    cellcolors = specialcolormap(bin,:);    
  
    seq.frames(i).cells_colors(temp_local_cells(cell_passed_thru), :) = cellcolors;
    seq.frames(i).cells_colors(temp_local_cells(cell_did_not_pass), :) = repmat([0.1 0.1 0.1],length(cell_did_not_pass),1);    
   
    seq.frames(i).cells_alphas(temp_local_cells(cell_passed_thru), :) = 0.3;
    seq.frames(i).cells_alphas(temp_local_cells(cell_did_not_pass), :) = 0.3;    
  
    switch polarityfiletype
        case 1
            temp_select_locals = temp_local_cells(cell_passed_thru);
            seq.frames(i).cells = temp_select_locals(data.cells.selected(i,cells(cell_passed_thru)));

        case 2
            passanddidnt = [cell_did_not_pass,cell_passed_thru];
            templocals = temp_local_cells(passanddidnt);
            seq.frames(i).cells = templocals(data.cells.selected(i,cells(passanddidnt)));
    end
        
end


update_frame(handles);
success = true;