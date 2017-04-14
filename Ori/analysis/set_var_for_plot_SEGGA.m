function [vars, name_not_found] = set_var_for_plot_SEGGA(vars, name, varargin)
% % [v, f] = set_var_for_plot_SEGGA(v, n, varargin)
% INPUTS:
% 1. v => vars -    List of variables to append the new variable to.
% 2. n => name -    Name of the new variable to append.
% 3. vargin -       In sets of two, any field name coupled with its value.
%                   Takes the form: set_var_for_plot_SEGGA(v, n, fieldname,fieldvalue)
%                   where the fieldname is a string, and the fieldvalue can be
%                   any data structure.
% OUTPUTS:
% 1. v => vars -            list of variables after appending new variable
% 2. f => name_not_found -  Boolean set to True if the input name of the 
%                           variable was not recognized
% 
% If a 'name' is not given as the second input, then all possible options
% for names of variables are printed to the command window.
%
% >> set_var_for_plot_SEGGA()
% to see all possible variables
% 
% Author: Dene Farrell
% Sloan Kettering Insitute
% Jennifer Zallen's Laboratory
% release: 2017
% version: 1.0
% last edit: 2017 April 6
%
%
% Copyright (c) 2017 Dene Farrell, Jennifer Zallen
%
% Permission is hereby granted, free of charge, to any person obtaining a copy 
% of this software and associated documentation files (the "Software"), to deal 
% in the Software without restriction, including without limitation the rights 
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
% copies of the Software, and to permit persons to whom the Software is 
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
% SOFTWARE.


name_not_found = false;
if nargin < 2 || isempty(name)
    display_options
    return
end




[new_var, name_not_found] = set_var_for_plot_basic(name);
for i = 1:2:length(varargin)
    new_var.(varargin{i}) = varargin{i+1};
end

if isempty(new_var)
    return
end



fns = fieldnames(new_var);
old_num = length(vars);
for i = 1:length(fns)
    vars(old_num+1).(fns{i}) = new_var.(fns{i});
end


if isempty(vars)
    vars = new_var;
    return
end
% if any(strcmp(varargin,'chan_ind'))
%     loc = find(strcmp(varargin,'chan_ind'));
%     eval([varargin{loc},' = ',num2str(varargin{loc+1})]);
%     vars(end).func = @(x, t) x(chan_ind).mean;
%     vars(end).xvals_func = @(x, t) x(chan_ind).xvals;
%     vars(end).title = [new_var.title,'channel: ',num2str(chan_ind)];
% end


function display_options
disp(sprintf('\n'))
p = mfilename('fullpath');
fid = fopen([p,'.m'], 'r'); %the function analyzes itself!!
tline = fgetl(fid);
while ischar(tline)
    if strcmp(tline, 'function [var, name_not_found] = set_var_for_plot_basic(name)')
        break
    end
    tline = fgetl(fid);
end
vars = [];
while ischar(tline)
    k = strfind(tline, 'case ''');
    if ~isempty(k)
        vars = set_var_for_plot_SEGGA(vars, tline((k+6):(end-1)), 'tag', tline((k+6):(end-1)));
    end
    tline = fgetl(fid);
end
fclose(fid);

for i = 1:length(vars)
    disp(sprintf([vars(i).tag '\t\t\t\t' vars(i).title]));
end
fprintf('\n')


function [var, name_not_found] = set_var_for_plot_basic(name)
name_not_found = false;
switch name
    
%%%%%%%%%%%%%%%%%%%%%%% BASIC GROUP    
% % % % % %     (HALLMARK TIME SERIES MEASUREMENTS)
%         
%

    case 'num_cells_sel'
        var.var_name = 'data';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'analysis';
        var.title = 'Number of Cells Selected for Static Analysis';
        var.func = @(x,t) sum(x.cells.selected(1:end,:),2);
        
    case 'nghbrs_lost_per_cell'
        var.var_name = 'n_lost_per_cell';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Neighbors Lost Per Cell'; %t1s + ros
        
        
    case 't1_per_cell'
        var.var_name = 'num_t1_per_cell';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'T1 Transitions per Cell';
    
    case 'ros_per_cell'
        var.var_name = 'num_ros_per_cell';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Rosettes per Cell';
        
    case 'nghbrs_gained_per_cell'
        var.var_name = 'n_gained_per_cell';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Neighbors Gained Per Cell'; %direct method
          
    case 'hor_elon'
        var.var_name = 'hor';
        var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';
        var.title = 'Normalized Tissue Horizontal Length';
        
	case 'hor_len'
        var.var_name = 'hor';
