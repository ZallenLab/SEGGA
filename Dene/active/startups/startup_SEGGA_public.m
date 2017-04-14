function startup_SEGGA_public()

startdir = pwd;
P = mfilename('fullpath');
[PATHSTR,~,~] = fileparts(P);
SRC_base_dir = [PATHSTR,filesep,'..',filesep,'..',filesep,'..',filesep];
cd(SRC_base_dir);
SRC_base_dir = pwd;

display('adding Ori`s folders...')
addpath([SRC_base_dir,'/Ori/analysis']);
addpath([SRC_base_dir,'/Ori/imgproc2']);
addpath([SRC_base_dir,'/Ori/sim']);
display('---Ori`s folders added.')

display('Adding PIVlab folder.')
addpath([SRC_base_dir,'/PIVlab_1.32']);

display('Adding Rodrigo`s folders.')
addpath([SRC_base_dir,'/Rodrigo/CellSegmentation']);

display('Adding Dene`s folders.');
addpath([SRC_base_dir,'/Dene/SEGGA_GUI']);
addpath([SRC_base_dir,'/Dene/active/3D_segmentation/']);
addpath([SRC_base_dir,'/Dene/active/advancing_seg_quality/']);
addpath([SRC_base_dir,'/Dene/active/analysis/']);
addpath([SRC_base_dir,'/Dene/active/analysis_addons/']);
addpath([SRC_base_dir,'/Dene/active/big_gui/']);
addpath([SRC_base_dir,'/Dene/active/cell_polarity/']);
addpath([SRC_base_dir,'/Dene/active/deployment_filemapping']);
addpath([SRC_base_dir,'/Dene/active/edge_alt_angles/']);
addpath([SRC_base_dir,'/Dene/active/edge_dynamics_shrinks/']);
addpath([SRC_base_dir,'/Dene/active/edge_info_polarities/']);
addpath([SRC_base_dir,'/Dene/active/file_sys_management/']);
addpath([SRC_base_dir,'/Dene/active/from_others/']);
addpath([SRC_base_dir,'/Dene/active/from_others/anisodiff_Perona-Malik/']);
addpath([SRC_base_dir,'/Dene/active/from_others/anisodiff_Perona-Malik/anisodiff_Perona-Malik/']);
addpath([SRC_base_dir,'/Dene/active/from_others/bipolar_colormap/']);
addpath([SRC_base_dir,'/Dene/active/from_others/cbrewer/']);
addpath([SRC_base_dir,'/Dene/active/from_others/cprintf/']);
addpath([SRC_base_dir,'/Dene/active/from_others/kakearney-boundedline-pkg-5d00182/']);
addpath([SRC_base_dir,'/Dene/active/from_others/kakearney-boundedline-pkg-5d00182/boundedline/']);
addpath([SRC_base_dir,'/Dene/active/from_others/kakearney-boundedline-pkg-5d00182/inpaint_nans/']);
addpath([SRC_base_dir,'/Dene/active/from_others/mayer_denoising_archive/']);
addpath([SRC_base_dir,'/Dene/active/from_others/popupmessage/']);
addpath([SRC_base_dir,'/Dene/active/from_others/uipickfiles/']);
addpath([SRC_base_dir,'/Dene/active/from_others/popupmessage/']);
addpath([SRC_base_dir,'/Dene/active/from_others/various-collected/']);
addpath([SRC_base_dir,'/Dene/active/general/']);
addpath([SRC_base_dir,'/Dene/active/img_proc_dlf/']);
addpath([SRC_base_dir,'/Dene/active/miscellaneous/']);
addpath([SRC_base_dir,'/Dene/active/miscellaneous/fix_image_output/']);
addpath([SRC_base_dir,'/Dene/active/miscellaneous/fix_image_output/extras/']);
addpath([SRC_base_dir,'/Dene/active/piv_dlf/']);
addpath([SRC_base_dir,'/Dene/active/rotating-edges/']);
addpath([SRC_base_dir,'/segmentation_conversion/']);
addpath([SRC_base_dir,'/Dene/active/single_image_and_two_pops_analysis/']);
addpath([SRC_base_dir,'/Dene/active/startups/']);
addpath([SRC_base_dir,'/Dene/active/stats/']);
addpath([SRC_base_dir,'/Dene/active/tracking_sub_functions/']);
addpath([SRC_base_dir,'/Dene/active/v_field_plots/']);


savepath;
%! chmod 666 /Applications/MATLAB_R2015b.app/toolbox/local/pathdef.m
cd(startdir);
display('startup_SEGGA finished');

