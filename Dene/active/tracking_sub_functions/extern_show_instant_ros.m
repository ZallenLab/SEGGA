function seq = extern_show_instant_ros(handles,seq,orbit,min_ros,max_len,max_collapse)
data = seq2data(seq);
if nargin < 4 || isempty(min_ros)
    mult_thresh = 6;
else
    mult_thresh = min_ros;
end
if nargin < 5 || isempty(max_len)
    len_thresh = 0;
else
    len_thresh = max_len;
end
if nargin < 6 || isempty(max_collapse)
    max_collapse = 1;
end
max_collapse = max(1,max_collapse);

alpha_val = 0.5;
for i = orbit
    geom = seq.frames(i).cellgeom;
    [nm, ~] = node_mult(geom, geom.selected_cells);
    [nm,adjustment_inds,additional_nodes] = ...
        adjust_node_mult_by_collapsing_short_edges(geom,nm,len_thresh,max_collapse);
    high_mult = nm>=mult_thresh;
    if sum(high_mult)>0
        nodes = find(high_mult);
        cluster_colors = jet(numel(nodes));
        [~,randinds] = sort(rand(numel(nodes),1));
        cluster_colors = cluster_colors(randinds,:);
        %nodecellmap first part is the cell, second is the node
        %selected cells below are the cells inside of the border
        %(not the cells within the ROI)
