function getMUAfullLV_SF(animal,shank,threshold)

    exp_dir=get_exp(animal);
    ana_dir = get_ana(animal);

    load([ana_dir '\probe_data\ECHIP512.mat']); %get probe layout
    load([ana_dir '\filters\filt_600_6000.mat']); %get filter to isolate high frequencies
    b=filt1.tf.num;
    a=filt1.tf.den;
    
  
    %%shank = 3 %I assign in the meanpipeline. pick best shank, change depending on the recording/animal, make this a function input later
   %%threshold = -20 %more negative than -20 in filtered data, make this function input later
    %load([exp_dir 'LFP\BackSub\LFPvoltage_ch' num2str(65) '.mat']);
    load([exp_dir 'LFP\Backsub\LFPvoltage_ch2.mat']); %try the raw full data, also  %load up an random channel just to get the dimension - Susie
    full_spikes_per_bin = zeros(64, round(length(LFPvoltage)/3000000)); %make a matrix with 64 rows and columns with number of 2 min bins in recording

    shankchs=probelayout(:,shank); 
    %ch = 31;
    for ch=1:64  %1:64 
        rawch=shankchs(ch); %convert to real channel number
        %load([exp_dir 'LFP\Full\LFPvoltage_ch' num2str(rawch) '.mat']);
        load([exp_dir 'LFP\BackSub\LFPvoltage_ch' num2str(rawch) '.mat']);%load LFP for this channel %11 seconds
        LFPvoltage=double(LFPvoltage(round(1:end)));  %convert to double
        LFPvoltage_filtered=filtfilt(b,a,LFPvoltage); %filter

        spikes=false(1,length(LFPvoltage_filtered)); %make array of zeroes the length of the signal 
        indx =1; 
        while indx < length(LFPvoltage_filtered) %go through each sample and find anywhere there is a spike
             %spikes(indx) = LFPvoltage_filtered(indx)<=threshold;  %change value to TRUE whenever voltage goes below a threshold
             spikes(indx) = abs(LFPvoltage_filtered(indx))>=threshold; 
             if spikes(indx) == 1
             indx = indx + 50; %after a spike is registered, skip forward 2ms (50 samples)
             elseif spikes(indx) == 0
             indx = indx + 1; %if not a spike, go to next sample 
             end
        end
        n=0;
        r=1;
        lastbin = size(full_spikes_per_bin,2);
        for bin = 1:size(full_spikes_per_bin,2) % for each minute in recording 
             if bin < lastbin  %if not last minute of data
             data = spikes(n*3000000+1:r*3000000); %set 2 minute time window
             %data = spikes((n*4500000)+1 : r*4500000); %set 3 minute time window
             %for 1min bin: first bin 1:1500000, second bin 1500001:3000000, third bin 3000001
             spikes_per_bin = length(find(data));    %count the number of spikes 
             full_spikes_per_bin(ch, r) = spikes_per_bin; %put number in full_spikes_per_min matrix 
             n = n+1;
             r=r+1;
             elseif bin == lastbin %in last bin just go till the end, since this one may be less than a minute long
             data = spikes(n*1500000+1:end);
      
             end
        end
        disp(['done with aniaml ' animal ' channel ' num2str(ch)])
        length(find(spikes))
end
           
save([exp_dir animal '_drift_MEC.mat'], 'full_spikes_per_bin','shank')


