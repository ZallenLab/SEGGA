function output_extracted_vals = extract_single_timepoint_vals(all_dirs_separated,legendtxt,control_ind,...
    vars,savedir,t_start,t_end, ylimcustom)
%%%
% For movies that do not reach the end point specified, the latest values
% are used in comparisons.
%
% In other words, The last value of the movie can be extended and used as
% the end condition for analyses in which all movies end at the same, 
% objectively defined reference point.
%
% Specifically, Regarding G.B.E.:
% If a movie is segmented until cell division occurs within the germband
% it is considered to have reached a timepoint that is equivalent to the
% end of the fast phase for a wild type, which is aproximately 30 mins after t=0
% and usually coincides with the first cell divisions in the germband. 
%
%
%
%
%

if nargin <8 || isempty(ylimcustom) 
    ylimcustom = [];
end

if nargin <7 || isempty(t_end) 
    t_end = 0;
end

if nargin <6 || isempty(t_start) 
    t_start = 0;
end

if ~isdir(savedir)
    mkdir(savedir)
end


start_dir = pwd;
round_func = @(x) floor(x*1000000)/1000000;

% [vecs shifts_returned dir_ind time_step_ret single_movie_dirs] = read_vecs_from_files(...
%     home_dir, dir_names, vars);

% all_dirs_separated = all_dirs_separated{groups};

    
for varind = 1:length(vars)
 
    clear dirlist
    
  
    for ii = 1:length(all_dirs_separated)


        dirlist(ii).var_final = [];
        dirlist(ii).var_integral = [];




        for i = 1:length(all_dirs_separated{ii})
            cd(all_dirs_separated{ii}{i});
            display(pwd);        
            current_var = vars(varind);
            load shift_info
            load timestep
            load cells_for_elon;
            eloncells = cells;
            load cells_for_t1_ros;
            topcells = cells;
            clear cells
            
           if isempty(dir([vars(varind).file_name,'*']))
               display('missing data file for chart');
               display(pwd);
               d.(vars(varind).var_name) = nan;
           else
            
            
            
            d = load(vars(varind).file_name, vars(varind).var_name);
                if isfield(vars(varind), 'func') && ~isempty(vars(varind).func)
                    d.(vars(varind).var_name) = vars(varind).func(d.(vars(varind).var_name), shift_info);
                end
                if isfield(vars(varind), 'post_func') && ~isempty(vars(varind).post_func)
                    d.(vars(varind).var_name) = vars(varind).post_func(d.(vars(varind).var_name));
                end
           end
                
                tempvec = d.(vars(varind).var_name);
            
%             t_start = 0;
%             t_end = 0;

        integralskip = false;
            if (t_end - t_start)<=0
                display('time differential is zero or negative: problem for integral');
%                 %must stop for this one and go to the next
%                 return
                integralskip = true;

            end

            
            time_takes = (max(((60/timestep)*t_start - shift_info),1):1:min(((60/timestep)*t_end - shift_info),length(tempvec)));

            theoretical_starttime = (60/timestep)*t_start - shift_info;
            startstoolate = theoretical_starttime <=0;
            
            needed_endtime = (60/timestep)*t_end - shift_info;
            actual_endtime = min(((60/timestep)*t_end - shift_info),length(tempvec));
            
            

            
            if actual_endtime <= 0 
                %movie doesn't start early enough
                display('actual_endtime <= 0');
                dirlist(ii).var_final = [dirlist(ii).var_final;nan];
                dirlist(ii).var_integral = [dirlist(ii).var_integral;nan];
                continue
                
            end

            if isnan(tempvec(actual_endtime))
                if any(~isnan(tempvec))
                    actual_endtime = find(~isnan(tempvec),1,'last');
                    time_takes = time_takes(time_takes <= actual_endtime);
                else
                    actual_endtime = 1;
                    time_takes = 1;
                end
            end
            
            
            
            %get number of static cells used
            load analysis data clusters;
            staticcells = data.cells.selected(actual_endtime,:);
            
            staticedges = data.edges.selected(actual_endtime,:);
            
            load shrinking_edges_info_new edges_global_ind;
            load('aligned_edges_info_linkage', 'v_linked','vertical_edges','shrink_to_shrink_linked');
            
            
            shrink_global_inds = [];
            shrink_global_inds = [shrink_global_inds,clusters(:).edges];
            shrink_global_inds = unique(shrink_global_inds, 'legacy');
            
            shrink_global_inds_long = zeros(1,size(data.edges.selected,2));
            shrink_global_inds_long(shrink_global_inds) = 1;
            vertshrinks = vertical_edges(actual_endtime,:)&shrink_global_inds_long;
            shrinkedges = data.edges.selected(actual_endtime,edges_global_ind);


            timediff = needed_endtime - actual_endtime;
            startnumbers = find(~isnan(tempvec),1,'first');
            if isempty(startnumbers)
                startnumbers = 1;
            end

            if startnumbers > 1
                 tempvec(1:startnumbers) = tempvec(startnumbers);
            end


            if timediff>0
                tempvec_sum = sum(tempvec(time_takes)) + tempvec(actual_endtime)*timediff;
            else
                tempvec_sum = sum(tempvec(time_takes));
            end
                tempvec_sum = tempvec_sum/(numel(time_takes)+timediff); %the integral divided by time

            
            
            dirlist(ii).var_final = [dirlist(ii).var_final;tempvec(actual_endtime)];
            

            
