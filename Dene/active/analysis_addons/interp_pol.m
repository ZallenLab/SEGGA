function no_nan_pol = interp_pol(cell_pol_sequence)


    no_nan_pol = zeros(size(cell_pol_sequence));
    for i = 1:size(cell_pol_sequence,2)
        times = 1:size(cell_pol_sequence,1);
        mask =  ~isnan(cell_pol_sequence(:,i));
        if sum(mask)>4
            no_nan_pol(mask,i) = cell_pol_sequence(mask,i);
            no_nan_pol(~mask,i) = interp1([0,times(mask),max(times)+1], [0;cell_pol_sequence(mask,i);0], times(~mask));
        else
            no_nan_pol(:,i) = 0;
        end
    end