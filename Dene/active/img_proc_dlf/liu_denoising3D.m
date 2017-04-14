function img_di_dt = liu_denoising3D(img_in)

%% this function creates the following calculations on a 2D image
%% image -> hessian -> eigen values -> diffusion tensor -> di/dt (adapted Perona Malik Algorithm)
%% dI = liu_denoising(I) gives the time derivative (dI/dt) of the image (I) which is a 2D array
%% now called -> "liu_denoising"
%% adapted from "Vertebrate kidney tubules elongate using a planar cell polairty-dependent..." 
%% Supplementary note section

%% for testing  
% directory=pwd; %directory containing the images you want to analyze
% suffix='*.tif'; %*.bmp or *.tif or *.jpg
% direc = dir([directory,filesep,suffix]); filenames={};
% [filenames{1:length(direc),1}] = deal(direc.name);
% filenames = sortrows(filenames); %sort all image files
% img_in = imread(fullfile(directory, filenames{1}));
% if numel(size(img_in))>2
%     img_in = rgb2gray(img_in);
% end
% img_in = smoothn(img_in);
% max(img_in(:));
% min(img_in(:));
%%


%  img_in = normalize(img_in);
 [gx, gy, gz] = gradient(double(img_in)); %gradient is a vector [gx, gy, gz] defined for all points in img (n x m)
 [gxx, gxy, gxz] = gradient(gx); %hessian  is a 2x2 vector [gxx, gxy; gyx, gyy] defined for all points in img (n x m)
 [gyx, gyy, gyz] = gradient(gy);
 [gzx, gzy, gzz] = gradient(gz);
 
% NOTE:
%  [V,D] = eig(X) produces a diagonal matrix D of eigenvalues and a
%     full matrix V whose columns are the corresponding eigenvectors so
%     that X*V = V*D.
% Matrix D is the canonical form of A ? a diagonal matrix with A's eigenvalues on the main diagonal.
% Matrix V is the modal matrix ? its columns are the eigenvectors of A.
 
eigfun3d = @(axx, bxy, cxz, dyx, eyy, fyz, gzx, hzy, izz) eig([axx, bxy, cxz; dyx, eyy, fyz; gzx, hzy, izz]); %eigens from hessian (function)

% k = 1; %diffusion tensor from eigen values (function)
% diff_tens_fun = @(eig_lams,eig_vecs)...
%     exp(-((min(eig_lams(1),0)/k)^2)).*eig_vecs(1,:)*transpose(eig_vecs(1,:))+...
%     exp(-((min(eig_lams(4),0)/k)^2)).*eig_vecs(2,:)*transpose(eig_vecs(2,:));
% % moving this code lower down, because k must be defined before 
% % creating the function


%% for testing functions
% [a, b] = eigfun(2,1,1,2);
% startmat = [2, 1; 1, 2];
% [a2 b2] = eig(startmat);
% 
% lams = nonzeros(b);
% diff_tens_fun(a,b);
% new_k = .01;
% diffusion_tensor(b,a,new_k);
% diffusion_tensor(eig_lams,eig_vecs,k)
%%


%% getting eigen values from hessian
tic;
[eigvecs_out, eigvals_out] = arrayfun(eigfun3d,...
    gxx, gxy, gxz, gyx, gyy, gyz, gzx, gzy, gzz, 'UniformOutput',false);
eigsfromhessiantime = toc;
display(['time for eigen vals from hessian = ',num2str(eigsfromhessiantime)]);
%  this stores eigen values as a cell
% eigvecs_out is a  vector [gxx, gxy; gyx, gyy] defined for all points in img (n x m)
orig_dims = size(eigvals_out);



% % changing to matrix arrays from cells
% % not using the mat form because cellfun is faster
% eigvecs_mat = reshape(cat(3,eigvecs_out{:}),2,2,orig_dims(1),orig_dims(2)); %cell -> mat
% eigvals_mat = reshape(cat(3,eigvals_out{:}),2,2,orig_dims(1),orig_dims(2)); %cell -> mat
% eigvecs_mat = permute(eigvecs_mat,[3,4,1,2]);
% eigvals_mat = permute(eigvals_mat,[3,4,1,2]);
 

% %% testing that the mat is ordered properly
% % ----------------------
% ind = 400;
% tkrs = ones(2);
% eigvecs_out{ind,ind}
% % reshape(eigvecs_mat(ind,ind,:,:),2,2) %for permuted
% eigvecs_mat(:,:,ind,ind) %for non-permuted
% %% ----------------------



% difftens_mat = nan(orig_dims);
% tic;
% for i = 1:orig_dims(1)
%     for j = 1:orig_dims(2)
%         difftens_mat(i,j) = diff_tens_fun(eigvals_mat(:,:,i,j),eigvecs_mat(:,:,i,j));
%     end
% end
% forlooptime = toc;
% display(['time for diff tensor with "for" loop = ',num2str(forlooptime)]);
% % for loop is slower, not using

