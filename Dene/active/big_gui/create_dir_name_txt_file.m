function create_dir_name_txt_file(refdir,savedir)


    [~, nosegpath] = get_filename_from_fullpath(refdir);
    [movname, nomovepath] = get_filename_from_fullpath(nosegpath);
    [genotypename, ~] = get_filename_from_fullpath(nomovepath);
    
    
    savename = [genotypename,'-',movname];
    fullsavename = [savedir,filesep,savename,'.txt'];
    
    fid = fopen(fullsavename, 'w+');
	fseek(fid,0,'bof');
    txt_to_add = savename;
    fwrite(fid,txt_to_add);
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    txt_to_add = 'this file exists to provide the name of the originating movie directory';
    fwrite(fid,txt_to_add);
    fprintf(fid,'\n');
	txt_to_add = ['full: ',refdir];
    fwrite(fid,txt_to_add);
    fprintf(fid,'\n');
    fclose(fid);
    
    