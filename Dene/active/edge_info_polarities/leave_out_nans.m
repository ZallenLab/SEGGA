function only_nums = leave_out_nans(input_list)
%input list is expect to be of the shape: 2 X n

%  works only for 2-D cases
% the first dimension is maintained
% 
% keepers = ~isnan(input_list);
% 
% 
% only_nums = input_list(keepers);
% 
% only_nums = reshape(only_nums,size(input_list,1),length(only_nums)/size(input_list,1));
% 
% 
% only_nums = uint16(only_nums);
% 
% 
% 
% % outputs in the following format:
% % 
% %       a  b  c  d  e
% %       a' b' c' d' e'
% 
% %  where (a,a') represents some point (x,y)
% 
% keepers = ~isnan(input_list(1, :));
% only_nums(1, :) = input_list(1, keepers);
% only_nums(2, :) = input_list(2, keepers);
% 
keepers = ~isnan(input_list(1, :));
only_nums = input_list(:, keepers);