%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate power by group and regions
%Input: animals, filters, state, and snimal_filter powerbychannel (NPower) 
%Output: region_filtertype_means_running power matrix
%calculate CA1DG, CA3, MEC, LEC seperately and saved in each folder under
%here: L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Means
%Note this file now doesn't handle epileptic spike, need to work on this later
%Susie 4/27/21
%taking care of bad ch in the beginnig to change values in NPower matrix
%-susie 7/10/21

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
function HPCEC_PowerCalculateAnimalMatrix_SF(animals, filters, state, overwrite)
%state= 'running' or 'non-running'
    [ana_dir]=get_ana(animals);
    load([ana_dir '\probe_data\ECHIP512.mat'])
    
    for f=1:length(filters)
        filtertype=filters{f};

 %%%%%prep sets of list for CA1DG      
        CA1DGanimal3wp=1; %served as counter
        CA1DGanimal3wc=1;
        CA1DGanimal8wp=1;
        CA1DGanimal8wc=1;
        
        CA1DGPower3wp = [];
        CA1DGMatPower3wp = [];
        CA1DGPower3wc = [];
        CA1DGMatPower3wc = [];
        CA1DGPower8wp = [];
        CA1DGMatPower8wp = [];
        CA1DGPower8wc = [];
        CA1DGMatPower8wc = [];
        
 %%%%%prep sets of list for CA3           
        CA3animal3wp=1;
        CA3animal3wc=1;
        CA3animal8wp=1;
        CA3animal8wc=1;
        
        CA3Power3wp = [];
        CA3MatPower3wp = [];
        CA3Power3wc = [];
        CA3MatPower3wc = [];
        CA3Power8wp = [];
        CA3MatPower8wp = [];
        CA3Power8wc = [];
        CA3MatPower8wc = [];

%%%%%prep sets of list for MEC           
        MECanimal3wp=1;
        MECanimal3wc=1;
        MECanimal8wp=1;
        MECanimal8wc=1;
        
        MECPower3wp = [];
        MECMatPower3wp = [];
        MECPower3wc = [];
        MECMatPower3wc = [];
        MECPower8wp = [];
        MECMatPower8wp = [];
        MECPower8wc = [];
        MECMatPower8wc = [];
        
