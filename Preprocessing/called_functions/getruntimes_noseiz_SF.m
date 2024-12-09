%%%%%%%%%%%%%%%%%%%%%%%
%This function is to generate run_times matrix with seizure time cutting out
%INPUT: animals; seizstatearray
%OUTPUT: runtimesNEW_noseiz.mat
%Susie 3/11/22
%%%%%%%%%%%%%%%%%%%%%%%

function getruntimes_noseiz_SF(animal)
binsize=0.1;
minrun=3; %1 second minimam run time.  changed to 1 after coh ana, in the middle of spike processing
minbins=minrun/binsize;
%assuming binsize=0.1

exp_dir=get_exp(animal);
stim_dir=[exp_dir 'stimuli\'];

load([stim_dir animal '_VRstatearrays.mat']); %running here is at 0.1sec time bins
load([stim_dir animal '_seizstatearray.mat']);

run_times=[];
isrunning=0;
runnumber=0;

minsize = size(bintimes, 1); %handle when binsize and seizing matrix size don't align 
if minsize >= length(seizing)
    minsize = length(seizing);
end

for b=minbins:minsize
    if isrunning==0
        if running(b)==1 && (sum(running(b-minbins+1:b))==minbins) && seizing(b) == 0 %see if the whole timebin is running
            isrunning=1;
            runnumber=runnumber+1;
            run_times(runnumber,:)=[(b-minbins+1)*binsize 0]; %assumes even bins - could replace with bintimes if wanted
        end
    elseif isrunning==1 
        if running(b)== 0 || seizing(b) == 1
            isrunning=0;
            run_times(runnumber,2)=(b)*binsize;
        end
    end
end

run_times(:,3)=run_times(:,2)-run_times(:,1);

save([stim_dir animal '_runtimesNEW_noseiz3sec.mat'],'run_times','minrun');
