function make_play_movie_channels(channel1_dir,channel2_dir,channel3_dir)
%defines channel1, channel2 and channel3
channel1 = channel1_dir;
channel2 = channel2_dir;
channel3 = channel3_dir;
save play_movie_channels channel1 channel2 channel3;


channel1_filename = [];
channel2_filename = [];
channel3_filename = [];

if ~isempty(channel1)
    new_files_ch1 = dir([channel1,filesep,'*.tif']);
    channel1_filename = [channel1,filesep,new_files_ch1(1).name];
end

if ~isempty(channel2)
    new_files_ch2 = dir([channel2,filesep,'*.tif']);
    channel2_filename = [channel2,filesep,new_files_ch2(3).name];
end

if ~isempty(channel3)
    new_files_ch3 = dir([channel3,filesep,'*.tif']);
    channel3_filename = [channel3,filesep,new_files_ch3(3).name];
end


filename = 'play_movie_channels.m';
fid = fopen(filename, 'w');
if fid == -1
    h = msgbox('Failed to open file', '', 'error', 'modal');
    waitfor(h);
    return
end
fprintf(fid, ['channel1 = ', '\''',channel1_filename,'\''; \n']);
fprintf(fid, ['channel2 = ', '\''',channel2_filename,'\''; \n']);
fprintf(fid, ['channel3 = ', '\''',channel3_filename,'\''; \n']);

fprintf(fid, ['channel = ', '{ \''',channel1_filename,'\'', \''',channel2_filename,'\'', \''',channel3_filename,'\''};']);

fclose(fid);