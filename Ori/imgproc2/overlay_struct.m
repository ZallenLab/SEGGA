function targ = overlay_struct(targ, src)
f = fieldnames(src);
for i = 1:length(f)
    if ~isstruct(src.(f{i})) || ~isfield(targ, f{i})
        targ.(f{i}) = src.(f{i});
    else 
        targ.(f{i}) = overlay_struct(targ.(f{i}), src.(f{i}));
    end
end
