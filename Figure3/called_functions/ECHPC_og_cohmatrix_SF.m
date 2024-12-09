%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&
%This script is to generate coh matrix for 4 shanks (CA1DG, CA3, MEC, LEC in this order)
%picked for each animal. 
%Input: animal list,track, run_times_range,animal_runtimeNEW,aniaml_shankx_LFP, position
%Output: 256 x 256  coh matrix.
%Handle non-exsit shank: assign a random shank for now from script getCA1DGCA3ECshank_SF(animal), then skip when when use ch loc file to only pick the actual real shank.ch
%Do not handle bad ch at this step

%written by susie 8/20/2021, updated 3/20/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

function ECHPC_og_cohmatrix_SF(animals, track, run_times_range)
% 
% animals = {'TS118-4'}
% track = '1';
% run_times_range = 400; %in sec, this is how much run time you want to process

for a = 1:length(animals)
    animal = animals(a);
    %animal='TS118-4';

    exp_dir=get_exp(animal);
    load([exp_dir '\exp.mat'])
    load([exp_dir '\stimuli\' animal '_runtimesNEW_noseiz.mat'], 'run_times') %run_time matrix is in sec unit
    load([exp_dir '\stimuli\position.mat'])

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Below is loading all 4 shanks of interest from ch loc file
    %note when certain region doesn't exsit, this fun loat a random fake shank, not ideal, but susie decide to deal with this later when make concadenated coh matrix

    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);

    %below is to specify to process track1 or 2   
    track2 = find(position == 5); %track1 in position is 0-4, track2 is 4.5-8.5
    
    if isempty(track2)==0 %below is for animals with both track1 and 2
        track2_startsec = track2(1)/25000; %this the sec that when I switch to track2
        track2_endsec = track2(end)/25000; %this the sec that when when track2 end, since animal got back on track1 after 2


        runtime_track2_start = find(run_times(:,1) >= track2_startsec); %find in run_times sheet, where does track2 start
        runtime_track2_start =  runtime_track2_start(1); %index of the row number when track2 start
        runtime_track2_end = find(run_times(:,2) >= track2_endsec); %find in run_times sheet, where does track2 end. minus 1 here is to handle round error
 
        if isempty(runtime_track2_end) == 0
            runtime_track2_end = runtime_track2_end(end); %index of the row number when track2 end
        else %handle when runtime_track2_end is empty (animal stopped running in the end)
             runtime_track2_end = length(run_times); 
        end
        
        %below is to create new matrix for track1 and 2 run time
        run_times_track1 = run_times(1:runtime_track2_start,:); %create a new matrix for track1 run time. NOTE currently not handling when add track1 after track2
        run_times_track2 = run_times(runtime_track2_start:runtime_track2_end,:); %create a new matrix for track 2 run time

        if strcmp(track,'1')==1 %for track1
            run_timescumsumtrack1 = cumsum(run_times_track1(:,3)); %generating the cumsum matrix from run_times_track1
            track1_end_include_index = find(run_timescumsumtrack1>=run_times_range); %find at which row total run time reach to run_times_range
            try  %to handle when the run_times_range is greater than total run time in track1
                track1_end_include_index = track1_end_include_index(1); %the first number is the index of the row that we want to process track1 until
            end

            if track1_end_include_index <= runtime_track2_start
                run_times = run_times_track1(1:track1_end_include_index,:);
            else
                 run_times = run_times_track1(1: runtime_track2_start,:); %to handle when the run_times_range is greater than total run time in track1
            end
        
        
        elseif strcmp(track,'2')==1 %for track2
            run_timescumsumtrack2 = cumsum(run_times_track2(:,3)); %generating the cumsum matrix from run_times_track2
            track2_end_include_index = find(run_timescumsumtrack2>=run_times_range); %find at which row total run time reach to run_times_range
            try  %to handle when the run_times_range is greater than total run time in track2
                track2_end_include_index = track2_end_include_index(1); %the first number is the index of the row that we want to process track2 until
            end

            if track2_end_include_index <= runtime_track2_end-runtime_track2_start %bc we generated new run_times_track2 matrix toget track2_end_include_index
                run_times = run_times_track2(1:track2_end_include_index,:);  
            else
                run_times = run_times_track2(1:runtime_track2_end-runtime_track2_start,:);  
            end

        end
    
    else %handle animals with no track 2
        if strcmp(track,'2')==1 
             error('Track missing: Current animal doesnt have track2');
        else
            track1 = find(position == 4);
            track1_endsec = track1(end)/25000; 
            runtime_track1_end = round(find(run_times(:,1) < track1_endsec));
            runtime_track1_end = runtime_track1_end(end);

            %below is to create new matrix for track1 run time
            run_times_track1 = run_times(1:runtime_track1_end,:);
            if strcmp(track,'1')==1 %for track1
                run_timescumsumtrack1 = cumsum(run_times_track1(:,3)); %generating the cumsum matrix from run_times_track1
                track1_end_include_index = find(run_timescumsumtrack1>=run_times_range); %find at which row total run time reach to run_times_range
            try  %to handle when the run_times_range is greater than total run time in track1
                track1_end_include_index = track1_end_include_index(1); %the first number is the index of the row that we want to process track1 until
            end
            
            if track1_end_include_index <= runtime_track2_start
                run_times = run_times_track1(1:track1_end_include_index,:);
            else
                run_times = run_times_track1(:,:); %to handle when the run_times_range is greater than total run time in track1
            end
            end
        end  
        
    end
 
    fpass1=0;
    fpass2=200;

    CA1DGLFP=load([exp_dir 'LFP\' animal '_shank' num2str(CA1DGshank) '_LFP.mat']);
    CA1DGLFP=CA1DGLFP.LFP;

    CA3LFP=load([exp_dir 'LFP\' animal '_shank' num2str(CA3shank) '_LFP.mat']);
    CA3LFP=CA3LFP.LFP;

    MECLFP=load([exp_dir 'LFP\' animal '_shank' num2str(MECshank) '_LFP.mat']);
    MECLFP=MECLFP.LFP;

    LEC_LFP=load([exp_dir 'LFP\' animal '_shank' num2str(LECshank) '_LFP.mat']);
    LEC_LFP=LEC_LFP.LFP;

    LFP=[CA1DGLFP; CA3LFP; MECLFP; LEC_LFP]; 

        totalchs=size(LFP,1);

        cohMATRIX=cell(totalchs,totalchs);
        phaseMATRIX=cell(totalchs,totalchs);
        SmnMATRIX=cell(totalchs,totalchs);
        SmmMATRIX=cell(totalchs,totalchs);
                coh_gamma=NaN(totalchs,totalchs);
                coh_theta=NaN(totalchs,totalchs);
                coh_fastgamma=NaN(totalchs,totalchs);
                coh_slowgamma=NaN(totalchs,totalchs);
                coh_beta=NaN(totalchs,totalchs);

                phase_gamma=NaN(totalchs,totalchs);
                phase_theta=NaN(totalchs,totalchs);
                phase_fastgamma=NaN(totalchs,totalchs);
                phase_slowgamma=NaN(totalchs,totalchs);
                phase_beta=NaN(totalchs,totalchs);

                freq=[];

        for ch1=1:totalchs  %parfor here
            for ch2=1:totalchs
                if ch2>=ch1            
                [Cmn, Phimn, Smn, Smm, f, ConfC, PhiStd, Cerr]=coherencebyanimal(animal,[],LFP,run_times,ch1,ch2,fpass1, fpass2);

    % Output:
    %       Cmn     magnitude of coherency - frequencies x iChPairs
    %       Phimn   phase of coherency - frequencies x iChPairs
    %       Smn     cross spectrum -  frequencies x iChPairs
    %       Smm     spectrum m - frequencies x channels
    %       f       frequencies x 1
    %       ConfC   1 x iChPairs; confidence level for Cmn at 1-p % - only for err(1)>=1
    %       PhiStd  frequency x iChPairs; error bars for phimn - only for err(1)>=1
    %       Cerr    2 x frequency x iChPairs; Jackknife error bars for Cmn - use only for Jackknife - err(1)=2
                cohMATRIX{ch1,ch2}=Cmn;
                phaseMATRIX{ch1,ch2}=Phimn;
                SmnMATRIX{ch1,ch2}=Smn;
                SmmMATRIX{ch1,ch2}=Smm;

                gind=find(f>30 & f<80);
                lgind=find(f>30 & f<50);
                thind=find(f>5 & f<12); %I need to change this to match with what I used in CohenrenceMatByAnimal.m - SF

                fgind=find(f>90 & f<130);
                bind=find(f>15 & f<25);
                coh_gamma(ch1,ch2)=mean(Cmn(gind));
                coh_slowgamma(ch1,ch2)=mean(Cmn(lgind));
                coh_theta(ch1,ch2)=mean(Cmn(thind));
                coh_fastgamma(ch1,ch2)=mean(Cmn(fgind));
                coh_beta(ch1,ch2)=mean(Cmn(bind));

                phase_gamma(ch1,ch2)=circ_mean(Phimn(gind));
                phase_slowgamma(ch1,ch2)=circ_mean(Phimn(lgind)); %was not circ_mean before 9/29/22
                phase_theta(ch1,ch2)=circ_mean(Phimn(thind));
                phase_beta(ch1,ch2)=circ_mean(Phimn(bind));
                phase_fastgamma(ch1,ch2)=circ_mean(Phimn(fgind)); %
                freq=f;
                end
            end
            disp(['done with ch1=' num2str(ch1)]);
        end

        for ch1=1:totalchs
            for ch2=1:totalchs
                if ch2<ch1            
                    cohMATRIX{ch1,ch2}=cohMATRIX{ch2,ch1};
                    phaseMATRIX{ch1,ch2}=phaseMATRIX{ch2,ch1};
                    SmnMATRIX{ch1,ch2}=SmnMATRIX{ch2,ch1};
                    SmmMATRIX{ch1,ch2}=SmmMATRIX{ch2,ch1};
                    coh_gamma(ch1,ch2)=coh_gamma(ch2,ch1);
                    coh_slowgamma(ch1,ch2)=coh_slowgamma(ch2,ch1);
                    coh_theta(ch1,ch2)=coh_theta(ch2,ch1);
                    coh_fastgamma(ch1,ch2)=coh_fastgamma(ch2,ch1);
                    coh_beta(ch1,ch2)=coh_beta(ch2,ch1);
                    phase_gamma(ch1,ch2)=phase_gamma(ch2,ch1);
                    phase_slowgamma(ch1,ch2)=phase_slowgamma(ch2,ch1);
                    phase_theta(ch1,ch2)=phase_theta(ch2,ch1);
                    phase_fastgamma(ch1,ch2)=phase_fastgamma(ch2,ch1);
                    phase_beta(ch1,ch2)=phase_beta(ch2,ch1);
                end
            end
        end




        save([exp_dir '\ECHIP_coherence_shank' num2str(CA1DGshank) 'v' num2str(CA3shank) 'v' num2str(MECshank) 'v' num2str(LECshank) 'track' track '.mat'],'cohMATRIX','phaseMATRIX', 'SmnMATRIX','SmmMATRIX', 'fpass1', 'fpass2','freq','coh_gamma','coh_theta','coh_fastgamma','coh_slowgamma','coh_beta','phase_gamma','phase_theta','phase_fastgamma', 'phase_slowgamma', 'phase_beta');
        disp(['done with shank for animal ' animal]);
    
end

%    figure;
%    subplot(3,1,1);
%    imagesc(flipud(coh_theta)); 
%    subplot(3,1,2);
%    imagesc(flipud(coh_gamma)); 
%    subplot(3,1,3);
%    imagesc(flipud(coh_fastgamma)); 




  end
