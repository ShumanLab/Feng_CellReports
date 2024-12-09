%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is modified for Susie's chlocation format
%Susie channel locations sheet: L:\Susie\SummerEphysHPCEC
function [ch]=getchannels(animal,shank)
ana_dir=get_ana(animal);
load('L:\Susie\SummerEphysHPCEC\chlocationsECHIP_SF.mat')

ch=struct;

%just to handle when making template for HPC and EC
if shank == 'Mean'
    animalind = 2;

else
    a = find(strcmp(chlocations(:,1),animal)==1);
    b = find([0; cell2mat(chlocations(4:end,3))]==shank);
    %b = find([0; cell2mat(chlocations(3:end,3))]==shank);
    b=b+2;
    animalind = intersect(a,b);
    clear a b;
end

%to find which row to take from this chlocation sheet

ch.group=chlocations{animalind,2};
ch.shank=chlocations{animalind,3};
ch.region=chlocations{animalind,4};
ch.MedLat=chlocations{animalind,5};
ch.MidPyr=chlocations{animalind,6};
ch.Or1=chlocations{animalind,7};
ch.Or2=chlocations{animalind,8};
ch.Pyr1=chlocations{animalind,9};
ch.Pyr2=chlocations{animalind,10};
ch.Rad1=chlocations{animalind,11};
ch.Rad2=chlocations{animalind,12};
ch.LM1=chlocations{animalind,13};
ch.LM2=chlocations{animalind,14};
ch.Mol1=chlocations{animalind,15};
ch.Mol2=chlocations{animalind,16};
ch.GC1=chlocations{animalind,17};
ch.GC2=chlocations{animalind,18};
ch.Hil1=chlocations{animalind,19};
ch.Hil2=chlocations{animalind,20};
ch.LB1=chlocations{animalind,21};
ch.LB2=chlocations{animalind,22};

ch.CA3sr1=chlocations{animalind,23};
ch.CA3sr2=chlocations{animalind,24};
ch.CA3sp1=chlocations{animalind,25};
ch.CA3sp2=chlocations{animalind,26};
ch.CA3so1=chlocations{animalind,27};
ch.CA3so2=chlocations{animalind,28};

ch.MEC31=chlocations{animalind,29};
ch.MEC32=chlocations{animalind,30};

ch.MEC21=chlocations{animalind,31};
ch.MEC22=chlocations{animalind,32};

ch.MEC11=chlocations{animalind,33};
ch.MEC12=chlocations{animalind,34};

ch.LEC31=chlocations{animalind,35};
ch.LEC32=chlocations{animalind,36};

ch.LEC21=chlocations{animalind,37};
ch.LEC22=chlocations{animalind,38};

ch.LEC11=chlocations{animalind,39};
ch.LEC12=chlocations{animalind,40};

%below is channel assignment if we combine MEC and LEC
ch.EC31=chlocations{animalind,41};
ch.EC32=chlocations{animalind,42};
ch.EC21=chlocations{animalind,43};
ch.EC22=chlocations{animalind,44};
ch.EC11=chlocations{animalind,45};
ch.EC12=chlocations{animalind,46};

%below is channel assignment for CA1(or-LSM) DG(MO-LB) and CA3(CA3so-CA3sr) 
ch.CA1up=chlocations{animalind,47};
ch.CA1low=chlocations{animalind,48};
ch.DGup=chlocations{animalind,49};
ch.DGlow=chlocations{animalind,50};
ch.CA3up=chlocations{animalind,51};
ch.CA3low=chlocations{animalind,52};


    %i don't know how below is helpful? susie, so I haven't update it to my
    %format
%     ch.MidPyr(ch.MidPyr==0)=[];
%     ch.Or1(ch.Or1==0)=[];
%     ch.Or2(ch.Or2==0)=[];
%     ch.Pyr1(ch.Pyr1==0)=[];
%     ch.Pyr2(ch.Pyr2==0)=[];
%     ch.Rad1(ch.Rad1==0)=[];
%     ch.Rad2(ch.Rad2==0)=[];
%     ch.LM1(ch.LM1==0)=[];
%     ch.LM2(ch.LM2==0)=[];
%     ch.Mol1(ch.Mol1==0)=[];
%     ch.Mol2(ch.Mol2==0)=[];
%     ch.GC1(ch.GC1==0)=[];
%     ch.GC2(ch.GC2==0)=[];
%     ch.Hil1(ch.Hil1==0)=[];
%     ch.Hil2(ch.Hil2==0)=[];
% 
% 
% ch.CA31(ch.CA31==0)=[];
% ch.CA32(ch.CA32==0)=[];
% 
% ch.EC31(ch.EC31==0)=[];
% ch.EC32(ch.EC32==0)=[];
% ch.EC21(ch.EC21==0)=[];
% ch.EC22(ch.EC22==0)=[];
% ch.EC11(ch.EC11==0)=[];
% ch.EC12(ch.EC12==0)=[];



end