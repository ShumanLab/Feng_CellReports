function [Cmn, Phimn, Smn, Smm, f, ConfC, PhiStd, Cerr]=coherencebyanimal(animal,side,LFP,run_times,ch1,ch2,fpass1, fpass2)

% [group, shank, MidPyr,Or1,Or2, Pyr1,Pyr2,Rad1,Rad2,LM1,LM2,Mol1,Mol2,GC1,GC2,Hil1,Hil2]=getCA1DGlocations(animal, side);
% exp_dir=get_exp(animal);
% 
% cd([exp_dir '\LFP']);
% load([animal '_shank' num2str(shank) '_LFP.mat'], 'LFP'); %loads LFP

% 
% dat1=LFP(45,:);
% dat2=LFP(12,:);
% 
% [Cxy F]=mscohere(dat1,dat2,hanning(2024),[],[],1000);
% figure; plot(F,Cxy)

% 
% 
% %get recorded reward times
% cd(strcat(exp_dir, '\stimuli'));
% load(strcat(animal,'_runtimes.mat'));
% 


dat1=LFP(ch1,:);
dat2=LFP(ch2,:);

data=[dat1' dat2'];
sMarkers= [round(run_times(:,1)*1000)  round(run_times(:,2)*1000)];                             %start stop indexes

movingwin=[3 3];

params.fpass=[fpass1 fpass2];
params.Fs=1000;
params.tapers=[3 5]; %[NW K]  K=2NW-1 

p=0.05;
params.err=[2 p];


[Cmn,Phimn,Smn,Smm,f,ConfC,PhiStd,Cerr] = coherencyc_unequal_length_trials(data, movingwin, params, sMarkers );
%  figure; plot(f,Cmn)


end