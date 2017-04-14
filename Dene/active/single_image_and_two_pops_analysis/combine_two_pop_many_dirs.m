function [outpols_pooled, outpols_means] = combine_two_pop_many_dirs(base_dir_list,color)

startdir = pwd;    
outpols_pooled.one = [];
outpols_pooled.two = [];

outpols_pooled.one_adjusted = [];
outpols_pooled.two_adjusted = [];

outpols_means.one = {};
outpols_means.two = {};
outpols_means.allEdges = {};
outpols_means.vertEdgesNormed = {};
outpols_means.twoOneVertEdgesNormed = {};
outpols_means.oneTwoVertEdgesNormed = {};

binranges = [-3.0:.25:3.0];
hist_perc_list = [];
nameFoldstotal = {};

for baseind = 1:length(base_dir_list)

    cd(base_dir_list{baseind});
    search_dir = pwd;
    d = dir(search_dir);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'}, 'legacy')) = [];
    nameFoldsToAdd = logical(ones(size(nameFolds)));
    
    
    
    colornames = {'*red','*green','*blue'};
    % colornames = {'*blue'};


    for foldind = 1:length(nameFolds)
        mystartdir = pwd;
        cd(nameFolds{foldind});
        homedir = pwd;
%         add_on_analysis_fixed_polarity_image_second;


%             alldirsrun = dir(colornames{colorind});
%             actiondir = alldirsrun(i).name;
%             actiondir = 'red';
              actiondir = color;

                
                if isdir([pwd,filesep,color])&&isdir([pwd,filesep,'two-pop-stats']) ||...
                        isdir([pwd,filesep,color])&&isdir([pwd,filesep,'two-pop-stats-new'])



                    cd(actiondir)
                    display(pwd);
                    data_files = dir('edges_info*');
                    if isempty(data_files)
                        display('missing ''edges_info*'' data file');
                        cd(startdir);
                        return
                    else
                        display(['loading ',data_files(1).name]);
                        load(data_files(1).name);
                    end
                    
                    workdir = [pwd,filesep,'..',filesep,'seg'];                    
                    chan_num = find(strcmp(color,{channel_info(:).name}));
                    if isempty(chan_num)
                        display(['color, ',color,' not found in channel_info']);
                        return
                    end
                    
                    if isempty(dir([workdir,filesep,'two_pop_cells.mat']))
                        display('missing two_pop_cells.mat, skipping dir in combine_two_pop_many_dirs');
                        return
                    end
                    stripe_quants_means = get_mean_stripe_pols(workdir,chan_num);
                    stripe_quants_full = get_full_stripe_pols(workdir, chan_num);
                    stripe_edge_quants = get_mean_stripe_edge_pols(workdir,chan_num);
                    

%                     temppols = get_pols_for_combining(workdir);
%                     tempmean = mean(temppols(~isnan(temppols)));
                    
                    outpols_pooled.one = [outpols_pooled.one(:);stripe_quants_full.pop1_full(:)];
                    outpols_pooled.two = [outpols_pooled.two(:);stripe_quants_full.pop2_full(:)];
                    
                    outpols_pooled.one_adjusted = [outpols_pooled.one_adjusted(:);stripe_quants_full.pop1_full_zero_and_std(:)];
                    outpols_pooled.two_adjusted = [outpols_pooled.two_adjusted(:);stripe_quants_full.pop2_full_zero_and_std(:)];
                    
