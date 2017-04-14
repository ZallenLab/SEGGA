function output_to_csv = pvals_for_seg_measurement_to_csv(all_dirs_separated,legendtxt,control_ind,...
    vars,savedir,t_start,t_end, ylimcustom)
% 
% The last value of the movie can be extended
% and used as the end condition for analyses
% in which all movies end at the same, objectively
% defined reference point.


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
    txtstr_movlen = cell(length(all_dirs_separated),1);
    topcellstxt = txtstr_movlen;
    eloncellstxt = txtstr_movlen;
    staticcellstxt = txtstr_movlen;
    staticedgestxt = txtstr_movlen;
    vertshrinkedgestxt = txtstr_movlen;
    endvalstxt = txtstr_movlen;
    dirnamesstxt = txtstr_movlen;
    shrinkedgestxt = txtstr_movlen;
	growedgestxt = txtstr_movlen;
  
    for ii = 1:length(all_dirs_separated)


        dirlist(ii).var_final = [];
        dirlist(ii).var_integral = [];

        dirlist(ii).finalsmean_sterr = [];
        dirlist(ii).integralsmean_sterr = [];
        

        dirlist(ii).psameftest_compare_integrals = [];
        dirlist(ii).psamettest_compare_integrals = [];
        dirlist(ii).psameuttest_compare_integrals = [];

        dirlist(ii).psameftest_compare_finals = [];
        dirlist(ii).psamettest_compare_finals = [];
        dirlist(ii).psameuttest_compare_finals = [];


        for i = 1:length(all_dirs_separated{ii})
            cd(all_dirs_separated{ii}{i});
            display(pwd);
            
%             if isempty(dir([pwd,filesep,'..',filesep,'annotations']))
%                 create_many_annotation_movies(pwd);
%             end
            
            
%             remove later
%             write_shift_info_txt_file(pwd);
            
            current_var = vars(varind);
            load shift_info
            load timestep
            load cells_for_elon;
            eloncells = cells;
            load cells_for_t1_ros;
            topcells = cells;
            clear cells
            
            if isempty(dir([vars(varind).file_name,'*']))
                display(['missing file: ',vars(varind).file_name]);
                continue
            end
            d = load(vars(varind).file_name, vars(varind).var_name);
            if ~isfield(d,vars(varind).var_name)
                display(['variable did not load from data file']);
                continue
            end
            
            if isfield(vars(varind), 'func') && ~isempty(vars(varind).func)
                d.(vars(varind).var_name) = vars(varind).func(d.(vars(varind).var_name), shift_info);
            end
            if isfield(vars(varind), 'post_func') && ~isempty(vars(varind).post_func)
                d.(vars(varind).var_name) = vars(varind).post_func(d.(vars(varind).var_name));
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
            actual_endtime = min(round((60/timestep)*t_end - shift_info),length(tempvec));
            
            

            
            if actual_endtime <= 0 
                %movie doesn't start early enough
                continue
            end

            if isnan(tempvec(actual_endtime))
                actual_endtime = find(~isnan(tempvec),1,'last');
                if isempty(actual_endtime)
                    display([vars(varind).var_name, 'is empty for dir',pwd,'... skipping']);
                    continue
                end
                time_takes = time_takes(time_takes <= actual_endtime);

            end
            
            
            
            %get number of static cells used
            load analysis data clusters;
            staticcells = data.cells.selected(actual_endtime,:);
            mean_Ncells = mean(sum(data.cells.selected,2));
            
            staticedges = data.edges.selected(actual_endtime,:);
            mean_Nedges = mean(sum(data.edges.selected,2));
            
            load shrinking_edges_info_new edges_global_ind edges_global_ind_growing;
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

            if startnumbers > 1
                 tempvec(1:startnumbers) = tempvec(startnumbers);
            end


            if timediff>0
                tempvec_sum = sum(tempvec(time_takes)) + tempvec(actual_endtime)*timediff;
            else
                tempvec_sum = sum(tempvec(time_takes));
            end
            
            
            
            dirlist(ii).var_final = [dirlist(ii).var_final;tempvec(actual_endtime)];
            

            
