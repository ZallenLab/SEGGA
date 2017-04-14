function make_and_save_cellshapes_full(seq, cells, img_save_str, extra_save_name,...
                                        pol_only,annotation_selection,cmapDB_bool,...
                                        fullcmapname,pol_cmap_opts)

dir_str_inds = strfind(pwd,filesep);
currdir = pwd;
global container_dir
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));

%%% TO DO - Generalize: Define base save directories only once.
% bname_sep = [pwd,filesep,'..',filesep,...
%         container_dir,'_annotations',filesep,var.name,filesep,...
%         'sep_tiffs',filesep]; 
% bname = [pwd,filesep,'..',filesep,container_dir,...
%          '_annotations',filesep,var.name,filesep];

if nargin < 9 || isempty(pol_cmap_opts)
    pol_cmap_opts.type = 'Adaptive';
    pol_cmap_opts.val = 0;
    pol_cmap_opts.bounds = [];
end
    
if nargin <8 || isempty(fullcmapname)
    cmapDB_bool = false;
    fullcmapname = [];
end


if nargin <7 || isempty(cmapDB_bool)
    cmapDB_bool = false;
    fullcmapname = [];
end

if nargin<6 || isempty(annotation_selection)
        annotation_selection.cmap_names = {...
        'nlost_t0';...
        'nsides';...
        'len_width';...
        'eccentricity';...
        'cell_size';...
        'ros_all';...
        'pat_defo';...
        'polarity'...        
        };
    annotation_selection.names = annotation_selection.cmap_names;
	annotation_selection.sel_vals = {...
        true;...%'nlost_t0'; (1)...
        true;...%'nsides'; (2)...
        true;...%'len_width'; (3)...
        false;...%'eccentricity'; (4)...
        false;...%'cell_size'; (5)...
        true;...%'ros_all'; (6)...
        false;...%'pat_defo'; (7)...
        false;...%'polarity' (8)...        
        };
    
    annotation_selection.smth_vals = {...
        false;...%'nlost_t0'; (1)...
        false;...%'nsides'; (2)...
        false;...%'len_width'; (3)...
        false;...%'eccentricity'; (4)...
        false;...%'cell_size'; (5)...
        false;...%'ros_all'; (6)...
        false;...%'pat_defo'; (7)...
        false;...%'polarity' (8)...        
        };
end

if nargin < 5 || isempty(pol_only)
    pol_only = false;
end

if cmapDB_bool
    load(fullcmapname); %loads 'zlab_cmaps' variable
    if isempty(whos('zlab_cmaps'))
        if isempty(whos('SEGGA_default_cmaps'))
            display(['variables zlab_cmaps || SEGGA_default_cmaps not found in fullcmapname file:',fullcmapname]);
            return
        else
            zlab_cmaps = SEGGA_default_cmaps;
        end
    end
end

perframe = [];
data = seq2data(seq);
[~, justdirpath] = get_filename_from_fullpath(pwd);
[dirtxt, ~] = get_filename_from_fullpath(justdirpath);


if pol_only
    load('edges_info_cell_background','channel_info');
    var.name = 'polarity';
    var.title = 'polarity';
    if cmapDB_bool
        polInd = 9;
        cmap_name = anntn_sel.cmap_names(polInd);
        cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
    else
        cmap = [];
    end
    
    for  chan_num = 1:length(channel_info)
        var.chan_num = chan_num;
        make_polarity_annotation_internal(seq,data,var,'edges_info_cell_background',...
            find(any(data.cells.selected)),var.chan_num,dirtxt,cmap,pol_cmap_opts);
    end

    return
end



% % %  non polarity stuff


load topological_events_per_cell cells_lost_hist cells_to_anal
topo_cells = cells_to_anal;
nlost_after_t0 = create_nlost_for_visual(pwd);

% in order to perform temporal smoothing, we need global cell IDs
big_pat_defo = NaN(size(data.cells.selected));
big_LW = big_pat_defo;
big_ecc = big_pat_defo;
big_area = big_pat_defo;


for i = 1:length(seq.frames)   
    geom = seq.frames(i).cellgeom;
    l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));    
    faces = geom.faces(l_cells, :);
    faces_for_area = faces2ffa(faces);
     
    %eccentricity
    [cell_L1, cell_L2, cell_angle, ~] = cell_ellipse(geom.nodes, faces_for_area);
    ecc = realsqrt(1 - (cell_L2 ./ cell_L1).^2);

%     length_width_ratio = (cell_L1 ./ cell_L2);
    hor = sqrt((cell_L1 .* cosd(cell_angle)).^2 + (cell_L2 .* sind(cell_angle)).^2);
    ver = sqrt((cell_L1 .* sind(cell_angle)).^2 + (cell_L2 .* cosd(cell_angle)).^2);
    cell_hor_ver_ratio = hor./ver;
   
    
    % numsides taken from global data, but size and order are maintained
    % with local cell measurements
    perframe(i).numsides = [data.cells.num_sides(i,data.cells.selected(i,:))]';    
    perframe(i).cell_hor_ver_ratio = log2(cell_hor_ver_ratio);
