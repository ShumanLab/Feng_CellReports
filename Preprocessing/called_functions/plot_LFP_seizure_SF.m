%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%This script is to plot a given channel of downsampled LFP from

%INPUTS: animal list, downsr (downsample rate from 1000hz), channel to plot

%OUTPUT:Downsampled LFP plot
  
%wirtten by susie,2/21/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


function plot_LFP_seizure_SF(animals, downsr, channel)
for  a=1:length(animals)
    animal=animals{a};
   [ana_dir]=get_ana(animal);
    exp_dir=get_exp(animal);
    LFP_dir=([exp_dir 'LFP\LFP1000\']);
    load([LFP_dir 'LFPvoltage_ch' num2str(channel) '.mat']) %loads LFPvoltage
    L=double(LFPvoltage_notch);
    reLFP=decimate(L,downsr);
    reLFP=single(reLFP);
    figure()
    plot(reLFP);
   % og_length = length(reLFP)*downsr*25;
    %og_length_sec = og_length/25000;  %orginal data length in min
    %xticks([1: og_length_sec]);
    %xticklabels({1:og_length_sec 10});  
 
     xlabel('Time in sample unit')
     ylabel('Amplitude')
     title(['Downsampled Power plot of ' animal ' ch' num2str(channel) ' (' num2str(1000/downsr) 'Hz)'])
end
end