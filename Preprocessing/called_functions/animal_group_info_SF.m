%this function take animal ID and add group info into exp.m 
%by susie 10/18/2021

function animal_group_info_SF(animal)   %time in sec
    exp_dir=get_exp(animal);
    ana_dir=get_ana(animal);
    exp = load([exp_dir 'exp.mat']);
    cd L:\Susie\SummerEphysHPCEC
    load('animal_info'); %animal and group mapping
    loc = find(strcmp(animalinfo(:,1),animal)==1);
    groupinfo = animalinfo(loc,2);
    exp.group = groupinfo;
    save([exp_dir 'exp.mat'],'-struct', 'exp');

   