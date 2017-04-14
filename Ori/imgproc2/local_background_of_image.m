function img = local_background_of_image(src, r)
c = double(getnhood(strel('disk', r, 0)));

[m,n]=size(src);

%pad image by reflecting.
img = [ src(r:-1:1,r:-1:1)      src(r:-1:1,:)       src(r:-1:1,n:-1:n-r+1);
        src(:,r:-1:1)           src                 src(:,n:-1:n-r+1) ;
        src(m:-1:m-r+1,r:-1:1)  src(m:-1:m-r+1,:)   src(m:-1:m-r+1,n:-1:n-r+1) ];
    
img = conv2(img,c,'same')./sum(c(:));
img = img(r+1:r+m , r+1:r+n);
