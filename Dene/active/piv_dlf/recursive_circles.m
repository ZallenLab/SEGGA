    function matout = recursive_circles(mat_in,radii,centroids)
     matout = mat_in;
     startmat = zeros(size(mat_in));
     for i=1:length(radii)
    
        rad = radii(i);
        label = 1;
        locx = round(centroids(i,1));
        locy = round(centroids(i,2));
        circlocs = replace_circs(startmat,rad,label,locx,locy);
        
            for ii = 1:rad
                circgroup = circlocs==ii;
                matout(circgroup) = mean(mat_in(circgroup));
            end
   
     end
     
     
