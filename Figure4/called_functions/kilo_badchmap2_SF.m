%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is to fix the post kilosort mis labelled channel for each cluster DURING spikeprocessing
%This is a replacement for kilo_badchmap_SF which was used to post fix after spike processing
%INPUT: animal, shank, cells mat file post phyoutput_SF function, AND channel_map.csv generated from python to do the actual mapping
%OUTPUT: In cells at file, create a new viable showing the updated highest ch
%Susie 4/19/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [correctch] = kilo_badchmap2_SF(animal, shank, clusterch)
    shankname = ['shank' num2str(shank)];
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
   % load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run']) %read unit info from cells.m, for now susie only saved unit info in cells.m, not MUA
    channel_map = readtable(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\channel_map']); %run_time matrix is in sec unit
    channel_map = table2cell(channel_map);
  
    oldch = clusterch;
    a = find(strcmp(channel_map(:,3),animal)==1);
    b = find(strcmp(channel_map(:,4),shankname)==1);
    animalind = intersect(a,b);
    clear a b;
    
    
    correctch = {};
    for i = 1:length(oldch)
        chmap_subset = channel_map(animalind,:); %subset from channel_map
        idx = find([0; cell2mat(chmap_subset(:,1))]==oldch(i));
        idx = idx-1; %it's offset by 1 for some reason
        correctch(i) =  chmap_subset(idx,2);
    end
  
    correctch = cell2mat(correctch);
    %units.correctclusterch = correctch;
    %save(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '_processedunits_run.mat'],'units') 
end