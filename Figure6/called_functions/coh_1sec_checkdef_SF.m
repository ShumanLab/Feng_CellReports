%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This scipt is to calc/orgnize coh based on track1 running using 1sec bins and just from a
% signle ch data to see if original deficits exsit
% Susie 5/14/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DGCA1
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%DGCA1_singch_calc_running_SF(animals)
%track = '1';

animallist = {};
grouplist = {};
cohlist = [];
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    stim_dir=[exp_dir 'stimuli\'];
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info

    load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix'); 
    load([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix'); 

    coh_run_mat = nan(length(coh_matrix),1);
    for i=1:length(coh_run_mat)
        if run_matrix(i,1) == 1
            coh_run_mat(i) = coh_matrix(i); %take only running + nonseize
        else
        end
    end
    coh_ave = nanmean(coh_run_mat);
    cohlist = [cohlist coh_ave];
    animallist = [animallist animal];
    grouplist = [grouplist group];
    %grouplist = str2double(grouplist);
    %grouplist = double2c

end
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\DGCA1\';
if exist(savepath)==0
     mkdir(savepath);
end
save([savepath '\DGCA1_coh_singch_ori.mat'],'cohlist','animallist', 'grouplist' );

clear all


%% M2M3
animals = {'TS112-0' 'TS114-1'  'TS111-1' 'TS115-2' 'TS116-3' ...
    'TS116-2' 'TS117-0' 'TS118-4'  'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2'  ...
     'TS110-3'  'TS115-1'  ...
    'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with mec2 and mec3

%track = '1';
animallist = {};
grouplist = {};
cohlist = [];
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    stim_dir=[exp_dir 'stimuli\'];
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info

    load([exp_dir '\M2M3coh_1sec.mat'],'coh_matrix'); 
    load([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix'); 

    coh_run_mat = nan(length(coh_matrix),1);
    for i=1:length(coh_run_mat)
        if run_matrix(i,1) == 1
            coh_run_mat(i) = coh_matrix(i);
        else
        end
    end
    coh_ave = nanmean(coh_run_mat);
    cohlist = [cohlist coh_ave];
    animallist = [animallist animal];
    grouplist = [grouplist group];
end
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\M2M3\';
if exist(savepath)==0
     mkdir(savepath);
end
save([savepath '\M2M3_coh_singch_ori.mat'],'cohlist','animallist',  'grouplist' );

clear all


%% M2MO
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with M2 and MO
animallist = {};
grouplist = {};
cohlist = [];
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    stim_dir=[exp_dir 'stimuli\'];
    
    load([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix'); 
    load([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix'); 

    coh_run_mat = nan(length(coh_matrix),1);
    for i=1:length(coh_run_mat)
        if run_matrix(i,1) == 1
            coh_run_mat(i) = coh_matrix(i);
        else
        end
    end

    coh_ave = nanmean(coh_run_mat);
    cohlist = [cohlist coh_ave];
    animallist = [animallist animal];
    grouplist = [grouplist group];
end
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\M2MO\';
if exist(savepath)==0
     mkdir(savepath);
end
save([savepath '\M2MO_coh_singch_ori.mat'],'cohlist','animallist',  'grouplist' );

clear all

