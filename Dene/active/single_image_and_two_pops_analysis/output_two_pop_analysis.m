function [combined_output_cells, combined_output_edges] = output_two_pop_analysis(indir,polsavename,chan_num)

combined_output_cells = [];
combined_output_edges = [];

if nargin <1 || isempty(indir)
    indir = pwd;
end

if nargin <2 || isempty(polsavename)
    polsavename = 'edges_info_max_proj_single_given';
end

startdir = pwd;
cd(indir);

% fullpolfilename = dir('edges_info*');
% fullpolfilename = fullpolfilename(1).name;
% load(fullpolfilename);
% 
% chanlist = 1:length(channel_info);

frame_num = 1;

% for chan_num = chanlist

    % chan_num = 1;
%     chan_name = channel_info(chan_num).name;
    load(polsavename);
    %levels_all(frame_num,shared_inds,chan_num)
    if (size(levels_all,1)~=1)
        display('first dimension of ''levels_all'' should be one for single images');
        display(['size of levels_all: ',num2str(size(levels_all))]);
        warndlg({'first dimension of ''levels_all'' should be one for single images';...
                 ['size of levels_all: ',num2str(size(levels_all))]});
    end
    if (size(levels_all,3)<chan_num)
        display(['third dimension of ''levels_all'' less than chan_num (',num2str(chan_num),')']);
        display(['size of levels_all: ',num2str(size(levels_all))]);
        warndlg({['third dimension of ''levels_all'' less than chan_num (',num2str(chan_num),')'];...
                 ['size of levels_all: ',num2str(size(levels_all))];...
                 'Quitting ''output_two_pop_analysis'''});
        return
    end
    seq.directory = pwd;
    if isempty(dir('cells_for_two_pops.mat'))
        display('missing cells_for_two_pops');
        return
    end
    load('cells_for_two_pops');

    % find(pop_two_cells)
    % find(pop_one_cells)

    if size(levels_all,1)>1
        cells_all_full = any(data.cells.selected);
    else
        cells_all_full = data.cells.selected;
    end
    cells_all_linear = find(cells_all_full);

    pop_one_ind = ismember(cells_all_linear,find(pop_one_cells), 'legacy');
    pop_two_ind = ismember(cells_all_linear,find(pop_two_cells), 'legacy');


    % pop_one_pol
    % pop_two_pol
    % all_cells_pol

    all_cells_pol = channel_info(chan_num).cell_pol;

    all_pol.mean = mean(all_cells_pol(frame_num,~isnan(all_cells_pol(frame_num,:))));
    all_pol.std = std(all_cells_pol(frame_num,~isnan(all_cells_pol(frame_num,:))));

    pop_one_pols = all_cells_pol(frame_num,pop_one_ind);
    pop_one_pols = pop_one_pols(~isnan(pop_one_pols));
    pop_one_pol.mean = mean(pop_one_pols);
    pop_one_pol.std = std(pop_one_pols);

    pop_two_pols = all_cells_pol(frame_num,pop_two_ind);
    pop_two_pols = pop_two_pols(~isnan(pop_two_pols));
    pop_two_pol.mean = mean(pop_two_pols);
    pop_two_pol.std = std(pop_two_pols);


    % find all interfaces between groups
    ecm = seq.frames(frame_num).cellgeom.edgecellmap;
    edges_list_pop_one = faster_unique(ecm(ismember(ecm(:, 1), find(pop_one_cells), 'legacy'), 2), length(seq.frames(frame_num).cellgeom.edges));
    edges_list_pop_two = faster_unique(ecm(ismember(ecm(:, 1), find(pop_two_cells), 'legacy'), 2), length(seq.frames(frame_num).cellgeom.edges));
    shared_edges = edges_list_pop_one(ismember(edges_list_pop_one,edges_list_pop_two, 'legacy'));
    

    % edge is between one (anterior) and two (posterior)
    % or edge is between two (anterior) and one (posterior)
    edge_one_on_ant = false(size(shared_edges));

    % shared_edges = seq.inv_edges_map(frame_num,seq.edges_map(frame_num,shared_edges));
    glob_shared_edges = seq.inv_edges_map(frame_num,shared_edges);
    glob_shared_edges = glob_shared_edges(ismember(glob_shared_edges,edges, 'legacy'));
    
    %     only use edges that are in the edges list (selected in the poly)
    shared_edges = shared_edges(ismember(glob_shared_edges,edges, 'legacy'));
    shared_inds = find(ismember(edges,glob_shared_edges, 'legacy'));
    % edges(find(ismember(edges,glob_shared_edges)))
    
    levels_shared = levels_all(frame_num,shared_inds,chan_num);
    shared_edges_stats.mean = mean(levels_shared);
    shared_edges_stats.std = std(levels_shared);

    temp_levels_all = levels_all(frame_num,:,chan_num);
    all_edges_stats.mean = mean(temp_levels_all(~isnan(temp_levels_all)));
    all_edges_stats.std = std(temp_levels_all(~isnan(temp_levels_all)));

    cells_touching_other_pop = faster_unique(ecm(ismember(ecm(:, 2), shared_edges, 'legacy'), 1), length(seq.frames(frame_num).cellgeom.circles));
    pop_one_boundary = cells_touching_other_pop(ismember(cells_touching_other_pop,find(pop_one_cells), 'legacy'));
    pop_two_boundary = cells_touching_other_pop(ismember(cells_touching_other_pop,find(pop_two_cells), 'legacy'));

    pop_one_boundary_anterior_inds = false(size(pop_one_boundary));
    pop_one_boundary_posterior_inds = false(size(pop_one_boundary));

    pop_two_boundary_anterior_inds = false(size(pop_one_boundary));
    pop_two_boundary_posterior_inds = false(size(pop_one_boundary));

    %  remember a cell can be both on the anterior of one stripe 
    %  and the posterior of another if the stripe is only one cell thick

    % just for population one, finding which cells are on which boundary

    for i = 1:length(pop_one_boundary)

        cell_ind = pop_one_boundary(i);

        all_cell_edges = faster_unique(ecm(ismember(ecm(:, 1), cell_ind, 'legacy'), 2), length(seq.frames(frame_num).cellgeom.edges));
        cell_shared_edges = shared_edges(ismember(shared_edges,all_cell_edges, 'legacy'));
        boundary_otherpopcells = faster_unique(ecm(ismember(ecm(:, 2), cell_shared_edges, 'legacy'), 1), length(seq.frames(frame_num).cellgeom.circles));
        boundary_otherpopcells = boundary_otherpopcells(~(boundary_otherpopcells==cell_ind));

        local_cell_ind = seq.inv_cells_map(frame_num,cell_ind);
        currcell_loc = seq.frames(frame_num).cellgeom.circles(cell_ind,:);

        local_ind_boundary_otherpopcells = seq.inv_cells_map(frame_num,boundary_otherpopcells);
        boundary_otherpopcells_loc = seq.frames(frame_num).cellgeom.circles(local_ind_boundary_otherpopcells,:);

        anteriorchecks = boundary_otherpopcells_loc(:,2)>currcell_loc(:,2);
        if any(anteriorchecks)
            pop_one_boundary_anterior_inds(i) = true;
    %         one is on the anterior for that cell and those edges
            edge_one_on_ant(ismember(shared_edges,cell_shared_edges, 'legacy')) = true;
        end

        posteriorchecks = boundary_otherpopcells_loc(:,2)<currcell_loc(:,2);
        if any(posteriorchecks)
            pop_one_boundary_posterior_inds(i) = true;
        end

        if any(posteriorchecks)&&any(anteriorchecks)
            display('cell is on both borders - anterior and posterior - to other group');
        end

    end
    
