function write_to_csv_custom(datalist,savename)




fid = fopen(savename, 'w');
% fwrite(fid,[fnums(:),...
%         tnums(:),utnums(:)]);
% fclose('fid');



for i=1:(size(datalist,1))
    
    for j = 1:length(datalist(i,:))
    
        element_to_write = datalist{i,j};
        
        if ~ischar(element_to_write)
            element_to_write = num2str(element_to_write);
        end
        
        fprintf(fid,element_to_write);
        
        if j<length(datalist(i,:))
            fprintf(fid,', ');
        end
        
    end
        fprintf(fid,'\n');
end

fclose('all');

