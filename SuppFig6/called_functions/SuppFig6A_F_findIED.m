%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This scipt is to find epileptic spikes in mid pyr ch 
% Goal is to calc epi spk during run and non run 
% Inputs: backsub mat file for each ch; LFP data; probe 512 map; 
% Outputs: 
% Susie: 7/1/2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%animals = {'TS114-0'};
samplingrate=25000;
mindist_sec=1;%seconds, distance between 2 spikes. it was 0.5 orginal script,i tried 0.2
mindist=mindist_sec*samplingrate;%min time window for the second spk to raise
minspiketime_sec = 0.001; %in sec, minimam time above theres time should last to be consider as epi spk. was 0.02s but I think it's too much? since this is not whole spike time, this is above thres spike time (I was using 0.001 zoe used 0.0001)
minspiketime=minspiketime_sec*samplingrate; 
spikevnoisethresh = 10000; %tested and 10000 works

maxdur_sec = 0.004; %in sec, max time allowed for epi spk to reach the bottom peak after reaching the threshold. why this number?
maxdur = maxdur_sec*samplingrate;
% Susie doesn't understand the point to have maxdur
plotaround_sec=0.3;%secc
plotaround=plotaround_sec*samplingrate;

onlyneg = 1; %set to 1 if only consider downward spikes
threshold = 1200; %unit in uV, was 150o susie changed to 1000 after some pilo animal have ~1100 epi spikes
groupc_total = [];
group3wp_total = [];
group8wp_total = [];
groupc_run = [];
group3wp_run = [];
group8wp_run = [];
groupc_NONrun = [];
group3wp_NONrun = [];
group8wp_NONrun = [];
count_c = 1;
count_3wp = 1;
count_8wp = 1;
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\EpilepticSpike\runNonrun\';
if exist(savepath)==0
     mkdir(savepath);
end

