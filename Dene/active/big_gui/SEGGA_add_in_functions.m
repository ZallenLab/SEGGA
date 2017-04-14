function SEGGA_add_in_functions()

action_bool = false;

if action_bool
    try
        movenodes
        call_collapse_edge
        merge_cells
        addedge
        associate_node
        node2edge
        hole2cell
        remove_cell
        delineate_cell
        classifytrack
        calc_int_ang_squareness
    catch
        display('could not finish running all functions in SEGGA_add_in_functions');
    end
end