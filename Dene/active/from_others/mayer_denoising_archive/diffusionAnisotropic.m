function sol = diffusionAnisotropic(img, varargin)
% DIFFUSIONANISOTROPIC
% Anisotropic image diffusion as defined by Joachim Weickert. A
% comprehensive introduction into this algorithm class can be found in:
% 
% Joachim Weickert: Anisotropic Diffuion in Image Processing, ECMI Series,
% Teubner-Verlag, Stuttgart, Germany, 1998, available online.
%
% The implementation contains the originally proposed anisotropic
% formulation of the Perona-Malik method, with two
% edgestoping function (Perona-Malik and Tuckey), as well as coherence
% enhancement diffusion.
% 
% The underlying PDE is solved by the lagged diffusivity method 
% (C. R. Vogel, 1996, see below) using red-black Gauss-Seidel iteration 
% steps.
%
% Parameters:
% SOL = denoisePM(IMG, VARARGIN)
% IMG: 2D image matrix
% SOL: Resulting diffused image 
% VARARGIN: Optional parameters:
%   sigma: one or more parameters for the diffusion, depending on the
%        edge-stopping function. 
%   time: Time parameter - Amount of diffusion applied
%   function: Type of Diffusion 
%        Default: 'tukey' (sigma: Standart Derivation)
%        'perona' (sigma: Standart Derivation)
%        'coherence' (sigma: 3-Array: 1 = Standart Derivation, 
%                                     2 = alpha in between [0,1],
%                                     3 = Diffusion weight)
%        The corresponding 'norm' options normalize the diffusion to the
%        largest structure tensor eigenvalue on the image. Faster
%        convertion and slightly different results (sigma dependency!) have
%        to be expected.
%   sigmaGauss: Standartderivation parameter(s) for pre- and postsmoothing
%        for gradient calculation. Either scalar or 2-Array 
%        Default: 1
%   maxIter: Max. Iterations, Default: 200
%   initialSolution: Initial Solution
%
% The lagged diffusitivy solution of the PDE was proposed in:
% C. R. Vogel, M. E. Oman: Iterative Methods for Total Variation Denoising,
% SIAM Journal on Scientific Computing, 17(1), 1996, 227?238.
% 
% Further discussion on the method can be found in:
% T. Chan, P. Mulet: On the convergence of the lagged diffusivity fixed
% point method in total variation image restoration,
% SIAM journal on numerical analysis, 36(2), 1999, 354?367.
%
% Implementation by Markus Mayer, Pattern Recognition Lab, 
% University of Erlangen-Nuremberg, 2008
% This version of the Code was NOT revised, therefore use it with caution -
% if you'll find any bugs, please tell us!
%
% You may use this code as you want. I would be grateful if you would go to
% my homepage look for articles that you find worth citing in your next
% publication:
% http://www5.informatik.uni-erlangen.de/en/our-team/mayer-markus
% Thanks, Markus

Params.edgeStopFunction = 'tukey';
Params.sigma = 20;
Params.sigmaGauss = 1;
Params.maxIter = 200;
Params.time = 3;
Params.initialSolution = [];

% Read Optional Parameters
if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end

for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'sigma'))
        Params.sigma = varargin{k+1};
    elseif (strcmp(varargin{k}, 'sigmaGauss'))
        Params.sigmaGauss = varargin{k+1};
    elseif (strcmp(varargin{k}, 'time'))
        Params.time = varargin{k+1};
    elseif (strcmp(varargin{k}, 'maxIter'))
        Params.maxIter = varargin{k+1};
    elseif (strcmp(varargin{k}, 'function'))
        Params.edgeStopFunction = varargin{k+1};
    elseif (strcmp(varargin{k}, 'initialSolution'))
        Params.initialSolution = varargin{k+1};
    end
end


if strcmp(Params.edgeStopFunction, 'coherence') || strcmp(Params.edgeStopFunction, 'normcoherence')
    if size(Params.sigma,2) == 1
        Params.sigma(2) = 0.001;
        Params.sigma(3) = 1;
    elseif size(Params.sigma,2) == 2
        Params.sigma(3) = 1;
    end
end

if strcmp(Params.edgeStopFunction, 'tukcoherence')
    if size(Params.sigma,2) == 1
        Params.sigma(2) = 0.01;
        Params.sigma(3) = 0.2;
    elseif size(Params.sigma,2) == 2
        Params.sigma(3) = 0.2;
    end
end

% Add a 1-border to the image to avoid boundary problems
img = [img(:,1), img, img(:,size(img,2))];
img = vertcat(img(1,:), img, img(size(img,1),:));

