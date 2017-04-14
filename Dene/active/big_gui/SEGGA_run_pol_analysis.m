function SEGGA_run_pol_analysis(params)

previous_savename = params.previous_savename;
% new_savename = 'edges_info_SEGGA_test';
new_savename = 'edges_info_cell_background';
% base_dir = params.base_dir;
seg_filename = fullfile(params.seg_img_base_dir,params.seg_filename);
options = params.options;
channel_info = params.channel_info;
load_existing = params.load_existing;
runanalysis = true;
[seg_dir, ~, ~] = fileparts(seg_filename);
base_dir = [seg_dir,filesep,'..',filesep];
analysis_type = params.analysis_type;

display('running polarity analysis from SEGGA_run_pol_analysis.m');

general_values_along_edges_adaptation(previous_savename,new_savename,base_dir,seg_filename,...
                                      options,channel_info,load_existing,runanalysis,analysis_type);
                                  
                                  
display('FINISHED running polarity analysis from SEGGA_run_pol_analysis.m');