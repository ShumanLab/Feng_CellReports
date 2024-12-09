%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract raw LFP into one unified file 
%Input: ECHIP512.mat, position_dense64.mat, LFPvoltage_ch.mat (notch filtered)
%Output: animal_shank_LFP.mat
%don't handle bad ch 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function extractLFP2_restricttime(animal,probe,shank,time)   %time in sec
    exp_dir=get_exp(animal);
    ana_dir=get_ana(animal);
    
%     [~, shank]=getCA1DGlocations(animal, side); %only needed for old data   

%load bad channels - susie.
% 4/29/21 susie decides she doesn't want to take out bad channels at this step
% expinfo = load([exp_dir 'exp.mat']);
% badchannels = expinfo.badchannels;

    %get probelayout and arrayposition
    if strcmp(probe, 'ECHIP512')==1
load([ana_dir '\probe_data\ECHIP512.mat']);
load([ana_dir '\probe_data\position_dense64.mat']);

    end
    
    
    shank_array=probelayout(:,shank);
    if time==0
    [t0, t1]=gettime(animal, 'all','1000');
    else
        %restrict time
        t1=time*1000;
    end
        t1=floor(t1);
        LFP=NaN(length(shank_array),t1);

        

    for chi=1:length(shank_array)
        ch=shank_array(chi);
        cd([exp_dir '\LFP\LFP1000']);
        if exist(['LFPvoltage_ch' num2str(ch) '.mat'])>0 %  && isempty(intersect(badchannels,ch))==1   %susie decided to not taking care of bad channels at this step
            load(['LFPvoltage_ch' num2str(ch) '.mat'], 'LFPvoltage_notch');
            LFP(chi,:)=LFPvoltage_notch(1:t1);
        else
            LFP(chi,:)=NaN(1,t1);
        end
    end
    
cd([exp_dir '\LFP']);

save([animal '_shank' num2str(shank) '_LFP.mat'], '-v7.3', 'LFP');

end








