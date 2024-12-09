%% Preprocess Data

%below is all animal list (order matters)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment

edit animallist_SF

%1, set up experiment info and analysis script path

%select data directory
data_dir = uigetdir; %data_dir is where the raw data located
animal='TS110-0';  
experiment='SummerEphysHPCEC';
datei='220130';
filename='Recording';

% fileindex=[animal '-' filen ame '_' datei '_*.rhd'];
fileindex=[animal '*.rhd'];

%set ana_dir
%%set analysis script path which will be pass in later different functions:
%global ana_dir:
ana_dir = 'L:\Susie\EphysAnalysisScripts\ECHPC';
edit get_ana

%%
% 2, set exp_dir (output dir)
%this is the dir where you want your analysis to be saved, normally should be seperate with raw data file
exp_dir=['K:\Susie\' experiment '\AnalysisOutput\' animal '\' datei '\' filename '\'];
if exist(exp_dir)==0
mkdir(exp_dir)
end
edit get_exp   %pop up the “get_exp” and put in path of your next animal in a new elseif statement

%%
% 3, generate bad channel mapped file (require pre generated bad channel csv file (badch.csv) located in raw data folder
%skip this if you do not wish to assign bad channels-susie
probetype='ECHIP512';
badch_map_SF(animal, probetype);
numchans=512;

%% 4, save parameters
exp_dir=get_exp(animal);
%save parameters
exp.animal=animal;
exp.experiment=experiment;
exp.datei=datei;
exp.filename=filename;
exp.fileindex=fileindex;
exp.exp_dir=exp_dir;
exp.data_dir=data_dir;

%load up bad channels
if exist([exp_dir '\' animal 'badch_mapped.mat'])>0
    load([exp_dir '\' animal 'badch_mapped.mat']);
    badchannels=badchannelmapped;
    exp.badchannels=badchannels;
else
    exp.badchannels=[];
end
exp.probetype=probetype;
exp.numchans=numchans;
exp.ana_dir = ana_dir;

save([exp_dir 'exp.mat'],'-struct', 'exp');

%% write in animal group info into exp.m
animals = {'TS112-0'}; 
for anim = 1:length(animals)
    animal=animals{anim};
    animal_group_info_SF(animal)
end
%% moved from seiz detection part to here to remind myself to add this info in if accidentally overwrite exp file
% write seizure time into exp file
% NEED TO UPDATE when new animals added in!
%below is all animal list (order matters)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
for anim = 1:length(animals)
    animal=animals{anim};
    animal_seizing_info_SF(animal)
end
%% moved from kilosort part to here to remind myself to add this info in if accidentally overwrite exp file
%below is all animal list (order matters)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
for anim = 1:length(animals)
    animal=animals{anim};
    get_kilo_inputtime_SF(animal) %save kilot0 and kilot1 as start and end process time through kilosort
end

%%
%save full data by channel
%below is all animal list (order matters)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment

for anim = 1:length(animals)
    animal=animals{anim};
parfor shank=1:8
SaveEachChannelMbyshank(animal,shank) %saves each channel and stimuli into mat files in exp_dir
end
end
%for 142GB data on Boron takes 5hrs for this step

%PlotStimuli(animal) %plots position, licking, rewards, running

%%
%Plot drifts and animal's position

%below is animals list with master MEC shank and without control seizing  (110-0, 117-4, 113-3; 112-1. 113-2-(have shank but no spike))
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of al

for anim = 1:length(animals)
    animal=animals{anim};
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
    shank=MECshank; %pick best shank, change depending on the recording/animal
    threshold=32; %more negative than -20 in filtered data
    getMUAfullLV_SF(animal,shank,threshold); %calc the spike/min and make matrix of it
end
%     animal = 'TS91-2';
%     shank = 3;
%     plotdrift_position_SF(animal, shank); %plot drifting map and animal's position
%end;

%%

%remove licking artifact if necessary
% animal='AD1-1';
% RemoveLickArtifacts(animal)
animals = {'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' 'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 

for anim = 1:length(animals)
    animal=animals{anim};
%get downsampled LFP
    srate=25000; %full sampling rate (after resample if performed)
    numchans=512;
    DownsampleRecordingTo1000Hz(animal, srate, numchans) %for 142G data on Boron takes 2hrs
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Clear 60Hz 120Hz 180Hz noise
%SF 8/1/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
numchans = 512;
clean60hznoise_SF(animals, numchans);
% 
%%
%this section is to plot and check through noises
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
ch = 10;
plotPSD_SF(animals, ch)

%%
%clean noise for weird noise animals
animals = {'TS110-3' 'TS89-2' 'TS112-0'};
numchans = 512;
cleanweirdhznoise_SF(animals, numchans); %THIS IS ONLY for 110-3 89-2 and 112-0


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEIZURE detection
% PART1
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; 
%animals = { 'TS113-2' 'TS112-1'}; 
animals = {'TS114-1'};
downsr = 10; %from 1000hz, how many fold to downsample. eg: if put 10, final sample rate is 100hz
channel = 510;
plot_LFP_seizure_SF(animals, downsr, channel)

%% PART2
% write seizure time into exp file
% NEED TO UPDATE when new animals added in!
animals = {'TS110-0'}; 
for anim = 1:length(animals)
    animal=animals{anim};
    animal_seizing_info_SF(animal)
end

%%

animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment

for a=1:length(animals)  
    animal=animals{a};
    getruntimes_noseiz_SF(animal) %this is used in coherence analysis laterin post analysis 
end


for a=1:length(animals)  
    animal=animals{a};
VRstatearraysNEW(animal, 0.1); %~30 minutes; about 5-10min for 142G recording
getruntimes(animal); %makes run_times from running bins made in VRstatearraysNEW
getruntimes_noseiz_SF(animal) %this is used in coherence analysis laterin post analysis 

end

% get running times, non running times, also detect lick and reward
VRstatearraysNEW(animal, 0.1); %binsize is second argument (sec) ~30 minutes; about 5-10min for 142G recording
getruntimes(animal); %makes run_times from running bins made in VRstatearraysNEW
getruntimes_noseiz_SF(animal) %this is used in coherence analysis laterin post analysis 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%Genrate LFP power files for each channel at different frequency band
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
filters={'theta' 'gamma' 'ripple' 'slow_gamma' 'fast_gamma' 'fastripple' 'beta' 'theta_fastgamma'};
%filters={ 'gamma' 'ripple' 'theta_fastgamma'};

refchannels=[64 64 64 64 64 64 64 64]; %[64 64] for 128A
numloops=1000;
state='running';
probetype='ECHIP512';

numchans=512;
 for a=1:length(animals)  
    animal=animals{a};
        for filt=1:length(filters)
            filtertype=filters{filt};
               FilterOnly_P(animal, filtertype, numchans); %take notch LFP now %only works if folder doesn't exist
               [LFP128, PX]=power128byshank2(animal, filtertype,probetype); %save certain frequency band power for all channels in one file in each frequency folder
               [phasedev3 stddev]=LFPphasedev_running(animal,filtertype, refchannels, numloops); %plot shift for all shanks for all frequency and save in RunningPhaseDev folder %needs running! this is a terrible script - needs to be replaced. don't even need it since you get the same with coh/phase plot calculation
               PowerByChannel(animal, state, filtertype, probetype); %generate power for each channel duirng running or non-running phase and save in powerbychannle folder
        end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generating coherence matrix 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
for a=1:length(animals)
    animal=animals{a};
    %parpool('SpmdEnabled',false)
    time=0;  %if dotrials=520 - in seconds - if t=0 use full length
    probetype='ECHIP512';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %generating LFP power for each shank
        %parfor shank=1:8
        for shank=1:8
        extractLFP2_restricttime(animal,probetype,shank,time) %use downsampled 1000hz data to construct LFP for each shank with bad channel left in there
        %Susie decided not to take care her bad ch at this step so she commented out that part in this function
        end
    %make a coherence matrix - plot to see layer
    CoherenceMatByAnimal %For 143G data that animal ran a lot, it is about 2hours per shank
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





