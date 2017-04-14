function [t_num base_name] = get_t_num_from_new_volocity_file_format(filename)
%Assumed filename is of the format:
% 'filenametxt T=1 C=GFP Z=1.tif'
[dummy1 filename ] = fileparts(filename); %get rid of the extension
c_ind_start = strfind(filename, 'T=');
c_ind_end = strfind(filename, 'C=')-1;

if isempty(c_ind_start) || isempty(c_ind_end)
    t_num = [];
    base_name = [];
    return
end
t_num = str2num(filename(c_ind_start(end)+2:c_ind_end));
base_name = filename(1:c_ind_start(end));


