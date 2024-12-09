

%%

%This is adapted from Paul's code

%Goal: For each animal, calculate a matrix of power to generate a heatmap
%across all frequencies and channels on a given shank (currently made for a
%64 channel hippocampus shank

%then make an average heatmap for each group

%sub-functions/things you need:
%ChannelPowerDiff_Run_LV.m
%ChannelPowerSpectrumZ_Run_LV.m
%in Paul's folder get 'UpDownCmap.mat' and 'UpDownSigCmap.mat'

%also need animalmatrix calculated for each animal

%things to add: %do i need to add some normalization?
%subtraction between groups? 


animals = {'3xTg1-1', '3xTg1-2','3xTg48-0', 'WT45-2', '3xTg49-2', '3xTg49-1', 'AD-WT-1-0', 'WT78-0', '3xTg75-1', 'WT77-0', '3xTg79-0', 'WT89-0', 'WT98-0', '3xTg77-1' 'AD-WT-44-1' 'WT45-1' }; 
%took out WT47-0 because wasn't enough running bins in first hour

idx6wt=1; %serves as counter to build a matrix for each group  %6 mo WT
idx63x=1; %6 mo AD 3xTg etc 
idx8wt=1;
idx83x=1;

P6wt = {}; %matrices for each animal will get added to their group here
P63x = {};
P8wt = {};
P83x = {};


probetype = 'ECHIP512';
minTbin= 3; %min length of running bins 3s


badChan = [];  %currently not using this


for animalIdx=1:length(animals)

    animal=animals{animalIdx}; 
    
    exp_dir = get_exp(animal);
    %need to load animal matrix 
    if exist([exp_dir 'animalCA1DGmatrix.mat']) 
    load([exp_dir 'animalCA1DGmatrix.mat'])  %assuming this is calculated previously
    animalmatrix = animalCA1DGmatrix;
    else
    disp('animal matrix does not exist') %warn me if I haven't generated animalmatrix yet
    end 
    
   
    %[f, plotPower(:,:,animalIdx)]=ChannelPowerDiff_Run_LV(animal, probetype, badChan, minTbin);
    %the line above is from Paul's code and might be faster
    
    [f, plotPower]=ChannelPowerDiff_Run_LV(animal, probetype, badChan, minTbin);
    
    [HIPshank, ECshank]=getshankECHIP(animal); 

     [ch]=getchannels_LV(animal,HIPshank); %get group from chlocations file
            if strcmp(ch.group, '6wt') == 1;  %if the animal belongs to this group
                P6wt{idx6wt} = plotPower; %add the animal's matrix to the cell for this group
                idx6wt = idx6wt+1; %add one to the index
            elseif strcmp(ch.group, '63x') == 1;  %if the animal belongs to this group
                P63x{idx63x} = plotPower; %add the animal's matrix to the cell for this group
                idx63x = idx63x+1; %add one to the index
            elseif strcmp(ch.group, '8wt') == 1;  %if the animal belongs to this group
                P8wt{idx8wt} =plotPower; %add the animal's matrix to the cell for this group
                idx8wt = idx8wt+1; %add one to the index
            elseif strcmp(ch.group, '83x') == 1;  %if the animal belongs to this group
                P83x{idx83x} = plotPower; %add the animal's matrix to the cell for this group
                idx83x = idx83x+1; %add one to the index
            end
       

   
            
    disp([num2str(animalIdx) ' animals done']);
end

% %%

P6wt3D = cat(3, P6wt{:}); %Put all the 6 month WT matrices into 3D

        
P63x3D = cat(3, P63x{:});  %repeat for other groups 

        
P8wt3D = cat(3, P8wt{:});

        
P83x3D = cat(3, P83x{:});


meanfull6wt = mean(P6wt3D, 3, 'omitnan'); %and then average them to make one new mean matrix
meanfull8wt = mean(P8wt3D, 3, 'omitnan');
meanfull63x = mean(P63x3D, 3, 'omitnan');
meanfull83x = mean(P83x3D, 3, 'omitnan');

% %%
   load('UpDownCmap.mat', 'UpDownCmap')
   load('UpDownSigCmap.mat', 'UpDownSigCmap')

    %smooth
    SmoothedDB6wt = (imgaussfilt(mag2db(meanfull6wt),2));
    SmoothedDB8wt = (imgaussfilt(mag2db(meanfull8wt),2));
    SmoothedDB63x = (imgaussfilt(mag2db(meanfull63x),2));
    SmoothedDB83x = (imgaussfilt(mag2db(meanfull83x),2));
  
    
%     DBmin6wt = min(SmoothedDB6wt(:));
%     DBmin8wt = min(SmoothedDB8wt(:));
%     DBmin63x = min(SmoothedDB63x(:));
%     DBmin83x = min(SmoothedDB83x(:));
      DBmin = min(SmoothedDB83x(:));  %need to figure out the best way to do this\
      %but right now just using the group that has lowest power as min and
      %highest power as max 
% 
%     DBmax6wt = max(SmoothedDB6wt(:));
%     DBmax8wt = max(SmoothedDB8wt(:));
%     DBmax63x = max(SmoothedDB63x(:));
%     DBmax83x = max(SmoothedDB83x(:)); 
      DBmax = max(SmoothedDB8wt(:));
      
%     dbScale6wt = [min([DBmin6wt]), max([DBmax6wt])];
%     dbScale8wt = [min([DBmin8wt]), max([DBmax8wt])];
%     dbScale63x = [min([DBmin63x]), max([DBmax63x])];
%     dbScale83x = [min([DBmin83x]), max([DBmax83x])];
      dbScale = [min([DBmin]), max([DBmax])]  %need to set values so we can give each group the same scale


%plot mean for each condition

%plot
%6 mo 3xTg
    figure('Name', [ '6 mo 3xTg']);
    imagesc((imgaussfilt(mag2db(meanfull63x),2)))
    f_labels = f(xticks+1);
    xticklabels(f_labels)
    axis xy
    yticks(5:5:size(meanfull63x,1))
    title(['6 mo 3xTg'])
    xlabel('Frequency (Hz)')
    ylabel('Channel')
    caxis(dbScale)    
    c = colorbar;
    c.Label.String = 'PSD (DB/Hz)';
    box off

%8 mo 3xTg
   
    figure('Name', [ '8 mo 3xTg']);
    imagesc((imgaussfilt(mag2db(meanfull83x),2)))
    f_labels = f(xticks+1);
    xticklabels(f_labels)
    axis xy
    yticks(5:5:size(meanfull83x,1))
    title(['8 mo 3xTg'])
    xlabel('Frequency (Hz)')
    ylabel('Channel')
    caxis(dbScale)    
    c = colorbar;
    c.Label.String = 'PSD (DB/Hz)';
    box off

%8 mo WT
    figure('Name', [ '8 mo WT']);
    imagesc((imgaussfilt(mag2db(meanfull8wt),2)))
    f_labels = f(xticks+1);
    xticklabels(f_labels)
    axis xy
    yticks(5:5:size(meanfull8wt,1))
    title(['8 mo WT'])
    xlabel('Frequency (Hz)')
    ylabel('Channel')
    caxis(dbScale)    
    c = colorbar;
    c.Label.String = 'PSD (DB/Hz)';
    box off
    
 %6 mo WT
    figure('Name', [ '6 mo WT']);
    imagesc((imgaussfilt(mag2db(meanfull6wt),2)))
    f_labels = f(xticks+1);
    xticklabels(f_labels)
    axis xy
    yticks(5:5:size(meanfull6wt,1))
    title(['6 mo WT'])
    xlabel('Frequency (Hz)')
    ylabel('Channel')
    caxis(dbScale)    
    c = colorbar;
    c.Label.String = 'PSD (DB/Hz)';
    box off
    
 %%    
% % % a bunch of Paul's plotting stuff that I'm not using 
% % % %plot mean change from basline
% % %    figure('Name', [group ' PeakZ']);
% % %     %imagesc((peakZsmoothed))
% % %     %imagesc(meanPeakZ)
% % %     imagesc((imgaussfilt(meanPeakZ,2)))
% % %     f_labels = f(xticks+1);
% % %     xticklabels(f_labels)
% % % 
% % %     axis xy
% % %     yticks(5:5:size(meanPeakZ,1))
% % %     
% % %     title([group ' Peak (z-scored)'])
% % %     xlabel('Frequency (Hz)')
% % %     ylabel('Channel')
% % %     colormap(UpDownSigCmap)
% % %     caxis([-4 4])
% % %     c = colorbar;
% % %     % c.Label.String = '?';
% % %     box off
% % % 
% % %     figure('Name', [group ' TroughZ']);
% % %     %imagesc((troughZsmoothed))
% % %     %imagesc((meanTroughZ))
% % %     imagesc((imgaussfilt(meanTroughZ,2)))
% % %     f_labels = f(xticks+1);
% % %     xticklabels(f_labels)
% % % 
% % %     axis xy
% % %     yticks(5:5:size(meanTroughZ,1))
% % % 
% % %     title([group ' Trough (z-scored)'])
% % %     xlabel('Frequency (Hz)')
% % %     ylabel('Channel')
% % %     colormap(UpDownSigCmap)
% % %     caxis([-4 4])
% % %     c = colorbar;
% % %     % c.Label.String = '?';
% % %     box off
% % % %%
% % %calulate significance matrix
% % % 
% % % pPeak=[];
% % % pTrough=[];
% % % for chanIdx = 1:size(peakZalign,1)
% % %     for freqIdx = 1:size(peakZalign,2)
% % %         peakDist = peakZalign(chanIdx,freqIdx,:);
% % %         troughDist = troughZalign(chanIdx,freqIdx,:);        
% % %         [~, pPeak(chanIdx,freqIdx)] = ttest(peakDist);
% % %         [~, pTrough(chanIdx,freqIdx)] = ttest(troughDist);
% % %     end
% % % end
% % % toc
% % % %%
% % %make significance plots
% % %    figure('Name', [group ' PeakSig']);
% % %     imagesc(pPeak)
% % %     f_labels = f(xticks+1);
% % %     xticklabels(f_labels)
% % % 
% % %     axis xy
% % %     yticks(5:5:size(meanPeakZ,1))
% % %     
% % %     title([group ' Peak Significance'])
% % %     xlabel('Frequency (Hz)')
% % %     ylabel('Channel')
% % %     colormap(flipud(jet))   
% % %     caxis([.001 .05])
% % %     c = colorbar;
% % %     set( c, 'YDir', 'reverse' );
% % % 
% % %     % c.Label.String = '?';
% % %     box off
% % % 
% % %     figure('Name', [group ' TroughSig']);
% % %     imagesc((pTrough))
% % %     f_labels = f(xticks+1);
% % %     xticklabels(f_labels)
% % % 
% % %     axis xy
% % %     yticks(5:5:size(meanPeakZ,1))
% % % 
% % %     title([group ' Trough Significance'])
% % %     xlabel('Frequency (Hz)')
% % %     ylabel('Channel')
% % %     colormap(flipud(jet))   
% % %     caxis([.001 .05])
% % %     c = colorbar;
% % %     set( c, 'YDir', 'reverse' );
% % %     % c.Label.String = '?';
% % %     box off
% %%

%% save!! 

    exp_dir=get_exp(animal);
    outDir=fileparts(fileparts(exp_dir) ); %save data for this group one level above folder for current animal %calling fileparts twice is necessary due to convention of including trailing '/' in exp_dir
    
  
%put this back when the rest is working!!!
%     if exist(outDir, 'dir')~=7
%         mkdir(outDir)
%     end
%     save(fullfile(outDir,[group ' powerMats.mat']), 'meanfull');
% 
%         FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
%         if ~isempty(FigList)
%             for iFig = 1:length(FigList)
%               FigHandle = FigList(iFig);
%               FigName   = get(FigHandle, 'Name');
%               saveas(FigHandle, fullfile(outDir, [FigName '.fig']));
%               saveas(FigHandle, fullfile(outDir, [FigName '.jpg']));
%               saveas(FigHandle, fullfile(outDir, [FigName '.svg']));
%             end
%         %savefig(FigList,outFig);
%         end
%        close all;
    
    %   toc
