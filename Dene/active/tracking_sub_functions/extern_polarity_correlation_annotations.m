function seq = extern_polarity_correlation_annotations(handles,seq,orbit)


polarityfiletype = 0;
if ~isempty(dir('edges_info_cell_background*'))
    load edges_info_cell_background channel_info
    
    polarityfiletype = 1;
else if ~isempty(dir('edges_info_max_proj_single_given*'))
        load edges_info_max_proj_single_given channel_info 
        polarityfiletype = 2;
    else
        display('no polarity file found');
        return
    end
        
end
    
    

chan_txt_list = {channel_info(1).name};
if length(channel_info)>1
    for i = 2:length(channel_info)
        chan_txt_list = {chan_txt_list{:},channel_info(i).name};
    end
end

data = seq2data(seq);
num_frames = length(seq.frames);
cells = find(any(data.cells.selected));

if length(channel_info)~=2
    display('need exactly two channels for correlation analysis');
    return
end

switch polarityfiletype

    case 1 %movie type
        pol_cells_one = channel_info(1).cells.polarity;
        pol_cells_two = channel_info(2).cells.polarity;
        pol_cells_one = interp_pol(pol_cells_one);
        pol_cells_two = interp_pol(pol_cells_two);

    case 2 %still type
        pol_cells_one = channel_info(1).cells.polarity;
        pol_cells_two = channel_info(2).cells.polarity;
end

local_cells = nan(size(pol_cells_one));
for i = 1:num_frames
    local_cells(i,:) = seq.cells_map(i,cells(:));
end

load shift_info
load timestep
timetake = min(max(1,-shift_info)+ceil(60/timestep*5),length(seq.frames));
chanone_ref_val = mean(pol_cells_one(timetake,data.cells.selected(timetake,cells)));
chantwo_ref_val = mean(pol_cells_two(timetake,data.cells.selected(timetake,cells)));
    
combined_pol = (pol_cells_one./chanone_ref_val + pol_cells_two./chantwo_ref_val)/2;
combined_ref = (abs(chanone_ref_val)+abs(chantwo_ref_val))/2;

coef = corrcoef(pol_cells_one(timetake,data.cells.selected(timetake,cells)),...
pol_cells_two(timetake,data.cells.selected(timetake,cells)));
coef = coef(2);
coefsign = sign(coef);



for i = 1:num_frames
    pos_inds = find(local_cells(i,:));
    incrvals = [-20,-combined_ref:.05:combined_ref,20];
    specialcolormap = bipolar(length(incrvals), 0.1);
    
    
    pol_cells = combined_pol/combined_ref;
    tempcellpols = pol_cells(i, pos_inds);
    temp_pol_inds = ~isnan(tempcellpols);
    [n,bin] = histc(tempcellpols(temp_pol_inds),incrvals);
    bin(bin==0) = floor(length(incrvals)/2);
    
    
    tempcellpols_one = pol_cells_one(i, pos_inds);
    tempcellpols_two = pol_cells_two(i, pos_inds);
  
    corrterms = single_contributions_to_correlation(tempcellpols_one,tempcellpols_two);
    corrterms = corrterms*numel(corrterms);

    
    
    cell_passed_thru = pos_inds(temp_pol_inds);
    cell_did_not_pass = pos_inds(~temp_pol_inds);
    
    cellcolors = specialcolormap(bin,:);
    

    
        

    corrsigns = sign(corrterms);
    corrmods = log(abs(corrterms)+1).*corrsigns;
    tempcols = zeros(length(corrmods),3);
    tempcols(:,2) = min(max(-corrmods,0),1);
    tempcols(:,3) = min(max(corrmods,0),1);
    tempcolwhitened = zeros(length(corrmods),3);
    for col_ind = 1:length(corrmods)
        tempcolwhitened(col_ind,:) = interp1([0 1], [1 1 1; tempcols(col_ind,:)], min(max(abs(corrmods(col_ind)),0),1));
    end

    
    minalpha = 0.2;

    seq.frames(i).cells_colors(local_cells(i,cell_passed_thru), :) = tempcolwhitened;
    seq.frames(i).cells_colors(local_cells(i,cell_did_not_pass), :) = repmat([0.1 0.1 0.1],length(cell_did_not_pass),1);
    
    seq.frames(i).cells_alphas(local_cells(i,cell_passed_thru), :) = 0.5;
    seq.frames(i).cells_alphas(local_cells(i,cell_did_not_pass), :) = minalpha; 
    
    
        switch polarityfiletype
        
            case 1
                templocals = local_cells(i,cell_passed_thru);
                seq.frames(i).cells = templocals(data.cells.selected(i,cells(cell_passed_thru)));
            case 2
                passanddidnt = [cell_did_not_pass,cell_passed_thru];
                templocals = local_cells(i,passanddidnt);
                seq.frames(i).cells = templocals(data.cells.selected(i,cells(passanddidnt)));
        end
        
end


update_frame(handles);