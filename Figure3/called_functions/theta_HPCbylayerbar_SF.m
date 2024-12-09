%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is to plot PSD by sublayer, by taking the fft of each ch and
% ave accross ch for each layer. Each animal represented by one line for
% one layer
% INPUTS: animals, chloc, LFP1000
% OUTPUTS: HPC_Freq_bylayer.mat; PSD plot by group by layer; PSD theta frequency bar plot
% by changing the freq range, gamma plotting can use this same plot
% Susie 9/29/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% organize data structure
%% below is all animal list without control seizing  (110-0, 117-4, 113-3)
%layer = 'Or';
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment

groupc = [];
group3wp = [];
group8wp = [];
group_ind = {};
count_c = 1;
count_3wp = 1;
count_8wp = 1;
for a = 1:length(animals)
    
    animal = animals(a);
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
    shank = CA1DGshank(1);
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir '\exp.mat'])
    load([exp_dir '\stimuli\' animal '_runtimesNEW_noseiz1sec.mat']) %run_time matrix is in sec unit
    load([exp_dir '\stimuli\position.mat'])
    load([ana_dir '\probe_data\ECHIP512.mat']) %note probe layout is upside down of a probe. eg; 1st row in probelayout is actually ch #1 on probe which is the bottom tip of the probe physically
    load([exp_dir 'LFP\' animal '_shank' num2str(shank) '_LFP.mat']) %run_time matrix is in sec unit
    [channel]=getchannels(animal,shank); %pick CA1DGshank to figure out group info since every animal has it
    group_ind{a} = group;
    PSDmat = nan(64,500); %create matrix hold PSD data for this animal
    PSDmatbylayer = nan(7,500); %take ave of PSD data for each layer
    %lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');
% fft for each channel
    for ch=1:length(LFP(:,1))
        PSD2 = [];
        %data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'], 'LFPvoltage_notch');
        %data = data.LFPvoltage; %to handle ones already have notch file
        data = LFP(ch, :);
% sort out only run time in LFP
        run_length = run_times(:,3);
        run_times_3plus = run_times(run_length >=3, :); %only run_times longer than 3s
        run_times_1000hz = round(run_times_3plus*1000); %convert to numbers that will match up with LFP1000 files
        runidx = zeros(length(data),1);  % T/F matrix   %rename this 
        for i=1:length(data)   %for each time point in LFP1000
            for time_window = 1:length(run_times_1000hz)  %go through each time window in run times
                if i >= run_times_1000hz(time_window, 1) && i <= run_times_1000hz(time_window, 2) %check if that time point falls within that time window
                    runidx(i, 1) = 1;  %set to 1;
                    continue
                else
                end
            end
        end
 % fft for each channel
        data = data(runidx == 1); %only get LFP data points that are happening during running bins 
        
        Fs =1000;  % Sampling frequency (1kHz) 
        %data = struct2cell(data);
        %data = cell2mat(data);
        L = length(data(1,:)); % Length of signal 
        t = (0:L-1)*(1/Fs);   % Time vector (in sec)
        
        Y = fft(data); %fourier transform
        PSD = abs(Y/L); %normalize by length of data
        PSD = PSD(:,1:L/2+1);  
        PSD(:,2:end-1) = 2*PSD(:,2:end-1);  
        f = Fs*(0:(L/2))/L; 

        [X,f2] = discretize(f,500); %make this into 500 bins
         
        for i=1:500
             idx = find(X==i);
             first = idx(1);
             last = idx(end);
             PSDi = mean(PSD(first:last));
             PSD2 = [PSD2 ;PSDi];
        end
        PSD2 = PSD2';
        PSDmat(ch,:) = PSD2;
        clear PSD2;
        disp(['Done with animal ' animal ' ch ' num2str(ch)])

    end
% ave accross ch in the same layer
    if ~isempty(channel.Or1) && ~isempty (channel.Or2)  
        PSDmatbylayer(1,:) = nanmean(PSDmat(channel.Or2:channel.Or1,:));
    end
    if ~isempty(channel.Pyr1) && ~isempty (channel.Pyr2)  
        PSDmatbylayer(2,:) = nanmean(PSDmat(channel.Pyr2:channel.Pyr1,:));
    end
    if ~isempty(channel.Rad1) && ~isempty (channel.Rad2)  
        PSDmatbylayer(3,:) = nanmean(PSDmat(channel.Rad2:channel.Rad1,:));
    end
    if ~isempty(channel.LM1) && ~isempty (channel.LM2)  
        PSDmatbylayer(4,:) = nanmean(PSDmat(channel.LM2:channel.LM1,:));
    end
    if ~isempty(channel.Mol1) && ~isempty (channel.Mol2)  
        PSDmatbylayer(5,:) = nanmean(PSDmat(channel.Mol2:channel.Mol1,:));
    end
    if ~isempty(channel.GC1) && ~isempty (channel.GC2)  
        PSDmatbylayer(6,:) = nanmean(PSDmat(channel.GC2:channel.GC1,:));
    end
    if ~isempty(channel.Hil1) && ~isempty (channel.Hil2)  
        PSDmatbylayer(7,:) = nanmean(PSDmat(channel.GC2:channel.GC1,:));
    end
     
    if group == '3wC' | group == '8wC'
        groupc(:,:,count_c) = PSDmatbylayer;
        count_c = count_c + 1;
    elseif group == '3wP'
        group3wp(:,:,count_3wp) = PSDmatbylayer;
        count_3wp = count_3wp + 1;
    elseif group == '8wP'
        group8wp(:,:,count_8wp) = PSDmatbylayer;
        count_8wp = count_8wp + 1;
    end
    disp(['Done with animal ' animal])

end
%% save the data
freqdir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Frequency\';
if exist(freqdir)==0
    mkdir(freqdir)
end
save([freqdir '\HPC_Freq_bylayer.mat'],'groupc' ,'group3wp' ,'group8wp' );  

%% plot by group
freqdir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Frequency\';
load([freqdir '\HPC_Freq_bylayer.mat'],'groupc' ,'group3wp' ,'group8wp' ); 
%% normalize the power number
for i = 1:size(groupc,1)
    for m = 1:size(groupc,3)
        groupc_norm(i,:,m) = (groupc(i,:,m)-min(groupc(i,:,m)))/(max(groupc(i,:,m))-min(groupc(i,:,m)));
    end
end
for i = 1:size(group3wp,1)
    for m = 1:size(group3wp,3)
        group3wp_norm(i,:,m) = (group3wp(i,:,m)-min(group3wp(i,:,m)))/(max(group3wp(i,:,m))-min(group3wp(i,:,m)));
    end
end
for i = 1:size(group8wp,1)
    for m = 1:size(group8wp,3)
        group8wp_norm(i,:,m) = (group8wp(i,:,m)-min(group8wp(i,:,m)))/(max(group8wp(i,:,m))-min(group8wp(i,:,m)));
    end
end
groupc = groupc_norm;
group3wp = group3wp_norm;
group8wp = group8wp_norm;

figure('Renderer', 'painters', 'Position', [10 10 500 1400])
% or
h(1) = subplot(7,1,1);
for i = 1:size(groupc,3)
    PSD = groupc(1,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(1,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(1,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(1,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(1,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(1,:), 'Color', [0.4,0,0], 'LineWidth',3);

% xticks([1 9 18 27 36]);
% xticklabels({ '0' '180' '360' '540' '720'});  
%  yticks([0 0.1 0.2 0.3 0.4]);
%  yticklabels({ '0' '0.1' '0.2' '0.3' '0.4'});  
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - Or')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

% pyr
h(2)=subplot(7,1,2);
for i = 1:size(groupc,3)
    PSD = groupc(2,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(2,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(2,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(2,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(2,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(2,:), 'Color', [0.4,0,0], 'LineWidth',3);
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - Pyr')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

% Rad
h(3)=subplot(7,1,3);
for i = 1:size(groupc,3)
    PSD = groupc(3,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(3,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(3,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(3,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(3,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(3,:), 'Color', [0.4,0,0], 'LineWidth',3);
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - Rad')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

% LSM
h(4)=subplot(7,1,4);
for i = 1:size(groupc,3)
    PSD = groupc(4,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(4,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(4,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(4,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(4,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(4,:), 'Color', [0.4,0,0], 'LineWidth',3);
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - LSM')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

% MO
h(5)=subplot(7,1,5);
for i = 1:size(groupc,3)
    PSD = groupc(5,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(5,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(5,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(5,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(5,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(5,:), 'Color', [0.4,0,0], 'LineWidth',3);
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - Mol')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

% GC
h(6)=subplot(7,1,6);
for i = 1:size(groupc,3)
    PSD = groupc(6,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(6,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(6,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(6,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(6,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(6,:), 'Color', [0.4,0,0], 'LineWidth',3);
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - GC')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

% Hil
h(7)=subplot(7,1,7);
for i = 1:size(groupc,3)
    PSD = groupc(7,:,i);
    plot(PSD,'Color',[0,0.5,0.7,0.2],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group3wp,3)
    PSD = group3wp(7,:,i);
    plot(PSD,'Color',[1,0.5,0.5,0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
for i = 1:size(group8wp,3)
    PSD = group8wp(7,:,i);
    plot(PSD,'Color',[0.1, 0.1, 0.1, 0.3],  'LineStyle','-', 'LineWidth',0.25)
    hold on
end
groupc_mat = nanmean(groupc,3);
group3wp_mat = nanmean(group3wp,3);
group8wp_mat = nanmean(group8wp,3);
PSD_c = plot(groupc_mat(7,:), 'Color', [0,0.3,0.7], 'LineWidth',3);
PSD_3wp = plot(group3wp_mat(7,:), 'Color', [1,0.5,0.5], 'LineWidth',3);
PSD_8wp = plot(group8wp_mat(7,:), 'Color', [0.4,0,0], 'LineWidth',3);
ylabel('Normalized Power (AU)');
xlabel('Frequency (Hz)');
title('HPC - Hil')
legend( [PSD_c PSD_3wp PSD_8wp], 'control', '3wp', '8wp');

linkaxes(h)
xlim([5 12])
%ylim([0 0.4])


%% take freq with highest power for theta/gamma range for each layer and each animal
groupc_freq_2D = nan(size(groupc,1),size(groupc,3));
for i = 1:size(groupc,1)
    for m = 1:size(groupc,3)
        maxval = max(groupc_norm(i,5:12,m));
        freq = find(groupc(i,:,m) == maxval);
        if ~isempty(freq)
            groupc_freq_2D(i,m) = freq;
        else
            groupc_freq_2D(i,m) = nan;
        end
    end
end

group3wp_freq_2D = nan(size(group3wp,1),size(group3wp,3));
for i = 1:size(group3wp,1)
    for m = 1:size(group3wp,3)
        maxval = max(group3wp_norm(i,5:12,m));
        freq = find(group3wp(i,:,m) == maxval);
        if ~isempty(freq)
            group3wp_freq_2D(i,m) = freq;
        else
            group3wp_freq_2D(i,m) = nan;
        end
    end
end

group8wp_freq_2D = nan(size(group8wp,1),size(group8wp,3));
for i = 1:size(group8wp,1)
    for m = 1:size(group8wp,3)
        maxval = max(group8wp_norm(i,5:12,m));
        freq = find(group8wp(i,:,m) == maxval);
        if ~isempty(freq)
            group8wp_freq_2D(i,m) = freq;
        else
            group8wp_freq_2D(i,m) = nan;
        end
    end
end

%% plot in bar plot for freq with highest power
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Frequency\';
if exist(savepath)==0
     mkdir(savepath);
end
% Or 
data = {groupc_freq_2D(1,:), group3wp_freq_2D(1,:), group8wp_freq_2D(1,:)}; %data use for plot and stats
title_name = 'HPC-Or Frequency Across Groups';
scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);

% Pyr 
data = {groupc_freq_2D(2,:), group3wp_freq_2D(2,:), group8wp_freq_2D(2,:)}; %data use for plot and stats
title_name = 'HPC-Pyr Frequency Across Groups';
scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);

% Rad
data = {groupc_freq_2D(3,:), group3wp_freq_2D(3,:), group8wp_freq_2D(3,:)}; %data use for plot and stats
title_name = 'HPC-Rad Frequency Across Groups';
scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);

% LSM 
data = {groupc_freq_2D(4,:), group3wp_freq_2D(4,:), group8wp_freq_2D(4,:)}; %data use for plot and stats
title_name = 'HPC-LSM Frequency Across Groups';
[results] = scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);

% Mol
data = {groupc_freq_2D(5,:), group3wp_freq_2D(5,:), group8wp_freq_2D(5,:)}; %data use for plot and stats
title_name = 'HPC-Mol Frequency Across Groups';
[results] = scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);

% GC 
data = {groupc_freq_2D(6,:), group3wp_freq_2D(6,:), group8wp_freq_2D(6,:)}; %data use for plot and stats
title_name = 'HPC-GC Frequency Across Groups';
[results] = scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);

% Hil
data = {groupc_freq_2D(7,:), group3wp_freq_2D(7,:), group8wp_freq_2D(7,:)}; %data use for plot and stats
title_name = 'HPC-Hil Frequency Across Groups';
[results] = scatterBars_freq_SF(data, {'c', '3wp','8wp'},  {'blue', 'm','red'}, title_name, savepath);






