%create running, etc arrays

function VRstatearraysNEW(animal, binsize)
%binsize is in seconds
exp_dir=get_exp(animal);
stim_dir=[exp_dir 'stimuli\'];

%get stimuli
load([stim_dir 'licking.mat']);
load([stim_dir 'position.mat']);
load([stim_dir 'reward.mat']);
load([stim_dir 'running.mat']);

%find all licks
licking=5-licking;
threshold=3; %going up
lickstarts=[];
lickends=[];
maxLickTime=0.200*25000;
minLickTime=0.001*25000;
for l=2:length(licking)
    if licking(l)>threshold && licking(l-1)<threshold %maybe add some length requirement?
        lickstarts=[lickstarts l];
    elseif licking(l)<threshold && licking(l-1)>threshold && length(lickstarts)==length(lickends)+1
        if l-lickstarts(end)>maxLickTime || l-lickstarts(end)<minLickTime
            lickstarts=lickstarts(1:end-1);
        else            
            lickends=[lickends l];
        end
    end
end


rewardstarts=[];
rewardends=[];
minTimeRewards=25000;

if strcmp(animal,'TS110-2')==1 | strcmp(animal,'TS110-3')|strcmp(animal,'TS110-0')| strcmp(animal,'TS112-0')| strcmp(animal,'TS112-1')| strcmp(animal,'TS114-3')| strcmp(animal,'TS114-0')| strcmp(animal,'TS114-2')| strcmp(animal,'TS114-1')| strcmp(animal,'TS111-0')| strcmp(animal,'TS111-1')| strcmp(animal,'TS111-2')| strcmp(animal,'TS113-1')| strcmp(animal,'TS113-3')| strcmp(animal,'TS113-2')| strcmp(animal,'TS115-2')| strcmp(animal,'TS115-1')| strcmp(animal,'TS116-3')
 rthresh=0.02;%this is used for all 2020 summer ephys animal before TS116-1 since the ground wire missing
else
  rthresh=2;
end
 
for r=2:length(reward)
    if abs(reward(r))>rthresh && abs(reward(r-1))<rthresh  %maybe add some length requirement?
        if length(rewardstarts)==0
        rewardstarts=[rewardstarts r];
        else
           if r-rewardstarts(end)>minTimeRewards
               rewardstarts=[rewardstarts r];
           end
        end
    elseif abs(reward(r))<rthresh && abs(reward(r-1))>rthresh && length(rewardstarts)==length(rewardends)+1
        rewardends=[rewardends r];
    end
end
rewards=rewardstarts;


%%
%divide into 0.5s bins and determine running or not running in each bin
%based on ephys time(VR.time) - in seconds
running=double(running);
run1k=decimate(running,25);
frun=smoothts(run1k,'b',1000);
frun25=smoothts(running,'b',25000);

% binsize=0.1; %seconds
% mindistperbin=20*binsize;   % running = ~100/sec, moving =~20?

t=1:length(run1k);
t=t/1000;
totaltime=t(end);
totalbins=ceil(totaltime/binsize);
running=zeros(1,totalbins);
nonrunning=zeros(1,totalbins);
% ITT=zeros(1,totalbins);
% rewards=VR.rewards;
bintimes=zeros(totalbins,2);
runthresh=2.7; %2.6 is rest

for bin=1:totalbins
    %bin times
    b0=binsize*(bin-1);
    b1=b0+binsize;
    bintimes(bin,:)=[b0 b1];
    bt=find(t>=b0 & t<b1);
    meanrun=mean(frun(bt(1):bt(end)));    
        if meanrun>=runthresh
             running(bin)=1;
             nonrunning(bin)=0;
        else
             running(bin)=0;
             nonrunning(bin)=1;
        end
        
        

        
         if (mod(bin,5000)==0)
            sprintf(['Running VR state arrays for ' animal '. %2.0f%% done.'], bin/totalbins*100)
        end
end

save([stim_dir animal '_VRstatearrays.mat'], 'running', 'nonrunning', 'runthresh', 'binsize', 'bintimes','lickstarts', 'lickends', 'rewards', 'rewardstarts', 'rewardends');

end