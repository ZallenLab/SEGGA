function fix_flip_image_dirs(dir_list)

cellfun(@flipimage,dir_list)

function flipimage(dir)
    cd(dir)
    fliplr_img_dir;
end

end

