function suc = export_to_compucell(geom, cells, types, types_names, ...
    contact_energy, img, filename)
suc = 0;
geom.faces(isnan(geom.faces(:))) = 0;
geom.nodes = double(geom.nodes);
[m n] = size(img);
img(:) = 0;
img_type = img;
if isempty(types_names)
    types_names = num2str((1:length(unique(types, 'legacy')))', '%04.0f');
end
if isempty(contact_energy)
    contact_energy = -20*ones(length(types_names(:,1)));
    for i = 1:length(contact_energy)
        contact_energy(i,i) = -200;
    end
end
for i = 1:length(cells)
    y = geom.nodes(nonzeros(geom.faces(cells(i),:)), 1);
    x = geom.nodes(nonzeros(geom.faces(cells(i),:)), 2);
    bw = poly2mask(x, y, m, n);
    img(bw) = i;
    img_type(bw) = types(i);
end

%crop the image
a = find(any(img, 1), 1, 'first');
b = find(any(img, 1), 1, 'last');
c = find(any(img, 2), 1, 'first');
d = find(any(img, 2), 1, 'last');
img = img(c:d, a:b);
img_type = img_type(c:d, a:b);
[m n] = size(img);

fid = fopen(filename, 'w');
if fid == -1
    h = msgbox('Failed to open file', '', 'error', 'modal');
    waitfor(h);
    return
end

%%%%%%%%% Cell Type - Cut and Paste to XML file %%%%%%%%%%%%%%
fprintf(fid, '<Plugin Name="CellType">\n');
fprintf(fid, '<CellType TypeName="Medium" TypeId="0"/>\n');
for i = 1:length(types_names(:,1))
    fprintf(fid, '<CellType TypeName="%s" TypeId="%d"/>\n', types_names(i,:), i);
end
fprintf(fid, '</Plugin>\n\n\n');

%%%%%%%%% Contact Energy - Cut and Paste to XML file %%%%%%%%%%%%%%
fprintf(fid, '<Plugin Name="Contact">\n');
fprintf(fid, '<Energy Type1="Medium" Type2="Medium">0</Energy>\n');
for i = 1:length(types_names(:,1))
    fprintf(fid, '<Energy Type1="Medium" Type2="%s">0</Energy>\n', types_names(i,:));
end
for i = 1:length(types_names(:,1))
    for j = i:length(types_names(:,1))
        fprintf(fid, '<Energy Type1="%s" Type2="%s">%d</Energy>\n', ...
            types_names(i,:), types_names(j,:), contact_energy(i,j));
    end
end
fprintf(fid, '<Depth>1</Depth>\n');
fprintf(fid, '</Plugin>\n\n\n');


%%%%%%%%%%%% Pif file contets %%%%%%%%%%%%%%%
fprintf(fid, '0 \t Medium \t %d \t %d \t %d \t %d \t 0 \t 0\n', 0, n, 0, m);
for i = 1:m
    for j = 1:n
        if img(i, j)
            fprintf(fid, '%d \t %s \t %d \t %d \t %d \t %d \t 0 \t 0\n', ... %z=0 for now.
                img(i, j), types_names(img_type(i, j), :), ...
                j + 10, j + 10, i + 10, i + 10); 
                %the image is cropped. We move the coordinates away from
                %the boundary
        end
    end
end
suc = ~fclose(fid);


        