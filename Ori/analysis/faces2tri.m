function tri = faces2tri(faces)
faces(isnan(faces)) = 0;
num_tri = sum(faces(:) > 0);
tri = zeros(num_tri, 4);

last_tri_num = 1;
for i=1:length(faces(:,1));
    f_nodes = nonzeros(faces(i,:));
    f_nodes2 = [f_nodes(end); f_nodes(1:end-1)]; % = circshift(f_nodes, 1);
    f_nodes0 = [f_nodes(2:end); f_nodes(1)]; % = circshift(f_nodes, -1);    
    l = length(f_nodes);
    tri(last_tri_num:last_tri_num + l - 1, 1) = f_nodes0;
    tri(last_tri_num:last_tri_num + l - 1, 2) = f_nodes;
    tri(last_tri_num:last_tri_num + l - 1, 3) = f_nodes2;
    tri(last_tri_num:last_tri_num + l - 1, 4) = i;
    last_tri_num =last_tri_num +l;
end
