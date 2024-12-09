%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% This script is to output the power and coh data for seizure correlation 
% Susie 3/5/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'};

[ana_dir]=get_ana(animals);
load([ana_dir '\probe_data\ECHIP512.mat'])
state = 'running';
overwrite = 0;
filtertype = 'theta';
track = '1';
%%%%%prep sets of list for CA1DG      
CA1DGanimal3wp=1; %served as counter
CA1DGanimal3wc=1;
CA1DGanimal8wp=1;
CA1DGanimal8wc=1;


LMMolPower3wp = [];
LMMolPower3wc = [];
LMMolPower8wp = [];
LMMolPower8wc = [];

aniamlname_3wc = {};
aniamlname_8wc = {};
aniamlname_3wp = {};
aniamlname_8wp = {};
%% Output LSM/MO power for each animal 
 for anim=1:length(animals)
         animal=animals{anim};
%need to handle the missing shank situation
         [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
         [animalCA1DGmatrix, animalCA3matrix, animalMECmatrix, animalLECmatrix]=getanimalmatrixHPCEC_SF(animal, overwrite);
         exp_dir=get_exp(animal);
         expinfo = load([exp_dir 'exp.mat']);
         badchannels = expinfo.badchannels;
         load([exp_dir '\LFP\PowerByChannel\' state '\seizclean\'  animal '_' filtertype 'powerbychannel.mat']);

         
         % Note NPower indexing from 1-64, so Or at the bottom in NPower matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%CA1DG power calculation   
%%
        %take care of bad ch for this entire sceipt by modify NPower matrix
        %loop into NPower matrix, when run into bad ch, replace it with the average of neighbor 2 entries
        for i = 1:length(badchannels)
            loc = find(probelayout == badchannels(i)); %loc will be in order from 1-512, going from top to bottom, left to right

            %deal with edge channels (ch1 and ch64), when run into edge chs, just take the ch after it or before it
            if ismember(badchannels(i), [54 75 139 246 310 331 395 502]) %bad ch on the top
                NPower(loc) = NPower(loc+1); 
            elseif  ismember( badchannels(i), [47 82 146 239 303 338 402 495]) %bad ch on the bottom
                NPower(loc) = NPower(loc-1);                   
            else
                NPower(loc) = mean([NPower(loc-1) NPower(loc+1)], 'omitnan'); %bad ch in the middle, replace the bad ch power value with the average value of neighbor channels
            end
        end

         shank = CA1DGshank;
         animalmatrix = animalCA1DGmatrix;
         
         [ch]=getchannels(animal,shank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 

         group = ch.group; 
         MidPyr=ch.MidPyr; Pyr1=ch.Pyr1; Pyr2=ch.Pyr2; Or1=ch.Or1; Or2=ch.Or2; Rad1=ch.Rad1; Rad2=ch.Rad2;
         LM1=ch.LM1; LM2=ch.LM2; Mol1=ch.Mol1; Mol2=ch.Mol2; GC1=ch.GC1; GC2=ch.GC2; Hil1=ch.Hil1; Hil2=ch.Hil2; LB1=ch.LB1; LB2=ch.LB2;

         MatPower=[];
        for a=1:length(animalmatrix) %need to handle the Nan here, just get make them nan so dimention stay the same
            
            if isnan(animalmatrix(a))
                MatPower(a,1)=NaN;
            else
                MatPower(a,1)=NPower(animalmatrix(a),shank);
            end
        end
        

        %%
        %below is raw mean power before putting into animal matrix format
%         OrPower= nanmean(NPower(Or2:Or1,shank));
%         PyrPower= nanmean(NPower(Pyr2:Pyr1,shank));
%         RadPower= nanmean(NPower(Rad2:Rad1,shank));
%         LMPower= nanmean(NPower(LM2:LM1,shank));
%         MolPower= nanmean(NPower(Mol2:Mol1,shank));
%         GCPower= nanmean(NPower(GC2:GC1,shank));
%         HilPower= nanmean(NPower(Hil2:Hil1,shank));
%         LBPower= nanmean(NPower(LB2:LB1,shank));
        LMMolPower = nanmean(NPower(Mol2:LM1,shank));

        if strcmp(group, '3wp')==1  
            LMMolPower3wp(CA1DGanimal3wp,:)=LMMolPower;   
            aniamlname_3wp(CA1DGanimal3wp,:) = {convertCharsToStrings(animal)};
            CA1DGanimal3wp=CA1DGanimal3wp+1;
            
        elseif strcmp(group, '3wc')==1  
            LMMolPower3wc(CA1DGanimal3wc,:)=LMMolPower;   
            aniamlname_3wc(CA1DGanimal3wc,:) = {convertCharsToStrings(animal)};
            CA1DGanimal3wc=CA1DGanimal3wc+1;
            
        elseif strcmp(group, '8wp')==1  
            LMMolPower8wp(CA1DGanimal8wp,:)=LMMolPower;   
            aniamlname_8wp(CA1DGanimal8wp,:) = {convertCharsToStrings(animal)};
            CA1DGanimal8wp=CA1DGanimal8wp+1;
            
            
        elseif strcmp(group, '8wc')==1
            LMMolPower8wc(CA1DGanimal8wc,:)=LMMolPower;  
            aniamlname_8wc(CA1DGanimal8wc,:) = {convertCharsToStrings(animal)};
            CA1DGanimal8wc=CA1DGanimal8wc+1;  
        end


 end
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\';
if exist(savepath)==0
    mkdir(savepath);
end
LMMolPower3wctable = table(aniamlname_3wc, LMMolPower3wc);
LMMolPower8wctable = table(aniamlname_8wc, LMMolPower8wc);
LMMolPower3wptable = table(aniamlname_3wp, LMMolPower3wp);
LMMolPower8wptable = table(aniamlname_8wp, LMMolPower8wp);
writetable(LMMolPower3wctable, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\LMMolPower3wctable.csv','Delimiter',',');
writetable(LMMolPower8wctable, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\LMMolPower8wctable.csv','Delimiter',',');
writetable(LMMolPower3wptable, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\LMMolPower3wptable.csv','Delimiter',',');
writetable(LMMolPower8wptable, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\LMMolPower8wptable.csv','Delimiter',',');

%% Coh (I'm lazy so I'm reusing animalname)

cohdir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Coherence\03282022_allanimal';
if exist(cohdir)==0
    mkdir(cohdir)
end
load([cohdir '\full_ECHIP_coherence_' filtertype '_track' track '.mat'],'single_3wc' ,'single_3wp' ,'single_8wc' ,'single_8wp');  

hil2pyr_3wc = [];
hil2pyr_8wc = [];
hil2pyr_3wp = [];
hil2pyr_8wp = [];

MEC32MEC_3wc = [];
MEC32MEC_8wc = [];
MEC32MEC_3wp = [];
MEC32MEC_8wp = [];

MEC22MO_3wc = [];
MEC22MO_8wc = [];
MEC22MO_3wp = [];
MEC22MO_8wp = [];

% Hil2Pyr (2,7)
for i = 1:size(single_3wc,3)
    hil2pyr_3wc(i,:) = single_3wc(2,7,i);
end
for i = 1:size(single_8wc,3)
    hil2pyr_8wc(i,:) = single_8wc(2,7,i);
end
for i = 1:size(single_3wp,3)
    hil2pyr_3wp(i,:) = single_3wp(2,7,i);
end
for i = 1:size(single_8wp,3)
    hil2pyr_8wp(i,:) = single_8wp(2,7,i);
end
hil2pyrcoh_3wc = table(aniamlname_3wc, hil2pyr_3wc);
hil2pyrcoh_8wc = table(aniamlname_8wc, hil2pyr_8wc);
hil2pyrcoh_3wp = table(aniamlname_3wp, hil2pyr_3wp);
hil2pyrcoh_8wp = table(aniamlname_8wp, hil2pyr_8wp);
writetable(hil2pyrcoh_3wc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\hil2pyrcoh_3wc.csv','Delimiter',',');
writetable(hil2pyrcoh_8wc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\hil2pyrcoh_8wc.csv','Delimiter',',');
writetable(hil2pyrcoh_3wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\hil2pyrcoh_3wp.csv','Delimiter',',');
writetable(hil2pyrcoh_8wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\hil2pyrcoh_8wp.csv','Delimiter',',');

% MEC3 2 MEC2 (12,13)
for i = 1:size(single_3wc,3)
    MEC32MEC_3wc(i,:) = single_3wc(12,13,i);
end
for i = 1:size(single_8wc,3)
    MEC32MEC_8wc(i,:) = single_8wc(12,13,i);
end
for i = 1:size(single_3wp,3)
    MEC32MEC_3wp(i,:) = single_3wp(12,13,i);
end
for i = 1:size(single_8wp,3)
    MEC32MEC_8wp(i,:) = single_8wp(12,13,i);
end
MEC32MECcoh_3wc = table(aniamlname_3wc, MEC32MEC_3wc);
MEC32MECcoh_8wc = table(aniamlname_8wc, MEC32MEC_8wc);
MEC32MECcoh_3wp = table(aniamlname_3wp, MEC32MEC_3wp);
MEC32MECcoh_8wp = table(aniamlname_8wp, MEC32MEC_8wp);
writetable(MEC32MECcoh_3wc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC32MECcoh_3wc.csv','Delimiter',',');
writetable(MEC32MECcoh_8wc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC32MECcoh_8wc.csv','Delimiter',',');
writetable(MEC32MECcoh_3wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC32MECcoh_3wp.csv','Delimiter',',');
writetable(MEC32MECcoh_8wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC32MECcoh_8wp.csv','Delimiter',',');


% MEC2 2 MO (13, 5)
for i = 1:size(single_3wc,3)
    MEC22MO_3wc(i,:) = single_3wc(13,5,i);
end
for i = 1:size(single_8wc,3)
    MEC22MO_8wc(i,:) = single_8wc(13,5,i);
end
for i = 1:size(single_3wp,3)
    MEC22MO_3wp(i,:) = single_3wp(13,5,i);
end
for i = 1:size(single_8wp,3)
    MEC22MO_8wp(i,:) = single_8wp(13,5,i);
end
MEC22MOcoh_3wc = table(aniamlname_3wc, MEC22MO_3wc);
MEC22MOcoh_8wc = table(aniamlname_8wc, MEC22MO_8wc);
MEC22MOcoh_3wp = table(aniamlname_3wp, MEC22MO_3wp);
MEC22MOcoh_8wp = table(aniamlname_8wp, MEC22MO_8wp);
writetable(MEC22MOcoh_3wc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC22MOcoh_3wc.csv','Delimiter',',');
writetable(MEC22MOcoh_8wc, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC22MOcoh_8wc.csv','Delimiter',',');
writetable(MEC22MOcoh_3wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC22MOcoh_3wp.csv','Delimiter',',');
writetable(MEC22MOcoh_8wp, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\seizurecorr\MEC22MOcoh_8wp.csv','Delimiter',',');
                
