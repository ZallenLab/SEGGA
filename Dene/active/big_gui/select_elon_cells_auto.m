function select_elon_cells_auto(indir,seq,data)
if nargin < 1 || isempty(indir)
    indir = pwd;
end

startdir = pwd;
cd(indir);

start_frame = 1;
numframes_track = 80;

if nargin <2 || isempty(seq)
    if ~isempty(dir('poly_seq.mat'))
        seq = load_dir(pwd);
    else
        display('missing poly_seq.mat');
        return
    end
end
if nargin <3 || isempty(data)
    data = seq2data(seq);
end

firstframe_selcells = logical(data.cells.selected(start_frame,:));
cells_tracked_thru = logical(data.cells.area(numframes_track,:)>0) & logical(firstframe_selcells);
auto_cells_for_elon = find(cells_tracked_thru);
cells = auto_cells_for_elon;
datenow = date();
if ~isempty(dir('cells_for_elon.mat'))
    copyfile('cells_for_elon.mat',['cells_for_elon_autobackup',datenow,'.mat']);
end
notes = 'made by select_elon_cells_auto';
save('cells_for_elon','cells','notes');
display('cells_for_elon saved');
    

cd(startdir);