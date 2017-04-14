function scaleBarH = add_scale_bar_to_single_img(imgIn,scaleBarSize,pixelSize,scaleBarLoc,...
                                    expectedimgDims,scaleBarColor,readyFigH,saveName,vertBool)

if nargin < 9
    vertBool = false; %draw scale bar vertically
end
                                
if nargin > 6 && ~isempty(readyFigH)
    if ishandle(readyFigH)
        useExistingFigBool = true;
    else
        useExistingFigBool = false;
    end
else
    useExistingFigBool = false;
end

if ~useExistingFigBool
    if nargin < 1 || isempty(imgIn)
        actionDir = pwd;
        imgChoiceMethod = questdlg('image choice method', ...
                             'Input Image', ...
                             'first', 'manual', 'cancel', 'cancel');
        switch imgChoiceMethod    
            case 'first'
                allImgs = dir([actionDir,filesep,'*.TIF']);
                if isempty(allImgs)
                    allImgs = dir([actionDir,filesep,'*.TIFF']);
                end
                if isempty(allImgs)
                    allImgs = dir([actionDir,filesep,'*.tif']);
                end
                if isempty(allImgs)
                    allImgs = dir([actionDir,filesep,'*.tiff']);
                end
                if isempty(allImgs)
                    display('no image found');
                    return
                end
                imgIn = allImgs(1).name;

            case 'manual'
                [imgIn, imgpath] = uigetfile('*');
                imgIn = fullfile(imgpath, imgIn);
            otherwise
                display('user cancelled (imgIn)');
                return
        end
    end
    imgtmp = imread(imgIn);
    imgzs = size(imgtmp);
else
    current_graphics = readyFigH.Children(1).Children;
    imgtmp = findall(current_graphics,'type','image');
    imgsz = size(imgtmp.CData);
end
imgsz = imgsz(1:2);

if nargin <2 || isempty(scaleBarSize)
%     scaleBarSize = 10; %10 microns
	prompt={'Enter scale bar size (microns):'};
    name='scale bar size';
    numlines=1;
    defaultanswer={'10'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    scaleBarSize = str2num(answer{1});
end

if nargin <3 || isempty(pixelSize)
%     pixelSize = 0.32; %1pixel length = 0.32 microns
	prompt={['Current Image Dimensions: [', num2str(imgsz),'], Enter pixel length (microns):']};
    name='pixel length';
    numlines=1;
    defaultanswer={'0.33'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    pixelSize = str2num(answer{1});
end


if nargin <4 || isempty(scaleBarLoc)
%     pixelSize = 0.32; %1pixel length = 0.32 microns
	prompt={'scale bar location'};
    str = {'northeast',...
           'northwest',...
           'southeast',...
           'southwest',...
           'specific'};
	[sBarSelection,v] = listdlg('PromptString',prompt,...
                      'SelectionMode','single',...
                      'ListString',str);
    if v==0
        display('user cancelled (scaleBarLoc)');
        return
    end
    sBarSelection = str{sBarSelection};
    switch sBarSelection
        case 'northeast'
            sbarStart = [0.2,0.8];
        case 'northwest'
            sbarStart = [0.2,0.2];
        case 'southeast'
            sbarStart = [0.8,0.8];
        case 'southwest'
            sbarStart = [0.8,0.2];
        case 'specific'
            	prompt={'x:','y:'};
                name='unit length coordinates';
                numlines=1;
                defaultanswer={'0.8','0.8'};
                pause(0.01);
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                sbarStart(1) = 1-str2num(answer{2});
                sbarStart(2) = str2num(answer{1});
        otherwise
            display('sBarSelection unknown');
            return
    end
else
    sbarStart = scaleBarLoc;            
end

if nargin <5 || isempty(expectedimgDims)
%     expectedimgDims = [512,672];
    prompt={'image dimensions'};
    name='expected image dimensions';
    numlines=1;
%     defaultanswer={'512,672'};
    defaultanswer={num2str(imgsz)};
    
    pause(0.01);
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    expectedimgDims = str2num(answer{1});
end

if nargin <6 || isempty(scaleBarColor)
    prompt={'color'};
    name='scale bar color';
    numlines=1;
    defaultanswer={'1 0 1'};
    pause(0.01);
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    scaleBarColor = str2num(answer{1});
end

if ~useExistingFigBool
    tempImg = imread(imgIn);
    actualimgDims = size(tempImg);
else
    ax1 = findobj(readyFigH,'Type','axes');
    if length(ax1)>1
        ax1 = ax1(1);
    end
    actualimgDims = [diff(ax1.YLim),diff(ax1.XLim)];
end
scaleBarLength = scaleBarSize/pixelSize;


imgDims = actualimgDims;
mismatch_bool = false;
if any(expectedimgDims-actualimgDims)
    mismatch_bool = true;
    wrntitle = 'Image Dimension Mismatch';
    wrntxt = sprintf(['Expected: ',num2str(expectedimgDims),'\n'...
        'Actual: ',num2str(actualimgDims),'\n']);
    wH = warndlg(wrntxt, wrntitle);
    uiwait(wH);
    
    prompt={'image dimensions'};
    name='expected image dimensions';
    numlines=1;
	defaultanswer={num2str(actualimgDims)};
    pause(0.01);
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    expectedimgDims = str2num(answer{1});
    imgDims = expectedimgDims;
end


display(num2str(actualimgDims));
if vertBool
	scaleBarCoord = [sbarStart(1),sbarStart(2);sbarStart(1),sbarStart(2)];
    scaleBarCoord =scaleBarCoord.*repmat(imgDims,2,1)+[0,0;scaleBarLength,0];        
else
    scaleBarCoord = [sbarStart(1),sbarStart(2);sbarStart(1),sbarStart(2)];
    scaleBarCoord =scaleBarCoord.*repmat(imgDims,2,1)+[0,0;0,scaleBarLength];  
end

scaleBarCoord(:,1) = scaleBarCoord(:,1)+ax1.YLim(1);
scaleBarCoord(:,2) = scaleBarCoord(:,2)+ax1.XLim(1);

if ~useExistingFigBool
    figure;
    imgH_new = image(tempImg);
    imgH_new.Parent.CLim = [min(tempImg(:)),max(tempImg(:))];
    tmp_cmap = gray(single(diff(imgH_new.Parent.CLim)));
    colormap(tmp_cmap);
    imgH_new.CDataMapping = 'scaled';
    hold on
    imgAx = imgH_new.Parent;
else
    ax1 = findobj(readyFigH,'Type','axes');
    if length(ax1)>1
        ax1 = ax1(1);
    end
    imgAx = ax1;
end
scaleBarH = add_scale_bar(imgAx,scaleBarCoord,scaleBarColor);

if nargin > 7 && ~isempty(saveName)
    savFig = scaleBarH.Parent.Parent;
    saveas(savFig,[saveName,'.fig']);
    saveas(savFig,[saveName,'.pdf']);
    saveas(savFig,[saveName,'.tif']);
end
    


function scaleBarH = add_scale_bar(imgAxHandle,scaleBarLoc,scaleBarColor)
axes(imgAxHandle);
scaleBarH = line(scaleBarLoc(:,2),scaleBarLoc(:,1));
scaleBarH.LineWidth = 4;
scaleBarH.Color = scaleBarColor;

