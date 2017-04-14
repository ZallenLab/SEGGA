function img_out = inverse_gradient_numerical(img_in,Fx,Fy,a_dist)



new_Fx = Fx;
new_Fy = Fy;


div = divergence(new_Fx, new_Fy);
mod_div = smoothn(-div);

imgcurr = img_in;
num_tsteps = 8;
const_dist = 1;%-20; %for [mean_Fx, mean_Fy] -> div 
const_self = .05;

se = strel('disk',2);


% div = divergence(mean_Fx, mean_Fy);



d_mean=mean(mod_div(:));
d_std=std(mod_div(:));

low_inds = logical(mod_div < (d_mean-d_std));
low_inds2= bwareaopen(low_inds,10);
CC = bwconncomp(low_inds2);
s  = regionprops(CC, 'centroid');
centroids = cat(1, s.Centroid);  %x,y is flipped back to 1,2 for centroids
linearinds = sub2ind(size(a_dist), round(centroids(:,2)), round(centroids(:,1)));
radii = round((a_dist(linearinds)./(2^(1/2))))-2;
new_circ_div = recursive_circles(mod_div,radii,centroids);



for i = 1:num_tsteps
    
	imgcurr =mat2gray(imgcurr);
    lims = stretchlim(imgcurr,[0.015,0.995]);
    imgcurr = min(max((imgcurr - lims(1)),0)/lims(2),1).*255;
    
    
    imgcurr = double(imgcurr) + new_circ_div*const_dist;
    imgcurr = min(max(imgcurr,0),300);
    
    selfL = del2(double(imgcurr));
    imgcurr = double(imgcurr) + selfL*const_self;
    imgcurr = imclose(smoothn(imgcurr),se);
    if mod(i,10)==0
        figure; imagesc(imgcurr);colormap('gray');
        
        title(['i = ',num2str(i)]);
%         imgcurr = imerode(imgcurr,se);
    end
   
end
img_out = imgcurr;

return


% old display and test code

% testing
[orig_Fx, orig_Fy] = gradient(double(image1));
L_mat = del2(double(image1));

% testimg = min(abs(inv_gradient(orig_Fx))+abs(inv_gradient(orig_Fy)),1);
testimg = max(min((inv_gradient(mean_Fx))+(inv_gradient(mean_Fy))+0.01,.015),-0.005);
figure; imagesc(testimg);colormap('gray');
figure; imagesc(-L_mat);colormap('gray');

div = divergence(new_Fx, new_Fy);
% div = divergence(mean_Fx, mean_Fy);
figure; imagesc(-div);colormap('gray');

mod_div = -div;
d_mean=mean(mod_div(:));
d_std=std(mod_div(:));
portion_fac = 1/2;
low_inds = logical(mod_div < (d_mean-d_std));
low_inds2= bwareaopen(low_inds,10);
CC = bwconncomp(low_inds2);
s  = regionprops(CC, 'centroid');
centroids = cat(1, s.Centroid);  %x,y is flipped back to 1,2 for centroids
linearinds = sub2ind(size(a_dist), round(centroids(:,2)), round(centroids(:,1)));
radii = round((a_dist(linearinds)./(2^(1/2))))-2;
labels = [1;cumsum(radii+1)]; %create space for unique circle identities
figure; imagesc(low_inds2);colormap('gray');
imshow(low_inds2)
hold on
plot(centroids(:,1), centroids(:,2), 'b*');
hold off

[VX,VY] = voronoi(centroids(:,1), centroids(:,2));
figure; imagesc(img_in);colormap('gray');
hold on
plot(VX,VY, 'r');


tempind = 1;
rad = radii(tempind);
label = labels(tempind);
[endmat, rel_indx, rel_indy] = concent_circs(rad,label);
mat_in = zeros(size(a_dist));
locx = round(centroids(tempind,1));
locy = round(centroids(tempind,2));

function newmat =  replace_circs(mat_in,rad,label,locx,locy)
    
    [circmat, rel_indx, rel_indy] = concent_circs(rad,label);
    newmat = mat_in;
    rel_indx = rel_indx + locx;
    rel_indy = rel_indy + locy;
    off_gridx = (rel_indx<1)|(rel_indx>size(mat_in,2));
    off_gridy = (rel_indy<1)|(rel_indy>size(mat_in,1));
    off_grid = off_gridx|off_gridy;
    
%     sub_locx = rel_indx(~off_grid);
%     sub_locy = rel_indy(~off_grid);
%     sub_vals = circmat(~off_grid);
    
    lin_subinds = sub2ind(size(a_dist), rel_indy(~off_grid), rel_indx(~off_grid));
    newmat(lin_subinds) = circmat(~off_grid);
    figure; imagesc(newmat);
    
    new_dist_div = recursive_circles(mod_div,radii,centroids);
    
    figure; imagesc(new_dist_div);colormap('gray');

    


    mat_in(sub2ind(size(a_dist),round(centroids(1:10,2)),round(centroids(1:10,1)))) = labels(1:10);
    figure; imagesc(mat_in);




% mod_div(mid_inds) = d_mean;
mod_div = smoothn(mod_div);
figure; imagesc(mod_div);colormap('gray');




% % previous techniques, testing and visualizing:
% L_mat = del2(double(image1));
% gradient
% Fx = zeros(size(L_mat));
% Fy = zeros(size(L_mat));
% Ldims = size(L_mat);
% Lmat_reshape_x = reshape(L_mat,Ldims(1),1,Ldims(2)); %last dim is x
% rotL = flipud(rot90(L_mat));
% Lmat_reshape_y = reshape(rotL,Ldims(2),1,Ldims(1)); %last dim is y
% 
% for i = 1:Ldims(2)
%     Fy(:,i) = cumsum(-squeeze(Lmat_reshape_y(i,1,:)));
%     
% end
% for ii = 1:Ldims(1)
%     Fx(ii,:) = cumsum(-squeeze(Lmat_reshape_x(ii,1,:)));
% end
% 
% figure;
% imagesc(a_dist);
% hold on
% % quiver(dist_Fx,dist_Fy,'r','AutoScaleFactor', 1.5);
% quiver(Fx,Fy,'r','AutoScaleFactor', 1.5);
% hold off;
% axis image;
% title(filenames{counter},'interpreter','none')
% set(gca,'xtick',[],'ytick',[])
% drawnow;

