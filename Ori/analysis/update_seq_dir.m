function seq = update_seq_dir(seq, directory)
if nargin < 2 || isempty(directory)
    directory = pwd; 
end
seq.directory = directory;
    