%%%%%prep sets of list for LEC           
        LECanimal3wp=1;
        LECanimal3wc=1;
        LECanimal8wp=1;
        LECanimal8wc=1;
        
        LECPower3wp = [];
        LECMatPower3wp = [];
        LECPower3wc = [];
        LECMatPower3wc = [];
        LECPower8wp = [];
        LECMatPower8wp = [];
        LECPower8wc = [];
        LECMatPower8wc = [];
        
        
        for anim=1:length(animals)
            animal=animals{anim};
  %need to handle the missing shank situation
             [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
             [animalCA1DGmatrix, animalCA3matrix, animalMECmatrix, animalLECmatrix]=getanimalmatrixHPCEC_SF(animal, overwrite);
             exp_dir=get_exp(animal);
             expinfo = load([exp_dir 'exp.mat']);
             badchannels = expinfo.badchannels;
             load([exp_dir '\LFP\PowerByChannel\' state '\seizclean\'  animal '_' filtertype 'powerbychannel.mat']);

             
             % Note NPower indexing from 1-64, so Or at the bottom in NPower matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%CA1DG power calculation   
 %%
            %take care of bad ch for this entire sceipt by modify NPower matrix
            %loop into NPower matrix, when run into bad ch, replace it with the average of neighbor 2 entries
            for i = 1:length(badchannels)
                loc = find(probelayout == badchannels(i)); %loc will be in order from 1-512, going from top to bottom, left to right

                %deal with edge channels (ch1 and ch64), when run into edge chs, just take the ch after it or before it
                if ismember(badchannels(i), [54 75 139 246 310 331 395 502]) %bad ch on the top
                    NPower(loc) = NPower(loc+1); 
                elseif  ismember( badchannels(i), [47 82 146 239 303 338 402 495]) %bad ch on the bottom
                    NPower(loc) = NPower(loc-1);                   
                else
                    NPower(loc) = mean([NPower(loc-1) NPower(loc+1)], 'omitnan'); %bad ch in the middle, replace the bad ch power value with the average value of neighbor channels
                end
            end
                
            %%
             shank = CA1DGshank;
             animalmatrix = animalCA1DGmatrix;
             
             [ch]=getchannels(animal,shank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 

         group = ch.group; 
         MidPyr=ch.MidPyr; Pyr1=ch.Pyr1; Pyr2=ch.Pyr2; Or1=ch.Or1; Or2=ch.Or2; Rad1=ch.Rad1; Rad2=ch.Rad2;
         LM1=ch.LM1; LM2=ch.LM2; Mol1=ch.Mol1; Mol2=ch.Mol2; GC1=ch.GC1; GC2=ch.GC2; Hil1=ch.Hil1; Hil2=ch.Hil2; LB1=ch.LB1; LB2=ch.LB2;
    %CA3sr1=ch.CA3sr1; CA3sr2=ch.CA3sr2; CA3sp1=ch.CA3sp1; CA3sp2=ch.CA3sp2; 
            
            
            MatPower=[];
            for a=1:length(animalmatrix) %need to handle the Nan here, just get make them nan so dimention stay the same
                
                if isnan(animalmatrix(a))
                    MatPower(a,1)=NaN;
                else
                    MatPower(a,1)=NPower(animalmatrix(a),shank);
                end
            end
            

            %%
            %below is raw mean power before putting into animal matrix format
           
           
            OrPower= nanmean(NPower(Or2:Or1,shank));
            PyrPower= nanmean(NPower(Pyr2:Pyr1,shank));
            RadPower= nanmean(NPower(Rad2:Rad1,shank));
            LMPower= nanmean(NPower(LM2:LM1,shank));
            MolPower= nanmean(NPower(Mol2:Mol1,shank));
            GCPower= nanmean(NPower(GC2:GC1,shank));
            HilPower= nanmean(NPower(Hil2:Hil1,shank));
            LBPower= nanmean(NPower(LB2:LB1,shank));

            if strcmp(group, '3wp')==1  
                CA1DGPower3wp(CA1DGanimal3wp,:)=[LBPower HilPower GCPower MolPower LMPower RadPower PyrPower OrPower];
                CA1DGMatPower3wp(CA1DGanimal3wp,:)=MatPower;   
                CA1DGanimal3wp=CA1DGanimal3wp+1;
                
            elseif strcmp(group, '3wc')==1  
                CA1DGPower3wc(CA1DGanimal3wc,:)=[LBPower HilPower GCPower MolPower LMPower RadPower PyrPower OrPower];
                CA1DGMatPower3wc(CA1DGanimal3wc,:)=MatPower;   
                CA1DGanimal3wc=CA1DGanimal3wc+1;
                
            elseif strcmp(group, '8wp')==1  
                CA1DGPower8wp(CA1DGanimal8wp,:)=[LBPower HilPower GCPower MolPower LMPower RadPower PyrPower OrPower];
                CA1DGMatPower8wp(CA1DGanimal8wp,:)=MatPower;   
                CA1DGanimal8wp=CA1DGanimal8wp+1;
                
            elseif strcmp(group, '8wc')==1
                CA1DGPower8wc(CA1DGanimal8wc,:)=[LBPower HilPower GCPower MolPower LMPower RadPower PyrPower OrPower];
                CA1DGMatPower8wc(CA1DGanimal8wc,:)=MatPower;   
                CA1DGanimal8wc=CA1DGanimal8wc+1; 
            end
       meandir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Means\CA1DG\';
        if exist(meandir)==0
            mkdir(meandir)
        end

%Data saving
        if strcmp(state,'running')==1
            save([meandir 'HPCEC_CA1DG_' filtertype '_means_running.mat'],'CA1DGPower3wp', 'CA1DGPower3wc', 'CA1DGPower8wp', 'CA1DGPower8wc', 'CA1DGMatPower3wp', 'CA1DGMatPower3wc', 'CA1DGMatPower8wp', 'CA1DGMatPower8wc');
        
        elseif strcmp(state,'non-running')==1
            save([meandir 'HPCEC_CA1DG_' filtertype '_means_NONrunning.mat'],'CA1DGPower3wp', 'CA1DGPower3wc', 'CA1DGPower8wp', 'CA1DGPower8wc', 'CA1DGMatPower3wp', 'CA1DGMatPower3wc', 'CA1DGMatPower8wp', 'CA1DGMatPower8wc');
        else
            save([meandir 'HPCEC_CA1DG_' filtertype '_means_' state '.mat'],'CA1DGPower3wp', 'CA1DGPower3wc', 'CA1DGPower8wp', 'CA1DGPower8wc', 'CA1DGMatPower3wp', 'CA1DGMatPower3wc', 'CA1DGMatPower8wp', 'CA1DGMatPower8wc');
  
        end
       % end
    

%add clear power matrix step here for the following step to start clean
clear shank animalmatrix group MatPower
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%CA3 power calculation   

             shank = CA3shank;
             animalmatrix = animalCA3matrix;
  
             [ch]=getchannels(animal,shank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 

         group = ch.group; 
         CA3sr1=ch.CA3sr1; CA3sr2=ch.CA3sr2; CA3sp1=ch.CA3sp1; CA3sp2=ch.CA3sp2; 

               MatPower=[];
            for a=1:length(animalmatrix) %need to handle the Nan here, just get make them nan so dimention stay the same
                if isnan(animalmatrix(a))
                    MatPower(a,1)=NaN;
                else
                MatPower(a,1)=NPower(animalmatrix(a),shank);
                 end
            end
                    
            CA3srPower= mean(NPower(CA3sr2:CA3sr1,shank), 'omitnan');
            CA3spPower= mean(NPower(CA3sp2:CA3sp1,shank), 'omitnan');

            if strcmp(group, '3wp')==1  
                CA3Power3wp(CA3animal3wp,:)=[CA3spPower CA3srPower];
                CA3MatPower3wp(CA3animal3wp,:)=MatPower;   
                CA3animal3wp=CA3animal3wp+1;
                
            elseif strcmp(group, '3wc')==1  
                CA3Power3wc(CA3animal3wc,:)=[CA3spPower CA3srPower];
                CA3MatPower3wc(CA3animal3wc,:)=MatPower;   
                CA3animal3wc=CA3animal3wc+1;
                
            elseif strcmp(group, '8wp')==1  
                CA3Power8wp(CA3animal8wp,:)=[CA3spPower CA3srPower];
                CA3MatPower8wp(CA3animal8wp,:)=MatPower;   
                CA3animal8wp=CA3animal8wp+1;
                
            elseif strcmp(group, '8wc')==1
                CA3Power8wc(CA3animal8wc,:)=[CA3spPower CA3srPower];
                CA3MatPower8wc(CA3animal8wc,:)=MatPower;   
                CA3animal8wc=CA3animal8wc+1;

            end
        

        meandir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Means\CA3\';
        if exist(meandir)==0
            mkdir(meandir)
        end
  
%Data saving
        if strcmp(state,'running')==1
            save([meandir 'HPCEC_CA3_' filtertype '_means_running.mat'],'CA3Power3wp', 'CA3Power3wc', 'CA3Power8wp', 'CA3Power8wc', 'CA3MatPower3wp', 'CA3MatPower3wc', 'CA3MatPower8wp', 'CA3MatPower8wc');
        elseif strcmp(state,'non-running')==1
            save([meandir 'HPCEC_CA3_' filtertype '_means_NONrunning.mat'],'CA3Power3wp', 'CA3Power3wc', 'CA3Power8wp', 'CA3Power8wc', 'CA3MatPower3wp', 'CA3MatPower3wc', 'CA3MatPower8wp', 'CA3MatPower8wc');
        else
            save([meandir 'HPCEC_CA3_' filtertype '_means_' state '.mat'],'CA3Power3wp', 'CA3Power3wc', 'CA3Power8wp', 'CA3Power8wc', 'CA3MatPower3wp', 'CA3MatPower3wc', 'CA3MatPower8wp', 'CA3MatPower8wc');
  
        end
        
    
 
%add clear power matrix step here for the following step to start clean
clear shank animalmatrix group MatPower        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%MEC power calculation   

             shank = MECshank;
             animalmatrix = animalMECmatrix;
  
             [ch]=getchannels(animal,shank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 

            group = ch.group; 
            MEC31=ch.MEC31; MEC32=ch.MEC32; MEC21=ch.MEC21; MEC22=ch.MEC22; MEC11=ch.MEC11; MEC12=ch.MEC12;
           
            MatPower=[];
            for a=1:length(animalmatrix) %need to handle the Nan here, just get make them nan so dimention stay the same
                if isnan(animalmatrix(a))
                    MatPower(a,1)=NaN;
                else
                     MatPower(a,1)=NPower(animalmatrix(a),shank);
                end
            end
                    
            MEC3Power= mean(NPower(MEC32:MEC31,shank),'omitnan');
            MEC2Power= mean(NPower(MEC22:MEC21,shank), 'omitnan');
            MEC1Power= mean(NPower(MEC12:MEC11,shank), 'omitnan');

            if strcmp(group, '3wp')==1  
                MECPower3wp(MECanimal3wp,:)=[MEC1Power MEC2Power MEC3Power];
                MECMatPower3wp(MECanimal3wp,:)=MatPower;   
                MECanimal3wp=MECanimal3wp+1;
                
            elseif strcmp(group, '3wc')==1  
                MECPower3wc(MECanimal3wc,:)=[MEC1Power MEC2Power MEC3Power];
                MECMatPower3wc(MECanimal3wc,:)=MatPower;   
                MECanimal3wc=MECanimal3wc+1;
                
            elseif strcmp(group, '8wp')==1  
                MECPower8wp(MECanimal8wp,:)=[MEC1Power MEC2Power MEC3Power];
                MECMatPower8wp(MECanimal8wp,:)=MatPower;   
                MECanimal8wp=MECanimal8wp+1;
                
            elseif strcmp(group, '8wc')==1
                MECPower8wc(MECanimal8wc,:)=[MEC1Power MEC2Power MEC3Power];
                MECMatPower8wc(MECanimal8wc,:)=MatPower;   
                MECanimal8wc=MECanimal8wc+1;

            end
        

        meandir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Means\MEC\';
        if exist(meandir)==0
            mkdir(meandir)
        end
  
%Data saving
        if strcmp(state,'running')==1
        save([meandir 'HPCEC_MEC_' filtertype '_means_running.mat'],'MECPower3wp', 'MECPower3wc', 'MECPower8wp', 'MECPower8wc', 'MECMatPower3wp', 'MECMatPower3wc', 'MECMatPower8wp', 'MECMatPower8wc');
        elseif strcmp(state,'non-running')==1
        save([meandir 'HPCEC_MEC_' filtertype '_means_NONrunning.mat'],'MECPower3wp', 'MECPower3wc', 'MECPower8wp', 'MECPower8wc', 'MECMatPower3wp', 'MECMatPower3wc', 'MECMatPower8wp', 'MECMatPower8wc');
        else
        save([meandir 'HPCEC_MEC_' filtertype '_means_' state '.mat'],'MECPower3wp', 'MECPower3wc', 'MECPower8wp', 'MECPower8wc', 'MECMatPower3wp', 'MECMatPower3wc', 'MECMatPower8wp', 'MECMatPower8wc');
  
        end
      
       
 %add clear power matrix step here for the following step to start clean
clear shank animalmatrix group MatPower  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%LEC power calculation   

             shank = LECshank;
             animalmatrix = animalLECmatrix;
  
             [ch]=getchannels(animal,shank); %gets relative channels from manually determined channel sets in chlocationsECHIP.mat file 

            group = ch.group; 
            LEC31=ch.LEC31;LEC32=ch.LEC32; LEC21=ch.LEC21; LEC22=ch.LEC22; LEC11=ch.LEC11; LEC12=ch.LEC12;   
           
                 MatPower=[];
            for a=1:length(animalmatrix) %need to handle the Nan here, just get make them nan so dimention stay the same
                if isnan(animalmatrix(a))
                    MatPower(a,1)=NaN;
                else
                MatPower(a,1)=NPower(animalmatrix(a),shank);
                 end
            end
                    
            LEC3Power= mean(NPower(LEC32:LEC31,shank), 'omitnan');
            LEC2Power= mean(NPower(LEC22:LEC21,shank), 'omitnan');
            LEC1Power= mean(NPower(LEC12:LEC11,shank), 'omitnan');
            if strcmp(group, '3wp')==1  
                LECPower3wp(LECanimal3wp,:)=[LEC1Power LEC2Power LEC3Power];
                LECMatPower3wp(LECanimal3wp,:)=MatPower;   
                LECanimal3wp=LECanimal3wp+1;
                
            elseif strcmp(group, '3wc')==1  
                LECPower3wc(LECanimal3wc,:)=[LEC1Power LEC2Power LEC3Power];
                LECMatPower3wc(LECanimal3wc,:)=MatPower;   
                LECanimal3wc=LECanimal3wc+1;
                
            elseif strcmp(group, '8wp')==1  
                LECPower8wp(LECanimal8wp,:)=[LEC1Power LEC2Power LEC3Power];
                LECMatPower8wp(LECanimal8wp,:)=MatPower;   
                LECanimal8wp=LECanimal8wp+1;
                
            elseif strcmp(group, '8wc')==1
                LECPower8wc(LECanimal8wc,:)=[LEC1Power LEC2Power LEC3Power];
                LECMatPower8wc(LECanimal8wc,:)=MatPower;   
                LECanimal8wc=LECanimal8wc+1;

            end
        

        meandir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Means\LEC\';
        if exist(meandir)==0
            mkdir(meandir)
        end
  
%Data saving
        if strcmp(state,'running')==1
        save([meandir 'HPCEC_LEC_' filtertype '_means_running.mat'],'LECPower3wp', 'LECPower3wc', 'LECPower8wp', 'LECPower8wc', 'LECMatPower3wp', 'LECMatPower3wc', 'LECMatPower8wp', 'LECMatPower8wc');
        elseif strcmp(state,'non-running')==1
        save([meandir 'HPCEC_LEC_' filtertype '_means_NONrunning.mat'],'LECPower3wp', 'LECPower3wc', 'LECPower8wp', 'LECPower8wc', 'LECMatPower3wp', 'LECMatPower3wc', 'LECMatPower8wp', 'LECMatPower8wc');
        else
        save([meandir 'HPCEC_LEC_' filtertype '_means_' state '.mat'],'LECPower3wp', 'LECPower3wc', 'LECPower8wp', 'LECPower8wc', 'LECMatPower3wp', 'LECMatPower3wc', 'LECMatPower8wp', 'LECMatPower8wc');
  
        end
    end
    end
end
                  
 
