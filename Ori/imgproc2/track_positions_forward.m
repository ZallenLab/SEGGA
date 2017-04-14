function tr_f = track_positions_forward(a, b);
%Finds the nearest neighbor in b for every item in a. very similar to track.m
aa = repmat(a, [1 1 length(b(1,:))]);
b = reshape(b, [2 1 length(b(1,:))]);
bb = repmat(b, [1 length(a(1,:)) 1]);
dd = reshape(sum((aa - bb).^2,1), [length(a(1,:)) length(b(1,:))])';
%dd is the matrix distance between each pair of positions.
[c1,tr_f] = min(dd, [], 1);
