function cmap_out = extern_get_cmap_from_db_with_name(cmap_name,zlab_cmaps)


if nargin < 2 || isempty(zlab_cmaps)
    P = mfilename('fullpath');
    reversestr = fliplr(P);
    [~, justdirpath] = strtok(reversestr,filesep);
    base_dir = fliplr(justdirpath);
    base_dir = [base_dir,filesep,'..',filesep,'general',filesep];
    savename = [base_dir,filesep,'SEGGA_default_cmaps']; 
    fullcmapname = savename;
    
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