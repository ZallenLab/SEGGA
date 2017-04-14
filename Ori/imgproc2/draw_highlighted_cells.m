function h = draw_highlighted_cells(activefig, cells, c, a)
if nargin == 3
    a = 0.4;
end
if size(c) == [1 3]
    c = repmat(c, [length(cells) 1]);
end
if size(a) == [1 1]
    a = repmat(a, [length(cells) 1]);
end
if gcf ~= activefig
    figure(activefig);
end
h = zeros(1,length(cells));
for i=1:length(cells)
    if ~isempty(cells(i).nodes)
        h(i) = patch(cells(i).nodes(:,2),cells(i).nodes(:,1),c(i,:), 'FaceAlpha', a(i), 'EdgeColor', 'none');
    end
end
