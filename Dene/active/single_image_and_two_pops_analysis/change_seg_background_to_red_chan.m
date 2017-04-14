function success = change_seg_background_to_red_chan(indir,changebackbool)

success = false;
startdir = pwd;
cd(indir);

allmatfiles = dir('*mat');
allmatfiles = {allmatfiles(:).name};

for i = 1:length(allmatfiles)
    [znum, tnum] = check_file_is_seg(allmatfiles{i});
    if ~isempty(znum)
%         display(num2str(znum));

%         load(allmatfiles{i})

        if ~changebackbool
            digitlength_t = length(num2str(tnum));
            zerobuff_t = num2str(zeros(1,4-digitlength_t));
            tf = isspace(zerobuff_t);
            zerobuff_t = zerobuff_t(~tf);
            
            digitlength_z = length(num2str(znum));
            zerobuff_z = num2str(zeros(1,4-digitlength_z));
            tf = isspace(zerobuff_z);
            zerobuff_z = zerobuff_z(~tf);
            
            lastpart_filename = ['convertedsize_red_T',zerobuff_t,num2str(tnum),'_Z',zerobuff_z,num2str(znum),'.tif'];

            folderred = 'red';
            new_red_filename = {['..',filesep,folderred,filesep,lastpart_filename]};            
%             copyfile(lastpart_filename,[pwd,filesep,lastpart_filename]);
%             filenames = lastpart_filename;
            filenames = new_red_filename;
            if isempty(dir(filenames{1}))
                display(['file did not exist: ',filenames{1}]);
                return
            end
            save(allmatfiles{i},'filenames','-append');        
        else             
            digitlength_t = length(num2str(tnum));
            zerobuff_t = num2str(zeros(1,4-digitlength_t));
            tf = isspace(zerobuff_t);
            zerobuff_t = zerobuff_t(~tf);
            
            digitlength_z = length(num2str(znum));
            zerobuff_z = num2str(zeros(1,4-digitlength_z));
            tf = isspace(zerobuff_z);
            zerobuff_z = zerobuff_z(~tf);
            
            lastpart_filename = ['convertedsize_seg_T',zerobuff_t,num2str(tnum),'_Z',zerobuff_z,num2str(znum),'.tif'];
            new_seg_filename = {lastpart_filename};
            filenames = new_seg_filename;
            if isempty(dir(filenames{1}))
                display(['file did not exist: ',filenames{1}]);
                return
            end
            save(allmatfiles{i},'filenames','-append');
        end                       
    end
end
success = true;
