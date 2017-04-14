function new = gaussfilt(old,n,sigma)


g1 = gauss(1:n,sigma);

d2g = g1' * g1;
filter1 = d2g / sum(d2g(:));%norm(d2g);  %should be d2g / sum(d2g(:));

    
[x y] = size(old);
old = [ old(n:-1:1,n:-1:1) old(n:-1:1,:) old(n:-1:1,y:-1:y-n+1); 
        old(:,n:-1:1) old old(:,y:-1:y-n+1) ;
        old(x:-1:x-n+1,n:-1:1) old(x:-1:x-n+1,:) old(x:-1:x-n+1,y:-1:y-n+1)];



new=conv2(double(old),double(filter1),'same');
new = new(n+1:n+x , n+1:n+y);

function y = gauss(x,std)
y = exp(-x.^2/(2*std^2)) / (std*sqrt(2*pi));