%     using log2 because the values go between 0 and inf
    perframe(i).ecc = ecc;
    [~, pd] = pattern_defo_graner(seq.frames(i).cellgeom, l_cells');
    perframe(i).pat_defo = pd';
    
    %inv_cells_map goes from local to global
    globs = seq.inv_cells_map(i, l_cells);
    big_pat_defo(i,globs) = perframe(i).pat_defo;
    big_LW(i,globs) = perframe(i).cell_hor_ver_ratio;
    big_ecc(i,globs) = perframe(i).ecc;
    
    takers = logical((seq.cells_map(i,topo_cells)~=0).*data.cells.selected(i,topo_cells));
    
    perframe(i).nlost_regular = cells_lost_hist(i,takers(:));
    perframe(i).nlost_t0 = nlost_after_t0(i,takers(:));    
    perframe(i).l_cells = l_cells;
    perframe(i).areas = data.cells.area(i,data.cells.selected(i,:));
    big_area(i,globs) = perframe(i).areas;
end

big_pat_defo = smoothen(big_pat_defo);
big_LW = smoothen(big_LW);
big_ecc = smoothen(big_ecc);
big_area = smoothen(big_area);

for i = 1:length(seq.frames)
    l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :))); 
    globs = seq.inv_cells_map(i, l_cells);
    % re globs: same thing as doing find(data.cells.selected(i,:))    
    % we can throw these values in the other list which is based on local
    % indices because order and size is maintained (just as it was above.
    perframe(i).pat_defo_smooth = squeeze(big_pat_defo(i,globs));
    perframe(i).cell_hor_ver_smooth = squeeze(big_LW(i,globs));
    perframe(i).ecc_smooth = squeeze(big_ecc(i,globs));
    perframe(i).area_smooth = squeeze(big_area(i,globs));
end

nlost_t0Ind = 1;
if annotation_selection.sel_vals{nlost_t0Ind} %nlost_t0
    if cmapDB_bool        
        cmap_name = annotation_selection.cmap_names(nlost_t0Ind);
        try
            cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
        catch
            display('trying alternative name for ''cmap_name''');
            str_presence = strfind(cmap_name,'nlost');
            if any(str_presence{:})
                cmap = get_cmap_from_db_with_name('NLost',zlab_cmaps);
            end
        end
    else
%         cmap = [];
        cmap.colorInput = [];
    end
    var.name = 'nlost_t0';
    var.min = 0;
    var.max = 4;
    var.title = 'Neighbors Lost';
    make_discrete_annotation_internal(seq,data,var,perframe,topo_cells,cmap.colorInput);
end

nsidesInd = 2;
if annotation_selection.sel_vals{nsidesInd} %nsides
    if cmapDB_bool        
        cmap_name = annotation_selection.cmap_names(nsidesInd);
        cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
        var.min = cmap.mapped_numbers(1);
        var.max = cmap.mapped_numbers(end);
    else
        cmap.colorInput = [];
        var.min = 4;
        var.max = 8;
    end
    var.name = 'numsides';
    var.title = 'N Sides';


    cells_input = [];
    make_discrete_annotation_internal(seq,data,var,perframe,cells_input,cmap.colorInput);
    
end

len_widthInd = 3;
if annotation_selection.sel_vals{len_widthInd} %'len_width';...
    if cmapDB_bool        
        cmap_name = annotation_selection.cmap_names(len_widthInd);
        try
            cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
        catch
            display('trying alternative name for ''cmap_name''');
            str_presence = strfind(cmap_name,'len_width');
            if any(str_presence{:})
                cmap = get_cmap_from_db_with_name('LW_ratio',zlab_cmaps);
            end
        end
    else
        cmap = [];
    end

    if isfield(annotation_selection,'smth_vals') && annotation_selection.smth_vals{len_widthInd}
        var.name = 'cell_hor_ver_smooth';
    else
        var.name = 'cell_hor_ver_ratio';
    end
    var.min = log2(1/2); %log2(0.25)
    var.max = log2(2); %log2(4)
    
    %%% these will override the numbers above (var.min, var.max)
    var.min_fun = @(x) -(abs(mean(x)) + 2*std(x));
    var.max_fun = @(x) (abs(mean(x)) + 2*std(x));
    
    var.title = 'Length Width Ratio';
    cells_input = [];
    logscale_switch = true;
    make_gradient_annotation_internal(seq,data,var,perframe,cells_input,logscale_switch,cmap);

end

eccenInd = 4;
if annotation_selection.sel_vals{eccenInd} %'eccentricity';...
	if cmapDB_bool        
        cmap_name = annotation_selection.cmap_names(eccenInd);
        cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
    else
        cmap = [];
    end
	if annotation_selection.smth_vals{eccenInd}
        var.name = 'ecc_smooth';
    else
        var.name = 'ecc';
    end
    
    var.min = 0;
    var.max = 1;
    
    %%% these will override the numbers above (var.min, var.max)
    var.min_fun = @(x) 0;
%     var.min_fun = @(x) mean(x) - 2*std(x);
    var.max_fun = @(x) mean(x) + 2*std(x);
    
    var.title = 'Eccentricity';
    cells_input = [];
    logscale_switch = false;
    make_gradient_annotation_internal(seq,data,var,perframe,cells_input,logscale_switch,cmap);
end

areaInd = 5;
if annotation_selection.sel_vals{areaInd} %'cell_size';...
	if cmapDB_bool        
        cmap_name = annotation_selection.cmap_names(areaInd);
        cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
    else
        cmap = [];
    end
	if annotation_selection.smth_vals{areaInd}
        var.name = 'area_smooth';
    else
        var.name = 'areas';
    end
    
    var.min = 50;
    var.max = 1250;
    
	%%% these will override the numbers above (var.min, var.max)
    var.min_fun = @(x) mean(x) - 2*std(x);
    var.max_fun = @(x) mean(x) + 2*std(x);
    
    var.title = 'Area';
    cells_input = [];
    logscale_switch = false;
    make_gradient_annotation_internal(seq,data,var,perframe,cells_input,logscale_switch,cmap);
end

rosAllInd = 6;
if annotation_selection.sel_vals{rosAllInd} %'ros_all';...    
	var.name = 'ros';
    var.min = 5;
    var.title = 'rosettes';
    cells_input = [];
    load('analysis','clusters');
    make_clusters_annotation_internal(seq,data,var,clusters,cells_input);
end


pat_defoInd = 7;
if annotation_selection.sel_vals{pat_defoInd} %'pat_defo';...
%     perframe(i).pat_defo_smooth
	if cmapDB_bool        
        cmap_name = annotation_selection.cmap_names{pat_defoInd};
        cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
    else
        cmap = [];
    end
	if annotation_selection.smth_vals{pat_defoInd}
        var.name = 'pat_defo_smooth';
    else
        var.name = 'pat_defo';
    end
    
    var.min = 1;
    var.max = 2;
    
	%%% these will override the numbers above (var.min, var.max)
    var.min_fun = @(x) 1;
%     var.min_fun = @(x) mean(x) - 2*std(x);
    var.max_fun = @(x) mean(x) + 2*std(x);
    
    var.title = 'pattern deformation';
    cells_input = [];
    logscale_switch = false;
    make_gradient_annotation_internal(seq,data,var,perframe,cells_input,logscale_switch,cmap);
end

polInd = 8;
if annotation_selection.sel_vals{polInd} %'polarity';... 
    if isempty(dir('edges_info*'))
        display('missing polarity file');
        return
    end
    load('edges_info_cell_background','channel_info');
    var.name = 'polarity';
    var.title = 'polarity';
    if cmapDB_bool
%         polInd = 9;
        cmap_name = annotation_selection.cmap_names(polInd);
%         discrete_bool = false;
        cmap = get_cmap_from_db_with_name(cmap_name,zlab_cmaps);
    else
        cmap = [];
    end
    for  chan_num = 1:length(channel_info)
        var.chan_num = chan_num;
        alpha = [];                                            
        make_polarity_annotation_internal(seq,data,var,'edges_info_cell_background',...
                                          find(any(data.cells.selected)),var.chan_num,...
                                          dirtxt,cmap,alpha,container_dir,pol_cmap_opts);
    end
end

          
function make_gradient_annotation_internal(seq,data,var,...
                                            perframe_data,cells,...
                                            logscale_switch,cmap,alpha,...
                                            container_dir)
% global container_dir                                        
if nargin < 9 || isempty(container_dir) 
        dir_str_inds = strfind(pwd,filesep);
        currdir = pwd;
        container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
end

if nargin < 8 || isempty(alpha)
    alpha = 0.6;
end

if nargin < 7 || isempty(cmap)
    use_extern_cmap_bool = false;
else
    use_extern_cmap_bool = true;
end

if nargin < 6 || isempty(logscale_switch)
    logscale_switch = false;
end

startdir = pwd;

if isfield(var,'min_fun') && isfield(var,'max_fun')
    %%% Get max and min from distribution
    pooled_data = [];
    for j = 1:length(perframe_data)
        pooled_data = [pooled_data,flatten(getfield(perframe_data(j),var.name))];
    end
    minval = var.min_fun(pooled_data);
    maxval = var.max_fun(pooled_data);
    var.min = minval;
    var.max = maxval;
end


for i = 1:length(seq.frames)

    if nargin < 5 || isempty(cells)
        l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
        takers = true(1,length(l_cells));
        seq.frames(i).cells = l_cells;
    else

        takers = logical(data.cells.selected(i,cells))&logical(seq.cells_map(i,cells)~=0);
        tempcells = cells(takers);
        seq.frames(i).cells  = nonzeros(seq.cells_map(i,tempcells));

    end


    numcols = 100; 
%     cm = bipolar_mod_dlf(numcols, 0.4);
    if use_extern_cmap_bool
        m = numcols;
        interp = 'linear'; 
        if m ~= size(cmap.contin_cmap, 1)
            xi = linspace(1, size(cmap.contin_cmap, 1), m);
            cm = interp1(cmap.contin_cmap, xi, interp);
        end
    else
        cm = bipolar_original(numcols, -0.2);
    end
%         cm = bipolar(numcols, 0.4); %white in the middle    
    curr_var = getfield(perframe_data(i),var.name);
 
    percs = min((round(max(0,(curr_var(takers)-var.min)./(var.max-var.min))*numcols)+1),numcols);
    seq.frames(i).cells_colors(perframe_data(i).l_cells,1:3) = cm(percs,:);
    seq.frames(i).cells_alphas(perframe_data(i).l_cells,1)  = alpha;

    frameind = i;
    imgfilename = seq.frames(frameind).img_file;

    directory = pwd;
    if length(dir(fullfile(directory, seq.bnr_dir, imgfilename)))
        imgfilename = fullfile(directory, seq.bnr_dir, imgfilename);
    end

    img = imread(imgfilename);
    imghandle = figure;
    set(imghandle,'Visible','off'); 

    colormap(gray);
    imagesc(imread(imgfilename));
    axis off;
    hold on
    
    ax = gca;
    set(ax, 'units', 'pixels')
    pos = get(ax, 'position');
    pos = round(pos);
    pos([4 3]) = [size(img,1),size(img,2)];
    set(ax, 'position', pos);

    temp_cells = seq.frames(frameind).cells;
    cells_colors = seq.frames(frameind).cells_colors(seq.frames(frameind).cells,:);
    alphas = seq.frames(frameind).cells_alphas(seq.frames(frameind).cells);


    arg1 = cells_colors;
    arg2 = 'flat';

    fac = seq.frames(frameind).cellgeom.faces(temp_cells, :);
    vert = [seq.frames(frameind).cellgeom.nodes(:,2) seq.frames(frameind).cellgeom.nodes(:,1)];            


    cellsH = patch('Faces', fac, 'Vertices', vert, ...
        'FaceVertexCData', arg1, 'FaceColor', arg2, ...
        'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
        'AlphaDataMapping', 'none', 'edgecolor', 'none');


%           title(var.title,'interpreter','none');
    particularname = [var.name,'_0',num2str(zeros(1,3-size(num2str(i),2))),num2str(i)];
    particularname(ismember(particularname,' ,.:;!', 'legacy')) = [];
%           regexprep(s,'[^\w'']','')
    bname_sep = [pwd,filesep,'..',filesep,...
        container_dir,'_annotations',filesep,var.name,filesep,...
        'sep_tiffs',filesep]; 
    if ~isdir(bname_sep)
        mkdir(bname_sep);
    end
    
    h = gcf;
    pos = [680   408   801   684];
    set(h, 'position', pos);
%     set(gcf,'PaperPosition',pos)
%     set(gca,'position',[0 0 1 1],'units','normalized')
    %%% Normalize the resolution, and pixel size of the output:
    h.PaperUnits = 'inches';
    h.PaperPosition = [0 0 5 4];
    movie_frame = getframe(gca);
%     print(h,[bname_sep,particularname, '.tif'],'-dtiff','-r250')
    imwrite(movie_frame.cdata,[bname_sep,particularname, '.tif'], 'Resolution',[2000,2000]);
%     saveas(gcf, [bname_sep,particularname, '.tif']);
    set(gca,'position',[0 0 1 1],'units','normalized')
    set(imghandle,'Visible','off');
    set(cellsH,'Visible','off');

    close(imghandle);
                
end
        
bname_sep = [pwd,filesep,'..',filesep,container_dir,...
             '_annotations',filesep,var.name,filesep,'sep_tiffs',filesep];
bname = [pwd,filesep,'..',filesep,container_dir,...
         '_annotations',filesep,var.name,filesep];
ImageList = dir([bname_sep,'*.tif']);
sname = [bname,var.name, '.avi'];
%                     t0 file
if isempty(dir([bname,'tzero*']))
    write_shift_info_txt_file(pwd,bname);
    create_dir_name_txt_file(pwd,bname);
end


if isempty(dir([bname,'..',filesep,'tzero*']))
    write_shift_info_txt_file(pwd,[bname,'..',filesep]);
    create_dir_name_txt_file(pwd,[bname,'..',filesep]);
end

ticknums = [0,size(cm,1)/2,size(cm,1)];
ticknums_rel = ticknums./size(cm,1);
if logscale_switch
    ticktxt = {num2str(2^var.min),num2str(2^((var.min+var.max)/2)),num2str(2^var.max)};
else
    ticktxt = {num2str(var.min),num2str((var.min+var.max)/2),num2str(var.max)};
end

% save_custom_cbar(colormap_in,tickvals,ticklabels,savedir,...
%                           savename,cbar_txt,alpha,ftypes)
save_custom_cbar(cm,ticknums_rel,ticktxt,bname,'cmap');


%AVI = avifile(sname, 'FPS', 1, 'Compression', 'none');
writerObj = VideoWriter(sname);
open(writerObj);
for iImage = 1:length(ImageList)
    aImage = imread([bname_sep,ImageList(iImage).name]);

%   AVI = addframe(AVI, aImage);
    writeVideo(writerObj,aImage)
end
close(writerObj);
cd(startdir);
                     
                     
	
function make_discrete_annotation_internal(seq,data,var,perframe_data,...
                                           cells,cust_clr_map,alpha,...
                                           container_dir)
                                       
if nargin < 9 || isempty(container_dir) 
        dir_str_inds = strfind(pwd,filesep);
        currdir = pwd;
        container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
end
        
if nargin < 6 || isempty(cust_clr_map)

    num_colors = (var.max - var.min +1);

    if num_colors == 5
        manyhsv = hsv(20*4);
        convnums = [1,16,29,49,61];
        evenshsv = manyhsv(convnums,:);
        custom_color_list = evenshsv;
    end

    if num_colors == 8
        manyhsv = cool(20);
        evenshsv = manyhsv(2:2:end,:);
        evenshsv = evenshsv([1,2,4,6:end],:);
        evenshsv = evenshsv([end,1:end-1],:);
        evenshsv = evenshsv([1:2,4:end,3],:);
        evenshsv(1,:) = [1 0 0];
        evenshsv(2,:) = [1 0.4 0];
        custom_color_list = evenshsv;
    end

    custom_color_list = custom_color_list(end:-1:1,:);
else
    custom_color_list = cust_clr_map;
end

if nargin < 7 || isempty(alpha)
    alpha = 0.6;
end
        
startdir = pwd;

for i = 1:length(seq.frames)

    if nargin < 5 || isempty(cells)
        seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    else
        tmp_glob_cells = logical(cells.*(data.cells.selected(i,:)));
        seq.frames(i).cells  = (nonzeros(seq.cells_map(i,tmp_glob_cells)));
    end
        
        

    curr_var = getfield(perframe_data(i),var.name);      
    seq.frames(i).cells_colors(seq.frames(i).cells,:)  = custom_color_list(min(max(curr_var-var.min+1,1),(var.max-var.min+1)),:);
	seq.frames(i).cells_alphas(seq.frames(i).cells,1)  = alpha;
    
    frameind = i;
    imgfilename = seq.frames(frameind).img_file;
    img = imread(imgfilename);
    imghandle = figure;
    set(imghandle,'Visible','off'); 

    colormap(gray);
    imagesc(imread(imgfilename));
    axis off;
    hold on
    
	ax = gca;
    set(ax, 'units', 'pixels')
    pos = get(ax, 'position');
    pos = round(pos);
    pos = [0,0, size(img,1),size(img,2)];
    set(ax, 'position', [2, 2, pos(4), pos(3)]);
    set(gcf, 'position', [1, 1, pos(4)+2, pos(3)+2]);

    temp_cells = seq.frames(frameind).cells;
    cells_colors = seq.frames(frameind).cells_colors(seq.frames(frameind).cells,:);
    alphas = seq.frames(frameind).cells_alphas(seq.frames(frameind).cells);


    arg1 = cells_colors;
    arg2 = 'flat';

    fac = seq.frames(frameind).cellgeom.faces(temp_cells, :);
    vert = [seq.frames(frameind).cellgeom.nodes(:,2) seq.frames(frameind).cellgeom.nodes(:,1)];            


    cellsH = patch('Faces', fac, 'Vertices', vert, ...
        'FaceVertexCData', arg1, 'FaceColor', arg2, ...
        'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
        'AlphaDataMapping', 'none', 'edgecolor', 'none');
            
    title(var.title,'interpreter','none');
    particularname = [var.name,'_0',num2str(zeros(1,3-size(num2str(i),2))),num2str(i)];
    particularname(ismember(particularname,' ,.:;!', 'legacy')) = [];
%                 regexprep(s,'[^\w'']','')
    bname_sep = [pwd,filesep,'..',filesep,container_dir,...
                 '_annotations',filesep,var.name,filesep,'sep_tiffs',filesep]; 
    if ~isdir(bname_sep)
        mkdir(bname_sep);
    end
%     pos = [680   408   801   684];
%     set(gcf, 'position', pos);
%     set(gca,'position',[0 0 1 1],'units','normalized')
%     h = gcf;
%     
%     %%% Normalize the resolution, and pixel size of the output:
%     h.PaperUnits = 'inches';
%     h.PaperPosition = [0 0 5 4];
%     print(h,[bname_sep,particularname, '.tif'],'-dtiff','-r250')
    movie_frame = getframe(gca);
    imwrite(movie_frame.cdata,[bname_sep,particularname, '.tif'], 'Resolution',[2000,2000]);
    
%     saveas(gcf, [bname_sep,particularname, '.tif']);
    set(imghandle,'Visible','off');
    set(cellsH,'Visible','off');
    close(imghandle);
end
    


bname = [pwd,filesep,'..',filesep,container_dir,...
         '_annotations',filesep,var.name,filesep];
if ~isdir(bname)
    mkdir(bname);
end

% t0 file
if isempty(dir([bname,'tzero*']))
        write_shift_info_txt_file(pwd,bname);
        create_dir_name_txt_file(pwd,bname);
end

if isempty(dir([bname,'..',filesep,'tzero*']))
        write_shift_info_txt_file(pwd,[bname,'..',filesep]);
        create_dir_name_txt_file(pwd,[bname,'..',filesep]);
end

ticknums = (0:size(custom_color_list,1))+0.5;
rel_ticknums = ticknums./size(custom_color_list,1);
maxval = max((var.max-var.min+1),size(custom_color_list,1))+var.min - 1;
ticktxt = num2str((var.min:maxval)');
save_custom_cbar(custom_color_list,rel_ticknums,ticktxt,bname,'cmap');
save([bname,'cmap_data'],'custom_color_list');


ImageList = dir([bname_sep,'*.tif']);
sname = [bname,var.name, '.avi'];
%AVI = avifile(sname, 'FPS', 1, 'Compression', 'none');
writerObj = VideoWriter(sname);
open(writerObj);
for iImage = 1:length(ImageList)
    aImage = imread([bname_sep,ImageList(iImage).name]);
%   AVI = addframe(AVI, aImage);
    writeVideo(writerObj,aImage)
end
close(writerObj);
cd(startdir);
                     
                   
% % % % % % %                      
% % % % % % %  For polarity

function make_polarity_annotation_internal(seq,data,var,pol_file_name,...
                                            cells,chan_num,dirtxt,cmap,alpha,...
                                            container_dir,pol_cmap_opts)
if nargin < 11 || isempty(pol_cmap_opts)
    pol_cmap_opts.type = 'Adaptive';
    pol_cmap_opts.val = 0;
    pol_cmap_opts.bounds = [];
end

if nargin < 10 || isempty(container_dir) 
        dir_str_inds = strfind(pwd,filesep);
        currdir = pwd;
        container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
end

if nargin < 9 || isempty(alpha)
    alpha = 0.6;
end
    
if nargin < 8 || isempty(cmap)
    use_extern_cmap_bool = false;
else
    use_extern_cmap_bool = true;
end

clear('channel_info','options');    
startdir = pwd;
load(pol_file_name,'channel_info','options');
startdir = pwd;
% cd([pwd,filesep,'..',filesep,'scripts',filesep,]);
% script_for_values_along_edges_cell_back;
cd(startdir);
%polarityfiletype = 1;
num_frames = length(seq.frames);
%cells = find(any(data.cells.selected));

pol_cells = channel_info(chan_num).cells.polarity;
no_nan_pol = interp_pol(pol_cells);
pol_cells = smoothen(no_nan_pol);


for i = 1:num_frames
    local_cells(i,:) = seq.cells_map(i,cells(:));
end

tmp_all_cells = channel_info(chan_num).cells.polarity(:);
tmp_all_cells = tmp_all_cells(~isnan(tmp_all_cells));
pol_mean = mean(tmp_all_cells);
pol_std = std(tmp_all_cells);
pol_rad = abs(pol_mean)+2*pol_std;


switch pol_cmap_opts.type
    case 'Adaptive' % pol_cmap_opts.val = 0;
        display('using adaptive polarity colormap bounds');
        b = [-pol_rad,pol_rad];
        incr_step = diff(b)/100;
        %%% if the magnitude of the value is larger than pol_rad*5 then it's probably
        %%% something weird/wrong - so map it back to the middle (done below)
        incrvals = [-pol_rad*5,b(1):incr_step:b(end),pol_rad*5];
        incr_min = incrvals(1);
        incr_max = incrvals(end);

    case 'User Defined' % pol_cmap_opts.val = 1;
        display('using user defined polarity colormap bounds');
        b = pol_cmap_opts.bounds;
        incr_step = diff(b)/100;
        %%% if the value is outside of the user defined range by twice the
        %%% span of the range, then map to the middle just as in the other
        %%% cases.
        
        far_left = b(1) - 2*diff(b);
        far_right = b(end) + 2*diff(b);
        incrvals = [far_left,b(1):incr_step:b(end),far_right];
        incr_min = incrvals(1);
        incr_max = incrvals(end);

    case 'Hard Coded' % pol_cmap_opts.val = 2;
        display('using hard coded polarity colormap bounds');
        
        incrvals_baz = [-20,-1.2:.05:1.2,20];
        incrvals_sqh = [-20,-0.6:.05:0.6,20];
        incrvals_moe = [-20,-0.4:.05:0.4,20];

        if strcmp(channel_info(chan_num).name,'sqh') || strcmp(channel_info(chan_num).name,'utrophin') ||...
                strcmp(channel_info(chan_num).name,'shrm') || strcmp(channel_info(chan_num).name,'rok')
            incrvals = incrvals_sqh;
        else if strcmp(channel_info(chan_num).name,'baz')
                incrvals = incrvals_baz;

            else if strcmp(channel_info(chan_num).name,'moe')
                incrvals = incrvals_moe;
                else if strcmp(channel_info(chan_num).name,'arm')
                incrvals = [-20,-1:.05:1,20];
                    else
                        display(['no condition for: ',channel_info(chan_num).name]);
                    end
                end
            end
        end

        incr_min = incrvals(2);
        incr_max = incrvals(end-1);
end

%%% These steps for all cmap_opts choices

% %   old bipolar -> red to [blck (if n < 0.5) or white if (n > 0.5)] to blue
%      if (n < 0):   red to orange to blck to cyan to blue
if use_extern_cmap_bool
    m = length(incrvals);
    interp = 'linear'; 
    if m ~= size(cmap.contin_cmap, 1)
        xi = linspace(1, size(cmap.contin_cmap, 1), m);
        specialcolormap = interp1(cmap.contin_cmap, xi, interp);
    else
        specialcolormap = cmap.contin_cmap;
    end
else
    specialcolormap = bipolar_original(length(incrvals), -0.2);
end
    
for i = 1:num_frames
    pos_inds = find(local_cells(i,:));
    tempcellpols = pol_cells(i, pos_inds);
    temp_pol_inds = ~isnan(tempcellpols);
    [n,bin] = histc(tempcellpols(temp_pol_inds),incrvals);
    %%% handling values outside of the bin range ('incrvals')
    bin(bin==0) = floor(length(incrvals)/2);
    
    cell_passed_thru = pos_inds(temp_pol_inds);
    cell_did_not_pass = pos_inds(~temp_pol_inds);
    
    cellcolors = specialcolormap(bin,:);
    nonselected_cells = nonzeros(local_cells(i,~data.cells.selected(i,cells)));

  
    seq.frames(i).cells_colors(local_cells(i,cell_passed_thru), :) = cellcolors;
    seq.frames(i).cells_colors(local_cells(i,cell_did_not_pass), :) = repmat([0.1 0.1 0.1],length(cell_did_not_pass),1);
    
    seq.frames(i).cells_alphas = zeros(size(seq.frames(i).cells_colors,1),1);
%     seq.frames(i).cells_alphas(local_cells(i,cell_passed_thru)) = min(max(abs(tempcellpols(:)).*(1/3),0.3),0.5);
    seq.frames(i).cells_alphas(local_cells(i,cell_passed_thru)) = alpha;
    
    if ~isempty(cell_did_not_pass)
        seq.frames(i).cells_alphas(local_cells(i,cell_did_not_pass), :) = 0;
    end
    

    templocals = local_cells(i,cell_passed_thru);
    seq.frames(i).cells = templocals(data.cells.selected(i,cells(cell_passed_thru)));

      
end
    
    
    
%use the polarity image
startfile = channel_info(chan_num).filename;
%[z_num, t_num, t_ind] = get_file_nums_dlf(startfile)
[justfile justdirpath] = get_filename_from_fullpath(startfile);
outfilenames = get_img_file_for_pol_calcs(options,seq,startfile);

chansettingsfilename = 'channel_image_settings.txt';
if isempty(dir([justdirpath,filesep,chansettingsfilename]))
    startdir = pwd;
    cd(justdirpath);
    channel_image_options_script;
    cd(startdir);
end


[a,b] = textread([justdirpath,filesep,chansettingsfilename], ...
 '%s = %s', 'commentstyle', 'matlab');
for i = 1:length(b)
    eval([a{i} ' = ' b{i} ';'])
end
                    
                    
%   if there is an empty chan options file, then rewrite it        
if isempty(a) || isempty(b)
    startdir = pwd;
    cd(justdirpath);
    channel_image_options_script;
    cd(startdir);
    [a b] = textread([justdirpath,filesep,chansettingsfilename], ...
         '%s = %s', 'commentstyle', 'matlab');
        for i = 1:length(b)
            eval([a{i} ' = ' b{i} ';'])
        end
end    
            
for i = 1:length(seq.frames)
    if nargin < 5 || isempty(cells)
        l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
        takers = true(1,length(l_cells));
        seq.frames(i).cells = l_cells;
    else

        takers = logical(data.cells.selected(i,cells))&logical(seq.cells_map(i,cells)~=0);
        tempcells = cells(takers);
        seq.frames(i).cells  = nonzeros(seq.cells_map(i,tempcells));

    end
        
    frameind = i;
%             imgfilename = seq.frames(frameind).img_file;
    imgfilename = outfilenames{i};

    directory = pwd;
    if length(dir(fullfile(directory, seq.bnr_dir, imgfilename)))
        imgfilename = fullfile(directory, seq.bnr_dir, imgfilename);
    end

    img = double(imread(imgfilename));
    img = uint8((img - shift_factor)*brightness_factor*1.2);
    imghandle = figure;
    set(imghandle,'Visible','off'); 
    colormap(gray(256));

    image(img);
    axis off;
    hold on
    
    ax = gca;
    set(ax, 'units', 'pixels')
    pos = get(ax, 'position');
    pos = round(pos);
    pos = [0,0, size(img,1),size(img,2)];
    set(ax, 'position', [2, 2, pos(4), pos(3)]);
    set(gcf, 'position', [1, 1, pos(4)+2, pos(3)+2]);

    temp_cells = seq.frames(frameind).cells;
    cells_colors = seq.frames(frameind).cells_colors(seq.frames(frameind).cells,:);
    alphas = seq.frames(frameind).cells_alphas(seq.frames(frameind).cells);

    arg1 = cells_colors;
    arg2 = 'flat';
    fac = seq.frames(frameind).cellgeom.faces(temp_cells, :);
    vert = [seq.frames(frameind).cellgeom.nodes(:,2) seq.frames(frameind).cellgeom.nodes(:,1)];            

%     figure(imghandle);
    cellsH = patch('Faces', fac, 'Vertices', vert, ...
        'FaceVertexCData', arg1, 'FaceColor', arg2, ...
        'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
        'AlphaDataMapping', 'none', 'edgecolor', 'none');


%   title(var.title,'interpreter','none');
    particularname = [var.name,'_0',num2str(zeros(1,3-size(num2str(i),2))),num2str(i)];
    particularname(ismember(particularname,' ,.:;!', 'legacy')) = [];
%   regexprep(s,'[^\w'']','')
    bname_sep = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,[var.name,' ',channel_info(chan_num).name],filesep,'sep_tiffs',filesep]; 
    if ~isdir(bname_sep)
        mkdir(bname_sep);
    end
%     pos = [680   408   801   684];
%     set(gcf, 'position', pos);
%     set(gca,'position',[0 0 1 1],'units','normalized')
%     h = gcf;
% 	%%% Normalize the resolution, and pixel size of the output:
%     h.PaperUnits = 'inches';
%     h.PaperPosition = [0 0 5 4];
%     print(h,[bname_sep,particularname, '.tif'],'-dtiff','-r250')
    movie_frame = getframe(gca);
    imwrite(movie_frame.cdata,[bname_sep,particularname, '.tif'], 'Resolution',[2000,2000]);

    
%     saveas(gcf, [bname_sep,particularname, '.tif']);
%     set(gca,'position',[0 0 1 1],'units','normalized');
%   print(gcf, [bname_sep,particularname, '.tif'],'-r',max(size(img))/150);
    set(imghandle,'Visible','off');
    set(cellsH,'Visible','off');
    close(imghandle);
end
    
    
    
bname_sep = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,[var.name,' ',channel_info(chan_num).name],filesep,'sep_tiffs',filesep];
bname = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,[var.name,' ',channel_info(chan_num).name],filesep];
ImageList = dir([bname_sep,'*.tif']);
sname = [bname,dirtxt,'-',var.name, '.avi'];


