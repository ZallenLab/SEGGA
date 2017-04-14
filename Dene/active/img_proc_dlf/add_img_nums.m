function filenameout = add_img_nums(filenamegiven, t_num, z_num,filetype_str)

% t_num = 1;
% z_num = 1;
filenameout = [filenamegiven, strcat('_T', sprintf('%04d',t_num)), strcat('_Z', sprintf('%04d',z_num)),filetype_str];