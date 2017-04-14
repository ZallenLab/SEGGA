function angs = edge_ang_by_cells(edges,seq,misc)

% edges = edges_global_ind;
angs = nan(length(seq.frames),length(edges));


for i = 1:length(seq.frames)
    

    local_edges = seq.edges_map(i,edges);
    local_edges_exist = ~(local_edges==0);
    local_edges = nonzeros(local_edges);
    
    global_cells = misc.edges_by_cells(edges,:);
    
    local_cells1 = seq.cells_map(i,global_cells(local_edges_exist,1));
    local_cells2 = seq.cells_map(i,global_cells(local_edges_exist,2));
    
    local_centers1 = seq.frames(i).cellgeom.circles(local_cells1,[1,2]);
    local_centers2 = seq.frames(i).cellgeom.circles(local_cells2,[1,2]);
    
    x1 = local_centers1(:,2);
    x2 = local_centers2(:,2);
    y1 = local_centers1(:,1);
    y2 = local_centers2(:,1);
    
    
    centers_ang = 180 * (atan2((y2-y1) , (x2 - x1))) / pi;
    centers_ang = mod(centers_ang, 180);
    centers_ang = abs(90 - centers_ang);
%     centers_ang = 90 - abs(90 - centers_ang)
    
    angs(i,local_edges_exist) = centers_ang;
    
end
    