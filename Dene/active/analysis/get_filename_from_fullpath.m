function [justfile justdirpath] = get_filename_from_fullpath(startfile)

                % startfile = channel_info(chan_num).filename;
%             [z_num, t_num, t_ind] = get_file_nums_dlf(startfile)


%             [strone, strtwo] = strtok(startfile,filesep);
%             while ~isempty(strtwo)
%                 [strone, strtwo] = strtok(strtwo,filesep);
%             end
%             
%             justfile = strone;
            
            reversestr = fliplr(startfile);
            [justfile, justdirpath] = strtok(reversestr,filesep);
            justfile = fliplr(justfile);
            justdirpath = fliplr(justdirpath);
            
            
            