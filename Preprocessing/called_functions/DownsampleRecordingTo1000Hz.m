function DownsampleRecordingTo1000Hz(animal, srate, numchans)


% animal='AD2-3';
exp_dir=get_exp(animal);
load([exp_dir 'exp.mat']);
LFP_dir=[exp_dir '\LFP\Full\'];
re_dir=[exp_dir '\LFP\LFP1000\'];

 mkdir(re_dir)



% numchans=128;

    for ch=1:numchans
% sprintf(['working on ch ' num2str(ch)])
         L=matfile([LFP_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
         LFPvoltage=double(L.LFPvoltage(1, :));
%       LFP=load([exp_dir '\LFP\Full\LFPvoltage_ch' num2str(ch) '.mat']); %loads LFPvoltage
%       LFPvoltage=double(LFP.LFPvoltage); 
      reLFP=decimate(LFPvoltage,srate/1000);
        LFPvoltage=single(reLFP);
%         clear LFP
         m=matfile([re_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
         m.LFPvoltage=LFPvoltage;
%          save([re_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'LFPvoltage'); %loads LFPvoltage
%           clear LFPvoltage
         if (mod(ch,10)==0)
         sprintf('Downsampling channels. %2.0f%% done.', ch/numchans*100)
         end

    
    end

end