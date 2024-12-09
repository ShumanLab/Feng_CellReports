%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script is to plot HPC firing rate as bar plot for each group by animal
%by refined time peroid)
% INPUTS: 
% animal list
% exp.m
% track
% shank_processedunits_run_trackx
% shank_processedunitswholetrack

% OUTPUTS:
% by animal by group firing rate plot for run_FR and non_run FR (HPC CA1 and DG)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1'  'TS114-3'  'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3'  'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'};  %list of animal have master CA1DG shank that can be processed here %TS112-1 TS113-2 don't have MEC master shank
track = 1;


mFR=[];
FRmean = [];
FRmeanwhole = [];
highestFR = [];
animal_ind = {};
group_ind = {};
CA1=[]; 
DG=[];


for a = 1:length(animals)
    uind=0;  %master unit index (need to be under animal here for it to reset every round

    animal = animals(a);
    exp_dir=get_exp(animal);
    load([exp_dir '\exp.mat'])
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);

    for shank=[CA1DGshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks
        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification
      
        if ~isempty(ch.Pyr2) && ~isempty (ch.Pyr1) %find units in oriens or pyr 
            CA1=find(units.correctclusterch>=ch.Pyr2 & units.correctclusterch<=ch.Pyr1); %currently only including pyr (previously wa both or and pyr)  
        end
        if ~isempty(ch.Hil2) && ~isempty (ch.GC1)  %find units in GCL or Hilus 
            DG=find(units.correctclusterch>=ch.Hil2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
        end

        for u=1:length(units.waveforms)  %getting all the important info about each unit from file we loaded in earlier 
            uind=uind+1;
            animal_ind{uind} = animal;  %added this so I can know which animal each cluster belongs to for plotting later
            group_ind{uind} = group;

            if ~isempty(units.spikes{u}) 
                numspikes(uind)=units.numspikes(u);
                refravio(uind)=units.refravio(u);
                %asym(uind)=unitswholetrack.wavesasym; 
                %c(uind)=unitswholetrack.wavesc;
                FRmeanwhole(uind)=unitswholetrack.FRmean(u); %use for clasification, calc by whole rec
                mFR(uind)=units.mFR(u);   %toatl spike/total time
                FRmean(uind)=units.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                highestFR(uind)=units.highestFR(u);   % Method2: take the highest FR for certain length of time bins, use that as FR
                meanAC(uind)=unitswholetrack.meanAC(u); %mean of autocorr
                burst(uind)=units.burst(u);
                burstbw(uind) = units.burstbw(u);
                mISI(uind)=units.mISI(u);
                CSI(uind)=unitswholetrack.CSI(u);
                mAmp(uind)=units.mAmp(u);
        
             elseif isempty(units.spikes{u})
                 disp(['empty cluster' num2str(u) 'in animal ' animal])
            end
        end
    end   %END FOR each shank 

       % to identify the unqualified units
    unqualifylist = [];
    for u=1:length(FRmean)
        if numspikes(u) < 200 || refravio(u) > 0.6
            unqualifylist = [u unqualifylist];
        end
    end
    %to take out from M1 M2 M3 unit list
    CA1_qua_ind=~ismember(CA1,unqualifylist);  %set unqualified as 0, qualified as 1
    DG_qua_ind=~ismember(DG,unqualifylist);  %set unqualified as 0, qualified as 1
    CA1 = CA1(CA1_qua_ind(:) == 1);
    DG = DG(DG_qua_ind(:) == 1);

    
    %% CLUSTER
    type = [];
    for idx=1:length(CSI)
        if CSI(idx)<20 && meanAC(idx)> 0.11 && FRmeanwhole(idx)>=2.5
             type(idx)=1;
        elseif CSI(idx) > 5 && meanAC(idx)<0.11 && FRmeanwhole(idx)<8   %susie change FR from 5 to 5.5 since using FRmean now
             type(idx)=2;
         else
             type(idx)=3;
        end
    end
    inh = find(type == 1);
    exc = find(type == 2);
    weird = find(type == 3);
    
    %all cells all animals
     figure(1);clf; scatter3(FRmean(exc),CSI(exc), meanAC(exc), 20, 'g');
     hold on; scatter3(FRmean(inh),CSI(inh), meanAC(inh), 20,'r');
     hold on; scatter3(FRmean(weird),CSI(weird),meanAC(weird), 20,'y');
     xlabel('Firing Rate')
     ylabel('CSI')
     zlabel('meanAC')
     title('All animals')



    eDG=intersect(exc,DG);  
    iDG=intersect(inh,DG); 
    eCA1=intersect(exc,CA1); 
    iCA1=intersect(inh,CA1); 


        % PLOT firing rate for this animal
    %below is to plot polarscatter plot for exc cell and inh cell
    if group == '3wc'
        savepath = 'L:\Susie\singleunit_FR\byanimal\HPC\3wc';
        if exist(savepath)==0
             mkdir(savepath);
        end
    elseif group == '3wp'
        savepath = 'L:\Susie\singleunit_FR\byanimal\HPC\3wp';
        if exist(savepath)==0
             mkdir(savepath);
        end
     elseif group == '8wc'
        savepath = 'L:\Susie\singleunit_FR\byanimal\HPC\8wc';
        if exist(savepath)==0
             mkdir(savepath);
        end
     elseif group == '8wp'
        savepath = 'L:\Susie\singleunit_FR\byanimal\HPC\8wp';
        if exist(savepath)==0
             mkdir(savepath);
        end
    end


    data = {FRmean(eCA1), highestFR(eCA1), mFR(eCA1)};
    title_name = [animal ' ' group ' Firing Rate Value of CA1 Exc Units'];
    scatterBars_FR_SF(data, {'FRmean', 'highestFR', 'mFR'}, {'blue', 'red','yellow'}, title_name, savepath);

    data = {FRmean(iCA1), highestFR(iCA1), mFR(iCA1)};
    title_name = [animal ' ' group  ' Firing Rate Value of CA1 Inh Units'];
    scatterBars_FR_SF(data, {'FRmean', 'highestFR', 'mFR'}, {'blue', 'red','yellow'}, title_name, savepath);

    data = {FRmean(eDG), highestFR(eDG), mFR(eDG)};
    title_name = [animal ' ' group ' Firing Rate Value of DG Exc Units'];
    scatterBars_FR_SF(data, {'FRmean', 'highestFR', 'mFR'}, {'blue', 'red','yellow'}, title_name, savepath);

    data = {FRmean(iDG), highestFR(iDG), mFR(iDG)};
    title_name = [animal ' ' group ' Firing Rate Value of DG Inh Units'];
    scatterBars_FR_SF(data, {'FRmean', 'highestFR', 'mFR'}, {'blue', 'red','yellow'}, title_name, savepath);

clear CA1 DG;

end  %end for each animal
%close all