% % trying to figure out a good k constant from eigen value dist.
alleigs =[eigvals_out{:}];
alleigs = nonzeros(alleigs);
% k = mean(abs(alleigs))/2;
% just using the hard coded 'k' below now - not
k = min(0.00001,(mean(abs(alleigs)))^2); %for k use 1/1000 or 1/5th of the mean of |lamba| 

%% for checking eigen value ditribution
% figure; hist(alleigs(:),[-0.1:.001:0.1]);
% set(gca,'xlim',[-2,2]);
%%


%%
% k = 100; %diffusion tensor from eigen values (function)
diff_tens_fun3d = @(eig_lams,eig_vecs)...
    exp(-((min(eig_lams(1),0)/k)^2))*(eig_vecs(:,1)*transpose(eig_vecs(:,1)))+...
    exp(-((min(eig_lams(5),0)/k)^2))*(eig_vecs(:,2)*transpose(eig_vecs(:,2)))+...
    exp(-((min(eig_lams(9),0)/k)^2))*(eig_vecs(:,3)*transpose(eig_vecs(:,3)));
%%  diffusion tensor is a 3x3 matrix at each pixel
                          
tic;
display(['k = ',num2str(k)]);
D_tensor = cellfun(diff_tens_fun3d,eigvals_out,eigvecs_out,'UniformOutput',false);
% D_tensor2 = cellfun(@(x, y) diffusion_tensor(x, y, k),eigvals_out,eigvecs_out,'UniformOutput',true);
% either way works fine
cellfuntime = toc;
display(['time for diff tensor with cellfun = ',num2str(cellfuntime)]);
% used if variables are cells 

%%
tic;
gradcell = cellfun(@(x, y, z) {[x; y; z]},num2cell(gx), num2cell(gy), num2cell(gz));
grad2celltime = toc;
display(['time to make gradient into cell = ',num2str(grad2celltime)]);
%% The gradient is a 3x1 vector at each pixel


tic;
difftens_by_grad = cellfun(@(x,y) x*y, D_tensor,gradcell,'UniformOutput',false);
multtime = toc;
display(['time for diff tensor x gradient with arrayfun = ',num2str(multtime)]);
%% multiplying the diffusion tensor (3x3) by the gradient (3x1)
% gives a (3x1) output
difftens_times_gradx = cellfun(@(x) x(1),difftens_by_grad,'UniformOutput',true);
difftens_times_grady = cellfun(@(x) x(2),difftens_by_grad,'UniformOutput',true);
difftens_times_gradz = cellfun(@(x) x(3),difftens_by_grad,'UniformOutput',true);


img_di_dt = divergence(difftens_times_gradx,difftens_times_grady,difftens_times_gradz);

% img_dt_std = std(img_di_dt(:));
% img_dt_mean = mean(img_di_dt(:));

%% attempting to test the functional use of dIdt below here
return
[img_di_dt_norm, shift_used] = normalize(img_di_dt,1);


lim = stretchlim(img_di_dt_norm,0.01);
img_di_dt_adj = imadjust(img_di_dt_norm,lim);
img_di_dt_adj = img_di_dt_adj- mean(img_di_dt_adj(:));

myfilter = fspecial('gaussian',[3 3], 0.5);
img_di_dt_adj = imfilter(img_di_dt_adj, myfilter, 'replicate');

figure; imagesc(img_di_dt_norm); %colormap('gray');
figure; imagesc(img_di_dt_adj); %colormap('gray');





display('showing change to image');
figure; imagesc(img_in); colormap('gray');
title('original img');
set(gca,'xlim',[200,250],'ylim',[200,250]);
num_iters = 5;
new_img = img_in;
di_dt = img_di_dt_adj; %pick one of the versions
change_const = (1/std(di_dt(:)))^(1.5);
% change_const = 1e4/num_iters;
for i = 1:num_iters
    new_img = new_img + sig_fig(di_dt*change_const,4);
%     new_img = min(max(new_img,0),1);
    figure; imagesc(new_img); colormap('gray');
    title(['iteration number',num2str(i)]);
    set(gca,'xlim',[200,250],'ylim',[200,250]);
end

diffimg = sig_fig((img_in - new_img),4);
sum(diffimg(:))/numel(diffimg);



return
%% testing output
%% show original image and the resultant differential
% figure; imagesc(img_di_dt);
% set(gca,'xlim',[100,200],'ylim',[100,200]);
figure; imagesc(img_in);
set(gca,'xlim',[100,200],'ylim',[100,200]);

img_di_dt_norm = normalize(img_di_dt,1,false);
figure; imagesc(img_di_dt*5);
set(gca,'xlim',[100,200],'ylim',[100,200]);

% % % streamline doesn't seem to be relevant to this kind of gradient
% figure;
% [X,Y] = meshgrid(1:50:orig_dims(2),1:50:orig_dims(1));
% streamline(difftens_times_gradx,difftens_times_grady,X,Y);
% streamline(gx,gy,X,Y);
                                 
%% show hist of all eigen vlaues    
alleigs =[eigvals_out{:}];
alleigs = alleigs(:);
figure; hist(alleigs);
set(gca,'xlim');
mean(abs(alleigs))




 