%                     need to change the others above to the same format
                    outpols_means.one = [outpols_means.one,{stripe_quants_means.pop1_mean}];
                    outpols_means.two = [outpols_means.two,{stripe_quants_means.pop2_mean}];
                    
                    outpols_means.allEdges = [outpols_means.allEdges,{stripe_edge_quants.all_mean}];
                    outpols_means.vertEdgesNormed = [outpols_means.vertEdgesNormed,{stripe_edge_quants.vert_ratio}];
                    outpols_means.twoOneVertEdgesNormed = [outpols_means.twoOneVertEdgesNormed,{stripe_edge_quants.ant_bound_vert_ratio}];
                    outpols_means.oneTwoVertEdgesNormed = [outpols_means.oneTwoVertEdgesNormed,{stripe_edge_quants.post_bound_vert_ratio}];
                    


                    cd(homedir);
                    
                else 
                    
                    nameFoldsToAdd(foldind) = false;
                    outpols_means.one = [outpols_means.one,{nan}];
                    outpols_means.two = [outpols_means.two,{nan}];
                    outpols_means.allEdges = [outpols_means.allEdges,{nan}];
                    outpols_means.vertEdgesNormed = [outpols_means.vertEdgesNormed,{nan}];
                    outpols_means.twoOneVertEdgesNormed = [outpols_means.twoOneVertEdgesNormed,{nan}];
                    outpols_means.oneTwoVertEdgesNormed = [outpols_means.oneTwoVertEdgesNormed,{nan}];
       
                    
                end
                
                
                
           


        cd(mystartdir);
    end
    
    nameFoldstotal = {nameFoldstotal{:},nameFolds{nameFoldsToAdd}};
    

end







function stripe_edge_quants = get_mean_stripe_edge_pols(workdir,chan_num)

    startdir = pwd;
    cd(workdir)
	[~,combined_output_edges] = output_two_pop_analysis(workdir,[],chan_num);
%     maybe comment out, not necessary - line below
%     combined_output_cells = reshape(combined_output_cells,1,size(combined_output_cells,1),size(combined_output_cells,2));
            
%     load([pwd,filesep,'..',filesep,'seg',filesep,'edges_info_max_proj_single_given'],'channel_info');
%     load(['two-pop-stats-',channel_info(chan_num).name],'combined_output_edges');
%          
	if isempty(combined_output_edges)
        display('combined_output_cells is empty, skipping output_two_pop_analysis...');
        stripe_edge_quants = [];
        return
    end

    

    indofallmean = strcmp({combined_output_edges(:).name},'all_edges_stats_mean');
    stripe_edge_quants.all_mean = combined_output_edges(indofallmean).val;
    
    indofvert = strcmp({combined_output_edges(:).name},'all_edges_vert_levels_mean');
    stripe_edge_quants.vert_mean = combined_output_edges(indofvert).val;
    stripe_edge_quants.vert_ratio = str2num(stripe_edge_quants.vert_mean)/str2num(stripe_edge_quants.all_mean);
    stripe_edge_quants.vert_ratio = num2str(stripe_edge_quants.vert_ratio);
    
    indofant_boundary_vert = strcmp({combined_output_edges(:).name},'twoOne_edges_vert_levels_mean');
    stripe_edge_quants.ant_bound_vert = combined_output_edges(indofant_boundary_vert).val;
    stripe_edge_quants.ant_bound_vert_ratio = str2num(stripe_edge_quants.ant_bound_vert)/str2num(stripe_edge_quants.all_mean);
    stripe_edge_quants.ant_bound_vert_ratio = num2str(stripe_edge_quants.ant_bound_vert_ratio);
    
    
    indofpost_boundary_vert = strcmp({combined_output_edges(:).name},'onetwo_edges_vert_levels_mean');
    stripe_edge_quants.post_bound_vert = combined_output_edges(indofpost_boundary_vert).val;
    stripe_edge_quants.post_bound_vert_ratio = str2num(stripe_edge_quants.post_bound_vert)/str2num(stripe_edge_quants.all_mean);
    stripe_edge_quants.post_bound_vert_ratio = num2str(stripe_edge_quants.post_bound_vert_ratio);
    
    cd(startdir);
    

return






% return
% scraps from first attempt
function stripe_quants = get_mean_stripe_pols(workdir,chan_num)

    startdir = pwd;
    cd(workdir)
	[combined_output_cells,~] = output_two_pop_analysis(workdir,[],chan_num);