iter = 0; % Iteration counter

if numel(Params.initialSolution) == 0
    sol = img; %Solution initialisation: original image
else
    sol = [Params.initialSolution(:,1), Params.initialSolution, ...
           Params.initialSolution(:,size(Params.initialSolution,2))];
    sol = vertcat(sol(1,:), sol, sol(size(sol,1),:));
end

% Preparing stencil matrices
stencilN = zeros(size(img, 1), size(img, 2));
stencilS = zeros(size(img, 1), size(img, 2));
stencilE = zeros(size(img, 1), size(img, 2));
stencilW = zeros(size(img, 1), size(img, 2));

stencilCO = zeros(size(img, 1), size(img, 2));
stencilM = zeros(size(img, 1), size(img, 2));

resimg = img;
resold = 1e+30; % old residual
resarr = [1e+30 1e+30 1e+30]; % array of the last 3 residual changes

% Stoping criteria: No further improvement over 3 iterations
% or max. iteration limit reached
while (sum(resarr) > 0) && (iter < Params.maxIter);
    % Calculation of the edge-stoping function
    if size(Params.sigmaGauss, 2) == 2
        [Gx2, Gxy, Gy2] = structureTensor(sol, Params.sigmaGauss(1), Params.sigmaGauss(2));
    else
        [Gx2, Gxy, Gy2] = structureTensor(sol, Params.sigmaGauss(1), 1);
    end
    
    [Dy2, Dxy, Dx2] = diffusionTensor(Gx2, Gxy, Gy2, Params);
    
    % Bringing in the timefactor
    Dx2 =  (Dx2 ) * Params.time;
    Dy2 =  (Dy2 ) * Params.time; 
    Dxy =  Dxy * Params.time * 2; % Weighting of diagonal diffusion 
   
    % stencil computation
    stencilN(2:end-1, 2:end-1) = (Dx2(2:end-1, 2:end-1) + Dx2(1:end-2, 2:end-1))/2;
    stencilS(2:end-1, 2:end-1) = (Dx2(2:end-1, 2:end-1) + Dx2(3:end, 2:end-1))/2;
    stencilE(2:end-1, 2:end-1) = (Dy2(2:end-1, 2:end-1) + Dy2(2:end-1, 3:end))/2;
    stencilW(2:end-1, 2:end-1) = (Dy2(2:end-1, 2:end-1) + Dy2(2:end-1, 1:end-2))/2;
    
    stencilCO =  0.25 * Dxy; % One stencil for all corners
    
    stencilM = stencilN + stencilS + stencilE + stencilW + 1; % Center
   
    % Solution computation: R/B Gauss Seidel
    sol(2:2:end-1, 2:2:end-1) = (img(2:2:end-1, 2:2:end-1) ...
        + (stencilN(2:2:end-1, 2:2:end-1) .* sol(1:2:end-2, 2:2:end-1) ...
        + stencilS(2:2:end-1, 2:2:end-1) .* sol(3:2:end, 2:2:end-1) ...
        + stencilE(2:2:end-1, 2:2:end-1) .* sol(2:2:end-1, 3:2:end)...
        + stencilW(2:2:end-1, 2:2:end-1) .* sol(2:2:end-1, 1:2:end-2) ...
        - stencilCO(2:2:end-1, 2:2:end-1) .* sol(1:2:end-2, 3:2:end) ...
        + stencilCO(2:2:end-1, 2:2:end-1) .* sol(1:2:end-2, 1:2:end-2) ...
        - stencilCO(2:2:end-1, 2:2:end-1) .* sol(3:2:end, 1:2:end-2) ...
        + stencilCO(2:2:end-1, 2:2:end-1) .* sol(3:2:end, 3:2:end) )) ...
        ./ stencilM(2:2:end-1, 2:2:end-1);

    sol(3:2:end, 3:2:end) = (img(3:2:end, 3:2:end) ...
        + (stencilN(3:2:end, 3:2:end) .* sol(2:2:end-1, 3:2:end) ...
        + stencilS(3:2:end, 3:2:end) .* sol(4:2:end, 3:2:end) ...
        + stencilE(3:2:end, 3:2:end) .* sol(3:2:end, 4:2:end) ...
        + stencilW(3:2:end, 3:2:end) .* sol(3:2:end, 2:2:end-1) ...
        - stencilCO(3:2:end, 3:2:end) .* sol(2:2:end-1, 4:2:end) ...
        + stencilCO(3:2:end, 3:2:end) .* sol(2:2:end-1, 2:2:end-1) ...
        - stencilCO(3:2:end, 3:2:end) .* sol(4:2:end, 2:2:end-1) ...
        + stencilCO(3:2:end, 3:2:end) .* sol(4:2:end, 4:2:end) )) ...
        ./ stencilM(3:2:end, 3:2:end);

    sol(2:2:end-1, 3:2:end) = (img(2:2:end-1, 3:2:end) ...
        + (stencilN(2:2:end-1, 3:2:end) .* sol(1:2:end-2, 3:2:end) ...
        + stencilS(2:2:end-1, 3:2:end) .* sol(3:2:end, 3:2:end) ...
        + stencilE(2:2:end-1, 3:2:end) .* sol(2:2:end-1, 4:2:end) ...
        + stencilW(2:2:end-1, 3:2:end) .* sol(2:2:end-1, 2:2:end-1) ...
        - stencilCO(2:2:end-1, 3:2:end) .* sol(1:2:end-2, 4:2:end) ...
        + stencilCO(2:2:end-1, 3:2:end) .* sol(1:2:end-2, 2:2:end-1) ...
        - stencilCO(2:2:end-1, 3:2:end) .* sol(3:2:end, 2:2:end-1) ...
        + stencilCO(2:2:end-1, 3:2:end) .* sol(3:2:end, 4:2:end) )) ...
        ./ stencilM(2:2:end-1, 3:2:end);

    sol(3:2:end, 2:2:end-1) = (img(3:2:end, 2:2:end-1) ...
        + (stencilN(3:2:end, 2:2:end-1) .* sol(2:2:end-1, 2:2:end-1) ...
        + stencilS(3:2:end, 2:2:end-1) .* sol(4:2:end, 2:2:end-1) ...
        + stencilE(3:2:end, 2:2:end-1) .* sol(3:2:end, 3:2:end) ...
        + stencilW(3:2:end, 2:2:end-1) .* sol(3:2:end, 1:2:end-2) ...
        - stencilCO(3:2:end, 2:2:end-1) .* sol(2:2:end-1, 3:2:end) ...
        + stencilCO(3:2:end, 2:2:end-1) .* sol(2:2:end-1, 1:2:end-2) ...
        - stencilCO(3:2:end, 2:2:end-1) .* sol(4:2:end, 1:2:end-2) ...
        + stencilCO(3:2:end, 2:2:end-1) .* sol(4:2:end, 3:2:end) )) ...
        ./ stencilM(3:2:end, 2:2:end-1);

    % Residual computation
    resimg(2:end-1, 2:end-1) = (-(stencilN(2:end-1, 2:end-1) .* sol(1:end-2, 2:end-1) ...
        + stencilS(2:end-1, 2:end-1) .* sol(3:end , 2:end-1) ...
        + stencilE(2:end-1, 2:end-1) .* sol(2:end-1, 3:end) ...
        + stencilW(2:end-1, 2:end-1) .* sol(2:end-1, 1:end-2) ...
        - stencilCO(2:end-1, 2:end-1) .* sol(1:end-2, 3:end)  ...
        + stencilCO(2:end-1, 2:end-1) .* sol(1:end-2, 1:end-2) ...
        - stencilCO(2:end-1, 2:end-1) .* sol(3:end,   1:end-2) ...
        + stencilCO(2:end-1, 2:end-1) .* sol(3:end, 3:end) )) ...
        + stencilM(2:end-1, 2:end-1) .* sol(2:end-1, 2:end-1) - img(2:end-1, 2:end-1);

    res = sum(sum(real(resimg .^ 2)));

    resdiff = resold - res;
    resold = res;
    resarr = [resdiff resarr(1, 1:(size(resarr, 2)-1))];

    % Duplicate edges as new borders
    sol = [sol(:,2), sol(:, 2:end-1), sol(:,end-1)];
    sol = vertcat(sol(2,:), sol(2:end-1, :), sol(end-1,:));
    
    iter = iter + 1;
