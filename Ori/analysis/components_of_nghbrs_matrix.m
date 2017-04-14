function c = components_of_nghbrs_matrix(mat, fn)
%mat is a neighbors matrix. That is, i and j are linked if mat(i,j) > 0.
%c is a struct array. Each element of c corresponds to a 
%connectivity component. The items in the k-th component are listed in
%c(k).(fn)
%mat is assumed to be symmetric.
%Items that are not connected to other items are part of a singelton
%component if they are connected to themselves (mat(i, i) = true).

if nargin < 2 || isempty(fn)
    fn = 'items';
end

done = false(length(mat));
[i j] = find(mat, 1);
c(1).(fn) = add_items_to_component(mat, i); 
for i = 1:length(mat);
    if ~done(i) && any(mat(i, :))
        c(end+1).(fn) = add_items_to_component(mat, i);
    end
end

function d = add_items_to_component(mat, i)
    d = i;
    done(i) = true;
    new_items = find(mat(i, :));
    for j = new_items
        if done(j)
            continue
        end
        d = [d add_items_to_component(mat, j)];
    end

end        
end