function [forward backward f_dist b_dist i1 i2] = track(a, b)
%Input: a(2, n), list of n positions in two dimensions.
%       b(2, n), list of n positions in two dimensions.
%Ouput: all outputs are vectors of length n.

%For each position listed in a find which position in b is nearest and
%vice versa.
%forward(i) = Position listed in b nearest to position listed in a(1:2, i).
%backward(i) = Position listed in a nearest to position listed in b(1:2, i).
%f_dist square of the distance between a(:, i) and b(:, forward(i))
%b_dist square of the distance between b(:, i) and a(:, backward(i))
%forward(i) will be equal to zero if a(:, i) is not the closest position
%among all a to b(:, forward(i)).
%backward(i) will be equal to zero if b(:, i) is not the closest position
%among all a to a(:, backward(i)).


aa = repmat(a, [1 1 length(b(1,:))]);
b = reshape(b, [2 1 length(b(1,:))]);
bb = repmat(b, [1 length(a(1,:)) 1]);
dd = reshape(sum((aa - bb).^2,1), [length(a(1,:)) length(b(1,:))])';
%dd is the matrix distance between each pair of positions.
[c1, i1] = min(dd, [], 1);
[c2, i2] = min(dd, [], 2);

%i1 lists the closest item position in b to each position listed in a.

%Set mismatched mappings to zero (ie, if i1(k) is the closest to k but k is
%not the closest to i1(k)).
forward = match(i1(:), i2(:), length(a(1, :)));
backward = match(i2(:), i1(:), length(b(1, :)));
f_dist = c1;
b_dist = c2;

function injection = match(i1, i2, len)
injection = zeros(1,len);
injection(i2(i1)' == 1:len) = i1(i2(i1)' == 1:len);
