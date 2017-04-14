declareglobs
cancelled = false;

if batch_mode 
    filename = batch_filename;
    [pathstr, name, ext, versn] = fileparts(filename);
    filename = [name '.mat'];
    pathname = batch_directory;
    highlighting_handles = [];
else
    if never_saved | ~isdir(file_path) | isempty(casename) 
        [filename, pathname] = uiputfile(casename,'Save case file to');
    else
        filename = casename;
        pathname = file_path;
    end
end
if isequal(filename,0)|isequal(pathname,0)
  disp('Case file not saved.')
  cancelled = true;
else
  if exist(fullfile(pathname,filename), 'file') == 2
      delete(fullfile(pathname,filename));
  end
  casename = filename;
  file_path = pathname;
  cd(pathname);
  eval(['save ' sprintf('%c%s%c',39,fullfile(pathname,filename),39) ' -v6' globstring]);
  disp(['Case saved to ', fullfile(pathname,filename)])
  changed=0;
  never_saved=0;
end
  
setuicolors
