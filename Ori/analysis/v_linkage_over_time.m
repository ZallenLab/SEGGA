function v = v_linkage_over_time(seq, data, all_links, theta, shift)
[v_linked vertical_edges] = find_vert_linked(seq, data, all_links, theta, shift);
v = sum(v_linked, 2) ./ sum(vertical_edges, 2);

function [v_linked vertical_edges] = find_vert_linked(seq, data, all_links, theta, shift)
vertical_edges = abs(data.edges.angles - (90 + shift)) < theta;
vertical_edges = vertical_edges & data.edges.selected;
% vertical_edges = vertical_edges & data.edges.len > 10;
v_linked = false(size(vertical_edges));
for i = 1:length(seq.frames);
    for j = find(vertical_edges(i, :) & data.edges.selected(i, :) > 0 );
        linked = all_links(j).edges(all_links(j).on(i, :));
        if any(vertical_edges(i, linked))
            v_linked(i, j) = true;
        end
    end
end
        
        