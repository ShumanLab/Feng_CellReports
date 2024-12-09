function getruntimes(animal)
binsize=0.1;
minrun=1; %1 second min run time
minbins=minrun/binsize;
%assuming binsize=0.1

exp_dir=get_exp(animal);
stim_dir=[exp_dir 'stimuli\'];

load([stim_dir animal '_VRstatearrays.mat']);


run_times=[];
isrunning=0;
runnumber=0;
    for b=minbins:size(bintimes,1)
        
        if isrunning==0
            if running(b)==1 && (sum(running(b-minbins+1:b))==minbins)
                isrunning=1;
                runnumber=runnumber+1;
                run_times(runnumber,:)=[(b-minbins+1)*binsize 0]; %assumes even bins - could replace with bintimes if wanted
            end
        elseif isrunning==1
            if running(b)==0
                isrunning=0;
                run_times(runnumber,2)=(b)*binsize;
            end
        end
    end

run_times(:,3)=run_times(:,2)-run_times(:,1);

save([stim_dir animal '_runtimesNEW.mat'],'run_times','minrun');

end