function img = circthresh(src,r, fac, shape)
  if nargin < 4 || isempty(shape)
      c = double(getnhood(strel('disk', r, 0)));
  else
      c = shape;
      siz = size(c);
      if siz(1) ~= siz(2)
          disp('currently expecting square matrix for shape in circthresh.m');
          return
      end
      r = siz(1);

  end
  if nargin < 3 || isempty(fac)
      fac = 1;
  end
  [m,n]=size(src);
  fprintf('Thresholding cell walls...');

  if isinf(r)
    img = (src > mean(mean(src)));
  else
    
    %c = circle(r)*1; %the *1 converts the circle from a logical to a double.
    % The way I'm repeating the edge here isn't strictly correct...
    img = [ src(r:-1:1,r:-1:1) src(r:-1:1,:) src(r:-1:1,n:-1:n-r+1);
	    src(:,r:-1:1) src src(:,n:-1:n-r+1) ;
	    src(m:-1:m-r+1,r:-1:1) src(m:-1:m-r+1,:) src(m:-1:m-r+1,n:-1:n-r+1) ];
    img = conv2(img,c,'same')./sum(sum(c));
    img = ((fac * src) > img(r+1:r+m , r+1:r+n)); 
    %img = ((fac * src) ./ img(r+1:r+m , r+1:r+n)); 
    %img(img>5) = 5;
  end
  fprintf(' Done!\n');