%         var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';
        var.title = 'Tissue Horizontal Length';
        
        
    case 'ver_elon'
        var.var_name = 'ver';
        var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Normalized Tissue Vertical Length';
        
	case 'ver_len'
        var.var_name = 'ver';
%         var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Tissue Vertical Length';
        
	case 'longaxis_elon'
        var.var_name = 'L1';
        var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';
        var.title = 'Normalized Tissue Long Axis Length';
        
        
	case 'shortaxis_elon'
        var.var_name = 'L2';
        var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';
        var.title = 'Normalized Tissue Short Axis Length';
        
	case 'longaxis_len'
        var.var_name = 'L1';
%         var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';
        var.title = 'Tissue Long Axis Length';
        
	case 'L2_len'
        var.var_name = 'L2';
%         var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Tissue Short Axis Length';
        
	case 'norm_hor_to_ver_ratio'
        var.var_name = 'hor_to_ver_ratio';
        var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Normalized Tissue Aspect Ratio (Horizontal to Vertical)';
	
    case 'hor_to_ver_ratio'
        var.var_name = 'hor_to_ver_ratio';
%         var.func = @(x,t);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Tissue Aspect Ratio (Horizontal to Vertical)';
        
	case 'norm_L1_to_L2_ratio'
        var.var_name = 'L1_to_L2_ratio';
        var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Normalized Tissue Aspect Ratio (Long Axis to Short Axis)';
        
	case 'L1_to_L2_ratio'
        var.var_name = 'L1_to_L2_ratio';
%         var.func = @(x,t) x/x(max(-t, 0)+1);
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'elon';        
        var.title = 'Tissue Aspect Ratio (Long Axis to Short Axis)';
    
    case 'top_dis'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Topological Disorder';
        var.boundary_r = 2;
        var.boundary_l = 2;
        var.func = @(x, t) x.top_dis;
        
        
	case 'num_nghbrs'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Number of Neighbors';
        var.func = @(x,t) x.num_nghbrs;
        %%%%%% Not working - fix this
        
    case 'node_multiplicity'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Node Multiplicity';
        var.func = @(x,t) x.nm; 
    
    case 'edge_align'
        var.var_name = 'v_linkage';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'v_link';
        var.title = 'Vertical Edge Alignment';
        var.func = @(x,t) x*100; %fraction -> percentage

    case 'cell_hor_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Horizontal Length';
        var.func = @(x,t) x.cell_hor;
        
	case 'cell_ver_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Vertical Length';
        var.func = @(x,t) x.cell_ver;
        
    case 'norm_cell_hor_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Normalized Cell Horizontal Length';
        var.func = @(x,t) x.cell_hor/x.cell_hor(max(-t, 0)+1);
        
    case 'norm_cell_ver_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Normalized Cell Vertical Length';
        var.func = @(x,t) x.cell_ver/x.cell_ver(max(-t, 0)+1);
        
    case 'cell_hortovert_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Horizontal to Vertical Length Ratio';
        var.func = @(x,t) x.cell_hor./x.cell_ver;
        
    case 'cell_vertohor_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Vertical to Horizontal Length Ratio';
        var.func = @(x,t) x.cell_ver./x.cell_hor;
        
	case 'norm_cell_hortovert_length'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Normalized Cell Horizontal to Vertical Length Ratio';
        var.func = @(x,t) (x.cell_hor./x.cell_ver)./(x.cell_hor(max(-t, 0)+1)/x.cell_ver(max(-t, 0)+1));
        
    case 'cell_area'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Area';
        var.boundary_r = 2;
        var.boundary_l = 2;
        var.func = @(x, t) x.areas;
        
    case 'norm_cell_area'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Normalized Cell Area';
        var.func = @(x, t) x.areas/x.areas(max(-t, 0)+1);
        
    case 'cell_area_coeff'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Area Coefficient of Variation';
        var.boundary_r = 2;
        var.boundary_l = 2;
        var.func = @(x, t) x.areas_std_over_mean;
        
    case 'cell_area_coefficient_of_variation'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Area Coefficient of Variation';
        var.boundary_r = 2;
        var.boundary_l = 2;
        var.func = @(x, t) x.areas_std_over_mean;
        
    case 'cell_ecc'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Eccentricity';
        var.func = @(x,t) x.ecc;
        
	case 'cell_ang'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Orientation';
        var.func = @(x,t) x.cell_angle;
         
    case 'pat_defo'
        var.var_name = 'measurements';
        var.file_name = 'measurements';
        var.title = 'Pattern Deformation (Texture Tensor)';
        var.func = @(x,t) x.pat_defo;
        
    case 'cell_qVal'
        var.var_name = 'avrgs';
        var.file_name = 'avrgs';
        var.title = 'Cell Structural Order (q)';
        var.boundary_r = 2;
        var.boundary_l = 2;        
        var.func = @(x, t) x.qVal;
        
	case 'cell_area_deriv_avg'
        var.var_name = 'new_avrgs';
        var.file_name = 'new_avrgs';
        var.title = 'Cell Area Derivative';
        var.func = @(x, t) x.area_deriv_mean;
        
	case 'cell_area_deriv_sum'
        var.var_name = 'new_avrgs';
        var.file_name = 'new_avrgs';
        var.title = 'Sum of Cell Area Derivatives';
        var.func = @(x, t) x.area_deriv_sum;
        

        

