function corrterms = single_contributions_to_correlation(pop_a,pop_b)

mean_a = mean(pop_a);
mean_b = mean(pop_b);

% mean_a = 1;
% mean_b = 1;

corr_single_val = @(x,y,xmean,ymean) ((x-xmean).*(y-ymean))./(std(x)*std(y)*numel(x));

corrterms = corr_single_val(pop_a,pop_b,mean_a,mean_b);
