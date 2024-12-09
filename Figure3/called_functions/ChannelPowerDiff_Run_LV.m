function [f, plotPower] = ChannelPowerDiff_Run_LV(animal, probetype, badChan, minTbin)
    
    %the code in this script fits the power data generated by
    %ChannelPowerSpectrumZ_Run_LV into animalmatrix format/size and plots
    %each animal's data
    
    load('UpDownCmap.mat', 'UpDownCmap')
    load('UpDownSigCmap.mat', 'UpDownSigCmap')
    
    %[start_time, end_time] = gettime(animal,'running', 25000);  %%need to fix this!! 
    %start_time=start_time/25000;
    %end_time=end_time/25000;

    
     
    startTime = 0;
    endTime = 3600;

    [powerMat, stdMat, f, f_dim] = ChannelPowerSpectrumZ_Run_LV(startTime, endTime, animal, probetype, minTbin, true);
    %true means use running time only
 
    %%%
%    badChan = [];
% 
%     for chi = badChan
% 
%         powerMat(chi,:) = mean([powerMat(chi-1,:); powerMat(chi+1,:)]); %replace bad channel with mean of channel above and below
%  
%         stdMat(chi,:) = mean([stdMat(chi-1,:); stdMat(chi+1,:)]); %replace bad channel with mean of channel above and below
%        
% 
%     end
    
    
    exp_dir=get_exp(animal); 
    if exist([exp_dir 'animalCA1DGmatrix.mat']) 
    load([exp_dir 'animalCA1DGmatrix.mat'])  %assuming this is calculated previously
    animalmatrix = animalCA1DGmatrix;
    else
    disp('animal matrix does not exist')
    end 
    
    [HIPshank, ECshank]=getshankECHIP(animal); 
    [ch]=getchannels_LV(animal,HIPshank);
    group = ch.group;

    %%%
    OldPowerMat = powerMat;
    NewPowerMat = [ ]; %makes an empty matrix
            %for gets numbers and fits them
            %into a new matrix based on the template
            
            %deals with nan values
                
           for column = 1:f_dim;          %number of columns in input and output matrix, 501
                for row = 1:length(animalmatrix);  %number of rows in output matrix, one per channel in animalmatrix
                    if isnan(animalmatrix(row));
                        NewPowerMat(row, column) = nan;
                    else
                        NewPowerMat(row, column) = OldPowerMat(animalmatrix(row), column); %make a new matrix that fits with animalmatrix
                    end
                end
           end
           
      
     NewStd = [ ];
     
             for column = 1:f_dim;          %number of columns in input and output matrix, 501
                for row = 1:length(animalmatrix);  %number of rows in output matrix, one per channel in animalmatrix
                    if isnan(animalmatrix(row));
                        NewStd(row, column) = nan;
                    else
                        NewStd(row, column) = stdMat(animalmatrix(row), column);
                    end
                end
             end
    
    NewPowerMat = NewPowerMat(4:end, :);   %need to fix this to be adaptable for different numbers of nan rows
    %right now I have 3 rows of Nans so I'm just getting rid of them by
    %cutting out the first 3 rows
    NewStd = NewStd(4:end, :);
             
    plotPower = NewPowerMat(:,2:101); %plot 1 to 100Hz (first frequency bin is 0hz dc component)
    plotPower(:,60)= mean([plotPower(:,59), plotPower(:,61)],2); %average to get rid of notch filter dip
    plotSTD = NewStd(:,2:101);

    

    %%%

   Smoothed = imgaussfilt(plotPower,2);

 
    %%%
    SmoothedDB = mag2db(Smoothed); %convert to decibels?
    
    %%%
%     peakDiff = (peakSmoothed - baseSmoothed);
%     %peakZ = (plotPowerPeak-plotPowerBase) ./ (plotSTDbase/sqrt(nPeak));
%     peakZ = (plotPowerPeak-plotPowerBase) ./ (plotSTDbase);    
%     peakZsmoothed = imgaussfilt(peakZ,2);
% 
%     pctpeakDiff = (peakDiff./baseSmoothed)*100;
%     peakDiffDB = peakSmoothedDB-baseSmoothedDB;
% 
% 
%     troughDiff = (troughSmoothed - baseSmoothed);
%     %troughZ = (plotPowerTrough-plotPowerBase) ./ (plotSTDbase/sqrt(nTrough));
%     troughZ = (plotPowerTrough-plotPowerBase) ./ (plotSTDbase);
%     troughZsmoothed = imgaussfilt(troughZ,2);
% 
%     pcttroughDiff = (troughDiff./baseSmoothed)*100;
%     troughDiffDB = troughSmoothedDB-baseSmoothedDB;



    %DBmin = min(SmoothedDB(:));
    

    %DBmax = max(SmoothedDB(:));
   

    %dbScale = [min([DBmin]), max([DBmax])];
    dbScale = [0, 70];

%     dbDiffScale = max( max(abs(peakDiffDB(:))) , max(abs(troughDiffDB(:))) );
% 
%     diffCscale = max( max(abs(peakDiff(:))) , max(abs(troughDiff(:))) );
% 
%     pctdiffCscale = max( max(pctpeakDiff(:)) , max(pcttroughDiff(:)) );



    %%