end

% Remove border
sol = sol(2:(size(sol,1)-1), 2:(size(sol,2)-1));

end

%--------------------------------------------------------------------------
function [Gx2, Gxy, Gy2] = structureTensor(img, sigmaPre, sigmaPost)
% StructureTensor: Calculate the structure tensor

gauss1 = fspecial('gaussian', round(sigmaPre * sigmaPre + 1) , sigmaPre);
smoothimg = imfilter(img, gauss1, 'symmetric');

[Gx, Gy] = gradient(smoothimg);
Gx2 = Gx .^ 2;
Gxy = Gx .* Gy;
Gy2 = Gy .^ 2;

gauss2 = fspecial('gaussian', round(sigmaPost * sigmaPost + 1) , sigmaPost);
Gx2 = imfilter(Gx2, gauss2, 'symmetric');
Gy2 = imfilter(Gy2, gauss2, 'symmetric');
Gxy = imfilter(Gxy, gauss2, 'symmetric');

end

%--------------------------------------------------------------------------
function [Dx2, Dxy, Dy2, kappa] = diffusionTensor(Gx2, Gxy, Gy2, Params)
% DiffusionTensor: Calculate Diff.Tensor out of structure tensor and
%                  parameters

% Eigenvalue calculation
temp = sqrt(((Gx2 - Gy2) .^ 2) + 4 * (Gxy .^ 2));
temp = real(temp);

