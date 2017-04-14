function fix_figure_boundaries_for_export(h)

if nargin<1 || isempty(h)
    h = gcf;
end

if ~verLessThan('matlab', '9.0') %% 2016a or more recent
    set(gcf,'PaperUnits','normalized');
    startPP = get(h,'PaperPosition');
%         newPP = [max(0,startPP(1)),max(0,startPP(2)),min(1,startPP(3)),min(1,startPP(4))];
    newPP = [max(0,startPP(1)),0.2,min(1,startPP(3)),0.6];
    set(h,'PaperPosition',newPP);
end