%t0 file
if isempty(dir([bname,'tzero*']))
    write_shift_info_txt_file(pwd,bname);
    create_dir_name_txt_file(pwd,bname);
end


if isempty(dir([bname,'..',filesep,'tzero*']))
    write_shift_info_txt_file(pwd,[bname,'..',filesep]);
    create_dir_name_txt_file(pwd,[bname,'..',filesep]);
end

ticknums = [0,size(specialcolormap,1)/2,size(specialcolormap,1)];
ticktxt = {num2str(incr_min),'mid',num2str(incr_max)};
rel_ticknums = ticknums./size(specialcolormap,1); 
save_custom_cbar(specialcolormap,rel_ticknums,ticktxt,bname,'cmap');

%AVI = avifile(sname, 'FPS', 1, 'Compression', 'none');
writerObj = VideoWriter(sname);
open(writerObj);
for iImage = 1:length(ImageList)
    aImage = imread([bname_sep,ImageList(iImage).name]);

%AVI = addframe(AVI, aImage);
    writeVideo(writerObj,aImage)
end
close(writerObj);
cd(startdir);
                     
              
                     
% % % % % % 
% % % % % % 
% % %  make polarity correlation image %%% currently not using

function make_pol_correlation_annotation_internal(seq,data,var,pol_file_name,...
                                                  cells,dirtxt,...
                                                  container_dir)

