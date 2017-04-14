function split_stacks_all_subfolds(split_base_dir, rm_all_tog_bool)

if nargin <2 || isempty(rm_all_tog_bool)
    rm_all_tog_bool = false;
end


f = dir(split_base_dir);
sf = f(logical([f.isdir]) & ~ismember({f.name},{'.','..'}));
if isempty(sf)
    display('no subdirs found');
    return
end
for i = 1:length(sf)
    action_dir = [split_base_dir,filesep,sf(i).name];
    cd(action_dir);
    try        
        src = [action_dir,filesep,'all_layers_together'];
        src_has_tifs = ~isempty(dir([src,filesep,'*.tif']));
        src_has_tifs = src_has_tifs || ~isempty(dir([src,filesep,'*.TIF']));
        src_has_tifs = src_has_tifs || ~isempty(dir([src,filesep,'*.tiff']));
        src_has_tifs = src_has_tifs || ~isempty(dir([src,filesep,'*.TIFF']));
        if src_has_tifs
            dest = [action_dir,filesep,'all_layers_sep'];
            mkdir(dest);
            convert_exp_images_dir_dlf(src,dest);
            if rm_all_tog_bool
                delete(rmdir(src));
            end
        else
            display(['no tifs in dir (',src,')']);
        end
    catch
        display('could not perform tif stack splitting on dir:');
        display(['  ',pwd,'  ']);
    end
end