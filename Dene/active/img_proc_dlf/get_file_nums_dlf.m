function [z_num, t_num, t_ind] = get_file_nums_dlf(filename, no_stop)

z_num = [];
t_num = [];
t_ind = 0;


num_length = 4;
c_ind = strfind(filename, '_T');
if isempty(c_ind)
    c_ind = strfind(filename, '_t');
end
t_ind = c_ind;
if isempty(c_ind)
    if nargin > 1 && no_stop
        z_num = [];
        t_num = [];
        return
    end
%     msg = ['File name format error. Could not find ''_T'' in file name ' ...
%         'and assign a frame number'];
%     msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
%     waitfor(msgboxH);
%     return
end

if ~isempty(c_ind)
    i = 1;
    t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
    while isempty(t_num) && (i<length(c_ind))
        i = i+1;
        t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
    end
    
    reduct_ind = 1;
    while isempty(t_num) && ((num_length-reduct_ind)>0)
        reduct_ind = reduct_ind+1;
        t_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length-reduct_ind));
    end
    
end

c_ind = strfind(filename, '_Z');
if isempty(c_ind)
    c_ind = strfind(filename, '_z');
end
if isempty(c_ind)
    if nargin > 1 && no_stop
        z_num = [];
%         t_num = [];
        return
    end
%     msg = ['File name format error. Could not find ''_Z'' in file name ' ...
%         'and assign a Z slice number'];
%     msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
%     waitfor(msgboxH);
%     return
end

if ~isempty(c_ind)
    i = 1;
    z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
    while isempty(z_num)
        i = i+1;
        z_num = str2num(filename(c_ind(i)+2:c_ind(i)+ 1 + num_length));
    end
end