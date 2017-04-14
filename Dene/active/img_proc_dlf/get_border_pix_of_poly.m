function outerpix = get_border_pix_of_poly(img, poly)

polypix = poly2mask(poly(:,2),poly(:,1),size(img,1),size(img,2));

se = strel('disk',10);        
innerpix = imerode(polypix,se);
outerpix = max(polypix - innerpix,0);

 