function val  = check_for_edge_intensity_val(img, pt_one, pt_two, method, trap_bool, search_radius, buffer, flip)
if nargin > 7 && ~isempty(flip) && flip % Added for future optional use -- Ori, March 4 2009 
    pt_one = pt_one([2 1]);
    pt_two = pt_two([2 1]);
end

%%%% March 05, 2009  -- Ori
%%%% vetors of length <= 1 have a different shape than what ortho_search2
%%%% expects (the old and new version). For now, just the return the img
%%%% value at the given pixel.
if max(abs((pt_one - pt_two))) < 1
%     m = size(img,1);
%     val = img((m * (round(pt_one(1)-1))) + round(pt_two(2)));
    val = get_part_from_matrix(img, round(pt_one(1)) , round(pt_two(2)));
    return
end
%%%%

if nargin < 4 || isempty(method)
    method = 'maxes_then_mean';
end

if nargin < 5 || isempty(trap_bool)
    trap_bool = 0;
end

if nargin < 6 || isempty(search_radius)
    search_radius = 2;
end

if nargin < 7 || isempty(buffer)
    buffer = 2;
end

   
sample_pixels = ortho_search2(size(img),search_radius,trap_bool,pt_one,pt_two);
val = get_edge_intensity_val(img, sample_pixels, method, buffer);

