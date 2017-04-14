function success = change_seg_file_names_to_match_img(indir)


success = false;
if nargin ==0 || isempty(indir)
    indir = pwd;
    qstring = 'rename files in current dir';
    titlenow = 'proceed request';
    button = questdlg(qstring,titlenow,'yes','no','yes');
    
    switch button
    case 'yes'
        display('continuing');
    case 'no'
        display('stopping')
        return
    end
end

filenamesimgs = dir('*.tif');
filenamessegs = dir('*.mat');

if isempty(filenamesimgs)
    display('no img files found, trying ''TIF''');
    filenamesimgs =  dir('*.TIF');
end

if isempty(filenamesimgs)
    display('no img files found, trying ''TIFF''');
       filenamesimgs = dir('*.TIFF');
end

if isempty(filenamesimgs)
    display('no img files found, trying ''tiff''');
	filenames = dir('*.tiff');
end

if isempty(filenamesimgs)
    display('no tif files found in this dir');
    display('cannot run function');
    return
end

if isempty(filenamessegs)
    display('no tif files found in this dir');
    display('cannot run function');
    return
end

check_tiff_match_mat = false;
if length(filenamessegs)~=length(filenamesimgs)
    display('total number of seg files do not match up to img files');
    display('checking if scanning for ''t'' fixes mismatch');
    check_tiff_match_mat = true;
end





filenamessegs_as_cell = {filenamessegs(:).name};


seg_lookforT = [strfind(filenamessegs_as_cell, '_T')];
for i = 1:length(seg_lookforT)
    seg_lookforT{i} = ~isempty(seg_lookforT{i});
end
seg_lookforT = logical([seg_lookforT{:}]);
filenamessegs = vertcat(filenamessegs(seg_lookforT).name);
original_filenamessegs = filenamessegs;


filenamesimgs_as_cell = {filenamesimgs(:).name};
filenamesimgs = vertcat(filenamesimgs(:).name);
original_filenamesimgs = filenamesimgs;


seg_c_ind = [strfind(filenamessegs_as_cell, '_T')];
if any(size(seg_c_ind) ~= size(filenamessegs_as_cell))
    msg = ['For seg (mat) files: File name format error. Could not find ''_T'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
seg_c_ind = [seg_c_ind{:}];


img_c_ind = [strfind(filenamesimgs_as_cell, '_T')];
if any(size(img_c_ind) ~= size(filenamesimgs_as_cell))
    msg = ['For img (tiff) files: File name format error. Could not find ''_T'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
img_c_ind = [img_c_ind{:}];



if check_tiff_match_mat
    display(['number of mat files: ',num2str(length(original_filenamessegs))]);
	display(['number of tiff files: ',num2str(length(original_filenamesimgs))]);
    display(['number of mat files with ''_T'' in it: ',num2str(length(seg_c_ind))]);
    display(['number of tiff files with ''_T'' in it: ',num2str(length(img_c_ind))]);
end



if length(seg_c_ind) == length(img_c_ind)
    display('(for t search) number of seg and img files agree, continuing');
else
    display('(for t search) number of seg and img files do not agree, stopping');
    return
end


imgs_t_nums = vertcat(original_filenamesimgs(:,(img_c_ind+2):(img_c_ind+5)));
segs_t_nums = vertcat(original_filenamessegs(:,(seg_c_ind+2):(seg_c_ind+5)));


all_tnums_match = logical(all(all(imgs_t_nums == segs_t_nums)));


% all t numbers should match
if all_tnums_match
    display('all ''_T...'' numbers match up, continuing');
else
    display('all ''_T...'' numbers do not match up, stopping');
    return
end




% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

seg_d_ind = [strfind(filenamessegs_as_cell, '_Z')];
if any(size(seg_d_ind) ~= size(filenamessegs_as_cell))
    msg = ['For seg (mat) files: File name format error. Could not find ''_Z'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
seg_d_ind = [seg_d_ind{:}];


img_d_ind = [strfind(filenamesimgs_as_cell, '_Z')];
if any(size(img_d_ind) ~= size(filenamesimgs_as_cell))
    msg = ['For img (tiff) files: File name format error. Could not find ''_Z'' in file name ' ...
        'and assign a frame number'];
    msgboxH = msgbox(msg, 'Bad file name', 'error', 'modal');
    waitfor(msgboxH);
    return
end
img_d_ind = [img_d_ind{:}];



if check_tiff_match_mat
    display(['number of mat files: ',num2str(length(original_filenamessegs))]);
	display(['number of tiff files: ',num2str(length(original_filenamesimgs))]);
    display(['number of mat files with ''_Z'' in it: ',num2str(length(seg_d_ind))]);
    display(['number of tiff files with ''_Z'' in it: ',num2str(length(img_d_ind))]);
end



if length(seg_d_ind) == length(img_d_ind)
    display('(for z search) number of seg and img files agree, continuing');
else
    display('(for z search) number of seg and img files do not agree, stopping');
    return
end


imgs_z_nums = vertcat(original_filenamesimgs(:,(img_d_ind+2):(img_d_ind+5)));
segs_z_nums = vertcat(original_filenamessegs(:,(seg_d_ind+2):(seg_d_ind+5)));


all_znums_match = logical(all(all(imgs_z_nums == segs_z_nums)));


if all_znums_match
    display('all ''_Z...'' numbers match up, there is nothing to do, stopping');
        return
else
    display('all ''_Z...'' numbers do not match up, continuing to rewrite mats from tiffs');
end

filenamessegs(:,(img_d_ind+2):(img_d_ind+5)) = filenamesimgs(:,(img_d_ind+2):(img_d_ind+5));

% % % % % % % % % % % % % % % % % % % % % % % % 
% change the data within the filenames
display('changing filename mapping within data in ''mat'' files');
for i = 1:length(filenamessegs)
    load(original_filenamessegs(i,:));
    filenames = {filenamesimgs_as_cell{i}};
    casename = filenamessegs(i,:);
    save(filenamessegs_as_cell{i},'filenames','casename','-append')
end


if ~isempty(dir('change_these_filenames.m'))
    display('file for renaming already created, check ''change_these_filenames'', possibly delete.');
    return
end

% % % % % % % % % % % % % % % % % % % % % % % %
% actually change the filenames
filenamessegs(:,(img_d_ind+2):(img_d_ind+5)) = filenamesimgs(:,(img_d_ind+2):(img_d_ind+5));

fid = fopen('change_these_filenames.m','w');
fprintf(fid, '%% ! sudo chmod 777 -R %s \n', indir);
    
for i = 1:length(filenamessegs)
    fprintf(fid, '!mv %s ', [indir,filesep,original_filenamessegs(i,:)]);
    fprintf(fid, '%s \n', [indir,filesep,filenamessegs(i,:)]);
    
%     eval(['save(''',original_filenamessegs(i,:),''',','''
end



fclose(fid);
display('all data collected changing filenames');

rehash path;
change_these_filenames;

z_for_t_out = create_z_shift_from_files('mat', false);

basefilename = filenamessegs(1,1:(img_c_ind(1)-1));
save('basefilename','basefilename');


success = true;


