function addon_topo_measurements(indir)
    if nargin <1 || isempty(indir)
        indir = pwd;
    end
    startdir = pwd;
    cd(indir);
        %node_mult_hist_passive_3D shows [dims: frame,cells,node multiplicity] how many
        %times a cell was actively OR passively involved in a cluster of a given
        %multiplicity, keeping the time dimension
    if ~isempty(dir('topological_events_per_cell_extras.mat'))
        load('topological_events_per_cell_extras');
        num_cells = size(node_mult_hist_3D,2);
        nodemult_allros_active_oneplus = sum(sum(node_mult_hist_3D(:,:,5:end),3)>0,2)/num_cells;
        nodemult_allros_passive_oneplus = sum(sum(node_mult_hist_passive_included_3D(:,:,5:end),3)>0,2)/num_cells;
        nodemult_allros_active_twoplus = sum(sum(node_mult_hist_3D(:,:,5:end),3)>1,2)/num_cells;
        nodemult_allros_passive_twoplus = sum(sum(node_mult_hist_passive_included_3D(:,:,5:end),3)>1,2)/num_cells;
       
        save('topological_events_per_cell_extras','nodemult_allros_active_oneplus','nodemult_allros_passive_oneplus',...
            'nodemult_allros_active_twoplus','nodemult_allros_passive_twoplus','-append');
    else
        display('topological_events_per_cell_extras missing');
        cd(startdir);
        return
    end

    cd(startdir);