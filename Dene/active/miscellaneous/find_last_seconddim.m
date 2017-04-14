function rowsfound = find_last_seconddim(twodim_list)

rowsfound = nan(size(twodim_list,2),1);
for i = 1:size(twodim_list,2)
    rowsfound(i) = find(twodim_list(:,i),1,'last');
end
    