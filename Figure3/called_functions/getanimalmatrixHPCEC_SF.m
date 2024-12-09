
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Format of animal matrix: each animal has 4 matrix files: 
%animaCADGmatrix.mat (has a fixed number of channels for CA1, DG)
%animalCA3matrix.mat (has a fixed number of channels for CA3)
%animalMECmatrix.mat  (has a fixed number of channels for MEC)
%animalLECmatrix.mat
%
%In HPC matrix, it has a fixed number of channels for CA1, DG and CA3
%In MEC matrix, it has a fixed number of channels of MEC 
%In LEC matrix, it has a fixed number of channels of LEC 
%NOTE TS114-0 no LEC shank, TS117-0 no CA3shank, TS118-4 no CA3 shank, TS118-3 no CA3 shank, TS88-3 no CA3 shank, TS90-0 no CA3 shank

%Data saved in each animal's recording ananlysis folder
%channel number in this matrix is saved as 1-64 (not real ch number yet)
%Note output matrices are not necessarily starting from 1, if notm the template ch before 1 just will have NaN filled in
%SF - 4/26/2021  (referencing getanimalmatrixMGE.mat)

%*** optimized the mean row so that they don't overlap on numbers. also to have them cleanly starting at 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function [animalCA1DGmatrix, animalCA3matrix, animalMECmatrix, animalLECmatrix]=getanimalmatrixHPCEC_SF(animal, overwrite)

    [ana_dir]=get_ana(animal);
    exp_dir=get_exp(animal);
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
    
    
    %HPC Matrix Genrating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get mean locations for HPC
    %note: HPC should be ready but susie hasn't tested -4/7%%%%%%%
    manimal = 'Mean'; mshank = 'Mean';
    [ch]=getchannels(manimal,mshank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 
    % shankchs=probelayout(:,shank); %for later convert ch number to real ch number 
         MidPyr=ch.MidPyr; Pyr1=ch.Pyr1; Pyr2=ch.Pyr2; Or1=ch.Or1; Or2=ch.Or2; Rad1=ch.Rad1; Rad2=ch.Rad2;
    LM1=ch.LM1; LM2=ch.LM2; Mol1=ch.Mol1; Mol2=ch.Mol2; GC1=ch.GC1; GC2=ch.GC2; Hil1=ch.Hil1; Hil2=ch.Hil2; LB1=ch.LB1; LB2=ch.LB2;
    CA3sr1=ch.CA3sr1; CA3sr2=ch.CA3sr2; CA3sp1=ch.CA3sp1; CA3sp2=ch.CA3sp2; 
    
    %below is the combined layer for CA1 DG and CA3, susie comment out, not sure we need this
    %CA1up=ch.CA1up; CA1low=ch.CA1low; DGup=ch.DGup; DGlow=ch.DGlow;  CA3up=ch.CA3up; CA3low=ch.CA3low; 
    
    %construt the template for CA1/DG matrix holder
     mMidPyr=MidPyr; mOr=[Or2:Or1]; mPyr=[Pyr2:Pyr1];mRad=[Rad2:Rad1];mLM=[LM2:LM1];mMol=[Mol2:Mol1]; mGC=[GC2:GC1]; mHil=[Hil2:Hil1];  mLB=[LB2:LB1];
    %construt the template for CA3 matrix holder
     mCA3sr=[CA3sr2:CA3sr1]; mCA3sp=[CA3sp2:CA3sp1];
     
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now let's get the CA1/DG ch assignment for this animal of interest

    [ch]=getchannels(animal,CA1DGshank); %for CA1/DG
    MidPyr=ch.MidPyr; Pyr1=ch.Pyr1; Pyr2=ch.Pyr2; Or1=ch.Or1; Or2=ch.Or2; Rad1=ch.Rad1; Rad2=ch.Rad2;
    LM1=ch.LM1; LM2=ch.LM2; Mol1=ch.Mol1; Mol2=ch.Mol2; GC1=ch.GC1; GC2=ch.GC2; Hil1=ch.Hil1; Hil2=ch.Hil2; LB1=ch.LB1; LB2=ch.LB2;

 %Now we are building the CA1/DG animal matrix    
if exist([exp_dir '\animalCA1DGmatrix.mat'])>0 & overwrite == 0
    load([exp_dir '\animalCA1DGmatrix.mat'],'animalCA1DGmatrix');
else
            %create animalmatrix - indexes of normalized plots
          animalCA1DGmatrix=NaN(1,mOr(end));
            
             aLB=[LB2:LB1];
             if isempty(aLB) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mLB)
                %find best corresponding coherence chan
                nLB=length(aLB);
                nmLB=length(mLB);
                chp=round(chi/nmLB*nLB);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mLB(1))=chp+aLB(1)-1;
            end     
             end
                        
            aHil=[Hil2:Hil1];
            if isempty(aHil) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mHil)
                %find best corresponding coherence chan
                nHil=length(aHil);
                nmHil=length(mHil);
                chp=round(chi/nmHil*nHil);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mHil(1))=chp+aHil(1)-1;

            end
            end
            aGC=[GC2:GC1];
            if isempty(aGC) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mGC)
                %find best corresponding coherence chan
                nGC=length(aGC);
                nmGC=length(mGC);
                chp=round(chi/nmGC*nGC);  
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mGC(1))=chp+aGC(1)-1;
            end
            end
            aMol=[Mol2:Mol1];
            if isempty(aMol) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mMol)
                %find best corresponding coherence chan
                nMol=length(aMol);
                nmMol=length(mMol);
                chp=round(chi/nmMol*nMol);        
                animalCA1DGmatrix(chi-1+mMol(1))=chp+aMol(1)-1;
            end    
            end
            aRad=[Rad2:Rad1];
            if isempty(aRad) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mRad)
                %find best corresponding coherence chan
                nRad=length(aRad);
                nmRad=length(mRad);
                chp=round(chi/nmRad*nRad); 
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mRad(1))=chp+aRad(1)-1;
            end
            end
            aLM=[LM2:LM1];
            if isempty(aLM) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mLM)
                %find best corresponding coherence chan
                nLM=length(aLM);
                nmLM=length(mLM);
                chp=round(chi/nmLM*nLM); 
                if chp == 0
                    ch = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mLM(1))=chp+aLM(1)-1;
            end
            end
            aPyr=[Pyr2:Pyr1];
            if isempty(aPyr) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mPyr)
                %find best corresponding coherence chan
                nPyr=length(aPyr);
                nmPyr=length(mPyr);
                chp=round(chi/nmPyr*nPyr);   
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mPyr(1))=chp+aPyr(1)-1;
            end
            end
            aOr=[Or2:Or1];
            if isempty(aOr) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mOr)
                %find best corresponding coherence chan
                nOr=length(aOr);
                nmOr=length(mOr);
                chp=round(chi/nmOr*nOr); 
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA1DGmatrix(chi-1+mOr(1))=chp+aOr(1)-1;
            end
            end
            
    save([exp_dir '\animalCA1DGmatrix.mat'],'animalCA1DGmatrix');
     end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now let's get the CA3 ch assignment for this animal of interest  
    [ch]=getchannels(animal,CA3shank); %for CA3
    CA3sr1=ch.CA3sr1; CA3sr2=ch.CA3sr2; CA3sp1=ch.CA3sp1; CA3sp2=ch.CA3sp2;
 
 %Now we are building the CA3 animal matrix
     if exist([exp_dir '\animalCA3matrix.mat'])>0 & overwrite == 0
    load([exp_dir '\animalCA3matrix.mat'],'animalCA3matrix');
     else
            %create animalmatrix - indexes of normalized plots
            animalCA3matrix=NaN(1,mCA3sr(end));
            
              aCA3sp=[CA3sp2:CA3sp1];
              if isempty(aCA3sp) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mCA3sp)
                %find best corresponding coherence chan
                nCA3sp=length(aCA3sp); %real channel number
                nmCA3sp=length(mCA3sp); %template channel number
                chp=round(chi/nmCA3sp*nCA3sp);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalCA3matrix(chi-1+mCA3sp(1))=chp+aCA3sp(1)-1;
            end     
              end
            
            aCA3sr=[CA3sr2:CA3sr1];
            if isempty(aCA3sr) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mCA3sr)
                %find best corresponding coherence chan
                nCA3sr=length(aCA3sr);
                nmCA3sr=length(mCA3sr);
                chp=round(chi/nmCA3sr*nCA3sr);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
           
                animalCA3matrix(chi-1+mCA3sr(1))=chp+aCA3sr(1)-1;
            end 
            end
     save([exp_dir '\animalCA3matrix.mat'],'animalCA3matrix');
     end         
            
   
    %EC Matrix Genrating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get mean locations for MEC and LEC

    manimal = 'Mean'; mshank = 'Mean'; %which is the second row in chlocations
    [ch]=getchannels(manimal,mshank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 
     MEC31=ch.MEC31; MEC32=ch.MEC32; MEC21=ch.MEC21; MEC22=ch.MEC22; MEC11=ch.MEC11; MEC12=ch.MEC12;
    LEC31=ch.LEC31;LEC32=ch.LEC32; LEC21=ch.LEC21; LEC22=ch.LEC22; LEC11=ch.LEC11; LEC12=ch.LEC12;   
   
  
    %construt the template mean value for MEC/LEC matrix holder
    mMEC3=[MEC32:MEC31]; mMEC2=[MEC22:MEC21];mMEC1=[MEC12:MEC11];
    mLEC3=[LEC32:LEC31]; mLEC2=[LEC22:LEC21];mLEC1=[LEC12:LEC11];
     
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now let's get the MEC ch assignment for this animal of interest
    [ch]=getchannels(animal,MECshank); %for MEC
     MEC31=ch.MEC31; MEC32=ch.MEC32; MEC21=ch.MEC21; MEC22=ch.MEC22; MEC11=ch.MEC11; MEC12=ch.MEC12;
  
    
 %Now we are bulldng the MEC animal matrix
     if exist([exp_dir '\animalMECmatrix.mat'])>0 & overwrite == 0
    load([exp_dir '\animalMECmatrix.mat'],'animalMECmatrix');
     else
            %create animalmatrix - indexes of normalized plots
            animalMECmatrix=NaN(1,mMEC3(end));
            
             aMEC3=[MEC32:MEC31];
             if isempty(aMEC3) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mMEC3)
                %find best corresponding coherence chan
                nMEC3=length(aMEC3);
                nmMEC3=length(mMEC3);
                chp=round(chi/nmMEC3*nMEC3);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalMECmatrix(chi-1+mMEC3(1))=chp+aMEC3(1)-1;
            end
             end
               aMEC2=[MEC22:MEC21];
               if isempty(aMEC2) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mMEC2)
                %find best corresponding coherence chan
                nMEC2=length(aMEC2);
                nmMEC2=length(mMEC2);
                chp=round(chi/nmMEC2*nMEC2);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalMECmatrix(chi-1+mMEC2(1))=chp+aMEC2(1)-1;
            end 
               end
          
               aMEC1=[MEC12:MEC11];
               if isempty(aMEC1) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mMEC1)
                %find best corresponding coherence chan
                nMEC1=length(aMEC1);
                nmMEC1=length(mMEC1);
                chp=round(chi/nmMEC1*nMEC1);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalMECmatrix(chi-1+mMEC1(1))=chp+aMEC1(1)-1;
            end 
               end
            
    save([exp_dir '\animalMECmatrix.mat'],'animalMECmatrix');
    end
     
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now let's get the LEC ch assignment for this animal of interest
 
    [ch]=getchannels(animal,LECshank); %for LEC
    LEC31=ch.LEC31;LEC32=ch.LEC32; LEC21=ch.LEC21; LEC22=ch.LEC22; LEC11=ch.LEC11; LEC12=ch.LEC12;   
  
