function update_rotation_interface(rotHandles)

alpha = getappdata(rotHandles.figure1,'rot_ang');
if isempty(alpha)
    display('missing alpha value in update_rotation_interface, setting to zero');
    alpha = 0;
end
set(rotHandles.rot_slider,'value',alpha);

z = max(getappdata(rotHandles.figure1,'z'),1);
set(rotHandles.z_slider,'value',z);

img_stack = getappdata(rotHandles.figure1,'img');
img_pre = img_stack(:,:,round(z));

img_post = imrotate(img_pre, -alpha, 'bicubic');

imagesc(rotHandles.axes1,img_pre);
axes(rotHandles.axes1);
axis off
colormap('gray');

imagesc(rotHandles.axes3,img_post);
axes(rotHandles.axes3);
axis off
colormap('gray');

