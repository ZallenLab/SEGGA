function seq = prep_seq_for_tracking(seq_basic)
    seq = seq_basic;
    img_num = 1;
    
    seq.t = seq.frames(img_num).t;
    seq.z = seq.frames(img_num).z;
    seq.img_num = seq.frames_num(seq.t, seq.z);

    all_cells_colors = zeros(length(seq.frames(seq.img_num).cellgeom.circles(:,1)), 3);
    all_cells_alphas = zeros(length(seq.frames(seq.img_num).cellgeom.circles(:,1)), 1);
    if nargin == 1
        cells = [];
    else
        all_cells_colors(cells, :) = cells_colors;
        all_cells_alphas(cells) = cells_alphas;
    end
    
    cell_states = false(size(all_cells_alphas));
    cell_states(nonzeros(cells)) = 1;
    
    seq = update_orbit(seq, cells, all_cells_colors, all_cells_alphas, ...
        seq.t, seq.z, 1:length(seq.frames), [], cell_states, [], 1);