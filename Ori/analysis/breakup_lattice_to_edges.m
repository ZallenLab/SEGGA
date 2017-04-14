function [x1 x2 y1 y2] = breakup_lattice_to_edges(seq, edges)
x1 = nan(length(seq.frames), length(edges));
x2 = x1;
y1 = x1;
y2 = x1;
for frm = 1:length(seq.frames)
    geom = seq.frames(frm).cellgeom;
    for i = 1:length(edges)
        ed = seq.edges_map(frm, edges(i));
        if ed
            node1 = 1;
            node2 = 2;
            x1(frm, i) = geom.nodes(geom.edges(ed, node1), 1);
            x2(frm, i) = geom.nodes(geom.edges(ed, node2), 1);
            y1(frm, i) = geom.nodes(geom.edges(ed, node1), 2);
            y2(frm, i) = geom.nodes(geom.edges(ed, node2), 2);
        end
    end
end
