function mean_adjusted_levels_out = mean_adjusted_levels_edge_info(channel_info)

len_mov = size(channel_info(1).levels,1);
for i = 1:length(channel_info)
    mean_adjusted_levels_out(i).levels = nan(size(channel_info(1).levels));
    mean_adjusted_levels_out(i).mean = nan(len_mov,1);
    for j = 1:len_mov
        takers = ~isnan(channel_info(i).levels(j,:));
        mean_adjusted_levels_out(i).mean(j) = mean(channel_info(i).levels(j,takers));
        mean_adjusted_levels_out(i).levels(j,takers) = channel_info(i).levels(j,takers)./mean_adjusted_levels_out(i).mean(j);
    end
end