function seq = extern_coloredges_for_colorpicker_Callback(handles,seq,orbit,data)

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

incrvals = [minnum:intrval:maxnum];
incrvals = [min(incrvals)-abs(min(incrvals))*100,incrvals,max(incrvals)+abs(max(incrvals))*100];
if discrete_bool
    for i = orbit
        eval(expr_input);
        seq.frames(i).edges_velocity_inds = seq.edges_map(i,data.edges.selected(i,:));
        [~,binned_edge_vels] = histc(edge_vels(i,data.edges.selected(i,:)),incrvals);
        binned_edge_vels(binned_edge_vels==0) = round(numel(incrvals)/2);
        seq.frames(i).edges_individual_colors = custom_color_list(binned_edge_vels,:); 
    end
else
    continuous_colors = output_colormap.contin_colors;
	for i = orbit
        eval(expr_input);%%%gives the 'bin' values
        seq.frames(i).edges_velocity_inds = seq.edges_map(i,data.edges.selected(i,:));
        [~,binned_edge_vels] = histc(edge_vels(i,data.edges.selected(i,:)),incrvals);
        binned_edge_vels(binned_edge_vels==0) = round(numel(incrvals)/2);
        seq.frames(i).edges_individual_colors = continuous_colors(binned_edge_vels,:);
    end
end


update_frame(handles);


