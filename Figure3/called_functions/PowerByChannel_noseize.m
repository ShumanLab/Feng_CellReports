%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input: stimuli animal_VRstatearrays.mat, LFPvoltage_ch individual file in LFP/frequency folder
%Outout: animal_filtertype powerbychannel.mat, with Power and NPower matrix
%in; seizing and non_seizing state array

%bad channels are not being taken care of during this step
%written by susie - 02/25/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Power, NPower] = PowerByChannel_noseize(animal, state, filtertype, probetype, seizwd)
% animal = 'TS116-0';
% state = 'running';
% filtertype = 'theta';
% probetype = 'ECHIP512';
% seizwd = 600; %in sec

[ana_dir]=get_ana(animal);

load([ana_dir '\probe_data\ECHIP512.mat'])
numshanks=8;
numchans=512;
%%%%%%% all below is to just calc non run for DGCA1 shank
%  numshanks = 1;
%  numchans=64;
%  [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
  shankHPC = CA1DGshank;

[t0 t1]=gettime(animal, 'all', '1000');    
exp_dir=get_exp(animal);
expinfo = load([exp_dir 'exp.mat']);

load([exp_dir '\stimuli\' animal '_VRstatearrays.mat']);

btimes=bintimes(:,2); %from VRstatearrays
lastbin=find(btimes>=t1/1000,1,'first')-1;

if isempty(lastbin)==0
    bins=lastbin;
else
    bins=size(bintimes,1);
end

                    %BELOW is to generate seizing and nonseizing array
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    totalbins = bins; %this is to align bin number and size with running bin size, which was set binsize as 0.1s
                    seizing = zeros(1, totalbins);
                    nonseizing = zeros(1, totalbins);
                    bintimes_seize=zeros(totalbins,2);
                    seiztp = expinfo.seiz_time; %in sec
    
                    if strcmp(seiztp, 'na')==1  
                        seizing = zeros(1, totalbins);
                        nonseizing = ones(1, totalbins);
                    else
                        seizing = zeros(1, totalbins);
                        nonseizing = ones(1, totalbins);
                        seiztp_10 = seiztp * 10; %convert seizure timepoint from sec to 10Hz to fit with 0.1s bins

                        for s = 1:length(seiztp) %create seziing array
                            seizing(seiztp_10(s):seiztp_10(s)+seizwd/binsize-1)=1;  %put where seizure start to where seizre ends as 1 in seizing array
                        end

                        for bin = 1: totalbins  %create nonseizing array
                            if seizing(bin) == 1
                                nonseizing(bin) = 0;
                            elseif seizing(bin) == 0
                                nonseizing(bin) = 1;
                            end
                        end

                    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
if strcmp(state, 'running')==1
   
    %calculate filtered power
    Power=NaN(numchans/numshanks, numshanks);
    NPower=NaN(numchans/numshanks, numshanks);
    cd(strcat(exp_dir, '\LFP\', filtertype));
    for shank=1:numshanks
        for chi=1:64
            ch=probelayout(chi,shank);

             if exist(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'))>0
                load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
                else
                    Power(chi,shank)=NaN;
                    NPower(chi,shank)=NaN;
             end    %calculate power for each bin

                ch_power=0;
                ch_power_div=0;                        
                actualnoise=0;

                %run test through here
                for b=1:bins
                    if bintimes(b,1)<=0
                        continue  %ignore and skip the first 0 index
                    end
                    
                    %BELOW is TAKING OUT SEIZURE TIME
                    %%%%%%%%%%%%%%%%%%%%%%%%%
%                     if (mod(bin,5000)==0)
%                        sprintf(['Running VR state arrays for ' animal '. %2.0f%% done.'], bin/totalbins*100)
%                     end                       
                        
                    if seizing(b)>0 %define seizuretimes as boolean of seizure yes/no
                        continue
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%
 
                    if running(b)==1  
                       x=filt_data(round(bintimes(b,1)*1000):round(bintimes(b,2)*1000));
                       power = (norm(x)^2)/length(x);  %by def how power is calc
                       ch_power=ch_power+power;
                       ch_power_div=ch_power_div+1;
                    end
                end
                    Power(chi,shank)=ch_power;
                    NPower(chi,shank)=ch_power/ch_power_div;

        end
    end


    
%BELOW IS NON RUNNING STATE 
elseif strcmp(state, 'non-running')==1

%calculate filtered power
    Power=NaN(numchans/numshanks, numshanks);
    NPower=NaN(numchans/numshanks, numshanks);
    cd(strcat(exp_dir, '\LFP\', filtertype));
    for shank=1:numshanks
        for chi=1:64
        ch=probelayout(chi,shankHPC); %for non running power purpose
       % ch=probelayout(chi,shank);
            if exist(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'))>0
            load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
            else
                Power(chi,shank)=NaN;
                NPower(chi,shank)=NaN;
                continue
            end    %calculate power for each bin

        ch_power=0;
        ch_power_div=0;

        for b=1:bins
            if bintimes(b,1)<=0 || round(bintimes(b,2)*1000)>length(filt_data)
                continue
            end
  %BELOW is TAKING OUT SEIZURE TIME
 %%%%%%%%%%%%%%%%%%%%%%
%                     if (mod(bin,5000)==0)
%                        sprintf(['Running VR state arrays for ' animal '. %2.0f%% done.'], bin/totalbins*100)
%                     end                       
                        
                    if seizing(b)>0 %define seizuretimes as boolean of seizure yes/no
                        continue
                    end
 %%%%%%%%%%%%%%%%%%%%%%%%%                  
            if nonrunning(b)==1
               x=filt_data(round(bintimes(b,1)*1000):round(bintimes(b,2)*1000));

            power = (norm(x)^2)/length(x);
            ch_power=ch_power+power;
            ch_power_div=ch_power_div+1;
            end
        end
        Power(chi,shank)=ch_power;
        NPower(chi,shank)=ch_power/ch_power_div;
    end
    end
    
end

if exist(strcat(exp_dir, '\LFP\PowerByChannel\', state,'\seizclean\'))==0
    mkdir(strcat(exp_dir, '\LFP\PowerByChannel\', state, '\seizclean\'));
end


cd(strcat(exp_dir, '\LFP\PowerByChannel\', state, '\seizclean\'));
save(strcat(animal, '_', filtertype, 'powerbychannel.mat'), 'Power', 'NPower','ch_power_div');

% cd(strcat(exp_dir, '\stimuli\'));
% save(strcat(animal, '_seizstatearray.mat'), 'seizing', 'nonseizing');
disp(['done with animal' animal])


end





