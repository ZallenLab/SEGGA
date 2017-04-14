function make_dittoname_folder_for_images(indir)
start_dir = pwd;
cd(indir);
imgfiles = dir('*.tif');
imgfiles = {imgfiles(:).name};

cellfun(@makedirandmoveto,imgfiles);
cd(start_dir);

function makedirandmoveto(imgname)
    imgname_noext = strtok(imgname,'\.');
    new_img_dir = [pwd,filesep,imgname_noext];
    mkdir(new_img_dir);
    movefile([pwd,filesep,imgname],[new_img_dir,filesep,imgname]);
end
    
    
end
    
    