function liu_denoise_3d_fun_v02(imgStartDir,imgExpDir,max_t)
%%%
% Apply denoising on a set of images in a directory
%
% liu_denoise_3d_fun_v02(src,dest,max_t)
% INPUTS:
% 1. src => directory with images to denoise.
% 2. dest => location to export denoised images to.
% 3. max_t => maximum number of timepoints to denoise before quitting
% 
% 
% Adapted from:
% Vertebrate kidney tubules elongate using a planar cell
% polarity?dependent, rosette-based mechanism of convergent extension,
% S. Lienkamp et al.,
% Nature Genetics 44, 1382?1387 (2012) doi:10.1038/ng.2452
% (http://www.nature.com/ng/journal/v44/n12/full/ng.2452.html)
% 
% 
% Author: Dene Farrell
% Sloan Kettering Insitute
% Jennifer Zallen's Laboratory
% version: 1.0
% last edit: 2017 April 6
%
%
% Copyright (c) 2017 Dene Farrell, Jennifer Zallen
%
% Permission is hereby granted, free of charge, to any person obtaining a copy 
% of this software and associated documentation files (the "Software"), to deal 
% in the Software without restriction, including without limitation the rights 
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
% copies of the Software, and to permit persons to whom the Software is 
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
% SOFTWARE.

if nargin < 1 || isempty(imgStartDir)
   imgStartDir = pwd;
end

if nargin < 2 || isempty(imgExpDir)
   imgExpDir = [imgStartDir,filesep,'..',filesep,'denoised',filesep];
end
    
if nargin < 3 || isempty(max_t)
    max_t = inf;
end

% directory=pwd; %directory containing the images you want to analyze
suffix='*.TIF'; %*.bmp or *.tif or *.jpg
direc = dir([imgStartDir,filesep,suffix]); filenames={};
if isempty(direc)
    suffix='*.tif'; %*.bmp or *.tif or *.jpg
    direc = dir([imgStartDir,filesep,suffix]); filenames={};
end
[filenames{1:length(direc),1}] = deal(direc.name);
filenames = sortrows(filenames); %sort all image files

for imgind = 1:length(filenames)
    starttime = tic();
    imgfilename = filenames{imgind};
    img_load_name = fullfile(imgStartDir, imgfilename);
    display(['imgind = ',num2str(imgind),' filename ',imgfilename]);
    
    tnum = get_t_num_from_new_file_format(imgfilename);
    if tnum > max_t
        display(['tnum ',num2str(tnum),' greater than max t allowed ',num2str(max_t), 'SKIPPING --']);
        continue 
    end
    
    
%     outputdir = [directory,filesep,'denoised',filesep];
    imgfilename_noext = strtok(imgfilename,'.');
    outputFileName_tocheck = fullfile(imgExpDir, [imgfilename_noext,'.TIF']);
	if ~isempty(dir(outputFileName_tocheck))
        display(['imgind = ',num2str(imgind),' output found for ',imgfilename_noext]);
        continue        
    end




    %% for Loading a TIF stack
    InfoImage=imfinfo(img_load_name);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);% (should remove messy layer)

    blocksize = 120;
    buff = 5;
    putsize = blocksize - buff*2;
    m90 = ceil(mImage/putsize); %90 = (100 - 2*5) pix overlap on both sides
    n90 = ceil(nImage/putsize);
    nblocks = m90*n90;
    completeBlock = zeros(nImage,mImage,NumberImages);
    %         for i=1:NumberImages
    %            tempimg=imread(img_load_name,'Index',i);
    %            if numel(size(tempimg))>2
    %                 tempimg = rgb2gray(tempimg);
    %            end
    %            completeBlock(:,:,i) = tempimg;
    %         end

    for blockindm = 1:m90
        for blockindn = 1:n90
            display('building image stack');
            % img_in=zeros(nImage,mImage,NumberImages,'uint16');
            zdepth = NumberImages;
            xsize = blocksize;%100;
            ysize = blocksize;%100;
            xstart = 90*(blockindm-1)+1;
            ystart = 90*(blockindn-1)+1;
            xtakes = xstart:min((xstart+xsize-1),mImage);
            ytakes = ystart:min((ystart+ysize-1),nImage);
            img_in=zeros(numel(ytakes),numel(xtakes),zdepth,'uint16');
