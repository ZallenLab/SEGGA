
load('piv_data.mat','x','y','u','v','u_filt','v_filt');
num_frms = length(u);
x_res = size(u{1},2);
y_res = size(u{1},1);

% use blocks of the image
% at 1/3 from left, middle
% and 1.3 from right, middle

b1_x = floor(x_res/3);
b1_y = floor(y_res/2);

b2_x = floor(x_res*2/3);
b2_y = floor(y_res/2);

% Use ~5% of avail PIV info at each block
x_rad = round(x_res/20);
y_rad = round(y_res/20);
yinds = (b1_y-y_rad):(b1_y+y_rad);
xinds = (b1_x-x_rad):(b1_x+x_rad);

yindmat = repmat(yinds',1,numel(xinds));
xindmat = repmat(xinds,numel(yinds),1);
b1_inds = sub2ind(size(u{1}),yindmat,xindmat);


yinds = (b2_y-y_rad):(b2_y+y_rad);
xinds = (b2_x-x_rad):(b2_x+x_rad);
yindmat = repmat(yinds',1,numel(xinds));
xindmat = repmat(xinds,numel(yinds),1);
b2_inds = sub2ind(size(u{1}),yindmat,xindmat);


mpf = 0.25; %frames per minute
left = 2; %left column for analysis of elongation (you can vary this)
right = 8; %right column for analysis of elongation (you can vary this)
t_shift = 0; %for aligning different curves at some "zero" time

namelist = ls('*.mat'); % as a char array
nfiles = length(namelist(:,1));
mytime = linspace(1,nfiles,nfiles)*mpf-t_shift;
   
fixed = 4; % pick a row for analysis of elongation along a fixed horizontal line

b1.mean_u = zeros(num_frms,1);
b1.mean_v = zeros(num_frms,1);
b2.mean_u = zeros(num_frms,1);
b2.mean_v = zeros(num_frms,1);

x_temp = x{1};
y_temp = y{1}; %in pixels

for i=1:num_frms % run through all the files for the movie
        
    u_temp = u_filt{i};
    v_temp = v_filt{i};


    b1.mean_u(i) = mean(flatten(u_temp(b1_inds)));
    b1.mean_v(i) = mean(flatten(v_temp(b1_inds)));
	b2.mean_u(i) = mean(flatten(u_temp(b2_inds)));
    b2.mean_v(i) = mean(flatten(v_temp(b2_inds)));
    
	b1.max_u(i) = max(flatten(u_temp(b1_inds)));
    b1.max_v(i) = max(flatten(v_temp(b1_inds)));
	b2.max_u(i) = max(flatten(u_temp(b2_inds)));
    b2.max_v(i) = max(flatten(v_temp(b2_inds)));

end


cumsum_mean_diff = cumsum(b1.mean_u - b2.mean_u); % option 1, cumulative sum
cumsum_max_diff = cumsum(b1.max_u - b2.max_u); % option 2, cumulative sum

l_o = x_temp(b1_y,b1_x)-x_temp(b2_y,b2_x);  % "initial" length

rel_elon_mean = (cumsum_mean_diff + l_o)/l_o; % relative elongation, option 1
rel_elon_mean = rel_elon_mean/min(rel_elon_mean); 
save('piv_procd_data','rel_elon_mean');



clear('p','s','x','y','u','v','typevector','directory','filenames','pivdir',...
    'u_filt','v_filt','typevector_filt');

clear('b1','b1_inds','b1_x','b1_y','b2','b2_inds','b2_x','b2_y','cumsum_max_diff',...
       'cumsum_mean_diff','fixed','i','l_o','left','mpf','mytime','namelist','nfiles',...
       'num_frms','rel_elon_mean','right','t_shift','u_temp','v_temp','rad' ,'x_res',...
       'x_temp','xindmat','xinds','y_rad','y_res','y_temp','yindmat','yinds');


% allvars = whos;
% display({allvars(:).name})



