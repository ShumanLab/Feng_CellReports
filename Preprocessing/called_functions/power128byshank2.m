function [LFP128, PX]=power128byshank2(animal, filtertype,probetype)
[ana_dir]=get_ana(animal);
%%%%% NEED TO CREATE PROBELAYOUT %%%%%%
if strcmp(probetype,'ECHIP512')==1
load([ana_dir '\probe_data\ECHIP512.mat'])
numshanks=8;
pershank=64;
elseif strcmp(probetype,'128A_bottom')==1
numshanks=2;
pershank=64;
load([ana_dir '\probe_data\probe128A_bottom.mat'])
end


maxpx=1000000; %this is the max number of trough it will find

exp_dir=get_exp(animal);
[t0, t1]=gettime(animal, 'all', '1000');    

cd(strcat(exp_dir, 'LFP\', filtertype));
LFP128=zeros(pershank,numshanks);
PX=cell(pershank,numshanks);
for shank=1:numshanks

    for ch=1:pershank    
        p=probelayout(ch,shank);

            if exist(strcat('LFPvoltage_ch', num2str(p), filtertype, '.mat'))>0
            load(strcat('LFPvoltage_ch', num2str(p), filtertype, '.mat'));
            %calculate theta power within time frame
            x=filt_data(t0:t1);
            power = (norm(x)^2)/length(x);
            LFP128(ch,shank)=power;
            
            
            hx=hilbert(x);
            ax=angle(hx);
            [pks, px]=findpeaks(ax);
                if length(px)>maxpx
                PX{ch,shank}=px(1:maxpx);
                else
                PX{ch,shank}=px;
                end
            end
    end

      
end



save(strcat(animal, '_', filtertype, '_128power.mat'), 'LFP128', 'PX', '-v7.3');

disp(['done with power128 for ' animal ' ' filtertype]); 

%add phase deviation from pyramidal layer
%and plot with a line graph by depth (theta power increase is LM, phase deviates at pyr layer) 








end