%%%%%%%%% SHRINKING EDGES %%%%%%%%%%%%%%%%%%
    case 'num_edges_aligned_shrinks'
        var.var_name = 'aligned_sel_sh';
        var.file_name = 'shrinking_edges_info_new';
        var.title = 'Number of Edges for Aligned Shrink Measure';
        var.fun = @(x,t) sum(x);
       
	case 'num_shrink_selected'
        var.var_name = 'num_shrink_selected';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'where_shrinks_go';
        var.title = 'Number of Shrinking Edges';
        
    case 'all_contract_rate_mean'
        var.var_name = 'all_contract_rate_mean';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'shrink_angs_new';
        var.title = 'Contraction Rate of All Shrinking Edges';

	case 'vert_contract_rate_mean'
        var.var_name = 'vert_contract_rate_mean';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'shrink_angs_new';
        var.title = 'Contraction Rate of Vertical Shrinking Edges';
        
	case 'ros_contract_rate_mean'
        var.var_name = 'ros_contract_rate_mean';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'shrink_angs_new';
        var.title = 'Contraction Rate of Shrinking Edges that Form Rosettes';

	case 't1_contract_rate_mean'
        var.var_name = 't1_contract_rate_mean';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'shrink_angs_new';
        var.title = 'Contraction Rate of Shrinking Edges that Form T1s';

    case 'len_sh_mean'
        var.var_name = 'len_sh_mean';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'aligned_edges_info';
        var.title = 'Length of Shrinking Edges (pixels)';
        
    case 'len_gr_mean'
        var.var_name = 'len_gr_mean';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'aligned_edges_info';
        var.title = 'Length of Growing Edges (pixels)';


        
%%%%%%%%%%%% binning variables %%%%%%%%%%%%%
%%%%%%% HISTOGRAMS
% % % % % %     BINNED VARIABLES MEASUREMENTS
    case 'cells_lost_hist'
        var.var_name = 'cells_lost_hist';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Histogram of Neighbors Lost';
        var.bins = 0:4;
%         var.binning_func = @(x,t,bins) histc(x,bins,2);
        var.binning_func = @(x,t,bins) x;
        var.func = @(x,t) histogram_of_nghbr_xchange(x,var.bins);
        var.apply_norm = true;
        
    case 'cells_gain_hist'
        var.var_name = 'cells_gain_hist';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Histogram of Neighbors Gained';
        var.bins = 0:4;
%         var.binning_func = @(x,t,bins) histc(x,bins,2);
        var.binning_func = @(x,t,bins) x;
        var.func = @(x,t) histogram_of_nghbr_xchange(x,var.bins);
        var.apply_norm = true;
        
	case 'cells_t1_hist'
        var.var_name = 'cells_t1_hist';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Histogram of Neighbors Lost through T1s';
        var.bins = 0:4;
