function deactivate_tracking_opts(indir,changebackbool)

startdir = pwd;
cd(indir);

if changebackbool
    
    file_to_switch = dir('tracking_options_deact.txt');
    
    if isempty(file_to_switch)
        display('missing tracking_options_deact.txt file');
        return
    else
        copyfile(file_to_switch.name,'tracking_options.txt');
        
    end
    
else
    
    file_to_switch = dir('tracking_options.txt');
    
    if isempty(file_to_switch)
        display('missing tracking_options.txt file');
        return
    else
        copyfile(file_to_switch.name,'tracking_options_deact.txt');
        delete(file_to_switch.name);
        
    end
    
end

cd(startdir);