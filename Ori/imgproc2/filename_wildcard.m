function filename = filename_wildcard(filename)
num_length = 4;
c_ind = strfind(filename, '_T');
if isempty(c_ind)
    msg = ['File name format error. Could not find ''_T'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH)
end
i = 1;
t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
while isempty(t_num)
    i = i+1;
    t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
end
filename(c_ind(i)+2:c_ind(i)+ 1 + num_length) = '****';

c_ind = strfind(filename, '_Z');
if isempty(c_ind)
    msg = ['File name format error. Could not find ''_Z'' in file name ' ...
        'and assign a Z slice number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH)
end
i = 1;
z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
while isempty(z_num)
    i = i+1;
    z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
end
filename(c_ind(i)+2:c_ind(i)+ 1 + num_length) = '****';