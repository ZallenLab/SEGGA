function [poly_seq poly_frame_ind] = add_poly_to_poly_seq_inter(poly_seq, poly_frame_ind, poly, i)
%make sure frame is not already in poly_frame_ind
old_poly_ind = find(poly_frame_ind == i);
if ~isempty(old_poly_ind)
    poly_seq(old_poly_ind) = poly;

else
    %add poly to poly_seq
    if isempty(poly_seq)
        poly_seq = poly;
    else
        poly_seq(end+1) = poly;
    end
    poly_frame_ind(end+1) = i;
end