%         var.binning_func = @(x,t,bins) histc(x,bins,2);
        var.binning_func = @(x,t,bins) x;
        var.func = @(x,t) histogram_of_nghbr_xchange(x,var.bins);
        var.apply_norm = true;
             
	case 'cells_ros_hist'
        var.var_name = 'cells_ros_hist';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Histogram of Neighbors Lost through Rosettes';
        var.bins = 0:4;
%         var.binning_func = @(x,t,bins) histc(x,bins,2);
        var.binning_func = @(x,t,bins) x;
        var.func = @(x,t) histogram_of_nghbr_xchange(x,var.bins);
        var.apply_norm = true;
        
	case 'num_sides_hist'
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.var_name = 'data';
        var.file_name = 'analysis';
        var.title = 'Number of Cell Sides Hist';
        var.bins = 1:10;
        var.func = @(x,t) histogram_of_nsides(x,var.bins);        
        var.binning_func = @(x,t,bins) x;
%         var.num_from_hist_bool = true;
        var.apply_norm = true;
        
%%%%%%%%% EXTRAS - NON-COMMON BASIC %%%%%%%%%%%%%%%%%%
    case 't1_to_ros_ratio'
        var.var_name = 't1_to_ros_ratio';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Ratio of Shrinking Edges that are T1s to Rosettes';
%         var.func = @(x, t) x;


    case 'perc_nlost_ros'
        var.var_name = 't1_to_ros_ratio';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Percent of Shrinking Edges that form Rosettes';
        var.func = @(x, t) (1-x./(x + 1)).*100;
        
	case 'perc_nlost_t1'
        var.var_name = 't1_to_ros_ratio';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Percent of Shrinking Edges that form T1s';
        var.func = @(x, t) (x./(x + 1)).*100;
        
%%%%%%% INCLUSION / DRIVING PARTICIPATION IN EVENTS
    case 'cells_at_least_one_event_anykind'
        var.var_name = 'node_mult_hist_passive_included_3D';
        var.file_name = 'topological_events_per_cell_extras';
%         var.title = 'Percent of Rearrangements that are T1 Transitions or Rosettes.';
        var.title = 'Percent of Cells in T1s or Rosettes';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (sum(sum(x(:,:,4:end),3)>0,2)/size(x,2)).*100;
        

    case 'cells_at_least_one_T1'
        var.var_name = 'perc_node_mult_passive_included_3D_oneplus';
        var.file_name = 'topological_events_per_cell_extras';
        var.title = 'Percent of Cells in T1 Transitions';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (x(:,4)).*100;
        
        
	case 'cells_at_least_one_rosette'
        var.var_name = 'nodemult_allros_passive_oneplus';
        var.file_name = 'topological_events_per_cell_extras';
        var.title = 'Percent of Cells in Rosettes';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (x).*100;
        
	case 'cells_at_least_two_rosettes'
        var.var_name = 'nodemult_allros_passive_twoplus';
        var.file_name = 'topological_events_per_cell_extras';
        var.title = 'Percent of Cells in Two or More Rosettes';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (x).*100;
        
	case 'cells_w_edges_shrink_into_at_least_one_event_anykind'
        var.var_name = 'cells_lost_hist';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.file_name = 'topological_events_per_cell';
        var.title = 'Percent of Cells in T1s or Rosettes (Contracting Only)';
        var.func = @(x,t) (1-sum(x==0,2)./size(x,2)).*100;
        
	case 'cells_w_edges_shrink_into_at_least_one_T1'
        var.var_name = 'perc_node_mult_3D_oneplus';
        var.file_name = 'topological_events_per_cell_extras';
        var.title = 'Percent of Cells in T1 Transitions (Contracting Only)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) x(:,4).*100;
        
	case 'cells_w_edges_shrink_into_at_least_one_rosette'
        var.var_name = 'nodemult_allros_active_oneplus';
        var.file_name = 'topological_events_per_cell_extras';
        var.title = 'Percent of Cells in Rosettes (Contracting Only)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (x).*100;

        
	case 'cells_w_edges_shrink_into_at_least_two_rosettes'
        var.var_name = 'nodemult_allros_active_twoplus';
        var.file_name = 'topological_events_per_cell_extras';
        var.title = 'Percent of Cells in Two or More Rosettes (Contracting Only)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (x).*100;
        
                
