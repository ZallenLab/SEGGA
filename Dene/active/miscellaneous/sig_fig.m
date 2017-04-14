function out = sig_fig(val,sig_figs)

out = round(val*10^(0+sig_figs))/10^(0+sig_figs);