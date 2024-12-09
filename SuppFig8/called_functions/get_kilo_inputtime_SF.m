%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function take start and end time that when binary file is generate as input into kilosort
%EDIT THIS WHEN ADD NEW animal's binary files!
%INPUT: animal
%OUTPUT: kiloto kilot1 in exp.m
%by susie, 10/19/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function get_kilo_inputtime_SF(animal)
exp_dir=get_exp(animal);

%below is batch 1
if strcmp(animal, 'TS112-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 8640 %in sec
    exp.kilot1 = 11700
    save([exp_dir 'exp.mat'],'-struct', 'exp');

    
elseif strcmp(animal, 'TS114-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  %put as 0 if the full length was used for binary file 
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
elseif strcmp(animal, 'TS114-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 7680 %in sec
    exp.kilot1 = 22080 %put as 0 if the full length was used for binary file
    save([exp_dir 'exp.mat'],'-struct', 'exp');   
    
elseif strcmp(animal, 'TS111-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 1 %in sec
    exp.kilot1 = 10040 
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS111-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 2280 %in sec
    exp.kilot1 = 18720  
    save([exp_dir 'exp.mat'],'-struct', 'exp');     

elseif strcmp(animal, 'TS115-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp');  
    
elseif strcmp(animal, 'TS116-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
elseif strcmp(animal, 'TS116-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS116-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS117-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS118-4') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
elseif strcmp(animal, 'TS118-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS118-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS88-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0 %in sec
    exp.kilot1 = 0  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS90-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 1; %in sec
    exp.kilot1 = 5400;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'T89-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
    %below is betach 2
    
elseif strcmp(animal, 'TS110-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS114-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 7200; %in sec
    exp.kilot1 = 18360;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS113-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 2400; %in sec
    exp.kilot1 = 20640;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
elseif strcmp(animal, 'TS117-4') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
        
elseif strcmp(animal, 'TS118-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
        
elseif strcmp(animal, 'TS86-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 12000; %in sec
    exp.kilot1 = 15960;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
        
elseif strcmp(animal, 'TS89-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 5280; %in sec
    exp.kilot1 = 17160;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
        
elseif strcmp(animal, 'TS91-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 1; %in sec
    exp.kilot1 = 10800;  
    save([exp_dir 'exp.mat'],'-struct', 'exp');

  %Batch 3

elseif strcmp(animal, 'TS110-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS112-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 11520; %in sec
    exp.kilot1 = 18840;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS114-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 8160; %in sec
    exp.kilot1 = 20520;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS113-3') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS113-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 8160; %in sec
    exp.kilot1 = 17520;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS115-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 3360; %in sec
    exp.kilot1 = 7680;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS116-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 1; %in sec
    exp.kilot1 = 5520;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS117-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS86-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS89-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 6360; %in sec
    exp.kilot1 = 13800;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS91-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 0; %in sec
    exp.kilot1 = 0;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 

elseif strcmp(animal, 'TS90-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.kilot0 = 4320; %in sec
    exp.kilot1 = 16440;  
    save([exp_dir 'exp.mat'],'-struct', 'exp'); 
    
end
