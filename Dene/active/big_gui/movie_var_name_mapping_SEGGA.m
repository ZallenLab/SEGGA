function var_name_output = movie_var_name_mapping_SEGGA(var_name_input,default_name)
%%% This function maps internal data names to end-user readable names
%%% used from CSV and txt output from SEGGA Analyses
%%%

if nargin < 2 || isempty(default_name)
    default_name = var_name_input;
end

replace_spaces_bool = true;
v = [];
try
    x = set_var_for_plot_SEGGA([],var_name_input);
    v = x.title;
catch
    display(['variable not found in first name mapping search (',var_name_input,')']);
end

if isempty(v)
    %try secondary mapping (should not be necessary)
    v = secondary_movie_var_name_mapping(var_name_input);    
end

if isempty(v)
    % if neither mapping finds anything, then use the default name provided
    v = default_name;
end

var_name_output = v;

if replace_spaces_bool
    expression = '\s';
    replace = '\_';
    var_name_output = regexprep(var_name_output,expression,replace);
end






function name_out = secondary_movie_var_name_mapping(n)
name_out = [];
switch n
    case 'node_resolution_times'
        name_out = 'Node Resolution Times';
    case 't1_res_times'
        name_out = 'T1 Node Resolution Times';
    case 'ros_res_times'
        name_out = 'Rosette Node Resolution Times';
    case 'piv_hor_elon'
        name_out = 'Tissue Horizontal Elongation by PIV';
    case 'cell_L1_length'
        name_out = 'Cell Long Axis Length';
    case 'cell_L2_length'
        name_out = 'Cell Short Axis Length';
	case 'cell_L1_toL2_ratio'
        name_out = 'Cell Ratio of Long to Short Axis Lengths';
    case 'cell_pat_defo'
        name_out = 'Cell Pattern Deformation';
    case 'cell_num_nghbrs'
        name_out = 'Number of Neighbors per Cell';
        %%% All of the following should already be accounted for with
        %%% set_var_for_plot_SEGGA 
        %%% change name in set_var_for_plot_SEGGA  to modify mapping, or
        %%% apply this mapping first before checking in set_var_for_plot_SEGGA
    case 'L1_to_L2_ratio'
        name_out = 'Ratio of tissue long axis to tissue short axis';
    case 'all_contract_rate_mean'
        name_out = 'Rate of edge contraction (all contracting edges)';
    case 'cell_ang'
        name_out = 'Cell orientation';
    case 'cell_area'
        name_out = 'Cell area';
    case 'cell_area_coefficient_of_variation'
        name_out = 'Cell area coefficient of variation';
    case 'cell_ecc'
        name_out = 'Cell eccentricity';
    case 'cell_hor_length'
        name_out = 'Cell horizontal length';
    case 'cell_hortovert_length'
        name_out = 'Cell horizontal to vertical length ratio';
    case 'cell_ver_length'
        name_out = 'Cell vertical length';
    case 'cell_vertohor_length'
        name_out = 'Cell vertical to horizontal length ratio';
    case 'cells_at_least_one_event_anykind'
        name_out = 'Percent of Cells in T1s or Rosettes';
    case 'cells_at_least_one_T1'
        name_out = 'Percent of Cells in T1 Transitions';        
    case 'cells_at_least_one_rosette'
        name_out = 'Percent of Cells in Rosettes';
    case 'cells_at_least_two_rosettes'
        name_out = 'Percent of Cells in Two or More Rosettes';
    case 'cells_gain_hist'
        name_out = 'Accumulative count of neighbors gained per cell';
    case 'cells_lost_hist'
        name_out = 'Accumulative count of neighbors lost per cell';
    case 'cells_ros_hist'
        name_out = 'Accumulative count of rosettes per cell';
    case 'cells_t1_hist'
        name_out = 'Accumulative count of T1 transitions per cell';
    case 'cells_w_edges_shrink_into_at_least_one_event_anykind'
    	name_out = 'Fraction of Cells that lose 1 or More Ngbrs';
    case 'cells_w_edges_shrink_into_at_least_one_T1'
        name_out = 'Percent of Cells in T1 Transitions (Contracting Only)';
    case 'cells_w_edges_shrink_into_at_least_one_rosette'
    	name_out = 'Percent of Cells in Rosettes (Contracting Only)';
    case 'cells_w_edges_shrink_into_at_least_two_rosettes'
    	name_out = 'Percent of Cells in Two or More Rosettes (Contracting Only)';
    case 'edge_align'
        name_out = 'Vertical edge alignment';
    case 'hor_elon'
        name_out = 'Tissue horizontal elongation';
    case 'hor_to_ver_ratio' 
        name_out = 'Tissue horizontal-to-vertical aspect ratio';
    case 'longaxis_elon'
        name_out = 'Tissue long axis elongation';
    case 'nghbrs_gained_per_cell'
        name_out = 'Neighbors gained per cell';
    case 'nghbrs_lost_per_cell'
        name_out = 'Neighbors lost per cell';
    case 'node_multiplicity'
        name_out = 'Node Multiplicity';
    case 'norm_L1_to_L2_ratio'
        name_out = 'Normalized tissue long axis to short axis aspect ratio';
    case 'norm_cell_area'
        name_out = 'Normalized cell area';
    case 'norm_cell_hor_length'
        name_out = 'Normalized cell horizontal length';
    case 'norm_cell_hortovert_length'
        name_out = 'Normalized cell horizontal-to-vertical length ratio';
    case 'norm_cell_ver_length'
        name_out = 'Normalized cell vertical length';
    case 'norm_hor_to_ver_ratio' 
        name_out = 'Normalized tissue horizontal-to-vertical length ratio';
    case 'num_cells_sel'
        name_out = 'Number of cells selected';
    case 'num_nghbrs'
        name_out = 'Number of neighbors';
    case 'num_shrink_selected'
        name_out = 'Number of shrinking edges selected';
    case 'num_sides_hist'
        name_out = 'Histogram of number of sides';
    case 'pat_defo'
        name_out = 'Pattern deformation';
    case 'perc_nlost_ros'
        name_out = 'Percent of neighbors lost contributed by rosettes';
    case 'perc_nlost_t1'
        name_out = 'Percent of neighbors lost contributed by T1s';
    case 'ros_contract_rate_mean'
        name_out = 'Rate of edge contraction for rosette forming edges';
    case 'ros_per_cell'
        name_out = 'Rosettes per cell';
    case 'shortaxis_elon'
        name_out = 'Tissue short axis elongation';
    case 't1_contract_rate_mean'
        name_out = 'Rate of edge contraction for rosette forming edges';
    case 't1_per_cell'
        name_out = 'T1 transitions per cell';
    case 'top_dis'
        name_out = 'Topological disorder';
    case 'ver_elon'
        name_out = 'Tissue vertical elongation';
    case 'vert_contract_rate_mean'
        name_out = 'Rate of edge contraction for vertical contracting edges';
    otherwise
        display('could not find variable name in secondary mapping function.');
end


