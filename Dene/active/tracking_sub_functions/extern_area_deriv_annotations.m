function seq = extern_area_deriv_annotations(handles,seq,orbit)

data = seq2data(seq);
if size(data.cells.area,1) < 2
    display('cannot take deriv of single image');
    return
end

area_derivs = smoothen(deriv(data.cells.area));
one_std = std(area_derivs(data.cells.selected));
% max_area_der = max(area_derivs(data.cells.selected));
% min_area_der = min(area_derivs(data.cells.selected));
% absmax = max(abs(min_area_der),max_area_der);
choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
% Handle response
switch choice
    case 'Default'
%         display('continuing');
    case 'Custom'
        ncolors = 3;
        callingfig = handles.figure1;
        minnum = -2*one_std;
        maxnum = 2*one_std;
        midnum = 0;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [1 0 0; 0.75 0 0.75; 0 0 1];

        cbar_txt = 'Area Derivative';
        intrval = one_std/100;
        continuous_vals = [minnum:intrval:maxnum];
        outside_loop_expr = 'area_derivs = smoothen(deriv(data.cells.area));';
        expr_input =    ['cell_cdata = min(max(round((area_derivs(i,data.cells.selected(i,:))-',...
            num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input,outside_loop_expr);
        uiwait(cpickerH);
        return
    case 'Cancel'
        display('user cancelled');
        return        
end

%%% defaulting to the colormap db ('SEGGA_default_cmaps.mat')
cmap_name = 'dArea';
cmap_out = extern_get_cmap_from_db_with_name(cmap_name);
% cmap_out.contin_cmap;

minnum = -2*one_std;
maxnum = 2*one_std;
intrval = (maxnum-minnum)/100;

for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    temp_dA = area_derivs(i,data.cells.selected(i,:));
%     mu = mean(temp_dA(takers));
%     seq.frames(i).cells_colors(seq.frames(i).cells,1)  = max(min(0.75-((temp_dA(takers))./(one_std)),1),0);
%     seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
%     seq.frames(i).cells_colors(seq.frames(i).cells,3)  = max(min(0.75+(temp_dA(takers)./(one_std)),1),0);

    cell_cdata =  min(max(round((temp_dA(takers)-minnum)/intrval),1),size(cmap_out.contin_cmap,1));
	seq.frames(i).cells_colors(seq.frames(i).cells,:) = cmap_out.contin_cmap(cell_cdata,:);
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .4;
end

update_frame(handles)