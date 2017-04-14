function setuicolors
  declareglobs
  
  if ~isempty(guihandle)
    if isempty(procstate)
      procstate = procstates.NONE;
    end
    GRAY = [0.5 0.5 0.5];
    GREEN = [0 0.5 0];
    BLACK = [0 0 0];
    


    % Stateful buttons and menues
    blists(procstates.NONE).l = {'new_case_button'};
    blists(procstates.LOADED).l = {'makeedges'};
    blists(procstates.EDGES).l = {'movenodes','addedge','unite_cells', 'edge_to_node', 'node2cell', 'node2egde_btn'};
    blists(procstates.CELLS).l = {'analyzesel', 'undo'};
    blists(procstates.ANALYZED).l = {'highlight'};
    
    mlists(procstates.HIGHLIGHT).l = {'fig_win_menu'};
    mlists(procstates.NONE).l = {'new_menu', 'open_menu'};
    mlists(procstates.LOADED).l = {'make_edges_menu', 'save_menu', ...
        'save_as_menu', 'close_case_menu', 'limit_area_menu', ...
        'show_area_menu','preprocess_menu'};
    mlists(procstates.CIRCLES).l = {'redraw_circles_menu'};
    mlists(procstates.EDGES).l = {'move_nodes_menu','add_edge_menu', ...
        'redraw_cells_menu', ...
        'unite_cells_menu', 'edge2node_menu', 'node2cell_menu',...
        'angles_menu', 'node2edge_menu'};
    mlists(procstates.CELLS).l = {'anal_sel_menu','select_all_menu', ...
        'poly_select_menu','click_select_menu', 'clear_sel_menu', 'undo_menu'};
    mlists(procstates.ANALYZED).l = {'highlight_menu', 'corr_menu'};

    for I=length(blists):-1:1
      if procstate > I
    	setbuttons(guihandle,blists(I).l,BLACK,BLACK,'normal', 'normal');
        enablebuttons(guihandle,blists(I).l,'on');
        enablebuttons(guihandle,mlists(I).l,'on');
      elseif procstate == I
        setbuttons(guihandle,blists(I).l,GREEN,BLACK,'bold', 'normal');
        enablebuttons(guihandle,blists(I).l,'on');
        enablebuttons(guihandle,mlists(I).l,'on');
      else
    	setbuttons(guihandle,blists(I).l,BLACK,BLACK,'normal', 'normal');
        enablebuttons(guihandle,blists(I).l,'off');
        enablebuttons(guihandle,mlists(I).l,'off');
      end
    end
  end
    % Save button
    if changed
        set(guihandle.save_menu, 'Enable', 'on');
    else
        set(guihandle.save_menu, 'Enable', 'off');
    end

  
function setbuttons(h,list,c1,c2,attr1, attr2)
  if ~isempty(list)
    set(getfield(h,char(list(1))),'ForegroundColor',c1)
    set(getfield(h,char(list(1))),'FontWeight',attr1)
    for I=2:length(list)
      set(getfield(h,char(list(I))),'ForegroundColor',c2)
      set(getfield(h,char(list(I))),'FontWeight',attr2)
    end
  end
  
function enablebuttons(h,list, attr)
  if ~isempty(list)
      for I=1:length(list)
        set(getfield(h,char(list(I))),'Enable', attr)
      end
  end

