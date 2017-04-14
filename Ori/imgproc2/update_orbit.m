function seq = update_orbit(seq, cells, cells_colors, cells_alphas, ...
    t_val, z, orbit, edges, cell_states, edge_states, apply_to_all, within_high)

if nargin < 12
    within_high = 0;
end 
pos = find(orbit == seq.frames_num(t_val,z));
cells_ind = seq.inv_cells_map(orbit(pos), cells);

%Remove some single cell edges.
if ~apply_to_all
    edge_states = edge_states(1:(min(length(seq.inv_edges_map(1, :)), length(edge_states))));
    valid_ind = find(seq.inv_edges_map(orbit(pos), 1:length(edge_states)));
    edges_states_global(seq.inv_edges_map(orbit(pos), valid_ind)) = ...
        edge_states(valid_ind);
end
edges = edges(edges < length(seq.inv_edges_map(orbit(pos), :))); 
edges_ind = nonzeros(seq.inv_edges_map(orbit(pos), edges)); %the zeros come 
%from boundary edges. Each boundary edge is part of a single cell and thus not
%part of the edges_map.

cells_colors_global(cells_ind, :) = cells_colors(cells, :);
cells_alphas_global(cells_ind) = cells_alphas(cells);

cells_colors = cells_colors(seq.cells_map(orbit(pos), cells_ind), :);
cells_alphas = cells_alphas(seq.cells_map(orbit(pos), cells_ind));
cells_alphas = reshape(cells_alphas, [], 1);



for i = 1:length(orbit)
    if ~isfield(seq.frames(orbit(i)), 'cells_alphas') || ...
            isempty(seq.frames(orbit(i)).cells_alphas)
        seq.frames(orbit(i)).cells_alphas = 0.2*...
            ones(length(seq.frames(orbit(i)).cellgeom.circles(:,1)), 1);
    end
    if apply_to_all
        if within_high
            cells = false(1,length(seq.frames(i).cellgeom.circles(:,1)));
            cells(seq.frames(i).cells) = true;
            
            edges = false(1,length(seq.frames(i).cellgeom.edges(:,1)));
            edges(seq.frames(i).edges) = true;
        else
            cells = true(1,length(seq.frames(i).cellgeom.circles(:,1)));
            edges = true(1,length(seq.frames(i).cellgeom.edges(:,1))); 
        end
        temp_cells = false(1,length(seq.frames(i).cellgeom.circles(:,1)));
        temp_cells(nonzeros(seq.cells_map(orbit(i), cells_ind))) = true;
        cells = temp_cells & cells;
        
        temp_edges = false(1,length(seq.frames(i).cellgeom.edges(:,1)));
        temp_edges(nonzeros(seq.edges_map(orbit(i), edges_ind))) = true;
        edges = edges & temp_edges;
        
        seq.frames(orbit(i)).edges = find(edges);
        seq.frames(orbit(i)).cells = find(cells);
        seq.frames(orbit(i)).cells_colors = ...
            zeros(length(seq.frames(orbit(i)).cellgeom.circles(:,1)),3);
        seq.frames(orbit(i)).cells_alphas = 0.2 * ...
            ones(length(seq.frames(orbit(i)).cellgeom.circles(:,1)),1);
        
        if ~isempty(seq.frames(orbit(i)).cells)
            seq.frames(orbit(i)).cells_colors(cells, :) = ...
                cells_colors_global(seq.inv_cells_map(orbit(i), cells), :);
            seq.frames(orbit(i)).cells_alphas(cells) = ...
                cells_alphas_global(seq.inv_cells_map(orbit(i), cells));
        end
    else
        temp_edges = false(1, length(seq.frames(orbit(i)).cellgeom.edges(:,1)));
        temp_edges(nonzeros(seq.frames(orbit(i)).edges)) = true;
        frame_edges = seq.edges_map(orbit(i), edges_ind);
        temp_edges(nonzeros(frame_edges)) = edges_states_global(edges_ind(find(frame_edges)));
        seq.frames(orbit(i)).edges = find(temp_edges);
        
        temp_cells = false(1, length(seq.frames(orbit(i)).cellgeom.circles(:,1)));
        temp_cells(seq.frames(orbit(i)).cells) = true;
        frame_cells = seq.cells_map(orbit(i), cells_ind);
        temp_cells(nonzeros(frame_cells)) = cell_states(cells(find(frame_cells)));
        seq.frames(orbit(i)).cells = find(temp_cells);
        seq.frames(orbit(i)).cells_colors(nonzeros(frame_cells), :) = ...
            cells_colors(find(frame_cells), :);
        seq.frames(orbit(i)).cells_alphas(nonzeros(frame_cells)) = ...
            cells_alphas(find(frame_cells));
        
        seq.frames(orbit(i)).cells_alphas = ...
            reshape(seq.frames(orbit(i)).cells_alphas, [], 1);
            
    end
       
end
