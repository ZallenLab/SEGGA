function nngbr_cell_pols = calc_pols_from_nearest_neighbors(cell_pol,seq,data)

if length(seq.frames)>1
    cells = find(any(data.cells.selected));
else
    cells = find(data.cells.selected);
end

nngbr_cell_pols = nan(size(cell_pol));

% seq = getappdata(gcf,'seq');
% data = seq2data(seq);


% debug hardcode

for frameind = 1:length(seq.frames)

    selectedcells = find(data.cells.selected(frameind,:));
%     selectedcellsglobals = seq.cells_map(frameind,selectedcells);
    
    for cellind_glob = selectedcells
        
        currcellpol = cell_pol(frameind,cells == cellind_glob);
        cellindlocal = seq.cells_map(frameind,cellind_glob);
        
        if ~isempty(currcellpol)
            
        
    %         get the inds of cell-edge pairs for given cell
            edgesfacesind = ismember(seq.frames(frameind).cellgeom.edgecellmap(:,1),cellindlocal, 'legacy');
    %         get the edges touching given cell
            edgesfaces = seq.frames(frameind).cellgeom.edgecellmap(edgesfacesind,2);
    %         remove the nans fromt that list
            edgesfaces = edgesfaces(~isnan(edgesfaces));

    %         get all positions of cell-edge pairs for a list of edges
            cellstouchingind = ismember(seq.frames(frameind).cellgeom.edgecellmap(:,2),edgesfaces, 'legacy');
    %         get all cells for the list of previous pairs
            cellstouching = seq.frames(frameind).cellgeom.edgecellmap(cellstouchingind,1);
    %         keep only unique instances for each cell
            cellstouching = unique(cellstouching, 'legacy');


    %         include the cell itself in it's neighborhood
            tempnghbrs = nonzeros(cellstouching');
    %         display(num2str(tempnghbrs'));


            tempscells = ismember(cells,tempnghbrs, 'legacy');
            allngbr_polstemp = cell_pol(frameind,tempscells);
            allngbr_polstemp = allngbr_polstemp(~isnan(allngbr_polstemp));

    %         weightcenter = 2;
    if sum(tempscells)==0
            weightslist = 1;
    else
%             weightslist = [ones(1,length(allngbr_polstemp)),length(allngbr_polstemp)];
            weightslist = ones(1,length(allngbr_polstemp));
            weightslist  = weightslist./sum(weightslist);
    end

    %         add the center cell
%             allngbr_polstemp = [allngbr_polstemp,cell_pol(frameind,cells == cellind_glob)];

            tempcellindpos = cells == cellind_glob;
    %         nngbr_cell_pols(frameind,tempcellindpos) = mean(allpolstemp(~isnan(allpolstemp)));

            nngbr_cell_pols(frameind,tempcellindpos) = sum(weightslist.*allngbr_polstemp);
            
            if isnan(nngbr_cell_pols(frameind,tempcellindpos))
                display('nan alert');
            end
            
        else 
            
            nngbr_cell_pols(frameind,(cells == cellind_glob)) = nan;
        
        end
        
        
    end
    
end
    
    