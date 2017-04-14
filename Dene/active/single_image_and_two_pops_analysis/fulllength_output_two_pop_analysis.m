function [full_combined_output_cells] = fulllength_output_two_pop_analysis(indir,polsavename,chan_num)

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
    seq.directory = pwd;
	if isempty(dir('cells_for_two_pops.mat'))
        display('missing cells_for_two_pops');
        full_combined_output_cells = [];
        return
    end
    load('cells_for_two_pops');

    % find(pop_two_cells)
    % find(pop_one_cells)
    if size(data.cells.selected,1)>1
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

    all_pol_full = all_cells_pol(frame_num,~isnan(all_cells_pol(frame_num,:)));
    

    pop_one_pols = all_cells_pol(frame_num,pop_one_ind);
    pop_one_pols = pop_one_pols(~isnan(pop_one_pols));
    pop_one_pol_full = pop_one_pols;

    pop_two_pols = all_cells_pol(frame_num,pop_two_ind);
    pop_two_pols = pop_two_pols(~isnan(pop_two_pols));
    pop_two_pol_full = pop_two_pols;
    
    
    all_pol_mean = mean(all_pol_full);
    all_pol_full_zeroed = all_pol_full - all_pol_mean;
    
    pop_one_pols_mean = mean(pop_one_pols);
    pop_one_pol_full_zeroed = pop_one_pol_full - pop_one_pols_mean;
    
    pop_two_pols_mean = mean(pop_two_pols);
    pop_two_pol_full_zeroed = pop_two_pol_full - pop_two_pols_mean;
    
	
    
    all_pol_full_normed = all_pol_full/abs(all_pol_mean);
    pop_one_pol_full_normed = pop_one_pol_full/abs(all_pol_mean);
    pop_two_pol_full_normed = pop_two_pol_full/abs(all_pol_mean);
    
    all_pol_full_zero_shift_and_std_divided = all_pol_full_zeroed/std(all_pol_full_zeroed);
    pop_one_pol_full_zero_shift_and_std_divided = pop_one_pol_full_zeroed/std(pop_one_pol_full_zeroed);
    pop_two_pol_full_zero_shift_and_std_divided = pop_two_pol_full_zeroed/std(pop_two_pol_full_zeroed);
    

    % % %  combine all variables describing cells

    all_names_cells = ...
                {   'all_pol_full',...              %1%
                    'pop_one_pol_full',...          %2%
                    'pop_two_pol_full'...          %3%
%                     'all_pol_full_zeroed',...              %4%
%                     'pop_one_pol_full_zeroed',...          %5%
%                     'pop_two_pol_full_zeroed',...          %6%
%                     'all_pol_full_normed',...              %7%
%                     'pop_one_pol_full_normed',...          %8%
%                     'pop_two_pol_full_normed',...          %9%
%                     'all_pol_full_zero_shift_and_std_divided',...              %10%
%                     'pop_one_pol_full_zero_shift_and_std_divided',...          %11%
%                     'pop_two_pol_full_zero_shift_and_std_divided'...          %12%
                    };


    all_vals_cells = ... 
                {   all_pol_full,...              %1%
                    pop_one_pol_full,...          %2%
                    pop_two_pol_full...          %3%
%                     all_pol_full_zeroed,...              %4%
%                     pop_one_pol_full_zeroed,...          %5%
%                     pop_two_pol_full_zeroed,...          %6%
%                     all_pol_full_normed,...              %7%
%                     pop_one_pol_full_normed,...          %8%
%                     pop_two_pol_full_normed,...          %9%
%                     all_pol_full_zero_shift_and_std_divided,...              %10%
%                     pop_one_pol_full_zero_shift_and_std_divided,...          %11%
%                     pop_two_pol_full_zero_shift_and_std_divided...          %12%
                    };

    all_descriptions_cells = ... 
                {   'all polarities (all cells in ROI poly) log2 values',...              %1%
                    'all polarities - pop one log2 values',...          %2%
                    'all polarities - pop two log2 values'...          %3%
%                     'all polarities (both groups) -> shifted by (-mean)',...              %4%
%                     'all polarities - pop one -> shifted by (-mean)',...          %5%
%                     'all polarities - pop two -> shifted by (-mean)',...          %6%
%                     'all polarities - (both groups) -> norm (./) by (-mean)',...              %7%
%                     'all polarities - pop one -> norm (./) by (-mean)',...          %8%
%                     'all polarities - pop two -> norm (./) by (-mean)'...          %9%
%                     'all polarities (both groups) -> shifted by (-mean) and divided by std',...              %10%
%                     'all polarities - pop one -> shifted by (-mean) and divided by std',...          %11%
%                     'all polarities - pop two -> shifted by (-mean) and divided by std'...          %12%
                    };



            full_combined_output_cells = [];
            current_ind = 0;
    % ratchet_structure_special(struct_in,ind_in,var_val_in,var_name_in)

%     changing -> removing num2str line for all vals
    
    for i = 1:length(all_names_cells)
        [full_combined_output_cells,current_ind] = ratchet_structure_special(full_combined_output_cells,current_ind,...
            all_vals_cells{i},all_names_cells{i},all_descriptions_cells{i});
    end

    