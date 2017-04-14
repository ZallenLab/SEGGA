function img_out = convert_img_to_uint8(img_in)
img_out = cast(img_in,'single');
img_out = (img_out-min(img_out(:)))/(max(img_out(:))-min(img_out(:)))*256;
img_out =cast(img_out,'uint8');