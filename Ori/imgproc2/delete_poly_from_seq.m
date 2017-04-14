function [poly_seq poly_frame_ind suc] = delete_poly_from_seq(poly_seq, poly_frame_ind, frame_num)
suc = false;
poly_ind = find(poly_frame_ind == frame_num);
if ~isempty(poly_ind)
    poly_seq = poly_seq([1:(poly_ind-1) (poly_ind+1):end]);
    poly_frame_ind = poly_frame_ind([1:(poly_ind-1) (poly_ind+1):end]);
    suc = true;
end