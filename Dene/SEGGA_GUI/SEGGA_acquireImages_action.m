function SEGGA_acquireImages_action(params_from_gui)

% SEGGA_acquireImages Find source files, declare actions to perform
% and then modify them in chosen local directory
% Zallen Lab 2015
% Created by Dene Farrell April 15, 2015



% Folder Names
% source_base = one dir above dir with originals
% destin_base = one dir above dir where new files go
% fold_names = folder in source_base to take (reassigned in dest.)


% batch_source_base = one dir above dir with originals
% batch_destin_base = one dir above dir where new files go
% batch_fold_names = folders in source_base to take (reassigned in dest.)
% batch_on = run with 'batch' settings instead of single movie settings

%Default Parameters
% 1. source_dir = dir with originals
% 2. dest_base = dir where new files go
% 3. sepBool = separate y/n
% 4. maxBool = max proj y/n
% 5. segBool = seg fold y/n
% 6. scriptsBool = script folder y/n
% 7. combinedBool = combo folder y/n
% 8. multi_settingsBool = make multi channel settings file y/n
% 9. colors_cherry = red is cherry y/n
% 10. figsBool = figures folder y/n
% 11. scripts_dir = where polarity analysis scripts are
% 12. rm_all_tog_bool = remove the tif stacks after duplicating separtes
% y/n
% 13. adaptMaxBool = run adaptive max proj (necessary for PIV)
% 14. PIVBool = run PIV
% 15. showPIVelon = get elon info from PIV
% 16. visualize_PIV = show PIV working as it's calculated
% 17. super_smplBool = supersample originals in z dim
% 18. aniso_smthBool = apply anisotropic smoothing to super sampled set
% 19. denoisingBool = apply denoising to whichever  images are most
% processed (origs < supersmpl < smthd)
% 20. transf_origs = transfer originals -> set to zero if you are not
% transfering files, but using this function for something else




sepBool             = params_from_gui.sepBool;
maxBool             = params_from_gui.maxBool;
segBool             = params_from_gui.segBool;
scriptsBool         = params_from_gui.scriptsBool;
combinedBool        = params_from_gui.combinedBool;
multi_settingsBool  = params_from_gui.multi_settingsBool;
colors_cherry       = params_from_gui.colors_cherry;
figsBool            = params_from_gui.figsBool;
copy_settings       = params_from_gui.copy_settings;
pe_volocityBool     = params_from_gui.pe_volocityBool;
scripts_dir         = params_from_gui.scripts_dir;
rm_all_tog_bool     = params_from_gui.rm_all_tog_bool;
adaptMaxBool        = params_from_gui.adaptMaxBool;
PIVBool             = params_from_gui.PIVBool;
showPIVelon         = params_from_gui.showPIVelon;
visualize_PIV       = params_from_gui.visualize_PIV;
super_smplBool      = params_from_gui.super_smplBool;
aniso_smthBool      = params_from_gui.aniso_smthBool;
denoisingBool       = params_from_gui.denoisingBool;
transf_origs        = params_from_gui.transf_origs;
rot_ang             = params_from_gui.rotation_angle;



% IN this GUI the default is to ask the user for source images and destinations
% if they haven't already been specified
if params_from_gui.batch_on
    rot_ang = 0;
	source_base = params_from_gui.batch_source_base;
    destin_base = params_from_gui.batch_destin_base;
    fold_names = params_from_gui.batch_fold_names;
    fold_names_out = params_from_gui.batch_fold_names_out;
else
	source_base = params_from_gui.source_base;
    destin_base = params_from_gui.destin_base;
    fold_names = params_from_gui.fold_names;
    fold_names_out = params_from_gui.fold_names_out;
end

if isempty(source_base) && transf_origs

    % source_base
    h = msgbox('NEXT: Select a File from the Source Directory.');
    uiwait(h);
    pause(0.5);
    [filename, source_dir_ui] = uigetfile( ...
    {'*.TIF','Tagged Image File (*.TIF)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Select a Representative File', ...
    'MultiSelect', 'on');
    if (source_dir_ui==0)
        error('No Source Directory Selected!');
    end

    fold_names = {fliplr(strtok(fliplr(source_dir_ui),filesep))};
    [~,source_base] = strtok(fliplr(source_dir_ui),filesep);
    source_base = fliplr(source_base);


    if ~isdir(source_dir_ui)
        error('The directory %s does not exist', source_dir_ui);
        return
    end
    
end


if isempty(destin_base)

    %destination base directory
    h = msgbox('NEXT: Select the Destination Directory.');
    uiwait(h);
    pause(0.5);

    destin_base = uigetdir(pwd,'Select Base Destination Directory');
    if (destin_base==0)
        error('No Destination Directory Selected!');
    else
    if ~isdir(destin_base)
    error('The directory %s does not exist', destin_base);
    return
    end
    destin_base = [destin_base,filesep];
    end
end

		     
    
for i = 1:length(fold_names)
    if transf_origs
        source_dir = [source_base,filesep,fold_names{i},filesep];
        destin_dir = [destin_base,filesep,fold_names_out{i},filesep];
    else
        source_dir = [];
        destin_dir = destin_base;
    end
    
%   Volocity Files are modified first
%   But I'm leaving this in (new_movie_dir_volocity)
%   just in case it comes in handy at a later time
    if pe_volocityBool
        new_movie_dir_volocity(source_dir,destin_dir,sepBool,maxBool,segBool,scriptsBool,...
            combinedBool,multi_settingsBool,colors_cherry,figsBool,scripts_dir);
    else
        new_movie_dir(source_dir,destin_dir,sepBool,maxBool,segBool,scriptsBool,...
            combinedBool,multi_settingsBool,colors_cherry,figsBool,scripts_dir,...
            rm_all_tog_bool,adaptMaxBool,PIVBool,showPIVelon,...
            visualize_PIV,super_smplBool,aniso_smthBool,denoisingBool,...
            transf_origs,rot_ang);
    end
end


if copy_settings
    cd(destin_base);
    save('settings_used_for_creation');
end

return
