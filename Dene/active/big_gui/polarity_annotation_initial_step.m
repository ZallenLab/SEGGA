function [success, incrvals, pol_cells, polarityfiletype, chan_num] = ...
    polarity_annotation_initial_step(chan_num, pol_cmap_opts)

if nargin < 2 || isempty(pol_cmap_opts)
    pol_cmap_opts.type = 'Adaptive';
    pol_cmap_opts.val = 0;
    pol_cmap_opts.bounds = [];
end



success = false;
incrvals = [];
pol_cells = [];

% polarityfiletype = 0;
if ~isempty(dir('edges_info_cell_background*'))
    load edges_info_cell_background channel_info    
    polarityfiletype = 1;
else if ~isempty(dir('edges_info_max_proj_single_given*'))
        load edges_info_max_proj_single_given channel_info 
        polarityfiletype = 2;
    else
        display('no polarity file found');
        return
    end        
end
        
chan_txt_list = {channel_info(1).name};
if length(channel_info)>1
    for i = 2:length(channel_info)
        chan_txt_list = {chan_txt_list{:},channel_info(i).name};
    end
end

if nargin < 1 || isempty(chan_num)
    global channel_handle
    temp_handle = checkbox_for_tracking(chan_txt_list);
    uiwait(temp_handle.f);
    if exist('channel_handle','var')
        if any(strcmp('checked',fieldnames(channel_handle)))
            display(channel_handle.checked);
        end
    end
    chan_num = channel_handle.checked(:);
end



switch polarityfiletype       
    case 1
        pol_cells = channel_info(chan_num).cells.polarity;
        no_nan_pol = interp_pol(pol_cells);
        pol_cells = no_nan_pol;    
    case 2            
        pol_cells = channel_info(chan_num).cell_pol;
end

switch pol_cmap_opts.type
    case 'Adaptive' % pol_cmap_opts.val = 0;
        if isfield(channel_info(chan_num),'cells')
            tmp_all_cells = channel_info(chan_num).cells.polarity(:);
        elseif isfield(channel_info(chan_num),'cell_pol')
            tmp_all_cells = channel_info(chan_num).cell_pol;    
        else
            display('could not find appropriate field for cell polarities in channel_info data structure');                    
        end

        tmp_all_cells = tmp_all_cells(~isnan(tmp_all_cells));
        pol_mean = mean(tmp_all_cells);
        pol_std = std(tmp_all_cells);
        pol_rad = abs(pol_mean)+2*pol_std;

        display('using adaptive polarity colormap bounds');
        b = [-pol_rad,pol_rad];
        incr_step = diff(b)/100;
        %%% if the magnitude of the value is larger than pol_rad*5 then it's probably
        %%% something weird/wrong - so map it back to the middle (done below)
        incrvals = [-pol_rad*5,b(1):incr_step:b(end),pol_rad*5];
    case 'User Defined' % pol_cmap_opts.val = 1;
        display('using user defined polarity colormap bounds');
        b = pol_cmap_opts.bounds;
        incr_step = diff(b)/100;
        %%% if the value is outside of the user defined range by twice the
        %%% span of the range, then map to the middle just as in the other
        %%% cases.
        far_left = b(1) - 2*diff(b);
        far_right = b(end) + 2*diff(b);
        incrvals = [far_left,b(1):incr_step:b(end),far_right];    

    case 'Hard Coded'
        incrvals_baz = [-20,-1:.05:1,20];
        incrvals_sqh = [-20,-0.6:.05:0.6,20];
        incrvals_rok = [-20,-0.6:.05:0.6,20];    
        if strcmp(channel_info(chan_num).name,'sqh') || strcmp(channel_info(chan_num).name,'shrm')           
            incrvals = incrvals_sqh;
        else if strcmp(channel_info(chan_num).name,'baz')
                incrvals = incrvals_baz;           
                else if strcmp(channel_info(chan_num).name,'rok') || strcmp(channel_info(chan_num).name,'utrophin')...
                            || strcmp(channel_info(chan_num).name,'moe')
                    incrvals = incrvals_rok;
                    else
                        display(['no condition for: ',channel_info(chan_num).name]);
                    end
            end
        end
    otherwise
        display(['unknown cmap bounds option [',pol_cmap_opts.type,']']);
end
        
    
    
success = true;