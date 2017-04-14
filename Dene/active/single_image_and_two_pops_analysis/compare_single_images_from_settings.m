function compare_single_images_from_settings(settings)


% fixed_analysis_script_combine_all
% General Settings
cntrl_ind = 1;
main_base_common = settings.movie_base_dir;
legendtxt = settings.labels;
fig_name_str = 'averaged-hists';
color_to_take = 'red';
clear('grouped_hists_list');
special_savename_base = [settings.save_dir,filesep];

% step 10-12 analyze all chans
chans = {'red','green','blue'};
for i = 1:length(chans);    
    local_analyze_channel(chans{i},settings,legendtxt,...
                      special_savename_base,cntrl_ind,...
                      fig_name_str)
end

return

%%%% Delete the unused code later if no issues arise (2016-Dec-22)
%%%% Careful not to delete active subfunctions (local_analyze_channel) 
%%%% defined below

for ii = 1:length(settings.groups)
        
        clear('csvcell');
        list_of_dirs = {};
        for j = 1:length(settings.groups(ii).dirs)
%             list_of_dirs = {list_of_dirs{:},[settings.movie_base_dir,filesep,settings.dirnames{settings.groups(ii).dirs(j)}]};
            list_of_dirs = {list_of_dirs{:},[settings.fullpath_dirnames{settings.groups(ii).dirs(j)}]};
        end   
        
        [grouped_hists_list(ii).outpols_pooled,...
        grouped_hists_list(ii).hist_perc_list,...
        grouped_hists_list(ii).binranges,...
        grouped_hists_list(ii).outpols_means,...
        grouped_hists_list(ii).nameFolds,...
        grouped_hists_list(ii).numcells]...
        = combine_pols_of_many_dirs(list_of_dirs,color_to_take);
    
    
        [grouped_situ_list(ii).outpols_pooled,...
        grouped_situ_list(ii).outpols_means...
        ]...
         = combine_two_pop_many_dirs(list_of_dirs,color_to_take);
    
    
    ysize = length(grouped_hists_list(ii).nameFolds);
        csvcell{1,1} = 'name';
        csvcell{1,2} = 'mean-pol';
        csvcell{1,3} = 'num-cells';
        csvcell{1,4} = 'mean-pop-one-pol';
        csvcell{1,5} = 'mean-pop-two-pol';
        csvcell{1,6} = 'mean-all-edges';
        csvcell{1,7} = 'vert-edges-normd';
        csvcell{1,8} = 'ant-vert-edges-normd';
        csvcell{1,9} = 'post-vert-edges-normd';
        
    
    for nameind = 1:ysize

        if isempty(grouped_hists_list(ii).outpols_means)
            continue
        end
        csvcell{nameind+1,1} = grouped_hists_list(ii).nameFolds{nameind};
        csvcell{nameind+1,2} = grouped_hists_list(ii).outpols_means(nameind);
        csvcell{nameind+1,3} = grouped_hists_list(ii).numcells(nameind);
        
        if ~isempty(grouped_situ_list(ii).outpols_means.one)
            csvcell{nameind+1,4} = grouped_situ_list(ii).outpols_means.one{nameind};
            csvcell{nameind+1,5} = grouped_situ_list(ii).outpols_means.two{nameind};
            csvcell{nameind+1,6} = grouped_situ_list(ii).outpols_means.allEdges{nameind};
            csvcell{nameind+1,7} = grouped_situ_list(ii).outpols_means.vertEdgesNormed{nameind};
            csvcell{nameind+1,8} = grouped_situ_list(ii).outpols_means.twoOneVertEdgesNormed{nameind};
            csvcell{nameind+1,9} = grouped_situ_list(ii).outpols_means.oneTwoVertEdgesNormed{nameind};
            
        else            
            display([' missing 2 pop: ',pwd]);
        end
        
    end
    special_savename = [special_savename_base,legendtxt{ii},color_to_take,'-','alldata.csv'];
    write_to_csv_custom(csvcell',special_savename)

end




binranges = grouped_hists_list(1).binranges;
savedir = [special_savename_base,filesep,'dists-red',filesep];

for i = 1:length(settings.groups)
     if i~=cntrl_ind
        fig_name_str_special = [fig_name_str,'-',legendtxt{i}];
        
        takerslist = zeros(1,length(settings.groups));
        takerslist(cntrl_ind) = 1;
        takerslist(i) = 1;
        takerslist = logical(takerslist);
        temphists = grouped_hists_list(takerslist);
        
        indnumsspecial = sort([cntrl_ind,i]);
        legendtxtspecial = {legendtxt{indnumsspecial}};
        
        if isempty([temphists(:).outpols_means])
            display('data empty for red chan');
        else
            multiple_barcharts_red(temphists,binranges,legendtxtspecial,fig_name_str_special,savedir,indnumsspecial)
        end
     end
end




% step 11. do it for green

% grouped_hists_list  = []
clear('grouped_hists_list');
color_to_take = 'green';
for ii = 1:length(settings.groups)
        
        clear('csvcell');
        list_of_dirs = {};
        for j = 1:length(settings.groups(ii).dirs)
%            list_of_dirs = {list_of_dirs{:},[settings.movie_base_dir,filesep,settings.dirnames{settings.groups(ii).dirs(j)}]};
            list_of_dirs = {list_of_dirs{:},settings.fullpath_dirnames{settings.groups(ii).dirs(j)}};
        end
    
        [grouped_hists_list(ii).outpols_pooled,...
        grouped_hists_list(ii).hist_perc_list,...
        grouped_hists_list(ii).binranges,...
        grouped_hists_list(ii).outpols_means,...
        grouped_hists_list(ii).nameFolds,...
        grouped_hists_list(ii).numcells]...
        = combine_pols_of_many_dirs(list_of_dirs,color_to_take);
    
    
        [   grouped_situ_list(ii).outpols_pooled,...
        grouped_situ_list(ii).outpols_means...
        ]...
         = combine_two_pop_many_dirs(list_of_dirs,color_to_take);
    
    
    ysize = length(grouped_hists_list(ii).nameFolds);
        csvcell{1,1} = 'name';
        csvcell{1,2} = 'mean-pol';
        csvcell{1,3} = 'num-cells';
        csvcell{1,4} = 'mean-pop-one-pol';
        csvcell{1,5} = 'mean-pop-two-pol';
        csvcell{1,6} = 'mean-all-edges';
        csvcell{1,7} = 'vert-edges-normd';
        csvcell{1,8} = 'ant-vert-edges-normd';
        csvcell{1,9} = 'post-vert-edges-normd';
        
   
    
    for nameind = 1:ysize

        
        csvcell{nameind+1,1} = grouped_hists_list(ii).nameFolds{nameind};
        csvcell{nameind+1,2} = grouped_hists_list(ii).outpols_means(nameind);
        csvcell{nameind+1,3} = grouped_hists_list(ii).numcells(nameind);
        
        if ~isempty(grouped_situ_list(ii).outpols_means.one)
            csvcell{nameind+1,4} = grouped_situ_list(ii).outpols_means.one{nameind};
            csvcell{nameind+1,5} = grouped_situ_list(ii).outpols_means.two{nameind};
            csvcell{nameind+1,6} = grouped_situ_list(ii).outpols_means.allEdges{nameind};
            csvcell{nameind+1,7} = grouped_situ_list(ii).outpols_means.vertEdgesNormed{nameind};
            csvcell{nameind+1,8} = grouped_situ_list(ii).outpols_means.twoOneVertEdgesNormed{nameind};
            csvcell{nameind+1,9} = grouped_situ_list(ii).outpols_means.oneTwoVertEdgesNormed{nameind};
        end
    end
    special_savename = [special_savename_base,legendtxt{ii},color_to_take,'-','alldata.csv'];
    write_to_csv_custom(csvcell',special_savename)

end

% [outpols_pooled, hist_perc_list.separate_bins, binranges]  = combine_pols_of_many_dirs(basedirlist);

binranges = grouped_hists_list(1).binranges;
savedir = [special_savename_base,filesep,'dists-green',filesep];     
    
for i = 1:length(settings.groups)
%     if i~=cntrl_ind
        fig_name_str_special = [fig_name_str,'-',legendtxt{i}];
        
        takerslist = zeros(1,length(settings.groups));
        takerslist(cntrl_ind) = 1;
        takerslist(i) = 1;
        takerslist = logical(takerslist);
        temphists = grouped_hists_list(takerslist);
        
        indnumsspecial = sort([cntrl_ind,i]);
        legendtxtspecial = {legendtxt{indnumsspecial}};
        
        multiple_barcharts_green(temphists,binranges,legendtxtspecial,fig_name_str_special,savedir,indnumsspecial)
%     end
end

% multiple_barcharts_green(grouped_hists_list,binranges,legendtxt,fig_name_str,savedir)


%step 12 analyze the blue channel
local_analyze_channel('blue',settings,legendtxt,...
                      special_savename_base,cntrl_ind,...
                      fig_name_str)


return


function local_analyze_channel(channame,settings,legendtxt,...
                               special_savename_base,cntrl_ind,...
                               fig_name_str)

clear('grouped_hists_list');
for ii = 1:length(settings.groups)        
    clear('csvcell');
    list_of_dirs = {};
    for j = 1:length(settings.groups(ii).dirs)
        list_of_dirs = {list_of_dirs{:},settings.fullpath_dirnames{settings.groups(ii).dirs(j)}};
    end

    [grouped_hists_list(ii).outpols_pooled,...
    grouped_hists_list(ii).hist_perc_list,...
    grouped_hists_list(ii).binranges,...
    grouped_hists_list(ii).outpols_means,...
    grouped_hists_list(ii).nameFolds,...
    grouped_hists_list(ii).numcells]...
    = combine_pols_of_many_dirs(list_of_dirs,channame);

    [grouped_situ_list(ii).outpols_pooled,...
    grouped_situ_list(ii).outpols_means...
    ]...
     = combine_two_pop_many_dirs(list_of_dirs,channame);
        
    ysize = length(grouped_hists_list(ii).nameFolds);
    csvcell{1,1} = 'name';
    csvcell{1,2} = 'mean-pol';
    csvcell{1,3} = 'num-cells';
    csvcell{1,4} = 'mean-pop-one-pol';
    csvcell{1,5} = 'mean-pop-two-pol';
%     csvcell{1,6} = 'mean-all-edges';
%     csvcell{1,7} = 'vert-edges-normd';
%     csvcell{1,8} = 'ant-vert-edges-normd';
%     csvcell{1,9} = 'post-vert-edges-normd';
    
    for nameind = 1:ysize
        if isempty(grouped_hists_list(ii).outpols_pooled)
            continue
        end
        csvcell{nameind+1,1} = grouped_hists_list(ii).nameFolds{nameind};
        csvcell{nameind+1,2} = grouped_hists_list(ii).outpols_means{nameind};
        csvcell{nameind+1,3} = grouped_hists_list(ii).numcells{nameind};
        if ~isempty(grouped_situ_list(ii).outpols_means.one)
            csvcell{nameind+1,4} = grouped_situ_list(ii).outpols_means.one{nameind};
            csvcell{nameind+1,5} = grouped_situ_list(ii).outpols_means.two{nameind};
%             csvcell{nameind+1,6} = grouped_situ_list(ii).outpols_means.allEdges{nameind};
%             csvcell{nameind+1,7} = grouped_situ_list(ii).outpols_means.vertEdgesNormed{nameind};
%             csvcell{nameind+1,8} = grouped_situ_list(ii).outpols_means.twoOneVertEdgesNormed{nameind};
%             csvcell{nameind+1,9} = grouped_situ_list(ii).outpols_means.oneTwoVertEdgesNormed{nameind};
        end
    end
    special_savename = [special_savename_base,legendtxt{ii},channame,'-','alldata.csv'];
    write_to_csv_custom(csvcell',special_savename)

end

%%%% Below Code is for making charts.
%%%% No longer in active use
%%%% Disabling 03-28-2017

% binranges = grouped_hists_list(1).binranges;
% savedir = [special_savename_base,filesep,'dists-',channame,filesep];
% 
% for i = 1:length(settings.groups)
%     if i~=cntrl_ind
%         fig_name_str_special = [fig_name_str,'-',legendtxt{i}];        
%         takerslist = zeros(1,length(settings.groups));
%         takerslist(cntrl_ind) = 1;
%         takerslist(i) = 1;
%         takerslist = logical(takerslist);
%         temphists = grouped_hists_list(takerslist);        
%         indnumsspecial = sort([cntrl_ind,i]);
%         legendtxtspecial = {legendtxt{indnumsspecial}};
%         %%% NOT USING 'indnumsspecial'
%         if ~isempty(vertcat(temphists(:).outpols_pooled))
%             multiple_barcharts(temphists,binranges,legendtxtspecial,...
%                                fig_name_str_special,savedir,channame);
%         end
%     end
% end
