function outvars = current_vars_to_plot_SEGGA

clear outvars
outvars = [];




outvars = set_var_for_plot_SEGGA(outvars, 'nghbrs_lost_per_cell');
outvars = set_var_for_plot_SEGGA(outvars, 't1_per_cell', 'color', [0 0 1]);
outvars = set_var_for_plot_SEGGA(outvars, 'ros_per_cell', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'nghbrs_gained_per_cell', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'hor_elon', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'longaxis_elon', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'shortaxis_elon', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'ver_elon', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars,'norm_cell_hortovert_length');
outvars = set_var_for_plot_SEGGA(outvars, 'norm_hor_to_ver_ratio', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'norm_L1_to_L2_ratio', 'color', [1 0 0]);

outvars = set_var_for_plot_SEGGA(outvars, 'top_dis', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'cell_area', 'color', [1 0 0]);
area_pos = length(outvars);
outvars = set_var_for_plot_SEGGA(outvars, 'cell_area_coeff', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'norm_cell_area', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'num_nghbrs', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'edge_align', 'color', [1 0 0]);

outvars = set_var_for_plot_SEGGA(outvars, 'cell_hor_length', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'norm_cell_hor_length', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'norm_cell_ver_length', 'color', [1 0 0]);

outvars = set_var_for_plot_SEGGA(outvars, 'cell_vertohor_length', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'cell_hortovert_length', 'color', [1 0 0]);

outvars = set_var_for_plot_SEGGA(outvars, 'cell_ver_length', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'pat_defo', 'color', [1 0 0]);
outvars = set_var_for_plot_SEGGA(outvars, 'node_multiplicity', 'color', [1 0 0]);
% outvars = set_var_for_plot_SEGGA(outvars, 'cells_lost_hist', 'color', [1 0 0]);



% vars(i).boundary_l and vars(i).boundary_r determins behavior of nan
% values beyond left and right boundaries, respectively. (when a movie time
% span is shorter than of other movies with which its data are averaged). 
% vars(i).boundary_l = 0 to set to zero, = 1 to set to the same value as
% the boundary value, = 2 to set to nan (and then ignored when averaging).

% [outvars(:).post_func] = deal(@(x)smoothen(x));
% 
% [outvars(area_pos).post_func] = deal(@(x)smoothen(x*(0.33^2)));

for i = 1:length(outvars)
    outvars(i).boundary_l = 2;
    outvars(i).boundary_r = 1;
end

return


