function [flag found_edges event_times] = double_exchange(...
    linked1, linked2, e1, edges1, e2, edges2, ...
    time_pos, time_pos2, time_window, num_frames, extra_time_pos)
%flag = are any of the edges listed in edges1 end up being connected to an 
%edge listed in edges2? This must occur for least time_window frames
%(unless it's near the end of the movie). These time_window (or more) on
%frames must be after time_pos and before time_pos2.
%
%Also, checks that the edges are connected through the end by which they
%were connected to the edges that connected them (e1 and e2).
%
%found_edges is a list of all found edges that among edge1 and edges2 that
%do meet. an edge can appear more than once in found edges.

found_edges = [];
event_times = [];

side_flag1 = false(size(edges1));
for cnt_i = 1:length(edges1)
    i = edges1(cnt_i);
    if any(linked2(i).edges == e1);
        side_flag1(cnt_i) = true;
    end
end
side_flag2 = false(size(edges2));
for cnt_j = 1:length(edges2)
    j = edges2(cnt_j);
    if any(linked2(j).edges == e2);
        side_flag2(cnt_j) = true;
    end
end

flag = 0;
threshold = min(time_window,  num_frames - time_pos - 2);
if threshold < 1
    return
end
for cnt_i = 1:length(edges1)
    i = edges1(cnt_i);

    %check only for edges at the correct side of edge i
    if side_flag1(cnt_i)
        links1 = linked2(i);
    else
        links1 = linked1(i);
    end
    for cnt_j = 1:length(edges2)
        j = edges2(cnt_j);
        [l pos] = link_strength(links1, j, time_pos:time_pos2);
        pos = pos + time_pos - 1;
        %make sure the link between the two edges exist for a long
        %enough time.
        if l > threshold
            %make sure the edges were not connected before the edge shrank
            frms = 1:extra_time_pos;
            l  = link_strength(links1, j, frms);
            if l >= min(time_window, length(frms))
                continue
            end
            %check that the found link is the the correct side of edge j
            if side_flag2(cnt_j)
                links2 = linked2(j);
            else
                links2 = linked1(j);
            end
            l = link_strength(links2, i, time_pos:time_pos2);
            if l > threshold
                flag = true;
                found_edges = [found_edges; i j];
                event_times = [event_times pos];
            end
        end
    end
end