%%%% POLARITY VARIABLES
	case 'polarity_basic_tag_name_dependent'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Polarity (Basic)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.notes = 'needs combine_many_polarities_SEGGA';
        var.pol_field_name = 'big_pol_mat';
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'basic_pol';
        
	case 'polarity_normed_tag_name_dependent'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Polarity (Normalized)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.notes = 'needs combine_many_polarities_SEGGA';
        var.pol_field_name = 'big_pol_mat_normed';
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'normed_pol';
        
        
	case 'polarity_orderscore_tag_name_dependent'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Polarity (Edge Angular Ordering Score)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.notes = 'needs combine_many_polarities_SEGGA';
        var.pol_field_name = 'big_pol_mat_stack';
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'order_score_pol';
        
    case 'cortical_to_cyto'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Cortical to Cytoplasmic';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.notes = 'needs combine_many_polarities_SEGGA';
        var.pol_field_name = 'big_cortical_to_cyto_mat';
        var.ylabel_txt = 'Log2(ratio)';
        var.save_name = 'cortical2cyto';
        
	case 'polarity_basic_chan_one'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Polarity (Basic) Chan One';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) x(1).cell_avg.polarity;
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'basic_pol';
        
	case 'polarity_basic_chan_two'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Polarity (Basic) Chan Two';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) x(min(length(x),2)).cell_avg.polarity.*(length(x)-1);
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'basic_pol';
        
	case 'polarity_normed_chan_one'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Norm Cell Polarity (Basic) Chan One';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) x(1).cell_avg.polarity./max(abs(x(1).cell_avg.polarity));
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'basic_pol';
        
        
	case 'polarity_normed_chan_two'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Norm Cell Polarity (Basic) Chan Two';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) (x(min(length(x),2)).cell_avg.polarity).*(length(x)-1)./max(abs(x(min(length(x),2)).cell_avg.polarity));
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'basic_pol';
        
	case 'polarity_orderscore_chan_one'
        var.var_name = 'polarity_scores';
        var.file_name = 'polarity_scores';
        var.title = 'Cell Polarity (Edge Angular Ordering Score) Chan One';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) x(1).scoreList;
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'order_score_pol';
        
	case 'polarity_orderscore_chan_two'
        var.var_name = 'polarity_scores';
        var.file_name = 'polarity_scores';
        var.title = 'Cell Polarity (Edge Angular Ordering Score) Chan Two';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) x(min(length(x),2)).scoreList*(length(x)-1);
        var.ylabel_txt = 'Log2(polarity)';
        var.save_name = 'order_score_pol';
        
    
    case 'cortical_to_cyto_chan_one'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Cortical to Cytoplasmic Chan One';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) log2((x(1).cell_avg.cytoplasm_unadjusted+x(1).cell_avg.mean_edge_intensity)./...
                x(1).cell_avg.cytoplasm_unadjusted);
        var.ylabel_txt = 'Log2(ratio)';
        var.save_name = 'cortical2cyto';
        
	case 'cortical_to_cyto_chan_two'
        var.var_name = 'channel_info';
        var.file_name = 'edges_info_cell_background';
        var.title = 'Cell Cortical to Cytoplasmic Chan Two';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.func = @(x, t) log2((x(min(length(x),2)).cell_avg.cytoplasm_unadjusted+x(min(length(x),2)).cell_avg.mean_edge_intensity)./...
                x(min(length(x),2)).cell_avg.cytoplasm_unadjusted.*(length(x)-1));
        var.ylabel_txt = 'Log2(ratio)';
        var.save_name = 'cortical2cyto';
      


    case 'rot_edges_chan_one'
        var.var_name = 'aligned_levels';
        var.file_name = 'rotating_edges';
        var.title = 'rotating (from <30 to >70) ';
        var.get_name_from_chan = true;
        var.boundary_r = 2;
        var.boundary_l = 2;
        var.color = [1 0.5 0];
        var.func = @(x, t) x(1).mean;
        var.xvals_func = @(x, t) x(1).xvals;
        var.name_func = @(x, t) x(1).chan_name;
        var.start_title = 'rot. dv->ap channel (1): ';
        
	case 'rot_edges_chan_two'
        var.var_name = 'aligned_levels';
        var.file_name = 'rotating_edges';
        var.title = 'rotating (from <30 to >70) ';
        var.get_name_from_chan = true;
        var.boundary_r = 2;
        var.boundary_l = 2;
        var.color = [0 1 0];
        var.func = @(x, t) x(2).mean;
        var.xvals_func = @(x, t) x(2).xvals;
        var.name_func = @(x, t) x(2).chan_name;
        var.start_title = 'rot. dv->ap channel (2): ';
        
        
        
