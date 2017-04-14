function subdirname = getsubdirname(indir)

filesep_inds = strfind(indir,filesep);
last_ind = filesep_inds(end);
subdirname = indir((last_ind+1):end);