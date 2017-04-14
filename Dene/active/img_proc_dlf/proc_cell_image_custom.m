function a_out = proc_cell_image_custom(a)

% a = (a ./ max(a(:)));
% a = a*25;
% a(a>1) = 1;
a_start = a;
a = wiener2(a,[2 2],.15);
    before_smooth = a;
%     
    a_big = imresize(a, 2);    
    SE = strel('disk',1); 
    a_big =  imclose(a_big,SE);
    SE = strel('disk',1); 
    a_big = imerode(a_big,SE);
    a = imresize(a_big, 1/2);    
    
    
    a = a.*before_smooth;
    
    a = adapthisteq(a); %moved by ori
    a = imadjust(a, stretchlim(a(a>0)), [0, 1]);
    a = a.*a_start;
    
    % 
%  
%     
% %     SE = strel('square',1); 
% %     a =  imclose(a,SE);
% %     a = adapthisteq(a);
% %     
% %     
% %     
% % %     a = a.*(wiener2(a,[2 2],.15));
% %     a =  medfilt2(a);
% %     SE = strel('square',2); 
% %     a = imerode(a,SE);
% %     SE = strel('square',1); 
% %     a =  imclose(a,SE);
% %     a = imerode(a,SE);
% %     
% %     
% %     second_stage = a;
% %     
% %     
% % %     
%     SE = strel('square',2);
%     a = imdilate(a,SE);
%     a =  imclose(a,SE);
%     SE = strel('square',1); 
%     a = imerode(a,SE);
%     SE = strel('square',2); 
%     a = imdilate(a,SE);
%     SE = strel('square',3);
%     a =  imclose(a,SE);
%     SE = strel('square',2); 
%     a = imerode(a,SE);
% %     
% %     
% %     
% % %     a = a.*before_smooth;
% % %     SE = strel('square',2);
% % %     a = imdilate(a,SE);
% % %     a =  imclose(a,SE);
% % %     SE = strel('square',1); 
% % %     a = imerode(a,SE);
% % %     SE = strel('square',4); 
% % %     a =  imclose(a,SE);
% %     
% %     a = a.*second_stage;
% %     SE = strel('square',2);
% %     a = imdilate(a,SE);
% %     a =  imclose(a,SE);
% %     SE = strel('square',1); 
% %     a = imerode(a,SE);
% %     SE = strel('square',4); 
% %     a =  imclose(a,SE);
    
    a_out = a;
