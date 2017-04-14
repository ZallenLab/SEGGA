function [all_possible_variables,all_possible_variables_display_names] = give_possible_variables_to_SEGGA_basic()


all_possible_variables = {...
    	'num_cells_sel',... %'Number of cells selected',...
        'nghbrs_lost_per_cell',... % 'Neighbors lost per cell',... 
        't1_per_cell',... % 'T1 transitions per cell',...
        'ros_per_cell',... % 'Rosettes per cell',...
        'nghbrs_gained_per_cell',... % 'Neighbors gained per cell',...
        'hor_elon',... % 'Normalized tissue horizontal length',...
        'longaxis_elon',... % 'Normalized tissue long axis length',...
        'ver_elon',... % 'Normalized tissue vertical length',...
        'shortaxis_elon',... % 'Normalized tissue short axis length',... 
        'hor_to_ver_ratio',... % 'Tissue aspect ratio (horizontal to vertical length ratio)',...
        'L1_to_L2_ratio',... % 'Tissue aspect ratio (long axis to short axis length ratio)',...
        'norm_hor_to_ver_ratio',... % 'Normalized tissue aspect ratio (horizontal to vertical length ratio)',...
        'norm_L1_to_L2_ratio',... % 'Normalized tissue aspect ratio (long axis to short axis length ratio)',...
        'top_dis',... % 'Topological disorder',...
        'num_nghbrs',... % 'Number of neighbors',... 
        'node_multiplicity',... % 'Node multiplicity',... 
        'edge_align',... % 'Vertical edge alignment',... 
        'cell_hor_length',... % 'Cell horizontal length',... 
        'cell_ver_length',... % 'Cell vertical length',...         
        'norm_cell_hor_length',... % 'Normalized cell horizontal length',... 
        'norm_cell_ver_length',... % 'Normalized cell vertical length',... 
        'cell_hortovert_length',... % 'Cell horizontal to vertical length ratio',... 
        'cell_vertohor_length',... % 'Cell vertical to horizontal length ratio',...
        'norm_cell_hortovert_length',... % 'Normalized cell horizontal to vertical length ratio',... 
        'cell_area',... % 'Cell area',... 
        'norm_cell_area',... % 'Normalized cell area',... 
        'cell_area_coeff',... % 'Cell area coefficient of variation',... 
        'cell_ecc',... % 'Cell eccentricity',...
        'cell_ang',... % 'Cell orientation',...
        'pat_defo'...  % 'Pattern deformation'...
        };
    
 
all_possible_variables_display_names = {...
    'Number of cells selected',...
    'Neighbors lost per cell',... 
    'T1 transitions per cell',...
    'Rosettes per cell',...
    'Neighbors gained per cell',...
    'Normalized tissue horizontal length',...
    'Normalized tissue long axis length',...
    'Normalized tissue vertical length',...
    'Normalized tissue short axis length',... 
    'Tissue aspect ratio (horizontal to vertical length ratio)',...
    'Tissue aspect ratio (long axis to short axis length ratio)',...
    'Normalized tissue aspect ratio (horizontal to vertical length ratio)',...
    'Normalized tissue aspect ratio (long axis to short axis length ratio)',...
    'Topological disorder',...
    'Number of neighbors',... 
    'Node multiplicity',... 
    'Vertical edge alignment',... 
    'Cell horizontal length',... 
    'Cell vertical length',... 
    'Normalized cell horizontal length',... 
    'Normalized cell vertical length',... 
    'Cell horizontal to vertical length ratio',... 
    'Cell vertical to horizontal length ratio',...
    'Normalized cell horizontal to vertical length ratio',... 
    'Cell area',... 
    'Normalized cell area',... 
    'Cell area coefficient of variation',... 
    'Cell eccentricity',...
    'Cell orientation',...
    'Pattern deformation'...
        };