% The last value of the movie can be extended and used as the end condition for
% analyses in which all movies end at the same, objectively defined reference point
            if (startnumbers > 1) || integralskip || startstoolate
                
%                 do nothing here, leave the list, add nothing
%                 dirlist(ii).var_integral = [dirlist(ii).var_integral;nan];
                
            else
                
                dirlist(ii).var_integral = [dirlist(ii).var_integral;tempvec_sum];
                
            end
            
            if ~isempty(txtstr_movlen{ii}) txtstr_movlen{ii} = [txtstr_movlen{ii},'; ']; end
            txtstr_movlen{ii} = [txtstr_movlen{ii},num2str(floor((length(tempvec) + shift_info)*15/60))];
            
            if ~isempty(topcellstxt{ii}) topcellstxt{ii} = [topcellstxt{ii},'; ']; end
            topcellstxt{ii} = [topcellstxt{ii},num2str(length(find(topcells)))];
            
            if ~isempty(eloncellstxt{ii}) eloncellstxt{ii} = [eloncellstxt{ii},'; ']; end
            eloncellstxt{ii} = [eloncellstxt{ii},num2str(length(find(eloncells)))];
            
            if ~isempty(staticcellstxt{ii}) staticcellstxt{ii} = [staticcellstxt{ii},'; ']; end
            staticcellstxt{ii} = [staticcellstxt{ii},num2str(mean_Ncells)];


            if ~isempty(endvalstxt{ii}) endvalstxt{ii} = [endvalstxt{ii},'; ']; end
            endvalstxt{ii} = [endvalstxt{ii},num2str(tempvec(actual_endtime))];
            
            if ~isempty(staticedgestxt{ii}) staticedgestxt{ii} = [staticedgestxt{ii},'; ']; end
            staticedgestxt{ii} = [staticedgestxt{ii},num2str(mean_Nedges)];
            
            
            
            if ~isempty(vertshrinkedgestxt{ii}) vertshrinkedgestxt{ii} = [vertshrinkedgestxt{ii},'; ']; end
            vertshrinkedgestxt{ii} = [vertshrinkedgestxt{ii},num2str(length(find(vertshrinks)))];
            
            if ~isempty(shrinkedgestxt{ii}) shrinkedgestxt{ii} = [shrinkedgestxt{ii},'; ']; end
            shrinkedgestxt{ii} = [shrinkedgestxt{ii},num2str(length(find(edges_global_ind)))];
           
            if ~isempty(growedgestxt{ii}) growedgestxt{ii} = [growedgestxt{ii},'; ']; end
            growedgestxt{ii} = [growedgestxt{ii},num2str(length(find(edges_global_ind_growing)))];
            
            subdirname = getsubdirname(relative_dir(pwd,'..'));
            if ~isempty(dirnamesstxt{ii}) dirnamesstxt{ii} = [dirnamesstxt{ii},'; ']; end
            dirnamesstxt{ii} = [dirnamesstxt{ii},'''',strrep(subdirname,',','_'),''''];
  

        end

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
                dirlist(ii).finalsmean_sterr = std(var_finals)./realsqrt(length(var_finals));
                
                dirlist(ii).psameftest_compare_finals = ftest(var_finals ,dirlist(control_ind).var_final);
                dirlist(ii).psamettest_compare_finals = ttest(var_finals ,dirlist(control_ind).var_final);
                dirlist(ii).psameuttest_compare_finals = uttest(var_finals ,dirlist(control_ind).var_final);
                
            else
                
                var_finals = dirlist(ii).var_final;
                dirlist(ii).finalsmean = mean(var_finals);
                dirlist(ii).finalsmean_sterr = nan;
                
                dirlist(ii).psameftest_compare_finals = [];
                dirlist(ii).psamettest_compare_finals = [];
                dirlist(ii).psameuttest_compare_finals = [];
                
            end

%                 dirlist(ii).psameftest = ftest(var_integrals,var_finals);
%                 dirlist(ii).psamettest = ttest(var_integrals,var_finals);
%                 dirlist(ii).psameuttest = uttest(var_integrals,var_finals);

            if size(dirlist(ii).var_integral,1)>1 &&...
                    (std(dirlist(ii).var_final)~=0||std(dirlist(control_ind).var_final)~=0);

                var_integrals = dirlist(ii).var_integral;
                dirlist(ii).integralsmean = mean(var_integrals);
                dirlist(ii).integralsmean_sterr = std(var_integrals)./realsqrt(length(var_integrals));

                dirlist(ii).psameftest_compare_integrals = ftest(var_integrals,dirlist(control_ind).var_integral);
                dirlist(ii).psamettest_compare_integrals = ttest(var_integrals,dirlist(control_ind).var_integral);
                dirlist(ii).psameuttest_compare_integrals = uttest(var_integrals,dirlist(control_ind).var_integral);




            else

                var_integrals = dirlist(ii).var_integral;    
                dirlist(ii).integralsmean = mean(var_integrals);                
                dirlist(ii).integralsmean_sterr = nan;              

                dirlist(ii).psameftest_compare_integrals = [];
                dirlist(ii).psamettest_compare_integrals = [];
                dirlist(ii).psameuttest_compare_integrals = [];


            end




        end

    end

    % return



    conv_integral = ((60/timestep)); %(t_end-t_start) not sensitive to time

%     fixedtxt = {'Genotype','genotype name placeholder','measurement','measurement name placeholder',...
%     'n-vals cells (top)','n-vals cells (elon)','n-vals cells (static)',...
%     'means [integral/time and point val]','S.E.M. [integral/time and point val]','end times (min)',...
%     'point val ftest','point val ttest','point val uttest',...
%     'integral ftest','integral ttest','integral uttest',...
%     };

%     output_to_csv(1,1).name = 'genotype';
%     output_to_csv(1,2).name = 'measurement';
% 
%     output_to_csv(1,3).name = 'n-vals cells (top)';
%     output_to_csv(1,4).name = 'n-vals cells (elongation)';
%     output_to_csv(1,5).name = 'n-vals cells (static)';
% 
%     output_to_csv(1,6).name = 'means [integral and point val]';
%     output_to_csv(1,7).name = 'S.E.M. [integral and point val]';
%     output_to_csv(1,8).name = 'end times (min)';
% 
%     output_to_csv(1,9).name = 'point val ftest';
%     output_to_csv(1,10).name = 'point val ttest';
%     output_to_csv(1,11).name = 'point val uttest';
% 
%     output_to_csv(1,12).name = 'integral ftest';
%     output_to_csv(1,13).name = 'integral ttest';
%     output_to_csv(1,14).name = 'integral uttest';
%     
%     output_to_csv(1,15).name = 'comparison genotype';
%     
    


    for i = 1:length(all_dirs_separated)
        
        mean_integral = dirlist(i).integralsmean/conv_integral;
        mean_final = dirlist(i).finalsmean;
        sterr_var_integral = dirlist(i).integralsmean_sterr/conv_integral;
        sterr_var_final = dirlist(i).finalsmean_sterr;
        
        sep_finals = dirlist(i).var_final;

            
            ftest_integrals_txt = num2str(round_func(dirlist(i).psameftest_compare_integrals));
            ttest_integrals_txt = num2str(round_func(dirlist(i).psamettest_compare_integrals));
            uttest_integrals_txt = num2str(round_func(dirlist(i).psameuttest_compare_integrals));
            
            
            
            ftest_pointval_txt = num2str(round_func(dirlist(i).psameftest_compare_finals));
            ttest_pointval_txt = num2str(round_func(dirlist(i).psamettest_compare_finals));
            uttest_pointval_txt = num2str(round_func(dirlist(i).psameuttest_compare_finals));
        
        
        output_to_csv(i,varind,1).val = legendtxt{i};%'genotype';
        output_to_csv(i,varind,2).val = vars(varind).title;%'measurement';

        output_to_csv(i,varind,3).val = ['[',topcellstxt{i},']'];%'n-vals cells (top)';
        output_to_csv(i,varind,4).val = ['[',eloncellstxt{i},']'];%'n-vals cells (elon)';
        output_to_csv(i,varind,5).val = ['[',staticcellstxt{i},']'];%'n-vals cells (static)';
        
        output_to_csv(i,varind,6).val = ['[',staticedgestxt{i},']'];%'n-vals edges (mean static)';
        output_to_csv(i,varind,7).val = ['[',shrinkedgestxt{i},']'];%'n-vals edges (shrinks)';
        output_to_csv(i,varind,8).val = ['[',growedgestxt{i},']'];%'n-vals edges (grows)';
        output_to_csv(i,varind,9).val = ['[',' ',']'];%'n-vals edges (shrinks)'; vertshrinkedgestxt{i} - removed
        
     
        
        output_to_csv(i,varind,10).val = num2str([mean_final]);%'means [final val]';
        output_to_csv(i,varind,11).val = num2str([sterr_var_final]);%'S.E.M. [final val]';
        output_to_csv(i,varind,12).val = ftest_pointval_txt;%'point val ftest';
        output_to_csv(i,varind,13).val = ttest_pointval_txt;%'point val ttest';
        output_to_csv(i,varind,14).val = uttest_pointval_txt;%'point val uttest';
        
        output_to_csv(i,varind,15).val = num2str([mean_integral]);%'means [integral]';
        output_to_csv(i,varind,16).val = num2str([sterr_var_integral]);%'S.E.M. [integral]';
        output_to_csv(i,varind,17).val = ftest_integrals_txt;%'integral ftest';
        output_to_csv(i,varind,18).val = ttest_integrals_txt;%'integral ttest';
        output_to_csv(i,varind,19).val = uttest_integrals_txt;%'integral uttest';
        
        output_to_csv(i,varind,20).val = ['[',txtstr_movlen{i},']'];%'end times (min)';

        
        output_to_csv(i,varind,21).val = legendtxt{control_ind};%'comparison genotype';
        output_to_csv(i,varind,22).val = num2str([t_start,t_end]);%'time interval';
        output_to_csv(i,varind,23).val = num2str(endvalstxt{i});%'final vals separate';
        
        output_to_csv(i,varind,24).val = num2str(dirnamesstxt{i});%'dir names';

        
        
        
        
        %%%%%%%%%%%
        %%%These stay the same, just duplicating
        output_to_csv(i,varind,1).name = 'genotype';
        output_to_csv(i,varind,2).name = 'measurement';

        output_to_csv(i,varind,3).name = 'n-vals cells (cell rearrangements)';
        output_to_csv(i,varind,4).name = 'n-vals cells (elongation)';
        output_to_csv(i,varind,5).name = 'n-vals cells (mean static)';
        
        output_to_csv(i,varind,6).name = 'n-vals edges (mean static)';
        output_to_csv(i,varind,7).name = 'n-vals edges (shrinks entire movie)';
        output_to_csv(i,varind,8).name = 'n-vals edges (grows entire movie)';
        output_to_csv(i,varind,9).name = ''; %n-vals vert shrinks - removed

        
        output_to_csv(i,varind,10).name = 'means [final val]';
        output_to_csv(i,varind,11).name = 'S.E.M. [final val]';
        output_to_csv(i,varind,12).name = 'final val ftest';
        output_to_csv(i,varind,13).name = 'final val ttest';
        output_to_csv(i,varind,14).name = 'final val uttest';
        
        output_to_csv(i,varind,15).name = 'means [integral*(timestep/60)]';
        output_to_csv(i,varind,16).name = 'S.E.M. [integral*(timestep/60)]';
        output_to_csv(i,varind,17).name = 'integral ftest';
        output_to_csv(i,varind,18).name = 'integral ttest';
        output_to_csv(i,varind,19).name = 'integral uttest';
        
        output_to_csv(i,varind,20).name = 'end times (min)';


        output_to_csv(i,varind,21).name = 'comparison genotype';
        output_to_csv(i,varind,22).name = 'time interval ''[start;end]''';
        output_to_csv(i,varind,23).name = 'final vals';
        
        output_to_csv(i,varind,24).name = 'dir names';

        
        
        

    end
    
end


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

    






