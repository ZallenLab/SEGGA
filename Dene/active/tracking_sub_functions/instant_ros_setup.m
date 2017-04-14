function [min_ros,max_len] = instant_ros_setup()

min_ros = [];
max_len = [];
prompt={'Enter minimum rosette size','Enter maximum edge length'};
name='rosette parameters';
numlines=1;
defaultanswer={'5','0','inf'};
ros_params=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(ros_params)
    display('user cancelled');
    return
else
    min_ros = str2num(ros_params{1});
    max_len = str2num(ros_params{2});
%     max_collapse = str2num(ros_params{3});
end