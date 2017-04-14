function check_that_default_settings_files_exist()

% if isdeployed()
%     base_dir = ctfroot();
% end
    
base_dir = fileparts(mfilename('fullpath'));
if ~isdir(base_dir)
    display([base_dir,' not a directory']);
    return
else
    display(['found mfilepath: ',base_dir]);
end

%%% Add to this list for other files that need to be included, but are
%%% missing from deployed application
flist(1).name = [base_dir,filesep,'..',filesep,'general',filesep,'SEGGA_default_cmaps.mat'];
flist(1).gen_fun = 'generate_SEGGA_default_cmaps';

for i = 1:length(flist)    
    if isempty(dir(flist(i).name))
        display(['missing file: ',flist(i).name, ' -- generating file now']);
        eval(flist(i).gen_fun);
    end
end