%plot each animal 
    figure('Name', [group, animal]);
    imagesc(SmoothedDB)
   
    
    f_labels = f(xticks+1);
    xticklabels(f_labels);

    axis xy
    yticks(5:5:size(plotPower,1))
    
    title('Power')

    xlabel('Frequency (Hz)')
    ylabel('Channel')
    caxis(dbScale)    
    c = colorbar;
    c.Label.String = 'PSD (DB/Hz)';
    box off

    %% more of Paul's plotting code 
    
    % figure('Name', 'Peak-Baseline');
    % imagesc((peakDiff))
    % f_labels = f(xticks+1);
    % xticklabels(f_labels)
    % 
    % ch_labels = flip(yticklabels);
    % yticks((4:5:64)+1)
    % yticklabels(60:-5:1);
    % title('Peak - Baseline')
    % 
    % xlabel('Frequency (Hz)')
    % ylabel('Channel')
    % colormap(UpDownCmap)
    % caxis([-diffCscale diffCscale])
    % colorbar
    % box off
    % %
    % 
    % 
    % 
    % 
    % %
    % figure('Name', 'Trough-Baseline');
    % imagesc((troughDiff))
    % f_labels = f(xticks+1);
    % xticklabels(f_labels)
    % 
    % ch_labels = flip(yticklabels);
    % yticks((4:5:64)+1)
    % yticklabels(60:-5:1);
    % title('Trough - Baseline')
    % 
    % xlabel('Frequency (Hz)')
    % ylabel('Channel')
    % colormap(UpDownCmap)
    % caxis([-diffCscale diffCscale])
    % colorbar
    % box off
    % 
    % 
    % 
    % 
    % %
    % figure('Name', 'Peak-BaselineDB');
    % imagesc((peakDiffDB))
    % f_labels = f(xticks+1);
    % xticklabels(f_labels)
    % 
    % ch_labels = flip(yticklabels);
    % yticks((4:5:64)+1)
    % yticklabels(60:-5:1);
    % title('Peak - Baseline db')
    % xlabel('Frequency (Hz)')
    % ylabel('Channel')
    % colormap(UpDownCmap)
    % caxis([-dbDiffScale dbDiffScale])
    % colorbar
    % box off
    % 
    % figure('Name', 'Trough-BaselineDB');
    % imagesc((troughDiffDB))
    % f_labels = f(xticks+1);
    % xticklabels(f_labels)
    % 
    % ch_labels = flip(yticklabels);
    % yticks((4:5:64)+1)
    % yticklabels(60:-5:1);
    % title('trough - Baseline db')
    % xlabel('Frequency (Hz)')
    % ylabel('Channel')
    % colormap(UpDownCmap)
    % caxis([-dbDiffScale dbDiffScale])
    % colorbar
    % box off
    %
    % 
% % %     figure('Name', 'PeakZ');
% % %     imagesc(peakZsmoothed)
% % %     f_labels = f(xticks+1);
% % %     xticklabels(f_labels)
% % % 
% % %     axis xy
% % %     yticks(5:5:size(plotPowerBase,1))
% % %     title('Peak (z-scored)')
% % %     xlabel('Frequency (Hz)')
% % %     ylabel('Channel')
% % %     colormap(UpDownSigCmap)
% % %     caxis([-4 4])
% % %     c = colorbar;
% % %     % c.Label.String = '?';
% % %     box off
% % % 
% % %     figure('Name', 'TroughZ');
% % %     imagesc(troughZsmoothed)
% % %     f_labels = f(xticks+1);
% % %     xticklabels(f_labels)
% % % 
% % %     axis xy
% % %     yticks(5:5:size(plotPowerBase,1))
% % %     title('Trough (z-scored)')
% % %     xlabel('Frequency (Hz)')
% % %     ylabel('Channel')
% % %     colormap(UpDownSigCmap)
% % %     caxis([-4 4])
% % %     c = colorbar;
% % %     % c.Label.String = '?';
% % %     box off



    % figure;
    % imagesc((pctpeakDiff))
    % f_labels = f(xticks+1);
    % xticklabels(f_labels)
    % 
    % ch_labels = flip(yticklabels);
    % yticks((4:5:64)+1)
    % yticklabels(60:-5:1);
    % title('Peak pct change')
    % 
    % colormap(UpDownCmap)
    % caxis([-pctdiffCscale pctdiffCscale])
    % colorbar
    % %
    % 
    % figure;
    % imagesc((pcttroughDiff))
    % f_labels = f(xticks+1);
    % xticklabels(f_labels)
    % 
    % ch_labels = flip(yticklabels);
    % yticks((4:5:64)+1)
    % yticklabels(60:-5:1);
    % title('Trough pct change')
    % 
    % colormap(UpDownCmap)
    % caxis([-pctdiffCscale pctdiffCscale])
    % colorbar
    % %
    %% uncomment this once everything else is working
%     exp_dir=get_exp(animal);
%     outDir=fullfile(exp_dir, 'Power Spectra');
% 
% 
% 
%     if exist(outDir, 'dir')~=7
%         mkdir(outDir)
%     end
%     save(fullfile(outDir,'powerMats.mat'),'plotPower','f', 'totalBins');
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
end
