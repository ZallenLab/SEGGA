function seq = extern_edge_contraction_rate_annotations(handles,seq,orbit)


data = seq2data(seq);
edge_lens = data.edges.len;
edge_lens(edge_lens ==0) = nan;
edge_lens = smoothen_special(edge_lens);
edge_lens(~data.edges.selected) = nan;
edge_vels = deriv(edge_lens);
allVels = edge_vels(data.edges.selected);
cMap_bound = abs(mean(allVels(~isnan(allVels)))+2*std(allVels(~isnan(allVels))));
cMap_Incr = cMap_bound/50;
maxnum = cMap_bound;
minnum = -cMap_bound;
intrval = (maxnum-minnum)/100;
load shift_info
load timestep

outside_loop_expr = [...
'data = seq2data(seq);',...
'edge_lens = data.edges.len;',...
'edge_lens(edge_lens ==0) = nan;',...
'edge_lens = smoothen_special(edge_lens);',...
'edge_lens(~data.edges.selected) = nan;',...
'edge_vels = deriv(edge_lens);',...
'allVels = edge_vels(data.edges.selected);'...
'cMap_bound = abs(mean(allVels(~isnan(allVels)))+2*std(allVels(~isnan(allVels))));',...
'cMap_Incr = cMap_bound/50;',...
'maxnum = cMap_bound;',...
'minnum = -cMap_bound;',...
'intrval = (maxnum-minnum)/100;'...
];
% eval(outside_loop_expr);

continuous_vals = [-20,-cMap_bound:intrval:cMap_bound,20];
setappdata(handles.figure1,'curr_cmap_extrema',[minnum,maxnum]);
expr_input = ['edge_cdata = min(max(round((edge_vels(i,data.edges.selected(i,:))-',...
               num2str(minnum),')/',num2str(intrval),'),1),',num2str(numel(continuous_vals)),');'];





choice = questdlg('color map selection', ...
	'options:', ...
	'Default','Custom','Cancel','Cancel');
switch choice
    case 'Default'
        display('automapping edge contraction rates to red and blue colormap (white in middle)');
	case 'Custom'
        ncolors = 5;
        callingfig = handles.figure1;
        midnum = (maxnum-minnum)/2+minnum;
        mapped_numbers = [minnum,midnum,maxnum];
        colorInput = [[1 0 0];...
                     [182,104,104]./255;...
                     [72,72,72]./255;...
                     [104,104,182]./255;...
                     [0 0 1]];
        cbar_txt = 'Edge Contraction Rate';
        cpickerH = custom_colorpicker_02(ncolors,callingfig,handles,...
                            mapped_numbers,colorInput,cbar_txt,...
                            continuous_vals,expr_input,outside_loop_expr);
        setappdata(cpickerH,'edgesBool',true);
        uiwait(cpickerH);
        return
    case 'CustomNew'
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
        setappdata(cmap_figH,'edgesBool',true);
        mapped_numbers = [cMap_bound,0,cMap_bound];
        setappdata(cmap_figH,'mapped_numbers',mapped_numbers);
        return
    case 'Cancel'
        display('user cancelled');
        return        
end



for i = orbit%num_frames
    incrvals = [-20,-cMap_bound:cMap_Incr:cMap_bound,20];
    specialcolormap = bipolar(length(incrvals), 0.1);
    specialcolormap = flipud(specialcolormap);
    
    seq.frames(i).edges_velocity_inds = seq.edges_map(i,data.edges.selected(i,:));
    [~,binned_edge_vels] = histc(edge_vels(i,data.edges.selected(i,:)),incrvals);
    binned_edge_vels(binned_edge_vels==0) = round(numel(incrvals)/2);
    seq.frames(i).edges_individual_colors = specialcolormap(binned_edge_vels,:);        
end


update_frame(handles);

answr = questdlg('make colorbar?','cbar','yes','no','no');
switch answr
    case 'yes'
        mapped_numbers = [-cMap_bound,0,cMap_bound];
        cbar_txt = num2str(mapped_numbers);
        cbar_txt_bool = true;
        make_extern_colorbar(mapped_numbers,cbar_txt,cbar_txt_bool,specialcolormap)
    case 'no'
        return
end

function make_extern_colorbar(mapped_numbers,cbar_txt,cbar_txt_bool,specialcolormap)

[FileName,PathName] = uiputfile({'*.pdf;*.fig;*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Save Colorbar',...
          [pwd,filesep,'cbar.tif']);
FileName = strtok(FileName,'.');
discrete_bool = false;

output_colormap.colors = zeros(numel(mapped_numbers),3);
for i = 1:length(mapped_numbers)
    ind = 1+(i-1)*round((size(specialcolormap,1)-1)/2);
    output_colormap.colors(i,:) = specialcolormap(ind,:);
end

ticknums = ((1:size(output_colormap.colors,1))-0.5).*1/size(output_colormap.colors,1);
ticktxt = num2str(mapped_numbers');
if discrete_bool
    if cbar_txt_bool
        save_custom_cbar(output_colormap.colors,ticknums,ticktxt,PathName,FileName,cbar_txt);
    else
        save_custom_cbar(output_colormap.colors,ticknums,ticktxt,PathName,FileName);
    end
else
    contin_colors = specialcolormap;
    ticknums = (0:size(output_colormap.colors,1)/max(numel(mapped_numbers)-1,1):(size(output_colormap.colors,1))).*1/size(output_colormap.colors,1);

    if cbar_txt_bool        
        save_custom_cbar(contin_colors,ticknums,ticktxt,PathName,FileName,cbar_txt);
    else
        save_custom_cbar(contin_colors,ticknums,ticktxt,PathName,FileName);
    end
end
    
save([PathName,'cmap_data'],'output_colormap');