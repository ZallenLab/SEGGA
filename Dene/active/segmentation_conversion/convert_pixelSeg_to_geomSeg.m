function convert_pixelSeg_to_geomSeg(homedir,autobool,debugbool,preload_params)
%%% To Do: 
% 1-4 done
% 5. recode 'extract_geometry' so it doesn't use dip image
% should be able to plug it into our own work flow in our segmentation
% process.
% 6. Automatically handle inconsistencies (overlaps and gaps) in
% segmentation.


if (nargin < 4) || isempty(preload_params)
    preload_bool = false;
else
    preload_bool = true;
end

if (nargin < 3) || isempty(debugbool)
    debugbool = false;
end

if (nargin<2)||isempty(autobool)
    autobool = false;
end


%%% DEBUG Code
if debugbool
    db_start_fun();
end

if (nargin <1) || isempty(homedir)
    homedir = pwd;
end

% Use Exisiting Labels
startdir = pwd;
cd(homedir);

if preload_bool
    start_seg = imread(preload_params.start_seg);
    start_img = imread(preload_params.start_img);
    start_img = convert_img_to_uint8(start_img);
    output_dir = preload_params.output_dir;
    output_filename = preload_params.output_filename;
else
    [start_seg,start_img,output_dir] = get_input_output_locs(homedir,autobool);
end

if any(any(start_seg(:))&any(start_img(:))&any(output_dir(:)))
    display('extracting geometry');
else
    display('input output locs incomplete');
    return
end

%%% Convert Pixel Segmentation to Geometry
[nodes, edges, nodecellmap] = extract_geometry(dip_image(start_seg));

%%%just a rough preview
if debugbool
    nodemat = zeros(size(start_seg));
    nodemat(sub2ind(size(start_seg),nodes(:,1),nodes(:,2))) = 1;
    figure; imagesc(nodemat);
    figure; imagesc(start_seg);
end


display('Saving Data');
% imwrite(start_img,[output_dir,filesep,'convgeom_T0001_new_Z0001.tif']);
imwrite(start_img,[output_dir,filesep,output_filename,'.tif']);



startgeom.nodes = nodes;
startgeom.edges = edges;
startgeom.nodecellmap = nodecellmap;
save([output_dir,filesep,'interm_geom.mat'], 'startgeom');

cellgeom = convert_geom(startgeom);
% casename = 'convgeom_T0001_new_Z0001.mat';
% filenames = {'convgeom_T0001_new_Z0001.tif'};
casename = [output_filename,'.mat'];
filenames = {[output_filename,'.tif']};

% save([output_dir,filesep,'convgeom_T0001_new_Z0001.mat'], 'cellgeom','casename','filenames');
save([output_dir,filesep,output_filename,'.mat'], 'cellgeom','casename','filenames');

seg_conv_remove_big_cells(homedir,output_dir,output_filename)


cd(startdir);
return


% % node multiplicity
% [temp_nm sel_nodes] = node_mult(cellgeom);
% nm = temp_nm(sel_nodes);
% figure; hist(nm,2:8);
% mean(nm)

%%%reload info
% nodemat = zeros(size(start_img));
% nodemat(sub2ind(size(start_img),startgeom.nodes(:,1),startgeom.nodes(:,2))) = 1;
% figure; imagesc(nodemat);
% figure; imagesc(start_img);


function geom = convert_geom(geom)
temp = unique(geom.nodecellmap(:, 1), 'legacy');
inv_map(temp) = 1:length(temp);
geom.nodecellmap(:, 1) = inv_map(geom.nodecellmap(:, 1));

[n_c_unique, n_c, dummy2] = unique(geom.nodecellmap(:,1), 'legacy');
n_c_s = [0 n_c(1:end - 1)'];
cell_centers = nan(length(temp) , 2);

for cnt =1:length(temp)
    nmap = geom.nodecellmap((n_c_s(cnt) + 1):n_c(cnt),2);
    cell_centers(cnt, :) = mean(geom.nodes(nmap, :));
end
 
        
%find the phase angle of each node relative to the cell center.
    nodes_vectors = geom.nodes(geom.nodecellmap(:, 2), :)...
        -cell_centers(geom.nodecellmap(:, 1), :);
    angles = atan2(nodes_vectors(:,1), nodes_vectors(:,2));

% sort the nodes cells list according to cell and then according the node 
%phase angle

nodes_cells = sortrows(...
    [double(geom.nodecellmap)...
    -angles], [1 3]);
geom.nodecellmap = nodes_cells(:, 1:2);
geom = fix_geom(geom);



function [start_seg,start_img,output_dir] = get_input_output_locs(homedir,autobool)

start_seg = 0;
start_img = 0;
output_dir = 0;

if isdir('./Segments/') 
    cd('./Segments/');
end

%%%% Get Segmentation file
display('Select Segmentation file');
display('usually, ./Segments/file');
segname = 'Segment_0_000.tif';
if autobool
    if isempty(dir(segname))
        segname = uigetfile({'.tif'},'Select Segmentation file');
    end
else
    segname = uigetfile({'.tif'},'Select Segmentation file');
end

if ~any(segname)
    display('no file selected');
    return
end
start_seg = imread(segname);


%%%% Get Image file
display('Select Background file');
display('usually, ./Outlines/file');
cd(homedir);
outline_name = 'Outline_0_000.tif';
if isdir('./Outlines/')
    cd('./Outlines/');
end

if autobool
    if isempty(dir(outline_name))
        outline_name = uigetfile({'.tif'},'Select Image file');
    end
else
    outline_name = uigetfile({'.tif'},'Select Image file');
end

if ~any(outline_name)
    display('no file selected');
    return
end

start_img = imread(outline_name);
start_img = convert_img_to_uint8(start_img);
cd(homedir);

%%%% Get Output Dir
display('Select Output Dir');
display('usually, ./Conv/');
if autobool
    if ~isdir([homedir,filesep,'Conv']);
        mkdir([homedir,filesep,'Conv']);
    end
    output_dir = ([homedir,filesep,'Conv']);
else
    output_dir = uigetdir([],'Select Output Dir');
end

if (~any(output_dir))||~isdir(output_dir)
    display('no output dir');
    return
end

function db_start_fun()
msgbox('provide directory with seg files');
db_dir = uigetdir();
if isdir(db_dir)
    cd(db_dir);
    start_img = imread('./Outlines/Outline_0_000.tif');
    figure;imagesc(start_img);
    skel = bwmorph(start_img,'skel');
    figure;imagesc(skel);
    label_img = bwlabel(~skel,4);
    figure;imagesc(label_img);
    pause(0.1);
else
    display('db_dir missing/incorrect');
    display('turn off debug or give correct location');
    return
end
