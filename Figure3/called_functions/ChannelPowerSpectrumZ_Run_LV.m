function [powerMat, stdMat, f, f_dim] = ChannelPowerSpectrumZ_Run_LV(startTime, endTime, animal, probetype, minTbin, runflag)
  
%this function finds running bouts in your time frame of interest that are longer than 3 seconds and does power
%calculations on LFP1000 files

%currently assumes that LFPvoltage files contain LFPvoltage_notch|


    fs=1000;
    nfft=1000;
    f_dim = nfft/2+1;


    exp_dir=get_exp(animal); 

  
    load([exp_dir 'stimuli\' animal '_runtimesNEW.mat'], 'run_times'); 
    %finds not running times
    nonrun_times(:,1)=run_times(1:end-1,2);
    nonrun_times(:,2)=run_times(2:end,1);
    nonrun_times(:,3)= nonrun_times(:,2) - nonrun_times(:,1);
    
    %if runflag = true, i.e. you want to stick to only times when mouse was
    %running 
    if runflag
        Bouts = run_times(run_times(:,3)>=minTbin,:); %select only running bouts that exceed minimmum duration (3s by default)
    else
        Bouts = run_times(nonrun_times(:,3)>=minTbin,:); %select only running bouts that exceed minimmum duration (3s by default)
    end

    Bouts = Bouts(Bouts(:,1)>=startTime&Bouts(:,2)<=endTime,:); %select only bouts that occur within specified period
    numBouts = size(Bouts,1);  %finds number of bouts
    
    tBinWidth = minTbin * fs;    %length of bin in samples, 3s = 3000 samples
    numTbin = floor(Bouts(:,3)/minTbin);  %finds the number of 3s time bins in each bout, rounded down
    
    %load probelayout
    if strcmp(animal,'3xTg1-2')
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat');
    else
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');
    end

    
  
    lfp_dir = fullfile(exp_dir,'LFP\LFP1000'); %load LFP file

    [HIPshank, ECshank]=getshankECHIP(animal); 
    shank = HIPshank;
    numChan = length(probelayout(:,shank));

    powerMat = zeros(numChan, f_dim);
    stdMat = zeros(numChan, f_dim);

    

           
    for chi=1:numChan 
        ch=probelayout(chi, shank);
        
       
        load(fullfile(lfp_dir, strcat('LFPvoltage_ch', num2str(ch), '.mat')));

        lfp=LFPvoltage_notch;   
        
        totalBins = sum(numTbin);
        pxx=zeros(totalBins, f_dim);
        
        
        for boutIdx=1:numBouts


            boutStart = uint64(Bouts(boutIdx,1)*fs);
            boutEnd = uint64(Bouts(boutIdx,2)*fs);
            boutLFP = lfp(boutStart:boutEnd);
            
            for tBinIdx=1:numTbin(boutIdx)
                
                tBinStart = (tBinIdx-1)*tBinWidth+1;
                tBinEnd = (tBinIdx)*tBinWidth;
                tBinLFP = boutLFP(tBinStart:tBinEnd);

            
                [pxx(boutIdx,:),f] = periodogram(tBinLFP,hanning(length(tBinLFP)),nfft,fs);       

            end

        end







        powerMat(chi, :) = mean(pxx);%dB;
        stdMat(chi, :) = std(pxx);

 
    end

   

end
