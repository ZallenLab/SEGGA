function [len pos]= link_strength(links, b, time_frame)
pos = 0;
ind = links.edges == b;
if ~any(ind)
    len = 0;
    return
end
len = sum(links.on(time_frame, ind));
if len
    pos = find(links.on(time_frame, ind), 1);
end