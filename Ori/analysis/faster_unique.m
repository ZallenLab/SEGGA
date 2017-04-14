function u = faster_unique(a, max_val)
t = false(1, max_val);
t(a) = true;
u = find(t);
