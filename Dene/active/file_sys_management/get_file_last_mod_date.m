function [last_mod_str, last_mod_num] = get_file_last_mod_date(queryfile)

last_mod_str = [];
import java.io.*;
import java.util.Date;
a=File(queryfile);
bool=a.exists();
if ~bool
    display('file does not exist');
    return
end

last_mod_num = a.lastModified();
b = Date(a.lastModified());

%%% Convert to string
dateFormatter = java.text.SimpleDateFormat('dd-MMM-yyyy HH:mm:ss');
dateString = char(dateFormatter.format(b));
last_mod_str = dateString;