lambda1 = (Gx2 + Gy2 + temp) * 0.5;
lambda2 = (Gx2 + Gy2 - temp) * 0.5;

% Eigenvector calculation
teta = 0.5 * atan2(- 2 * Gxy, Gy2 - Gx2);
cosT = cos(teta);
sinT = sin(teta);

v1x = cosT;
v1y = sinT;
v2x = -sinT;
v2y = cosT;

% Different edge-stoppers
if strcmp(Params.edgeStopFunction, 'tuckey')
    lambda1 = zeros(size(lambda2, 1), size(lambda2, 2));
    lambda1 = lambda1 + 1;
    lambda2 = tukeyEdgeStop(lambda2, Params.sigma);
elseif strcmp(Params.edgeStopFunction, 'normtuckey')
    lambda1 = zeros(size(lambda2, 1), size(lambda2, 2));
    lambda1 = lambda1 + 1;
    lambda2 = lambda2 ./ (max(max(lambda2)));
    lambda2 = tukeyEdgeStop(lambda2, Params.sigma);
    lambda2 = lambda2 ./ (max(max(lambda2)));
elseif strcmp(Params.edgeStopFunction, 'perona')
    lambda1 = zeros(size(lambda2, 1), size(lambda2, 2));
    lambda1 = lambda1 + 1;
    lambda2 = lambda2 ./ (max(max(lambda2)));
    lambda2 = peronaEdgeStop(lambda2, Params.sigma);
elseif strcmp(Params.edgeStopFunction, 'coherence')
    kappa = (lambda1 - lambda2) .^ (2 * Params.sigma(3));
    kappa(kappa <= 0) = 1e-20;
    lambda1 = Params.sigma(2) + (1 - Params.sigma(2)) * exp(- Params.sigma(1) ./ kappa);
    lambda2 = Params.sigma(2);
elseif strcmp(Params.edgeStopFunction, 'normcoherence')
    kappa = (lambda1 - lambda2) .^ (2 * Params.sigma(3));
    kappa = kappa ./ max(max(kappa));
    kappa(kappa <= 0) = 1e-20;
    lambda1 = Params.sigma(2) + (1 - Params.sigma(2)) * exp(- Params.sigma(1) ./ kappa);
    lambda1 = lambda1 ./ max(max(lambda1));
    lambda2 = Params.sigma(2);
elseif strcmp(Params.edgeStopFunction, 'tukcoherence')
    kappa = (lambda1 - lambda2) .^ 2;
    kappa = kappa ./ max(max(kappa));
    kappa(kappa <= 0) = 1e-20;
    lambda1 = (1 - Params.sigma(3)) * exp(- Params.sigma(1) ./ kappa) ;   
    lambda1 = lambda1 ./ max(max(lambda1));
    
    lambda2 = lambda2 ./ (max(max(lambda2)));
    lambda2 = Params.sigma(3) .* tukeyEdgeStop(lambda2, Params.sigma(2)) ;
    lambda2 = lambda2 ./ (max(max(lambda2)));
end

% Diffusion Tensor out of new eigenvalues and the eigenvectors
Dx2 = lambda1 .* (v1x .^ 2) + lambda2 .* (v2x .^ 2);
Dxy = lambda1 .* v1x .* v1y + lambda2 .* v2x .* v2y;
Dy2 = lambda1 .* (v1y .^ 2) + lambda2 .* (v2y .^ 2);

end

%--------------------------------------------------------------------------
% Tuckey edge-stoping function
function lambda2 = tukeyEdgeStop(lambda, sigma)
lambda2 = 1 - (lambda ./ sigma) .^ 2;
lambda2(lambda2 < 0) = 0;
lambda2 = lambda2 .* lambda2;

end

%--------------------------------------------------------------------------
% Perona-Malik edge-stoping function
function lambda2 = peronaEdgeStop(lambda, sigma)
lambda2 = exp(- lambda .* lambda / (2 * sigma * sigma));
lambda2 = lambda2 ./ (max(max(lambda2)));

end



