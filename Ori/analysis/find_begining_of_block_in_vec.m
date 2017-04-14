function pos = find_begining_of_block_in_vec(vec, len)
%Returns the position from which the first continuous block contaning all 
%zeros of length len or greater starts.
%returns 0 is no such block is found.
%Assumes vec(1) is not zero.

vec(end+1) = 1;
v = find(vec ~= 0);
b = diff(v);
temp = find(b >= len, 1, 'first'); 
if ~isempty(temp)
    pos = v(temp) + 1;
else
    pos = 0;
end