function [node1 node2] = reposition_edge(pad_img, cellgeom, edge, rad)
[can_nhood_x2 can_nhood_y2] = find(circle(rad));
can_nhood_x2 = can_nhood_x2 - (rad + 1);
can_nhood_y2 = can_nhood_y2 - (rad + 1);

[m n] = size(pad_img);
nodes = round(cellgeom.nodes);
edges = cellgeom.edges;
temp_var = nodes;
nodes(:,1) = temp_var(:,2) + 2*rad;
nodes(:,2) = temp_var(:,1) + 2*rad;

num_iter = 1;
for cnt = 1:num_iter
    repo_inter(cellgeom.edges(edge, :));
    repo_inter(cellgeom.edges(edge, [2 1]));
end
node1 = nodes(cellgeom.edges(edge, 1), [2 1]) - 2*rad;
node2 = nodes(cellgeom.edges(edge, 2), [2 1]) - 2*rad;

    function repo_inter(ed_nodes)
    node = ed_nodes(1);
    end_node = ed_nodes(2);
    ed_2_mv = edges(edges(:,1) == node, 2);
    ed_2_mv = [ed_2_mv; edges(edges(:,2) == node, 1)];

    nhood_x = can_nhood_x2;
    nhood_y = can_nhood_y2;
    score = zeros(length(nhood_x), 1);
    lens = zeros(size(ed_2_mv));
    for j = 1:length(ed_2_mv)
        lens(j) = realsqrt(sum((nodes(node,:) - nodes(ed_2_mv(j), :)).^2));
    end
    for k = 1:length(nhood_x)
        node_new_pos = nodes(node,:) + [nhood_y(k) nhood_x(k)];
        for j = 1:length(ed_2_mv)
            if max(abs(node_new_pos - nodes(ed_2_mv(j), :))) < 1
                ed_score = -inf;
            else
                ed_score = check_for_myo(pad_img, node_new_pos, nodes(ed_2_mv(j),:), 'weighted_sum', [], 1, 2);
                if isnan(ed_score)
                    ed_score = 0; %CHANGE TO -INF? TO THE MINIMUM OF PAD_IMG?
                end
                if ed_2_mv(j) == end_node
                    ed_score = ed_score * 2;
                end
                ed_score = ed_score * lens(j);
            end
            score(k) = score(k) + ed_score;
        end
    end
    [dummy k] = max(score);
    nodes(node,:) = nodes(node, :) + [nhood_y(k) nhood_x(k)];
    end
end