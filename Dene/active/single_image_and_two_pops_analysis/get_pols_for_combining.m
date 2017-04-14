function outpols = get_pols_for_combining(indir)
outpols = [];
cd(indir)

savename = 'edges_info_max_proj_single_given.mat';

if isempty(dir(savename))
    str_out = ['data file missing (',savename,') in dir: ',pwd];
    cprintf('*red', [str_out,'\n']);
    outpols = [];
    return
end

load(savename);

currdir = pwd;
currdirreverse = currdir(end:-1:1);
[toke, remain] = strtok(currdirreverse,'/');
currcolor = toke(end:-1:1);

colorind = 0;
colorfound = 0;
for i = 1:length(channel_info)
    if strcmp(channel_info(i).color,currcolor)
        colorind = i;
        colorfound = 1;
        continue
    end
end

if ~colorfound
    curr_fname = mfilename;
    display(['ERROR in ---> ',curr_fname]);
    display(['color (',currcolor,') of dir not matched in channel_info data (error)']);
    return
end

outpols = channel_info(colorind).cell_pol(1,:);
outpols = outpols(~isnan(outpols));