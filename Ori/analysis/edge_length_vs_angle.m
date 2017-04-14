function [binned_hists bins] = edge_length_vs_angle(data, ...
    bins, vs_initial_angle)

if nargin < 2 || isempty(bins)
    bins = 0:30:150;
end

if nargin < 3 || isempty(vs_initial_angle)
    vs_initial_angle = false;
end

temp_len = data.edges.len;
temp_len(~data.edges.selected) = nan;
full_len_deriv = smoothen(deriv(temp_len));
for i = 1:length(data.edges.len(:, 1))

    if vs_initial_angle
        selected_edges = data.edges.selected(1, :) & data.edges.selected(i, :);
    else
        selected_edges = data.edges.selected(i, :);
    end
    cnt = 0;
    max_len = zeros(1, nnz(selected_edges));
    mean_len = max_len;        
    for j = find(selected_edges)
        cnt = cnt + 1;
        ind = data.edges.selected(:, j);
        max_len(cnt) = max(data.edges.len(ind, j));
        mean_len(cnt) = mean(data.edges.len(ind, j));
    end
    len = temp_len(i, selected_edges);
    len_deriv = full_len_deriv(i, selected_edges);
    
    if vs_initial_angle
        ang = data.edges.angles(1, selected_edges);
    else
        ang = data.edges.angles(i, selected_edges);
    end
    
    %length as a function of time and angle(t)
    [a s] = binned_avg(ang, bins - eps('single'), len, 0);
    binned_hists.len_vs_ang.avg(i, 1:length(a)) = a;
    binned_hists.len_vs_ang.std(i, 1:length(a)) = s;

    %max length as a function of time and angle(t)
    [a s] = binned_avg(ang, bins - eps('single'), max_len, 1);
    binned_hists.max_len_vs_ang.avg(i, 1:length(a)) = a;
    binned_hists.max_len_vs_ang.std(i, 1:length(a)) = s;
    
    %rate of change of length as a function of time and angle(t)
    [a s] = binned_avg(ang, bins - eps('single'), len_deriv, 1);
    binned_hists.len_vel_vs_ang.avg(i, 1:length(a)) = a;
    binned_hists.len_vel_vs_ang.std(i, 1:length(a)) = s;
    
    %mean length as a function of time and angle(t)
    [a s] = binned_avg(ang, bins - eps('single'), mean_len, 1);
    binned_hists.mean_len_vs_ang.avg(i, 1:length(a)) = a;
    binned_hists.mean_len_vs_ang.std(i, 1:length(a)) = s;
    
end

