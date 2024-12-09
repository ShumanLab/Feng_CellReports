%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is to find the time bins to subsample data to aligh 3wk and 8wk pilo coh to control coh

% INPUTS:
% DGCA1coh_1sec.mat
% Find the subsample of the bins that matches with control coh value (DGCA1 coh)

% Note the analysis is retrained in track 1 
% For Pilo and control: whole track 1
% Note this aligning is using running no-seiz data 

% Note part 1 only need to run once, part 2 is calling saved output from part 1. But if changing stuff about bins, need to redo part 1
% susie 5/16/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART1 control coh range calc
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
track = '1';
length_rec = [];
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    stim_dir=[exp_dir 'stimuli\'];
    %load([ana_dir '\probe_data\ECHIP512.mat'])
    %load([exp_dir '\stimuli\' animal '_runtimesNEW_noseiz.mat']) %I used 3sec version for previous process
    if group == '3wC' | group == '8wC'
        load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix'); 
        load([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix');
        if length(run_matrix) > length(coh_matrix)
            run_matrix = run_matrix(1:length(coh_matrix),:);
        elseif length(run_matrix) < length(coh_matrix)
            coh_matrix = coh_matrix(1:length(run_matrix));
        end
        coh_matrix_run = coh_matrix(find(run_matrix(:,1) == 1));
        matrix_len = length(coh_matrix_run);
        length_rec = [length_rec matrix_len];
    end
end

max_len = max(length_rec);
coh_c = nan(11,max_len);
counter = 1;
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    stim_dir=[exp_dir 'stimuli\'];
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    if group == '3wC' | group == '8wC'
        load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix'); %this is all track1, not just running
        load([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix'); 
        if length(run_matrix) > length(coh_matrix)
            run_matrix = run_matrix(1:length(coh_matrix),:);
        elseif length(run_matrix) < length(coh_matrix)
            coh_matrix = coh_matrix(1:length(run_matrix));
        end
        coh_matrix_run = coh_matrix(find(run_matrix(:,1) == 1));
        
        coh_matrix_run(end+1:max_len) = nan;
        coh_c(counter,:) = coh_matrix_run;
  
        counter = counter + 1;
        save([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'track','run_matrix');
        clear coh_matrix coh_matrix_run run_matrix
    end
    
end

% ave across all animal for each time bin
coh_c_ave = nanmean(coh_c,1);
% coh_c_maxSD = mean(coh_c_ave)+1*std(coh_c_ave);
% coh_c_minSD = mean(coh_c_ave)-1*std(coh_c_ave);

coh_c_maxSD = mean(coh_c_ave)+0.5*std(coh_c_ave);
coh_c_minSD = mean(coh_c_ave)-0.5*std(coh_c_ave);

%% PART2 find subsample from pilo animals
% go in each animal of 3wp and 8wp, and find coh bins fall in coh_c_minSD & coh_c_maxSD
%animals = {'TS112-0' };
for a = 1:length(animals)
    align_ind_run = []; %indicate which timebins are aligned, call to coh_matrix_run
    align_ind = []; %call to coh matrix
    aligned_coh_matrix = [];
    counter = 1;
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    stim_dir=[exp_dir 'stimuli\'];
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    if group == '3wP' | group == '8wP' 
        load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix');
        load([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix');
        if length(run_matrix) > length(coh_matrix)
            run_matrix = run_matrix(1:length(coh_matrix),:);
        elseif length(run_matrix) < length(coh_matrix)
            coh_matrix = coh_matrix(1:length(run_matrix));
        end
        coh_matrix_run = coh_matrix(find(run_matrix(:,1) == 1));
        for i = 1:length(coh_matrix_run)
            if coh_matrix_run(i) >= coh_c_minSD
                aligned_coh_matrix(counter) = coh_matrix_run(i);
                align_ind_run(i) = 1;
                counter = counter + 1;
            else
                align_ind_run(i) = 0;
            end
        end

        for i = 1:length(coh_matrix)
            if run_matrix(i,1) == 1 && coh_matrix(i) >= coh_c_minSD
                align_ind(i) = 1;
            else
                align_ind(i) = 0;
            end
        end
        save([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind');
        disp([animal group]);
        clear coh_matrix_run coh_matrix aligned_coh_matrix run_matrix align_ind_run align_ind
    end 

end


%% Check if subsample worked


coh_c = [];
coh_3wp_align = [];
coh_8wp_align = [];
counter_c = 1;
counter_3wp = 1;
counter_8wp = 1;

for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info


    load([ana_dir '\probe_data\ECHIP512.mat'])
    if group == '3wP'
        load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind');
        coh_3wp_align(counter_3wp) = nanmean(aligned_coh_matrix);
        coh_ave_3wp_ani{counter_3wp} = animal;
        counter_3wp = counter_3wp +1;
    elseif group == '8wP' 
        load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind');
        coh_8wp_align(counter_8wp) = nanmean(aligned_coh_matrix);
        coh_ave_8wp_ani{counter_8wp} = animal;
        counter_8wp =counter_8wp + 1;
    elseif group == '3wC' | group == '8wC' 
        load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix', 'coh_matrix_run');  %deal with control doesn't have manualbin_update
        coh_c(counter_c) = nanmean(coh_matrix_run);
        coh_ave_c_ani{counter_c} = animal;
        counter_c = counter_c + 1;
    end

end %end of animal

savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\DGCA1\';
if exist(savepath)==0
    mkdir(savepath);
end
save([savepath '\DGCA1_coh_whileDGCA1Colalign_running.mat'],'coh_3wp_align','coh_8wp_align', 'coh_c', 'coh_ave_c_ani', 'coh_ave_8wp_ani','coh_ave_3wp_ani');













