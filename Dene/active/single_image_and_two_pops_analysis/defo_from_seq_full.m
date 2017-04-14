function [m, m_full] = defo_from_seq_full(seq, cells)
%cells(t, i) == 1 of the i-th cell is to be included in the analysis at
%timepoint t.
m = zeros(1, length(seq.frames));
for i = 1:length(seq.frames)
    [m(i), m_full(i).pd] = pattern_defo_graner(seq.frames(i).cellgeom, seq.cells_map(i, cells(i, :)));
end