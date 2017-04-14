function interp3d_img_doublesample(imgStartDir,imgExpDir,supersampleBool,smthBool)


if nargin <3 || isempty(supersampleBool)
    supersampleBool = true;
end


if nargin <4 || isempty(smthBool)
    smthBool = true;
end

if ~(smthBool||supersampleBool)
    display('nothing to do if neither super sampling nor smoothing is specified');
    return
end


if nargin <1 || isempty(imgStartDir)
    imgStartDir = pwd;
end

if nargin <2 || isempty(imgExpDir)
    if smthBool && ~supersampleBool
        imgExpDir = [imgStartDir,filesep,'smoothed',filesep];
    else if ~smthBool && supersampleBool
            imgExpDir = [imgStartDir,filesep,'supersampled',filesep];
        else if smthBool && supersampleBool
                imgExpDir = [imgStartDir,filesep,'sampled2_smthd',filesep];
            else
                display('nothing to do based on input');
                return;
            end
        end
    end
end





suffix = '*.TIF'; %*.bmp or *.tif or *.jpg
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
    
	outputdir_tocehck = imgExpDir;
    imgfilename_noext = strtok(imgfilename,'.');
    outputFileName_tocheck = fullfile(outputdir_tocehck, [imgfilename_noext,'.TIF']);
    if ~isempty(dir(outputFileName_tocheck))
        display(['imgind = ',num2str(imgind),' output found for ',imgfilename_noext]);
        continue 
    end

    

    %% for Loading a TIF stack
    InfoImage=imfinfo(img_load_name);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);% 

% % this stuff is used for chopping up images 
% % when running denoising
%     blocksize = 100;
%     buff = 5;
%     putsize = blocksize - buff*2;
%     m90 = ceil(mImage/putsize); %90 = (100 - 2*5) pix overlap on both sides
%     n90 = ceil(nImage/putsize);
%     nblocks = m90*n90;
    

    completeBlock = uint16(zeros(nImage,mImage,NumberImages));
    for i=1:NumberImages
        completeBlock(:,:,i)=imread(img_load_name,'Index',i);
    end
    completeBlock = double(completeBlock);
    
% %     stretch and normalize to uint8
%     ninetyninth_prctile = prctile(completeBlock(:),99.5);
%     first_prctile = prctile(completeBlock(:),0.5);
%     completeBlock = max(completeBlock-first_prctile,0)/(ninetyninth_prctile-first_prctile)*255;
% %     completeBlock = uint8(completeBlock);
%     
    
    
	if supersampleBool
        [x,y,z] = meshgrid(1:mImage, 1:nImage, 1:NumberImages); 
        [xi,yi,zi] = meshgrid(1:0.5:mImage, 1:0.5:nImage, 1:0.5:NumberImages);
        vi = interp3(x,y,z,completeBlock,xi,yi,zi); % vi is 25-by-40-by-25
    else
        vi = completeBlock;
	end

    if smthBool
        display(['------ image ',num2str(imgind), ' running... ------']);
        display(['------ writing smoothed file ------']);

    %     figure;
    %     slice(xi,yi,zi,vi,[6 9.5],2,[-2 .2]), shading flat

        num_iter = 1;
        delta_t = 3/44;
        kappa = 40;
        option = 1;
        voxel_spacing = ones(3,1);
        img_out = anisodiff3D(vi, num_iter, delta_t, kappa, option, voxel_spacing);
        img_out = uint16(img_out);

        img_out_final = nan(nImage, mImage, size(vi,3));
        for i = 1:size(vi,3)
            img_out_final(:,:,i) = imresize(img_out(:,:,i), [nImage mImage]);
        end

        img_out_final = uint16(img_out_final);
        imgfilename_noext = strtok(imgfilename,'.');
        if ~isdir(imgExpDir)
            mkdir(imgExpDir)
        end
        outputFileName = fullfile(imgExpDir, [imgfilename_noext,'.TIF']);
        imwrite(img_out_final(:, :, 1), outputFileName, 'Compression','none');
        for K=2:length(img_out_final(1, 1, :))
           imwrite(img_out_final(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
        end
        display(['------ writing smoothened image ',num2str(imgind), ' finished. ------']);

%     or just supersample
    else if supersampleBool

        % %  supersample without smoothening
            display(['------ image ',num2str(imgind), ' running... ------']);
            display(['------ writing supersample (not smoothed) file ------']);

            img_out_final2 = nan(nImage, mImage, size(vi,3));
            for i = 1:size(vi,3)
                img_out_final2(:,:,i) = imresize(vi(:,:,i), [nImage mImage]);
            end

            img_out_final = uint16(img_out_final2);
%             imgExpDir = [directory,filesep,'doublesampled',filesep];
            imgfilename_noext = strtok(imgfilename,'.');
            if ~isdir(imgExpDir)
                mkdir(imgExpDir)
            end
            outputFileName = fullfile(imgExpDir, [imgfilename_noext,'.TIF']);
            imwrite(img_out_final(:, :, 1), outputFileName, 'Compression','none');
            for K=2:length(img_out_final(1, 1, :))
               imwrite(img_out_final(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
            end
            stoptime = tic();
            totaltime = (stoptime - starttime)/10e8;
            display(['------ time for image  #',num2str(imgind),' -- ',num2str(totaltime), ' (secs) ------']);
            display(['------double sampling of image ',num2str(imgind), ' finished. ------']);            
        end
    end    
    
    
end