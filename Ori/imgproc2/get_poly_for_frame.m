function [poly dummy] = get_poly_for_frame(i, poly_frame_ind, poly_seq, inv_frame_num)
if nargin < 4
    [dummy poly_ind] = min(abs(i - poly_frame_ind));
    poly = poly_seq(poly_ind);
else
    if i==0
        poly=[];
        dummy=[];
    end
    poly_t = inv_frame_num(poly_frame_ind, 1);
    poly_z = inv_frame_num(poly_frame_ind, 2);
    t = inv_frame_num(i, 1);
    z = inv_frame_num(i, 2);
    [dummy poly_ind] = min((poly_t - t).^2 + (poly_z - z).^2);
    poly = poly_seq(poly_ind);
end
