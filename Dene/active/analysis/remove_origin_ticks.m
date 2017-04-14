function remove_origin_ticks(input_axis)

if nargin <1 || isempty(input_axis)
    input_axis = gca;
end

fsize = get(gca,'fontsize');
fwght = get(gca,'fontweight');

tempxlim = get(gca,'xlim');
tempylim = get(gca,'ylim');

Q=get(input_axis,'xtick');
R=get(input_axis,'xticklabel');

if numel(Q) == 0
    display('no x ticks found');
    return
end

if Q(1) == tempxlim(1)
    set(input_axis,'xtick',Q(2:end));
    set(input_axis,'xticklabel',R(2:end,:));
    txt_h=text(tempxlim(1),tempylim(1),[R(1,:),' '],'fontsize',fsize,'fontweight',fwght);
  % Manually  include y label at first position
    set(txt_h,'horizontalAlignment','center','verticalAlignment','top');
end


S=get(input_axis,'ytick');
T=get(input_axis,'yticklabel');

if S(1) == tempylim(1)
    set(input_axis,'ytick',S(2:end));
    set(input_axis,'yticklabel',T(2:end,:));
    txt_h2=text(tempxlim(1),tempylim(1),[T(1,:),'  '],'fontsize',fsize,'fontweight',fwght);
  % Manually  include y label at first position
    set(txt_h2,'horizontalAlignment','right');
end




    
    
    