%         selected_cell_inds = ismember(geom.nodecellmap(:,1),find(geom.selected_cells));
        for ii = 1:length(nodes)
            selected_node_inds = ismember(geom.nodecellmap(:,2),nodes(ii));
            inds = selected_node_inds;
            if adjustment_inds(nodes(ii))
                additional_selected_node_inds = ismember(geom.nodecellmap(:,2),nonzeros(additional_nodes(nodes(ii),:)));
                inds = ((selected_node_inds+additional_selected_node_inds)>0);
            end
            high_mult_cells = unique(geom.nodecellmap(inds,1));
            selcells = cast(nonzeros(seq.cells_map(i, data.cells.selected(i, :))),'like',high_mult_cells);
            tempcells = intersect(selcells,high_mult_cells);
            if numel(tempcells)>0
                if ~isempty(seq.frames(i).cells)
                    high_mult_cells = cast(high_mult_cells,'like',seq.frames(i).cells);
                    new_cells = high_mult_cells(~ismember(high_mult_cells,seq.frames(i).cells));
                else
                    new_cells = high_mult_cells;
                end
                try
                    seq.frames(i).cells = [seq.frames(i).cells;new_cells];
                catch
                    seq.frames(i).cells = [seq.frames(i).cells,new_cells'];
                end
                seq.frames(i).cells_colors(high_mult_cells,1) = cluster_colors(ii,1);
                seq.frames(i).cells_colors(high_mult_cells,2) = cluster_colors(ii,2);
                seq.frames(i).cells_colors(high_mult_cells,3) = cluster_colors(ii,3);
                seq.frames(i).cells_alphas(high_mult_cells) = alpha_val;
            end
        end
    end
end
update_frame(handles);

function [nm_adjusted,adjustment_inds,additional_nodes] = ...
    adjust_node_mult_by_collapsing_short_edges(geom,nm,len_thresh,max_collapse)
nm_adjusted = nm;
adjustment_inds = false(size(nm)); %indices of nodes that subsumed local nodes
additional_nodes = int16(zeros(size(nm)));
if len_thresh==0
    return
end
short_edges = geom.edges_length<=len_thresh;
if sum(short_edges)==0
%     display('no short edges found');
    return
end
% collapsing all connected components
%build a graph where the only connections are short edges
adjmat = diag(ones(numel(nm),1));
node_inds = geom.edges(short_edges,:);
inds = sub2ind(size(adjmat),node_inds(:,1),node_inds(:,2));
rev_inds = sub2ind(size(adjmat),node_inds(:,2),node_inds(:,1));
adjmat(inds)=1;
adjmat(rev_inds)=1;
% %find all paths of length 'max_collapse' or smaller
% finaladjmat=(adjmat^max_collapse)>0;
% %turn the adjacency matrix into connected components
[p,~,r] = dmperm(adjmat);
comp_sizes = r(2:end)-r(1:end-1);
clusters = find(comp_sizes>1);

for i = 1:length(clusters)
    cc_node_inds = p(r(clusters(i)):r(clusters(i)+1)-1);
    mults = nm(cc_node_inds);
    [~,I] = max(mults);
    nm_adjusted(cc_node_inds(I)) = sum(nm(cc_node_inds))-2*(numel(cc_node_inds)-1);
    adjustment_inds(cc_node_inds(I)) = true;
    tempAddNodes = cc_node_inds(~(cc_node_inds==cc_node_inds(I)));
    additional_nodes(cc_node_inds(I),1:numel(tempAddNodes)) = tempAddNodes;
end



return
%%%%%%%%%%%%%%scraps
% if max_collapse == 1
nm_adjusted = nm;
adjustment_inds = false(size(nm)); %indices of nodes that subsumed local nodes
additional_nodes = int16(zeros(size(nm)));
collapsed_edges = int16(zeros(size(nm)));
nodes2aggregate = int16(zeros(size(nm)));
if len_thresh==0
    return
end
short_edges = geom.edges_length<=len_thresh;
if sum(short_edges)==0
    display('no short edges found');
    return
end

node_inds = geom.edges(short_edges,:);
if size(node_inds,1)==1
    mults = nm(node_inds)';
else
    mults = nm(node_inds);
end
[~,I] = sort(mults,2);
high_inds = sub2ind(size(node_inds),1:size(node_inds,1),I(:,2)');
low_inds = sub2ind(size(node_inds),1:size(node_inds,1),I(:,1)');
nm_adjusted(node_inds(high_inds)) = nm_adjusted(node_inds(high_inds))+...
    nm_adjusted(node_inds(low_inds))-2;

adjustment_inds(node_inds(high_inds)) = true;
additional_nodes(node_inds(high_inds),1) = node_inds(low_inds)'; %nodes to be added to subsuming nodes
collapsed_edges(node_inds(high_inds),1) = find(short_edges);

%nodes2aggregate
%first dim index is the node
%second dim index is depth of the collapsing action
%value stored is the aggregate node to which it collapses
nodes2aggregate(node_inds(low_inds),1) = node_inds(high_inds)';





%%%%%%%%%%%%%%scraps
% if max_collapse < inf
        current_radius = 2;
        extinguished_radius = false;
        while ~extinguished_radius && (current_radius<=max_collapse)
            %nodes to check if they are connected to more collapsing edges
            check_nodes = nonzeros(nodes2aggregate(:,current_radius-1));
            %find the edge that collapsed into each of the aggregate nodes
            prevEdges = collapsed_edges(check_nodes,current_radius-1);
            extinguished_radius = true; %reset to false if any action later
            for i = 1:numel(check_nodes)
                %all edges connected to the nodes that collapsed into an
                %aggregate in the last step (can't recollapse the same edge)
                connected_edges = find(((geom.edges(:,1)==check_nodes(i))+(geom.edges(:,2)==check_nodes(i)))>0);
                %check if any connected edges are short, but not already
                %collapsed into the node being referenced
                new_edges = connected_edges(~(connected_edges==prevEdges(i)));
                new_edges = new_edges(short_edges(new_edges));
                if ~isempty(new_edges)
                    extinguished_radius = false; %still collapse edges, so keep looking
                    %if there are multiple edges, then just take the
                    %shortest
                    if numel(new_edges)>1
                        [~,maxind] = max(geom.edges_length(new_edges));
                    else
                        maxind = 1;
                    end
                    node_inds = geom.edges(new_edges(maxind),:);
                    if ~(sum(node_inds==check_nodes(i))==1)
                        display('exactly one node in the new collapsing edge should equal the focus node');
                        display('discrepancy found, quitting...');
                        return
                    end
                    mults = nm_adjusted(node_inds)';
                    other_node = node_inds(~(node_inds==check_nodes(i)));
                    nm_adjusted(check_nodes(i)) = sum(nm_adjusted(node_inds))-2;
                    adjustment_inds(check_nodes(i)) = true;
                    additional_nodes(check_nodes(i),current_radius) = other_node; %nodes to be added to subsuming nodes
                    collapsed_edges(check_nodes(i),current_radius) = new_edges(maxind);
                    previousLow = additional_nodes(check_nodes(i),current_radius-1);
                    nodes2aggregate(previousLow,current_radius) = other_node;
                end
            end
            current_radius = current_radius+1;
        end
