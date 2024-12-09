%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function outputs organized units.mat which has firing property of each unit in HPC
%Take all HPC shanks and the assigned MEC shank
%This only takes runtime and non seiz time
%INPUT: 
%1. the output file (cells.m) from phyoutput_SF function
%2. exp.m
%3. runtimesNEW_nosieze1sec.mat
%4. reference channel theta and gamma filtered LFP file
%5. backsub data, channels that is arounf the best ch for each unit
%6. probe file ECHIP512.mat


%OUTPUT: shank_processedunits_run.m (structure) with firing property, output currently into csstorage Y:\Susie\2020\Summer_Ephys_ALL\kilosort\animal

%NOTE: when it comes to which pyr theta phase to use, I will use the same shank’s pyr theta as where the units are coming from. And in terms of which MEC shank to use for HPC to MEC phase locking analysis, I will choose the MEC shank from the initial shank assignment to keep this consistent. 

%Susie 03212022, adapt from TSprocesSpikes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TSprocessSpikes_HPC_runtime_noseiz_SFCopy(animal, shank, track)

[CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
refshankCA1 = CA1DGshank(1); %to pick ref shank on CA1DG shank
refshankMEC = MECshank(1); %to pick ref ch on MEC shank
exp_dir=get_exp(animal);
[ana_dir]=get_ana(animal);
%load spike times
load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '\cells.mat']) %read unit info from cells.m, for now susie only saved unit info in cells.m, not MUA
load([exp_dir '\stimuli\' animal '_runtimesNEW_noseiz1sec.mat']) %run_time matrix is in sec unit
load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
exp_dir=get_exp(animal);
load([exp_dir '\stimuli\position.mat'])

nclusters=size(unit,2);

%% LOAD and save full track data in animalshank_processedunitswholetrack.mat
for c=1:nclusters
    wavesa(c) = unit(c).wavesa;
    wavesasym(c) = unit(c).wavesasym;
    wavesb(c) = unit(c).wavesb;
    wavesc(c) = unit(c).wavesc;   
    CSI(c) = unit(c).CSI;
    meanAClist(c) = unit(c).meanAC;
    FRmeanlist(c) = unit(c).FRmean;
end  %end of cluster
    
%put variebles in unitswholetrack struct
unitswholetrack.CSI=CSI;
unitswholetrack.meanAC=meanAClist;
unitswholetrack.FRmean=FRmeanlist;
unitswholetrack.wavesa = wavesa;
unitswholetrack.wavesasym = wavesasym;
unitswholetrack.wavesb = wavesb;
unitswholetrack.wavesc = wavesc;
save(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat'],'unitswholetrack') %save final units info as shank_units.mat in animal folder under kilosort


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clean spike time HERE to only process spikes during running and non-seize time and save as unit_run in cells.m
%Goal is to align spike time with LFP (theta, gamma phase) time
unit_run = struct(); %copy the unit file as unit_run, and oly modify the unit_run 

%loop through spike time, add the kilot0 time onto spike time
%kilot0 is specific for susie's binary file, as susie sometimes trim recordings before generating binary files
t0 = kilot0 * 25000; %convert from sec to sample (25k)
t1 = kilot1 * 25000;

% %deal with when the first part of recording being cut off. adjust spiketime to the cut
% THIS STEP MOVED TO phyoutput_SF
% for c=1:nclusters
%     unit(c).spiketimesnew = unit(c).spiketimes + t0; %add t0 to all spike times
% end

%adjust run_times base on t0 t1
if t1 ~= 0
    idx = find((run_times(:,1) >= kilot0) & (run_times(:,1) <= kilot1));
    run_times = run_times(idx, :);
end

%loop through spike time and run_times (no seiz), create new spike array that only contains spikes happen during run
run_length = run_times(:,3);
run_times_1plus = run_times(run_length >=1, :); %only run_times longer than 1s - at this point everything is in seconds
%run_times_1plus = round(run_times_1plus*25000); %convert from ffseconds to samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% seperate track1 or 2 spike info and put into unit_run
track2 = find(position == 5); %track1 in position is 0-4, track2 is 4.5-8.5

if ~isempty(track2) %below is for animals with both track1 and 2
        track2_startsec = track2(1)/25000; %this the sec that when I switch to track2
        track2_endsec = track2(end)/25000; %this the sec that when when track2 end, since animal got back on track1 after 2
        runtime_track2_start = find(run_times_1plus(:,1) >= track2_startsec); %find in run_times sheet, where does track2 start
        runtime_track2_start =  runtime_track2_start(1); %index of the row number when track2 start
        runtime_track2_end = find(run_times_1plus(:,2) >= track2_endsec); %find in run_times sheet, where does track2 end. minus 1 here is to handle round error
 
        if ~isempty(runtime_track2_end)
            runtime_track2_end = runtime_track2_end(1); %index of the row number when track2 end
        else %handle when runtime_track2_end is empty (animal stopped running in the end)
             runtime_track2_end = length(run_times_1plus); 
        end
        
        %below is to create new matrix for track1 and 2 run time
        run_times_track1 = run_times_1plus(1:runtime_track2_start,:); %create a new matrix for track1 run time. NOTE currently not handling when add track1 after track2
        run_times_track2 = run_times_1plus(runtime_track2_start:runtime_track2_end,:); %create a new matrix for track 2 run time

        if strcmp(track,'1')==1 %for track1
            run_times = round(run_times_track1*25000); %to handle when the run_times_range is greater than total run time in track1
            totaltime = round(track2_startsec*25000)-t0; %how long animal spend on this track (run + nonrun), account for kilot0 (added -to 0n 7/25)
            totaltimesec = totaltime/25000; %in sec
            totaltime_run = sum(run_times(:,3));
            totaltime_runsec = totaltime_run/25000; %in sec
            totaltime_nonrunsec = totaltimesec - totaltime_runsec;
            totaltime_nonrun = round(totaltime_nonrunsec*25000);

        elseif strcmp(track,'2')==1 %for track2
            run_times = round(run_times_track2*25000);

            if kilot1<track2_endsec && kilot1 ~= 0 %deal with kilot1 is before track2 end
                totaltime = round((kilot1-track2_startsec)*25000);  %how long animal spend on this track (run + nonrun)
            else
                totaltime = round((track2_endsec-track2_startsec)*25000);   %how long animal spend on this track (run + nonrun)
            end
            totaltimesec = totaltime/25000; %in sec
            totaltime_run = sum(run_times(:,3)); %in sample
            totaltime_runsec = totaltime_run/25000; %in sec
            totaltime_nonrunsec = totaltimesec - totaltime_runsec;
            totaltime_nonrun = round(totaltime_nonrunsec*25000);
        end
else %handle animals with no track 2
     if strcmp(track,'2')==1 
          error('Track missing: Current animal doesnt have track2');
     else %calculate track1 when there is no track2 
            track1 = find(position == 4);
            track1_endsec = track1(end)/25000; 
            runtime_track1_end = round(find(run_times(:,1) < track1_endsec));
            runtime_track1_end = runtime_track1_end(end);

            %below is to create new matrix for track1 run time
            run_times_track1 = run_times(1:runtime_track1_end,:);
            if strcmp(track,'1')==1 %for track1
                run_times = run_times_track1(:,:); %to handle when the run_times_range is greater than total run time in track1
                run_times = round(run_times*25000);
                totaltime = round(run_times(runtime_track1_end,2));%how long animal spend on this track (run + nonrun)
                totaltimesec = totaltime/25000; %in sec
                totaltime_run = sum(run_times(:,3));
                totaltime_runsec = totaltime_run/25000; %in sec
                totaltime_nonrunsec = totaltimesec - totaltime_runsec;
                totaltime_nonrun = round(totaltime_nonrunsec*25000);

            end
     end
 end
 run_length = totaltime_runsec;  %update run_length after assign shank
 nonrun_length = totaltime_nonrunsec;  %update run_length after assign shank

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %BREAKDOWN unit.spiketime into track1 and 2; RECONSTRUCT unit_trackx struct with track specific spike info
 if strcmp(track,'1')==1 
     runtimestart = run_times(1,1);
     runtimeend = run_times(end, 2);
     unit_track1 = {};
     for c=1:nclusters
         
         spiketime_track1_end = round(find(unit(c).spiketimesnew(:) <= runtimeend)); %index for at which row the spiketimes reaches to the when rantime track1 end
         if ~isempty(spiketime_track1_end)
             spiketime_track1_end = spiketime_track1_end(end);
             %unit_track1(c).spiketimes = unit(c).spiketimes(1:spiketime_track1_end);
             unit_track1(c).spiketimesnew = unit(c).spiketimesnew(1:spiketime_track1_end);
             unit_track1(c).num_spikes = length(unit_track1(c).spiketimesnew);
             unit_track1(c).cluster_id = unit(c).cluster_id;
             unit_track1(c).highest_chan = unit(c).highest_chan;
             unit_track1(c).amplitudes = unit(c).amplitudes(1:spiketime_track1_end);
            
             for s = 1:length(unit_track1(c).spiketimesnew)
                 for i = 1:length(run_times)
                    if unit_track1(c).spiketimesnew(s) >= run_times(i, 1) && unit_track1(c).spiketimesnew(s) <= run_times(i, 2)
                        unit_track1(c).running_spikes_binary(s) = 1; %set to true
                        break;
                    else
                        unit_track1(c).running_spikes_binary(s) = 0;
                    end
                 end
             end
             unit_track1(c).running_spikes_time =  unit_track1(c).spiketimesnew(unit_track1(c).running_spikes_binary(:) == 1);
             unit_track1(c).running_amplitudes =  unit_track1(c).amplitudes(unit_track1(c).running_spikes_binary(:) == 1);
             unit_track1(c).nonrunning_spikes_time =  unit_track1(c).spiketimesnew(unit_track1(c).running_spikes_binary(:) == 0);
             unit_track1(c).nonrunning_amplitudes =  unit_track1(c).amplitudes(unit_track1(c).running_spikes_binary(:) == 0);
             
         else %handle when cell don't fire at first track at all
             unit_track1(c).spiketimesnew = [];
             unit_track1(c).num_spikes = 0;
             unit_track1(c).cluster_id = unit(c).cluster_id;
             unit_track1(c).highest_chan = unit(c).highest_chan;
             unit_track1(c).amplitudes = [];
         
         end  
     end
    unit = unit_track1; %assign unit_track1 to unit structure

 elseif strcmp(track,'2')==1 %previously already handled when track2 doesn't exsit
     runtimestart = run_times(1,1);
     runtimeend = run_times(end, 2);
     unit_track2 = {};
      for c=1:nclusters
         spiketime_track2_end = round(find(unit(c).spiketimesnew(:) <= runtimeend)); %index for at which row the spiketimes reaches to the when rantime track2 end
         spiketime_track2_end = spiketime_track2_end(end);
         spiketime_track2_start = round(find(unit(c).spiketimesnew(:) >= runtimestart)); %index for at which row the spiketimes reaches to the when rantime track2 end
         
         if ~isempty(spiketime_track2_start)
             spiketime_track2_start = spiketime_track2_start(1);
             %unit_track2(c).spiketimes = unit(c).spiketimes(spiketime_track2_start:spiketime_track2_end);
             unit_track2(c).spiketimesnew = unit(c).spiketimesnew(spiketime_track2_start:spiketime_track2_end);
    
             unit_track2(c).num_spikes = length(unit_track2(c).spiketimesnew); %total spike num include run and nonrun
             unit_track2(c).cluster_id = unit(c).cluster_id;
             unit_track2(c).highest_chan = unit(c).highest_chan;
             unit_track2(c).amplitudes = unit(c).amplitudes(spiketime_track2_start:spiketime_track2_end);
             for s = 1:length(unit_track2(c).spiketimesnew)
                 for i = 1:length(run_times)
                    if unit_track2(c).spiketimesnew(s) >= run_times(i, 1) && unit_track2(c).spiketimesnew(s) <= run_times(i, 2)
                        unit_track2(c).running_spikes_binary(s) = 1; %set to true
                        break;
                    else
                        unit_track2(c).running_spikes_binary(s) = 0;
                     
                    end
                 end
             end
             unit_track2(c).running_spikes_time =  unit_track2(c).spiketimesnew(unit_track2(c).running_spikes_binary(:) == 1);
             unit_track2(c).running_amplitudes =  unit_track2(c).amplitudes(unit_track2(c).running_spikes_binary(:) == 1);
             unit_track2(c).nonrunning_spikes_time =  unit_track2(c).spiketimesnew(unit_track2(c).running_spikes_binary(:) == 0);
             unit_track2(c).nonrunning_amplitudes =  unit_track2(c).amplitudes(unit_track2(c).running_spikes_binary(:) == 0);
         else %handle when cell don't fire at second track at all
             unit_track2(c).spiketimesnew = [];
             unit_track2(c).num_spikes = 0;
             unit_track2(c).cluster_id = unit(c).cluster_id;
             unit_track2(c).highest_chan = unit(c).highest_chan;
             unit_track2(c).amplitudes = [];
         end     
      end %end of clusters

    unit = unit_track2; %assign unit_track2 to unit structure
 end

%%
for c=1:nclusters
    %create unit_run file
    unit_run(c).spiketimes = unit(c).running_spikes_time;
    unit_run(c).num_spikes = length(unit_run(c).spiketimes);
    unit_run(c).cluster_id = unit(c).cluster_id;
    unit_run(c).highest_chan = unit(c).highest_chan;
    unit_run(c).amplitudes = unit(c).running_amplitudes;
    %create unit_nonrun file
    unit_nonrun(c).spiketimes = unit(c).nonrunning_spikes_time;
    unit_nonrun(c).num_spikes = length(unit_nonrun(c).spiketimes);
    unit_nonrun(c).cluster_id = unit(c).cluster_id;
    unit_nonrun(c).highest_chan = unit(c).highest_chan;
    unit_nonrun(c).amplitudes = unit(c).nonrunning_amplitudes;

    %%
    %%%%%%%%%%%%%  UNIT_RUN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bintime = 120; %in sec, consistant across different FR calc

    if ~isempty(unit_run(c).spiketimes) %deal with units with no running spiketimes
       %method 1  calculate the total time that each cluster show decent firing above meanFR. then devided by this time
        FRavg = double(length(unit_run(c).spiketimes)/totaltime_runsec)/10;  %spike/sec
        histbin = round(totaltime_runsec/bintime); %how many bins to break totaltime into 
        if histbin == 0
            histbin = histbin +1;
        else
        end
        %bintime = totaltime_runsec/histbin; %in sec, how many sec for each bin. used in the previous fixed bin number method
        spikebincount = histcounts(unit_run(c).spiketimes,histbin); %spikecount for each bin
        bin = 0; %bin count
        spikecount = 0; % spike count
        for b = 1: histbin %count how many bins have spikecount >= meanFR
            if (spikebincount(b)/bintime)>=FRavg %by doing this, it should get rid of non-run time 
                bin = bin + 1;
                spikecount = spikecount+spikebincount(b);
            end
        end
        totaltime_final = bin * bintime;
        FRmean = spikecount/double(totaltime_final);
        unit_run(c).FRmean = FRmean;
        clear FRmean spikebincount totaltime_final bin 

        % method2 highestFR calc
        histbin = round(totaltime_runsec/bintime); %how many bins to break totaltime into 
         if histbin == 0
            histbin = histbin +1;
        else
        end
        binwd = 1; %inwindow size for each check; was 10 before change bintime to a fixed 120s
        spikebincount = histcounts(unit_run(c).spiketimes,histbin); %spikecount for each bin
        start = 1;
        highest_FR = 0;
        for i = 1:histbin-binwd
            FR = sum(spikebincount(start:start+binwd))/(binwd+1); %spickcount per bin for given window at the moment
            if FR > highest_FR
                highest_FR = FR; %#spike/histbin
            end
            start = start + 1;
        end
        unit_run(c).highest_FR = highest_FR/bintime; %convert to spike/sec
        clear highest_FR binwd spikebincount start
    
        % method3 mFR calc
        unit_run(c).mFR = length(unit_run(c).spiketimes)/totaltime_runsec; %in spike/sec This Susie need to update to fit units that only spike for a certain amount of time 

    else   % deal with empty spiketimes
        unit_run(c).FRmean = nan;
        unit_run(c).highest_FR = nan;
        unit_run(c).mFR = nan;
    end

 %%%%%%%%%%%%%  UNIT_NONRUN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(unit_nonrun(c).spiketimes) %deal with units with no running spiketimes
        %method1
        FRavg = double(length(unit_nonrun(c).spiketimes)/totaltime_nonrunsec)/10;  %spike/sec;  
        histbin = round(totaltime_nonrunsec/bintime); %how many bins to break totaltime into 
         if histbin == 0
            histbin = histbin +1;
        else
        end
        spikebincount = histcounts(unit_nonrun(c).spiketimes,histbin);
        bin = 0;
        spikecount = 0; % spike count

        for b = 1: histbin %count how many bins have spikecount >= meanFR
            if (spikebincount(b)/bintime)>=FRavg %by doing this, it should get rid of non-run time 
                bin = bin + 1;
                spikecount = spikecount+spikebincount(b);
            end
        end
        totaltime_final = bin * bintime; %sec
        FRmean = spikecount/double(totaltime_final);
        unit_nonrun(c).FRmean = FRmean;
        clear FRmean spikebincount totaltime_final bin

       %method2
        histbin = round(totaltime_nonrunsec/bintime); %how many bins to break totaltime into
         if histbin == 0
            histbin = histbin +1;
        else
        end
        spikebincount = histcounts(unit_nonrun(c).spiketimes,histbin); %spikecount for each bin
        binwd = 1; %inwindow size for each check; was 10 before change bintime to a fixed 120s
        start = 1;
        highest_FR = 0;
        for i = 1:histbin-binwd
            FR = sum(spikebincount(start:start+binwd))/(binwd+1); %spickcount per bin for given window at the moment
            if FR > highest_FR
                highest_FR = FR; %#spike/histbin
            end
            start = start + 1;
        end
        unit_nonrun(c).highest_FR = highest_FR/bintime; %convert to spike/sec
        clear highest_FR binwd spikebincount start
    
        %method3
        unit_nonrun(c).mFR = length(unit_nonrun(c).spiketimes)/totaltime_nonrunsec; 
    else
        unit_nonrun(c).FRmean = nan;
        unit_nonrun(c).highest_FR = nan;
        unit_nonrun(c).mFR = nan;
    end

%%%%%%%%%%%%%  UNIT_TOTALL (run + nonrun)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(unit(c).spiketimesnew) %deal with units with no running spiketimes
        %method1
        FRavg = double(length(unit(c).spiketimesnew)/totaltimesec)/10;  %spike/sec
        histbin = round(totaltimesec/bintime); %how many bins to break totaltime into 
         if histbin == 0
            histbin = histbin +1;
        else
        end
        spikebincount = histcounts(unit(c).spiketimesnew,histbin);
        bin = 0;
        spikecount = 0; % spike count
        for b = 1: histbin %count how many bins have spikecount >= meanFR
            if (spikebincount(b)/bintime)>=FRavg %by doing this, it should get rid of non-run time 
                bin = bin + 1;
                spikecount = spikecount+spikebincount(b);
            end
        end
        totaltime_final = bin * bintime; %sec
        FRmean = spikecount/double(totaltime_final);
        unit(c).FRmean = FRmean;
        clear FRmean spikebincount totaltime_final bin 

       %method2
        histbin = round(totaltimesec/bintime); %how many bins to break totaltime into 
         if histbin == 0
            histbin = histbin +1;
        else
        end
        binwd = 1; %step size for each check
        spikebincount = histcounts(unit(c).spiketimesnew,histbin); %spikecount for each bin
        start = 1;
        highest_FR = 0;
        for i = 1:histbin-binwd
            FR = sum(spikebincount(start:start+binwd))/(binwd+1); %spickcount per bin for given window at the moment
            if FR > highest_FR
                highest_FR = FR; %#spike/histbin
            end
            start = start + 1;
        end
        unit(c).highest_FR = highest_FR/bintime; %convert to spike/sec
        clear highest_FR binwd spikebincount start
    
        %method3
        unit(c).mFR = length(unit(c).spiketimesnew)/totaltimesec; %in spike/sec This Susie need to update to fit units that only spike for a certain amount of time 

    else
        unit(c).FRmean = nan;
        unit(c).highest_FR = nan;
        unit(c).mFR = nan;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save the new cells.mat after updating it to only runtimes
save(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '\cells_track' track '.mat'],'unit_run' , 'unit_nonrun', 'unit') %save new unit file into cells.mat after these updates
%NOTE: everything down below is for unit_run. But the unit_nonrun could be pull up directly from the saved file to do nonrun analysis!





%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '\cells_track' num2str(track) '.mat'],'unit_run') %save new unit file after these updates
% nclusters = length(unit_run);
spikes={};
numspikes=[];
clustch=[];
for c=1:nclusters
    spikes{c}=unit_run(c).spiketimes; %each element in spikes contains all the spike times for a given cluster
    numspikes(c)=length(unit_run(c).spiketimes);  %same with number of spikes
    clusterch(c)=unit_run(c).highest_chan;  %and highest chan