%%%%%%%%%%%%%%%%%%%%%%% ELONGATION CONTRIBUTION   
% % % % % %     
%         
%%%% Using Static Cells Avg Behavior VS Elongation Curve to find
%%%% Contributions
	case 'cell_deform_contrib_frac'
        var.var_name = 'deform_contrib_frac';
        var.file_name = 'elon_contribs';
        var.title = 'Cell Stretching Fraction Contribution to Elon (from all cells)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0];
        var.data_gen_func = 'elon_contribs_script';
        var.force_rerun = true;
        
        
	case 'interc_contrib_frac'
        var.var_name = 'interc_contrib_frac';
        var.file_name = 'elon_contribs';
        var.title = 'Intercalation Fraction Contribution to Elon (1-deform_contrib_frac)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0 0.8];
        var.data_gen_func = 'elon_contribs_script';
        
        
	case 'cell_deform_contrib_amount'
        var.var_name = 'deform_contrib_amount';
        var.file_name = 'elon_contribs';
        var.title = 'Cell Stretching Amount Contribution to Elon (from all cells)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0];
        var.data_gen_func = 'elon_contribs_script';
        
        
	case 'interc_contrib_amount'
        var.var_name = 'interc_contrib_amount';
        var.file_name = 'elon_contribs';
        var.title = 'Intercalation Stretching Amount Contribution to Elon (1-deform_contrib_frac)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0 0.8];
        var.data_gen_func = 'elon_contribs_script';
        
        
        
    case 'direct_cell_deform_contrib_frac'
        var.var_name = 'deform_contrib_direct_frac';
        var.file_name = 'elon_contribs';
        var.title = 'Cell Stretching Fraction Contribution to Elon (same group as elon)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0];
        var.data_gen_func = 'elon_contribs_script';
        
        
	case 'direct_interc_contrib_frac'
        var.var_name = 'interc_direct_contrib_frac';
        var.file_name = 'elon_contribs';
        var.title = 'Intercalation Fraction Contribution to Elon (1-deform_contrib_direct_frac)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0 0.8];
        var.data_gen_func = 'elon_contribs_script';
        
        
	case 'direct_cell_deform_contrib_amount'
        var.var_name = 'deform_contrib_direct_amount';
        var.file_name = 'elon_contribs';
        var.title = 'Cell Stretching Amount Contribution to Elon (same group as elon)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0];
        var.data_gen_func = 'elon_contribs_script';
        
        
        
	case 'direct_interc_contrib_amount'
        var.var_name = 'interc_direct_contrib_amount';
        var.file_name = 'elon_contribs';
        var.title = 'Intercalation Amount Contribution to Elon (1-deform_contrib_direct_amount)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0 0.8];
        var.data_gen_func = 'elon_contribs_script';
        
        
	case 'tissue_elon_change'
        var.var_name = 'hor';
        var.func = @(x,t) x/x(max(-t, 0)+1)-1;
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0 0];
        var.file_name = 'elon';
        var.title = 'Normalized Tissue Horizontal Length Change';
        
%%%% Using Tracked Cells (Frame to Frame): Geom VS Tissue Elon
%%%% Contributions        
        
	case 'delta_hor_cells_mean'
        var.var_name = 'delta_hor_cells_mean';
        var.file_name = 'elon_contribs';
        var.title = 'Strain (Hor) on All Cells (Full Pop, Separate)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0.3];
        var.data_gen_func = 'elon_contribs_script';
        
	case 'cum_delta_hor_cells_mean'
        var.var_name = 'delta_hor_cells_mean';
        var.file_name = 'elon_contribs';
        var.title = 'Cumulative (Sum) Strain (Hor) on All Cells (Full Pop, Separate)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0.3];
        var.func = @(x, t) cumsum(x)-sum(x(1:max(-t, 0)+1));
        var.data_gen_func = 'elon_contribs_script';
