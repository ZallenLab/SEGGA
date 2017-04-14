function a_out = proc_cell_image_grad(a)

% this is an experimental image processing algorithm
% that uses gradients, anisotropic, diffusion and other methods
% to enhance structure. It's still a work in progress and could benefit
% from some vectorization for the sake of speeding up the code.

% a = (a ./ max(a(:)));
% a = a*25;
% a(a>1) = 1;
    %stretch image size to avoid artefacts of method
    a = imresize(a,2);
    a_start = a;

    %%consider smoothing with weiner if orginal image is not smooth
%     a = wiener2(a,[2 2],.15);
%     before_smooth = a;
%     a = a.*a_start;
    
    %apply gradient method
    disp('running grad mthd first time');
    [a_dist, new_Fx,new_Fy] = dist_gradient_special(a);  
    img_out = inverse_gradient_numerical(a_start,new_Fx,new_Fy,a_dist);
    

    %   apply diffusion to remove some of the unwanted effects of the gradient method  
	disp('running anisotropic diff');
    anext = wiener2(img_out,[2 2],.15);
    anext  = (anext+a_start)./2;
    anext  = diffusionAnisotropic(anext, 'function', 'tuckey', 'sigma', 0.005, 'time', 2 , 'maxIter', 300);
    img_out = anext;
    
%     img_out = wiener2(img_out,[2 2],.15);
%     figure; imagesc(img_out); colormap('gray');
    disp('running grad mthd second time');
    [a_dist, new_Fx,new_Fy] = dist_gradient_special(img_out); 
    img_out = inverse_gradient_numerical(img_out,new_Fx,new_Fy,a_dist);
%     figure; imagesc(img_out); colormap('gray');
    
    
% 	disp('running anisotropic diff');
%     anext = wiener2(img_out,[2 2],.15);
% %     anext  = (anext+a_start)./2;
%     anext  = diffusionAnisotropic(anext, 'function', 'tuckey', 'sigma', 0.005, 'time', 2 , 'maxIter', 300);
%     anext = anext.*a_start;    
%     img_out = anext;
    
    a_out = imresize(img_out,1/2);
