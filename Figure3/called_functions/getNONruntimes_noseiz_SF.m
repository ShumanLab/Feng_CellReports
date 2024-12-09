%%%%%%%%%%%%%%%%%%%%%%%
%This function is to generate NON-run_times matrix with seizure time cutting out
%INPUT: animals; seizstatearray
%OUTPUT: nonruntimesNEW_noseiz.mat
%Susie 4/27/24
%%%%%%%%%%%%%%%%%%%%%%%

function getNONruntimes_noseiz_SF(animal)
binsize=0.1;
minnonrun=1; %1 second minimam run time.  changed to 1 after coh ana, in the middle of spike processing
minbins=minnonrun/binsize;
%assuming binsize=0.1

exp_dir=get_exp(animal);
stim_dir=[exp_dir 'stimuli\'];

load([stim_dir animal '_VRstatearrays.mat']);
load([stim_dir animal '_seizstatearray.mat']);

nonrun_times=[];
notrunning=0;
nonrunnumber=0;

minsize = size(bintimes, 1); %handle when binsize and seizing matrix size don't align 
if minsize >= length(seizing)
    minsize = length(seizing);
end

for b=minbins:minsize
    if notrunning==0
        if running(b)==0 && (sum(running(b-minbins+1:b))==0) && seizing(b) == 0 %see if the whole timebin is running
            notrunning=1;
            nonrunnumber=nonrunnumber+1;
            nonrun_times(nonrunnumber,:)=[(b-minbins+1)*binsize 0]; %assumes even bins - could replace with bintimes if wanted
        end
    elseif notrunning==1 
        if running(b)== 1 || seizing(b) == 1
            notrunning=0;
            nonrun_times(nonrunnumber,2)=(b)*binsize;
        end
    end
end

nonrun_times(:,3)=nonrun_times(:,2)-nonrun_times(:,1);

save([stim_dir animal '_NONruntimesNEW_noseiz1sec.mat'],'nonrun_times','minnonrun');
