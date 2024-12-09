%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to plot HPC and MEC exc and inh cluster for paper
% susie 6/7/23
%%%%%%%%%%%%%%%%%%%%%%%%

%% HPC cluster
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1'  'TS114-3'  'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3'  'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'};  %list of animal have master CA1DG shank that can be processed here %TS112-1 TS113-2 don't have MEC master shank
track = 1;

%(CA1DG). control seizing guys being taken out (110-0 117-4 113-3)
%currently need to take out animals without MECII PL value, need to deal with this situation later (112-1 113-2)

asym=[];
c=[];
c2=[];
meanAC=[];
burst=[];
burstbw = [];
mAmp = [];
mISI=[];
r2CA1=[];
pval2CA1=[];
pval2MEC=[];
mu2CA1=[];
r2MEC=[];
mu2MEC=[];
mFR=[];
FRmean = [];
highestFR = [];
CSI = [];
animal_ind = {};
group_ind = {};

%regions
CA1=[];
DG=[];
uind=0;  %master unit index

for anim=1:length(animals)  %loop through all animals and get info about each cluster
    
    animal=animals{anim};

    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);

    for shank=[CA1DGshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks

        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification

        if ~isempty(ch.Pyr2) && ~isempty (ch.Pyr1) %find units in pyr 
            CA1units=find(units.correctclusterch>=ch.Pyr2 & units.correctclusterch<=ch.Pyr1); %currently only including pyr (previously wa both or and pyr)  
            CA1=[CA1 CA1units+uind];  
        end
        %below is an whole DG version
        if ~isempty(ch.Hil2) && ~isempty (ch.GC1)  %find units in GCL or Hilus 
            DGunits=find(units.correctclusterch>=ch.Hil2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
            DG=[DG DGunits+uind];
        end

%  below is to look at only blade
%         ch.GC1 = ch.GC1 +3; %to account for too less cell in blade
%         ch.GC2 = ch.GC2 -4; %to account for too less cell in blade
%         if ~isempty(ch.GC2) && ~isempty (ch.GC1)  %find units in GCL or Hilus 
%             DGunits=find(units.correctclusterch>=ch.GC2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
%             DG=[DG DGunits+uind];
%         end

        %put spike attributes into master array
        for u=1:length(units.waveforms)  %getting all the important info about each unit from file we loaded in earlier 
            uind=uind+1;
            animal_ind{uind} = animal;  %added this so I can know which animal each cluster belongs to for plotting later
            group_ind{uind} = group;
            if ~isempty(units.spikes{u})      % && units.numspikes(u) > 200 && units.refravio(u) < 0.6 %% && units.CA1thetaPL{u}.pval<0.05 &&  units.MECIIthetaPL{u}.pval<0.05  %refravio rate <= 0.6% will be a reasonable cluster to include in - sf
                numspikes(uind)=units.numspikes(u);
                refravio(uind)=units.refravio(u);
                r2CA1(uind)=units.CA1thetaPL{u}.r;
                mu2CA1(uind)=units.CA1thetaPL{u}.mu;
                pval2CA1(uind) = units.CA1thetaPL{u}.pval;
                r2MEC(uind)=units.MECIIthetaPL{u}.r;
                mu2MEC(uind)=units.MECIIthetaPL{u}.mu;
                pval2MEC(uind) = units.MECIIthetaPL{u}.pval;
                r2DG(uind)=units.DGthetaPL{u}.r; 
                mu2DG(uind)=units.DGthetaPL{u}.mu;
                pval2DG(uind) = units.DGthetaPL{u}.pval;
%                 mFR(uind)=units.mFR(u);   %toatl spike/total time
%                 FRmean(uind)=units.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
%                 highestFR(uind)=units.highestFR(u);   % Method2: take the highest FR for certain length of time bins, use that as FR
                burst(uind)=units.burst(u);
                burstbw(uind) = units.burstbw(u);
                mISI(uind)=units.mISI(u);
                mAmp(uind)=units.mAmp(u);

                CSI(uind)=unitswholetrack.CSI(u);
                meanAC(uind)=unitswholetrack.meanAC(u); %mean of autocorr
                FRmean(uind)=unitswholetrack.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                %asym(uind)=unitswholetrack.wavesasym{u}; 
                c(uind)=unitswholetrack.wavesc(u);

            elseif isempty(units.spikes{u})
                disp(['empty cluster' num2str(u) 'in animal ' animal])
            end
        end
    end %end each shank
end %end each animal

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

% % CLUSTER!
%%use this for hippocampus (reference Zoe and Lauren's way) ************
type = [];
for idx=1:length(CSI)
    if meanAC(idx)> 0.1 && FRmean(idx)>=0.2
         type(idx)=1;
    elseif CSI(idx) > 0 && meanAC(idx)<0.1 && FRmean(idx)<8  && c(idx)>0.26
         type(idx)=2;
     else
         type(idx)=3;
    end
end
inh = find(type == 1);
exc = find(type == 2);
weird = find(type == 3);
% 
% %%use this for hippocampus (previous way) ************
% type = [];
% for idx=1:length(CSI)
%     if CSI(idx)<20 && meanAC(idx)> 0.11 && FRmean(idx)>=2.5
%          type(idx)=1;
%     elseif CSI(idx) > 5 && meanAC(idx)<0.11 && FRmean(idx)<8   %susie change FR from 5 to 5.5 since using FRmean now
%          type(idx)=2;
%      else
%          type(idx)=3;
%     end
% end
% inh = find(type == 1);
% exc = find(type == 2);
% weird = find(type == 3);

%all cells all animals
figure('Renderer', 'painters', 'Position', [10 10 1000 700])
 scatter3(FRmean(exc),CSI(exc), meanAC(exc), 20, 'MarkerEdgeColor','k',...
         'MarkerFaceColor',[1 .4 1]);
 hold on; scatter3(FRmean(inh),CSI(inh), meanAC(inh), 20, 'MarkerEdgeColor','k',...
         'MarkerFaceColor',[0.5 1 .9]);
 xlabel('Firing Rate')
 ylabel('Complex spike index')
 zlabel('Mean autocorrelation')
 title('HPC units')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% savepath = 'Y:\Susie\2020\Summer_Ephys_ALL\figures\supfig2';
% title_name = 'HPC-cluster-new';
% saveas(gca, fullfile(savepath, title_name), 'svg');
% clear all


 %% MEC cluster plot
 animals = { 'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%112-1 taken out since no master MEC; 113-2 out no master MEC
%110-0 117-4 113-3 seizures for control, taking out
track= 1;
asym=[];
c=[];
c2=[];
meanAC=[];
burst=[];
burstbw = [];
mAmp = [];
mISI=[];
r2CA1=[];
pval2CA1=[];
pval2MEC=[];
mu2CA1=[];
r2MEC=[];
mu2MEC=[];
mFR=[];
FRmean = [];
highestFR = [];
CSI = [];
animal_ind = {};
group_ind = {};


%cell regions
M1=[]; %MEC1
M2=[];
M3=[];

uind=0;  %master unit index

for anim=1:length(animals)  %loop through all animals and get info about each cluster
    animal=animals{anim};
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
    for shank=[MECshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks

        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification


        %include LEC version
        if ~isempty(ch.EC12) && ~isempty (ch.EC11) %find units in MEC1
            M1units=find(units.correctclusterch>=ch.EC12 & units.correctclusterch<ch.EC11); 
            M1=[M1 M1units+uind];
        end
    
        if ~isempty(ch.EC22) && ~isempty (ch.EC21) %find units in MEC2
            M2units=find(units.correctclusterch>=ch.EC22 & units.correctclusterch<ch.EC21); 
            M2=[M2 M2units+uind];
        end
        
        if ~isempty(ch.EC32) && ~isempty (ch.EC31) %find units in MEC3
            M3units=find(units.correctclusterch>=ch.EC32 & units.correctclusterch<ch.EC31); 
            M3=[M3 M3units+uind];
        end
                 
        %put spike attributes into master array
        for u=1:length(units.waveforms)  %getting all the important info about each unit from file we loaded in earlier 
            uind=uind+1;
            animal_ind{uind} = animal;  %added this so I can know which animal each cluster belongs to for plotting later
            group_ind{uind} = group;

            if ~isempty(units.spikes{u}) 
                numspikes(uind)=units.numspikes(u);
                refravio(uind)=units.refravio(u);

                r2CA1(uind)=units.CA1thetaPL{u}.r;
                mu2CA1(uind)=units.CA1thetaPL{u}.mu;
                pval2CA1(uind) = units.CA1thetaPL{u}.pval;
                r2MEC(uind)=units.MECIIthetaPL{u}.r;
                mu2MEC(uind)=units.MECIIthetaPL{u}.mu;
                pval2MEC(uind) = units.MECIIthetaPL{u}.pval;
                r2DG(uind)=units.DGthetaPL{u}.r; 
                mu2DG(uind)=units.DGthetaPL{u}.mu;
                pval2DG(uind) = units.DGthetaPL{u}.pval;

                burst(uind)=units.burst(u);
                burstbw(uind) = units.burstbw(u);
                mISI(uind)=units.mISI(u);
                mAmp(uind)=units.mAmp(u);

                c(uind)=unitswholetrack.wavesc(u);
                asym(uind)=unitswholetrack.wavesasym(u); 
                FRmean(uind)=unitswholetrack.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                meanAC(uind)=unitswholetrack.meanAC(u);
                CSI(uind)=unitswholetrack.CSI(u);

            elseif isempty(units.spikes{u})
                disp(['empty cluster' num2str(u) 'in animal ' animal])
            end
        end
    end %end each shank
end %end each animal


% to identify the unqualified units
unqualifylist = [];
for u=1:length(c)
    if numspikes(u) < 200 || refravio(u) > 0.6 || c(u) < 0.1
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

% CLUSTER!
% **********use this for EC***********
x=[ c' ]; %options: %meanAC' asym2' meanAC'  mISI' c2' mFR'  %only c works best for MEC   
[idx,C] = kmeans(x,2); %sort into two clusters and return cluster centroid locations?
[M, I]=max(C(:,1)); %finds indices of max value and puts them in output vector I
exc=find(idx==I);  %getting excitatory and inhibitory cells
inh=find(idx~=I);


figure('Renderer', 'painters', 'Position', [10 10 1000 700])
 scatter3(FRmean(exc),c(exc),asym(exc),20,  'MarkerEdgeColor','k',...
       'MarkerFaceColor',[1 .4 1]);
 hold on; scatter3(FRmean(inh),c(inh),asym(inh),20, 'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0.5 1 .9]);
 xlabel('Firing Rate')
 ylabel('Tough to peak latenc')
 zlabel('Peak amplitude asymetry')
 title('MEC units');
 