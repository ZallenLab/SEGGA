function [all_possible_variables,all_possible_display_names] = give_possible_variables_to_SEGGA_polarity_by_chan_num()


all_possible_variables = {...
        'polarity_basic_chan_one',...
        'polarity_basic_chan_two',...
        'polarity_normed_chan_one',...
        'polarity_normed_chan_two',...
        ...'polarity_orderscore_chan_one',...
        ...'polarity_orderscore_chan_two',...
        'cortical_to_cyto_chan_one'...
        'cortical_to_cyto_chan_two'...
%         'polarity_spatial_correlation'...
        };


all_possible_display_names = {...
        'Cell Polarity (Log2) - Chan One',...
        'Cell Polarity (Log2) - Chan Two',...
        'Cell Polarity Normalized to Max (Log2) - Chan One',...
        'Cell Polarity Normalized to Max (Log2) - Chan Two',...
        ...'Angular Order of Edge Intensities - Chan One',...
        ...'Angular Order of Edge Intensities - Chan Two',...
        'Cortical to Cytoplasmic Intensity Ratio (Log2) - Chan One'...
        'Cortical to Cytoplasmic Intensity Ratio (Log2) - Chan Two'...
%         'Spatial Correlation of Cell Polarity'...
        };


    
