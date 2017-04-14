function [xx yy xy] = inertia_tensor_discrete(x, y)
mx = mean(x);
my = mean(y);
xx = mean((x - mx).^2);
yy = mean((y - my).^2);
xy = mean((y-my).*(x-mx));

