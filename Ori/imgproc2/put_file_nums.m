function filename = put_file_nums(filename, t, z)
if (nargin < 2 || isempty(t)) || (nargin < 3 || isempty(z))
    [z_old t_old] = get_file_nums(filename);
    if (nargin < 2 || isempty(t))
        t = t_old;
    end
    if (nargin < 3 || isempty(z))
        z = z_old;
    end
end
num_length = 4;
format = sprintf('%%0%1dd', num_length); % = '%04d'
c_ind = strfind(filename, '_T');
if isempty(c_ind)
    msg = ['File name format error. Could not find ''_T'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
i = 1;
t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
while isempty(t_num)
    i = i+1;
    t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
end
filename(c_ind(i)+2:c_ind(i)+ 1 + num_length) = num2str(t, format);

c_ind = strfind(filename, '_Z');
if isempty(c_ind)
    msg = ['File name format error. Could not find ''_Z'' in file name ' ...
        'and assign a Z slice number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
i = 1;
z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
while isempty(z_num)
    i = i+1;
    z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
end
filename(c_ind(i)+2:c_ind(i)+ 1 + num_length) = num2str(z, format);