%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is made to address reviewers comment on kmean cluster
% this script is to plot the MEC3 subcluster plot in 0-720 degree range based
% on just mu value
% Also output the mu and r value for prism formating 
% Susie 4/6/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
M1=[];
M2=[];
M3=[];

uind=0;  %master unit index
for anim=1:length(animals)  %loop through all animals and get info about each cluster
    animal=animals{anim};
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
    for shank=[MECshank]  
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
                mu2CA1(uind)=units.CA1thetaPL{u}.mu; %the final phase of each cell
                pval2CA1(uind) = units.CA1thetaPL{u}.pval;
                rad2CA1{uind} = units.CA1thetaPL{u}.bins; %spike's rad value at histcounts 20degree bin
                
                r2MEC(uind)=units.MECIIthetaPL{u}.r;
                mu2MEC(uind)=units.MECIIthetaPL{u}.mu;
                pval2MEC(uind) = units.MECIIthetaPL{u}.pval;
                rad2MEC{uind} = units.MECIIthetaPL{u}.bins; %spike's rad value at histcounts 20degree bin

                r2DG(uind)=units.DGthetaPL{u}.r;
                mu2DG(uind)=units.DGthetaPL{u}.mu;
                pval2DG(uind) = units.DGthetaPL{u}.pval;
                rad2DG{uind} = units.DGthetaPL{u}.bins; %spike's rad value at histcounts 20degree bin

                FRmeantrack1(uind)=units.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                highestFRtrack1(uind)=units.highestFR(u); 

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


    %% CLUSTER!
    % **********use this for EC***********
    %below is hardset rule base on previous kmean explring
    x=[ c' ]; %options: %meanAC' asym2' meanAC'  mISI' c2' mFR'  %only c works best for MEC   
    exc = find(x>=0.4);
    inh = find(x<0.4);

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

eM1=intersect(exc,M1);  
iM1=intersect(inh,M1); 
eM2=intersect(exc,M2);  
iM2=intersect(inh,M2); 
eM3=intersect(exc,M3); 
iM3=intersect(inh,M3); 


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
%below is all exc/inh/weird cells for each group
e3wc = intersect(g_3wccells, exc);
e3wp = intersect(g_3wpcells, exc);
e8wc = intersect(g_8wccells, exc);
e8wp = intersect(g_8wpcells, exc);
ec =  intersect(g_ccells, exc);

i3wc = intersect(g_3wccells, inh);
i3wp = intersect(g_3wpcells, inh);
i8wc = intersect(g_8wccells, inh);
i8wp = intersect(g_8wpcells, inh);
ic =  intersect(g_ccells, inh);



% 2 MEC

e_M3mu2MEC_c = mu2MEC(eM3_c);
e_M3mu2MEC_3wp = mu2MEC(eM3_3wp);
e_M3mu2MEC_8wp = mu2MEC(eM3_8wp);

i_M3mu2MEC_c = mu2MEC(iM3_c);
i_M3mu2MEC_3wp = mu2MEC(iM3_3wp);
i_M3mu2MEC_8wp = mu2MEC(iM3_8wp);


e_M3r2MEC_c = r2MEC(eM3_c);
e_M3r2MEC_3wp = r2MEC(eM3_3wp);
e_M3r2MEC_8wp = r2MEC(eM3_8wp);

i_M3r2MEC_c = r2MEC(iM3_c);
i_M3r2MEC_3wp = r2MEC(iM3_3wp);
i_M3r2MEC_8wp = r2MEC(iM3_8wp);

% 2 CA1

e_M3mu2CA1_c = mu2CA1(eM3_c);
e_M3mu2CA1_3wp = mu2CA1(eM3_3wp);
e_M3mu2CA1_8wp = mu2CA1(eM3_8wp);

i_M3mu2CA1_c = mu2CA1(iM3_c);
i_M3mu2CA1_3wp = mu2CA1(iM3_3wp);
i_M3mu2CA1_8wp = mu2CA1(iM3_8wp);


e_M3r2CA1_c = r2CA1(eM3_c);
e_M3r2CA1_3wp = r2CA1(eM3_3wp);
e_M3r2CA1_8wp = r2CA1(eM3_8wp);

i_M3r2CA1_c = r2CA1(iM3_c);
i_M3r2CA1_3wp = r2CA1(iM3_3wp);
i_M3r2CA1_8wp = r2CA1(iM3_8wp);

%% establish rule for MEC3 cell cluster
% I need to do cluster first, and plot the 2 cluter sperately from 0-720 deg

% control
figure
scatter(e_M3mu2MEC_c, e_M3r2MEC_c, 'filled');
ylim([0, 1])
xlim([-3.2, 3.2])
title('control Theta MEC3 to MEC cluster');
e_M3highRind_c = find(e_M3mu2MEC_c > -1.5 & e_M3mu2MEC_c < 1.5);
e_M3lowRind_c = find(e_M3mu2MEC_c <= -1.5 | e_M3mu2MEC_c >= 1.5);

%3wp
figure
scatter(e_M3mu2MEC_3wp, e_M3r2MEC_3wp, 'filled');
ylim([0, 1])
xlim([-3.2, 3.2])
title('3wp Theta MEC3 to MEC cluster');
e_M3highRind_3wp = find(e_M3mu2MEC_3wp > -1.5 & e_M3mu2MEC_3wp < 1.5);
e_M3lowRind_3wp = find(e_M3mu2MEC_3wp <= -1.5 | e_M3mu2MEC_3wp >= 1.5);

%8wp
figure
scatter(e_M3mu2MEC_8wp, e_M3r2MEC_8wp, 'filled');
ylim([0, 1])
xlim([-3.2, 3.2])
title('8wp Theta MEC3 to MEC cluster');
e_M3highRind_8wp = find(e_M3mu2MEC_8wp > -1.5 & e_M3mu2MEC_8wp < 1.5);
e_M3lowRind_8wp = find(e_M3mu2MEC_8wp <= -1.5 | e_M3mu2MEC_8wp >= 1.5);


% 2 MEC
e_M3r2MEChighR_c = e_M3r2MEC_c(e_M3highRind_c);
e_M3r2MEChighR_3wp = e_M3r2MEC_3wp(e_M3highRind_3wp);
e_M3r2MEChighR_8wp = e_M3r2MEC_8wp(e_M3highRind_8wp);
e_M3r2MEClowR_c = e_M3r2MEC_c(e_M3lowRind_c);
e_M3r2MEClowR_3wp = e_M3r2MEC_3wp(e_M3lowRind_3wp);
e_M3r2MEClowR_8wp = e_M3r2MEC_8wp(e_M3lowRind_8wp);

e_M3mu2MEChighR_c = e_M3mu2MEC_c(e_M3highRind_c);
e_M3mu2MEChighR_3wp = e_M3mu2MEC_3wp(e_M3highRind_3wp);
e_M3mu2MEChighR_8wp = e_M3mu2MEC_8wp(e_M3highRind_8wp);
e_M3mu2MEClowR_c = e_M3mu2MEC_c(e_M3lowRind_c);
e_M3mu2MEClowR_3wp = e_M3mu2MEC_3wp(e_M3lowRind_3wp);
e_M3mu2MEClowR_8wp = e_M3mu2MEC_8wp(e_M3lowRind_8wp);

% 2CA1
e_M3r2CA1highR_c = e_M3r2CA1_c(e_M3highRind_c);
e_M3r2CA1highR_3wp = e_M3r2CA1_3wp(e_M3highRind_3wp);
e_M3r2CA1highR_8wp = e_M3r2CA1_8wp(e_M3highRind_8wp);
e_M3r2CA1lowR_c = e_M3r2CA1_c(e_M3lowRind_c);
e_M3r2CA1lowR_3wp = e_M3r2CA1_3wp(e_M3lowRind_3wp);
e_M3r2CA1lowR_8wp = e_M3r2CA1_8wp(e_M3lowRind_8wp);

e_M3mu2CA1highR_c = e_M3mu2CA1_c(e_M3highRind_c);
e_M3mu2CA1highR_3wp = e_M3mu2CA1_3wp(e_M3highRind_3wp);
e_M3mu2CA1highR_8wp = e_M3mu2CA1_8wp(e_M3highRind_8wp);
e_M3mu2CA1lowR_c = e_M3mu2CA1_c(e_M3lowRind_c);
e_M3mu2CA1lowR_3wp = e_M3mu2CA1_3wp(e_M3lowRind_3wp);
e_M3mu2CA1lowR_8wp = e_M3mu2CA1_8wp(e_M3lowRind_8wp);

e_M3r2MEChighR_c_double = [e_M3r2MEChighR_c e_M3r2MEChighR_c];
e_M3mu2MEChighR_c_double = [rad2deg(e_M3mu2MEChighR_c)+180 rad2deg(e_M3mu2MEChighR_c) + 540];
e_M3r2MEClowR_c_double = [e_M3r2MEClowR_c e_M3r2MEClowR_c];
e_M3mu2MEClowR_c_double = [rad2deg(e_M3mu2MEClowR_c)+180 rad2deg(e_M3mu2MEClowR_c) + 540];


figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(e_M3mu2MEChighR_c_double, e_M3r2MEChighR_c_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[0  0.8  0.5] );
hold on
scatter(e_M3mu2MEClowR_c_double, e_M3r2MEClowR_c_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[1 .7  0]);
ylim([0, 1])
xlim([0, 720])
title('MEC3 excitatory cells cluster in control');
hold off
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\clusterMEC_plot_clusterbymu\';
if exist(savepath)==0
    mkdir(savepath);
end
savename = 'MEC3 excitatory cells cluster in control';
saveas(gca, fullfile(savepath, savename), 'svg');


%%% MEC3 3wP
e_M3r2MEChighR_3wp_double = [e_M3r2MEChighR_3wp e_M3r2MEChighR_3wp];
e_M3mu2MEChighR_3wp_double = [rad2deg(e_M3mu2MEChighR_3wp)+180 rad2deg(e_M3mu2MEChighR_3wp) + 540];
e_M3r2MEClowR_3wp_double = [e_M3r2MEClowR_3wp e_M3r2MEClowR_3wp];
e_M3mu2MEClowR_3wp_double = [rad2deg(e_M3mu2MEClowR_3wp)+180 rad2deg(e_M3mu2MEClowR_3wp) + 540];

figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(e_M3mu2MEChighR_3wp_double, e_M3r2MEChighR_3wp_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[0  0.8  0.5])
hold on
scatter(e_M3mu2MEClowR_3wp_double, e_M3r2MEClowR_3wp_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[1 .7  0])
ylim([0, 1])
xlim([0, 720])
title('MEC3 excitatory cells cluster in 3wP');
hold off
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\clusterMEC_plot_clusterbymu\';
if exist(savepath)==0
    mkdir(savepath);
end
savename = 'MEC3 excitatory cells cluster in 3wP';
saveas(gca, fullfile(savepath, savename), 'svg');




%%% MEC3 8wp
e_M3r2MEChighR_8wp_double = [e_M3r2MEChighR_8wp e_M3r2MEChighR_8wp];
e_M3mu2MEChighR_8wp_double = [rad2deg(e_M3mu2MEChighR_8wp)+180 rad2deg(e_M3mu2MEChighR_8wp) + 540];
e_M3r2MEClowR_8wp_double = [e_M3r2MEClowR_8wp e_M3r2MEClowR_8wp];
e_M3mu2MEClowR_8wp_double = [rad2deg(e_M3mu2MEClowR_8wp)+180 rad2deg(e_M3mu2MEClowR_8wp) + 540];

figure('Renderer', 'painters', 'Position', [10 10 800 400])
scatter(e_M3mu2MEChighR_8wp_double, e_M3r2MEChighR_8wp_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[0  0.8  0.5])
hold on
scatter(e_M3mu2MEClowR_8wp_double, e_M3r2MEClowR_8wp_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[1 .7  0])
ylim([0, 1])
xlim([0, 720])
title('MEC3 excitatory cells cluster in 8wP');
hold off
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\clusterMEC_plot_clusterbymu\';
if exist(savepath)==0
    mkdir(savepath);
end
savename = 'MEC3 excitatory cells cluster in 8wP';
saveas(gca, fullfile(savepath, savename), 'svg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all groups together
e_M3r2MEChighR_ALL_double = [e_M3r2MEChighR_c_double, e_M3r2MEChighR_3wp_double, e_M3r2MEChighR_8wp_double];
e_M3r2MEClowR_ALL_double = [e_M3r2MEClowR_c_double, e_M3r2MEClowR_3wp_double, e_M3r2MEClowR_8wp_double];
e_M3mu2MEChighR_ALL_double = [e_M3mu2MEChighR_c_double, e_M3mu2MEChighR_3wp_double, e_M3mu2MEChighR_8wp_double];
e_M3mu2MEClowR_ALL_double = [e_M3mu2MEClowR_c_double, e_M3mu2MEClowR_3wp_double, e_M3mu2MEClowR_8wp_double];

figure('Renderer', 'painters', 'Position', [10 10 1200 400])
scatter(e_M3mu2MEChighR_ALL_double, e_M3r2MEChighR_ALL_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[0  0.8  0.5])
hold on
scatter(e_M3mu2MEClowR_ALL_double, e_M3r2MEClowR_ALL_double, 'MarkerEdgeColor',[0.5 .5 .5], 'MarkerFaceColor',[1 .7  0])
ylim([0, 1])
xlim([0, 720])
title('MEC3 excitatory cells cluster in ALL groups');
hold off
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\clusterMEC_plot_clusterbymu\';
if exist(savepath)==0
    mkdir(savepath);
end
savename = 'MEC3 excitatory cells cluster in ALL groups';
saveas(gca, fullfile(savepath, savename), 'svg');




%% generate prism output for mu and r (supp fig making)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pval assignment
%phaselock pval by genotype

%M3 circr pval to MECII
e_M32MECpval_c = pval2MEC(eM3_c);
e_M32MECpval_3wc = pval2MEC(eM3_3wc);
e_M32MECpval_3wp = pval2MEC(eM3_3wp);
e_M32MECpval_8wc = pval2MEC(eM3_8wc);
e_M32MECpval_8wp = pval2MEC(eM3_8wp);
%clustered M3 exc unit pval
eM32MECpval_highR_c = e_M32MECpval_c(e_M3highRind_c);
eM32MECpval_highR_3wp = e_M32MECpval_3wp(e_M3highRind_3wp);
eM32MECpval_highR_8wp = e_M32MECpval_8wp(e_M3highRind_8wp);

eM32MECpval_lowR_c = e_M32MECpval_c(e_M3lowRind_c);
eM32MECpval_lowR_3wp = e_M32MECpval_3wp(e_M3lowRind_3wp);
eM32MECpval_lowR_8wp = e_M32MECpval_8wp(e_M3lowRind_8wp);


%M3 circr pval to DG

e_M32DGpval_c = pval2DG(eM3_c);
e_M32DGpval_3wc = pval2DG(eM3_3wc);
e_M32DGpval_3wp = pval2DG(eM3_3wp);
e_M32DGpval_8wc = pval2DG(eM3_8wc);
e_M32DGpval_8wp = pval2DG(eM3_8wp);
% M3 exc cluster pval
eM32DGpval_highR_c = e_M32DGpval_c(e_M3highRind_c);
eM32DGpval_highR_3wp = e_M32DGpval_3wp(e_M3highRind_3wp);
eM32DGpval_highR_8wp = e_M32DGpval_8wp(e_M3highRind_8wp);
eM32DGpval_lowR_c = e_M32DGpval_c(e_M3lowRind_c);
eM32DGpval_lowR_3wp = e_M32DGpval_3wp(e_M3lowRind_3wp);
eM32DGpval_lowR_8wp = e_M32DGpval_8wp(e_M3lowRind_8wp);


%M3 circr pval to CA1

e_M32CA1pval_c = pval2CA1(eM3_c);
e_M32CA1pval_3wc = pval2CA1(eM3_3wc);
e_M32CA1pval_3wp = pval2CA1(eM3_3wp);
e_M32CA1pval_8wc = pval2CA1(eM3_8wc);
e_M32CA1pval_8wp = pval2CA1(eM3_8wp);

% M3 exc cluster pval
eM32CA1pval_highR_c = e_M32CA1pval_c(e_M3highRind_c);
eM32CA1pval_highR_3wp = e_M32CA1pval_3wp(e_M3highRind_3wp);
eM32CA1pval_highR_8wp = e_M32CA1pval_8wp(e_M3highRind_8wp);
eM32CA1pval_lowR_c = e_M32CA1pval_c(e_M3lowRind_c);
eM32CA1pval_lowR_3wp = e_M32CA1pval_3wp(e_M3lowRind_3wp);
eM32CA1pval_lowR_8wp = e_M32CA1pval_8wp(e_M3lowRind_8wp);



%% take out units in mu list that have non-significant r-circ p val (generate new list, don't overwrite)

% M3
e_M3mu2MEC_c_clean = e_M3mu2MEC_c(find(e_M32MECpval_c<0.05));
e_M3mu2CA1_c_clean = e_M3mu2CA1_c(find(e_M32CA1pval_c<0.05));

e_M3mu2MEC_3wp_clean = e_M3mu2MEC_3wp(find(e_M32MECpval_3wp<0.05));
e_M3mu2CA1_3wp_clean = e_M3mu2CA1_3wp(find(e_M32CA1pval_3wp<0.05));

e_M3mu2MEC_8wp_clean = e_M3mu2MEC_8wp(find(e_M32MECpval_8wp<0.05));
e_M3mu2CA1_8wp_clean = e_M3mu2CA1_8wp(find(e_M32CA1pval_8wp<0.05));

% clustered exc units
e_M3mu2CA1_highR_c_clean = e_M3mu2CA1highR_c(find(eM32CA1pval_highR_c<0.05));
e_M3mu2CA1_highR_3wp_clean = e_M3mu2CA1highR_3wp(find(eM32CA1pval_highR_3wp<0.05));
e_M3mu2CA1_highR_8wp_clean = e_M3mu2CA1highR_8wp(find(eM32CA1pval_highR_8wp<0.05));
e_M3mu2CA1_lowR_c_clean = e_M3mu2CA1lowR_c(find(eM32CA1pval_lowR_c<0.05));
e_M3mu2CA1_lowR_3wp_clean = e_M3mu2CA1lowR_3wp(find(eM32CA1pval_lowR_3wp<0.05));
e_M3mu2CA1_lowR_8wp_clean = e_M3mu2CA1lowR_8wp(find(eM32CA1pval_lowR_8wp<0.05));

e_M3mu2MEC_highR_c_clean = e_M3mu2MEChighR_c(find(eM32MECpval_highR_c<0.05));
e_M3mu2MEC_highR_3wp_clean = e_M3mu2MEChighR_3wp(find(eM32MECpval_highR_3wp<0.05));
e_M3mu2MEC_highR_8wp_clean = e_M3mu2MEChighR_8wp(find(eM32MECpval_highR_8wp<0.05));
e_M3mu2MEC_lowR_c_clean = e_M3mu2MEClowR_c(find(eM32MECpval_lowR_c<0.05));
e_M3mu2MEC_lowR_3wp_clean = e_M3mu2MEClowR_3wp(find(eM32MECpval_lowR_3wp<0.05));
e_M3mu2MEC_lowR_8wp_clean = e_M3mu2MEClowR_8wp(find(eM32MECpval_lowR_8wp<0.05));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%double the points on plot

% high R
e_M3mu2MEC_highR_c_clean_double = [rad2deg(e_M3mu2MEC_highR_c_clean)+180 rad2deg(e_M3mu2MEC_highR_c_clean) + 540];
e_M3mu2MEC_highR_3wp_clean_double = [rad2deg(e_M3mu2MEC_highR_3wp_clean)+180 rad2deg(e_M3mu2MEC_highR_3wp_clean) + 540];
e_M3mu2MEC_highR_8wp_clean_double = [rad2deg(e_M3mu2MEC_highR_8wp_clean)+180 rad2deg(e_M3mu2MEC_highR_8wp_clean) + 540];
% low R
e_M3mu2MEC_lowR_c_clean_double = [rad2deg(e_M3mu2MEC_lowR_c_clean)+180 rad2deg(e_M3mu2MEC_lowR_c_clean) + 540];
e_M3mu2MEC_lowR_3wp_clean_double = [rad2deg(e_M3mu2MEC_lowR_3wp_clean)+180 rad2deg(e_M3mu2MEC_lowR_3wp_clean) + 540];
e_M3mu2MEC_lowR_8wp_clean_double = [rad2deg(e_M3mu2MEC_lowR_8wp_clean)+180 rad2deg(e_M3mu2MEC_lowR_8wp_clean) + 540];


% high R
e_M3mu2CA1_highR_c_clean_double = [rad2deg(e_M3mu2CA1_highR_c_clean)+180 rad2deg(e_M3mu2CA1_highR_c_clean) + 540];
e_M3mu2CA1_highR_3wp_clean_double = [rad2deg(e_M3mu2CA1_highR_3wp_clean)+180 rad2deg(e_M3mu2CA1_highR_3wp_clean) + 540];
e_M3mu2CA1_highR_8wp_clean_double = [rad2deg(e_M3mu2CA1_highR_8wp_clean)+180 rad2deg(e_M3mu2CA1_highR_8wp_clean) + 540];
% low R
e_M3mu2CA1_lowR_c_clean_double = [rad2deg(e_M3mu2CA1_lowR_c_clean)+180 rad2deg(e_M3mu2CA1_lowR_c_clean) + 540];
e_M3mu2CA1_lowR_3wp_clean_double = [rad2deg(e_M3mu2CA1_lowR_3wp_clean)+180 rad2deg(e_M3mu2CA1_lowR_3wp_clean) + 540];
e_M3mu2CA1_lowR_8wp_clean_double = [rad2deg(e_M3mu2CA1_lowR_8wp_clean)+180 rad2deg(e_M3mu2CA1_lowR_8wp_clean) + 540];


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the stats for mu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% M3 2 MEC %%%%%%%%%%%%%%%
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\M32MEC\'; 
if exist(savepath)==0
     mkdir(savepath);
end


% high R plot and stats
data = {e_M3mu2MEC_highR_c_clean_double, e_M3mu2MEC_highR_3wp_clean_double, e_M3mu2MEC_highR_8wp_clean_double}; %data use for plot
data_mu_stats = {e_M3mu2MEC_highR_c_clean, e_M3mu2MEC_highR_3wp_clean, e_M3mu2MEC_highR_8wp_clean}; %data use for stats
title_name = 'Mu Value of M3 Exc High R Cluster to MECII theta';
scatterdouble_mu_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);


[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{2});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{2});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{2});
stats_name = 'Mu of M3 highR cluster to MECII (C vs 3wp)';
titlelist_mu(1,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(1,1) = pval;
pvallist_mu(1,2) = pval_k;
pvallist_mu(1,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{3});
stats_name = 'Mu of M3 highR cluster to MECII (C vs 8wp)';
titlelist_mu(2,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(2,1) = pval;
pvallist_mu(2,2) = pval_k;
pvallist_mu(2,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{2},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{2},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{2},data_mu_stats{3});
stats_name = 'Mu of M3 highR cluster to MECII (3wp vs 8wp)';
titlelist_mu(3,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(3,1) = pval;
pvallist_mu(3,2) = pval_k;
pvallist_mu(3,3) = pval_w;


% low R plot and stats
data = {e_M3mu2MEC_lowR_c_clean_double, e_M3mu2MEC_lowR_3wp_clean_double, e_M3mu2MEC_lowR_8wp_clean_double}; %data use for plot
data_mu_stats = {e_M3mu2MEC_lowR_c_clean, e_M3mu2MEC_lowR_3wp_clean, e_M3mu2MEC_lowR_8wp_clean}; %data use for stats
title_name = 'Mu Value of M3 Exc low R Cluster to MECII theta';
scatterdouble_mu_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{2});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{2});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{2});
stats_name = 'Mu of M3 lowR cluster to MECII (C vs 3wp)';
titlelist_mu(4,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(4,1) = pval;
pvallist_mu(4,2) = pval_k;
pvallist_mu(4,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{3});
stats_name = 'Mu of M3 lowR cluster to MECII (C vs 8wp)';
titlelist_mu(5,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(5,1) = pval;
pvallist_mu(5,2) = pval_k;
pvallist_mu(5,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{2},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{2},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{2},data_mu_stats{3});
stats_name = 'Mu of M3 lowR cluster to MECII (3wp vs 8wp)';
titlelist_mu(6,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(6,1) = pval;
pvallist_mu(6,2) = pval_k;
pvallist_mu(6,3) = pval_w;



%%%%%%%%%%%%%%%%% M3 2 CA1 %%%%%%%%%%%%%%%
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\M32CA1\';
if exist(savepath)==0
     mkdir(savepath);
end


%high R plot and stats - NOTE THE CLEAN VERSION DOESN"T HAVE ENOUGH CELL
data = {e_M3mu2CA1_highR_c_clean_double, e_M3mu2CA1_highR_3wp_clean_double, e_M3mu2CA1_highR_8wp_clean_double}; %data use for plot
data_mu_stats = {e_M3mu2CA1_highR_c_clean, e_M3mu2CA1_highR_3wp_clean, e_M3mu2CA1_highR_8wp_clean}; %data use for stats
title_name = 'Mu Value of M3 Exc High R Cluster to CA1 theta';
scatterdouble_mu_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{2});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{2});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{2});
stats_name = 'Mu of M3 highR cluster to CA1 (C vs 3wp)';
titlelist_mu(7,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(7,1) = pval;
pvallist_mu(7,2) = pval_k;
pvallist_mu(7,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{3});
stats_name = 'Mu of M3 highR cluster to CA1 (C vs 8wp)';
titlelist_mu(8,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(8,1) = pval;
pvallist_mu(8,2) = pval_k;
pvallist_mu(8,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{2},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{2},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{2},data_mu_stats{3});
stats_name = 'Mu of M3 highR cluster to CA1 (3wp vs 8wp)';
titlelist_mu(9,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(9,1) = pval;
pvallist_mu(9,2) = pval_k;
pvallist_mu(9,3) = pval_w;



%low R plot and stats
data = {e_M3mu2CA1_lowR_c_clean_double, e_M3mu2CA1_lowR_3wp_clean_double, e_M3mu2CA1_lowR_8wp_clean_double}; %data use for plot
data_mu_stats = {e_M3mu2CA1_lowR_c_clean, e_M3mu2CA1_lowR_3wp_clean, e_M3mu2CA1_lowR_8wp_clean}; %data use for stats
title_name = 'Mu Value of M3 Exc low R Cluster to CA1 theta';
scatterdouble_mu_SF(data, {'Control', '3wp', '8wp'}, {'blue', 'm','red'}, title_name, savepath);

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{2});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{2});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{2});
stats_name = 'Mu of M3 lowR cluster to CA1 (C vs 3wp)';
titlelist_mu(10,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(10,1) = pval;
pvallist_mu(10,2) = pval_k;
pvallist_mu(10,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{1},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{1},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{1},data_mu_stats{3});
stats_name = 'Mu of M3 lowR cluster to CA1 (C vs 8wp)';
titlelist_mu(11,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(11,1) = pval;
pvallist_mu(11,2) = pval_k;
pvallist_mu(11,3) = pval_w;

[pval, k, K] = circ_kuipertest(data_mu_stats{2},data_mu_stats{3});
[pval_k, f] = circ_ktest(data_mu_stats{2},data_mu_stats{3});
[pval_w, t] = circ_wwtest(data_mu_stats{2},data_mu_stats{3});
stats_name = 'Mu of M3 lowR cluster to CA1 (3wp vs 8wp)';
titlelist_mu(12,1) = {convertCharsToStrings(stats_name)};
pvallist_mu(12,1) = pval;
pvallist_mu(12,2) = pval_k;
pvallist_mu(12,3) = pval_w;


%save mu pval table
mu_pvaltable = table(titlelist_mu, pvallist_mu); %write pval to a table
writetable(mu_pvaltable, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\mu_pvaltable_MEC_cluster_CLEAN.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 


%% write to csv
%% mu
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\';
if exist(savepath)==0
     mkdir(savepath);
end

writematrix(e_M3mu2MEC_highR_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2MEC_highR_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_highR_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2MEC_highR_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_highR_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2MEC_highR_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_lowR_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2MEC_lowR_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_lowR_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2MEC_lowR_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_lowR_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2MEC_lowR_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
% 
writematrix(e_M3mu2CA1_highR_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2CA1_highR_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_highR_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2CA1_highR_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_highR_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2CA1_highR_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_lowR_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2CA1_lowR_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_lowR_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2CA1_lowR_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_lowR_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\mu\e_M3mu2CA1_lowR_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

%% r
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\';
if exist(savepath)==0
     mkdir(savepath);
end


e_M3r2MEChighR_c_ani = animal_ind(eM3_c);
e_M3r2MEChighR_c_ani = e_M3r2MEChighR_c_ani(e_M3highRind_c);
e_M3r2MEChighR_3wp_ani = animal_ind(eM3_3wp);
e_M3r2MEChighR_3wp_ani = e_M3r2MEChighR_3wp_ani(e_M3highRind_3wp);
e_M3r2MEChighR_8wp_ani = animal_ind(eM3_8wp);
e_M3r2MEChighR_8wp_ani = e_M3r2MEChighR_8wp_ani(e_M3highRind_8wp);
e_M3r2MEClowR_c_ani = animal_ind(eM3_c);
e_M3r2MEClowR_c_ani = e_M3r2MEClowR_c_ani(e_M3lowRind_c);
e_M3r2MEClowR_3wp_ani = animal_ind(eM3_3wp);
e_M3r2MEClowR_3wp_ani = e_M3r2MEClowR_3wp_ani(e_M3lowRind_3wp);
e_M3r2MEClowR_8wp_ani = animal_ind(eM3_8wp);
e_M3r2MEClowR_8wp_ani = e_M3r2MEClowR_8wp_ani(e_M3lowRind_8wp);

e_M3r2CA1highR_c_ani = animal_ind(eM3_c);
e_M3r2CA1highR_c_ani = e_M3r2CA1highR_c_ani(e_M3highRind_c);
e_M3r2CA1highR_3wp_ani = animal_ind(eM3_3wp);
e_M3r2CA1highR_3wp_ani = e_M3r2CA1highR_3wp_ani(e_M3highRind_3wp);
e_M3r2CA1highR_8wp_ani = animal_ind(eM3_8wp);
e_M3r2CA1highR_8wp_ani = e_M3r2CA1highR_8wp_ani(e_M3highRind_8wp);
e_M3r2CA1lowR_c_ani = animal_ind(eM3_c);
e_M3r2CA1lowR_c_ani = e_M3r2CA1lowR_c_ani(e_M3lowRind_c);
e_M3r2CA1lowR_3wp_ani = animal_ind(eM3_3wp);
e_M3r2CA1lowR_3wp_ani = e_M3r2CA1lowR_3wp_ani(e_M3lowRind_3wp);
e_M3r2CA1lowR_8wp_ani = animal_ind(eM3_8wp);
e_M3r2CA1lowR_8wp_ani = e_M3r2CA1lowR_8wp_ani(e_M3lowRind_8wp);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% M32CA1_r_exc/inh - high R
table = rval_to_prism(e_M3r2CA1highR_c_ani, e_M3r2CA1highR_c);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2CA1highR_c.csv','Delimiter',',') 

table = rval_to_prism(e_M3r2CA1highR_3wp_ani, e_M3r2CA1highR_3wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2CA1highR_3wp.csv','Delimiter',',')

table = rval_to_prism(e_M3r2CA1highR_8wp_ani, e_M3r2CA1highR_8wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2CA1highR_8wp.csv','Delimiter',',')

% M32CA1_r_exc/inh - low R
table = rval_to_prism(e_M3r2CA1lowR_c_ani, e_M3r2CA1lowR_c);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2CA1lowR_c.csv','Delimiter',',')

table = rval_to_prism(e_M3r2CA1lowR_3wp_ani, e_M3r2CA1lowR_3wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2CA1lowR_3wp.csv','Delimiter',',') 
table = rval_to_prism(e_M3r2CA1lowR_8wp_ani, e_M3r2CA1lowR_8wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2CA1lowR_8wp.csv','Delimiter',',') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M32MEC_r_exc/inh - high R
table = rval_to_prism(e_M3r2MEChighR_c_ani, e_M3r2MEChighR_c);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2MEChighR_c.csv','Delimiter',',') 

table = rval_to_prism(e_M3r2MEChighR_3wp_ani, e_M3r2MEChighR_3wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2MEChighR_3wp.csv','Delimiter',',')

table = rval_to_prism(e_M3r2MEChighR_8wp_ani, e_M3r2MEChighR_8wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2MEChighR_8wp.csv','Delimiter',',')

% M32MEC_r_exc/inh - low R
table = rval_to_prism(e_M3r2MEClowR_c_ani, e_M3r2MEClowR_c);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2MEClowR_c.csv','Delimiter',',')

table = rval_to_prism(e_M3r2MEClowR_3wp_ani, e_M3r2MEClowR_3wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2MEClowR_3wp.csv','Delimiter',',') 
table = rval_to_prism(e_M3r2MEClowR_8wp_ani, e_M3r2MEClowR_8wp);
writetable(table, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol_clusterbymu\prismrval\r\e_M3r2MEClowR_8wp.csv','Delimiter',',') 