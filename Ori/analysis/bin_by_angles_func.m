function h = bin_by_angles_func(seq, data, ang, channel_info, edges, bins, ...
    timestep, shift_info)

if nargin < 9 || isempty(xlim_selection)
    xlim_selection.choice = 'auto';
end

if nargin < 8 || isempty(shift_info)
    shift_info = 0;
end
if nargin < 7 || isempty(timestep)
    timestep = 35;
end
if nargin < 6 || isempty(bins)
    bins = (0:15:75);
end



custom_cols = [[0, 0, 1];...
               [0, 0.5, 0];...
               [1, 0, 0];...
               [0, 0.75, 0.75];...
               [0.75, 0, 0.75];...
               [0.75, 0.75, 0]];


%                [[0.75, 0.75, 0];...
%                [0.75, 0, 0.75];...
%                [0, 0.75, 0.75];...
%                [1, 0, 0];...
%                [0, 0.5, 0];...
%                [0, 0, 1]];


ind = data.edges.selected & data.edges.len > 10;
ind = ind(:, edges);
bin_ind = zeros(size(ind));
for j = 1:length(bins);
    bin_ind(ang >= bins(j)) = j;
end
channel_bins = zeros(length(seq.frames), length(bins), length(channel_info));

for j = 1:length(bins)
    leg{j} = sprintf('%d\\circ - %d\\circ', bins(j), bins(j) + (bins(2) - bins(1)));
end

for ch = 1:size(channel_bins, 3);
    for i = 1:length(seq.frames)
        indind = ind(i, :) & ~isnan(channel_info(ch).levels(i, :));
        channel_bins(i, :, ch) = accumarray(bin_ind(i, indind)', ...
            squeeze(channel_info(ch).levels(i, indind)), size(bins'), @mean)';
    end

    h(ch) = figure;
    xvals = timestep*((1:length(seq.frames)) + shift_info)/60;
    line_children = plot(xvals, ...
        smoothen(channel_bins(:, :, ch)), 'linewidth', 3);

    switch xlim_selection.choice
        case 'auto'
            %do nothing, automatic lims
        case 'tight'
            % force lims around bounds of data
            set(gca,'xlim',[xvals(1),xvals(end)]);
        case 'predefined'
            % force lims around bounds of data
            if isfield(xlim_selection,'lims')
                set(gca,'xlim',xlim_selection.lims);
            else
                display('missing lims field in xlim_selection variable');
            end
        otherwise
            display(['xlim_selection.choice unknown [',xlim_selection.choice,']']);
    end
        
    
    tmp_col = [];
    for i = 1:length(line_children)
        tmp_col = [tmp_col;line_children(i).Color];
    end
    
    if size(tmp_col,1) == 6
        for i = 1:length(line_children)
            line_children(i).Color = custom_cols(i,:);
        end
    end
        
    
    legend(leg);
    set(gca, 'fontsize', 14);
    title(['Average ' channel_info(ch).name ' Intensity'], ...
        'interpreter', 'none', 'fontsize', 14);
    xlabel('Minutes');
end

