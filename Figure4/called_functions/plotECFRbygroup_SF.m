%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script is to plot firing rate as bar plot for each group by animal and by units
%INPUT NEED TO BE UPDATED once new spike process is over - 6/14 (currently
%using not super correct DR calc method (not track specific and not devided
%by refined time peroid)
% INPUTS: 
% animal list
% exp.m
% track

% OUTPUTS:
% by animal by group firing rate plot for run_FR and non_run FR (MEC1/2/3)
% by unit by group firing rate plot for run_FR and non_run FR (MEC1/2/3)
% SF 6/10/22 (as for 6/12, only have run and NOT track specific at the moment, non_run is not ready yet)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS113-3' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%112-1 taken out since no master MEC; 113-2 out no master MEC


track = 1;
mFR=[];
FRmean = [];
highestFR = [];

animal_ind = {};
group_ind = {};
M1=[]; %MEC1
M2=[];
M3=[];

uind=0;  %master unit index

for a = 1:length(animals)
    animal = animals(a);
    exp_dir=get_exp(animal);
    load([exp_dir '\exp.mat'])
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
    for shank=[MECshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks
        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification
        if ~isempty(ch.MEC12) && ~isempty (ch.MEC11) %find units in MEC1
            M1units=find(units.correctclusterch>=ch.MEC12 & units.correctclusterch<ch.MEC11); 
            M1=[M1 M1units+uind];
        end
    
        if ~isempty(ch.MEC22) && ~isempty (ch.MEC21) %find units in MEC2
            M2units=find(units.correctclusterch>=ch.MEC22 & units.correctclusterch<ch.MEC21); 
            M2=[M2 M2units+uind];
        end
        
        if ~isempty(ch.MEC32) && ~isempty (ch.MEC31) %find units in MEC3
            M3units=find(units.correctclusterch>=ch.MEC32 & units.correctclusterch<ch.MEC31); 
            M3=[M3 M3units+uind];
        end
    
     %put spike attributes into master array
        for u=1:length(units.spikes)  %getting all the important info about each unit from file we loaded in earlier 
            %if ~isempty(units.spikes{u}) && units.numspikes(u) > 200 && units.refravio(u) < 0.6 %% && units.CA1thetaPL{u}.pval<0.05 &&  units.MECIIthetaPL{u}.pval<0.05  %refravio rate <= 0.6% will be a reasonable cluster to include in - sf
            uind=uind+1;
            animal_ind{uind} = animal;  %added this so I can know which animal each cluster belongs to for plotting later
            group_ind{uind} = group;
               
             if ~isempty(units.spikes{u}) %to deal with unit empty spikes
                numspikes(uind)=units.numspikes(u);
                refravio(uind)=units.refravio(u);

                mFR(uind)=units.mFR(u);   %toatl spike/total time
                FRmean(uind)=units.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                highestFR(uind)=units.highestFR(u);   % Method2: take the highest FR for certain length of time bins, use that as FR
                meanAC(uind)=unitswholetrack.meanAC(u); %mean of autocorr
                burst(uind)=units.burst(u);
                burstbw(uind) = units.burstbw(u);
                mISI(uind)=units.mISI(u);
                CSI(uind)=unitswholetrack.CSI(u);
                mAmp(uind)=units.mAmp(u);

                asym(uind)=unitswholetrack.wavesasym(u); 
                c(uind)=unitswholetrack.wavesc(u);
                FRmeanwhole(uind)=unitswholetrack.FRmean(u); %muse for clasification, calc by whole rec

             elseif isempty(units.spikes{u})
                 disp(['empty cluster' num2str(u) 'in animal ' animal])
             end
         end
    end %end each shank
end

% to identify the unqualified units
unqualifylist = [];
for u=1:length(mFR)
    if numspikes(u) < 200 || refravio(u) > 0.6
        unqualifylist = [u unqualifylist];
    end
end
%to take out from M1 M2 M3 unit list
M1_qua_ind=~ismember(M1,unqualifylist);  %set unqualified as 0, qualified as 1
M2_qua_ind=~ismember(M2,unqualifylist);  %set unqualified as 0, qualified as 1
M3_qua_ind=~ismember(M3,unqualifylist);  %set unqualified as 0, qualified as 1
M1 = M1(M1_qua_ind(:) == 1);
M2 = M2(M2_qua_ind(:) == 1);
M3 = M3(M3_qua_ind(:) == 1);


%%
% CLUSTER! !WITH UNQUALIFIED UNITS! )maybe i should take out unqualified here? - sf)
% **********use this for EC***********
x=[ c'  ]; %options: %meanAC' asym2' meanAC'  mISI' c2' mFR'  %only c works best for MEC   
%T=clusterdata(x,2); %matlab function to create clusters - this doesn't seem to get used again though??
[idx,C] = kmeans(x,2); %sort into two clusters and return cluster centroid locations?
[M, I]=max(C(:,1)); %finds indices of max value and puts them in output vector I
exc=find(idx==I);  %getting excitatory and inhibitory cells
inh=find(idx~=I);


figure(2);clf; scatter3(mFR(exc),c(exc),asym(exc),20, 'g');
hold on; scatter3(mFR(inh),c(inh),asym(inh),20,'r');
xlabel('Firing Rate')
ylabel('c')
zlabel('Asym')
title('All MEC Cells');

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
g_ccells = find(genotype_ind == 1 | genotype_ind == 3);

eM1=intersect(exc,M1);  
iM1=intersect(inh,M1); 
eM2=intersect(exc,M2);  
iM2=intersect(inh,M2); 
eM3=intersect(exc,M3); 
iM3=intersect(inh,M3); 

eM1_3wc = intersect(g_3wccells, eM1);
eM1_3wp = intersect(g_3wpcells, eM1);
eM1_8wc = intersect(g_8wccells, eM1);
eM1_8wp = intersect(g_8wpcells, eM1);
eM1_c = intersect(g_ccells, eM1);

iM1_3wc = intersect(g_3wccells, iM1);
iM1_3wp = intersect(g_3wpcells, iM1);
iM1_8wc = intersect(g_8wccells, iM1);
iM1_8wp = intersect(g_8wpcells, iM1);
iM1_c = intersect(g_ccells, iM1);

eM2_3wc = intersect(g_3wccells, eM2);
eM2_3wp = intersect(g_3wpcells, eM2);
eM2_8wc = intersect(g_8wccells, eM2);
eM2_8wp = intersect(g_8wpcells, eM2);
eM2_c = intersect(g_ccells, eM2);

iM2_3wc = intersect(g_3wccells, iM2);
iM2_3wp = intersect(g_3wpcells, iM2);
iM2_8wc = intersect(g_8wccells, iM2);
iM2_8wp = intersect(g_8wpcells, iM2);
iM2_c = intersect(g_ccells, iM2);


eM3_3wc = intersect(g_3wccells, eM3);
eM3_3wp = intersect(g_3wpcells, eM3);
eM3_8wc = intersect(g_8wccells, eM3); 
eM3_8wp = intersect(g_8wpcells, eM3);
eM3_c = intersect(g_ccells, eM3);

iM3_3wc = intersect(g_3wccells, iM3);
iM3_3wp = intersect(g_3wpcells, iM3);
iM3_8wc = intersect(g_8wccells, iM3);
iM3_8wp = intersect(g_8wpcells, iM3);
iM3_c = intersect(g_ccells, iM3);


%%%%%%%%%%%%%%%%

%% PLOT firing rate for each group by unit
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_FR\MECunits\';
if exist(savepath)==0
     mkdir(savepath);
end
%FRmean (method1)
%%% M1 exc %%%
% data = {FRmean(eM1_3wc), FRmean(eM1_3wp)};
% title_name = 'FRmean Value of MEC1 Exc Units (3w)';
% scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
% data = {FRmean(eM1_8wc), FRmean(eM1_8wp)};
% title_name = 'FRmean Value of MEC1 Exc Units (8w)';
% scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
% data = {FRmean(eM1_3wp), FRmean(eM1_8wp)};
% title_name = 'FRmean Value of MEC1 Exc Units (3w vs 8w)';
% scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
% %%% M1 inh %%%
% data = {FRmean(iM1_3wc), FRmean(iM1_3wp)};
% title_name = 'FRmean Value of MEC1 Inh Units (3w)';
% scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
% data = {FRmean(iM1_8wc), FRmean(iM1_8wp)};
% title_name = 'FRmean Value of MEC1 Inh Units (8w)';
% scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
% data = {FRmean(iM1_3wp), FRmean(iM1_8wp)};
% title_name = 'FRmean Value of MEC1 Inh Units (3w vs 8w)';
% scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% M2 exc %%%
data = {FRmean(eM2_3wc), FRmean(eM2_3wp)};
title_name = 'FRmean Value of MEC2 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eM2_8wc), FRmean(eM2_8wp)};
title_name = 'FRmean Value of MEC2 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eM2_3wp), FRmean(eM2_8wp)};
title_name = 'FRmean Value of MEC2 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% M2 inh %%%
data = {FRmean(iM2_3wc), FRmean(iM2_3wp)};
title_name = 'FRmean Value of MEC2 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iM2_8wc), FRmean(iM2_8wp)};
title_name = 'FRmean Value of MEC2 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iM2_3wp), FRmean(iM2_8wp)};
title_name = 'FRmean Value of MEC2 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% M3 exc %%%
data = {FRmean(eM3_3wc), FRmean(eM3_3wp)};
title_name = 'FRmean Value of MEC3 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eM3_8wc), FRmean(eM3_8wp)};
title_name = 'FRmean Value of MEC3 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(eM3_3wp), FRmean(eM3_8wp)};
title_name = 'FRmean Value of MEC3 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% M3 inh %%%
data = {FRmean(iM3_3wc), FRmean(iM3_3wp)};
title_name = 'FRmean Value of MEC3 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iM3_8wc), FRmean(iM3_8wp)};
title_name = 'FRmean Value of MEC3 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {FRmean(iM3_3wp), FRmean(iM3_8wp)};
title_name = 'FRmean Value of MEC3 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);



%highestFR (method2)
%%% M1 exc %%%
% data = {highestFR(eM1_3wc), highestFR(eM1_3wp)};
% title_name = 'highestFR Value of MEC1 Exc Units (3w)';
% scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
% data = {highestFR(eM1_8wc), highestFR(eM1_8wp)};
% title_name = 'highestFR Value of MEC1 Exc Units (8w)';
% scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
% data = {highestFR(eM1_3wp), highestFR(eM1_8wp)};
% title_name = 'highestFR Value of MEC1 Exc Units (3w vs 8w)';
% scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
% %%% M1 inh %%%
% data = {highestFR(iM1_3wc), highestFR(iM1_3wp)};
% title_name = 'highestFR Value of MEC1 Inh Units (3w)';
% scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
% data = {highestFR(iM1_8wc), highestFR(iM1_8wp)};
% title_name = 'highestFR Value of MEC1 Inh Units (8w)';
% scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
% data = {highestFR(iM1_3wp), highestFR(iM1_8wp)};
% title_name = 'highestFR Value of MEC1 Inh Units (3w vs 8w)';
% scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% M2 exc %%%
data = {highestFR(eM2_3wc), highestFR(eM2_3wp)};
title_name = 'highestFR Value of MEC2 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eM2_8wc), highestFR(eM2_8wp)};
title_name = 'highestFR Value of MEC2 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eM2_3wp), highestFR(eM2_8wp)};
title_name = 'highestFR Value of MEC2 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% M2 inh %%%
data = {highestFR(iM2_3wc), highestFR(iM2_3wp)};
title_name = 'highestFR Value of MEC2 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iM2_8wc), highestFR(iM2_8wp)};
title_name = 'highestFR Value of MEC2 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iM2_3wp), highestFR(iM2_8wp)};
title_name = 'highestFR Value of MEC2 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% M3 exc %%%
data = {highestFR(eM3_3wc), highestFR(eM3_3wp)};
title_name = 'highestFR Value of MEC3 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eM3_8wc), highestFR(eM3_8wp)};
title_name = 'highestFR Value of MEC3 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(eM3_3wp), highestFR(eM3_8wp)};
title_name = 'highestFR Value of MEC3 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% M3 inh %%%
data = {highestFR(iM3_3wc), highestFR(iM3_3wp)};
title_name = 'highestFR Value of MEC3 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iM3_8wc), highestFR(iM3_8wp)};
title_name = 'highestFR Value of MEC3 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {highestFR(iM3_3wp), highestFR(iM3_8wp)};
title_name = 'highestFR Value of MEC3 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%mFR (method2)
% %%% M1 exc %%%
% data = {mFR(eM1_3wc), mFR(eM1_3wp)};
% title_name = 'mFR Value of MEC1 Exc Units (3w)';
% scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
% data = {mFR(eM1_8wc), mFR(eM1_8wp)};
% title_name = 'mFR Value of MEC1 Exc Units (8w)';
% scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
% data = {mFR(eM1_3wp), mFR(eM1_8wp)};
% title_name = 'mFR Value of MEC1 Exc Units (3w vs 8w)';
% scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
% %%% M1 inh %%%
% data = {mFR(iM1_3wc), mFR(iM1_3wp)};
% title_name = 'mFR Value of MEC1 Inh Units (3w)';
% scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
% data = {mFR(iM1_8wc), mFR(iM1_8wp)};
% title_name = 'mFR Value of MEC1 Inh Units (8w)';
% scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
% data = {mFR(iM1_3wp), mFR(iM1_8wp)};
% title_name = 'mFR Value of MEC1 Inh Units (3w vs 8w)';
% scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% M2 exc %%%
data = {mFR(eM2_3wc), mFR(eM2_3wp)};
title_name = 'mFR Value of MEC2 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eM2_8wc), mFR(eM2_8wp)};
title_name = 'mFR Value of MEC2 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eM2_3wp), mFR(eM2_8wp)};
title_name = 'mFR Value of MEC2 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% M2 inh %%%
data = {mFR(iM2_3wc), mFR(iM2_3wp)};
title_name = 'mFR Value of MEC2 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iM2_8wc), mFR(iM2_8wp)};
title_name = 'mFR Value of MEC2 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iM2_3wp), mFR(iM2_8wp)};
title_name = 'mFR Value of MEC2 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%%% M3 exc %%%
data = {mFR(eM3_3wc), mFR(eM3_3wp)};
title_name = 'mFR Value of MEC3 Exc Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eM3_8wc), mFR(eM3_8wp)};
title_name = 'mFR Value of MEC3 Exc Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(eM3_3wp), mFR(eM3_8wp)};
title_name = 'mFR Value of MEC3 Exc Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);
%%% M3 inh %%%
data = {mFR(iM3_3wc), mFR(iM3_3wp)};
title_name = 'mFR Value of MEC3 Inh Units (3w)';
scatterBars_FR_SF(data, {'3wc', '3wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iM3_8wc), mFR(iM3_8wp)};
title_name = 'mFR Value of MEC3 Inh Units (8w)';
scatterBars_FR_SF(data, {'8wc', '8wp'}, {'blue', 'red'}, title_name, savepath);
data = {mFR(iM3_3wp), mFR(iM3_8wp)};
title_name = 'mFR Value of MEC3 Inh Units (3w vs 8w)';
scatterBars_FR_SF(data, {'3wp', '8wp'}, {'magenta', 'red'}, title_name, savepath);

%% combined control
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_FR\MECunits\combinedcontrol\';
if exist(savepath)==0
     mkdir(savepath);
end

%%%%%%%%%%%%%%%%%%%%%%FRmean%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% M2 exc %%%
data = {FRmean(eM2_c), FRmean(eM2_3wp), FRmean(eM2_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of M2 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(1,1) = {convertCharsToStrings(title_name)};
pvallist_r(1,1) = results(1,6); %control vs 3wp
pvallist_r(1,2) = results(2,6); %control vs 8wp
pvallist_r(1,3) = results(3,6); %3wp vs 8wp

%%% M2 inh %%%
data = {FRmean(iM2_c), FRmean(iM2_3wp), FRmean(iM2_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of M2 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(2,1) = {convertCharsToStrings(title_name)};
pvallist_r(2,1) = results(1,6); %control vs 3wp
pvallist_r(2,2) = results(2,6); %control vs 8wp
pvallist_r(2,3) = results(3,6); %3wp vs 8wp

%%% M3 Exc %%%
data = {FRmean(eM3_c), FRmean(eM3_3wp), FRmean(eM3_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of M3 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(3,1) = {convertCharsToStrings(title_name)};
pvallist_r(3,1) = results(1,6); %control vs 3wp
pvallist_r(3,2) = results(2,6); %control vs 8wp
pvallist_r(3,3) = results(3,6); %3wp vs 8wp

%%% M3 Inh %%%
data = {FRmean(iM3_c), FRmean(iM3_3wp), FRmean(iM3_8wp)}; %data use for plot and stats
title_name = 'FRmean Value of M3 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(4,1) = {convertCharsToStrings(title_name)};
pvallist_r(4,1) = results(1,6); %control vs 3wp
pvallist_r(4,2) = results(2,6); %control vs 8wp
pvallist_r(4,3) = results(3,6); %3wp vs 8wp

%%%%%%%%%%%%%%%%%%%%%%highestFR%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% M2 exc %%%
data = {highestFR(eM2_c), highestFR(eM2_3wp), highestFR(eM2_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of M2 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(5,1) = {convertCharsToStrings(title_name)};
pvallist_r(5,1) = results(1,6); %control vs 3wp
pvallist_r(5,2) = results(2,6); %control vs 8wp
pvallist_r(5,3) = results(3,6); %3wp vs 8wp

%%% M2 inh %%%
data = {highestFR(iM2_c), highestFR(iM2_3wp), highestFR(iM2_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of M2 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(6,1) = {convertCharsToStrings(title_name)};
pvallist_r(6,1) = results(1,6); %control vs 3wp
pvallist_r(6,2) = results(2,6); %control vs 8wp
pvallist_r(6,3) = results(3,6); %3wp vs 8wp

%%% M3 Exc %%%
data = {highestFR(eM3_c), highestFR(eM3_3wp), highestFR(eM3_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of M3 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(7,1) = {convertCharsToStrings(title_name)};
pvallist_r(7,1) = results(1,6); %control vs 3wp
pvallist_r(7,2) = results(2,6); %control vs 8wp
pvallist_r(7,3) = results(3,6); %3wp vs 8wp

%%% M3 Inh %%%
data = {highestFR(iM3_c), highestFR(iM3_3wp), highestFR(iM3_8wp)}; %data use for plot and stats
title_name = 'highestFR Value of M3 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(8,1) = {convertCharsToStrings(title_name)};
pvallist_r(8,1) = results(1,6); %control vs 3wp
pvallist_r(8,2) = results(2,6); %control vs 8wp
pvallist_r(8,3) = results(3,6); %3wp vs 8wp

%%%%%%%%%%%%%%%%%%%%%%mFR%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% M2 exc %%%
data = {mFR(eM2_c), mFR(eM2_3wp), mFR(eM2_8wp)}; %data use for plot and stats
title_name = 'mFR Value of M2 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(9,1) = {convertCharsToStrings(title_name)};
pvallist_r(9,1) = results(1,6); %control vs 3wp
pvallist_r(9,2) = results(2,6); %control vs 8wp
pvallist_r(9,3) = results(3,6); %3wp vs 8wp

%%% M2 inh %%%
data = {mFR(iM2_c), mFR(iM2_3wp), mFR(iM2_8wp)}; %data use for plot and stats
title_name = 'mFR Value of M2 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(10,1) = {convertCharsToStrings(title_name)};
pvallist_r(10,1) = results(1,6); %control vs 3wp
pvallist_r(10,2) = results(2,6); %control vs 8wp
pvallist_r(10,3) = results(3,6); %3wp vs 8wp

%%% M3 Exc %%%
data = {mFR(eM3_c), mFR(eM3_3wp), mFR(eM3_8wp)}; %data use for plot and stats
title_name = 'mFR Value of M3 Exc Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(11,1) = {convertCharsToStrings(title_name)};
pvallist_r(11,1) = results(1,6); %control vs 3wp
pvallist_r(11,2) = results(2,6); %control vs 8wp
pvallist_r(11,3) = results(3,6); %3wp vs 8wp

%%% M3 Inh %%%
data = {mFR(iM3_c), mFR(iM3_3wp), mFR(iM3_8wp)}; %data use for plot and stats
title_name = 'mFR Value of M3 Inh Units';
[results] = scatterBars_FR_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);
titlelist_r(12,1) = {convertCharsToStrings(title_name)};
pvallist_r(12,1) = results(1,6); %control vs 3wp
pvallist_r(12,2) = results(2,6); %control vs 8wp
pvallist_r(12,3) = results(3,6); %3wp vs 8wp


%save r pval table
r_pvaltable = table(titlelist_r, pvallist_r); %write pval to a table
writetable(r_pvaltable, 'L:\Susie\singleunit_FR\MECunits\combinedcontrol\FR_pvaltable_MEC.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 