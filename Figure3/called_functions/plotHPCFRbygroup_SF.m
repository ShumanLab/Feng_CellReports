%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script is to plot HPC firing rate as bar plot for each group by animal and by units
%by refined time peroid)
% INPUTS: 
% animal list
% exp.m
% track
% shank_processedunits_run_trackx
% shank_processedunitswholetrack

% OUTPUTS:
% by animal by group firing rate plot for run_FR and non_run FR (HPC CA1 and DG)
% by unit by group firing rate plot for run_FR and non_run FR (HPC CA1 and DG)
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

uind=0;  %master unit index

for a = 1:length(animals)
    animal = animals(a);
    exp_dir=get_exp(animal);
    load([exp_dir '\exp.mat'])
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
    for shank=[CA1DGshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks
        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification
      
        if ~isempty(ch.Pyr2) && ~isempty (ch.Pyr1) %find units in oriens or pyr 
            CA1units=find(units.correctclusterch>=ch.Pyr2 & units.correctclusterch<=ch.Pyr1); %currently only including pyr (previously wa both or and pyr)  
            CA1=[CA1 CA1units+uind];  
        end
        if ~isempty(ch.Hil2) && ~isempty (ch.GC1)  %find units in GCL or Hilus 
            DGunits=find(units.correctclusterch>=ch.Hil2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
            DG=[DG DGunits+uind];
        end
    
     %put spike attributes into master array
        for u=1:length(units.spikes)  %getting all the important info about each unit from file we loaded in earlier 
            uind=uind+1;
            animal_ind{uind} = animal;  %added this so I can know which animal each cluster belongs to for plotting later
            group_ind{uind} = group;
               
             if ~isempty(units.spikes{u}) %to deal with unit empty spikes
                numspikes(uind)=units.numspikes(u);
                refravio(uind)=units.refravio(u);
                %asym(uind)=unitswholetrack.wavesasym; 
                %c(uind)=unitswholetrack.wavesc;
                mFR(uind)=units.mFR(u);   %toatl spike/total time
                FRmean(uind)=units.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                highestFR(uind)=units.highestFR(u);   % Method2: take the highest FR for certain length of time bins, use that as FR
                burst(uind)=units.burst(u);
                burstbw(uind) = units.burstbw(u);
                mISI(uind)=units.mISI(u);
                mAmp(uind)=units.mAmp(u);

                CSI(uind)=unitswholetrack.CSI(u);
                meanAC(uind)=unitswholetrack.meanAC(u); %mean of autocorr
                FRmeanwhole(uind)=unitswholetrack.FRmean(u); %muse for clasification, calc by whole rec


             elseif isempty(units.spikes{u})
                 disp(['empty cluster' num2str(u) 'in animal ' animal])
             end
         end
    end %end each shank
end %end animal

% to identify the unqualified units
unqualifylist = [];
for u=1:length(mFR)
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

 %%
genotype_ind = zeros(length(group_ind), 1);  %make logical index for genotype
for i=1:length(genotype_ind)
    if group_ind{i} == '3wc'
       genotype_ind(i) = 1;
    elseif group_ind{i} == '3wp'
        genotype_ind(i) = 2;
    elseif group_ind{i} == '8wc'
        genotype_ind(i) = 3;
    elseif group_ind{i} == '8wp'
        genotype_ind(i) = 4;
    end
end


g_3wccells = find(genotype_ind == 1);  %find indices of all 3wc cells
g_3wpcells=find(genotype_ind == 2);     %find indices of all 3wp cells 
g_8wccells=find(genotype_ind == 3);     %find indices of all 8wc cells 
g_8wpcells=find(genotype_ind == 4);     %find indices of all 8wp cells 
g_ccells = find(genotype_ind == 1 | genotype_ind == 3); %find all control cells


eDG=intersect(exc,DG);  
iDG=intersect(inh,DG); 
eCA1=intersect(exc,CA1); 
iCA1=intersect(inh,CA1); 

eDG_3wc = intersect(g_3wccells, eDG);
eDG_3wp = intersect(g_3wpcells, eDG);
eDG_8wc = intersect(g_8wccells, eDG);
eDG_8wp = intersect(g_8wpcells, eDG);
eDG_c = intersect(g_ccells, eDG);

iDG_3wc = intersect(g_3wccells, iDG);
iDG_3wp = intersect(g_3wpcells, iDG);
iDG_8wc = intersect(g_8wccells, iDG);
iDG_8wp = intersect(g_8wpcells, iDG);
iDG_c = intersect(g_ccells, iDG);

eCA1_3wc = intersect(g_3wccells, eCA1);
eCA1_3wp = intersect(g_3wpcells, eCA1);
eCA1_8wc = intersect(g_8wccells, eCA1);
eCA1_8wp = intersect(g_8wpcells, eCA1);
eCA1_c = intersect(g_ccells, eCA1);

iCA1_3wc = intersect(g_3wccells, iCA1);
iCA1_3wp = intersect(g_3wpcells, iCA1);
iCA1_8wc = intersect(g_8wccells, iCA1);
iCA1_8wp = intersect(g_8wpcells, iCA1);
iCA1_c = intersect(g_ccells, iCA1);
%%%%%%%%%%%%%%%%

%% PLOT firing rate for each group by unit
%savepath='L:\Susie\singleunit_FR\HPCunits';
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_FR\HPCunits\';
if exist(savepath)==0
     mkdir(savepath);
end
%FRmean (method1)
%%% CA1 exc %%%
data = {FRmean(eCA1_3wc), FRmean(eCA1_3wp)};
title_name = 'FRmean Value of CA1 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eCA1_8wc), FRmean(eCA1_8wp)};
title_name = 'FRmean Value of CA1 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eCA1_3wp), FRmean(eCA1_8wp)};
title_name = 'FRmean Value of CA1 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% CA1 inh %%%
data = {FRmean(iCA1_3wc), FRmean(iCA1_3wp)};
title_name = 'FRmean Value of CA1 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iCA1_8wc), FRmean(iCA1_8wp)};
title_name = 'FRmean Value of CA1 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iCA1_3wp), FRmean(iCA1_8wp)};
title_name = 'FRmean Value of CA1 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% DG exc %%%
data = {FRmean(eDG_3wc), FRmean(eDG_3wp)};
title_name = 'FRmean Value of DG Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eDG_8wc), FRmean(eDG_8wp)};
title_name = 'FRmean Value of DG Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eDG_3wp), FRmean(eDG_8wp)};
title_name = 'FRmean Value of DG Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% DG inh %%%
data = {FRmean(iDG_3wc), FRmean(iDG_3wp)};
title_name = 'FRmean Value of DG Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iDG_8wc), FRmean(iDG_8wp)};
title_name = 'FRmean Value of DG Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iDG_3wp), FRmean(iDG_8wp)};
title_name = 'FRmean Value of DG Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);



%highestFR (method2)
%%% CA1 exc %%%
data = {highestFR(eCA1_3wc), highestFR(eCA1_3wp)};
title_name = 'highestFR Value of CA1 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eCA1_8wc), highestFR(eCA1_8wp)};
title_name = 'highestFR Value of CA1 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eCA1_3wp), highestFR(eCA1_8wp)};
title_name = 'highestFR Value of CA1 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% CA1 inh %%%
data = {highestFR(iCA1_3wc), highestFR(iCA1_3wp)};
title_name = 'highestFR Value of CA1 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iCA1_8wc), highestFR(iCA1_8wp)};
title_name = 'highestFR Value of CA1 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iCA1_3wp), highestFR(iCA1_8wp)};
title_name = 'highestFR Value of CA1 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% DG exc %%%
data = {highestFR(eDG_3wc), highestFR(eDG_3wp)};
title_name = 'highestFR Value of DG Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eDG_8wc), highestFR(eDG_8wp)};
title_name = 'highestFR Value of DG Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eDG_3wp), highestFR(eDG_8wp)};
title_name = 'highestFR Value of DG Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% DG inh %%%
data = {highestFR(iDG_3wc), highestFR(iDG_3wp)};
title_name = 'highestFR Value of DG Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iDG_8wc), highestFR(iDG_8wp)};
title_name = 'highestFR Value of DG Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iDG_3wp), highestFR(iDG_8wp)};
title_name = 'highestFR Value of DG Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);


%mFR (method2)
%%% CA1 exc %%%
data = {mFR(eCA1_3wc), mFR(eCA1_3wp)};
title_name = 'mFR Value of CA1 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eCA1_8wc), mFR(eCA1_8wp)};
title_name = 'mFR Value of CA1 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eCA1_3wp), mFR(eCA1_8wp)};
title_name = 'mFR Value of CA1 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% CA1 inh %%%
data = {mFR(iCA1_3wc), mFR(iCA1_3wp)};
title_name = 'mFR Value of CA1 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iCA1_8wc), mFR(iCA1_8wp)};
title_name = 'mFR Value of CA1 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iCA1_3wp), mFR(iCA1_8wp)};
title_name = 'mFR Value of CA1 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% DG exc %%%
data = {mFR(eDG_3wc), mFR(eDG_3wp)};
title_name = 'mFR Value of DG Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eDG_8wc), mFR(eDG_8wp)};
title_name = 'mFR Value of DG Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eDG_3wp), mFR(eDG_8wp)};
title_name = 'mFR Value of DG Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% DG inh %%%
data = {mFR(iDG_3wc), mFR(iDG_3wp)};
title_name = 'mFR Value of DG Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iDG_8wc), mFR(iDG_8wp)};
title_name = 'mFR Value of DG Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iDG_3wp), mFR(iDG_8wp)};
title_name = 'mFR Value of DG Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%% conbiend control plot
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_FR\HPC\combinedcontrol\';
if exist(savepath)==0
     mkdir(savepath);
end
%%%%%%%%%%%%%%%%%%%%%%FRmean%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CA1 exc %%%
data = {FRmean(eCA1_c), FRmean(eCA1_3wp), FRmean(eCA1_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of CA1 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(1,1) = {convertCharsToStrings(title_name)};
pvallist_r(1,1) = results(1,6); %control vs 3wp
pvallist_r(1,2) = results(2,6); %control vs 8wp
pvallist_r(1,3) = results(3,6); %3wp vs 8wp

%%% CA1 inh %%%
data = {FRmean(iCA1_c), FRmean(iCA1_3wp), FRmean(iCA1_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of CA1 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(2,1) = {convertCharsToStrings(title_name)};
pvallist_r(2,1) = results(1,6); %control vs 3wp
pvallist_r(2,2) = results(2,6); %control vs 8wp
pvallist_r(2,3) = results(3,6); %3wp vs 8wp

%%% DG Exc %%%
data = {FRmean(eDG_c), FRmean(eDG_3wp), FRmean(eDG_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of DG Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(3,1) = {convertCharsToStrings(title_name)};
pvallist_r(3,1) = results(1,6); %control vs 3wp
pvallist_r(3,2) = results(2,6); %control vs 8wp
pvallist_r(3,3) = results(3,6); %3wp vs 8wp

%%% DG Inh %%%
data = {FRmean(iDG_c), FRmean(iDG_3wp), FRmean(iDG_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of DG Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(4,1) = {convertCharsToStrings(title_name)};
pvallist_r(4,1) = results(1,6); %control vs 3wp
pvallist_r(4,2) = results(2,6); %control vs 8wp
pvallist_r(4,3) = results(3,6); %3wp vs 8wp

%%%%%%%%%%%%%%%%%%%%%%highestFR%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CA1 exc %%%
data = {highestFR(eCA1_c), highestFR(eCA1_3wp), highestFR(eCA1_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of CA1 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(5,1) = {convertCharsToStrings(title_name)};
pvallist_r(5,1) = results(1,6); %control vs 3wp
pvallist_r(5,2) = results(2,6); %control vs 8wp
pvallist_r(5,3) = results(3,6); %3wp vs 8wp

%%% CA1 inh %%%
data = {highestFR(iCA1_c), highestFR(iCA1_3wp), highestFR(iCA1_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of CA1 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(6,1) = {convertCharsToStrings(title_name)};
pvallist_r(6,1) = results(1,6); %control vs 3wp
pvallist_r(6,2) = results(2,6); %control vs 8wp
pvallist_r(6,3) = results(3,6); %3wp vs 8wp

%%% DG Exc %%%
data = {highestFR(eDG_c), highestFR(eDG_3wp), highestFR(eDG_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of DG Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(7,1) = {convertCharsToStrings(title_name)};
pvallist_r(7,1) = results(1,6); %control vs 3wp
pvallist_r(7,2) = results(2,6); %control vs 8wp
pvallist_r(7,3) = results(3,6); %3wp vs 8wp

%%% DG Inh %%%
data = {highestFR(iDG_c), highestFR(iDG_3wp), highestFR(iDG_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of DG Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(8,1) = {convertCharsToStrings(title_name)};
pvallist_r(8,1) = results(1,6); %control vs 3wp
pvallist_r(8,2) = results(2,6); %control vs 8wp
pvallist_r(8,3) = results(3,6); %3wp vs 8wp

%%%%%%%%%%%%%%%%%%%%%%mFR%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CA1 exc %%%
data = {mFR(eCA1_c), mFR(eCA1_3wp), mFR(eCA1_8wp)}; %data use for plot and stats
title_name = 'mFR Value of CA1 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(9,1) = {convertCharsToStrings(title_name)};
pvallist_r(9,1) = results(1,6); %control vs 3wp
pvallist_r(9,2) = results(2,6); %control vs 8wp
pvallist_r(9,3) = results(3,6); %3wp vs 8wp

%%% CA1 inh %%%
data = {mFR(iCA1_c), mFR(iCA1_3wp), mFR(iCA1_8wp)}; %data use for plot and stats
title_name = 'mFR Value of CA1 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(10,1) = {convertCharsToStrings(title_name)};
pvallist_r(10,1) = results(1,6); %control vs 3wp
pvallist_r(10,2) = results(2,6); %control vs 8wp
pvallist_r(10,3) = results(3,6); %3wp vs 8wp

%%% DG Exc %%%
data = {mFR(eDG_c), mFR(eDG_3wp), mFR(eDG_8wp)}; %data use for plot and stats
title_name = 'mFR Value of DG Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(11,1) = {convertCharsToStrings(title_name)};
pvallist_r(11,1) = results(1,6); %control vs 3wp
pvallist_r(11,2) = results(2,6); %control vs 8wp
pvallist_r(11,3) = results(3,6); %3wp vs 8wp

%%% DG Inh %%%
data = {mFR(iDG_c), mFR(iDG_3wp), mFR(iDG_8wp)}; %data use for plot and stats
title_name = 'mFR Value of DG Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(12,1) = {convertCharsToStrings(title_name)};
pvallist_r(12,1) = results(1,6); %control vs 3wp
pvallist_r(12,2) = results(2,6); %control vs 8wp
pvallist_r(12,3) = results(3,6); %3wp vs 8wp


%save r pval table
r_pvaltable = table(titlelist_r, pvallist_r); %write pval to a table
writetable(r_pvaltable, 'L:\Susie\singleunit_FR\HPCunits\combinedcontrol\FR_pvaltable.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
