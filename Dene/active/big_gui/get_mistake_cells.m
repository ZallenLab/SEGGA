function seq = get_mistake_cells(in_seq)

    seq = in_seq;
%     global seq
    
    %%% make the 'orbit'
    l = seq.min_t;
    r = seq.max_t;
    b = seq.min_z;
    t = seq.max_z;


    orbit = nonzeros(seq.frames_num(l:r, b:t))';
    
   %%% Highlight everything in poly_seq 
    filename = 'poly_seq.mat';
if ~length(dir(filename))
    h = msgbox('could not find poly_seq.mat in current directory', '', 'warn', 'modal');
    waitfor(h)
    return
end


s = load(filename);
poly_seq = s.poly_seq;
poly_frame_ind = s.poly_frame_ind;
for i = orbit
    %assuming frame numbers are sorted. the poly/frame with the closest t and z
    %indices should be used, not the one with the closest frame index. 
    [dummy poly_ind(i)] = min(abs(i - poly_frame_ind));
end


for i = orbit
    x = poly_seq(poly_ind(i)).x; 
    y = poly_seq(poly_ind(i)).y;
    if false %strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
        limit_to = false(length(seq.frames(i).cellgeom.circles(:, 1)), 1);
        limit_to(seq.frames(i).cells) = true;
    else
        limit_to = [];
    end
    
    new_selection = cells_in_poly(seq.frames(i).cellgeom, y, x);
    if nargin > 5 && ~isempty(limit_to)
        new_selection = new_selection & limit_to;
    end

    seq.frames(i).cells = find(new_selection);

end




    %%% highlight faulty cells within the poly
for frm_cnt = 1:length(orbit)
    i = orbit(frm_cnt);
    all_cells = nonzeros(seq.inv_cells_map(i, :));
    if isfield(seq.frames(i),'next_frame')
        n = seq.frames(i).next_frame;
    else
        n = [];
        return
    end
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
    if  true %strcmp(get(handles.lim_to_sel_edges_menu, 'checked'), 'on')
        temp_fc = false(1, length(seq.frames(i).cellgeom.circles(:, 1)));
        temp_fc2 = temp_fc;
        temp_fc(fc) = true;
        temp_fc2(seq.frames(i).cells) = true;
        fc = find(temp_fc & temp_fc2);
    end
        
    seq.frames(i).cells = fc;
end



% function seq = highlight_inside_poly(x, y, i, limit_to, seq)
% new_selection = cells_in_poly(seq.frames(i).cellgeom, y, x);
% if nargin > 5 && ~isempty(limit_to)
%     new_selection = new_selection & limit_to;
% end
%     
% seq.frames(i).cells = find(new_selection);


