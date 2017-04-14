function seq = extern_colorcells_for_colorpicker_Callback(handles,seq,orbit,data)

output_colormap = getappdata(handles.figure1,'output_colormap');
custom_color_list = output_colormap.colors;
mapped_numbers = output_colormap.numbs;
alpha_output = output_colormap.alpha;
discrete_bool = output_colormap.discrete_bool;
if ~discrete_bool
    continuous_vals = output_colormap.contin_numbs;
end

min_numCol = min(mapped_numbers); %for discrete
if ~isfield(output_colormap,'expr_input');
    expr_input = 'cell_cdata = data.cells.num_sides(i,data.cells.selected(i,:));';
else
    expr_input = output_colormap.expr_input;
end
if isfield(output_colormap,'outside_loop_expr');
    eval(output_colormap.outside_loop_expr);
end

if discrete_bool
    for i= orbit
        seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
        takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
        eval(expr_input);
        seq.frames(i).cells_colors(seq.frames(i).cells,:)  = custom_color_list(min(max(cell_cdata(takers)-min_numCol+1,1),numel(mapped_numbers)),:);
        seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = alpha_output;
    end
else
    running_polarity_bool = getappdata(handles.figure1,'running_polarity_bool');
    if isempty(running_polarity_bool)
        running_polarity_bool = false;
    end
    continuous_colors = output_colormap.contin_colors;

    if running_polarity_bool %special section to handle polarity
        for i= orbit
            eval(expr_input); %%%gives the 'bin' values
            cellcolors = continuous_colors(bin,:);
            seq.frames(i).cells_colors(temp_local_cells(cell_passed_thru), :) = cellcolors;
            seq.frames(i).cells_colors(temp_local_cells(cell_did_not_pass), :) = repmat([0.1 0.1 0.1],length(cell_did_not_pass),1);    
            seq.frames(i).cells_alphas(temp_local_cells(cell_passed_thru), :) = alpha_output;
            seq.frames(i).cells_alphas(temp_local_cells(cell_did_not_pass), :) = alpha_output;    
  
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
        
    else %%%for continuous, but not polarity
        minnum = min(mapped_numbers); %for continuous
        intrval = (max(mapped_numbers)-min(mapped_numbers))/100;
        for i= orbit
            seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
            takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
            eval(expr_input);
            colorinds = round(min(max(cell_cdata(takers),1),size(continuous_colors,1)));
            seq.frames(i).cells_colors(seq.frames(i).cells,:)  = continuous_colors(colorinds,:);
            if true%~exist('cell_adata','var')
                seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = alpha_output;
            else
                seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = cell_adata/size(continuous_colors,1);
            end
        end
    end
end

setappdata(handles.figure1,'running_polarity_bool',false);
update_frame(handles)

% --------------------------------------------------------------------
function color_area_Callback(hObject, eventdata, handles)
% hObject    handle to color_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    orbit = get_orbit_frames(handles);
    global seq
    data = seq2data(seq);
    
    max_area = 1;
    min_area = inf;
    mean_area = 1;
    
for i= orbit
	seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    areasofcells = data.cells.area(i,data.cells.selected(i,:));
    max_area = max(data.cells.area(data.cells.selected));
    max_area = min(max_area,mean(areasofcells)+3*std(areasofcells));
    min_area = min(data.cells.area(data.cells.selected));
    min_area = max(min_area,mean(areasofcells)-3*std(areasofcells));
end

    temp_areas = data.cells.area(data.cells.selected); 
%     mean_area = mean(temp_areas);
    max_area = 1250;
    min_area = 50;

choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
% Handle response
switch choice
    case 'Default'
        display('continuing');
    case 'Custom'
        display('custom');
        
        ncolors = 2;
        callingfig = handles.figure1;
        mapped_numbers = [min_area,max_area];
        colorInput = [];

        cbar_txt = 'area';
        continuous_vals = [min_area:max_area];
        expr_input = 'cell_cdata = data.cells.area(i,data.cells.selected(i,:));';
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input);
        uiwait(cpickerH);
        return
    case 'Cancel'
        display('user cancelled');
        return        
end


for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    areasofcells = data.cells.area(i,data.cells.selected(i,:));   
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = min(1,max(0,(areasofcells(takers)-min_area)./(max_area-min_area)));
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = min(1,max(0,1-(areasofcells(takers)-min_area)./(max_area-min_area)));
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .6;
end

update_frame(handles)