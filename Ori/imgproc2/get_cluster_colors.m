function colors = get_cluster_colors(n)

%colors = palettes.clusters_colormap(mod((n*37 -1), length(palettes.clusters_colormap)) + 1 ,:);
hsv_colormap = get_hsv_pallete;
colors = hsv_colormap(mod((n)*19, length(hsv_colormap)) + 1 ,:);

function hsv_colormap = get_hsv_pallete
hsv_colormap = [...
    1 , 0 , 0; ...
    1 , 0.09375 , 0;...
    1 , 0.1875 , 0;...
    1 , 0.28125 , 0;...
    1 , 0.375 , 0;...
    1 , 0.46875 , 0;...
    1 , 0.5625 , 0;...
    1 , 0.65625 , 0;...
    1 , 0.75 , 0;...
    1 , 0.84375 , 0;...
    1 , 0.9375 , 0;...
    0.96875 , 1 , 0;...
    0.875 , 1 , 0;...
    0.78125 , 1 , 0;...
    0.6875 , 1 , 0;...
    0.59375 , 1 , 0;...
    0.5 , 1 , 0;...
    0.40625 , 1 , 0;...
    0.3125 , 1 , 0;...
    0.21875 , 1 , 0;...
    0.125 , 1 , 0;...
    0.03125 , 1 , 0;...
    0 , 1 , 0.0625;...
    0 , 1 , 0.15625;...
    0 , 1 , 0.71875;...
    0 , 1 , 0.25;...
    0 , 1 , 0.34375;...
    0 , 1 , 0.4375;...
    0 , 1 , 0.53125;...
    0 , 1 , 0.625;...
    0 , 1 , 0.8125;...
    0 , 1 , 0.90625;...
    0 , 1 , 1;...
    0 , 0.90625 , 1;...
    0 , 0.8125 , 1;...
    0 , 0.71875 , 1;...
    0 , 0.625 , 1;...
    0 , 0.53125 , 1;...
    0 , 0.4375 , 1;...
    0 , 0.34375 , 1;...
    0 , 0.25 , 1;...
    0 , 0.15625 , 1;...
    0 , 0.0625 , 1;...
    0.03125 , 0 , 1;...
    0.125 , 0 , 1;...
    0.21875 , 0 , 1;...
    0.3125 , 0 , 1;...
    0.40625 , 0 , 1;...
    0.5 , 0 , 1;...
    0.59375 , 0 , 1;...
    0.6875 , 0 , 1;...
    0.78125 , 0 , 1;...
    0.875 , 0 , 1;...
    0.96875 , 0 , 1;...
    1 , 0 , 0.9375;...
    1 , 0 , 0.84375;...
    1 , 0 , 0.75;...
    1 , 0 , 0.65625;...
    1 , 0 , 0.5625;...
    1 , 0 , 0.46875;...
    1 , 0 , 0.375;...
    1 , 0 , 0.28125;...
    1 , 0 , 0.1875;...
    1 , 0 , 0.09375;...
    ];