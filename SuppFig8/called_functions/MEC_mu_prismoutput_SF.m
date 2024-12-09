%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script to organize all mu value into easy to paste prism format
% OUTPUT: csv shgeet with r value organized by animal
% MEC22CA1_mu_exc/inh
% MEC22DG_mu_exc/inh
% MEC22MEC_mu_exc/inh
% MEC32CA1_mu_exc/inh
% MEC32DG_mu_exc/inh
% MEC32MEC_mu_exc/inh

% susie 3/15/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    for shank=[MECshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks
        [ch]=getchannels(animal,shank);  % get channels
        group = ch.group;
        %load info about units generated by TSprocessSpikes_Lruntime_SF
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run_track' num2str(track) '.mat']); %units
        load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunitswholetrack.mat']); %unitswholetrack, use this for cell type classification
%         % ONLY MEC version
%         if ~isempty(ch.MEC12) && ~isempty (ch.MEC11) %find units in MEC1
%             M1units=find(units.correctclusterch>=ch.MEC12 & units.correctclusterch<ch.MEC11); 
%             M1=[M1 M1units+uind];
%         end
%     
%         if ~isempty(ch.MEC22) && ~isempty (ch.MEC21) %find units in MEC2
%             M2units=find(units.correctclusterch>=ch.MEC22 & units.correctclusterch<ch.MEC21); 
%             M2=[M2 M2units+uind];
%         end
%         
%         if ~isempty(ch.MEC32) && ~isempty (ch.MEC31) %find units in MEC3
%             M3units=find(units.correctclusterch>=ch.MEC32 & units.correctclusterch<ch.MEC31); 
%             M3=[M3 M3units+uind];
%         end

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
% 
% % % below is kmean, comment out now bc it generate different result each run
% x=[ c' ]; %options: %meanAC' asym2' meanAC'  mISI' c2' mFR'  %only c works best for MEC   
% [idx,C] = kmeans(x,2); %sort into two clusters and return cluster centroid locations?
% [M, I]=max(C(:,1)); %finds indices of max value and puts them in output vector I
% exc=find(idx==I);  %getting excitatory and inhibitory cells
% inh=find(idx~=I);

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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grabbing r values for each group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2 CA1
e_M2r2CA1_c = r2CA1(eM2_c);
e_M2r2CA1_3wp = r2CA1(eM2_3wp);
e_M2r2CA1_8wp = r2CA1(eM2_8wp);
e_M2r2CA1_c_ani = animal_ind(eM2_c);
e_M2r2CA1_3wp_ani = animal_ind(eM2_3wp);
e_M2r2CA1_8wp_ani = animal_ind(eM2_8wp);

i_M2r2CA1_c = r2CA1(iM2_c);
i_M2r2CA1_3wp = r2CA1(iM2_3wp);
i_M2r2CA1_8wp = r2CA1(iM2_8wp);
i_M2r2CA1_c_ani = animal_ind(iM2_c);
i_M2r2CA1_3wp_ani = animal_ind(iM2_3wp);
i_M2r2CA1_8wp_ani = animal_ind(iM2_8wp);

e_M3r2CA1_c = r2CA1(eM3_c);
e_M3r2CA1_3wp = r2CA1(eM3_3wp);
e_M3r2CA1_8wp = r2CA1(eM3_8wp);
e_M3r2CA1_c_ani = animal_ind(eM3_c);
e_M3r2CA1_3wp_ani = animal_ind(eM3_3wp);
e_M3r2CA1_8wp_ani = animal_ind(eM3_8wp);

i_M3r2CA1_c = r2CA1(iM3_c);
i_M3r2CA1_3wp = r2CA1(iM3_3wp);
i_M3r2CA1_8wp = r2CA1(iM3_8wp);
i_M3r2CA1_c_ani = animal_ind(iM3_c);
i_M3r2CA1_3wp_ani = animal_ind(iM3_3wp);
i_M3r2CA1_8wp_ani = animal_ind(iM3_8wp);


% 2 DG
e_M2r2DG_c = r2DG(eM2_c);
e_M2r2DG_3wp = r2DG(eM2_3wp);
e_M2r2DG_8wp = r2DG(eM2_8wp);
e_M2r2DG_c_ani = animal_ind(eM2_c);
e_M2r2DG_3wp_ani = animal_ind(eM2_3wp);
e_M2r2DG_8wp_ani = animal_ind(eM2_8wp);

i_M2r2DG_c = r2DG(iM2_c);
i_M2r2DG_3wp = r2DG(iM2_3wp);
i_M2r2DG_8wp = r2DG(iM2_8wp);
i_M2r2DG_c_ani = animal_ind(iM2_c);
i_M2r2DG_3wp_ani = animal_ind(iM2_3wp);
i_M2r2DG_8wp_ani = animal_ind(iM2_8wp);

e_M3r2DG_c = r2DG(eM3_c);
e_M3r2DG_3wp = r2DG(eM3_3wp);
e_M3r2DG_8wp = r2DG(eM3_8wp);
e_M3r2DG_c_ani = animal_ind(eM3_c);
e_M3r2DG_3wp_ani = animal_ind(eM3_3wp);
e_M3r2DG_8wp_ani = animal_ind(eM3_8wp);

i_M3r2DG_c = r2DG(iM3_c);
i_M3r2DG_3wp = r2DG(iM3_3wp);
i_M3r2DG_8wp = r2DG(iM3_8wp);
i_M3r2DG_c_ani = animal_ind(iM3_c);
i_M3r2DG_3wp_ani = animal_ind(iM3_3wp);
i_M3r2DG_8wp_ani = animal_ind(iM3_8wp);


% 2 MEC
e_M2r2MEC_c = r2MEC(eM2_c);
e_M2r2MEC_3wp = r2MEC(eM2_3wp);
e_M2r2MEC_8wp = r2MEC(eM2_8wp);
e_M2r2MEC_c_ani = animal_ind(eM2_c);
e_M2r2MEC_3wp_ani = animal_ind(eM2_3wp);
e_M2r2MEC_8wp_ani = animal_ind(eM2_8wp);

i_M2r2MEC_c = r2MEC(iM2_c);
i_M2r2MEC_3wp = r2MEC(iM2_3wp);
i_M2r2MEC_8wp = r2MEC(iM2_8wp);
i_M2r2MEC_c_ani = animal_ind(iM2_c);
i_M2r2MEC_3wp_ani = animal_ind(iM2_3wp);
i_M2r2MEC_8wp_ani = animal_ind(iM2_8wp);

e_M3r2MEC_c = r2MEC(eM3_c);
e_M3r2MEC_3wp = r2MEC(eM3_3wp);
e_M3r2MEC_8wp = r2MEC(eM3_8wp);
e_M3r2MEC_c_ani = animal_ind(eM3_c);
e_M3r2MEC_3wp_ani = animal_ind(eM3_3wp);
e_M3r2MEC_8wp_ani = animal_ind(eM3_8wp);

i_M3r2MEC_c = r2MEC(iM3_c);
i_M3r2MEC_3wp = r2MEC(iM3_3wp);
i_M3r2MEC_8wp = r2MEC(iM3_8wp);
i_M3r2MEC_c_ani = animal_ind(iM3_c);
i_M3r2MEC_3wp_ani = animal_ind(iM3_3wp);
i_M3r2MEC_8wp_ani = animal_ind(iM3_8wp);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grabbing mu values for each group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2 CA1
e_M2mu2CA1_c = mu2CA1(eM2_c);
e_M2mu2CA1_3wp = mu2CA1(eM2_3wp);
e_M2mu2CA1_8wp = mu2CA1(eM2_8wp);
e_M2mu2CA1_c_ani = animal_ind(eM2_c);
e_M2mu2CA1_3wp_ani = animal_ind(eM2_3wp);
e_M2mu2CA1_8wp_ani = animal_ind(eM2_8wp);

i_M2mu2CA1_c = mu2CA1(iM2_c);
i_M2mu2CA1_3wp = mu2CA1(iM2_3wp);
i_M2mu2CA1_8wp = mu2CA1(iM2_8wp);
i_M2mu2CA1_c_ani = animal_ind(iM2_c);
i_M2mu2CA1_3wp_ani = animal_ind(iM2_3wp);
i_M2mu2CA1_8wp_ani = animal_ind(iM2_8wp);

e_M3mu2CA1_c = mu2CA1(eM3_c);
e_M3mu2CA1_3wp = mu2CA1(eM3_3wp);
e_M3mu2CA1_8wp = mu2CA1(eM3_8wp);
e_M3mu2CA1_c_ani = animal_ind(eM3_c);
e_M3mu2CA1_3wp_ani = animal_ind(eM3_3wp);
e_M3mu2CA1_8wp_ani = animal_ind(eM3_8wp);

i_M3mu2CA1_c = mu2CA1(iM3_c);
i_M3mu2CA1_3wp = mu2CA1(iM3_3wp);
i_M3mu2CA1_8wp = mu2CA1(iM3_8wp);
i_M3mu2CA1_c_ani = animal_ind(iM3_c);
i_M3mu2CA1_3wp_ani = animal_ind(iM3_3wp);
i_M3mu2CA1_8wp_ani = animal_ind(iM3_8wp);


% 2 DG
e_M2mu2DG_c = mu2DG(eM2_c);
e_M2mu2DG_3wp = mu2DG(eM2_3wp);
e_M2mu2DG_8wp = mu2DG(eM2_8wp);
e_M2mu2DG_c_ani = animal_ind(eM2_c);
e_M2mu2DG_3wp_ani = animal_ind(eM2_3wp);
e_M2mu2DG_8wp_ani = animal_ind(eM2_8wp);

i_M2mu2DG_c = mu2DG(iM2_c);
i_M2mu2DG_3wp = mu2DG(iM2_3wp);
i_M2mu2DG_8wp = mu2DG(iM2_8wp);
i_M2mu2DG_c_ani = animal_ind(iM2_c);
i_M2mu2DG_3wp_ani = animal_ind(iM2_3wp);
i_M2mu2DG_8wp_ani = animal_ind(iM2_8wp);

e_M3mu2DG_c = mu2DG(eM3_c);
e_M3mu2DG_3wp = mu2DG(eM3_3wp);
e_M3mu2DG_8wp = mu2DG(eM3_8wp);
e_M3mu2DG_c_ani = animal_ind(eM3_c);
e_M3mu2DG_3wp_ani = animal_ind(eM3_3wp);
e_M3mu2DG_8wp_ani = animal_ind(eM3_8wp);

i_M3mu2DG_c = mu2DG(iM3_c);
i_M3mu2DG_3wp = mu2DG(iM3_3wp);
i_M3mu2DG_8wp = mu2DG(iM3_8wp);
i_M3mu2DG_c_ani = animal_ind(iM3_c);
i_M3mu2DG_3wp_ani = animal_ind(iM3_3wp);
i_M3mu2DG_8wp_ani = animal_ind(iM3_8wp);


% 2 MEC
e_M2mu2MEC_c = mu2MEC(eM2_c);
e_M2mu2MEC_3wp = mu2MEC(eM2_3wp);
e_M2mu2MEC_8wp = mu2MEC(eM2_8wp);
e_M2mu2MEC_c_ani = animal_ind(eM2_c);
e_M2mu2MEC_3wp_ani = animal_ind(eM2_3wp);
e_M2mu2MEC_8wp_ani = animal_ind(eM2_8wp);

i_M2mu2MEC_c = mu2MEC(iM2_c);
i_M2mu2MEC_3wp = mu2MEC(iM2_3wp);
i_M2mu2MEC_8wp = mu2MEC(iM2_8wp);
i_M2mu2MEC_c_ani = animal_ind(iM2_c);
i_M2mu2MEC_3wp_ani = animal_ind(iM2_3wp);
i_M2mu2MEC_8wp_ani = animal_ind(iM2_8wp);

e_M3mu2MEC_c = mu2MEC(eM3_c);
e_M3mu2MEC_3wp = mu2MEC(eM3_3wp);
e_M3mu2MEC_8wp = mu2MEC(eM3_8wp);
e_M3mu2MEC_c_ani = animal_ind(eM3_c);
e_M3mu2MEC_3wp_ani = animal_ind(eM3_3wp);
e_M3mu2MEC_8wp_ani = animal_ind(eM3_8wp);

i_M3mu2MEC_c = mu2MEC(iM3_c);
i_M3mu2MEC_3wp = mu2MEC(iM3_3wp);
i_M3mu2MEC_8wp = mu2MEC(iM3_8wp);
i_M3mu2MEC_c_ani = animal_ind(iM3_c);
i_M3mu2MEC_3wp_ani = animal_ind(iM3_3wp);
i_M3mu2MEC_8wp_ani = animal_ind(iM3_8wp);


%
%phaselock pval by genotype

%M2 circr pval to MECII
i_M22MECpval_3wc = pval2MEC(iM2_3wc);
i_M22MECpval_3wp = pval2MEC(iM2_3wp);
i_M22MECpval_8wc = pval2MEC(iM2_8wc);
i_M22MECpval_8wp = pval2MEC(iM2_8wp);
e_M22MECpval_3wc = pval2MEC(eM2_3wc);
e_M22MECpval_3wp = pval2MEC(eM2_3wp);
e_M22MECpval_8wc = pval2MEC(eM2_8wc);
e_M22MECpval_8wp = pval2MEC(eM2_8wp);
%M3 circr pval to MECII
i_M32MECpval_3wc = pval2MEC(iM3_3wc);
i_M32MECpval_3wp = pval2MEC(iM3_3wp);
i_M32MECpval_8wc = pval2MEC(iM3_8wc);
i_M32MECpval_8wp = pval2MEC(iM3_8wp);
e_M32MECpval_3wc = pval2MEC(eM3_3wc);
e_M32MECpval_3wp = pval2MEC(eM3_3wp);
e_M32MECpval_8wc = pval2MEC(eM3_8wc);
e_M32MECpval_8wp = pval2MEC(eM3_8wp);

%M2 circr pval to DG
i_M22DGpval_3wc = pval2DG(iM2_3wc);
i_M22DGpval_3wp = pval2DG(iM2_3wp);
i_M22DGpval_8wc = pval2DG(iM2_8wc);
i_M22DGpval_8wp = pval2DG(iM2_8wp);
e_M22DGpval_3wc = pval2DG(eM2_3wc);
e_M22DGpval_3wp = pval2DG(eM2_3wp);
e_M22DGpval_8wc = pval2DG(eM2_8wc);
e_M22DGpval_8wp = pval2DG(eM2_8wp);
%M3 circr pval to DG
i_M32DGpval_3wc = pval2DG(iM3_3wc);
i_M32DGpval_3wp = pval2DG(iM3_3wp);
i_M32DGpval_8wc = pval2DG(iM3_8wc);
i_M32DGpval_8wp = pval2DG(iM3_8wp);
e_M32DGpval_3wc = pval2DG(eM3_3wc);
e_M32DGpval_3wp = pval2DG(eM3_3wp);
e_M32DGpval_8wc = pval2DG(eM3_8wc);
e_M32DGpval_8wp = pval2DG(eM3_8wp);

%M2 circr pval to CA1
i_M22CA1pval_3wc = pval2CA1(iM2_3wc);
i_M22CA1pval_3wp = pval2CA1(iM2_3wp);
i_M22CA1pval_8wc = pval2CA1(iM2_8wc);
i_M22CA1pval_8wp = pval2CA1(iM2_8wp);
e_M22CA1pval_3wc = pval2CA1(eM2_3wc);
e_M22CA1pval_3wp = pval2CA1(eM2_3wp);
e_M22CA1pval_8wc = pval2CA1(eM2_8wc);
e_M22CA1pval_8wp = pval2CA1(eM2_8wp);
%M3 circr pval to CA1
i_M32CA1pval_3wc = pval2CA1(iM3_3wc);
i_M32CA1pval_3wp = pval2CA1(iM3_3wp);
i_M32CA1pval_8wc = pval2CA1(iM3_8wc);
i_M32CA1pval_8wp = pval2CA1(iM3_8wp);
e_M32CA1pval_3wc = pval2CA1(eM3_3wc);
e_M32CA1pval_3wp = pval2CA1(eM3_3wp);
e_M32CA1pval_8wc = pval2CA1(eM3_8wc);
e_M32CA1pval_8wp = pval2CA1(eM3_8wp);


%combined circ r pval

e_M22MECpval_c = [e_M22MECpval_3wc e_M22MECpval_8wc];
e_M22DGpval_c = [e_M22DGpval_3wc e_M22DGpval_8wc];
e_M22CA1pval_c = [e_M22CA1pval_3wc e_M22CA1pval_8wc];
i_M22MECpval_c = [i_M22MECpval_3wc i_M22MECpval_8wc];
i_M22DGpval_c = [i_M22DGpval_3wc i_M22DGpval_8wc];
i_M22CA1pval_c = [i_M22CA1pval_3wc i_M22CA1pval_8wc];

e_M32MECpval_c = [e_M32MECpval_3wc e_M32MECpval_8wc];
e_M32DGpval_c = [e_M32DGpval_3wc e_M32DGpval_8wc];
e_M32CA1pval_c = [e_M32CA1pval_3wc e_M32CA1pval_8wc];
i_M32MECpval_c = [i_M32MECpval_3wc i_M32MECpval_8wc];
i_M32DGpval_c = [i_M32DGpval_3wc i_M32DGpval_8wc];
i_M32CA1pval_c = [i_M32CA1pval_3wc i_M32CA1pval_8wc];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% take out units in mu list that have non-significant r-circ p val (generate new list, don't overwrite)
%control
i_M2mu2MEC_c_clean = i_M2mu2MEC_c(find(i_M22MECpval_c<0.05));
i_M2mu2DG_c_clean = i_M2mu2DG_c(find(i_M22DGpval_c<0.05));
i_M2mu2CA1_c_clean = i_M2mu2CA1_c(find(i_M22CA1pval_c<0.05));
e_M2mu2MEC_c_clean = e_M2mu2MEC_c(find(e_M22MECpval_c<0.05));
e_M2mu2DG_c_clean = e_M2mu2DG_c(find(e_M22DGpval_c<0.05));
e_M2mu2CA1_c_clean = e_M2mu2CA1_c(find(e_M22CA1pval_c<0.05));

i_M3mu2MEC_c_clean = i_M3mu2MEC_c(find(i_M32MECpval_c<0.05));
i_M3mu2DG_c_clean = i_M3mu2DG_c(find(i_M32DGpval_c<0.05));
i_M3mu2CA1_c_clean = i_M3mu2CA1_c(find(i_M32CA1pval_c<0.05));
e_M3mu2MEC_c_clean = e_M3mu2MEC_c(find(e_M32MECpval_c<0.05));
e_M3mu2DG_c_clean = e_M3mu2DG_c(find(e_M32DGpval_c<0.05));
e_M3mu2CA1_c_clean = e_M3mu2CA1_c(find(e_M32CA1pval_c<0.05));

%3wp
i_M2mu2MEC_3wp_clean = i_M2mu2MEC_3wp(find(i_M22MECpval_3wp<0.05));
i_M2mu2DG_3wp_clean = i_M2mu2DG_3wp(find(i_M22DGpval_3wp<0.05));
i_M2mu2CA1_3wp_clean = i_M2mu2CA1_3wp(find(i_M22CA1pval_3wp<0.05));
e_M2mu2MEC_3wp_clean = e_M2mu2MEC_3wp(find(e_M22MECpval_3wp<0.05));
e_M2mu2DG_3wp_clean = e_M2mu2DG_3wp(find(e_M22DGpval_3wp<0.05));
e_M2mu2CA1_3wp_clean = e_M2mu2CA1_3wp(find(e_M22CA1pval_3wp<0.05));

i_M3mu2MEC_3wp_clean = i_M3mu2MEC_3wp(find(i_M32MECpval_3wp<0.05));
i_M3mu2DG_3wp_clean = i_M3mu2DG_3wp(find(i_M32DGpval_3wp<0.05));
i_M3mu2CA1_3wp_clean = i_M3mu2CA1_3wp(find(i_M32CA1pval_3wp<0.05));
e_M3mu2MEC_3wp_clean = e_M3mu2MEC_3wp(find(e_M32MECpval_3wp<0.05));
e_M3mu2DG_3wp_clean = e_M3mu2DG_3wp(find(e_M32DGpval_3wp<0.05));
e_M3mu2CA1_3wp_clean = e_M3mu2CA1_3wp(find(e_M32CA1pval_3wp<0.05));

%8wp
i_M2mu2MEC_8wp_clean = i_M2mu2MEC_8wp(find(i_M22MECpval_8wp<0.05));
i_M2mu2DG_8wp_clean = i_M2mu2DG_8wp(find(i_M22DGpval_8wp<0.05));
i_M2mu2CA1_8wp_clean = i_M2mu2CA1_8wp(find(i_M22CA1pval_8wp<0.05));
e_M2mu2MEC_8wp_clean = e_M2mu2MEC_8wp(find(e_M22MECpval_8wp<0.05));
e_M2mu2DG_8wp_clean = e_M2mu2DG_8wp(find(e_M22DGpval_8wp<0.05));
e_M2mu2CA1_8wp_clean = e_M2mu2CA1_8wp(find(e_M22CA1pval_8wp<0.05));

i_M3mu2MEC_8wp_clean = i_M3mu2MEC_8wp(find(i_M32MECpval_8wp<0.05));
i_M3mu2DG_8wp_clean = i_M3mu2DG_8wp(find(i_M32DGpval_8wp<0.05));
i_M3mu2CA1_8wp_clean = i_M3mu2CA1_8wp(find(i_M32CA1pval_8wp<0.05));
e_M3mu2MEC_8wp_clean = e_M3mu2MEC_8wp(find(e_M32MECpval_8wp<0.05));
e_M3mu2DG_8wp_clean = e_M3mu2DG_8wp(find(e_M32DGpval_8wp<0.05));
e_M3mu2CA1_8wp_clean = e_M3mu2CA1_8wp(find(e_M32CA1pval_8wp<0.05));

%%
i_M2mu2MEC_c_clean_double = [rad2deg(i_M2mu2MEC_c_clean)+180 rad2deg(i_M2mu2MEC_c_clean) + 540];
i_M2mu2MEC_3wp_clean_double = [rad2deg(i_M2mu2MEC_3wp_clean)+180 rad2deg(i_M2mu2MEC_3wp_clean) + 540];
i_M2mu2MEC_8wp_clean_double = [rad2deg(i_M2mu2MEC_8wp_clean)+180 rad2deg(i_M2mu2MEC_8wp_clean) + 540];
e_M2mu2MEC_c_clean_double = [rad2deg(e_M2mu2MEC_c_clean)+180 rad2deg(e_M2mu2MEC_c_clean) + 540];
e_M2mu2MEC_3wp_clean_double = [rad2deg(e_M2mu2MEC_3wp_clean)+180 rad2deg(e_M2mu2MEC_3wp_clean) + 540];
e_M2mu2MEC_8wp_clean_double = [rad2deg(e_M2mu2MEC_8wp_clean)+180 rad2deg(e_M2mu2MEC_8wp_clean) + 540];

i_M2mu2DG_c_clean_double = [rad2deg(i_M2mu2DG_c_clean)+180 rad2deg(i_M2mu2DG_c_clean) + 540];
i_M2mu2DG_3wp_clean_double = [rad2deg(i_M2mu2DG_3wp_clean)+180 rad2deg(i_M2mu2DG_3wp_clean) + 540];
i_M2mu2DG_8wp_clean_double = [rad2deg(i_M2mu2DG_8wp_clean)+180 rad2deg(i_M2mu2DG_8wp_clean) + 540];
e_M2mu2DG_c_clean_double = [rad2deg(e_M2mu2DG_c_clean)+180 rad2deg(e_M2mu2DG_c_clean) + 540];
e_M2mu2DG_3wp_clean_double = [rad2deg(e_M2mu2DG_3wp_clean)+180 rad2deg(e_M2mu2DG_3wp_clean) + 540];
e_M2mu2DG_8wp_clean_double = [rad2deg(e_M2mu2DG_8wp_clean)+180 rad2deg(e_M2mu2DG_8wp_clean) + 540];

i_M2mu2CA1_c_clean_double = [rad2deg(i_M2mu2CA1_c_clean)+180 rad2deg(i_M2mu2CA1_c_clean) + 540];
i_M2mu2CA1_3wp_clean_double = [rad2deg(i_M2mu2CA1_3wp_clean)+180 rad2deg(i_M2mu2CA1_3wp_clean) + 540];
i_M2mu2CA1_8wp_clean_double = [rad2deg(i_M2mu2CA1_8wp_clean)+180 rad2deg(i_M2mu2CA1_8wp_clean) + 540];
e_M2mu2CA1_c_clean_double = [rad2deg(e_M2mu2CA1_c_clean)+180 rad2deg(e_M2mu2CA1_c_clean) + 540];
e_M2mu2CA1_3wp_clean_double = [rad2deg(e_M2mu2CA1_3wp_clean)+180 rad2deg(e_M2mu2CA1_3wp_clean) + 540];
e_M2mu2CA1_8wp_clean_double = [rad2deg(e_M2mu2CA1_8wp_clean)+180 rad2deg(e_M2mu2CA1_8wp_clean) + 540];

i_M3mu2MEC_c_clean_double = [rad2deg(i_M3mu2MEC_c_clean)+180 rad2deg(i_M3mu2MEC_c_clean) + 540];
i_M3mu2MEC_3wp_clean_double = [rad2deg(i_M3mu2MEC_3wp_clean)+180 rad2deg(i_M3mu2MEC_3wp_clean) + 540];
i_M3mu2MEC_8wp_clean_double = [rad2deg(i_M3mu2MEC_8wp_clean)+180 rad2deg(i_M3mu2MEC_8wp_clean) + 540];
e_M3mu2MEC_c_clean_double = [rad2deg(e_M3mu2MEC_c_clean)+180 rad2deg(e_M3mu2MEC_c_clean) + 540];
e_M3mu2MEC_3wp_clean_double = [rad2deg(e_M3mu2MEC_3wp_clean)+180 rad2deg(e_M3mu2MEC_3wp_clean) + 540];
e_M3mu2MEC_8wp_clean_double = [rad2deg(e_M3mu2MEC_8wp_clean)+180 rad2deg(e_M3mu2MEC_8wp_clean) + 540];

i_M3mu2DG_c_clean_double = [rad2deg(i_M3mu2DG_c_clean)+180 rad2deg(i_M3mu2DG_c_clean) + 540];
i_M3mu2DG_3wp_clean_double = [rad2deg(i_M3mu2DG_3wp_clean)+180 rad2deg(i_M3mu2DG_3wp_clean) + 540];
i_M3mu2DG_8wp_clean_double = [rad2deg(i_M3mu2DG_8wp_clean)+180 rad2deg(i_M3mu2DG_8wp_clean) + 540];
e_M3mu2DG_c_clean_double = [rad2deg(e_M3mu2DG_c_clean)+180 rad2deg(e_M3mu2DG_c_clean) + 540];
e_M3mu2DG_3wp_clean_double = [rad2deg(e_M3mu2DG_3wp_clean)+180 rad2deg(e_M3mu2DG_3wp_clean) + 540];
e_M3mu2DG_8wp_clean_double = [rad2deg(e_M3mu2DG_8wp_clean)+180 rad2deg(e_M3mu2DG_8wp_clean) + 540];

i_M3mu2CA1_c_clean_double = [rad2deg(i_M3mu2CA1_c_clean)+180 rad2deg(i_M3mu2CA1_c_clean) + 540];
i_M3mu2CA1_3wp_clean_double = [rad2deg(i_M3mu2CA1_3wp_clean)+180 rad2deg(i_M3mu2CA1_3wp_clean) + 540];
i_M3mu2CA1_8wp_clean_double = [rad2deg(i_M3mu2CA1_8wp_clean)+180 rad2deg(i_M3mu2CA1_8wp_clean) + 540];
e_M3mu2CA1_c_clean_double = [rad2deg(e_M3mu2CA1_c_clean)+180 rad2deg(e_M3mu2CA1_c_clean) + 540];
e_M3mu2CA1_3wp_clean_double = [rad2deg(e_M3mu2CA1_3wp_clean)+180 rad2deg(e_M3mu2CA1_3wp_clean) + 540];
e_M3mu2CA1_8wp_clean_double = [rad2deg(e_M3mu2CA1_8wp_clean)+180 rad2deg(e_M3mu2CA1_8wp_clean) + 540];

%%
% making csv sheet
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\';
if exist(savepath)==0
     mkdir(savepath);
end
writematrix(i_M2mu2MEC_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2MEC_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M2mu2MEC_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2MEC_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M2mu2MEC_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2MEC_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2MEC_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2MEC_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2MEC_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2MEC_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2MEC_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2MEC_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

writematrix(i_M2mu2DG_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2DG_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M2mu2DG_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2DG_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M2mu2DG_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2DG_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2DG_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2DG_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2DG_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2DG_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2DG_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2DG_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

writematrix(i_M2mu2CA1_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2CA1_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M2mu2CA1_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2CA1_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M2mu2CA1_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M2mu2CA1_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2CA1_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2CA1_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2CA1_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2CA1_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M2mu2CA1_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M2mu2CA1_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

writematrix(i_M3mu2MEC_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2MEC_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M3mu2MEC_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2MEC_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M3mu2MEC_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2MEC_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2MEC_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2MEC_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2MEC_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2MEC_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

writematrix(i_M3mu2DG_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2DG_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M3mu2DG_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2DG_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M3mu2DG_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2DG_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2DG_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2DG_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2DG_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2DG_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2DG_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2DG_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

writematrix(i_M3mu2CA1_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2CA1_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M3mu2CA1_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2CA1_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(i_M3mu2CA1_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\i_M3mu2CA1_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_c_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2CA1_c_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_3wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2CA1_3wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writematrix(e_M3mu2CA1_8wp_clean_double, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\singleunit_phaseloc\MECunits\theta\combinedcontrol\prismrval\mu\e_M3mu2CA1_8wp_clean_double.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 