for a = 1:length(animals)
    
    abovestart=[];
    aboveend=[];
    epspikes=[];
    noisespike=[];
   
    animal = animals(a);
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir '\exp.mat'])
    load([ana_dir '\probe_data\ECHIP512.mat']) %note probe layout is upside down of a probe. eg; 1st row in probelayout is actually ch #1 on probe which is the bottom tip of the probe physically
  
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
    shank = CA1DGshank;
    
    [channel]=getchannels(animal,shank); %pick CA1DGshank to figure out group info since every animal has it
    shankchs=probelayout(:,shank);
    chind=shankchs(channel.MidPyr);
    load([exp_dir '\LFP\' animal '_shank' num2str(shank) '_LFP.mat'],'LFP');
    load([exp_dir '\LFP\backsub\LFPvoltage_ch' num2str(chind) '.mat']);
    pyrLFP=LFPvoltage;
    load([exp_dir '\stimuli\' animal '_runtime_1s_bin.mat'],'run_matrix'); %note this is non seiz and track 1 only
%     load([exp_dir '\stimuli\' animal '_VRstatearrays.mat']) %run_time matrix is in sec unit
%     load([exp_dir '\stimuli\' animal '_seizstatearray.mat']) %run_time matrix is in sec unit
    load([exp_dir '\stimuli\position.mat'])
 
    %find track 1 time
    track1 = find(position == 4);
    track1_end = track1(end);
    track1_end_time = track1_end/samplingrate; %unit in sample rate


    % convert run_matrix to sample rate time
    run_matrix_samplerate = [];
    stp_win = samplingrate - 1;
    counter = 1;
    for r = 1:length(run_matrix)
        if counter + stp_win <= length(run_matrix)*samplingrate
            if run_matrix(r,1) == 1
                run_matrix_samplerate(counter:counter+stp_win) = 1;
            else
                run_matrix_samplerate(counter:counter+stp_win) = 0;
            end
        else
            if run_matrix(r,1) == 1
                run_matrix_samplerate(counter:end) = 1;
            else
                run_matrix_samplerate(counter:end) = 0;
            end
        end

        counter = counter + samplingrate;
    end

    %% find epi spk
    if onlyneg==1
        abovethresh=find(pyrLFP<=-threshold);
    else
        abovethresh=find(abs(pyrLFP)>=threshold);
    end
    %below is to slect each epi spk that pass threshold and follw min time window rule
    for t=1:length(abovethresh)
        if isempty(aboveend)==1
            
             if abs(pyrLFP(abovethresh(t)-1))<threshold
                 abovestart=[abovestart abovethresh(t)];       
             end
    
             if abs(pyrLFP(abovethresh(t)+1))<threshold   || abs(pyrLFP(abovethresh(t)+1) - pyrLFP(abovethresh(t)))>2*threshold
                 aboveend=[aboveend abovethresh(t)];
             end
             
        elseif abovethresh(t)>aboveend(end)+mindist
    
             if abs(pyrLFP(abovethresh(t)-1))<threshold
                 abovestart=[abovestart abovethresh(t)];       
             end
             
             if length(abovestart)>length(aboveend)
                     if abs(pyrLFP(abovethresh(t)+1))<threshold    || abs(pyrLFP(abovethresh(t)+1) - pyrLFP(abovethresh(t)))>2*threshold
                         aboveend=[aboveend abovethresh(t)];
                     end
             end
        end
    end
    abovetime=aboveend-abovestart;

%below is filter out spk doesn't last long enough to be spk and noise spk
%(shoudn't filter out a lot for thenoise part since im using backsub data)
    for m=1:length(abovetime)
        if abovetime(m)>=minspiketime
                %possible spike
                ds=samplingrate/1000;
                spiketime=round(abovestart(m)/ds);%downsample to LFP
                if spiketime>size(LFP,2)
                    continue
                end
                
                %calculate average LFP 
                avLFP=nanmean(LFP(:,spiketime));
                backLFP=LFP(:,spiketime)-avLFP;
                
                if nansum(abs(backLFP))>spikevnoisethresh %set as 10000 here
                    %spike is real
                    epspikes=[epspikes abovestart(m)];
                    
                else
                    noisespike=[noisespike abovestart(m)];
                end
        else
            %not a spike
        end
    end

%below is filter out spk doesn't reach bottom peak in short enough time
% also build in run and non run filter here
%(maxdur)
    %align spikes
    alepspikes_run=[]; %time stamp when epi spk happens
    alepspikes_NONrun=[];
    nonspikes=[];
    allspikes_run=[]; %for plotting arong LFP signal purpose
    allspikes_NONrun=[]; 
    spikenum_run=0;
    spikenum_NONrun=0;
    LFPspike_run=[];
    LFPspike_NONrun=[];
    for s=1:length(epspikes)
        starttime=epspikes(s);
        [C p]=min(pyrLFP(starttime:starttime+maxdur)); %find the position of min value in this list
        if p==maxdur+1   %this is testing if the backsubLFP window being looked at here is all decending trend, if so, go in nonspikes
            nonspikes=[nonspikes starttime];
        elseif epspikes(s) > length(run_matrix_samplerate) %this it to only focus on track1
            nonspikes=[nonspikes starttime];
        else
            if run_matrix_samplerate(epspikes(s)) == 1 %filter on run vs non_run
        
                    spikenum_run=spikenum_run+1;
                    alepspikes_run=[alepspikes_run starttime+p-1];
                    allspikes_run(spikenum_run,:)=pyrLFP(starttime+p-1-plotaround:starttime+p-1+plotaround);
                    LFPspike_run(:,:,spikenum_run)=LFP(:,(starttime+p-1-plotaround)/25:(starttime+p-1+plotaround)/25);

            elseif run_matrix_samplerate(epspikes(s)) == 0
                    spikenum_NONrun=spikenum_NONrun+1;
                    alepspikes_NONrun=[alepspikes_NONrun starttime+p-1];
                    allspikes_NONrun(spikenum_NONrun,:)=pyrLFP(starttime+p-1-plotaround:starttime+p-1+plotaround);
                    LFPspike_NONrun(:,:,spikenum_NONrun)=LFP(:,(starttime+p-1-plotaround)/25:(starttime+p-1+plotaround)/25);
            end
        end
    end
    
    spikenum_total = spikenum_run + spikenum_NONrun;
    alepspikes_total = [alepspikes_run alepspikes_NONrun];

    non=length(nonspikes);
    noise=length(noisespike);
    t=-plotaround_sec:1/samplingrate:plotaround_sec;  


    spikenum_totalave = spikenum_total/(length(run_matrix)/60); %epi spk / min
    spikenum_runave = spikenum_run/(length(run_matrix)/60); %epi spk / min
    spikenum_NONrunave = spikenum_NONrun/(length(run_matrix)/60); %epi spk / min
    if group == '3wC' | group == '8wC'
        groupc_total(count_c) = spikenum_totalave;
        groupc_run(count_c) = spikenum_runave;
        groupc_NONrun(count_c) = spikenum_NONrunave;
        count_c = count_c + 1;
    elseif group == '3wP'
        group3wp_total(count_3wp) = spikenum_totalave;
        group3wp_run(count_3wp) = spikenum_runave;
        group3wp_NONrun(count_3wp) = spikenum_NONrunave;
        count_3wp = count_3wp + 1;
    elseif group == '8wP'
        group8wp_total(count_8wp) = spikenum_totalave;
        group8wp_run(count_8wp) = spikenum_runave;
        group8wp_NONrun(count_8wp) = spikenum_NONrunave;
        count_8wp = count_8wp + 1;
    end
disp(['dine with animal ' animal])

    %% plot

%     figure;
%     for s = 1:length(alepspikes_run)
%         stime=alepspikes_run(s);
%         hold on
%         plot((t),pyrLFP(stime-plotaround:stime+plotaround),'Color',[0.5 0.5 0.5 0.25])
%     end
%     mspike=mean(allspikes_run,1);
%     sdepspikes=std(allspikes_run,[],1);
%     medspike=median(allspikes_run,1);
%     hold on
%     if spikenum_run ~= 0
%         fill_plot(t,mspike,sdepspikes/sqrt(length(alepspikes_run)),'r');
%     end
%     axis tight
%     ylabel({'Average';'Epileptic Spike'},'Fontsize',20)
%     xlabel('Time (s)','Fontsize',20)
%     title({['Animal: ' animal];['total spikes:' num2str(length(alepspikes_run))]});
%     hold off
% 
%     savename = append(group, '_', animal, '_EpilepticSpk');
%     saveas(gca, fullfile(savepath, savename), 'png');
%     save([exp_dir '\' animal '_epileptic_spikesonlyneg_shank' num2str(shank) '.mat'] ,'spikenum_run', 'alepspikes_run', 'mspike', 'sdepspikes', 'allspikes_run','LFPspike_run');
%     clear spikenum_run alepspikes_run mspike sdepspikes medspike allspikes_run LFPspike_run t;
%     disp(['Done with animal ' animal])


end

groupc(:,1) =  groupc_total;
groupc(:,2) =  groupc_run;
groupc(:,3) =  groupc_NONrun;
group3wp(:,1) =  group3wp_total;
group3wp(:,2) =  group3wp_run;
group3wp(:,3) =  group3wp_NONrun;
group8wp(:,1) =  group8wp_total;
group8wp(:,2) =  group8wp_run;
group8wp(:,3) =  group8wp_NONrun;

writematrix(groupc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\EpilepticSpike\runNonrun\group_C.csv', 'Delimiter', ',')
writematrix(group3wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\EpilepticSpike\runNonrun\group_3wP.csv')
writematrix(group8wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\EpilepticSpike\runNonrun\group_8wP.csv')