function load_seq(seq, ind);
if nargin < 2
    ind = 1;
end
commandsui
global commandsuiH
seq = seq(ind);
setappdata(commandsuiH, 'seq', seq);
cd(seq.directory) 
figure(commandsuiH)