function save_custom_cbar(colormap_in,tickvals,ticklabels,savedir,...
                          savename,cbar_txt,alpha,ftypes)
                      
    if nargin < 8 || isempty(ftypes)
%       ftypes = {'tif','pdf','fig'};
        ftypes = {'tif'};
    end

   if (nargin < 7) || isempty(alpha)
       alpha = 0.5;
   end
   
   if nargin < 6 || isempty(cbar_txt)
       cbar_txt_bool = false;
   else
       cbar_txt_bool = true;
   end
   

   
   %make automatic colorbar
   h = figure;
   colormap(colormap_in);
   hcol = colorbar;
   axis off
   set(hcol,'YTick',tickvals,'YTickLabel',ticklabels);
   pos = [0.9,0.1,0.0357,0.8];
   set(hcol,'position',pos);
   
   %%%make txt, notes
   if cbar_txt_bool
       loc = pwd;
       loc = split_up_txt(loc);
       dtstring = datestr(datetime);
       txtIn = ['Color Bar generated on ',dtstring,'\n',...
           'At location ',loc,'\n',...
           'Notes: ',cbar_txt];
       ready_txt = sprintf(txtIn);
       txtH = text(0, 0.5, ready_txt, 'FontSize', 9,'interpreter','none');
   end
   
   %%% make color bar with transparency and background
    pos = [0.5,0.05,0.3,0.9];
	ax2 = axes('position',pos,'parent',h);
    image(((1:3)')','parent',ax2);
    colormap(ax2,gray(3));
    axis off;
    set(ax2,'XTickLabel',[]);
    set(ax2,'YTickLabel',[]);
   
    cm = flipud(colormap_in);
    m = size(cm,1);

    pos = [0.55,0.1,0.2,0.8];
    ax3 = axes('position',pos,'parent',h);
    contin_cbarH = image((1:m)','parent',ax3,'AlphaData',alpha);
    axes(ax3)
    axis off;
    set(ax3,'XTickLabel',[]);
    set(ax3,'YTickLabel',[]);
    colormap(ax3,cm);
       
       
   bname = [savedir,savename];
   if sum(savename=='.')>1
       saveas(gcf, bname);
   else
       for i = 1:length(ftypes)
            saveas(gcf, [bname '.',ftypes{i}]);
       end
   end
   close(gcf);
   
function txt_out = split_up_txt(txt_in)
split_thresh = 32;
txt_out = txt_in;
if numel(txt_in)>split_thresh
   numsplits = floor(numel(txt_in)/split_thresh);
   for i = 1:numsplits
       if length(txt_in)>i*split_thresh %%avoid confusion at the multiples of the splits
           splitloc = i*split_thresh + 5*(i-1);
           txt_out = [txt_out(1:splitloc),'...\n',txt_in((i*split_thresh+1):end)];
       end
   end
end