if nargin < 7 || isempty(container_dir) 
        dir_str_inds = strfind(pwd,filesep);
        currdir = pwd;
        container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
end
        
clear('channel_info','options');    
startdir = pwd;
load(pol_file_name,'channel_info','options');
startdir = pwd;
cd([pwd,filesep,'..',filesep,'scripts',filesep,]);
script_for_values_along_edges_cell_back;
cd(startdir);



polarityfiletype = 0;
if ~isempty(dir('edges_info_cell_background*'))
    load edges_info_cell_background channel_info
    
    polarityfiletype = 1;
else if ~isempty(dir('edges_info_max_proj_single_given*'))
        load edges_info_max_proj_single_given channel_info 
        polarityfiletype = 2;
    else
        display('no polarity file found');
    end
        
end
    
    

    chan_txt_list = {channel_info(1).name};
    if length(channel_info)>1
        for i = 2:length(channel_info)
            chan_txt_list = {chan_txt_list{:},channel_info(i).name};
        end
    end
    
    data = seq2data(seq);
	num_frames = length(seq.frames);
    cells = find(any(data.cells.selected));
    
    if length(channel_info)~=2
        display('need exactly two channels for correlation analysis');
        return
    end
    
    switch polarityfiletype
        
        case 1 %movie type
            pol_cells_one = channel_info(1).cells.polarity;
            pol_cells_two = channel_info(2).cells.polarity;
            pol_cells_one = interp_pol(pol_cells_one);
            pol_cells_two = interp_pol(pol_cells_two);
            
        case 2 %still type
            pol_cells_one = channel_info(1).cells.polarity;
            pol_cells_two = channel_info(2).cells.polarity;
    end
    
    local_cells = nan(size(pol_cells_one));
    for i = 1:num_frames
        local_cells(i,:) = seq.cells_map(i,cells(:));
    end

