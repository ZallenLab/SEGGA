function [z_num base_name] = get_z_num_from_new_volocity_file_format(filename)
%Assumed filename is of the format:
% 'filenametxt T=1 C=GFP Z=1.tif'
[dummy1 filename ] = fileparts(filename); %get rid of the extension
z_ind_start = strfind(filename, 'Z=');
t_ind_start = strfind(filename, 'T=');
% c_ind_end = strfind(filename, 'C=')-1;

if isempty(z_ind_start) || isempty(t_ind_start)
    z_num = [];
    base_name = [];
    return
end
z_num = str2num(filename(z_ind_start(end)+2:end));
base_name = filename(1:t_ind_start(end));

