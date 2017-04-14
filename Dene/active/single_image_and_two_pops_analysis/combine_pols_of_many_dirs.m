function [outpols_pooled, hist_perc_list, binranges, outpols_means, nameFoldstotal, numcells] = combine_pols_of_many_dirs(base_dir_list,color)

outpols_pooled = [];
outpols_means = {};
nameFoldstotal = {};
numcells = {};
binranges = [-3.0:.25:3.0];
hist_perc_list = [];
nameFoldstotal = {};

for baseind = 1:length(base_dir_list)

    cd(base_dir_list{baseind});
    search_dir = pwd;
    d = dir(search_dir);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'}, 'legacy')) = [];
    nameFoldsToAdd = logical(ones(size(nameFolds)));   
    colornames = {'*red','*green','*blue'};

    for foldind = 1:length(nameFolds)
        startdir = pwd;
        cd(nameFolds{foldind});
        homedir = pwd;
%         add_on_analysis_fixed_polarity_image_second;


%             alldirsrun = dir(colornames{colorind});
%             actiondir = alldirsrun(i).name;
%             actiondir = 'red';
        actiondir = color;
        if isdir([pwd,filesep,color])
            cd(actiondir)
            display(pwd);
            temppols = get_pols_for_combining(pwd);
            if isempty(temppols)
                cd(startdir);
                nameFoldsToAdd(foldind) = false;
                continue
            end
            tempmean = mean(temppols(~isnan(temppols)));
%                     if strcmp(actiondir,'red')
%                         temppols = -temppols;
%                     end
            temp_hist = histc(temppols, binranges);
            temp_perc = temp_hist./sum(temp_hist);
                    
            hist_perc_list = [hist_perc_list,temp_perc'];
            outpols_pooled = [outpols_pooled(:);temppols(:)];
            outpols_means = [outpols_means(:);tempmean(:)];
            numcells = [numcells;length(temppols)];
            cd(homedir);
        else 
            nameFoldsToAdd(foldind) = false;
        end
        cd(startdir);
    end    
    nameFoldstotal = {nameFoldstotal{:},nameFolds{nameFoldsToAdd}};    
end


% for use for a quick hack to modify many dirs
function make_tracking_opts(channels_to_use)
        
        startdir = pwd;
        cd('seg');
        dest_name = [pwd,filesep,'tracking_options.txt'];
            
        fid = fopen(dest_name, 'w+');
        fseek(fid,0,'bof')
%             ftell(fid); 
        

        channel1txt = ['..',filesep,'blue',filesep,'convertedsize_blue_T0001_Z0001.tif'];
        channel2txt = ['..',filesep,'red',filesep,'convertedsize_red_T0001_Z0001.tif'];
        channel3txt = ['..',filesep,'green',filesep,'convertedsize_green_T0001_Z0001.tif'];
        channel3txtalt = ['..',filesep,'seg',filesep,'convertedsize_seg_T0001_Z0001.tif'];

        txt_to_add = ['channel1 = ''',channel1txt,'''',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        fprintf(fid,'\n');
        
        txt_to_add = ['channel2 = ''',channel2txt,'''',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        fprintf(fid,'\n');
        
        txt_to_add = ['channel3 = ''',channel3txtalt,'''',';'];
        fwrite(fid,txt_to_add);
        fprintf(fid,'\n');
        fprintf(fid,'\n');
        
        fclose(fid);
           

        cd(startdir);