%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to plot FR as X axis and mu as y to study their relationship
% Susie 3/24/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%below is animals list with master DGCA1 shank and without control seizing  (110-0, 117-4, 113-3, 113-1)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment

track= 1;

asym=[];
c=[];
c2=[];
meanAC=[];
r2CA1=[];
pval2CA1=[];
mu2CA1=[];
rad2CA1 = {};

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
    for shank=[CA1DGshank]  
        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification

        if ~isempty(ch.Pyr2) && ~isempty (ch.Pyr1) % && ~isempty (ch.Or1) %find units in pyr 
            
            CA1units=find(units.correctclusterch>=ch.Pyr2 & units.correctclusterch<=ch.Pyr1); %currently only including pyr (previously wa both or and pyr)  
            %CA1units=find(units.correctclusterch>=ch.Pyr2 & units.correctclusterch<=ch.Or1); %currently only including pyr (previously wa both or and pyr)  
            CA1=[CA1 CA1units+uind];  
        end
        if ~isempty(ch.GC1) && ~isempty (ch.Hil2)  %find units in GCL or Hilus 
            DGunits=find(units.correctclusterch>=ch.Hil2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
            %DGunits=find(units.correctclusterch>=ch.GC2 & units.correctclusterch<=ch.GC1); %currently not including mol layer
            DG=[DG DGunits+uind];
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
                mu2CA1(uind)=units.CA1thetaPL{u}.mu; %the final phase of each cell
                pval2CA1(uind) = units.CA1thetaPL{u}.pval;
                rad2CA1{uind} = units.CA1thetaPL{u}.bins; %spike's rad value at histcounts 20degree bin

                CSI(uind)=unitswholetrack.CSI(u);
                meanAC(uind)=unitswholetrack.meanAC(u); %mean of autocorr
                FRmean(uind)=unitswholetrack.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                asym(uind)=unitswholetrack.wavesasym(u); 
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
%%use this for hippocampus (previous way) ************
type = [];
for idx=1:length(CSI)
    if CSI(idx)<20 && meanAC(idx)> 0.11 && FRmean(idx)>=2.5
         type(idx)=1;
    elseif CSI(idx) > 5 && meanAC(idx)<0.11 && FRmean(idx)<8 
         type(idx)=2;
     else
         type(idx)=3;
    end
end
inh = find(type == 1);
exc = find(type == 2);

 %%
 %Sorting cells into subregions and groups - Hippocampus
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

eDG3wc = intersect(g_3wccells, eDG);
eDG3wp = intersect(g_3wpcells, eDG);
eDG8wc = intersect(g_8wccells, eDG);
eDG8wp = intersect(g_8wpcells, eDG);
eDGc = intersect(g_ccells, eDG);

iDG3wc = intersect(g_3wccells, iDG);
iDG3wp = intersect(g_3wpcells, iDG);
iDG8wc = intersect(g_8wccells, iDG);
iDG8wp = intersect(g_8wpcells, iDG);
iDGc = intersect(g_ccells, iDG);

eCA13wc = intersect(g_3wccells, eCA1);
eCA13wp = intersect(g_3wpcells, eCA1);
eCA18wc = intersect(g_8wccells, eCA1);
eCA18wp = intersect(g_8wpcells, eCA1);
eCA1c = intersect(g_ccells, eCA1);

iCA13wc = intersect(g_3wccells, iCA1);
iCA13wp = intersect(g_3wpcells, iCA1);
iCA18wc = intersect(g_8wccells, iCA1);
iCA18wp = intersect(g_8wpcells, iCA1);
iCA1c = intersect(g_ccells, iCA1);

%below is all exc/inh/weird cells for each group

e3wc = intersect(g_3wccells, exc);
e3wp = intersect(g_3wpcells, exc);
e8wc = intersect(g_8wccells, exc);
e8wp = intersect(g_8wpcells, exc);
ec = intersect(g_ccells,exc);

i3wc = intersect(g_3wccells, inh);
i3wp = intersect(g_3wpcells, inh);
i8wc = intersect(g_8wccells, inh);
i8wp = intersect(g_8wpcells, inh);
ic = intersect(g_ccells,inh);

%% assign firing rate value
e_FR_DG2CA1_c = FRmean(eDGc);
e_FR_DG2CA1_3wp = FRmean(eDG3wp);
e_FR_DG2CA1_8wp = FRmean(eDG8wp);
i_FR_DG2CA1_c = FRmean(iDGc);
i_FR_DG2CA1_3wp = FRmean(iDG3wp);
i_FR_DG2CA1_8wp = FRmean(iDG8wp);
%% GRAB mu and r value
% mu value for each cell
e_DGmu2CA1_c = mu2CA1(eDGc);%mu values DG units referenced to CA1
e_DGmu2CA1_3wp = mu2CA1(eDG3wp);
e_DGmu2CA1_8wp = mu2CA1(eDG8wp);

i_DGmu2CA1_c = mu2CA1(iDGc);%inh
i_DGmu2CA1_3wp = mu2CA1(iDG3wp);
i_DGmu2CA1_8wp = mu2CA1(iDG8wp);

e_CA1mu2CA1_c = mu2CA1(eCA1c);%mu values CA1 units referenced to CA1
e_CA1mu2CA1_3wp = mu2CA1(eCA13wp);
e_CA1mu2CA1_8wp = mu2CA1(eCA18wp);

i_CA1mu2CA1_c = mu2CA1(iCA1c);%inh
i_CA1mu2CA1_3wp = mu2CA1(iCA13wp);
i_CA1mu2CA1_8wp = mu2CA1(iCA18wp);

% r value for each cell
e_DGr2CA1_c = r2CA1(eDGc);%r values DG units referenced to CA1
e_DGr2CA1_3wp = r2CA1(eDG3wp);
e_DGr2CA1_8wp = r2CA1(eDG8wp);

i_DGr2CA1_c = r2CA1(iDGc);%inh
i_DGr2CA1_3wp = r2CA1(iDG3wp);
i_DGr2CA1_8wp = r2CA1(iDG8wp);

e_CA1r2CA1_c = r2CA1(eCA1c);%r values CA1 units referenced to CA1
e_CA1r2CA1_3wp = r2CA1(eCA13wp);
e_CA1r2CA1_8wp = r2CA1(eCA18wp);

i_CA1r2CA1_c = r2CA1(iCA1c);%inh
i_CA1r2CA1_3wp = r2CA1(iCA13wp);
i_CA1r2CA1_8wp = r2CA1(iCA18wp);


%% plot mu by FR
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\FR_mu_relation\';
if exist(savepath)==0
     mkdir(savepath);
end

% exc in DG
e_DGmu2CA1_c = rad2deg(e_DGmu2CA1_c)+180;
figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(e_FR_DG2CA1_c, e_DGmu2CA1_c);
yticks([0 90 180 270 360]);
yticklabels({ '0 peak' '90' '180 trough' '270' '360 peak'});  
xlabel('FR (Hz)');
ylim([0,360]);
xlim([0,10]);
title('DG Exc units mu relationship to FR (Control)')
saveas(gca, fullfile(savepath, 'DG Exc units mu relationship to FR (Control)'), 'png');

e_DGmu2CA1_3wp = rad2deg(e_DGmu2CA1_3wp)+180;
figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(e_FR_DG2CA1_3wp, e_DGmu2CA1_3wp, 'MarkerEdgeColor',[0.8 0.3 0.2], 'MarkerFaceColor',[0.8 0.3 0.2]);
yticks([0 90 180 270 360]);
yticklabels({ '0 peak' '90' '180 trough' '270' '360 peak'});  
xlabel('FR (Hz)');
ylim([0,360]);
xlim([0,10]);
title('DG Exc units mu relationship to FR (3wp)')
saveas(gca, fullfile(savepath, 'DG Exc units mu relationship to FR (3wp)'), 'png');

e_DGmu2CA1_8wp = rad2deg(e_DGmu2CA1_8wp)+180;
figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(e_FR_DG2CA1_8wp, e_DGmu2CA1_8wp, 'MarkerEdgeColor',[0.5 0 0], 'MarkerFaceColor',[0.5 0 0]);
yticks([0 90 180 270 360]);
yticklabels({ '0 peak' '90' '180 trough' '270' '360 peak'});  
xlabel('FR (Hz)');
ylim([0,360]);
xlim([0,10]);
title('DG Exc units mu relationship to FR (8wp)')
saveas(gca, fullfile(savepath, 'DG Exc units mu relationship to FR (8wp)'), 'png');


% Inh in DG
i_DGmu2CA1_c = rad2deg(i_DGmu2CA1_c)+180;
figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(i_FR_DG2CA1_c, i_DGmu2CA1_c);
yticks([0 90 180 270 360]);
yticklabels({ '0 peak' '90' '180 trough' '270' '360 peak'});  
xlabel('FR (Hz)');
ylim([0,360]);
xlim([0,30]);
title('DG Inh units mu relationship to FR (Control)')
saveas(gca, fullfile(savepath, 'DG Inh units mu relationship to FR (Control)'), 'png');

i_DGmu2CA1_3wp = rad2deg(i_DGmu2CA1_3wp)+180;
figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(i_FR_DG2CA1_3wp, i_DGmu2CA1_3wp, 'MarkerEdgeColor',[0.8 0.3 0.2], 'MarkerFaceColor',[0.8 0.3 0.2]);
yticks([0 90 180 270 360]);
yticklabels({ '0 peak' '90' '180 trough' '270' '360 peak'});  
xlabel('FR (Hz)');
ylim([0,360]);
xlim([0,30]);
title('DG Inh units mu relationship to FR (3wp)')
saveas(gca, fullfile(savepath, 'DG Inh units mu relationship to FR (3wp)'), 'png');

i_DGmu2CA1_8wp = rad2deg(i_DGmu2CA1_8wp)+180;
figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(i_FR_DG2CA1_8wp, i_DGmu2CA1_8wp, 'MarkerEdgeColor',[0.5 0 0], 'MarkerFaceColor',[0.5 0 0]);
yticks([0 90 180 270 360]);
yticklabels({ '0 peak' '90' '180 trough' '270' '360 peak'});  
xlabel('FR (Hz)');
ylim([0,360]);
xlim([0,30]);
title('DG Inh units mu relationship to FR (8wp)')
saveas(gca, fullfile(savepath, 'DG Inh units mu relationship to FR (8wp)'), 'png');