%Now we are bulldng the LEC animal matrix
     if exist([exp_dir '\animalLECmatrix.mat'])>0 & overwrite == 0
    load([exp_dir '\animalLECmatrix.mat'],'animalLECmatrix');
     else      
         
         animalLECmatrix=NaN(1,mLEC3(end));
         
               aLEC3=[LEC32:LEC31];
               if isempty(aLEC3) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mLEC3)
                %find best corresponding coherence chan
                nLEC3=length(aLEC3);
                nmLEC3=length(mLEC3);
                chp=round(chi/nmLEC3*nLEC3);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalLECmatrix(chi-1+mLEC3(1))=chp+aLEC3(1)-1;
            end
               end
             aLEC2=[LEC22:LEC21];
             if isempty(aLEC2) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mLEC2)
                %find best corresponding coherence chan
                nLEC2=length(mLEC2);
                nmLEC2=length(mLEC2);
                chp=round(chi/nmLEC2*nLEC2);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalLECmatrix(chi-1+mLEC2(1))=chp+aLEC2(1)-1;
            end 
             end
            
               aLEC1=[LEC12:LEC11];
               if isempty(aLEC1) %add this to handle if a certain layer is missing on a shank              
            else
            for chi=1:length(mLEC1)
                %find best corresponding coherence chan
                nLEC1=length(mLEC1);
                nmLEC1=length(mLEC1);
                chp=round(chi/nmLEC1*nLEC1);
                if chp == 0
                    chp = 1; %need to handle when chp == 0 sometimes
                end
                animalLECmatrix(chi-1+mLEC1(1))=chp+aLEC1(1)-1;
            end 
               end
   save([exp_dir '\animalLECmatrix.mat'],'animalLECmatrix');          

   end