load shift_info
load timestep
timetake = min(max(1,-shift_info)+ceil(60/timestep*5),length(seq.frames));
chanone_ref_val = mean(pol_cells_one(timetake,data.cells.selected(timetake,cells)));
chantwo_ref_val = mean(pol_cells_two(timetake,data.cells.selected(timetake,cells)));
    
combined_pol = (pol_cells_one./chanone_ref_val + pol_cells_two./chantwo_ref_val)/2;
combined_ref = (abs(chanone_ref_val)+abs(chantwo_ref_val))/2;

coef = corrcoef(pol_cells_one(timetake,data.cells.selected(timetake,cells)),...
pol_cells_two(timetake,data.cells.selected(timetake,cells)));
coef = coef(2);
coefsign = sign(coef);



for i = 1:num_frames
    pos_inds = find(local_cells(i,:));
    incrvals = [-20,-combined_ref:.05:combined_ref,20];
    specialcolormap = bipolar(length(incrvals), 0.1);
    
    
    pol_cells = combined_pol/combined_ref;
    tempcellpols = pol_cells(i, pos_inds);
    temp_pol_inds = ~isnan(tempcellpols);
    [n,bin] = histc(tempcellpols(temp_pol_inds),incrvals);
    bin(bin==0) = floor(length(incrvals)/2);
    
    
    tempcellpols_one = pol_cells_one(i, pos_inds);
    tempcellpols_two = pol_cells_two(i, pos_inds);
  
    corrterms = single_contributions_to_correlation(tempcellpols_one,tempcellpols_two);
    corrterms = corrterms*numel(corrterms);

    
    
    cell_passed_thru = pos_inds(temp_pol_inds);
    cell_did_not_pass = pos_inds(~temp_pol_inds);
    
    cellcolors = specialcolormap(bin,:);
    

    
        

    corrsigns = sign(corrterms);
    corrmods = log(abs(corrterms)+1).*corrsigns;
    tempcols = zeros(length(corrmods),3);
    tempcols(:,2) = min(max(-corrmods,0),1);
    tempcols(:,3) = min(max(corrmods,0),1);
    tempcolwhitened = zeros(length(corrmods),3);
    for col_ind = 1:length(corrmods)
        tempcolwhitened(col_ind,:) = interp1([0 1], [1 1 1; tempcols(col_ind,:)], min(max(abs(corrmods(col_ind)),0),1));
    end

    
    minalpha = 0.2;

    seq.frames(i).cells_colors(local_cells(i,cell_passed_thru), :) = tempcolwhitened;
    seq.frames(i).cells_colors(local_cells(i,cell_did_not_pass), :) = repmat([0.1 0.1 0.1],length(cell_did_not_pass),1);
    
    seq.frames(i).cells_alphas(local_cells(i,cell_passed_thru), :) = 0.5;
    seq.frames(i).cells_alphas(local_cells(i,cell_did_not_pass), :) = minalpha; 
    
    
        switch polarityfiletype
        
            case 1
                templocals = local_cells(i,cell_passed_thru);
                seq.frames(i).cells = templocals(data.cells.selected(i,cells(cell_passed_thru)));
            case 2
                passanddidnt = [cell_did_not_pass,cell_passed_thru];
                templocals = local_cells(i,passanddidnt);
                seq.frames(i).cells = templocals(data.cells.selected(i,cells(passanddidnt)));
        end
        
