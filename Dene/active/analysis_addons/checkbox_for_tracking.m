
function h = checkbox_for_tracking(chan_txt_list)

    width_val = 200;
    start_left = 10;

    width_val = max(length(chan_txt_list)*80,width_val);

    % [left, bottom, width, height]

    % Create figure
    h.f = figure('units','pixels','position',[200,200,width_val,50],...
                 'toolbar','none','menu','none');

    set(gcf,'name','Channels Select','numbertitle','off'); 

     for i = 1:length(chan_txt_list)
        % Create yes/no checkboxes
        h.c(i) = uicontrol('style','checkbox','units','pixels',...
                        'position',[start_left+(i-1)*80,30,50,15],...
                        'string',chan_txt_list{i},...
                        'callback',@generic_chckbox_callback);
     end

    % Create OK pushbutton   
    h.p1 = uicontrol('style','pushbutton','units','pixels',...
                    'position',[10,5,50,20],'string','OK',...
                    'callback',@p_call_okayed);

                % Create OK pushbutton   
    h.p2 = uicontrol('style','pushbutton','units','pixels',...
                    'position',[90,5,40,20],'string','Cancel',...
                    'callback',@p_call_close);
                
    function generic_chckbox_callback(chckbox_h, event)
        %%% Automatically Avoid User Selecting Multiple Channels
        if  chckbox_h.Value
           for j = 1:length(h.c)
               h.c(j).Value = false;
           end
           chckbox_h.Value = true;
       end
    end
        


    function p_call_okayed(varargin)
            vals = get(h.c,'Value');
            if ~iscell(vals)
                vals = {vals(:)};
            end
            checked = find([vals{:}]);
            if isempty(checked)
                checked = 'none';
            end

            h.checked = checked;
    %         close(h.f);
            global channel_handle
            channel_handle = h;
            close(h.f);


    end



    function p_call_close(varargin)

        close(h.f);
    end

end