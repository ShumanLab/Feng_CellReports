%%%%%%%%%%%%%%%%%%%%%%%
%This script is to generate run_times_1s_bin matrix with seizure time cutting out
%INPUT: animals; seizstatearray
%OUTPUT: runtimes_1s_bin_noseiz_track1.mat (in stimuli folder)
% column 1: binary to indicate that is running or not; column 2: speed during that sec
%This is for new subsample analysis
% NOTE THIS IS ONLY CALC track 1 to align with the samplesample coh matrix
%Susie 5/9/24
%%%%%%%%%%%%%%%%%%%%%%%


animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
for anim = 1:length(animals)
    animal = animals{anim};
    binsize=1; %sec
    POSsamplerate = 25000;
    starttime = 1; 
    win_sz = 10; % 10 x 0.1 = 1sec
    
    exp_dir=get_exp(animal);
    stim_dir=[exp_dir 'stimuli\'];
    load([exp_dir '\stimuli\position.mat'])
    load([stim_dir animal '_VRstatearrays.mat']);
    load([stim_dir animal '_seizstatearray.mat']); %running here is at 0.1sec time bins
    position10hz = downsample(position,2500);
    starttime = 1; 
    %find track 1 time
    track1 = find(position == 4);
    track1_end = track1(end);
    track1_end_sec = track1_end/POSsamplerate;
    position10hz_track1 = position10hz(1:track1_end_sec*10); %only care about track1 here
    
    run_matrix = nan(round(track1_end_sec),2); %col1: run index; col2: speed during that sec
    for i = 1:length(run_matrix)
        if sum(running(starttime:starttime+win_sz-1)) == 10 && sum(nonseizing(starttime:starttime+win_sz-1)) == 10
            run_matrix(i,1) = 1;
        else
            run_matrix(i,1) = 0;
        end
        starttime = starttime + 10;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calc speed for each bin (1sec)
    for i = 1:length(position10hz_track1)-1
        if position10hz_track1(i+1)-position10hz_track1(i) >= 0 
            speed(i) = (position10hz_track1(i+1)-position10hz_track1(i))/0.1; %pos/s
        else
            speed(i) = nan;     
        end
        i = i + 1;
    end
    speed = [speed, nan]; %make it the same length as other matrix
    
    starttime = 1;
    for i = 1:length(run_matrix)
        if starttime + 10 < length(speed) %deal with if last sec not full
           run_matrix(i,2) = nanmean(speed(starttime:starttime+win_sz-1));
        else
           run_matrix(i,2) = nanmean(speed(starttime:end));
        end
        starttime = starttime + 10;
    end
    save([stim_dir animal '_runtime_1s_bin.mat'],'run_matrix');
    clear speed run_matrix position position10hz_track1 position10hz starttime

end