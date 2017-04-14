function nodes = reposition(cellgeom, img, sel_nodes)
rad = 3;
rad2= 2;
[can_nhood_x can_nhood_y] = find(circle(rad));
can_nhood_x = can_nhood_x - (rad + 1);
can_nhood_y = can_nhood_y - (rad + 1);
can_weight = (rad.^2 + 1 - (can_nhood_x.^2 + can_nhood_y.^2)).^2;

[can_nhood_x2 can_nhood_y2] = find(circle(rad2));
can_nhood_x2 = can_nhood_x2 - (rad2 + 1);
can_nhood_y2 = can_nhood_y2 - (rad2 + 1);

pad_img = zeros(size(img) + [4*rad 4*rad]);
pad_img(2*rad + 1: end - 2*rad, 2*rad + 1: end - 2*rad) = -50 + double(img);
[m n] = size(pad_img);
nodes = round(cellgeom.nodes);
edges = cellgeom.edges;
nodes(:,1) = nodes(:,1) + 2*rad;
nodes(:,2) = nodes(:,2) + 2*rad;


for l = 1:length(sel_nodes)
    i = sel_nodes(l);
    ed_2_mv = edges(find(edges(:,1) == i),2);
    ed_2_mv = [ed_2_mv; edges(find(edges(:,2) == i),1)];
%     ind = [];
%     edge_origin = [];
%     for j = 1:length(ed_2_mv)
%         new_ind = connect_line(nodes(i,:), nodes(ed_2_mv(j),:))';
%         ind = [ind; new_ind];
%         edge_origin(end + 1 : end + 1 + length(new_ind)) = j;
%     end
%     nhood_x = [can_nhood_x2 ; ind(:,2) - nodes(i,2)];     
%     nhood_y = [can_nhood_y2 ; ind(:,1) -  nodes(i,1)];
%     verify_ind = length(nhood_y) - length(ind(:,1));
%     [dummy1 unique_ind dummy2] = unique([nhood_x nhood_y], 'rows');
%     nhood_x = nhood_x(unique_ind);
%     nhood_y = nhood_y(unique_ind);

    nhood_x = [can_nhood_x2];
    nhood_y = [can_nhood_y2];
    score = zeros(length(nhood_x), 1);
    for k = 1:length(nhood_x)
        node_new_pos = nodes(i,:) + [nhood_y(k) nhood_x(k)];
%         if unique_ind(k) > verify_ind
%             for j = setdiff(1:length(ed_2_mv), edge_origin(unique_ind(k) - verify_ind));
%                 tri = double([nodes(i,:); ...
%                     node_new_pos(1,:); ...
%                     nodes(ed_2_mv(j),:)]);
% %                 tri = double([(nodes(i,:) + nodes(ed_2_mv(j),:)) / 2; ...
% %                     (node_new_pos(1,:) + nodes(ed_2_mv(j),:)) / 2; ...
% %                     nodes(ed_2_mv(j),:)]);
%                 x = tri(:,1);
%                 y = tri(:,2);
%                 [m n] = size(pad_img);
%                 if sum(dil_img(poly2mask(x, y, m, n))) < 0;
%                     score(k) = -inf;
%                     break
%                 end
%             end
%         end
%         if score(k) ~= -inf
        weight = can_weight;
        new_ind_y = node_new_pos(:,1) + can_nhood_y;
        new_ind_x = node_new_pos(:,2) + can_nhood_x;
        %ind = sub2ind(size(pad_img), new_ind_y, new_ind_x);
        %sub2ind is slow...
        ind = (new_ind_x - 1)* m + new_ind_y; 
        for j = 1:length(ed_2_mv)
            new_ind = connect_line(node_new_pos, nodes(ed_2_mv(j),:))';
%             new_weight = [(length(new_ind):-1:1) 1:length(new_ind)]';
%             new_weight = new_weight(1:2:end);
            if size(new_ind) == [0, 0]
                new_ind = node_new_pos;
                new_weight = 1;
            else
                new_weight = ones(length(new_ind),1) * 15;
                 new_weight(1:min(3,end)) = 0;
                 new_weight(max(end-2, 1):end) = 0;        
                 %new_weight([1 end]) = 0;
            end
            %new_ind = sub2ind(size(pad_img), new_ind(:,1), new_ind(:,2));
            %sub2ind is slow...
            new_ind = (new_ind(:,2) - 1)*m + new_ind(:,1);
            ind = [ind; new_ind];
            weight = [weight; new_weight];
        end
        score(k) = sum(pad_img(ind) .* weight) / sum(weight);
%         end
    end
    [dummy k] = max(score);
    node_new_pos = round(nodes(i,:)) + [nhood_y(k) nhood_x(k)];
    nodes(i,:) = node_new_pos;
end
nodes(:,1) = nodes(:,1) - 2*rad;
nodes(:,2) = nodes(:,2) - 2*rad;
