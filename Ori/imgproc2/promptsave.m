declareglobs
if changed
  resp = questdlg('There are unsaved changes. Save changes?','There are unsaved changes','Yes','No','Yes');
  if isequal(resp,'Yes')
    savecase;
  end
end
