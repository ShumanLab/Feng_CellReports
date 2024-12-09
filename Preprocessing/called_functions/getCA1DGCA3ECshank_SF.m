%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%current strategy for animals that are missing a shank for CA1DG, CA3, MEC, or LEC, just assign a random shank for them, 
%that you are sure of doesn't contain anything at the target layers in chlocation matrix
%Therefore we will have NaNs assigned to those shanks that don't exist
%Susie 4/27/21, this is not a nice way to do it but I don't want to modify other stuff to handle this situation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal)

    %below is process batch 1
    if strcmp(animal,'TS116-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=7;
    elseif strcmp(animal,'TS112-0')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=5;
            LECshank=8;
    elseif strcmp(animal,'TS114-0')==1
            CA1DGshank=4;
            CA3shank=1;
            MECshank=7;
            LECshank=1;  %%%chose a random one that has no EC layers, NOT REAL
    elseif strcmp(animal,'TS114-1')==1
            CA1DGshank=3;
            CA3shank=2;
            MECshank=6;
            LECshank=8;
    elseif strcmp(animal,'TS111-1')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=8;            
            
     elseif strcmp(animal,'TS111-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=8;  
     elseif strcmp(animal,'TS115-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=5;
            LECshank=6;             
     elseif strcmp(animal,'TS116-3')==1
            CA1DGshank=3;
            CA3shank=2;
            MECshank=5;
            LECshank=8;               
     elseif strcmp(animal,'TS116-0')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=8;              
     elseif strcmp(animal,'TS117-0')==1
            CA1DGshank=3;
            CA3shank=5;  %%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=6;
            LECshank=8;  
     elseif strcmp(animal,'TS118-4')==1
            CA1DGshank=3;
            CA3shank=5;  %%%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=6;
            LECshank=7;            
     elseif strcmp(animal,'TS118-0')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=5;
            LECshank=8;            
     elseif strcmp(animal,'TS118-3')==1
            CA1DGshank=2; %changed from 3 to 2 on 11/22/22
            CA3shank=5;  %%%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=5;
            LECshank=8;            
     elseif strcmp(animal,'TS88-3')==1
            CA1DGshank=3;
            CA3shank=5;  %%%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=6;
            LECshank=8;    
     elseif strcmp(animal,'TS90-0')==1
            CA1DGshank=4;
            CA3shank=5;  %%%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=5;
            LECshank=8;             
     elseif strcmp(animal,'TS89-1')==1
            CA1DGshank=4;
            CA3shank=2;
            MECshank=6;
            LECshank=7;   
        
     %below is process batch2
     elseif strcmp(animal,'TS110-0')==1
            CA1DGshank=4;
            CA3shank=1;
            MECshank=6;
            LECshank=8;   
     elseif strcmp(animal,'TS114-3')==1
            CA1DGshank=4;
            CA3shank=1;
            MECshank=6;
            LECshank=8;   
     elseif strcmp(animal,'TS113-1')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=8;   
     elseif strcmp(animal,'TS117-4')==1
            CA1DGshank=3;
            CA3shank=1;  %%%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=7;
            LECshank=8;   
     elseif strcmp(animal,'TS118-2')==1
            CA1DGshank=3;
            CA3shank=5;  %%%%%%chose a random one that has no CA3 layers NOT REAL
            MECshank=5;
            LECshank=8;   
     elseif strcmp(animal,'TS86-1')==1
            CA1DGshank=3;
            CA3shank=2;
            MECshank=7;
            LECshank=8;
     elseif strcmp(animal,'TS89-3')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=8;
     elseif strcmp(animal,'TS91-1')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;
            LECshank=7;

    %below is process batch3
     elseif strcmp(animal,'TS110-3')==1
            CA1DGshank=3;
            CA3shank=2;
            MECshank=7;
            LECshank=4;   %%%%%%chose a random one that has no EC layers, NOT REAL
            
     elseif strcmp(animal,'TS112-1')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=4;  %%%%%%chose a random one that has no EC layers, NOT REAL
            LECshank=6;  
            
     elseif strcmp(animal,'TS114-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=5;  
            LECshank=7;  

     elseif strcmp(animal,'TS113-3')==1
            CA1DGshank=4;
            CA3shank=2;
            MECshank=5;  
            LECshank=7;  

     elseif strcmp(animal,'TS113-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=5;  
            LECshank=7;  

     elseif strcmp(animal,'TS115-1')==1
            CA1DGshank=4;
            CA3shank=2;
            MECshank=5;  
            LECshank=7;  

     elseif strcmp(animal,'TS116-1')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=5;  
            LECshank=7;  

     elseif strcmp(animal,'TS117-1')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=7;  
            LECshank=8;  

     elseif strcmp(animal,'TS86-2')==1
            CA1DGshank=2;
            CA3shank=1;
            MECshank=5;  
            LECshank=7;  

     elseif strcmp(animal,'TS89-2')==1
            CA1DGshank=3;
            CA3shank=8; %%%%%%chose a random one that has no CA3 layers, NOT REAL
            MECshank=5;  
            LECshank=7;  
            
     elseif strcmp(animal,'TS91-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=6;  
            LECshank=8;  

     elseif strcmp(animal,'TS90-2')==1
            CA1DGshank=3;
            CA3shank=1;
            MECshank=8;  
            LECshank=4;  %%%%%%chose a random one that has no EC layers, NOT REAL
            
            
    else
        disp('no shanks assigned');
        %CA1DGshank=0;
    end


end