end

            global load_only_filenames;
            load_only_filenames = true;

          %     use the polarity image
            startfile_one = channel_info(1).filename;
            startfile_two = channel_info(2).filename;
            run([pwd,filesep,'..',filesep,'scripts',filesep,'script_for_values_along_edges_cell_back.m']);
            startfile = seg_filename;
%             [z_num, t_num, t_ind] = get_file_nums_dlf(startfile)
            [justfile justdirpath] = get_filename_from_fullpath(startfile);
            outfilenames = get_img_file_for_pol_calcs(options,seq,startfile);
            
            chansettingsfilename = 'channel_image_settings.txt';
            if isempty(dir([justdirpath,filesep,chansettingsfilename]))
                startdir = pwd;
                cd(justdirpath);
                channel_image_options_script;
                cd(startdir);
            end

    
                    [a b] = textread([justdirpath,filesep,chansettingsfilename], ...
                     '%s = %s', 'commentstyle', 'matlab');
                    for i = 1:length(b)
                        eval([a{i} ' = ' b{i} ';'])
                    end
                    
                    
%             if there is an empty chan options file, then rewrite it        
            if isempty(a) || isempty(b)
                startdir = pwd;
                cd(justdirpath);
                channel_image_options_script;
                cd(startdir);
                
                
                
                [a b] = textread([justdirpath,filesep,chansettingsfilename], ...
                     '%s = %s', 'commentstyle', 'matlab');
                    for i = 1:length(b)
                        eval([a{i} ' = ' b{i} ';'])
                    end
            end    
            
            

                    
        
    
    for i = 1:length(seq.frames)
        
        if nargin < 5 || isempty(cells)
            l_cells = nonzeros(seq.cells_map(i, data.cells.selected(i, :)));
            takers = true(1,length(l_cells));
            seq.frames(i).cells = l_cells;
        else
            
            takers = logical(data.cells.selected(i,cells))&logical(seq.cells_map(i,cells)~=0);
            tempcells = cells(takers);
            seq.frames(i).cells  = nonzeros(seq.cells_map(i,tempcells));
            
        end
        


            


    
            frameind = i;
            imgfilename = seq.frames(frameind).img_file;
