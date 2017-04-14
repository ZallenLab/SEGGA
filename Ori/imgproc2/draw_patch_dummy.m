function draw_patch_dummy(h, method)
%This prevents having no patches at all (which can cause matlab to
%change the focus from the figure window to the command window). It
%also makes the playback of images with no highlighted cells as slow as
%playback of images with highlighted cells.

%matlab has some issues when the number of (transparent) patches changes from
%nonzero to zero. In order to prevent that we draw an almost invisible
%patch in the background. In order not to hinder performance, the dummy 
%patch should not be transparent when not drawing transparent
%patches.

patch_dummy = getappdata(h, 'patch_dummy');
delete(patch_dummy(ishandle(patch_dummy)));
if strcmp(method, 'solid')
patch_dummy = patch(1, 1, [1 1 1], 'FaceAlpha', 1, 'EdgeColor', 'none');
        setappdata(h, 'patch_dummy', patch_dummy);   
else
patch_dummy = patch(1, 1, [1 1 1], 'FaceAlpha', 0.01, 'EdgeColor', 'none');
        setappdata(h, 'patch_dummy', patch_dummy);
end
setappdata(h, 'patch_dummy', patch_dummy);


