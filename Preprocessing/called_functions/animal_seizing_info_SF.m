%this function take animal ID and add seizing info into exp.m 
%by susie 2/22/2022

function animal_seizing_info_SF(animal)   %time in sec
    exp_dir=get_exp(animal);
    
    if strcmp(animal, 'TS112-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [4380]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS114-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [2760 10120 19120]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS89-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [3420]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS113-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [3710]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS112-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [790 1570 8730]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS113-1') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [4020 6780 12470 19520]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS116-0') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [1970 8120]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    elseif strcmp(animal, 'TS111-2') == 1
    exp = load([exp_dir 'exp.mat']);
    exp.seiz_time = [2170]; %in sec
    save([exp_dir 'exp.mat'],'-struct', 'exp');
    
    else
        exp = load([exp_dir 'exp.mat']);
        exp.seiz_time = 'na'; 
        save([exp_dir 'exp.mat'],'-struct', 'exp');
        
    end
end