%     shorten list of edges to only the selected edges
	edge_one_on_ant = edge_one_on_ant(ismember(glob_shared_edges,edges, 'legacy'));

	pop_one_boundary_anterior_inds = logical(pop_one_boundary_anterior_inds);
	pop_one_boundary_posterior_inds = logical(pop_one_boundary_posterior_inds);

    pop_one_ants = pop_one_boundary(pop_one_boundary_anterior_inds);
    pop_one_posts = pop_one_boundary(pop_one_boundary_posterior_inds);


    pop_one_ants_inds = find(ismember(cells_all_linear,pop_one_ants, 'legacy'));
    pop_one_posts_inds = find(ismember(cells_all_linear,pop_one_posts, 'legacy'));

    % just for population two, finding which cells are on which boundary

    for i = 1:length(pop_two_boundary)

        cell_ind = pop_two_boundary(i);

        all_cell_edges = faster_unique(ecm(ismember(ecm(:, 1), cell_ind, 'legacy'), 2), length(seq.frames(frame_num).cellgeom.edges));
        cell_shared_edges = shared_edges(ismember(shared_edges,all_cell_edges, 'legacy'));
        boundary_otherpopcells = faster_unique(ecm(ismember(ecm(:, 2), cell_shared_edges, 'legacy'), 1), length(seq.frames(frame_num).cellgeom.circles));
        boundary_otherpopcells = boundary_otherpopcells(~(boundary_otherpopcells==cell_ind));

        local_cell_ind = seq.inv_cells_map(frame_num,cell_ind);
        currcell_loc = seq.frames(frame_num).cellgeom.circles(cell_ind,:);

        local_ind_boundary_otherpopcells = seq.inv_cells_map(frame_num,boundary_otherpopcells);
        boundary_otherpopcells_loc = seq.frames(frame_num).cellgeom.circles(local_ind_boundary_otherpopcells,:);

        anteriorchecks = boundary_otherpopcells_loc(:,2)>currcell_loc(:,2);
        if any(anteriorchecks)
            pop_two_boundary_anterior_inds(i) = true;
        end

        posteriorchecks = boundary_otherpopcells_loc(:,2)<currcell_loc(:,2);
        if any(posteriorchecks)
            pop_two_boundary_posterior_inds(i) = true;
        end

        if any(posteriorchecks)&&any(anteriorchecks)
            display('cell is on both borders - anterior and posterior - to other group');
        end

    end

        pop_two_boundary_anterior_inds = logical(pop_two_boundary_anterior_inds);
        pop_two_boundary_posterior_inds = logical(pop_two_boundary_posterior_inds);

    pop_two_ants = pop_two_boundary(pop_two_boundary_anterior_inds);
    pop_two_posts = pop_two_boundary(pop_two_boundary_posterior_inds);

    pop_two_ants_inds = find(ismember(cells_all_linear,pop_two_ants, 'legacy'));
    pop_two_posts_inds = find(ismember(cells_all_linear,pop_two_posts, 'legacy'));

    % getting means for those particular populations
    % pop one

    pop_one_ants_pols = all_cells_pol(frame_num,pop_one_ants_inds);
    pop_one_ants_pols = pop_one_ants_pols(~isnan(pop_one_ants_pols));
    pop_one_pol.ants_mean = mean(pop_one_ants_pols);
    pop_one_pol.ants_std = std(pop_one_ants_pols);

    pop_one_posts_pols = all_cells_pol(frame_num,pop_one_posts_inds);
    pop_one_posts_pols = pop_one_posts_pols(~isnan(pop_one_posts_pols));
    pop_one_pol.posts_mean = mean(pop_one_posts_pols);
    pop_one_pol.posts_std = std(pop_one_posts_pols);

    % pop two

    pop_two_ants_pols = all_cells_pol(frame_num,pop_two_ants_inds);
    pop_two_ants_pols = pop_two_ants_pols(~isnan(pop_two_ants_pols));
    pop_two_pol.ants_mean = mean(pop_two_ants_pols);
    pop_two_pol.ants_std = std(pop_two_ants_pols);

    pop_two_posts_pols = all_cells_pol(frame_num,pop_two_posts_inds);
    pop_two_posts_pols = pop_two_posts_pols(~isnan(pop_two_posts_pols));
    pop_two_pol.posts_mean = mean(pop_two_posts_pols);
    pop_two_pol.posts_std = std(pop_two_posts_pols);

    % % %  combine all variables describing cells

    all_names_cells = ...
                {   'all_pol_mean',...              %1%
                    'all_pol_std',...               %2%
                    'pop_one_pol_mean',...          %3%
                    'pop_one_pol_std',...           %4%
                    'pop_two_pol_mean',...          %5%
                    'pop_two_pol_std'...           %6%          
%                     'pop_one_pol_ants_mean',...     %7%
%                     'pop_one_pol_ants_std',...      %8%
%                     'pop_one_pol_posts_mean',...    %9%
%                     'pop_one_pol_posts_std',...     %10%
%                     ...
%                     'pop_two_pol_ants_mean',...     %11%
%                     'pop_two_pol_ants_std',...      %12%
%                     'pop_two_pol_posts_mean',...    %13%
%                     'pop_two_pol_posts_std'...     %14%
    %                 'placeholder',...               %15%
    %                 'placeholder',...               %16%          
    %                 'placeholder',...               %17%
    %                 'placeholder',...               %18%
    %                 'placeholder',...               %19%
    %                 'placeholder',...               %20%
                };


    all_vals_cells = ... 
                {   all_pol.mean,...                %1%
                    all_pol.std,...                 %2%
                    pop_one_pol.mean,...            %3%
                    pop_one_pol.std,...             %4%
                    pop_two_pol.mean,...            %5%
                    pop_two_pol.std...             %6%
%                     pop_one_pol.ants_mean,...       %7%
%                     pop_one_pol.ants_std,...        %8%
%                     pop_one_pol.posts_mean,...      %9%
%                     pop_one_pol.posts_std,...       %10%
%                     ...
%                     pop_two_pol.ants_mean,...       %11%
%                     pop_two_pol.ants_std,...        %12%
%                     pop_two_pol.posts_mean,...      %13%
%                     pop_two_pol.posts_std...       %14%
    %                 'placeholder',...               %15%
    %                 'placeholder',...               %16%          
    %                 'placeholder',...               %17%
    %                 'placeholder',...               %18%
    %                 'placeholder',...               %19%
    %                 'placeholder',...               %20%

                };

    all_descriptions_cells = ... 
                {   'mean of polarity of all cells',...                       %1%
                    'standard deviation of polarity of all cells',...                        %2%
                    'mean of polarity of population one cells',...            %3%
                    'standard deviation of polarity of population one cells',...             %4%
                    'mean of polarity of population two cells',...            %5%
                    'standard deviation of polarity of population two cells',...             %6%
%                     'mean of polarity of population boundary one cells - anterior border',...       %7%
%                     'std of polarity of population boundary one cells - anterior border',...        %8%
%                     'mean of polarity of population boundary one cells - posterior border',...      %9%
%                     'std of polarity of population boundary one cells - posterior border',...       %10%
%                     ...
%                     'mean of polarity of population boundary two cells - anterior border',...       %11%
%                     'std of polarity of population boundary two cells - anterior border',...        %12%
%                     'mean of polarity of population boundary two cells - posterior border',...      %13%
%                     'std of polarity of population boundary two cells - posterior border'...       %14%
    %                 'placeholder',...               %15%
    %                 'placeholder',...               %16%          
    %                 'placeholder',...               %17%
    %                 'placeholder',...               %18%
    %                 'placeholder',...               %19%
    %                 'placeholder',...               %20%

                };


            combined_output_cells = [];
            current_ind = 0;
    % ratchet_structure_special(struct_in,ind_in,var_val_in,var_name_in)

    for i = 1:length(all_names_cells)
        [combined_output_cells,current_ind] = ratchet_structure_special(combined_output_cells,current_ind,...
            num2str(all_vals_cells{i}),all_names_cells{i},all_descriptions_cells{i});
    end

    %%% Not Currently Using Edge Analysis 
    %%% Not Included in Output, but Code is functional.
    
    % shared_edges
    % glob_shared_edges
    % shared_inds
    levels_shared = levels_all(frame_num,shared_inds,chan_num);
    levels_shared = levels_shared(~isnan(levels_shared));
    shared_edges_stats.mean = mean(levels_shared);
    shared_edges_stats.std = std(levels_shared);

    temp_levels_all = levels_all(frame_num,:,chan_num);
    all_edges_stats.mean = mean(temp_levels_all(~isnan(temp_levels_all)));
    all_edges_stats.std = std(temp_levels_all(~isnan(temp_levels_all)));

        len = data.edges.len(:, edges);
        len(~data.edges.selected(:, edges)) = nan; 
        ang = (data.edges.angles(:, edges));
        ang(ang > 90) = 180 - ang(ang > 90);
