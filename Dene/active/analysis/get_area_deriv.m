function new_avrgs = get_area_deriv(seq,data)

if nargin ==0
    load analysis
end

area_derivs = deriv(data.cells.area);

new_avrgs.area_deriv_mean = nan(1,length(seq.frames));
new_avrgs.area_deriv_sum = nan(1,length(seq.frames));


for i= 1:length(seq.frames)
    seq.frames(i).cells  = nonzeros(seq.cells_map(i,data.cells.selected(i,:)));
    takers = seq.cells_map(i,data.cells.selected(i,:))~=0;
    withzeros = seq.cells_map(i,data.cells.selected(i,:));
    derivofareasofcells = area_derivs(i,data.cells.selected(i,:));
    new_avrgs.area_deriv_mean(i) = mean(derivofareasofcells);
    new_avrgs.area_deriv_sum(i) = sum(derivofareasofcells);
    
end
 

save new_avrgs new_avrgs