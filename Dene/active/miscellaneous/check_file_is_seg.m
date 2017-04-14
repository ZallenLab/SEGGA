function [znum, tnum] = check_file_is_seg(filename_in)

znum = [];
tnum = [];

z_ind = strfind(filename_in,'_Z');
t_ind = strfind(filename_in,'_T');

if ~isempty(z_ind)&&~isempty(t_ind)
    znum = str2num(filename_in((z_ind+2):(z_ind+5)));
    tnum = str2num(filename_in((t_ind+2):(t_ind+5)));
end

