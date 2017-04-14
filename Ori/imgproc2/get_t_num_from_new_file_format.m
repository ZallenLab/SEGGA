function [t_num base_name] = get_t_num_from_new_file_format(filename)
%Assumed filename is of the format 'base_filename_t123.ome'

[~,filename] = fileparts(filename); %get rid of the extension
c_ind = strfind(filename, '_t');
if isempty(c_ind)
    c_ind = strfind(filename, '_T');
    if isempty(c_ind)
        t_num = [];
        base_name = [];
        return
    end
	e_ind = strfind(filename, '.ome');
    if isempty(e_ind)
        display('did not find expected ".ome" for filename with "_T" in name');
%         return
%         e_ind = strfind(filename, '-diff');
          e_ind = numel(filename)+1;
    end
    t_num = str2num(filename(c_ind(end)+2:e_ind-1));
    if isempty(t_num)
        t_num = str2num(filename(c_ind(end):end));
    end
    t_num = t_num +1;
    base_name = filename(1:c_ind(end));
    return
end
t_num = str2num(filename(c_ind(end)+2:end));
base_name = filename(1:c_ind(end));