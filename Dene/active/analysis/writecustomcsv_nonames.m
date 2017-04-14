function writecustomcsv_nonames(csvinfo,fullfilename)


fid = fopen(fullfilename, 'a');
fwrite(fid,['date and time of input',','],'char');
fwrite(fid,datestr(now),'char');
fprintf(fid,'\n');
dimsinfo = size(csvinfo);

    
for outputval_ind=1:dimsinfo(3)        
    for var_ind=1:dimsinfo(2)                        
        element_name_to_write = csvinfo(1,var_ind,outputval_ind).name;
        fwrite(fid,[element_name_to_write,':',','],'char');            
        for genotype_ind=1:dimsinfo(1)    
            % run the vals        
            % element_name_to_write = csvinfo(genotype_ind,var_ind,outputval_ind).name;
            element_val_to_write = csvinfo(genotype_ind,var_ind,outputval_ind).val;
            %%% Handle lists of numbers
            if ((length(element_val_to_write)>1)&&isnumeric(element_val_to_write))
                element_val_to_write = num2str(element_val_to_write);
            end
            fwrite(fid,[element_val_to_write,','],'char');        
            if isfield(csvinfo(genotype_ind,var_ind,outputval_ind),'description')
                element_val_to_write = csvinfo(genotype_ind,var_ind,outputval_ind).description;
                fwrite(fid,[element_val_to_write,','],'char');
            end        
        end
    end
    fprintf(fid,'\n');
end

fprintf(fid,'\n');
fclose('all');
end