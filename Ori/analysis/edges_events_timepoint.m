function [dead_init dead_final born_init born_final ...
    edges_by_cells edges_can_exist transient_edge] = edges_events_timepoint(seq, data, edges, time_window, min_edge_length)
%time window is a parameter used in determining dead_init
%edges that are never shorter than min_edge_length for a time_window before disappearing or
%just after created are not tagged as dead or born.
%data fields used:
%data.edges.len
%data.edges.selected
%data.cells.area



if nargin < 3 || isempty(edges)
    edges = find(any(data.edges.selected > 0, 1));
end

if nargin < 4 || isempty(time_window)
    time_window = 10;
end

if nargin < 5 || isempty(min_edge_length)
    min_edge_length = 10;
end
%Denote each edge by the two cells separated by it.
edges_by_cells = global_edges2cells(seq, 1:length(seq.edges_map(1, :)));

% edges_by_cells_temp; = global_edges2cells(seq, edges);
% edges_by_cells = zeros(length(data.edges.selected(1, :)), 2);
% edges-by_cells(edges, :) = edges_by_cells_temp;

edges_can_exist = false(size(data.edges.selected));

for i = edges
    %Are the two cells which are separated by the edge in view?
    edges_can_exist(:, i) = all(data.cells.area(:, edges_by_cells(i, :)) > 0, 2);
end

edges_dead = ~(data.edges.len > 0) & edges_can_exist;
edges_alive = data.edges.len > 0;
edges_not_defind = ~edges_can_exist;

dead_final = zeros(1, length(edges_dead(1, :)));
dead_init = dead_final;
born_init = dead_final;
born_final = dead_final;
transient_edge = false(size(dead_init));
num_frms = length(edges_dead(:, 1));
for i = edges
    if sum(edges_alive(:, i)) < time_window
        %continue
    end
    last_frm_sel = find(data.edges.selected(:, i), 1, 'last');
    %remove isolated alive points (if edge is alive for a single time
    %point in which it is not selected and not alive for the previous
    %and next time_window frames, remove it).
    while 1
        temp_frm = find(edges_alive(:, i), 1, 'last');
        if isempty(temp_frm)
            break
        end
        if ~data.edges.selected(temp_frm , i) && temp_frm > time_window
            if sum(edges_alive((temp_frm-time_window):temp_frm, i)) == 1
                edges_alive(temp_frm, i) = 0;
            else
                break
            end
        else
            break
        end
    end
    %the edge can, but does not, exist at and after dead_final (dead final -1 is
    %the first time point after which the edge no longer exist)
    frm = find(edges_alive(:, i), 1, 'last');
    if ~isempty(frm) && frm < num_frms && edges_dead(frm + 1, i)
        dead_final(i) = frm + 1;
    end

    %dead_init = the first frame the edge disappeared (while still in view) 
    %after it existed for at least 2*time_window time points.
    %The loop makes sure there is no continguous block of
    %timepoints between dead_init and dead_final of length greater than
    %time_window in which the edge exists.

    
    temp_frm = find(edges_alive(:, i), 1);
%     temp_frm = find(edges_alive(:, i), 2*time_window);
%     if length(temp_frm) < 2*time_window
%         dead_final(i) = 0;
%         temp_frm = [];
%     else
%         temp_frm = temp_frm(end);
%     end
    while ~isempty(temp_frm)
        if dead_final(i) == 0
            break
        end
        
        frm = find(edges_dead(temp_frm:end, i), 1, 'first');
        frm = temp_frm + frm - 1;
        if ~isempty(frm) && frm > 1 && edges_alive(frm - 1, i) && ...
                dead_final(i) >= frm

            %if there exists a continuous block of time points of length
            %equal or greater to time_window, in which the edge is alive,
            %skip that block and search from the end of it again. ** this
            %is cancelled if the edge length never exceeds min_edge_length
            %during that block
            end_of_block = contains_block(edges_dead(frm:dead_final(i), i), time_window);
            if max(data.edges.len(frm:last_frm_sel , i)) < min_edge_length
                %end_of_block = 0;
            end
            if end_of_block
                temp_frm = frm + end_of_block - 1;
                continue
            end
            dead_init(i) = frm;
            break
        else
            temp_frm = frm;
        end
    end

    %make sure the edge's length approached zero as it disappears.
    frms_to_check = max(1, dead_init(i) - time_window):dead_final(i);
    if dead_init(i) && min(nonzeros(data.edges.len(frms_to_check, i))) > min_edge_length

        transient_edge(i) = true;
%         dead_final(i) = 0;
%         dead_init(i) = 0;
%         continue
    end
    
    

%     frm = find(edges_dead(:, i), 1, 'last');
%     if ~isempty(frm) && frm < num_frms && edges_alive(frm + 1, i)
%         born_final(i) = frm + 1;
%     end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %born_init is first frame in which the edge changes from dead to 
    %alive (and the two cells divided by it are in view). The edge must
    %have existed in all time points before that while the two cells it
    %divides are in view
    
    frm = find((diff(edges_dead(:, i)) == -1) & diff(edges_can_exist(:, i)) == 0, 1);
    if ~isempty(frm) && (all((edges_dead(1:frm, i) | edges_not_defind(1:frm, i)))); 
        born_init(i) = frm;
    end

    %born_final is the last time point in which the edge changes from dead
    %to alive (and the two cells divided by it are in view). The edge must
    %exist in all later tim points for which the two cells divided by it
    %are in view.
    frm = find((diff(edges_dead(:, i)) == -1) & diff(edges_can_exist(:, i)) == 0, 1, 'last');
    if ~isempty(frm) && (all((edges_alive(frm:end, i) | edges_not_defind(frm:end, i))))
        born_final(i) = frm;
    end
    %%%%%%%% IF AN EDGE DIES AFTER BEING BORN THIS WILL NOT ASSIGN A
    %%%%%%%% born_final VALUE. SHOULD BE CHANGED TO CHECK FOR A CONTINUOUS
    %%%%%%%% EXISTANCE OF THE CELL FOR time_window TIME POINTS, AND NOT FOR
    %%%%%%%% ALL FOLLOWING TIME POINTS. (but under this suggestions, 
    %%%%%%%% if the edge flickrs as it dies, the born_final value will be
    %%%%%%%% around its death time).
    %%%%%%%% 
    
    

%     frm = find(edges_alive(:, i), 1, 'first');
%     if ~isempty(frm) && frm > 1 && edges_dead(frm - 1, i) && born_final(i) >= frm    
%     end



    %make sure the edge was very short when created
    frms_to_check = born_init(i):min(num_frms, time_window + born_init(i));
    if born_init(i) && min(nonzeros(data.edges.len(frms_to_check, i))) > min_edge_length
        transient_edge(i) = true;
%         dead_final(i) = 0;
%         dead_init(i) = 0;
%         born_final(i) = 0;
%         born_init(i) = 0;
        continue
    end
    
end

function flag = contains_block(vec, len)
%is there a block of 0 of length len in the vector vec
%assumes vec(1) is not zero.
v = find(vec ~= 0);
b = diff(v);
temp = find(b >= len, 1, 'last'); 
if ~isempty(temp)
    flag = v(temp + 1);
else
    flag = 0;
end