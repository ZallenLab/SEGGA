function [A_n, shift_used] = normalize(A,range_size,shiftmin2zero,shiftval)
%% [A_n, shift_used] = normalize(A) takes 2D mat A and gives a normalized 2D mat --> A_n
% A_n = normalize(A) uses r (range) = 1, and s_TF (shift the minimum -> 0) = true
% A_n = normalize(A,r,s_TF) specifies the range ('r') to normalize to
% and whether or not ('s_TF') to shift to zero, or leave centered around
% the original mean (center) of the population.
% A_n is the normalized image, and 'shift_used' is the shift to the
% distribution
%
% A_n = normalize(A,r,s_TF,shift) specifies the range ('r') to normalize to
% and whether or not ('s') to shift the minimum, and what value ('shift')
% to shift the minimum to. In order to center the set around some value
% use (r/2) as the input for 'shift'
orig_A = A;

if nargin <4 || isempty(shiftval)
    shiftval = 0; 
end


if nargin <3 || isempty(shiftmin2zero)
    shiftmin2zero = true;
end

if nargin <2 || isempty(range_size)
    range_size = 1;
end

% A = rand(10); %for testing code
A = double(A);
maxval = max(A(:));
minval = min(A(:));
diff_extr = diff([minval,maxval]);

if diff_extr == 0
    A_n = A;
    shift_used = 0;
    return
end

if shiftmin2zero %numbers start at zero
    A_n = ((A-minval)./diff_extr)*range_size;
    shift_used = -(minval/diff_extr)*range_size;
else %start at min, just change the range
    A_n = (A)./diff_extr*range_size;
    shift_used = 0;
end


