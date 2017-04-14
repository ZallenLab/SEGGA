function n_values_script_many_dirs(all_dirs_separated,saveName)


% all_dirs_separated = {all_dirs_separated{1:3}};
edgeNValMins = nan(numel([all_dirs_separated{:}]),1);
edgeNValMaxs = edgeNValMins;
edgeNValMeans = edgeNValMins;
nvalsDVtoAP = edgeNValMins;
nvalsAPtoDV =edgeNValMins;
nvalsROI20 = edgeNValMins;
nvalsRel95 = edgeNValMins;
edgeShrinkNVal = edgeNValMins;
edgeGrowNVal = edgeNValMins;

rotate_nums_bool = false;
shrink_grow_bool = true;

flatNames = {};
movieNum = 0;
for typeInd = length(all_dirs_separated):-1:1
    dirlist = all_dirs_separated{typeInd};
    for movInd = 1:numel(dirlist)
        movieNum = movieNum+1;
        currdir = dirlist{movInd};
        flatNames = {flatNames{:},currdir};
        cd(currdir);
        display(pwd);
        if isempty(dir('analysis*'))
            display('---->>>> MISSING ANALYSIS');
        end
%         continue
%         analyze_dir_new;
%         compare_t1_and_ros_edge_velocity
%         continue
%         load('edges_info_cell_background','channel_info');
        load('analysis','data','seq');
        load timestep
        load shift_info
        if rotate_nums_bool
            [numDVtoAP, numAPtoDV, roi20] = rotating_edge_analysis_v03();
            nvalsDVtoAP(movieNum) = numDVtoAP;
            nvalsAPtoDV(movieNum) = numAPtoDV;
            nvalsROI20(movieNum) = roi20;
            temp_str_DVtoAP = ['edge DVtoAP N: ',num2str(numDVtoAP)];
            temp_str_APtoDV = ['edge APtoDV N: ',num2str(numAPtoDV)];
            temp_str_ROI20 = ['edge ROI20 N: ',num2str(roi20)];
        end
        nEdges = sum(data.edges.selected,2);
        edgeNValMins(movieNum) = min(nEdges);
        edgeNValMaxs(movieNum) = max(nEdges);
        edgeNValMeans(movieNum) = mean(nEdges);
        
%         rel_win_start = max(1,-shift_info-60/timestep*5);
%         rel_win_end = min(length(seq.frames),-shift_info+60/timestep*10);
%         rel_frm_cnt = round((rel_win_end-rel_win_start)*.95);
%         num_rel = sum((sum(seq.edges_map(rel_win_start:rel_win_end,:)~=0,1)>=rel_frm_cnt)&...
%             sum(data.edges.selected(rel_win_start:rel_win_end,:))>rel_frm_cnt);
%         nvalsRel95(movieNum) = num_rel;
        
        nCells = sum(data.cells.selected,2);
        cellNValMins(movieNum) = min(nCells);
        cellNValMaxs(movieNum) = max(nCells);
        cellNValMeans(movieNum) = mean(nCells);
        
        load cells_for_t1_ros.mat
        topo_cellNValMeans(movieNum) = sum(cells);
        
        load shrinking_edges_info_new edges_global_ind edges_global_ind_growing
        edgeShrinkNVal(movieNum) = length(edges_global_ind);
        edgeGrowNVal(movieNum) = length(edges_global_ind_growing);
    end %for movInd = 1:
end %for typeInd = 1:

% return
newNames = cellfun(@(x) ['''',x,''''], flatNames,'UniformOutput',false);
newNames = cellfun(@(x) strrep(x,',','-'), newNames, 'UniformOutput',false);
A = vertcat(newNames,cellstr(num2str(edgeNValMins(:)))');
A = vertcat(A,cellstr(num2str(edgeNValMaxs(:)))');
A = vertcat(A,cellstr(num2str(edgeNValMeans(:)))');
A = vertcat(A,cellstr(num2str(cellNValMins(:)))');
A = vertcat(A,cellstr(num2str(cellNValMaxs(:)))');
A = vertcat(A,cellstr(num2str(cellNValMeans(:)))');
A = vertcat(A,cellstr(num2str(topo_cellNValMeans(:)))');
colTxt = {'dir','edge N (min)','edge N (max)','edge N (mean)',...
              'cell N (min)','cell N (max)','cell N (mean)',...
              'cell N (cell rearrangements)'};
if rotate_nums_bool
    A = vertcat(A,cellstr(num2str(nvalsDVtoAP(:)))');
    A = vertcat(A,cellstr(num2str(nvalsAPtoDV(:)))');
    A = vertcat(A,cellstr(num2str(nvalsROI20(:)))');
    %A = vertcat(A,cellstr(num2str(nvalsRel95(:)))');
    colTxt = {colTxt{:},'DV to AP','AP to DV',...
        'edges in ROI >=20 frames'};    
end

if shrink_grow_bool
    A = vertcat(A,cellstr(num2str(edgeShrinkNVal(:)))');
    A = vertcat(A,cellstr(num2str(edgeGrowNVal(:)))');
    colTxt = {colTxt{:},...
        'shrinking','growing'};
end
    
c = vertcat(colTxt,A');

% xlswrite(saveName,c)
fid = fopen(saveName, 'w') ;
for i = 1:size(c,1)
    fprintf(fid, '%s,', c{i,1:end-1}) ;
    fprintf(fid, '%s\n', c{i,end}) ;
end

fprintf(fid, 'means,') ;
means = {mean(edgeNValMins), mean(edgeNValMaxs), mean(edgeNValMeans),...
         mean(cellNValMins), mean(cellNValMaxs), mean(cellNValMeans),...
         mean(topo_cellNValMeans)};
if rotate_nums_bool     
    means = {means{:}, mean(nvalsDVtoAP), mean(nvalsAPtoDV),...
             mean(nvalsROI20)};
end

if shrink_grow_bool
    means = {means{:}, mean(edgeShrinkNVal), mean(edgeGrowNVal)};
end


means = cellfun(@num2str,means, 'UniformOutput',false);
for i = 1:numel(means)
    fprintf(fid, '%s,', means{i});
end
fprintf(fid, '\n');


fclose(fid);