%         var.force_rerun = true;

	case 'cum_delta_hor_cells_mean_elongroup'
        var.var_name = 'delta_hor_cells_mean_elongroup';
        var.file_name = 'elon_contribs';
        var.title = 'Cumulative (Sum) Strain (Hor) on All Cells (Full Pop, Separate)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.8 0.3];
        var.func = @(x, t) cumsum(x)-sum(x(1:max(-t, 0)+1));
        var.data_gen_func = 'elon_contribs_script';


        
        
	case 'delta_hor_tissue'
        var.var_name = 'delta_hor_tissue';
        var.file_name = 'elon_contribs';
        var.title = 'Strain on Tissue (Frame to Frame, Full ROI)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.3 0 0.8];
        var.data_gen_func = 'elon_contribs_script';
        
        
	case 'cum_delta_hor_tissue'
        var.var_name = 'delta_hor_tissue';
        var.file_name = 'elon_contribs';
        var.title = 'Cumulative (Sum) Strain on Tissue (Frame to Frame, Full ROI)';
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.3 0 0.8];
        var.func = @(x, t) cumsum(x)-sum(x(1:max(-t, 0)+1));
        var.data_gen_func = 'elon_contribs_script';
        

	case 'cells_horiz_contrib'
        var.var_name = 'cells_hor';
        var.func = @(x,t) x/x(max(-t, 0)+1)-1;
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.9 0.4 0];
        var.file_name = 'elon_contribs';
        var.title = 'Norm Len chng from Cells Strain (Full Pop, Separate)';
        var.data_gen_func = 'elon_contribs_script';
        
	case 'cells_horiz_elongroup_contrib'
        var.var_name = 'cells_hor_elongroup';
        var.func = @(x,t) x/x(max(-t, 0)+1)-1;
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.8 0 0];
        var.file_name = 'elon_contribs';
        var.title = 'Norm Len chng from Cells Strain (elon Group)';
        var.data_gen_func = 'elon_contribs_script';
        
        
        
	case 'tissue_change_from_tissue_strain_full_roi'
        var.var_name = 'tiss_hor';
        var.func = @(x,t) x/x(max(-t, 0)+1)-1;
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.9 0 0.8];
        var.file_name = 'elon_contribs';
        var.title = 'Norm Len chng from Tissue Strain (Full ROI)';
        var.data_gen_func = 'elon_contribs_script';
        
	case 'tissue_change_from_tissue_strain_rep_roi'
        var.var_name = 'rep_hor';
        var.func = @(x,t) x/x(max(-t, 0)+1)-1;
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.9 0.9];
        var.file_name = 'elon_contribs';
        var.title = 'Norm Len chng from Tissue Strain (Elon ROI)';
        var.data_gen_func = 'elon_contribs_script';
        
	case 'tissue_change_from_tissue_strain_dup'
        var.var_name = 'rep_hor';
        var.func = @(x,t) x/x(max(-t, 0)+1)-1;
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.8 0 0];
        var.file_name = 'elon_contribs';
        var.title = 'Norm Len chng from Elon Measurment';
        var.data_gen_func = 'elon_contribs_script';
        
	case 'tissue_strain_cumsum_from_cell_tensors'
        var.var_name = 'x_strain_series';
        var.func = @(x,t) cumsum(x)-sum(x(1:max(-t, 0)));
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0.8 0.5 0];
        var.file_name = 'tissue_strain_data';
        var.title = 'Cumulative (Sum) Tissue Strain from Cell Tensors';
        var.data_gen_func = 'tissue_strain_and_rotation';
%         var.force_rerun = true;
        
	case 'tissue_strain_cumprod_from_cell_tensors'
        var.var_name = 'x_strain_series';
        var.func = @(x,t) cumprod(1+x)-get_last(cumprod(1+x(1:max(-t, 0))));
        var.boundary_r = 1;
        var.boundary_l = 1;
        var.color = [0 0.5 0.8];
        var.file_name = 'tissue_strain_data';
        var.title = 'Cumulative (Prod) Tissue Strain from Cell Tensors';
        var.data_gen_func = 'tissue_strain_and_rotation';
        var.force_rerun = true;
        
        
        
        
        
    otherwise
        var = [];
        name_not_found = true;
        
        
end


