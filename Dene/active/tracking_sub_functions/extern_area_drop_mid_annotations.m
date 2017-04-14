function seq = extern_area_drop_mid_annotations(handles,seq,orbit)

data = seq2data(seq);

%%%PIXELS
% max_area = 1250;
% min_area = 50;
mean_area = mean(data.cells.area(data.cells.selected));
one_std = std(data.cells.area(data.cells.selected));
max_area = mean_area+3*one_std;
min_area = max(mean_area - 3*one_std,0);

choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
% Handle response
switch choice
    case 'Default'
        display('continuing');
    case 'Custom'
        display('custom');
        
        ncolors = 3;
        callingfig = handles.figure1;
        mapped_numbers = [min_area,((max_area+min_area)/2),max_area];
        colorInput = [1 0 0;
                      0.5 0 0.5;
                      0 0 1];

        cbar_txt = 'area';
        continuous_vals = [min_area:max_area];
        expr_input = 'cell_cdata = data.cells.area(i,data.cells.selected(i,:));';
%         custom_colorpicker_02(ncolors,callingfig,callingfig_handles,...
%                             mapped_numbers,colorInput,cbar_txt,...
%                             continuous_vals,expr_input,outside_loop_expr,...
%                             for_DB_bool,cmapDB,cmapDB_figH,edgesBool)
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input);                        
        add_drop_min_btn_to_cpicker(cpickerH);
        setappdata(cpickerH,'seq',seq);
        uiwait(cpickerH);
        return
    
        
    case 'Cancel'
        display('user cancelled');
        return        
end



allareas = data.cells.area(data.cells.selected);
a_mean = mean(allareas);
a_min = min(allareas);
a_max = max(allareas);
a_std = std(allareas);
display({['a_mean: ',num2str(a_mean)],...
         [' a_min: ',num2str(a_min)],...
         [' a_max: ',num2str(a_max)],...
         [' a_std: ',num2str(a_std)]});

low_bound = max((a_mean-a_std),a_mean/2);
high_bound = (a_mean+a_std);
tmpmin = max(0,a_mean - 2*a_std);
tmpmax = min(a_max,a_mean+2*a_std);

figure; hist(allareas);
     
x = inputdlg({'Min','MinInner','MaxInner','Max'},...
              'Set Bounds', [1 15; 1 15;1 15; 1 15],...
              {num2str(tmpmin),num2str(low_bound),...
              num2str(high_bound),...
              num2str(tmpmax)}); 
          
display(x);

user_min = str2num(x{2});
user_max = str2num(x{3});
min_area = str2num(x{1});
max_area = str2num(x{4});



for i= orbit
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    areasofcells = data.cells.area(i,data.cells.selected(i,:));   
    seq.frames(i).cells_colors(seq.frames(i).cells,3)  = min(1,max(0,(areasofcells(takers)-min_area)./(max_area-min_area)));
    seq.frames(i).cells_colors(seq.frames(i).cells,2)  = 0;
    seq.frames(i).cells_colors(seq.frames(i).cells,1)  = min(1,max(0,1-(areasofcells(takers)-min_area)./(max_area-min_area)));
    seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = .6;
    
%     cond = ((areasofcells(takers)>(mean_area+one_std)) | (areasofcells(takers)<(max((mean_area-one_std),mean_area/2))));
%     seq.frames(i).cells = seq.frames(i).cells(cond);
	cond = (areasofcells(takers)>user_max) | (areasofcells(takers)<user_min);
    seq.frames(i).cells = seq.frames(i).cells(cond);
end

update_frame(handles)