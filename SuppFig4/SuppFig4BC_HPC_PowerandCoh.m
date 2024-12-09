%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POWER and FREQUENCY ANALYSIS STUFF %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-process - generate seizure clean power by channel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
%     'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
%     'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
%     'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
%     'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %all ani
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%filters={'theta' 'gamma' 'ripple' 'slow_gamma' 'fast_gamma' 'fastripple' 'beta' 'theta_fastgamma'};
filters={'theta'};
refchannels=[64 64 64 64 64 64 64 64]; %[64 64] for 128A
numloops=1000;
state='non-running'; %other option: non-running
probetype='ECHIP512';
seizwd = 600; %in sec
numchans=512;
 for a=1:length(animals)  
     
    animal=animals{a};
        for filt=1:length(filters)
            filtertype=filters{filt};
              PowerByChannel_noseize(animal, state, filtertype, probetype, seizwd); %generate power for each channel duirng running or non-running phase with seizure time out and save in powerbychannle folder
        end
end
%% PART 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LFP layer plotting across animals
%output path: L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Means
%This function take care of bad channels from NPower
%This function does not take out epileptic spikes or seizures for now
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
%     'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
%     'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
%     'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
%     'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; % all ani
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment

%filters={'theta' 'gamma' 'ripple' 'slow_gamma' 'fast_gamma' 'fastripple' 'beta' }; %midgamma
filters={'theta'}; %midgamma
state = 'running'; %running or non-running, but I haven't processed non-running yet
overwrite = 1; % 0 means will load the animal matrix from data folder without overwriting. 1 means overwrite the exsiting animal matrix in data folder
%HPCEC_PowerCalculateAnimalMatrix_NONrun_HPC_SF(animals, filters, state, overwrite)
HPCEC_PowerCalculateAnimalMatrix_SF(animals, filters, state, overwrite) %Mat Power matrix being saved used for gradual changing plotting, and power matrix saved used for each layer of plotting (one data point per layer)


%% Other power related script
thetapowerplot_SF

%% PART 2 Frequency analysis
% PSD for single channel of all animals from different groups
PSD_SF %
theta_HPCbylayerbar_SF
theta_MECbylayerbar_SF

%%
% PSD by shank
ChannelPowerDiff_Run_LV_SF
ChannelPowerSpectrumZ_Run_LV_SF
meanPowerDiff_LV_SF




%% COHERENCE STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Coherence between region calculation and matrix generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Generate non-seiz runing time array 03/11/22 susie
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
for anim = 1:length(animals)
    animal=animals{anim};
    getruntimes_noseiz_SF(animal) 
end
%%
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
for anim = 1:length(animals)
    animal=animals{anim};
    getNONruntimes_noseiz_SF(animal) 
end
%% PART1
% Generate 256 x 256 coherence matrix 
% Take run time and non seiz time
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
animals = { 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
track = '1'; %track 1 is normal, track 2 is novel (CAN'T HAVE TS90-2 if choose track2)
run_times_range = 300; %in sec, this is how much run time you want to process %used 300 for run time process
nonrun_times_range = 60; %in sec
ECHPC_og_cohmatrix_SF(animals, track, run_times_range); %To calculate the coherence among all 4 shanks. each animal takes about 6-8hrs of using run time at 300s
%ECHPC_og_cohmatrix_NONrun_SF(animals, track, nonrun_times_range); %

%reference: HPCEC_CohCalculateAnimalMatrix_LV , plotECHIPcoh.m
%below is script just to explore the total run time for all aniamls
%exploreRunTime_SF; 

%% PART2
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
track = '1'; %track 1 is normal, track 2 is novel
%ECHPC_uniformcoh_SF(animals, track); %to generate uniformed coherence matrix (180x180) for each animals and save for each animal
ECHPC_uniformcoh_NONrun_SF(animals, track);
%reference
%ECHIPpowerandcoh
%ECHIPpowerandcoh_LV

%% PART3
%concat single and full coh matrix from each animal into 3D structure and plot
% animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
%     'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
%     'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
%     'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
%     'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2'  'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %this is with control seiz out
track = '1'; %track 1 is normal, track 2 is novel
%filters={'theta' 'gamma' 'slow_gamma' 'fast_gamma' 'beta' }; %midgamma
filters={'theta' }; %midgamma
%ECHPC_coh_concat_SF(animals,track,filters); %To concat each animal's uniform coh mat into 3D structure
ECHPC_coh_concat_NONrun_SF(animals,track,filters); %To concat each animal's uniform coh mat into 3D structure


%% PART4
% calculate p value matrix for 3D single and full coh matrix, and plot p value matrix
%ECHPC_coh_p_calc_SF

%%%%%%this part is moved in python%%%%%

%% Power and Coh output
powercohcsvoutput_SF %this is for outputting coh and power for specific region pair to do seizure correlation analysis


