function untracked = extern_find_untracked_cells(seq)



    for i = 1:length(seq.frames)
        all_cells = nonzeros(seq.inv_cells_map(i, :));
        n = seq.frames(i).next_frame;
        n_cells = false(size(seq.cells_map(i, all_cells)));
        p_cells = false(size(seq.cells_map(i, all_cells)));
        if ~isempty(n)
            n_cells = full(seq.cells_map(n, all_cells)) == 0;
        end
        p = seq.frames(i).prev_frame; 
        if ~isempty(p)
            p_cells = full(seq.cells_map(p, all_cells)) == 0;
        end
        fc = full(seq.cells_map(i, all_cells(p_cells | n_cells)));
        filename = 'poly_seq.mat';
        if isempty(dir(filename))
            fc = [];
        else
            load(filename);
            poly_frame_ind = i;
            [~,poly_ind] = min(abs(i - poly_frame_ind));
            X = poly_seq(poly_ind).x;
            Y = poly_seq(poly_ind).y;
            cellsY = seq.frames(i).cellgeom.circles(fc, 2);
            cellsX = seq.frames(i).cellgeom.circles(fc, 1);
            fc = fc(inpolygon(cellsX,cellsY,X,Y));
        end

        untracked(i).fc = fc;
    end
