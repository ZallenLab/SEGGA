function [name_out, easyread_name_out] = SEGGA_single_image_analysis_output_names_mapping(pop_bool,name_in)
%%% This function maps new output names to existing names
%%% for the sake of maintaining the same names or naming paradigms
%%% within single image analyses and movie analyses
%%%
%%% INPUT
%%% pop_bool -> population level analysis (boolean), set to true for
%%% averages otherwise the mapping assumes that it is a cell based analysis
%%% that is for returning the full list of values
%%%
%%% name_in -> this will be the name already existing, whatever naming was
%%% inherited in the existing code base
%%%
%%% OUTPUT
%%% name_out -> this will be the prefered name in the final output used to
%%% generate csv files for end users.
if nargin < 2
    display('***--->need all inputs to run!<---***');
end

all_cells_names = {...
                  'area',...
                  'cell_angle',...
                  'cell_hor_ver_ratio',...
                  'cell_hor',...
                  'cell_length',...
                  'cell_ver',...
                  'cell_width',...
                  'circ',...
                  'ecc',...
                  'int_ang',...
                  'length_width_ratio',...
                  'nm',...
                  'num_sides',...
                  'pd',...
                  'peri',...
                  'qVal'...
                  };
              
avg_names = {...
                  'areas',...
                  'areas_std_over_mean',...
                  'cell_angle',...
                  'cell_hor_ver_ratio',...
                  'cell_hor',...
                  'cell_ver',...
                  'circ',...
                  'ecc',...
                  'int_ang',...
                  'length_width_ratio',...
                  'nm',...
                  'num_nghbrs',...
                  'pd',...
                  'peri',...
                  'qVal',...
                  'top_dis'...
                  };
              
name_out = [];
easyread_name_out = [];
%%% cell level data name mappings
if ~pop_bool % cell level
    switch name_in
        case 'area'
            name_out = 'cell_area';
            easyread_name_out = 'Cell Area';
        case 'cell_angle'
            name_out = 'cell_ang';
            easyread_name_out = 'Cell Angle';
        case 'cell_hor_ver_ratio'
            name_out = 'cell_hortovert_length';
            easyread_name_out = 'Cell Horizontal to Vertical Length Ratio';
        case 'cell_hor'
            name_out = 'cell_hor_length';
            easyread_name_out = 'Cell Horizontal Length';
        case 'cell_length'
            name_out = 'cell_L1_length';
            easyread_name_out = 'Cell Long Axis Length';
        case 'cell_ver'
            name_out = 'cell_ver_length';
            easyread_name_out = 'Cell Vertical Length';
        case 'cell_width'
            name_out = 'cell_L2_length';
            easyread_name_out = 'Cell Short Axis Length';
        case 'circ'
            name_out = 'cell_circularity';
            easyread_name_out = 'Cell Circularity';
        case 'ecc'
            name_out = 'cell_ecc';
            easyread_name_out = 'Cell Eccentricity';
        case 'int_ang'
            name_out = 'node_internal_angs';
            easyread_name_out = 'Internal Angles';
        case 'length_width_ratio'
            name_out = 'cell_L1_toL2_ratio';
            easyread_name_out = 'Cell Long to Short Axis Length Ratio';
        case 'nm'
            name_out = 'node_multiplicity';
            easyread_name_out = 'Node Multiplicity';
        case 'num_sides'
            name_out = 'cell_num_nghbrs';
            easyread_name_out = 'Number of Cell Sides';
        case 'pd'
            name_out = 'cell_pat_defo';
            easyread_name_out = 'Cell Pattern Deformation';
        case 'peri',...
            name_out = 'cell_perimeters';
            easyread_name_out = 'Cell Perimeter';
        case 'qVal'
            name_out = 'cell_qVals';
            easyread_name_out = 'Cell q Value';
        otherwise
            display(['condition not found [','''',name_in,'''','], need to update switch clauses']);
    end
else
    %%% population aggregate level data name mappings
    switch name_in
        case 'areas'
            name_out = 'avg_cell_area';
            easyread_name_out = 'Average Cell Area';
        case 'areas_std_over_mean'
            name_out = 'cell_area_coefficient_of_variation';
            easyread_name_out = 'Cell Area Coefficient of Variation';
        case 'cell_angle'
            name_out = 'avg_cell_ang';
            easyread_name_out = 'Average Cell Angle';
        case 'cell_hor_ver_ratio'
            name_out = 'avg_cell_hortovert_length';
            easyread_name_out = 'Average Cell Horizontal to Vertical Length Ratio';
        case 'cell_hor'
            name_out = 'avg_cell_hor_length';
            easyread_name_out = 'Average Cell Horizontal Length';
        case 'cell_ver'
            name_out = 'avg_cell_ver_length';
            easyread_name_out = 'Average Cell Vertical Length';
        case 'circ'
            name_out = 'avg_cell_circularity';
            easyread_name_out = 'Average Cell Circularity';
        case 'ecc'
            name_out = 'avg_cell_ecc';
            easyread_name_out = 'Average Cell Eccentricity';
        case 'int_ang'
            name_out = 'avg_node_internal_ang';
            easyread_name_out = 'Average Internal Angle';
        case 'length_width_ratio'
            name_out = 'avg_cell_L1_to_L2_ratio';
            easyread_name_out = 'Average Cell Long Axis to Short Axis Ratio';
        case 'nm'
            name_out = 'avg_node_multiplicity';
            easyread_name_out = 'Average Node Multiplicity';
        case 'num_nghbrs'
            name_out = 'avg_num_nghbrs';
            easyread_name_out = 'Average Number of Neighbors';
        case 'pd'
            name_out = 'avg_pat_defo';
            easyread_name_out = 'Average Cell Pattern Deformation';
        case 'peri'
            name_out = 'avg_perimeter';
            easyread_name_out = 'Average Cell Perimeter';
        case 'qVal'
            name_out = 'avg_cell_qVal';
            easyread_name_out = 'Average Cell q Value';
        case 'top_dis'
            name_out = 'top_dis';
            easyread_name_out = 'Topological Disorder';
        case 'v_linkage'
            name_out = 'edge_align';
            easyread_name_out = 'Vertical Edge Alignment';
        case 'edge_align'
            name_out = 'edge_align';
            easyread_name_out = 'Vertical Edge Alignment';
        otherwise
            display(['condition not found [','''',name_in,'''','], need to update switch clauses']);
    end
end

%%% single population metrics (avgs, stds, etc)