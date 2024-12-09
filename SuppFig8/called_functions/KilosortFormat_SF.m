%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%This script take file from backsub folder and write binary files in kilosort folder in Susie's folder in L drive 
%starting from Backsub files (LFPvoltage_chX.mat

%INPUTS
    %probelayout = channel configuration
        %should be .mat double with rows = chan nums, columns = shanks
    %mouse = mouse name 
    %shanks = which shanks to process ex: [3 7]
    %time = desired recording time to process in seconds (0 if full file time)
    %first 60 mins = 3600 
    %dir = filepath ('my\files\are\here\') for binary file output
    
    %for now set directory with "backsub" files to working directory - add a ugetdir function later 
    %example: KilosortFormat(probelayout, '3xTg49-1', [4 7], 3600, 'J:\data analysis\3xTgAD\3xTg49-1\201115\Recording\LFP\Full\')

%OUTPUT:
    %binary mat file in  savedir = ['L:\Susie\kilosort\' animal '\'];
    %non binary mat file save to whereever MATLAB's current dir is (not
    %sure how this is being saved, or if need this during post kilosort analysis)
%wirtten by Alie, modified by Susie to fit her pueposes, 9/3/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

    function KilosortFormat_SF(probelayout,animal,shanks,timefull,t0,t1)    %getting number of shanks in probelayout
    [ana_dir]=get_ana(animal);
    exp_dir=get_exp(animal);
    %dir = uigetdir; %select where the full data is located (either full or backsub)
    if strcmp(probelayout,'ECHIP512')==1
    load([ana_dir '\probe_data\ECHIP512.mat']) %getting number of shanks in probelayout
    end
    dir = [exp_dir 'LFP\Backsub'];
    
    for i = 1:length(shanks)
         savedir = ['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shanks(i)) '\'];
         if exist(savedir)==0
            mkdir(savedir)
         end
        nameShank = [animal 'Shank' num2str(shanks(1,i))];
        %making matfile for loading channels 
        m = matfile(nameShank,'Writable',true);
        for a = 1:length(probelayout(:,i))
            %a iterator is for num of channels on each shank 
            %(must be equal across shanks)
            %finding channel number a of shank i
            numChan = probelayout(a,shanks(1,i));
            %creating filename for chan a shank i 
            nameChan = ['LFPvoltage_ch' num2str(numChan) '.mat'];
            %chanFile = matfile(nameChan,'Writable',true);
            if exist([dir '\' nameChan])==2 %handle non-exsit file when using back_sub data
            try    
            load([dir '\' nameChan]);
            
                if timefull==1 %when processing the whole recording
                    time=length(LFPvoltage)/25000;
                    LFPvoltage=LFPvoltage(1:time*25000);
                    m.LFPvoltage(a,1:length(LFPvoltage)) = int16(LFPvoltage);   
                else %when using a time window
                    LFPvoltage=LFPvoltage(t0*25000:t1*25000);
                    m.LFPvoltage(a,1:length(LFPvoltage)) = int16(LFPvoltage);   
                end
            end
            end  
        end
        %saving MATfile to binary file type (required by kilosort)
            %possibly add fullfile function before this to set filename
        fid = fopen([savedir, 'binary', nameShank, '.mat'], 'w'); 
        %fwrite(fid, m.LFPvoltage, 'int16');
        fwrite(fid, m.LFPvoltage, 'int16');        
    end

end 