%     maybe comment out, not necessary - line below
%     combined_output_cells = reshape(combined_output_cells,1,size(combined_output_cells,1),size(combined_output_cells,2));
            
    if isempty(combined_output_cells)
        display('combined_output_cells is empty, skipping get_mean_stripe_pols...');
        stripe_quants.all_mean = [];
        stripe_quants.pop1_mean = [];
        stripe_quants.pop2_mean = [];
        return
    end
    
    indofallmean = find(strcmp({combined_output_cells(:).name},'all_pol_mean'));
    stripe_quants.all_mean = combined_output_cells(indofallmean).val;
    
    indofOnemean = find(strcmp({combined_output_cells(:).name},'pop_one_pol_mean'));
    stripe_quants.pop1_mean = combined_output_cells(indofOnemean).val;
    
    indofTwomean = find(strcmp({combined_output_cells(:).name},'pop_two_pol_mean'));
    stripe_quants.pop2_mean = combined_output_cells(indofTwomean).val;
    
    cd(startdir);
    

return

alltypes = unique(type_list);
numtypes = length(alltypes);

colorlist = {   [1 0 0];...
                [0 1 0];...
                [0 1 1]...
                };
            
pointsize = 0.5;

figure;
hold on;
for ii = 1:numtypes
    current_type = alltypes(i);
    takers = strcmp({agg_quants(:).type},current_type);
    temp_allmeans =  agg_quants(takers).all_mean;
    temp_OneMeans =  agg_quants(takers).pop1_mean;
    temp_TwoMeans =  agg_quants(takers).all_mean;
    xvals = rand(sum(takers),1)+ii*2;
    temp_colors = reshape(colorlist(3,:),3,sum(takers));
    scatter(xvals,temp_allmeans,pointsize,'color');
end



function stripe_quants = get_full_stripe_pols(workdir, chan_num)


    startdir = pwd;

% type_list = [];
% agg_quants.type = type_list;
% agg_quants.all_mean = [];
% agg_quants.pop1_mean = [];
% agg_quants.pop2_mean = [];

    cd(workdir);
    full_combined_output_cells = fulllength_output_two_pop_analysis(workdir,[],chan_num);
% 	full_combined_output_cells = reshape(full_combined_output_cells,1,size(full_combined_output_cells,1),size(full_combined_output_cells,2));
     
	if isempty(full_combined_output_cells)
        display('full_combined_output_cells is empty, skipping get_full_stripe_pols...');
        stripe_quants.all_full = [];
        stripe_quants.pop1_full = [];
        stripe_quants.pop2_full = [];
        return
    end
    
    indofallfull = find(strcmp({full_combined_output_cells(:).name},'all_pol_full'));
    stripe_quants.all_full = full_combined_output_cells(indofallfull).val;
    
    indofOnefull = find(strcmp({full_combined_output_cells(:).name},'pop_one_pol_full'));
    stripe_quants.pop1_full = full_combined_output_cells(indofOnefull).val;
    
    indofTwofull = find(strcmp({full_combined_output_cells(:).name},'pop_two_pol_full'));
    stripe_quants.pop2_full = full_combined_output_cells(indofTwofull).val;
    

    indofallfull_zero_and_std = find(strcmp({full_combined_output_cells(:).name},'all_pol_full_zero_shift_and_std_divided'));
    stripe_quants.all_full_zero_and_std = full_combined_output_cells(indofallfull_zero_and_std).val;
    
    indofOnefull_zero_and_std = find(strcmp({full_combined_output_cells(:).name},'pop_one_pol_full_zero_shift_and_std_divided'));
    stripe_quants.pop1_full_zero_and_std = full_combined_output_cells(indofOnefull_zero_and_std).val;
    
    indofTwofull_zero_and_std = find(strcmp({full_combined_output_cells(:).name},'pop_two_pol_full_zero_shift_and_std_divided'));
    stripe_quants.pop2_full_zero_and_std = full_combined_output_cells(indofTwofull_zero_and_std).val;
    
    cd(startdir);
    