%         ang = smoothen(ang); %smoothen when doing over time
        

        vertinds = ang>75;
        vertinds = find(vertinds(frame_num,:));

    %     all vertical edges
        all_edges_vert_levels_list = levels_all(frame_num,vertinds,chan_num);
        all_edges_vert_levels_list = all_edges_vert_levels_list(~isnan(all_edges_vert_levels_list));
        all_edges_vert_levels.mean = mean(all_edges_vert_levels_list);
        all_edges_vert_levels.std = std(all_edges_vert_levels_list);

    %     all shared (boundary) and vertical edges
        shared_and_vert_inds = vertinds(ismember(vertinds,shared_inds, 'legacy'));
        shared_edges_vert_levels_list = levels_all(frame_num,shared_and_vert_inds,chan_num);
        shared_edges_vert_levels_list = shared_edges_vert_levels_list(~isnan(shared_edges_vert_levels_list));
        shared_edges_vert_levels.mean = mean(shared_edges_vert_levels_list);
        shared_edges_vert_levels.std = std(shared_edges_vert_levels_list);

    %     all boundary vertical edges with one on the anterior
        onetwo_and_vert_inds = vertinds(ismember(vertinds,shared_inds(edge_one_on_ant), 'legacy'));
        onetwo_edges_vert_levels_list = levels_all(frame_num,onetwo_and_vert_inds,chan_num);
        onetwo_edges_vert_levels_list = onetwo_edges_vert_levels_list(~isnan(onetwo_edges_vert_levels_list));
        onetwo_edges_vert_levels.mean = mean(onetwo_edges_vert_levels_list);
        onetwo_edges_vert_levels.std = std(onetwo_edges_vert_levels_list);

    %     all boundary vertical edges with one on the posterior
        twoOne_and_vert_inds = vertinds(ismember(vertinds,shared_inds(~edge_one_on_ant), 'legacy'));
        twoOne_edges_vert_levels_list = levels_all(frame_num,twoOne_and_vert_inds,chan_num);
        twoOne_edges_vert_levels_list = twoOne_edges_vert_levels_list(~isnan(twoOne_edges_vert_levels_list));
        twoOne_edges_vert_levels.mean = mean(twoOne_edges_vert_levels_list);
        twoOne_edges_vert_levels.std = std(twoOne_edges_vert_levels_list);

    %     all (angle inclusive) boundary edges one on the anterior
        onetwo_inds = shared_inds(edge_one_on_ant);
        onetwo_edges_list = levels_all(frame_num,onetwo_inds,chan_num);
        onetwo_edges_list = onetwo_edges_list(~isnan(onetwo_edges_list));
        onetwo_edges_levels.mean = mean(onetwo_edges_list);
        onetwo_edges_levels.std = std(onetwo_edges_list);

    %     all (angle inclusive) boundary edges one on the posterior
        twoOne_inds = shared_inds(~edge_one_on_ant);
        twoOne_edges_list = levels_all(frame_num,twoOne_inds,chan_num);
        twoOne_edges_list = twoOne_edges_list(~isnan(twoOne_edges_list));
        twoOne_edges_levels.mean = mean(twoOne_edges_list);
        twoOne_edges_levels.std = std(twoOne_edges_list);

    % % %  combine all variables describing edges

    all_names_edges = ...
                {   'shared_edges_stats_mean',...              %1%
                    'shared_edges_stats_std',...               %2%
                    'all_edges_stats_mean',...          %3%
                    'all_edges_stats_std',...           %4%
                    'all_edges_vert_levels_mean',...          %5%
                    'all_edges_vert_levels_std',...           %6%          
                    'shared_edges_vert_levels_mean',...     %7%
                    'shared_edges_vert_levels_std',...      %8%
                    'onetwo_edges_vert_levels_mean',...    %9%
                    'onetwo_edges_vert_levels_std',...     %10%
                    ...
                    'twoOne_edges_vert_levels_mean',...     %11%
                    'twoOne_edges_vert_levels_std',...      %12%
                    'onetwo_edges_levels_mean',...    %13%
                    'onetwo_edges_levels_std'...     %14%
                    'twoOne_edges_levels_mean',...               %15%
                    'twoOne_edges_levels_std'...               %16%          
    %                 'placeholder',...               %17%
    %                 'placeholder',...               %18%
    %                 'placeholder',...               %19%
    %                 'placeholder',...               %20%
                };


    all_vals_edges = ... 
                {   shared_edges_stats.mean,...                %1%
                    shared_edges_stats.std,...                 %2%
                    all_edges_stats.mean,...            %3%
                    all_edges_stats.std,...             %4%
                    all_edges_vert_levels.mean,...            %5%
                    all_edges_vert_levels.std,...             %6%
                    shared_edges_vert_levels.mean,...       %7%
                    shared_edges_vert_levels.std,...        %8%
                    onetwo_edges_vert_levels.mean,...      %9%
                    onetwo_edges_vert_levels.std,...       %10%
                    ...
                    twoOne_edges_vert_levels.mean,...       %11%
                    twoOne_edges_vert_levels.std,...        %12%
                    onetwo_edges_levels.mean,...      %13%
                    onetwo_edges_levels.std...       %14%
                    twoOne_edges_levels.mean,...               %15%
                    twoOne_edges_levels.std...               %16%          
    %                 'placeholder',...               %17%
    %                 'placeholder',...               %18%
    %                 'placeholder',...               %19%
    %                 'placeholder',...               %20%

                };

    all_descriptions_edges = ... 
                {   'mean of all shared (boundary) edges',...              %1%
                    'std of all shared (boundary) edges',...               %2%
                    'mean of all edges',...          %3%
                    'std of all edges',...           %4%
                    'mean of all vertical edges',...          %5%
                    'std of all vertical edges',...           %6%          
                    'mean of all vert & shared (boundary) edges',...     %7%
                    'std of all vert & shared (boundary) edges',...      %8%
                    'mean of all vert & shared (boundary) edges - pop one on anterior side',...    %9%
                    'std of all vert & shared (boundary) edges - pop one on anterior side',...     %10%
                    ...
                    'mean of all vert & shared (boundary) edges - pop one on posterior side',...     %11%
                    'std of all vert & shared (boundary) edges - pop one on posterior side',...      %12%
                    'mean of all (angle inclusive) shared (boundary) edges - pop one on anterior side',...    %13%
                    'std of all (angle inclusive) shared (boundary) edges - pop one on anterior side'...     %14%
                    'mean of all (angle inclusive) shared (boundary) edges - pop one on posterior side',...               %15%
                    'std of all (angle inclusive) shared (boundary) edges - pop one on posterior side'...               %16%          
    %                 'placeholder',...               %17%
    %                 'placeholder',...               %18%
    %                 'placeholder',...               %19%
    %                 'placeholder',...               %20%
                };


            combined_output_edges = [];
            current_ind = 0;
    % ratchet_structure_special(struct_in,ind_in,var_val_in,var_name_in)

    for i = 1:length(all_names_edges)
        [combined_output_edges,current_ind] = ratchet_structure_special(combined_output_edges,current_ind,...
            num2str(all_vals_edges{i}),all_names_edges{i},all_descriptions_edges{i});
    end

% cd(startdir);