%             imgfilename = outfilenames{i};
            
            directory = pwd;
            if length(dir(fullfile(directory, seq.bnr_dir, imgfilename)))
                imgfilename = fullfile(directory, seq.bnr_dir, imgfilename);
            end
            
            img = double(imread(imgfilename));
            img = uint8((img - shift_factor)*brightness_factor*1.2);
            imghandle = figure;
            set(imghandle,'Visible','off'); 
%             figure; 
            colormap(gray(256));
%             a = img;
%             a = (a ./ max(max(a)))*255;
%             a = uint8(round(a));
%             a = imadjust(a, stretchlim(a(a>0)), [0, 1]);
            image(img);
            axis off;
            hold on
            
            ax = gca;
            set(ax, 'units', 'pixels')
            pos = get(ax, 'position');
            pos = round(pos);
            pos([4 3]) = [size(img,1),size(img,2)];
            set(ax, 'position', pos);

            temp_cells = seq.frames(frameind).cells;
            cells_colors = seq.frames(frameind).cells_colors(seq.frames(frameind).cells,:);
            alphas = seq.frames(frameind).cells_alphas(seq.frames(frameind).cells);
            

            arg1 = cells_colors;
            arg2 = 'flat';

            fac = seq.frames(frameind).cellgeom.faces(temp_cells, :);
            vert = [seq.frames(frameind).cellgeom.nodes(:,2) seq.frames(frameind).cellgeom.nodes(:,1)];            

            
            cellsH = patch('Faces', fac, 'Vertices', vert, ...
                'FaceVertexCData', arg1, 'FaceColor', arg2, ...
                'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
                'AlphaDataMapping', 'none', 'edgecolor', 'none');
            
            
%                title(var.title,'interpreter','none');
                particularname = [var.name,'_0',num2str(zeros(1,3-size(num2str(i),2))),num2str(i)];
                particularname(ismember(particularname,' ,.:;!', 'legacy')) = [];
%                 regexprep(s,'[^\w'']','')
                bname_sep = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,[var.name],filesep,'sep_tiffs',filesep]; 
                if ~isdir(bname_sep)
                    mkdir(bname_sep);
                end
                
                pos = [680   408   801   684];

                set(gca,'position',[0 0 1 1],'units','normalized')
                h = gcf;
                %%% Normalize the resolution, and pixel size of the output:
                h.PaperUnits = 'inches';
                h.PaperPosition = [0 0 5 4];
