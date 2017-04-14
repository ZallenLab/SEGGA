function make_and_save_single_pol_img(seq, cells, cell_pol, img_save_str,output_dir)

if nargin < 5 || isempty(output_dir)
    output_dir = [pwd,filesep,'analysis_charts',filesep];
end

imgfilename = seq.frames(1).img_file;                 
img = imread(imgfilename);
imgH1 = figure;

colormap(gray);
imagesc(imread(imgfilename));
hold on

frameind = 1;


cells_colors = seq.frames(1).cells_colors;
cells_alphas = seq.frames(1).cells_alphas;
cells_colors = cells_colors(nonzeros(cells),:);
alphas = cells_alphas(nonzeros(cells))';



if length(nonzeros(cells)) == 1
    arg1 = [];
    arg2 = cells_colors;
else
    arg1 = cells_colors;
    arg2 = 'flat';
end

fac = seq.frames(frameind).cellgeom.faces(nonzeros(cells), :);
vert = [seq.frames(frameind).cellgeom.nodes(:,2) seq.frames(frameind).cellgeom.nodes(:,1)];

%             fac = flipud(fac);
%             vert = flipud(vert);

cellsH = patch('Faces', fac, 'Vertices', vert, ...
    'FaceVertexCData', arg1, 'FaceColor', arg2, ...
    'facealpha', 'flat', 'FaceVertexAlphaData', alphas, ...
    'AlphaDataMapping', 'none', 'edgecolor', 'none');
axis off


particularbname = ['polarity-image-',img_save_str];
% bname = [pwd,filesep,particularbname];   
bname = [output_dir,filesep,particularbname];
% pos = [680   408   801   684];
% set(gcf, 'position', pos);


ax = gca;
set(ax, 'units', 'pixels')
pos = get(ax, 'position');
pos = round(pos);
pos = [0,0, size(img,1),size(img,2)];
set(ax, 'position', [1, 1, pos(4), pos(3)]);
set(gcf, 'position', [0, 0, pos(4)+2, pos(3)+2]);

fix_2016a_figure_output(gcf);
% saveas(gcf, [bname '.fig']);
% saveas(gcf, [bname '.pdf']);
% saveas(gcf, [bname '.tif']); %%% automatically transforming aspect ratio
movie_frame = getframe(gca);
imwrite(movie_frame.cdata,[bname, '.tif'], 'Resolution',[2000,2000]);
close(imgH1);


imgH2 = figure;
hist(cell_pol(frameind,:));
set(gca,'xlim',[-1.5,1.5]);

myylim = get(gca,'ylim');
originalymax = 400;
ratioymax = myylim(2)/originalymax;

myxlim = get(gca,'xlim');
xstart = myxlim(1) + (myxlim(2) - myxlim(1))/10;

title('Polarity Hist');
xlabel('Polarity Value (Log2)');
ylabel('Number of Cells');
hold on
h_t1 = text(xstart,375*ratioymax,['mean val : ',num2str(mean(cell_pol(~isnan(cell_pol))))]);
h_t1.FontWeight='bold';
dir_str_inds = strfind(pwd,filesep);
currdir = pwd;
container_dir = currdir((dir_str_inds(end-1)+1):(dir_str_inds(end)-1));
text(xstart,350*ratioymax,container_dir,'interpreter','none','Color',[0 1 0],'FontWeight','bold');


particularbname = ['histogram-',img_save_str];
% bname = [pwd,filesep,particularbname];
bname = [output_dir,filesep,particularbname];
pos = [680   408   801   684];
set(gcf, 'position', pos);
fix_2016a_figure_output(gcf);
% saveas(gcf, [bname '.fig']);
% saveas(gcf, [bname '.pdf']);
saveas(gcf, [bname '.tif']);
close(imgH2);