function [endmat, rel_indx, rel_indy] = concent_circs(rad,label)

diamtr = rad*2+1;
startmat = zeros(diamtr);
startmat(rad+1,rad+1) = 1;
padspecial = @(mat,p) padarray(mat,[p,p],0,'both'); %uniform padding all sides of p width
adjustcircle = @(x,a) padspecial(circle(x),((a-1)/2-x));
% x is radius of drawn circle
% a is diameter of subsuming mat
summats = arrayfun(adjustcircle,1:rad,ones(1,rad).*diamtr,'un',0);
catA=cat(3,summats{:});
endmat = sum(catA,3)+startmat;
endmat = (rad+label+1) - endmat;
endmat(endmat==rad+label+1) = 0;


[rel_indx, rel_indy] = (meshgrid(1:diamtr,1:diamtr));
rel_indx = rel_indx - (rad+1);
rel_indy = rel_indy - (rad+1);


return

% second attempt
% fairly efficient, figured out another way
labels_suc = label+1:(label+rad);
diamtr = rad*2+1;
startmat = zeros(diamtr);
padspecial = @(mat,p) padarray(mat,[p,p],0,'both'); %uniform padding all sides of p width
outercircle = @(x,a,lab) (padspecial(circle(x),((a-1)/2-x)) - padspecial(circle(x-1),((a-1)/2-x+1))).*lab;
% x is radius of drawn circle
% a is diameter of subsuming mat
circmats = arrayfun(outercircle,1:rad,ones(1,rad).*diamtr,labels_suc,'un',0);
catA=cat(3,circmats{:});
endmat = sum(catA,3);
endmat(rad+1,rad+1) = label;



% first attempt
% the old fashioned mathematical way of creating conc circs
% does not work efficiently with the confines of a pixel space
a = 0;
b = 0;
theta = linspace(0, 2*pi, 50);
[tmprad, tmpang] = meshgrid(0.5:0.25:1.75, theta);
tmpx = a+cos(tmpang).*tmprad;
tmpy = b+sin(tmpang).*tmprad;