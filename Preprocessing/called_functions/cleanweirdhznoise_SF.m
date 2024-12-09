%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scipt is only use for TS89-2 TS110-3 TS112-0
%Inputs: animal ID, numchans of your probe
%Output: update LFPvoltage_notch to LFP1000 files
%Writen by SF, 2/23/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cleanweirdhznoise_SF(animals, numchans)

for anim = 1:length(animals)
    animal=animals{anim};
    
    if strcmp(animal, 'TS89-2') == 1
        [ana_dir]=get_ana(animal);
        exp_dir=get_exp(animal);
        lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');
        exp = load([exp_dir 'exp.mat']);
        
         parfor ch=1:numchans 
        %for ch = 1:numchans
            data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
            data = data.LFPvoltage_notch; 
            Fs =1000;  % Sampling frequency (1kHz) 
            data = double(data);

            %below is self build filter
            d_55 = designfilt('bandstopiir','FilterOrder',2, ...
                           'HalfPowerFrequency1',53.5,'HalfPowerFrequency2',55, ...
                           'DesignMethod','butter','SampleRate',Fs);

            d_65 = designfilt('bandstopiir','FilterOrder',2, ...
                           'HalfPowerFrequency1',64.5,'HalfPowerFrequency2',66, ...
                           'DesignMethod','butter','SampleRate',Fs);

            d_195 = designfilt('bandstopiir','FilterOrder',2, ...
                           'HalfPowerFrequency1',195.2,'HalfPowerFrequency2',195.4, ...
                           'DesignMethod','butter','SampleRate',Fs);

            LFPvoltage_notch = filtfilt(d_55,data);
            LFPvoltage_notch = filtfilt(d_65,LFPvoltage_notch);
            LFPvoltage_notch = filtfilt(d_195,LFPvoltage_notch);

            %data=single(data);
            LFPvoltage_notch = single(LFPvoltage_notch);

             m=matfile([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
             %m.LFPvoltage=data;
             m.LFPvoltage_notch = LFPvoltage_notch;
           % save(lfp_dir strcat('LFPvoltage_ch', num2str(ch),'.mat'), 'LFPvoltage', 'LFPvoltage_notch');

             if (mod(ch,10)==0)
                sprintf('filtering channels. %2.0f%% done.', ch/numchans*100)
             end

         end

         
           elseif strcmp(animal, 'TS110-3') == 1
        [ana_dir]=get_ana(animal);
        exp_dir=get_exp(animal);
        lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');

        parfor ch=1:numchans 
        %for ch = 1:numchans
            data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
            data = data.LFPvoltage_notch; %to handle ones already have notch file
            Fs =1000;  % Sampling frequency (1kHz) 
            %data = struct2cell(data);
            %data = cell2mat(data);
            data = double(data);

            %below is self build notch filter
                    d_60 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',59.6,'HalfPowerFrequency2',60.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        d_120 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',119.6,'HalfPowerFrequency2',120.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        d_180 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',179.6,'HalfPowerFrequency2',180.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

            LFPvoltage_notch = filtfilt(d_60,data);
            LFPvoltage_notch = filtfilt(d_120,LFPvoltage_notch);
            LFPvoltage_notch = filtfilt(d_180,LFPvoltage_notch);
            LFPvoltage_notch = single(LFPvoltage_notch);
             m=matfile([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
             m.LFPvoltage_notch = LFPvoltage_notch;
             if (mod(ch,10)==0)
                sprintf('filtering channels. %2.0f%% done.', ch/numchans*100)
             end
        end
    
              elseif strcmp(animal, 'TS112-0') == 1
        [ana_dir]=get_ana(animal);
        exp_dir=get_exp(animal);
        lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');

        parfor ch=1:numchans 
        %for ch = 1:numchans
            data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
            data = data.LFPvoltage_notch; %to handle ones already have notch file
            Fs =1000;  % Sampling frequency (1kHz) 
            %data = struct2cell(data);
            %data = cell2mat(data);
            data = double(data);

            %below is self build notch filter
                    d_60 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',59.6,'HalfPowerFrequency2',60.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        d_120 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',119.6,'HalfPowerFrequency2',120.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        d_180 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',179.6,'HalfPowerFrequency2',180.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

            LFPvoltage_notch = filtfilt(d_60,data);
            LFPvoltage_notch = filtfilt(d_120,LFPvoltage_notch);
            LFPvoltage_notch = filtfilt(d_180,LFPvoltage_notch);
            LFPvoltage_notch = single(LFPvoltage_notch);
             m=matfile([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
             m.LFPvoltage_notch = LFPvoltage_notch;
             if (mod(ch,10)==0)
                sprintf('filtering channels. %2.0f%% done.', ch/numchans*100)
             end
        end
    end
end
    
    
%      elseif strcmp(animal, 'TS110-3') == 1
%         [ana_dir]=get_ana(animal);
%         exp_dir=get_exp(animal);
%         lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');
% 
%         parfor ch=1:numchans 
%         %for ch = 1:numchans
%             data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
%             data = data.LFPvoltage_notch; %to handle ones already have notch file
%             Fs =1000;  % Sampling frequency (1kHz) 
%             %data = struct2cell(data);
%             %data = cell2mat(data);
%             data = double(data);
% 
%             %below is self build notch filter
%             d_68 = designfilt('bandstopiir','FilterOrder',2, ...
%                            'HalfPowerFrequency1',66.5,'HalfPowerFrequency2',68, ...
%                            'DesignMethod','butter','SampleRate',Fs);
% 
%             d_75 = designfilt('bandstopiir','FilterOrder',2, ...
%                            'HalfPowerFrequency1',74.3,'HalfPowerFrequency2',75.7, ...
%                            'DesignMethod','butter','SampleRate',Fs);
% 
%             d_82 = designfilt('bandstopiir','FilterOrder',2, ...
%                            'HalfPowerFrequency1',81.5,'HalfPowerFrequency2',83.5, ...
%                            'DesignMethod','butter','SampleRate',Fs);
% 
%             LFPvoltage_notch = filtfilt(d_68,data);
%             LFPvoltage_notch = filtfilt(d_75,LFPvoltage_notch);
%             LFPvoltage_notch = filtfilt(d_82,LFPvoltage_notch);
%             LFPvoltage_notch = single(LFPvoltage_notch);
%              m=matfile([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
%              m.LFPvoltage_notch = LFPvoltage_notch;
%              if (mod(ch,10)==0)
%                 sprintf('filtering channels. %2.0f%% done.', ch/numchans*100)
%              end
%         end
%     
%         
%         
%     elseif strcmp(animal, 'TS112-0') == 1
%         [ana_dir]=get_ana(animal);
%         exp_dir=get_exp(animal);
%         lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');
% 
%         parfor ch=1:numchans 
%         %for ch = 1:numchans
%             data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
%             data = data.LFPvoltage_notch; %to handle ones already have notch file
%             Fs =1000;  % Sampling frequency (1kHz) 
%             %data = struct2cell(data);
%             %data = cell2mat(data);
%             data = double(data);
% 
%             %below is self build notch filter
%             d_53 = designfilt('bandstopiir','FilterOrder',2, ...
%                            'HalfPowerFrequency1',52,'HalfPowerFrequency2',54.5, ...
%                            'DesignMethod','butter','SampleRate',Fs);
% 
%             d_66 = designfilt('bandstopiir','FilterOrder',2, ...
%                            'HalfPowerFrequency1',66,'HalfPowerFrequency2',67.5, ...
%                            'DesignMethod','butter','SampleRate',Fs);
% 
%             d_195 = designfilt('bandstopiir','FilterOrder',2, ...
%                            'HalfPowerFrequency1',195,'HalfPowerFrequency2',195.4, ...
%                            'DesignMethod','butter','SampleRate',Fs);
% 
%             LFPvoltage_notch = filtfilt(d_53,data);
%             LFPvoltage_notch = filtfilt(d_66,LFPvoltage_notch);
%             LFPvoltage_notch = filtfilt(d_195,LFPvoltage_notch);
%             LFPvoltage_notch = single(LFPvoltage_notch);
%              m=matfile([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
%              m.LFPvoltage_notch = LFPvoltage_notch;
%              if (mod(ch,10)==0)
%                 sprintf('filtering channels. %2.0f%% done.', ch/numchans*100)
%              end
%         end
% 
%      end
%  end
% 



% 
% %below are testing how well this is getting rid of 60, 120, 180hz noise
% Fs =1000;
% L = length(LFPvoltage_notch(1,:)); % Length of signal 
% t = (0:L-1)*(1/Fs);   % Time vector (in sec)
% Fs =1000
% Y = fft(LFPvoltage_notch);
% PSD = abs(Y./L);
% PSD = PSD(:,1:L/2+1); 
% PSD(:,2:end-1) = 2*PSD(:,2:end-1); 
% f = Fs*(0:(L/2))/L;
% 
% 
% figure 
% plot(f,mean(PSD,1),'color',[0 0 0],'LineWidth',2)
% xlim
% xlabel('Frequency (Hz)')
% ylabel('Power (AU)')
% title('LFP2 PSD')
% 
% 
% 
% figure;
% plot(LFPvoltage_notch, 'r');
% hold on;
% plot(data, 'b');
