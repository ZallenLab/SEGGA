function poly = edit_poly_inter(poly, txt_h)
% fig = gcf;
msg = sprintf(['Click anywhere to add/move a vertex.\n'... 
    'a: Add vertex\nd: Delete vertex\nm: Move vertex\n' ...
    'Right click, press escape or press enter when done.\n'...
    'On some systems, key presses are not recognized before the first mouse click.']);
if nargin > 1 && ~isempty(txt_h) && ishandle(txt_h)
    old_string = get(txt_h, 'string');
    set(txt_h, 'string', msg)
end
% help_win = helpdlg(msg, '');
% old_u = get(fig, 'units');
% set(fig, 'units', 'pixels')
% fig_pos = get(fig, 'outerposition');
% set(fig, 'units', old_u)
% set(help_win, 'units', 'pixels')
% pos = get(help_win, 'outerposition');
% pos(1) = (fig_pos(1) + fig_pos(3) - pos(3))/2 ;
% pos(2) = fig_pos(2) - pos(4)/2;
% set(help_win, 'outerposition', pos);
% figure(fig);
poly_color = [0 0 1];
patch_options = {'FaceAlpha', 0, 'EdgeColor', poly_color, ...
    'marker', '*', 'markeredgecolor', 'y'};
x = poly.x;
y = poly.y;
h_poly = patch(y', x', [0 0 0], patch_options{:});
markerH = [];


while 1 %~isempty(new_x) && b ~= 27 && b ~= 3;
    [new_y, new_x, b] = ginput(1);
    if isempty(new_x) || b == 27 || b == 3;
        break
    end
    fake_vertices_x = (x + x([2:end 1]))/2;
    fake_vertices_y = (y + y([2:end 1]))/2;
        

    d=(x - new_x).^2 + (y - new_y).^2;
    [D, vertex] = min(d);
    d = (fake_vertices_x - new_x).^2 + (fake_vertices_y - new_y).^2;
    [D_fake, fake_vertex] = min(d);
    D_fake = D_fake/2;

    if b == 97 %user pressed a. Force add new vertex.
        D_fake = 0;
    end
    if b == 109 || (b == 1 && D < D_fake) %user pressed m, or clicked next to an
                                %existing node. Force move node.
        D = 0;
        markerH = patch(y(vertex), x(vertex), [0 0 0], 'markersize', 8,...
            'marker', 'o', 'markeredgecolor', 'r', 'markerfacecolor', 'r');
        [new_y, new_x, b] = ginput(1);
        delete(markerH(ishandle(markerH)));
        if isempty(new_x) || b == 27 || b == 3;
            continue
        end
    end

    if b == 100 %user pressed d. Delete nearest vertex
        x = x([1:(vertex-1) (vertex+1):end]);
        y = y([1:(vertex-1) (vertex+1):end]);
    elseif b == 1 || b == 97 || b == 109 %move or create node
        if D < D_fake %move node
            x(vertex) = new_x;
            y(vertex) = new_y;
        else %add node
            x_end = [x(2:end) x(1)];
            y_end = [y(2:end) y(1)];
            dist_to_lines = line_par_point_dist_2d(x_end - x, y_end - y, x, y, [new_x new_y]');
            [min_dist closest_line] = min(dist_to_lines);
            if closest_line == length(x)
                x = [x new_x];
                y = [y new_y];
            else
                x = [x(1:closest_line) new_x x((closest_line+1):end)];
                y = [y(1:closest_line) new_y y((closest_line+1):end)];
            end
        end
    end    
    if ishandle(h_poly)
        delete(h_poly)
    end
    h_poly = patch(y', x', [0 0 0], patch_options{:});
end
if ishandle(h_poly)
    delete(h_poly)
end
delete(markerH(ishandle(markerH)));
if nargin > 1 && ~isempty(txt_h) && ishandle(txt_h)
    set(txt_h, 'string', old_string);
end
% if ishandle(help_win)
%     close(help_win)
% end
poly.x = x;
poly.y = y;