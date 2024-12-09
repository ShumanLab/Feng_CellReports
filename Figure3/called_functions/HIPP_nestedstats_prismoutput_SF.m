%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script to organize all r value into easy to paste prism format
% OUTPUT: csv shgeet with r value organized by animal
% CA12CA1_r_exc/inh
% CA12DG_r_exc/inh
% CA12MEC_r_exc/inh
% DG2CA1_r_exc/inh
% DG2DG_r_exc/inh
% DG2MEC_r_exc/inh

% susie 2/2/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        if ~isempty(ch.Hil2) && ~isempty (ch.GC1)  %find units in GCL or Hilus 
            DGunits=find(units.correctclusterch>=ch.Hil2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
            DG=[DG DGunits+uind];
        end

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

%%
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
 figure(1);clf; scatter3(FRmean(exc),CSI(exc), meanAC(exc), 20, 'g');
 hold on; scatter3(FRmean(inh),CSI(inh), meanAC(inh), 20,'r');
 hold on; scatter3(FRmean(weird),CSI(weird),meanAC(weird), 20,'y');
 xlabel('Firing Rate')
 ylabel('CSI')
 zlabel('meanAC')
 title('All animals')


 %%
 %Sorting cells into subregions and groups
 %Hippocampus

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


eDG=intersect(exc,DG);  
iDG=intersect(inh,DG); 
eCA1=intersect(exc,CA1); 
iCA1=intersect(inh,CA1); 
%wDG = intersect(weird, DG); %not being clustered as exc or interneuron
%wCA1 = intersect(weird, CA1);

eDG3wc = intersect(g_3wccells, eDG);
eDG3wp = intersect(g_3wpcells, eDG);
eDG8wc = intersect(g_8wccells, eDG);
eDG8wp = intersect(g_8wpcells, eDG);

iDG3wc = intersect(g_3wccells, iDG);
iDG3wp = intersect(g_3wpcells, iDG);
iDG8wc = intersect(g_8wccells, iDG);
iDG8wp = intersect(g_8wpcells, iDG);

% wDG3wc = intersect(g_3wccells, wDG);
% wDG3wp = intersect(g_3wpcells, wDG);
% wDG8wc = intersect(g_8wccells, wDG);
% wDG8wp = intersect(g_8wpcells, wDG);

eCA13wc = intersect(g_3wccells, eCA1);
eCA13wp = intersect(g_3wpcells, eCA1);
eCA18wc = intersect(g_8wccells, eCA1);
eCA18wp = intersect(g_8wpcells, eCA1);

iCA13wc = intersect(g_3wccells, iCA1);
iCA13wp = intersect(g_3wpcells, iCA1);
iCA18wc = intersect(g_8wccells, iCA1);
iCA18wp = intersect(g_8wpcells, iCA1);

% wCA13wc = intersect(g_3wccells, wCA1);
% wCA13wp = intersect(g_3wpcells, wCA1);
% wCA18wc = intersect(g_8wccells, wCA1);
% wCA18wp = intersect(g_8wpcells, wCA1);

%below is all exc/inh/weird cells for each group

e3wc = intersect(g_3wccells, exc);
e3wp = intersect(g_3wpcells, exc);
e8wc = intersect(g_8wccells, exc);
e8wp = intersect(g_8wpcells, exc);

i3wc = intersect(g_3wccells, inh);
i3wp = intersect(g_3wpcells, inh);
i8wc = intersect(g_8wccells, inh);
i8wp = intersect(g_8wpcells, inh);

% w3wc = intersect(g_3wccells, weird);
% w3wp = intersect(g_3wpcells, weird);
% w8wc = intersect(g_8wccells, weird);
% w8wp = intersect(g_8wpcells, weird);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grabbing values for each group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% r values by genotype
e_DGr2CA1_3wc = r2CA1(eDG3wc);%r values DG units referenced to CA1
e_DGr2CA1_3wp = r2CA1(eDG3wp);
e_DGr2CA1_8wc = r2CA1(eDG8wc);
e_DGr2CA1_8wp = r2CA1(eDG8wp);
e_DGr2CA1_3wc_ani = animal_ind(eDG3wc);
e_DGr2CA1_3wp_ani = animal_ind(eDG3wp);
e_DGr2CA1_8wc_ani = animal_ind(eDG8wc);
e_DGr2CA1_8wp_ani = animal_ind(eDG8wp);

i_DGr2CA1_3wc = r2CA1(iDG3wc);%inh
i_DGr2CA1_3wp = r2CA1(iDG3wp);
i_DGr2CA1_8wc = r2CA1(iDG8wc);
i_DGr2CA1_8wp = r2CA1(iDG8wp);
i_DGr2CA1_3wc_ani = animal_ind(iDG3wc);
i_DGr2CA1_3wp_ani = animal_ind(iDG3wp);
i_DGr2CA1_8wc_ani = animal_ind(iDG8wc);
i_DGr2CA1_8wp_ani = animal_ind(iDG8wp);

e_CA1r2CA1_3wc = r2CA1(eCA13wc);%r values CA1 units referenced to CA1
e_CA1r2CA1_3wp = r2CA1(eCA13wp);
e_CA1r2CA1_8wc = r2CA1(eCA18wc);
e_CA1r2CA1_8wp = r2CA1(eCA18wp);
e_CA1r2CA1_3wc_ani = animal_ind(eCA13wc);
e_CA1r2CA1_3wp_ani = animal_ind(eCA13wp);
e_CA1r2CA1_8wc_ani = animal_ind(eCA18wc);
e_CA1r2CA1_8wp_ani = animal_ind(eCA18wp);

i_CA1r2CA1_3wc = r2CA1(iCA13wc);%inh
i_CA1r2CA1_3wp = r2CA1(iCA13wp);
i_CA1r2CA1_8wc = r2CA1(iCA18wc);
i_CA1r2CA1_8wp = r2CA1(iCA18wp);
i_CA1r2CA1_3wc_ani = animal_ind(iCA13wc);
i_CA1r2CA1_3wp_ani = animal_ind(iCA13wp);
i_CA1r2CA1_8wc_ani = animal_ind(iCA18wc);
i_CA1r2CA1_8wp_ani = animal_ind(iCA18wp);

e_DGr2MEC_3wc = r2MEC(eDG3wc);%r values DG units referenced to MEC2 
e_DGr2MEC_3wp = r2MEC(eDG3wp);
e_DGr2MEC_8wc = r2MEC(eDG8wc);
e_DGr2MEC_8wp = r2MEC(eDG8wp);
e_DGr2MEC_3wc_ani = animal_ind(eDG3wc);
e_DGr2MEC_3wp_ani = animal_ind(eDG3wp);
e_DGr2MEC_8wc_ani = animal_ind(eDG8wc);
e_DGr2MEC_8wp_ani = animal_ind(eDG8wp);


i_DGr2MEC_3wc = r2MEC(iDG3wc); %inh
i_DGr2MEC_3wp = r2MEC(iDG3wp);
i_DGr2MEC_8wc = r2MEC(iDG8wc);
i_DGr2MEC_8wp = r2MEC(iDG8wp);
i_DGr2MEC_3wc_ani = animal_ind(iDG3wc);
i_DGr2MEC_3wp_ani = animal_ind(iDG3wp);
i_DGr2MEC_8wc_ani = animal_ind(iDG8wc);
i_DGr2MEC_8wp_ani = animal_ind(iDG8wp);


e_CA1r2MEC_3wc = r2MEC(eCA13wc);%r values CA1 units referenced to MEC2
e_CA1r2MEC_3wp = r2MEC(eCA13wp);
e_CA1r2MEC_8wc = r2MEC(eCA18wc);
e_CA1r2MEC_8wp = r2MEC(eCA18wp);
e_CA1r2MEC_3wc_ani = animal_ind(eCA13wc);
e_CA1r2MEC_3wp_ani = animal_ind(eCA13wp);
e_CA1r2MEC_8wc_ani = animal_ind(eCA18wc);
e_CA1r2MEC_8wp_ani = animal_ind(eCA18wp);

i_CA1r2MEC_3wc = r2MEC(iCA13wc);%inh
i_CA1r2MEC_3wp = r2MEC(iCA13wp);
i_CA1r2MEC_8wc = r2MEC(iCA18wc);
i_CA1r2MEC_8wp = r2MEC(iCA18wp);
i_CA1r2MEC_3wc_ani = animal_ind(iCA13wc);
i_CA1r2MEC_3wp_ani = animal_ind(iCA13wp);
i_CA1r2MEC_8wc_ani = animal_ind(iCA18wc);
i_CA1r2MEC_8wp_ani = animal_ind(iCA18wp);

e_CA1r2DG_3wc = r2DG(eCA13wc);%r values CA1 units referenced to DG
e_CA1r2DG_3wp = r2DG(eCA13wp);
e_CA1r2DG_8wc = r2DG(eCA18wc);
e_CA1r2DG_8wp = r2DG(eCA18wp);
e_CA1r2DG_3wc_ani = animal_ind(eCA13wc);
e_CA1r2DG_3wp_ani = animal_ind(eCA13wp);
e_CA1r2DG_8wc_ani = animal_ind(eCA18wc);
e_CA1r2DG_8wp_ani = animal_ind(eCA18wp);

i_CA1r2DG_3wc = r2DG(iCA13wc);%inh
i_CA1r2DG_3wp = r2DG(iCA13wp);
i_CA1r2DG_8wc = r2DG(iCA18wc);
i_CA1r2DG_8wp = r2DG(iCA18wp);
i_CA1r2DG_3wc_ani = animal_ind(iCA13wc);
i_CA1r2DG_3wp_ani = animal_ind(iCA13wp);
i_CA1r2DG_8wc_ani = animal_ind(iCA18wc);
i_CA1r2DG_8wp_ani = animal_ind(iCA18wp);


e_DGr2DG_3wc = r2DG(eDG3wc);%r values DG units referenced to DG
e_DGr2DG_3wp = r2DG(eDG3wp);
e_DGr2DG_8wc = r2DG(eDG8wc);
e_DGr2DG_8wp = r2DG(eDG8wp);
e_DGr2DG_3wc_ani = animal_ind(eDG3wc);
e_DGr2DG_3wp_ani = animal_ind(eDG3wp);
e_DGr2DG_8wc_ani = animal_ind(eDG8wc);
e_DGr2DG_8wp_ani = animal_ind(eDG8wp);

i_DGr2DG_3wc = r2DG(iDG3wc);%inh
i_DGr2DG_3wp = r2DG(iDG3wp);
i_DGr2DG_8wc = r2DG(iDG8wc);
i_DGr2DG_8wp = r2DG(iDG8wp);
i_DGr2DG_3wc_ani = animal_ind(iDG3wc);
i_DGr2DG_3wp_ani = animal_ind(iDG3wp);
i_DGr2DG_8wc_ani = animal_ind(iDG8wc);
i_DGr2DG_8wp_ani = animal_ind(iDG8wp);


e_DGmu2CA1_3wc = mu2CA1(eDG3wc);%r values DG units referenced to CA1
e_DGmu2CA1_3wp = mu2CA1(eDG3wp);
e_DGmu2CA1_8wc = mu2CA1(eDG8wc);
e_DGmu2CA1_8wp = mu2CA1(eDG8wp);
e_DGmu2CA1_3wc_ani = animal_ind(eDG3wc);
e_DGmu2CA1_3wp_ani = animal_ind(eDG3wp);
e_DGmu2CA1_8wc_ani = animal_ind(eDG8wc);
e_DGmu2CA1_8wp_ani = animal_ind(eDG8wp);

i_DGmu2CA1_3wc = mu2CA1(iDG3wc);%inh
i_DGmu2CA1_3wp = mu2CA1(iDG3wp);
i_DGmu2CA1_8wc = mu2CA1(iDG8wc);
i_DGmu2CA1_8wp = mu2CA1(iDG8wp);
i_DGmu2CA1_3wc_ani = animal_ind(iDG3wc);
i_DGmu2CA1_3wp_ani = animal_ind(iDG3wp);
i_DGmu2CA1_8wc_ani = animal_ind(iDG8wc);
i_DGmu2CA1_8wp_ani = animal_ind(iDG8wp);

%% NOTE!!!!! susie accidentally changed this part to subsample and haven't changed back 5/30/24
% making csv sheet
% 
% savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\';
% if exist(savepath)==0
%      mkdir(savepath);
% end
% 
% 
% % DG2CA1_r_exc/inh
% table = rval_to_prism(e_DGr2CA1_3wc_ani, e_DGr2CA1_3wc);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\e_DGr2CA1_3wc_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(e_DGr2CA1_3wp_ani, e_DGr2CA1_3wp);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\e_DGr2CA1_3wp_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(e_DGr2CA1_8wc_ani, e_DGr2CA1_8wc);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\e_DGr2CA1_8wc_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(e_DGr2CA1_8wp_ani, e_DGr2CA1_8wp);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\e_DGr2CA1_8wp_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(i_DGr2CA1_3wc_ani, i_DGr2CA1_3wc);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\i_DGr2CA1_3wc_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(i_DGr2CA1_3wp_ani, i_DGr2CA1_3wp);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\i_DGr2CA1_3wp_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(i_DGr2CA1_8wc_ani, i_DGr2CA1_8wc);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\i_DGr2CA1_8wc_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
% table = rval_to_prism(i_DGr2CA1_8wp_ani, i_DGr2CA1_8wp);
% writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\r\DGCA1subsample\i_DGr2CA1_8wp_whenalignDGCA1.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 