%             zlayers = max((round(NumberImages/2)-round(zdepth/2)),1):min((round(NumberImages/2)+round(zdepth/2)-1),NumberImages);
            zlayers = 1:zdepth;
            for i=1:zdepth
               tempimg=imread(img_load_name,'Index',zlayers(i));
               if numel(size(tempimg))>2
                    tempimg = rgb2gray(tempimg);
               end
               tempimgcrop = tempimg(ytakes,xtakes);
               img_in(:,:,i) = imresize(tempimgcrop,size(img_in(:,:,i)));
            end
            %%



            display('normalizing image');
            img_in = double(img_in);
            [imgnorm, shift_used] = normalize(img_in,1);
            % imgnorm = img_in; %to stay with uints


            % make image square and/or even
%             dims = size(imgnorm);
%             evenbool = mod(dims,2)==0;
%             padBool = [1-evenbool];
%             padBool(3) = 0;
%             imgnorm = padarray(imgnorm,padBool,0,'post');
%             dims = size(imgnorm);


            % myfilter = fspecial('gaussian',[3 3], 0.5);
            % img_smth = imfilter(imgnorm, myfilter, 'replicate');




    %         display('projecting max of center and showing...');
    %         midslice = round(dims(3)*1/2);
    %         takerlayers = (midslice-1):(midslice+1);
    %         projimg = max(imgnorm(:,:,takerlayers),[],3);
    %         h = figure; imagesc(projimg); colormap('gray');
    %         title('original img');


            % set(gca,'xlim',[200,250],'ylim',[200,250]);
            num_iters = 1;
            new_img = imgnorm;
            display(['running liu denoising ',num2str(num_iters),' times']);
            % multiple iterations of denoising
            for i = 1:num_iters

                img_di_dt = liu_denoising3D(new_img);

                di_dt = img_di_dt; %pick one of the versions
                change_const = 0.75;
                new_img = new_img + di_dt*change_const;


    %             projimg = max(new_img(:,:,takerlayers),[],3);
    %             hplus = figure; imagesc(projimg); colormap('gray');
    %         %     set(gca,'xlim',[200,600],'ylim',[200,600]);
    %             title(['iteration number',num2str(i)]);
    %             h = [h hplus];
            end
    %             close(h);

            xputs = (xstart+buff):min((xstart+xsize-1-buff),mImage-buff);
            yputs = (ystart+buff):min((ystart+ysize-1-buff),nImage-buff);
            completeBlock(yputs,xputs,:) = new_img(buff+1:(end-buff),buff+1:(end-buff),:);
        end
    end

    imgfilename = filenames{imgind};
    imgfilename_noext = strtok(imgfilename,'.');
    [completeBlocknorm, shift_used] = normalize(completeBlock,255);
    completeBlocknorm = uint8(completeBlocknorm);


%     outputdir = [directory,filesep,'denoised',filesep];
%     if ~isdir(outputdir)
%         mkdir(outputdir)
%     end
%     outputFileName = fullfile(outputdir, ['denoised_',imgfilename_noext,'.TIF']);
    outputFileName = fullfile(imgExpDir, [imgfilename_noext,'.TIF']);
    imwrite(completeBlocknorm(:, :, 1), outputFileName, 'Compression','none');
    for K=2:length(completeBlock(1, 1, :))
       imwrite(completeBlocknorm(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
    end

%     figure; imagesc(completeBlocknorm(:, :, 1)); colormap('gray');
    % figure; imagesc(completeBlock(:, :, 1)); colormap('gray');
    stoptime = tic();
    totaltime = (stoptime - starttime)/10e8;
    display(['------ image ',num2str(imgind), ' finished. ------']);
    display(['------ total time = ',num2str(totaltime/60), ' mins ------']);
end


