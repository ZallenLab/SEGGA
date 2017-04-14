function img = read_tif_fast(filename,cast_type)
%%% ---------------------------------------------
%%% Reads a tif stack, i.e. a 3D tif image, 'filename'.
%%% Best if cast_type matches the data in filename.
%%% Uses existing class if cast_type is not given as input.
%%%
%%% If cast_type does not match, then function will try to force it 
%%% by normalizing to [0,1] (single), then converting to 'type_cast'.
%%%
%%% Output is a matlab matrix of cast 'cast_type'.
%%% This function should be faster at loading tifs than imageJ
%%% when it does not need to recast the image in a new data type.

%%% settings
get_original_class_direct_bool = false; %(if false use file info - faster)
%%% getting the class by reading the file adds on about 0.05 seconds per
%%% file

%%% default
if (nargin <1) || isempty(filename)
    alltifs = dir(['*','.tif']);
    if isempty(alltifs);
        alltifs = dir(['*','.TIF']);
    end
    if isempty(alltifs);
        display('filename not provided and not tifs in current directory');
        return
    end
    filename = alltifs(1).name;
end

%%% get info
FileTif=filename;
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);

%%% Get existing class information from the 'imfinfo' function
if ~get_original_class_direct_bool
    if isfield(InfoImage(1),'SampleFormat')
        unsigned_bool = strcmp(InfoImage(1).SampleFormat,'Unsigned integer');
        bitdepth = InfoImage(1).BitDepth;
        class_from_info = ['int',num2str(bitdepth)];
        if unsigned_bool
            class_from_info = ['u',class_from_info];
        end
%         display(['class_from_info: ',class_from_info]);
        original_cast_type = class_from_info;
    else
        get_original_class_direct_bool = true;        
    end
end

%%% Use existing cast if cast_type is not given as input
if nargin < 2
    cast_missing = true;
else
    cast_missing = false;
    desired_cast_type = cast_type;
end

%%% Get existing class information by reading it directly
if get_original_class_direct_bool
    TifLink = Tiff(FileTif, 'r');
    TifLink.setDirectory(1);
    tmp=TifLink.read();
    original_cast_type = class(tmp);
    TifLink.close();
end


if cast_missing
    desired_cast_type = original_cast_type;
    cast_matches = true;
else
    cast_matches = strcmp(desired_cast_type,original_cast_type);
    if ~cast_matches
        display(['warning: ''cast_type'' (',cast_type, ...
            ') does not match the original class, (',original_cast_type,')']);
        display(['of ',filename]);
    end
end



TifLink = Tiff(FileTif, 'r');
TifLink.setDirectory(1);
tmp=TifLink.read();
FinalImage=zeros(nImage,mImage,NumberImages,original_cast_type);
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();
img = FinalImage;

if ~cast_matches
    img_recast = cast(FinalImage,'single');
    %%% for discrete classes rescale dynamic range by the class
    eval(['maxnum = ',desired_cast_type,'(inf)']);
    eval(['minnum = ',desired_cast_type,'(-inf)']);
    
    %%% for double and single classes just use exisiting dynamic range
    if strcmp(desired_cast_type,'double') || strcmp(desired_cast_type,'single')
        maxnum = max(img(:));
        minnum = min(img(:));
    end
    
    %%% Normalize to [0,1] -> to [minnum,maxnum];
    diff = single(maxnum)-single(minnum);
    img_recast = (img_recast-min(img_recast(:)))./(max(img_recast(:))-min(img_recast(:)))*diff + single(minnum);
    
    %%% Cast as desired cast
    img_recast =cast(img_recast,desired_cast_type);
    img = img_recast;
end
