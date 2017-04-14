function [z_num, t_num, t_str, mid_str] = get_file_nums(filename, no_stop)
num_length = 4;
c_ind = strfind(filename, '_T');
if isempty(c_ind)
    if nargin > 1 && no_stop
        z_num = [];
        t_num = [];
        return
    end
    msg = ['File name format error. Could not find ''_T'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
i = 1;
t_str = filename(c_ind(i)+2:c_ind(i)+ 1 + num_length);
t_num = str2num(t_str);
while isempty(t_num) && i<length(c_ind)
    i = i+1;
    t_str = filename(c_ind(i)+2:c_ind(i)+ 1 + num_length);
    t_num = str2num(t_str);
end

if isempty(t_num)
    i = 1;
    t_str = filename(c_ind(i)+2:c_ind(i)+ 1 + num_length-1);
    t_num = str2num(t_str);
    while isempty(t_num) && i<length(c_ind)
        i = i+1;
        t_str = filename(c_ind(i)+2:c_ind(i)+ 1 + num_length-1);
        t_num = str2num(t_str);
    end
end

if isempty(t_num)
    i = 1;
    templen = num_length;
    while isempty(t_num) && templen>1
        templen = templen-1;
        t_str = filename(c_ind(i)+2:c_ind(i)+ 2 + templen-1);
        t_num = str2num(t_str);
    end
end

if isempty(t_num)
    display(['could not get t_num from image file, ',filename]);
end

cz_ind = strfind(filename, '_Z');
if isempty(cz_ind)
    if nargin > 1 && no_stop
        z_num = [];
        t_num = [];
        return
    end
    msg = ['File name format error. Could not find ''_Z'' in file name ' ...
        'and assign a Z slice number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end


i = 1;
z_num = str2num(filename(cz_ind(i)+2:min(cz_ind(i)+ 1 + num_length,numel(filename))));
while isempty(z_num)
    i = i+1;
    z_num = str2num(filename(cz_ind(i)+2:min(cz_ind(i)+ 1 + num_length,numel(filename))));
end

mid_str = filename(c_ind(i)+6:cz_ind(i));