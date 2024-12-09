function createBackgroundFile_badch_out_SF(animal,probetype)
%subtracts background according to each shank
% We take bad ch out when calculating the background noise, but still have
% a full size of channels set in output files


clear background1 background
exp_dir=get_exp(animal);
ana_dir=get_ana(animal);
%shanks are ordered by channel
%load bad channel mapped number
expinfo = load([exp_dir 'exp.mat']);
badchannels = expinfo.badchannels;

if strcmp(probetype, '128A_bottom')==1
    numshanks=2;
    ch_shank=[ones(1,64) ones(1,64)*2];  % in HPC=> shank2=medial, shank1=lateral
    numchannels=128;
elseif strcmp(probetype, 'ECHIP512')==1
     numshanks=8;
     ch_shank=[ones(1,64) ones(1,64)*2 ones(1,64)*3 ones(1,64)*4 ones(1,64)*5 ones(1,64)*6 ones(1,64)*7 ones(1,64)*8];
     numchannels=512;
elseif strcmp(probetype,'ECHIP512_3xTg1-2')==1
    numshanks=8;
    numchannels=512;
    ch_shank=[ones(1,64)*3 ones(1,64)*4 ones(1,64)*1 ones(1,64)*2 ones(1,64)*5 ones(1,64)*6 ones(1,64)*7 ones(1,64)*8];
end


for shank=1:numshanks

    %create background file for each shank
    bch=0;
    tic
    chan_shank=find(ch_shank==shank);
    for ch=chan_shank
        if ismember(ch, badchannels)==1    %leave bad channels out of calculating the mean
            continue
        else
           file=[exp_dir '\LFP\Full\LFPvoltage_ch' num2str(ch) '.mat'];
                if exist(file)==0
                    continue
                end
                if bch==0 
                   load(file)
                   background1=LFPvoltage;
                   bch=bch+1;
                else
                   bch=bch+1;
                   load(file)
                   background1=background1+LFPvoltage;
                end
            display(['Channel: ' num2str(ch)]);
           toc 
        end
    end


    background=background1/bch;


    if exist ([exp_dir '\LFP\BackSub'])==0
        mkdir([exp_dir '\LFP\BackSub']);
    end
    save([exp_dir '\LFP\BackSub\Background_shank' num2str(shank) '.mat'], 'background', '-v7.3');
    display(['Saved Background Shank ' num2str(shank)])

    
    %go through each channel and subtract background
    for ch=chan_shank
      file=[exp_dir '\LFP\Full\LFPvoltage_ch' num2str(ch) '.mat'];
      if exist(file)==0
          continue
      end

        load(file)
        background_ch=LFPvoltage-background;
        LFPvoltage=background_ch;
        
        
        % changed to v7.3 so no need for this i think
%         if length(LFPvoltage)>520*20*25000  
%             LFPvoltage=LFPvoltage(1:520*20*25000);
%         end
        
    LFPvoltage=single(LFPvoltage);
        
    save([exp_dir '\LFP\BackSub\LFPvoltage_ch' num2str(ch) '.mat'], 'LFPvoltage', '-v7.3');

    clear LFPvoltage
    clear background_ch
    display(['Done with channel: ' num2str(ch)]);
       toc 
    end

end


end