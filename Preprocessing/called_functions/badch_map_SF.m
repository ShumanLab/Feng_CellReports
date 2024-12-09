function badch_map_SF(animal, probetype)

%This script is to load up bad channel number in the matter that shank1~8 has channel 1-64 from dorsal to ventual; then mapped the bad channel
%number to the actual probelayout channel number; 
%NOTE1: require to have badch.csv file in the raw data folder which has the first raw as shank number and bad channel fake index being recorded from row#2
%NOTE2: bad channels were collected by finding the dark channels in 1min coherence plot
%wrote by Susie - 11/2020

exp_dir=get_exp(animal);
ana_dir=get_ana(animal);
data_dir = uigetdir;

if strcmp(probetype, 'ECHIP512')==1
     numshanks=8;
     ch_shank=[ones(1,64) ones(1,64)*2 ones(1,64)*3 ones(1,64)*4 ones(1,64)*5 ones(1,64)*6 ones(1,64)*7 ones(1,64)*8];
     numchannels=512;
     load([ana_dir '\probe_data\ECHIP512.mat']);
end

badch = csvread([data_dir '\' animal 'bad_ch.csv']);
badch_counter = sum(sum(~isnan(badch) & badch~=0))-numshanks; %from badch matrix, first count how many non zero and not nan elements are there for each col,then sum them up and substract the header 8 elements
badchannelmapped = zeros(badch_counter,1); %create array that is the length of total bad channels

counter = 1 ;   %to use in write in badchannelmapped array
for sh = 1:numshanks    %loop through all shanks
    start = 2;   %start from the second row since the first row is shank index
    
    for ch =1:size(badch,1)-1  %the total rows in badch input matrix (max num of bad channels per shank)
        idx = badch(start, sh);   %idx is the index of the bad channel which will be mapped into probelayout
        if idx ~= 0    %the nans show as 0 in badch matrix, exclude them here
        realch_num = probelayout(idx, sh);    %map to probe layout matrix
        badchannelmapped(counter) = probelayout(idx, sh);
        start = start +1 ;
        counter = counter +1;
        else    %pass if the value is 0 in badch matrix
            continue;
        end
      
    end
end

save([exp_dir '\' animal 'badch_mapped.mat'], 'badchannelmapped');
end