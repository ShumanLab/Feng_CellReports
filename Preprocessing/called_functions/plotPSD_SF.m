%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scipt is to plot PSD for an random channel for all animals in the list
%Inputs: animals, channel to plot
%Output: PSD figurs
%Writen by SF, 2/14/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotPSD_SF(animals, ch)


for anim = 1:length(animals)
    animal=animals{anim};
    [ana_dir]=get_ana(animal);
     exp_dir=get_exp(animal);
     lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');
     
     data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
     data = data.LFPvoltage_notch; %to handle ones already have notch file
     Fs =1000;
     L = length(data(1,:)); % Length of signal 
     t = (0:L-1)*(1/Fs);   % Time vector (in sec)
    
     Y = fft(data);
     PSD = abs(Y./L);
     PSD = PSD(:,1:L/2+1); 
     PSD(:,2:end-1) = 2*PSD(:,2:end-1); 
     f = Fs*(0:(L/2))/L;

     figure 
     plot(f,mean(PSD,1),'color',[0 0 0],'LineWidth',2)
    % xlim
     xlabel('Frequency (Hz)')
     ylabel('Power (AU)')
     title(['PSD ' animal ' ch' num2str(ch)])
end