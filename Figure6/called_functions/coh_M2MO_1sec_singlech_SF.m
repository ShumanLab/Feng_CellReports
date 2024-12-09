%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The purpose of this script is to calculate the coh for each sec (or given time frame)
% Bin the recording to 1s bins, calc M2MO coh for each bin

% Note the analysis is retrained in track 1 
% For Pilo and control: whole track 1
% Note this calculation is for the whole track, regardless running or not

% susie 5/3/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Part 1 calc coh for each time bin on track 1
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with M2 and MO
track = '1';

for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    load([ana_dir '\probe_data\ECHIP512.mat'])
    %load([exp_dir '\stimuli\' animal '_runtimesNEW_noseiz.mat']) %I used 3sec version for previous process
    load([exp_dir '\stimuli\position.mat'])
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
    CA1DGshank = CA1DGshank(1);
    MECshank = MECshank(1);

    POSsamplerate = 25000;
    starttime = 1; 
    %find track 1 time
    track1 = find(position == 4);
    track1_end = track1(end);
    track1_end_sec = track1_end/POSsamplerate;
    Fs = 1000; %LFP sample rate

    refch = []; % to collect ch# for MidPyr for all 2 shanks
    shank = [CA1DGshank, MECshank]; %first one for ca1, second one for DG
    badchannel_convert = nan(1,length(badchannels)); %to hold bad ch numbers that will be convert to fit coh matrix
    for i = 1:length(shank)
        if i == 1
            [ch]=getchannels(animal,shank(i));
            refch(i)=round(mean([ch.Mol1 ch.Mol2])); 
            refch_convert = probelayout(refch(i),shank(i));
            if ~isnan(refch)
                refch(i)=refch(i);
                 %deal with if bad ch is refch
                while 1
                     if ~ismember(refch_convert, badchannels)
                         break
                     end
                     refch(i) = refch(i) + 1; %find next ch as ref ch if current on is a bad ch
                     refch_convert = probelayout(refch(i),shank(i));
    
                end
            end
    
        else
            [ch]=getchannels(animal,shank(i));
            refch(i)=round(mean([ch.EC21 ch.EC22]));
            refch_convert = probelayout(refch(i),shank(i));
            if ~isnan(refch)
                refch(i)=refch(i);
                 %deal with if bad ch is refch
                while 1
                     if ~ismember(refch_convert, badchannels)
                         break
                     end
                     refch(i) = refch(i) + 1; %find next ch as ref ch if current on is a bad ch
                    refch_convert = probelayout(refch(i),shank(i));
                end
            end
        end
    end
       
%     fpass1=5;
%     fpass2=12;

    shankCA1DGLFP=load([exp_dir 'LFP\' animal '_shank' num2str(CA1DGshank) '_LFP.mat']);
    shankCA1DGLFP=shankCA1DGLFP.LFP;
    shankMECLFP=load([exp_dir 'LFP\' animal '_shank' num2str(MECshank) '_LFP.mat']);
    shankMECLFP=shankMECLFP.LFP;

    shankCA1DGrefLFP = shankCA1DGLFP(refch(1),:); %MO mid ch
    shankCA1DGrefLFP = shankCA1DGrefLFP(starttime:track1_end_sec*Fs);
    shankMECrefLFP = shankMECLFP(refch(2),:); %MEC2 mid ch
    shankMECrefLFP = shankMECrefLFP(starttime:track1_end_sec*Fs);

  
    LFP=[shankCA1DGrefLFP; shankMECrefLFP];    
    totalchs=length(shank); %the 4 Midpyr ch from 4 HPC shanks

   
    %%%%%%%%%%%%%%%%%%%%%%%%% calc coh %%%%%%%%%%%%%%%%%%%%%%%%%%
    params = struct();
    params.Fs = 1000; %LFP data sampling rate (this is downsampled)
    params.fpass = [5 12];
    params.trialave = 0;
    %params.segave = 0;
    params.tapers=[3 5];
    
    data1 = shankCA1DGrefLFP';
    data2 = shankMECrefLFP';
    win = 1;  %windows in seconds
    
    %%taken from coherencysegc script
    [tapers,pad,Fs,fpass,err,trialave,params]=getparams(params);
    N=check_consistency(data1,data2);
    dt=1/Fs; % sampling interval
    T=N*dt; % length of data in seconds
    E=0:win:T-win; % fictitious event triggers
    win=[0 win]; % use window length to define left and right limits of windows around triggers
    data1=createdatamatc(data1,E,Fs,win); % segmented data 1 %segments data so each column is a window and each row is a sample -LV
    data2=createdatamatc(data2,E,Fs,win); % segmented data 2
 
    [C,phi,S12,S1,S2,f]=coherencyc(data1,data2,params); %C is coh magnitude here
    coh_matrix = mean(C,1);
    disp(['done with ani=' animal]);
    save([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix');
end