function flag = are_times_overlapping(a1, b1, a2, b2, time_window)
%Are the intervals [a1,b1] and [a2, b2] less than time_window apart?
a1 = a1 - time_window/2;
a2 = a2 - time_window/2;
b1 = b1 + time_window/2;
b2 = b2 + time_window/2;
flag = ((b1 > a2) && (a1 < b2)) || ((b2 > a1) && (a2 < b1));
