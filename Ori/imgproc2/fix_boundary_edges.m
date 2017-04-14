function [geom changed_geom] = fix_boundary_edges(geom)
while 1
    [geom changed_geom] = fix_one_component(geom);
    if ~changed_geom
        break
    end
    geom = fix_geom(geom);
end

function [geom changed_geom] = fix_one_component(geom)
changed_geom = false;
[bord_comp border_edges] = border_components(geom);
%border_components(i).items is a list of nodes for the i-th border
%component
if length(bord_comp) < 2
    return
end
comp_size = cellfun(@length, {bord_comp.nodes});
[dummy order] = sort(comp_size);
for i = order
    if comp_size(i) > 10
        return
    end
    nodes = bord_comp(i).nodes;
    node1 = ismember(geom.edges(:, 1), nodes, 'legacy');
    node2 = ismember(geom.edges(:, 2), nodes, 'legacy');
    cand_edges = node1 & node2;
    border_edges_of_comp = find(cand_edges & border_edges);
    internal_edges_of_comp = find(cand_edges & ~border_edges);
    if ~isempty(internal_edges_of_comp)
        [geom success] = collapse_edge(geom, ...
                         geom.edges(internal_edges_of_comp(1),1), ...
                         geom.edges(internal_edges_of_comp(1),2), 1, 0);
         if success
            changed_geom = true;
            break
         end
    end
    if comp_size(i) < 3
        [geom success] = collapse_edge(geom, ...
                         geom.edges(border_edges_of_comp(1),1), ...
                         geom.edges(border_edges_of_comp(1),2), 1, 0);
         if success
            changed_geom = true;
            break
         end
    end
    [is_loop loop] = edges_form_loop(geom ,border_edges_of_comp);
    if is_loop
        [geom success] = loop2cell(geom, loop);
         if success
            changed_geom = true;
            break
         end
    end
end

function [is_loop loop] = edges_form_loop(geom ,edges)
is_loop = false;
loop = [];
if isempty(edges)
    return
end
done_edges = false(size(edges));
edge_ind = 1;
edge = edges(edge_ind);
first_node = geom.edges(edge, 1);
loop = first_node;
next_node_ed_ind = 2;


while ~isempty(edge_ind)
    edge = edges(edge_ind);
    done_edges(edge_ind) = true;
    node = geom.edges(edge, next_node_ed_ind);
    loop = [loop node];
    edge_ind = find(geom.edges(edges, 1) == node & ~done_edges);
    if ~isempty(edge_ind) 
        next_node_ed_ind = 2;
    else
        edge_ind = find(geom.edges(edges, 2) == node & ~done_edges);
        next_node_ed_ind = 1;
    end
    if length(edge_ind) > 1
        return
    end
end
if node == first_node
    is_loop = true;
    loop = loop(1:(end-1));
end
    
function [geom success] = loop2cell(geom, loop)
success = false;
[center_y center_x] = poly_centroid(geom.nodes(loop, 1), geom.nodes(loop, 2));
if cell_from_pos(center_x, center_y, geom)
    return
end

geom.nodecellmap(end +(1:length(loop)), 1) = length(geom.circles)+1;
geom.nodecellmap(end + 1 - (length(loop):-1:1), 2) = loop;

geom.circles(end+1,1:2) = [center_y center_x];

success = true;