function [min_z max_z min_t max_t filename_base] =  get_t_z_from_dir(curr_dir)

if nargin < 1 || isempty(curr_dir)
    curr_dir = pwd;
else
    cd(curr_dir)
end

clear curr_files;
curr_files =  dir('*.tif');
if isempty(curr_files)
    curr_files = dir('*.TIF');
end
curr_file_names = {};
z_list = nan(1,length(curr_files));
t_list = nan(1,length(curr_files));

for i = 1:length(curr_files)
    curr_file_names{i} =curr_files(i).name;
    if ~isempty(get_file_nums(curr_file_names{i}, 1));
        [z_list(i), t_list(i)] = get_file_nums(curr_file_names{i}, 1);
    end
end


min_z = min(z_list);
max_z = max(z_list);
min_t = min(t_list);
max_t = max(t_list);

% c_ind = strfind(curr_file_names{1}, '_T');
filename_base = curr_file_names{1}(1:strfind(curr_file_names{1}, '_T')-1);
filename_base = [filename_base,'_T'];