%                 print(h,[bname_sep,particularname, '.tif'],'-dtiff','-r250')
                movie_frame = getframe(gca);
                imwrite(movie_frame.cdata,[bname_sep,particularname, '.tif'], 'Resolution',[2000,2000]);
    
%                 saveas(gcf, [bname_sep,particularname, '.tif']);
                set(gca,'position',[0 0 1 1],'units','normalized')
%                 print(gcf, [bname_sep,particularname, '.tif'],'-r',max(size(img))/150);

                
                set(imghandle,'Visible','off');
                set(cellsH,'Visible','off');
               
                close(imghandle);
                
               
                

                
    end
    
    
    
                    bname_sep = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,[var.name],filesep,'sep_tiffs',filesep];
                    bname = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,[var.name],filesep];
                    ImageList = dir([bname_sep,'*.tif']);
                    sname = [bname,dirtxt,'-',var.name, '.avi'];
    %                 AVI = avifile(sname, 'FPS', 1, 'Compression', 'none');
                    writerObj = VideoWriter(sname);
                    open(writerObj);
                    for iImage = 1:length(ImageList)
                        aImage = imread([bname_sep,ImageList(iImage).name]);

    %                     AVI = addframe(AVI, aImage);
                        writeVideo(writerObj,aImage)
                    end
                    close(writerObj);
                    
                    
                     cd(startdir);           
                     
                     
                     
function cmap_out =get_cmap_from_db_with_name(cmap_name,zlab_cmaps)
    ind = find(strcmp(cmap_name,{zlab_cmaps(:).name}));
    if isempty(ind)
        display(['cmap named ''',cmap_name{:},''' was not found in cmap database']);
%         ind = find(strcmp({[cmap_name{:},'*']},{zlab_cmaps(:).name}),1);
        str = {zlab_cmaps(:).name};
        expression = [cmap_name{:},'*'];
        matchStr = regexp(str,expression,'match');
        ind = find(~cellfun(@isempty,matchStr),1);
        
        if isempty(ind)
            matchStr = regexpi(str,expression,'match');
            ind = find(~cellfun(@isempty,matchStr),1);
        end
        
        if ~isempty(ind)
            display(['using first match: ''',zlab_cmaps(ind).name,'''']);
        else
            display('no match found, quitting');
            return
        end
    end
    cmap_out = zlab_cmaps(ind);
                
            
	
function make_clusters_annotation_internal(seq,data,var,...
                                           clusters,cells,...
                                           container_dir)
                                       
if nargin < 6 || isempty(container_dir) 
        dir_str_inds = strfind(pwd,filesep);
        currdir = pwd;
        container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
end
        
startdir = pwd;
for i = 1:length(seq.frames)

    if nargin < 5 || isempty(cells)
        seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    else
        tmp_glob_cells = logical(cells.*data.cells.selected(i,:));
        seq.frames(i).cells  = nonzeros(seq.cells_map(i,tmp_glob_cells));
    end
    
    ind_t1 = false(size(clusters));
    ind_ros = ind_t1;
    for ci = 1:length(ind_t1);
        if length(clusters(ci).cells) >= var.min
            ind_ros(ci) = true;
        else
            ind_t1(ci) = true;
        end
    end
    partiality = 2; %total inclusion
    seq = color_by_clusters(seq, clusters, ind_ros, data, partiality);
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    frameind = i;
    imgfilename = seq.frames(frameind).img_file;
    img = imread(imgfilename);
    imghandle = figure;
    set(imghandle,'Visible','off'); 

    colormap('gray');
    imagesc(img);
    axis off;
    hold on
    
    ax = gca;
    set(ax, 'units', 'pixels')
    pos = get(ax, 'position');
    pos = round(pos);
    pos = [0,0, size(img,1),size(img,2)];
    set(ax, 'position', [2, 2, pos(4), pos(3)]);
    set(gcf, 'position', [1, 1, pos(4)+2, pos(3)+2]);
    
    temp_cells = seq.frames(frameind).cells;
    cells_colors = seq.frames(frameind).cells_colors(seq.frames(frameind).cells,:);
    alphas = seq.frames(frameind).cells_alphas(seq.frames(frameind).cells);


    arg1 = cells_colors;
    arg2 = 'flat';

    fac = seq.frames(frameind).cellgeom.faces(temp_cells, :);
    vert = [seq.frames(frameind).cellgeom.nodes(:,2) seq.frames(frameind).cellgeom.nodes(:,1)];            


    cellsH = patch('Faces', fac, 'Vertices', vert, ...
        'FaceVertexCData', arg1, 'FaceColor', arg2, ...
        'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
        'AlphaDataMapping', 'none', 'edgecolor', 'none');
            
    title(var.title,'interpreter','none');
    particularname = [var.name,'_0',num2str(zeros(1,3-size(num2str(i),2))),num2str(i)];
    particularname(ismember(particularname,' ,.:;!', 'legacy')) = [];
%                 regexprep(s,'[^\w'']','')
    bname_sep = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,var.name,filesep,'sep_tiffs',filesep]; 
    if ~isdir(bname_sep)
        mkdir(bname_sep);
    end
%     pos = [680   408   801   684];
%     set(gcf, 'position', pos);
%     set(gca,'position',[0 0 1 1],'units','normalized')
%     h = gcf;
%     %%% Normalize the resolution, and pixel size of the output:
%     h.PaperUnits = 'inches';
%     h.PaperPosition = [0 0 5 4];
%     print(h,[bname_sep,particularname, '.tif'],'-dtiff','-r250')
    movie_frame = getframe(gca);
    imwrite(movie_frame.cdata,[bname_sep,particularname, '.tif'], 'Resolution',[2000,2000]);

    
%     saveas(gcf, [bname_sep,particularname, '.tif']);
    set(imghandle,'Visible','off');
    set(cellsH,'Visible','off');
    close(imghandle);
end
    


bname = [pwd,filesep,'..',filesep,container_dir,'_annotations',filesep,var.name,filesep];
if ~isdir(bname)
    mkdir(bname);
end

% t0 file
if isempty(dir([bname,'tzero*']))
        write_shift_info_txt_file(pwd,bname);
        create_dir_name_txt_file(pwd,bname);
end

if isempty(dir([bname,'..',filesep,'tzero*']))
        write_shift_info_txt_file(pwd,[bname,'..',filesep]);
        create_dir_name_txt_file(pwd,[bname,'..',filesep]);
end


ImageList = dir([bname_sep,'*.tif']);
sname = [bname,var.name, '.avi'];
%AVI = avifile(sname, 'FPS', 1, 'Compression', 'none');
writerObj = VideoWriter(sname);
open(writerObj);
for iImage = 1:length(ImageList)
    aImage = imread([bname_sep,ImageList(iImage).name]);
%   AVI = addframe(AVI, aImage);
    writeVideo(writerObj,aImage)
end
close(writerObj);
cd(startdir);
