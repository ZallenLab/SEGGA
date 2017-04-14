function SEGGA_script_to_get_pvals(input_settings)

% the use of 'all_dirs_separated'
% which gives full paths for each directory 
% makes it possible to use any set of directories,
% not just some set under the same path base dir

control_ind = input_settings.stats_settings.control_ind;
legendtxt = {input_settings.groups(:).label};
% old home dir: [input_settings.movie_base_dir,filesep]                    
all_dirs_separated = give_structured_dir_list(filesep,input_settings.fullpath_dirnames,input_settings.groups);               
ylimcustom = 1;



savedir = [input_settings.save_base_dir,filesep,'stats-and-point-vals',filesep];
if ~isdir(savedir)
    mkdir(savedir);
end
if ~isdir(savedir)
    errordlg('could not create save dir');
    return
end



vars = input_settings.vars;
[vars(:).post_func] = deal(@(x)smoothen(x));

% % the usual vars
% allpossiblevars_nonshrink = {'nghbrs_lost_per_cell',...
%                     't1_per_cell',...
%                     'ros_per_cell',...
%                     'longaxis_elon',...
%                     'cell_hortovert_length'...
%                     };
                
%                    allpossiblevars_shrink =  {
%                     'vert_contract_rate_mean'...
%                     };
                
                 
for varind = 1:length(vars)
    

    controlname = legendtxt{control_ind};

    for t_start = input_settings.stats_settings.t_start
        for t_end = input_settings.stats_settings.t_end


            csvinfo = pvals_for_seg_measurement_to_csv(all_dirs_separated,legendtxt,control_ind,...
        vars(varind),savedir,t_start,t_end, ylimcustom);

            filename_nonames = ['cntrl',controlname,'-',vars(varind).title,'-tend',num2str(t_end),'.csv'];
            fullfilename_nonames = [savedir,filename_nonames];
            writecustomcsv_nonames(csvinfo,fullfilename_nonames)

        end
    end
    
end