% The last value of the movie can be extended and used as
% the end condition for analyses in which all movies end
% at the same, objectively defined reference point.
            if (startnumbers > 1) || integralskip || startstoolate
                
                dirlist(ii).var_integral = [dirlist(ii).var_integral;nan];
                
            else
                
                dirlist(ii).var_integral = [dirlist(ii).var_integral;tempvec_sum];
                
            end
            
            
  

        end
        
        display(dirlist(ii).var_final);

    end
    
    %%%Still inside the bigger for loop for 'var_ind'

    for ii = 1:length(all_dirs_separated)
        for i = 1:length(all_dirs_separated{ii})

            cd(all_dirs_separated{ii}{i});
            display(pwd);

            if size(dirlist(ii).var_final,1)>1 &&  size(dirlist(control_ind).var_final,1)>1&&...
                    (std(dirlist(ii).var_final)~=0||std(dirlist(control_ind).var_final)~=0);
                
                var_finals = dirlist(ii).var_final;
                dirlist(ii).finalsmean = mean(var_finals);
         
            else
                
                var_finals = dirlist(ii).var_final;
                dirlist(ii).finalsmean = mean(var_finals);
              
            end

            if size(dirlist(ii).var_integral,1)>1 &&...
                    (std(dirlist(ii).var_final)~=0||std(dirlist(control_ind).var_final)~=0);

                var_integrals = dirlist(ii).var_integral;
                dirlist(ii).integralsmean = mean(var_integrals);

            else

                var_integrals = dirlist(ii).var_integral;    
                dirlist(ii).integralsmean = mean(var_integrals);                
 

            end




        end

    end

    % return



    conv_integral = ((t_end-t_start)*(60/timestep));




    for i = 1:length(all_dirs_separated)
        
        mean_integral = dirlist(i).integralsmean/conv_integral;
        mean_final = dirlist(i).finalsmean;
      
        
        

    end
    
    
    
end

output_extracted_vals = dirlist;


cd(start_dir);







function [vecs shifts_returned dir_ind time_step_ret movie_dirs] = read_vecs_from_files(...
    home_dir, root_dir_names, vars)
dir_ind = false(length(root_dir_names));
cnt = 0;
for i = 1:length(root_dir_names)
    cd(root_dir_names{i});
    sub_dir = pwd;
    dir_names = dir;
    for j = 3:length(dir_names)
        if dir_names(j).isdir
            cd(sub_dir);
            cd(dir_names(j).name)
            if ~isdir('seg')
                continue
            end
            cd('seg')
            if ~length(dir('shift_info.mat'))
                continue
            end
            if ~length(dir('timestep.mat'))
                disp(['timestep.mat not found in ' pwd])
                continue
            end
            
            load('shift_info');
            load('timestep');


            cnt = cnt + 1;
            movie_dirs{cnt} = dir_names(j).name;
            dir_ind(i, cnt) = true; %for cases when we skip directories
            shifts_returned(cnt) = shift_info;
            time_step_ret(cnt) = timestep;
            
            for k = 1:length(vars)
                d = load(vars(k).file_name, vars(k).var_name);
                if isfield(vars(k), 'func') && ~isempty(vars(k).func)
                    d.(vars(k).var_name) = vars(k).func(d.(vars(k).var_name), shift_info);
                end
                vecs{k, cnt} = d.(vars(k).var_name);
            end
%             d = load(filename, var_name);
%             if isvector(d.(var_name))
%                 vecs{1, cnt} = d.(var_name);
%             else
%                 for arr_cnt = 1:size(d.(var_name), 2)
%                     vecs{arr_cnt, cnt} = d.(var_name)(:, arr_cnt);
%                 end
%             end
%             starts_before_elon(cnt) = found_min; 
        end    
    end
    cd(home_dir);
end



function avg_vecs = average_and_sum_vecs(vecs, shifts, groups, dir_ind, ...
    time_steps, global_timescale, vars)

grouped_dir_ind = false(length(groups), length(dir_ind(1, :)));
for j = 1:length(groups)
    for k = 1:length(groups(j).dirs)
        grouped_dir_ind(j, :) = grouped_dir_ind(j, :) | dir_ind(groups(j).dirs(k), :);
    end
end


for i = 1:size(vecs, 1)
    for j = 1:length(groups)
        
        time_steps_group = time_steps(grouped_dir_ind(j,:));
        
        [avg_vecs(i).group(j).avg avg_vecs(i).group(j).std_err ...
            avg_vecs(i).group(j).std_std avg_vecs(i).group(j).num] = ...
            avg_shifted_vecs_with_nans({vecs{i, grouped_dir_ind(j, :)}}, ...
            shifts(grouped_dir_ind(j, :)), vars(i).boundary_l, ...
            vars(i).boundary_r, time_steps_group, global_timescale, vars(i).avg_func);
%         DLF EDIT 2013July15 changing the timesteps to have only those for
%         the group being averaged
        if isfield(vars(i), 'post_func') && ~isempty(vars(i).post_func)
            new_mean = vars(i).post_func(avg_vecs(i).group(j).avg);
            if isfield(vars(i), 'post_func_err_linear') && vars(i).post_func_err_linear
                avg_vecs(i).group(j).std_err = avg_vecs(i).group(j).std_err .* ...
                    abs(new_mean ./ avg_vecs(i).group(j).avg);
                avg_vecs(i).group(j).std_std = avg_vecs(i).group(j).std_std .* ...
                    abs(new_mean ./ avg_vecs(i).group(j).avg);
            else
                avg_vecs(i).group(j).std_err = abs(vars(i).post_func...
                    (avg_vecs(i).group(j).avg + avg_vecs(i).group(j).std_err)...
                    - new_mean);
                avg_vecs(i).group(j).std_std = abs(vars(i).post_func...
                    (avg_vecs(i).group(j).avg + avg_vecs(i).group(j).std_std)...
                    - new_mean);
            end
            avg_vecs(i).group(j).avg = new_mean;
        end
    end    
end

    






