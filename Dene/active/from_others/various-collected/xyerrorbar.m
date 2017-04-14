%   xyerrorbar.m
%   (c) Nils Sjoberg 07-09-2004 Sweden
%   xyerrorbar(x,y,errx,erry,s) plots the data in y vs x with errorbars for
%   both y and x-data. Variables errx and erry are arrays of length=length(x and y) containing the
%   error in each and every datapoint.
%   s contains drawing-options for the plot and the options are the same as in
%   the ordinary plot-command, however the errorbar is plotted in a very
%   nice red hue!
%
%   Here is an example 
%   >figure
%   >xyerrorbar([1:0.5:5],[sin([1:0.5:5])],[ones(10,1).*0.1],[ones(10,1).*0.2],'g+')
%   the result shold be a plot of sin(x) vs x with errorbars for both x and
%   sin(x) -data.

function []=xyerrorbar(x,y,errx,erry,s_color,xerrtick,yerrtick)
if length(x)~=length(y)
    disp('x and y must have the same number of elements')
    return
end



starthold = ishold(gca);

if ~starthold
    hold on
end

if nargin <6 || isempty(xerrtick) || isempty(yerrtick)
    hold on
    for k=1:length(x)
        l1=line([x(k)-errx(k) x(k)+errx(k)],[y(k) y(k)]);
        set(l1,'color',s_color);
        l2=line([x(k)-errx(k) x(k)-errx(k)],[y(k)-0.05*errx(k) y(k)+0.05*errx(k)]);
        set(l2,'color',s_color);
        l3=line([x(k)+errx(k) x(k)+errx(k)],[y(k)-0.05*errx(k) y(k)+0.05*errx(k)]);
        set(l3,'color',s_color);
        l4=line([x(k) x(k)],[y(k)-erry(k) y(k)+erry(k)]);
        set(l4,'color',s_color);
        l5=line([x(k)-0.05*errx(k) x(k)+0.05*errx(k)],[y(k)-erry(k) y(k)-erry(k)]);
        set(l5,'color',s_color);
        l6=line([x(k)-0.05*errx(k) x(k)+0.05*errx(k)],[y(k)+erry(k) y(k)+erry(k)]);
        set(l6,'color',s_color);
    end
else
        hold on
    for k=1:length(x)
        l1=line([x(k)-errx(k) x(k)+errx(k)],[y(k) y(k)]);
        set(l1,'color',s_color);
        l2=line([x(k)-errx(k) x(k)-errx(k)],[y(k)-xerrtick/2 y(k)+xerrtick/2]);
        set(l2,'color',s_color);
        l3=line([x(k)+errx(k) x(k)+errx(k)],[y(k)-xerrtick/2 y(k)+xerrtick/2]);
        set(l3,'color',s_color);
        l4=line([x(k) x(k)],[y(k)-erry(k) y(k)+erry(k)]);
        set(l4,'color',s_color);
        l5=line([x(k)-xerrtick/2 x(k)+xerrtick/2],[y(k)-erry(k) y(k)-erry(k)]);
        set(l5,'color',s_color);
        l6=line([x(k)-xerrtick/2 x(k)+xerrtick/2],[y(k)+erry(k) y(k)+erry(k)]);
        set(l6,'color',s_color);
    end
end

if ~starthold
    hold off
end



