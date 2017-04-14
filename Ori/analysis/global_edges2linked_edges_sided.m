function [linked] = global_edges2linked_edges_sided(seq, data, edges, node1, node2, flip)
%linked(i).edges is a list of all edges that are linked to edge i at its
%first and/or second node, according to the flags node1 and node2 (where 
%edges are enumarted as in data). Both nodes are on by default.
%If flip(frm, i) is true node1 and node2
%replace each other at timepoint frm for the edge i.
%The default is flip = false at all time point for all edges.
%linked is computed for all timepoints and only for edges listed in edges. For all
%other edges the fields of linked are returned empty.
%output:
%linked(i).edges lists the edges connected to edge i
%linked(i).on is a (n x j) logical array where n is the number of time
%points in the movie and j the number of edges edge i is connected to.
%linked(i).on(frm, k) is true of edge i is connected to edge
%linked(i).edges(k) at time point frm.

if nargin < 4
    node1 = true;
    node2 = true;
end

if nargin < 6
    flip = [];
end
temp_list = false(1, length(seq.edges_map(1, :)));
temp_on = false(size(seq.edges_map));
linked = struct('edges', [], 'on', []);
linked(1:length(data.edges.len(1,:))) = linked;
for i = edges
    temp_list(:) = false;
    temp_on(:) = false;
    for frm = 1:length(seq.frames)
        edge = seq.edges_map(frm, i);
        if edge
            if ~isempty(flip) && flip(frm, i)
                n1 = node2;
                n2 = node1;
            else
                n1 = node1;
                n2 = node2;
            end
            e = edge2linked_edges(seq.frames(frm).cellgeom, edge, n1, n2);
        else
            e = [];
        end
        e = e(e <= length(seq.inv_edges_map(1, :)));
        linked_list = nonzeros(seq.inv_edges_map(frm, e));
        %add links to the dynamical list of links (on field) but add linked 
        %edges to the list of linked edges (edges field), only if the edge 
        %is selected at time point frm. Threfore, iff the link existed at
        %another time point, one in which edge was selected, the current
        %link will be taken into account.
        
        if data.edges.selected(frm, i) > 0
            temp_list(linked_list) = true;
        end

        temp_on(frm, linked_list) = true;
    end
    
    linked(i).edges = find(temp_list);
    linked(i).on = temp_on(:, temp_list);
end

    