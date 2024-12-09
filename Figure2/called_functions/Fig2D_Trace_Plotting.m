%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is to plot example raw trace for each group
% pick one mid ch as represent ch
% susie 5/10/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HPC
animal = 'TS118-4'; %3wp
animal = 'TS111-2'; %8wp
animal = 'TS116-2'; %control
animal = 'TS110-3'; %3wp

tmin=999.5;
tmax=1000.5;%in seconds

samplingrate=25000;
tmin_ind=tmin*samplingrate;
tmax_ind=tmax*samplingrate;
%timepar=linspace(tmin,tmax,(tmax-tmin)*samplingrate+1);

exp_dir=get_exp(animal);
[ana_dir]=get_ana(animal);
load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
load([ana_dir '\probe_data\ECHIP512.mat'])
[CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
shank = CA1DGshank(1);
[ch]=getchannels(animal,shank);
MEC3ch = round(mean([ch.Or1 ch.Or2]));
MEC3ch = probelayout(MEC3ch,shank);
MEC2ch = ch.MidPyr;
MEC2ch = probelayout(MEC2ch,shank);
MEC1ch = round(mean([ch.Rad1 ch.Rad2]));
MEC1ch = probelayout(MEC1ch,shank);
lmch = round(mean([ch.LM1 ch.LM2]));
lmch = probelayout(lmch,shank);
molch = round(mean([ch.Mol1 ch.Mol2]));
molch = probelayout(molch,shank);
gcch = round(mean([ch.GC1 ch.GC2]));
gcch = probelayout(gcch,shank);
hilch = round(mean([ch.Hil1 ch.Hil2]));
hilch = probelayout(hilch,shank);
%lbch = round(mean([ch.LB1 ch.LB2]));
or = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(MEC3ch) '.mat']);
pyr = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(MEC2ch) '.mat']); 
rad = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(MEC1ch) '.mat']); 
lm = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(lmch) '.mat']); 
mol = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(molch) '.mat']); 
gc = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(gcch) '.mat']); 
hil = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(hilch) '.mat']); 



figure('Renderer', 'painters', 'Position', [10 10 600 900])
subplot(7,1,1)
plot(or.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
subplot(7,1,2)
plot(pyr.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
subplot(7,1,3)
plot(rad.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
subplot(7,1,4)
plot(lm.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
subplot(7,1,5)
plot(mol.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
subplot(7,1,6)
plot(gc.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
subplot(7,1,7)
plot(hil.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-800,800]);
xlabel('Time(seconds)');
ylabel('Raw LFP');


%%
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\rawtraceplot\';
if exist(savepath)==0
     mkdir(savepath);
end
title('3wp 110-3' )
saveas(gca, fullfile(savepath, '3wp raw trace 110-3 999-1000'), 'svg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% MEC


animal = 'TS115-2'; %control
animal = 'TS118-4'; %3wp
animal = 'TS115-1'; %8wp
tmin=2400;
tmax=2401;%in seconds

samplingrate=25000;
tmin_ind=tmin*samplingrate;
tmax_ind=tmax*samplingrate;
%timepar=linspace(tmin,tmax,(tmax-tmin)*samplingrate+1);

exp_dir=get_exp(animal);
[ana_dir]=get_ana(animal);
load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
load([ana_dir '\probe_data\ECHIP512.mat'])
[CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
shank = MECshank(1);
[ch]=getchannels(animal,shank);
MEC3ch = round(mean([ch.MEC31 ch.MEC32]));
MEC3ch = probelayout(MEC3ch,shank);
MEC2ch = round(mean([ch.MEC21 ch.MEC22]));
MEC2ch = probelayout(MEC2ch,shank);
MEC1ch = round(mean([ch.MEC11 ch.MEC12]));
MEC1ch = probelayout(MEC1ch,shank);

MEC3 = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(MEC3ch) '.mat']);
MEC2 = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(MEC2ch) '.mat']); 
MEC1 = load([exp_dir 'LFP\Backsub\LFPvoltage_ch' num2str(MEC1ch) '.mat']); 




figure('Renderer', 'painters', 'Position', [10 10 600 400])
subplot(3,1,1)
plot(MEC3.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-250,250]);
subplot(3,1,2)
plot(MEC2.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-250,250]);
subplot(3,1,3)
plot(MEC1.LFPvoltage(tmin_ind:tmax_ind))
xlim([0,25000]);
ylim([-250,250]);
xlabel('Time(seconds)');
ylabel('Raw LFP');

%%
savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\rawtraceplot\';
if exist(savepath)==0
     mkdir(savepath);
end
title('8wp MEC 115-1' )
saveas(gca, fullfile(savepath, '8wp MEC raw trace 115-1 2400-2401'), 'svg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

