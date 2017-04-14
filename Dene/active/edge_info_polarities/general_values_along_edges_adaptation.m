function general_values_along_edges_adaptation(previous_savename,new_savename,base_dir,seg_filename,...
                                                options,channel_info,load_existing,runanalysis,analysis_type)


if nargin<9 || isempty(analysis_type)
    analysis_type = 'basic';
end

[seg_dir, ~, ~] = fileparts(seg_filename);

if load_existing
    cd(base_dir)
%     cd('seg')
    cd(seg_dir)
    load(previous_savename, 'seq', 'edges', 'x1', 'x2', 'y1', 'y2')
    
    if isempty(whos('seq'))
        seq = load_dir(pwd);
    end
    seq = update_seq_dir(seq);
    seq.directory = pwd;
    data = seq2data(seq);
else
%     cd(base_dir)
%     cd('seg')
    cd(seg_dir);
    seq = load_dir(pwd);
    seq = update_seq_dir(seq);
    data = seq2data(seq);
    edges = find(any(data.edges.selected));
end




if load_existing
    options.edge_positions_from_options = true;
    options.x1 = x1;
    options.x2 = x2;
    options.y1 = y1;
    options.y2 = y2;
else
    options.edge_positions_from_options = false;
end

options.smoothen_edges = true & ~options.edge_positions_from_options;
options.optimize_edges_pos = true & ~options.edge_positions_from_options;

if runanalysis
        switch analysis_type
            case 'basic'
                values_along_edges(base_dir, seg_filename, channel_info, seq, ...
                data, options, new_savename, edges)
            case 'full_profile'
                values_along_edges_full_profiles(base_dir, seg_filename, channel_info, seq, ...
                data, options, [new_savename,'_full_profiles'], edges)
        end
end
