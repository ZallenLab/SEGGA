function choose_cmap_range_opts_dialog(calling_h)
    % sends p_opts back to calling handle
    

    d = dialog('Position',[300 300 250 150],'Name','Color Mapping Options');
    
    p_opts.type = 'Adaptive';
    p_opts.val = 0;
    p_opts.bounds = [];
    setappdata(d,'p_opts',p_opts);
    setappdata(d,'calling_h',calling_h);
    
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 60],...
           'String','Select a range style');
       
    style_popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 95 100 25],...
           'String',{'Adaptive';'User Defined'},...;'Hard Coded'
           'Callback',@style_popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 10 70 20],...
           'String','Submit',...
           'Callback',@submit_callback);
       
    % Wait for d to close before running to completion
    uiwait(d);  
   
       function style_popup_callback(popup,event)
           calling_h = getappdata(popup.Parent,'calling_h');
    
%             idx = popup.Value;
%             popup_items = popup.String;
%             choice = char(popup_items(idx,:));

            pol_cmap_opts.bounds = []; 
            % 'bounds' get's saved later and might be modified below depending 
            %  on the options selected

            contents = cellstr(get(popup,'String'));
            pol_cmap.type = contents{get(popup,'Value')};
            switch pol_cmap.type
                case 'Adaptive'
                    pol_cmap.val = 0;
                case 'User Defined'
                    pol_cmap.val = 1;
                    prompt = {'pol_min','pol_max'};
                    dlg_title = '(log2) polarity cmap limits input dialog';
                    num_lines = 1;
                    def = {'-1','1'};
                    pol_lim_uinput = inputdlg(prompt,dlg_title,num_lines,def);
                    display(pol_lim_uinput);

                    if isempty(pol_lim_uinput)
                        display('no input received, setting cmap bounds technique to default: Adaptive');
                        pol_cmap.type = 'Adaptive';
                        pol_cmap.val = 0;
                        return;
                    else
                        p_min = str2num(pol_lim_uinput{1});
                        p_max = str2num(pol_lim_uinput{2});
                        p_bounds = [p_min,p_max];
                        pol_cmap_opts.bounds = p_bounds;
                        %%% add this value to settings.
                    end
                case 'Hard Coded'
                    pol_cmap.val = 2;
                    %%% just using whatevers already in the code
                otherwise
                    display(['pol_cmap type unknown [',pol_cmap.type,']']);
                    return
            end


            pol_cmap_opts.type = pol_cmap.type;
            pol_cmap_opts.val = pol_cmap.val;
            setappdata(popup.Parent,'p_opts',pol_cmap_opts);
            setappdata(calling_h, 'p_opts', pol_cmap_opts);
%             p_opts = pol_cmap_opts;
          
          
       end
   
   function p_opts = submit_callback(btn,event)
       calling_h = getappdata(btn.Parent,'calling_h');
       p_opts = getappdata(btn.Parent,'p_opts');
       setappdata(calling_h, 'p_opts', p_opts);
       close(btn.Parent);
   end
end