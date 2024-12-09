%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to calculate the mean waveform for the 2 subpopulation in MEC3
% also to calculate the spk width
% susie 4/3/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

animals = { 'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%112-1 taken out since no master MEC; 113-2 out no master MEC
%110-0 117-4 113-3 seizures for control, taking out

animal =  'TS116-2'; %list of all animals for susie summer ephys experiment
%112-1 taken out since no master MEC; 113-2 out no master MEC
%110-0 117-4 113-3 seizures for control, taking out
track = '1';
exp_dir=get_exp(animal);
[ana_dir]=get_ana(animal);
load([ana_dir '\probe_data\ECHIP512.mat']);

[CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
shank = MECshank(1);

track= 1;
asym=[];
c=[];
a = [];
b = [];
meanAC=[];
burst=[];
mISI=[];
pval2MEC=[];
r2MEC=[];
mu2MEC=[];

CSI = [];
auto_corr = {};

animal_ind = {};
group_ind = {};


%cell regions
M1=[]; %MEC1
M2=[];
M3=[];

uind=0;  %master unit index

%for anim=1:length(animals)  %loop through all animals and get info about each cluster
%    animal=animals{anim};
%    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
%    for shank=[MECshank]  %for now I only have 1 shank for each animal, I will edit getshank function if later want to add more single units data from more shanks

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

                r2MEC(uind)=units.MECIIthetaPL{u}.r;
                mu2MEC(uind)=units.MECIIthetaPL{u}.mu;
                pval2MEC(uind) = units.MECIIthetaPL{u}.pval;

                burst(uind)=units.burst(u);
                mISI(uind)=units.mISI(u);
                auto_corr(uind)=units.auto(u);
                CSI(uind)=units.CSI(u);
   
                c(uind)=unitswholetrack.wavesc(u);
                a(uind)=unitswholetrack.wavesa(u);
                b(uind)=unitswholetrack.wavesb(u);
                asym(uind)=unitswholetrack.wavesasym(u); 
                FRmean(uind)=unitswholetrack.FRmean(u); %method 1: calculate the total time that each cluster show decent firing above meanFR. then devided by this time
                meanAC(uind)=unitswholetrack.meanAC(u);
                CSI(uind)=unitswholetrack.CSI(u);

            elseif isempty(units.spikes{u})
                disp(['empty cluster' num2str(u) 'in animal ' animal])
            end
        end
%   end %end each shank
%end %end each animal


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
e_M2mu2MEC_c = mu2MEC(eM2_c);
e_M2mu2MEC_3wp = mu2MEC(eM2_3wp);
e_M2mu2MEC_8wp = mu2MEC(eM2_8wp);

i_M2mu2MEC_c = mu2MEC(iM2_c);
i_M2mu2MEC_3wp = mu2MEC(iM2_3wp);
i_M2mu2MEC_8wp = mu2MEC(iM2_8wp);

e_M3mu2MEC_c = mu2MEC(eM3_c);
e_M3mu2MEC_3wp = mu2MEC(eM3_3wp);
e_M3mu2MEC_8wp = mu2MEC(eM3_8wp);

i_M3mu2MEC_c = mu2MEC(iM3_c);
i_M3mu2MEC_3wp = mu2MEC(iM3_3wp);
i_M3mu2MEC_8wp = mu2MEC(iM3_8wp);


e_M2r2MEC_c = r2MEC(eM2_c);
e_M2r2MEC_3wp = r2MEC(eM2_3wp);
e_M2r2MEC_8wp = r2MEC(eM2_8wp);

i_M2r2MEC_c = r2MEC(iM2_c);
i_M2r2MEC_3wp = r2MEC(iM2_3wp);
i_M2r2MEC_8wp = r2MEC(iM2_8wp);

e_M3r2MEC_c = r2MEC(eM3_c);
e_M3r2MEC_3wp = r2MEC(eM3_3wp);
e_M3r2MEC_8wp = r2MEC(eM3_8wp);

i_M3r2MEC_c = r2MEC(iM3_c);
i_M3r2MEC_3wp = r2MEC(iM3_3wp);
i_M3r2MEC_8wp = r2MEC(iM3_8wp);


%% establish rule for MEC3 cell cluster
% kmean

% control
r_scale_fac = 0.9*pi; %set a scale for kmean to perform non bias
[idx] = MECcluster_SF(r_scale_fac,e_M3r2MEC_c, e_M3mu2MEC_c);

% below is to assign high R and low R
Rval1 = mean(e_M3r2MEC_c(find(idx == 1)));
Rval2 = mean(e_M3r2MEC_c(find(idx == 2)));
if Rval1 > Rval2
    e_M3highRind_c = find(idx == 1); %this is index for r or mu value matrix, not the actual r/mu value
    e_M3lowRind_c = find(idx == 2);
else
    e_M3highRind_c = find(idx == 2);
    e_M3lowRind_c = find(idx == 1);
end

% assign orginal index to high/low R clusters
e_M3highRind_c_OG = [];
for i = 1:length(e_M3highRind_c)
    e_M3highRind_c_OG = [e_M3highRind_c_OG, eM3_c(e_M3highRind_c(i))];
end

e_M3lowRind_c_OG = [];
for i = 1:length(e_M3lowRind_c)
    e_M3lowRind_c_OG = [e_M3lowRind_c_OG, eM3_c(e_M3lowRind_c(i))];
end
%%
%%%%%%%%%%%%%%%%%%%%%%%
c = 20; %define which cluster to look
waveforms = units.waveforms(c);
spk = units.spikes(c);
spk =spk{1};
% I'm only taking the best waveform, ref waveformpolt_MEC if want to plot neighbor chs
bestch = units.correctclusterch(c);


filt_dir=[ana_dir '\filters\'];
load([filt_dir 'filt_600_6000.mat']);
bf=filt1.tf.num;
af=filt1.tf.den;

spikelim=1000;
if length(spk)<spikelim
    spikelim=length(spk); % -1; %susie add minus one to account for Index exceeds the number of array elements
end

lastspike=spk(spikelim);
prespike=25; %samples, 1 ms before
postspike=25; %samples, 1 ms after
realchset=probelayout(bestch,shank); %will need to replace with current shank
chspikes=zeros(spikelim,prespike+postspike,length(realchset));


 for r=1:length(realchset) %Susie: we are doing the waveform calculation base on backsub data instead of kilosort output since the latter doesn't have waveform info
    load([exp_dir '\LFP\BackSub\LFPvoltage_ch' num2str(realchset(r)) '.mat']); %loads backsub
    LFPvoltage=double(LFPvoltage);
    filt_data=filtfilt(bf,af,LFPvoltage(1:lastspike+25000));   

    for s=1:spikelim
        t0=spk(s)-prespike+1;
        t1=spk(s)+postspike;
        chspikes(s,:,r)=filt_data(t0:t1);
    end
 end
mspikes=squeeze(mean(chspikes,1));

figure('Renderer', 'painters', 'Position', [10 10 1000 500]);

 for r=1:length(realchset) %Susie: we are doing the waveform calculation base on backsub data instead of kilosort output since the latter doesn't have waveform info
       wavey=mspikes(1,:); %best waveform
       plot(wavey)
       ylim([-35,25])
 end


% manual save the plot if good - L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\waveform_exp

