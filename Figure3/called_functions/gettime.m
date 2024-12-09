function [t0 t1]=gettime(animal, state, rate)

if strcmp(animal,'7-18C')==1
    
    r0=round(375682.3*25);
    r1=round(391766.3*25);
    n0 = 15000000;
    n1 = n0+1375000;
    f0=1;
    f1=1341000*25;
   
else 
    f0=1;
    exp_dir=get_exp(animal);
        if exist([exp_dir, '\LFP\Full\LFPvoltage_ch5.mat'])>0
           cd(strcat(exp_dir, '\LFP\Full'));
           load('LFPvoltage_ch5.mat');
           f1=length(LFPvoltage);
        else
             cd(strcat(exp_dir, '\LFP\LFP1000'));
           load('LFPvoltage_ch5.mat');
           f1=length(LFPvoltage)*25;
        end
    r0=0;
    r1=0;
    n0=0;
    n1=0;
end

if strcmp(state, 'running')
    
    t0=r0;
    t1=r1;
    
elseif strcmp(state, 'non-running')
    
    t0=n0;
    t1=n1;
    
elseif strcmp(state, 'all')
    
    t0=f0;
    t1=f1;

elseif strcmp(state, 'first30')
    
    
    t0=1;
    t1=30*60*25000;
end

if strcmp(rate, '1000')
    
    t0=t0/25;
    t1=floor(t1/25);
   if t0<1
       t0=1;
   end
elseif strcmp(rate, '25000')
    
    
end
    






end