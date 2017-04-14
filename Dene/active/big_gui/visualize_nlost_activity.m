function [temp_H] = visualize_nlost_activity(axH,eventsInput,fnum,time_cmap,use_with_tracking_bool)

temp_H = [];

if nargin<1 || isempty(axH)
    figure;
    axH = axes();
end
axes(axH);
hold on;

if nargin<2 || isempty(eventsInput)
    display('missing event info');
    return
end

if nargin <3 || isempty(fnum)
	display('missing frame number');
    return
end

if nargin <4 || isempty(time_cmap)
    use_default_tcmap = true;
else
    use_default_tcmap = false;
end

if nargin <4 || isempty(use_with_tracking_bool)
    use_with_tracking_bool = false;
end
use_with_tracking_bool = true;

%%%display the current events
lookbackWin = 7;
start_rad = 500;
end_rad = 50;
rad_incr = (start_rad-end_rad)/4;
allEvents = vertcat(eventsInput{:});
maxEvSize = max(allEvents(:,3));
allPastEvents = allEvents(allEvents(:,4)<=fnum,:);
numcols = max(allEvents(:,4))-min(allEvents(:,4))+1;
startcols = [0 0 1; 1 0 1; 1 0 0];
% cmapList = jet(numcols);
if numcols ~= size(startcols, 1)
    xi = linspace(1, size(startcols, 1), numcols);
    cm = interp1(startcols, xi);
end
cmapList = min(max(cm,0),1);

if use_with_tracking_bool
    takers = (allEvents(:,4)<=fnum)&(allEvents(:,4)>=fnum-lookbackWin);
    allPastEvents = allEvents(takers,:);
else
    axH.XLim = [0,672];
    axH.YLim = [0,512];
end


if ~isempty(allPastEvents)        
    x = allPastEvents(:,2);
    y = allPastEvents(:,1);
%     sizeVals = ((maxEvSize+1)-maxEvSize./allPastEvents(:,3)).*end_rad;
    sizeVals = repmat(end_rad,size(allPastEvents,1),1);
    allCols = cmapList(allPastEvents(:,4)-min(allEvents(:,4))+1,:);
    temp_H = [temp_H, scatter(x,y,sizeVals,allCols,'filled')];
end


    
%%%display the recent events
% return
lbCount = lookbackWin+1;
for fInd = fnum:-1:max(1,fnum-lookbackWin)
    rec_events = eventsInput{fInd};
    if (fInd==fnum) || isempty(rec_events)
        lbCount = lbCount-1;
        continue
    end

    big_rad = start_rad-(lbCount/(lookbackWin+1))*(start_rad-end_rad);
    for i = 1:size(rec_events,1)
        tCol0 =cmapList(rec_events(i,4)-min(allEvents(:,4))+1,:);
        weight1 = 1-(lbCount/(lookbackWin+1));
        weight2 = weight1/3;
        %whiten with time
        tCol1 = min(1,tCol0.*(1-weight1)+[1,1,1].*weight1);
        tCol2 = min(1,tCol0.*(1-weight2)+[1,1,1].*weight2);
        x = rec_events(i,2);
        y = rec_events(i,1);
        temp_H = [temp_H, scatter(x,y,max((big_rad-2*rad_incr),1),tCol2)]; 
        temp_H = [temp_H, scatter(x,y,big_rad+rad_incr,tCol1)];
    end
    lbCount = lbCount-1;
end
    
%%%DEBUG

return

load('time_localized_events_per_cell','edgeBased_activityData');
figure;
axH = axes();
for i = 1:length(edgeBased_activityData)
    if any(ishandle(tempH))
        delete(tempH);
    end
    [perm_H,temp_H] = visualize_nlost_activity(axH,edgeBased_activityData,i);
end
    
 