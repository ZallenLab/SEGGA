function [struct_out, ind_out] = ratchet_structure_special(struct_in,ind_in,var_val_in,var_name_in,descrptn_in)

    
ind_out = ind_in + 1;
struct_out = struct_in;
struct_out(ind_out).name = var_name_in;
struct_out(ind_out).val = var_val_in;
struct_out(ind_out).description = descrptn_in;
