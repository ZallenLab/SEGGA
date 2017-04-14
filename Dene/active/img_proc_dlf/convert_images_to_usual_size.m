function convert_images_to_usual_size(dirname,extra_fname_str)

if isempty(dirname) || nargin ==0
    dirname = pwd;
end

cd(dirname)
myimages = dir('*.tif');

if isempty(myimages)
    myimages = dir('*.TIF');
end

if isempty(myimages)
    display('couldnt find images!');
end

%%% RESCALING - Keeping Aspect Ratio the Same
for i = 1:length(myimages)
    right_format_bool = any(strfind(myimages(i).name,'_T0')) && any(strfind(myimages(i).name,'_Z0'));
    if ~right_format_bool
        continue
    end
    tempimg = imread(myimages(i).name);
    tempimg = max(tempimg,[],3);
    old_dims = [512 672];    
    str = [myimages(i).name];
    expression = '_T000';
    splitStr = regexp(str,expression);
    keepstr = str(splitStr:end);
    
    newscale = max(old_dims)/max(size(tempimg));
    resized_img = imresize(tempimg,newscale);
    tempsavename = ['convertedsize',extra_fname_str,keepstr];
    imwrite(resized_img,tempsavename,'tif')        
end

return

%%% OLD RESCALING TECHNIQUE - CAUSES Stretching
for i = 1:length(myimages)
    tempimg = imread(myimages(i).name);
    tempimg = max(tempimg,[],3);
%     [token, remain] = strtok(myimages(i).name,'_T000');
%     dimtemp = size(tempimg);
%     rescaleval_first = 672/dimtemp(1);
%     rescaleval_second = 512/dimtemp(2);
    old_dims = [512 672];    
    str = [myimages(i).name];
    expression = '_T000';
    splitStr = regexp(str,expression);
    keepstr = str(splitStr:end);
    
    resized_img = imresize(tempimg,old_dims);
    tempsavename = ['convertedsize',extra_fname_str,keepstr];
    imwrite(resized_img,tempsavename,'tif')        
end