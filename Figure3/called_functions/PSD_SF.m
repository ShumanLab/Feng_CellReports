function PSD(animals)  %maybe add something to do full or running time only 

%inputs: list of animals to loop through
%also need to define experimental groups if you want to plot data by group
%at the end 
%output: plots with power on the y axis and frequency on the x axis - from
%Susie's original script
%Plots for each animal + by group with SEM error bars

%Need to set chan=ch.?? in line 39 below to whatever region you want to grab a channel
%from - right now I set it to the mid hilus



%animals = {'3xTg1-1', '3xTg1-2','3xTg48-0', 'WT47-0', 'WT45-2', '3xTg49-2', '3xTg49-1', 'AD-WT-1-0', 'WT78-0', '3xTg75-1', 'WT77-0', '3xTg79-0', 'WT89-0', 'WT98-0', '3xTg77-1' };
%was trying to add something to get mean plots for each group but PSD for
%each animal is a different length???? 
PSD6wt = []; %make space to store PSD info
%for all the animals in each group so we can make group avg at the end
PSD8wt =[];
PSD63x = [];
PSD83x = [];
for anim = 1:length(animals)

animal = animals{anim};
exp_dir=get_exp(animal);
PSD2 = [];

if strcmp(animal,'3xTg1-2')==1
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
    else
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');
end

[HIPshank, ECshank]=getshankECHIP(animal);
shank = HIPshank;
shankchs=probelayout(:,shank);  %get actual channel numbers based on shank
[ch]=getchannels_LV(animal,shank);
chan = round((ch.Hil1 +ch.Hil2)/2);  %set this to whatever you want the channel used to be 
group = ch.group;
rawch=shankchs(chan); %convert to true channel number
load([exp_dir 'LFP\LFP1000\LFPvoltage_ch' num2str(rawch) '.mat']); %load data
load(strcat(exp_dir, '\stimuli\', animal, '_runtimesNEW.mat'),'run_times');
data = LFPvoltage_notch;

run_length = run_times(:,3);
run_times_3plus = run_times(run_length >=3, :); %only run_times longer than 3s
run_times_1000hz = round(run_times_3plus*1000); %convert to numbers that will match up with LFP1000 files

%check if index of LFP voltage is within the bounds of anything in
%run_times_1000hz 

test = zeros(length(data),1);  % T/F matrix   %rename this 
for i=1:length(data);   %for each time point in LFP1000
    for time_window = 1:length(run_times_1000hz);  %go through each time window in run times
        if i >= run_times_1000hz(time_window, 1) & i <= run_times_1000hz(time_window, 2); %check if that time point falls within that time window
        test(i, 1) = 1;  %set to 1;
        continue
        else
        end
    end
end

data = data(test == 1); %only get LFP data points that are happening during running bins 
         


Fs =1000;  % Sampling frequency (1kHz) 

%data = struct2cell(data);
%data = cell2mat(data);
L = length(data(1,:)); % Length of signal 
t = (0:L-1)*(1/Fs);   % Time vector (in sec)

Y = fft(data); %fourier transform
PSD = abs(Y/L); %normalize by length of data?
PSD = PSD(:,1:L/2+1);  %????
PSD(:,2:end-1) = 2*PSD(:,2:end-1);  %???? 
f = Fs*(0:(L/2))/L; %????

[X,f2] = discretize(f,500);
 
 for i=1:500
 idx = find(X==i);
 first = idx(1);
 last = idx(end);
 PSDi = mean(PSD(first:last));
 PSD2 = [PSD2 ;PSDi];
 end
 PSD2 = PSD2';
 
 %find all the places X= 1, average the values in PSD at all those indices,
 %then make that the first value - at the end there will be 500 values in
 %PSD
 %need a matrix that has the bin numbers for the x axis too 

plottitle = ['PSD' animal 'ch' num2str(chan)];

figure(anim) 
plot(PSD2,'color',[0 0 1],'LineWidth',2)
xlim([0 100])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle)


%plot(f,PSD,'color',[1 0 0],'LineWidth',2)
if group == '6wt'
PSD6wt=[PSD6wt; PSD2];

elseif group == '8wt'
PSD8wt=[PSD8wt; PSD2];


elseif group == '63x'
PSD63x=[PSD63x; PSD2];


elseif group == '83x'
PSD83x=[PSD83x; PSD2];

end 

end %end animal


PSD6wt_mean = mean(PSD6wt);
PSD6wt_error = std(PSD6wt) / sqrt(size(PSD6wt, 1)) ;
PSD8wt_mean = mean(PSD8wt);
PSD8wt_error = std(PSD8wt) / sqrt(size(PSD8wt, 1)) ; 
PSD63x_mean = mean(PSD63x);
PSD63x_error = std(PSD63x) / sqrt(size(PSD63x, 1)) ; 
PSD83x_mean = mean(PSD83x);
PSD83x_error = std(PSD83x) / sqrt(size(PSD83x, 1)) ;   


%%add stuff to make plotting nice 

plottitle2 = ['PSD 3xTg 6 mo'];
figure(100)
plot(PSD63x_mean,'color',[1 0 0],'LineWidth',2)
xlim([4 100])
%ylim([0 1])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle2)

plottitle3 = ['PSD 3xTg 8 mo'];
figure(101)
plot(PSD83x_mean,'color',[0.8 0 0],'LineWidth',2)
xlim([4 100])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle3)

plottitle4 = ['PSD WT 8 mo'];
figure(102)
plot(PSD8wt_mean,'color',[0 0 1],'LineWidth',2)
xlim([4 100])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle4)

plottitle5 = ['PSD WT 6 mo'];
figure(103)
plot(PSD6wt_mean,'color',[0 0 0.8],'LineWidth',2)
xlim([4 100])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle5)




plottitle6 = ['PSD']
figure(104)
plot(PSD63x_mean,'color',[0.9 0.6 0.7],'LineWidth',2)
hold on;
plot(PSD83x_mean,'color',[0.4 0 0.5],'LineWidth',2)
hold on;
plot(PSD8wt_mean,'color',[0.3 0.2 0.6],'LineWidth',2)
hold on;
plot(PSD6wt_mean,'color',[0.3 0.5 0.8],'LineWidth',2)
xlim([4 100])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle6)


plottitle7 = ['PSD in mid-Hilus']
figure(105)
errorbar(PSD63x_mean, PSD63x_error, 'color',[0.9 0.6 0.7],'LineWidth',2)
hold on;
errorbar(PSD83x_mean, PSD83x_error, 'color',[0.4 0 0.5],'LineWidth',2)
hold on;
%errorbar(PSD8wt_mean, PSD8wt_error, 'color',[0.3 0.2 0.6],'LineWidth',2)
%hold on;
errorbar(PSD6wt_mean, PSD6wt_error, 'color',[0.3 0.5 0.8],'LineWidth',2)
xlim([4 100])
xlabel('Frequency (Hz)')
ylabel('Power (AU)')
title(plottitle7)

% hold on;
% plot(PSD83x_mean,'color',[0.4 0 0.5],'LineWidth',2)
% hold on;
% plot(PSD8wt_mean,'color',[0.3 0.2 0.6],'LineWidth',2)
% hold on;
% plot(PSD6wt_mean,'color',[0.3 0.5 0.8],'LineWidth',2)
% xlim([4 100])
% xlabel('Frequency (Hz)')
% ylabel('Power (AU)')
%title(plottitle7)






end