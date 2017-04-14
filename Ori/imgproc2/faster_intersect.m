function o = faster_intersect(a, b, max_val)
ta = false(1, max_val);
tb = false(1, max_val);
ta(a) = true;
tb(b) = true;
o = find(ta & tb);