end
[correctch] = kilo_badchmap2_SF(animal, shank, clusterch); %fix channel number here by map the correct channels


%for each cell make a mean trace, autocorrelation, ISI distribution, mean waveforms, phase locking
meanAC=[];
auto={};
burst=[];
mISI=[];
burstbw=[];

CA1thetaPL={};
CA1gammaPL={};
MECIIthetaPL={};
MECIIgammaPL={};
DGthetaPL={};
DGgammaPL={};

waveforms={};

FRmean = [];
highestFR = [];
mFR = [];

refravio = [];
for c=1:nclusters %loop through all clusters this shank has
     if ~isempty(unit_run(c).spiketimes) %deal with units with no running spiketimes
        FRmean(c) = unit_run(c).FRmean;
        highestFR(c) = unit_run(c).highest_FR;
        mFR(c) = unit_run(c).mFR;
    
        spk=double(spikes{c});  %in samples, 25k hz, input for phaselockunitLV_SF(spk,filt_data)
        spks=spk/25000; %in seconds
    
        autocorr=[];
        %autocorrelation, which is the distribution of all intervals from spike 1 to spike that happen 250ms away in this case.
            for s=1:length(spks) %for each spiketime 
                ds=spks-spks(s); %get all other spike times relative to that spiketime
                autospikes=ds(ds>0 & ds<0.25); %0 to 250ms
                autocorr=[autocorr; autospikes]; %adds those spike times to autocorr
            end
    
        auto{c}=autocorr;  %puts autocorr matrix in the slot for this cluster
        meanAC(c)=mean(autocorr); %smaller mean is more likely to be exc cell, bc of bursty
    
        ISI=diff(spks); %calculates differences between adjacent spiketimes for this cluster 
        mISI(c)=mean(ISI(ISI<0.25));  %calculates average time between spikes for all spikes that are within 250ms of the last one
        burst(c)=sum(ISI<0.005)/sum(ISI<.3 & ISI>.2); %as in Senzai and Buzsaki 2017, higher bursty more likely to be exc cell
    
        %calc refrac violation -SF added base on https://www.princeton.edu/~wbialek/rome/refs/segev+al_04.pdf
        refravio(c) = (sum(ISI<=0.002)/length(spk))*100;
    
        %other way - adapt from Lauren%%%%%%%%%%%%%%%%%%%%%%%
        %bwillers defines burst index as percentage of spikes that occur within 20ms of the previous one 
        burstbw(c) = sum(ISI<0.020)/length(spk);    %not sure if this is right - might need to only include a subset of these
    
        %add a mean amplitude value
        %% 
        mAmp(c) = mean(unit_run(c).amplitudes);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %below are units from HPC shanks (using pyr mid layer to calc phase locking)
        %phaselock to CA1
    
         %loop through all HPC shank, here is just to find Mid Pyr for each shank
        [chref]=getchannels(animal,shank);
        refch=chref.MidPyr;
        load([ana_dir '\probe_data\ECHIP512.mat'])
        CA1refch=probelayout(refch,refshankCA1);
        %deal with if bad ch is refch
        while 1
             if ~ismember(CA1refch, badchannels)
                 break
             end
             refch = refch + 1; %find next ch as ref ch if current on is a bad ch
             CA1refch=probelayout(refch,refshankCA1);
        end
        load([exp_dir '\LFP\theta\LFPvoltage_ch' num2str(CA1refch) 'theta.mat']); %loads filt_data
        [PL]=phaselockunitLV_SF(spk,filt_data);
        %figure; polarhistogram(PL.spike_rad,18) %quick plot of PL of each unit to theta
        CA1thetaPL{c}=PL;
        load([exp_dir '\LFP\gamma\LFPvoltage_ch' num2str(CA1refch) 'gamma.mat']); %loads filt_data
        [PL]=phaselockunitLV_SF(spk,filt_data);
        CA1gammaPL{c}=PL;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %phaselock to DG
    
         %loop through all HPC shank, here is just to find Mid Pyr for master CA1DGshank
        [chref]=getchannels(animal,refshankCA1);
        refch=round(mean([chref.Hil1 chref.Hil2]));
        load([ana_dir '\probe_data\ECHIP512.mat'])
        DGrefch=probelayout(refch,refshankCA1);
        %deal with if bad ch is refch
        while 1
             if ~ismember(DGrefch, badchannels)
                 break
             end
             refch = refch + 1; %find next ch as ref ch if current on is a bad ch
             DGrefch=probelayout(refch,refshankCA1);
        end
        load([exp_dir '\LFP\theta\LFPvoltage_ch' num2str(DGrefch) 'theta.mat']); %loads filt_data
        [PL]=phaselockunitLV_SF(spk,filt_data);
        
        DGthetaPL{c}=PL;
        load([exp_dir '\LFP\gamma\LFPvoltage_ch' num2str(DGrefch) 'gamma.mat']); %loads filt_data
        [PL]=phaselockunitLV_SF(spk,filt_data);
        DGgammaPL{c}=PL;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %below is MECshank (using MECII specifically)
        [chref]=getchannels(animal,refshankMEC);
        refch=chref.EC21; %use top MECII ch as ref ch
        if ~isnan(refch)
            MECIIrefch=probelayout(refch,refshankMEC);
             
            while 1 %deal with if bad ch is refch
                 if ~ismember(MECIIrefch, badchannels)
                     break
                 end
                 refch = refch + 1; %find next ch as ref ch if current on is a bad ch
                 MECIIrefch=probelayout(refch,refshankMEC);
            end
            load([exp_dir '\LFP\theta\LFPvoltage_ch' num2str(MECIIrefch) 'theta.mat']); %loads filt_data
            [PL]=phaselockunitLV_SF(spk,filt_data);
       
            MECIIthetaPL{c}=PL;
            load([exp_dir '\LFP\gamma\LFPvoltage_ch' num2str(MECIIrefch) 'gamma.mat']); %loads filt_data
            [PL]=phaselockunitLV_SF(spk,filt_data);
            MECIIgammaPL{c}=PL;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %spike waveform calculation- using backsub data not kilo output, since kilosort data only has spiketiming and amp, not waveform
        %Susie 
        bestch=correctch(c);
    
        chset=bestch-3:bestch+3;  %get 6 channel range around highest channel for each cluster
        chset=chset(chset>0 & chset<65); %get around the top and bottom ch
        realchset=probelayout(chset,shank); %will need to replace with current shank
    
        spikelim=1000;
        if length(spk)<spikelim
            spikelim=length(spk); % - 1; %susie add -1 here to account for index exceeds array error, since need to add 25000 to last spike
        end
        lastspike=spk(spikelim);
        prespike=25; %samples, 1 ms before
        postspike=25; %samples, 1 ms after
        chspikes=zeros(spikelim,prespike+postspike,length(realchset));
    
        filt_dir=[ana_dir '\filters\'];
        load([filt_dir 'filt_600_6000.mat']);
        bf=filt1.tf.num;
        af=filt1.tf.den;
    
        for r=1:length(realchset) %Susie: we are doing the waveform calculation base on backsub data instead of kilosort output since the latter doesn't have waveform info
            load([exp_dir '\LFP\BackSub\LFPvoltage_ch' num2str(realchset(r)) '.mat']); %loads backsub
            LFPvoltage=double(LFPvoltage);
            if length(LFPvoltage) >= lastspike+25000
                filt_data=filtfilt(bf,af,LFPvoltage(1:lastspike+25000));   % +25000 to buffer for the filter, reduce edge effect
            else
                filt_data=filtfilt(bf,af,LFPvoltage);   
            end
    
            for s=1:spikelim
                t0=spk(s)-prespike+1;
                t1=spk(s)+postspike;
                chspikes(s,:,r)=filt_data(t0:t1);
            end
        end
    
        %24 samples should be working fine here
    
        mspikes=squeeze(mean(chspikes,1));
        [M I]=max(max(abs(mspikes))); %finds max values M and their indices I 
        wave=mspikes(:,I); %best waveform
        a2=max(wave(prespike-24:prespike))-wave(prespike-24);
        b2=max(wave(prespike:prespike+24))-wave(prespike+24);
        [~, bi]=max(wave(prespike+1:prespike+24));
        c2=(bi-1)/25; %trough to peak latency
        asym=(b2-a2)/(b2+a2);
    
        waves.asym=asym;
        waves.a=a2;
        waves.b=b2;
        waves.c=c2;
        waves.chspikes=chspikes;
        waves.realchset=realchset;
        waves.spikelim=spikelim;
        waves.mspikes=mspikes;
        waves.wave=wave;
    
        waveforms{c}=waves;
    
        %interneurons tend to have b>a and c<0.3 (Mizuseki 2009)
        %below to vis actocorr
        % autocorr=[-autocorr; autocorr];
        % figure; hist(autocorr,10000)
        
        %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Calculate CSI (complex spike index) for each cell/cluster - adapt from Lauren script
        
        %(CSI) is defined as the percentage of spikes within a burst that exhibit amplitude decay
        %minus the percentage of spikes within a burst that exhibit an increase in amplitude relative
        %to their predecessor. For cells which do not exhibit complex spiking, such as the inhibitory
        %interneurons near CA1, the CSI will typically be close"
    
        %burst index of a cluster as the percentage of spikes that occur within 20 ms of their predecessor. The complex spike index
    
        %CSI calc logic:
        %find spike amplitudes
                %for each spike time find spiketimes in the following 20s
                %get unit.amplitudes
        diff_amp=[];
        i = 1;
        spikelim=2000;
        
        if length(spk)<spikelim
            spikelim=length(spk); 
        end

        for sp=1:length(spikelim) %for each spiketime in the cluster
            ds=spks-spks(sp); %get all other spike times relative to that spiketime
            for d=2:length(ds)
                if ds(d) > 0 && ds(d) <0.02  %find spiketimes within 20ms (0.02s) %should I change this so it only finds the first instance?
                amp = unit_run(c).amplitudes(d); %get amplitude for that spike time
                amp_prev = unit_run(c).amplitudes(d-1); %get amplitude of previous spike
                diff_amp(i) = amp - amp_prev;  %store the difference between the amplitude of the previous and current spike
                i = i + 1; %add one to index 
                end
            end
        end  %done with all spiketimes for the cluster
        pos_amp=find(diff_amp>0);
        neg_amp=find(diff_amp<0);
        zero_amp=find(diff_amp==0);
        up = (length(pos_amp)/length(diff_amp))*100; %get ratio of spikes that decrease their amplitude
        down = (length(neg_amp)/length(diff_amp))*100; %get ratio of spikes that increase their amplitude
        CSI(c) = down-up; %subtract to get CSI 
    
    
        disp(['done with cluster' num2str(c) 'for animal ' animal 'at shank ' num2str(shank)])
    else
        disp(['EMPTY spike cluster ' num2str(c) 'for animal ' animal 'at shank ' num2str(shank)])
    end
end

units.meanAC=meanAC;
units.auto=auto;
units.burst=burst;
units.burstbw = burstbw;
units.mISI=mISI;
units.CSI = CSI;
units.CA1thetaPL=CA1thetaPL;
units.CA1gammaPL=CA1gammaPL;
units.MECIIthetaPL=MECIIthetaPL;
units.MECIIgammaPL=MECIIgammaPL;
units.DGthetaPL=DGthetaPL;
units.DGgammaPL=DGgammaPL;
units.waveforms=waveforms;
units.spikes=spikes;
units.numspikes=numspikes;
units.clusterch=clusterch;
units.correctclusterch = correctch;
units.mAmp = mAmp;
units.FRmean = FRmean;
units.highestFR = highestFR;
units.mFR = mFR;
units.refravio = refravio;

save(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' track '.mat'],'units') %save final units info as shank_units.mat in animal folder under kilosort
disp(['Done with animal ' animal 'for shank ' num2str(shank)])


clear all
end