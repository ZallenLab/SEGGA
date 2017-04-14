function [nghbrs l_nghbrs] = get_cell_nghbrs_global(seq, cell, frame_num)
l_cell = seq.cells_map(frame_num, cell);
l_nghbrs = get_cell_nghbrs(seq.frames(frame_num).cellgeom, l_cell);
nghbrs = seq.inv_cells_map(frame_num, l_nghbrs);