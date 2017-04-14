function completevars_out = complete_varnames_for_plots(varnames_in)

completevars_out = [];
for i = 1:length(varnames_in)
    display(varnames_in{i});
    completevars_out = set_var_for_plot_SEGGA(completevars_out, varnames_in{i});
end

for i = 1:length(completevars_out)
    completevars_out(i).boundary_l = 2;
    completevars_out(i).boundary_r = 1;
end