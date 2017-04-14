function write_shift_info_txt_file(indir,savedir)

        startdir = pwd;
        cd(indir);
        load shift_info
        load timestep
        min_intrvals = -20:5:30;
        min_intrvals_frame_nums = ceil(60/timestep*(min_intrvals)) - shift_info;
        tzeroname = 'tzero.txt';
        dest_name = [pwd,filesep,tzeroname];
            
        fid = fopen(dest_name, 'w+');
        fseek(fid,0,'bof');
%             ftell(fid); 
        
        tzerotxt = [num2str(-shift_info)];
        timesteptxt = [num2str(timestep)];
        

        txt_to_add = ['t0 = ''',tzerotxt,'''',' (frame number)',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        
        txt_to_add = ['timestep = ''',timesteptxt,'''',' (secs per frame)',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        fprintf(fid,'\n');
        fprintf(fid,'\n');
        
        txt_to_add = ['frame times = ''',num2str(min_intrvals),'''',' (minutes)',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        
        txt_to_add = ['frame number for times listed above = ''',num2str(min_intrvals_frame_nums),'''',' (frame number)',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        
        txt_to_add = ['formula = ''','frame number = ceil(60/timestep*(time in minutes)) + t0',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        
        txt_to_add = ['dir = ''',indir,';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        fprintf(fid,'\n');
                
        fclose(fid);
           
        nlostdirs = dir([pwd,filesep,'..',filesep,'nlost*']);
        
        if ~isempty(nlostdirs)
            for i = 1:length(nlostdirs)
                sourcefile = dest_name;
                destfile = [pwd,filesep,'..',filesep,nlostdirs(i).name,filesep,tzeroname];
                copyfile(sourcefile,destfile);
            end
        end
        
        
        
%         annotationbase = [pwd,filesep,'..',filesep,'annotations',filesep];
%         annotationdirs = dir(annotationbase);
        
        if nargin >1
                sourcefile = dest_name;
                destfile = [savedir,filesep,tzeroname];
                copyfile(sourcefile,destfile);
        end


        
        
        cd(startdir);