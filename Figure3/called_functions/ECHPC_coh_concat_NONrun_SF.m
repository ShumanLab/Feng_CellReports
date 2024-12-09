%%
%This script is for revision to get coh matrix during nonrun
%INPUT: animals, filters, track, singlevalueuniform_ECHIP_coherence,uniformfull_ECHIP_coherence
%OUTPUT: 
%1: 3D coh single value matrix for each group (x4)
%2: 3D coh full matrix for each group (x4)
%3: concat signle value matrix for each group (x4)
%4: concat full value matrix for each group (x4)

%susie 9/3/2021
%%

function ECHPC_coh_concat_NONrun_SF(animals,track,filters)
% animal = 'TS118-4';
% filtertype = "theta";
% track = '1';

%loop through filters here


for f=1:length(filters)
    filtertype=filters{f};
    
     idx3wc=1; %serves as counter  
     idx3wp=1; 
     idx8wc=1;
     idx8wp=1;

%loop through animals here 
    for i = 1:length(animals)
    animal = animals(i);
    [ana_dir]=get_ana(animal);
    exp_dir=get_exp(animal);
    expinfo = load([exp_dir 'exp.mat']);
    [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
    
    load([ana_dir '\probe_data\ECHIP512.mat']) %note probe layout is upside down of a probe. eg; 1st row in probelayout is actually ch #1 on probe which is the bottom tip of the probe physically
    load([exp_dir 'singlevalueuniform_ECHIP_coherence_shank' num2str(CA1DGshank) 'v' num2str(CA3shank) 'v' num2str(MECshank) 'v' num2str(LECshank) 'track' track '_NONrun.mat']);
    load([exp_dir 'uniformfull_ECHIP_coherence_shank' num2str(CA1DGshank) 'v' num2str(CA3shank) 'v' num2str(MECshank) 'v' num2str(LECshank) 'track' track '_NONrun.mat']);
             
     [ch]=getchannels(animal,CA1DGshank); %pick CA1DGshank to figure out group info since every animal has it
     group = ch.group; 
     expinfo.group=group; %save group info in exp_info this time
     

     
%      single_3wc = {};
%      single_3wp = {};
%      single_8wc = {};
%      single_8wp = {};
%      full_3wc = {};
%      full_3wp = {};
%      full_8wc = {};
%      full_8wp = {};
     
            if strcmp(filtertype, 'theta') == 1
                singlevalue_coh = coh_matrix_theta;
                full_coh = uniformfull_cohmatrix_theta;
            elseif strcmp(filtertype, 'gamma') == 1
                singlevalue_coh = coh_matrix_gamma;
                full_coh = uniformfull_cohmatrix_gamma;
            elseif strcmp(filtertype, 'beta') == 1
                singlevalue_coh = coh_matrix_beta;
                full_coh = uniformfull_cohmatrix_beta;
            elseif strcmp(filtertype, 'fast_gamma') == 1
                singlevalue_coh = coh_matrix_fgamma;
                full_coh = uniformfull_cohmatrix_fastgamma;
            elseif strcmp(filtertype, 'slow_gamma') == 1
                singlevalue_coh = coh_matrix_slgamma;
                full_coh = uniformfull_cohmatrix_slowgamma;
            else
                disp('choose another filter')
            end

    
        %Construct a 3D structure for
            if strcmp(ch.group, '3wc') == 1  %if the animal belongs to this group
                single_3wc(:,:,idx3wc) = singlevalue_coh; %add the animal's matrix to the 3D mat for this group
                full_3wc(:,:,idx3wc) = full_coh;
                idx3wc = idx3wc+1; %add one to the index
            elseif strcmp(ch.group, '3wp') == 1  %if the animal belongs to this group
                single_3wp(:,:,idx3wp) = singlevalue_coh; %add the animal's matrix to the 3D mat for this group
                full_3wp(:,:,idx3wp) = full_coh;
                idx3wp = idx3wp+1; %add one to the index
            elseif strcmp(ch.group, '8wc') == 1  %if the animal belongs to this group
                single_8wc(:,:,idx8wc) = singlevalue_coh; %add the animal's matrix to the 3D mat for this group
                full_8wc(:,:,idx8wc) = full_coh;
                idx8wc = idx8wc+1; %add one to the index
            elseif strcmp(ch.group, '8wp') == 1  %if the animal belongs to this group
                single_8wp(:,:,idx8wp) = singlevalue_coh; %add the animal's matrix to the 3D mat for this group
                full_8wp(:,:,idx8wp) = full_coh;
                idx8wp = idx8wp+1; %add one to the index
            end
    disp(['done with animal ' animal]);
    end %end the animal looping here%%%%%%%%

    
    %save the final 3D structure with all animals coh matrix in general folder, also the average across animal value
        cohdir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Coherence\';
        if exist(cohdir)==0
            mkdir(cohdir)
        end
       save([cohdir '\full_ECHIP_coherence_' filtertype '_track' track '_NONrun.mat'],'single_3wc' ,'single_3wp' ,'single_8wc' ,'single_8wp' ,'full_3wc', 'full_3wp', 'full_8wc', 'full_8wp');  
disp(['done with filter ' filtertype]);   

    
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    %Calculate and plot mean
%     mean3wc_single = nanmean(single_3wc,3,'omitnan');
%     mean3wp_single = nanmean(single_3wp,3,'omitnan');
%     mean8wc_single = nanmean(single_8wc,3,'omitnan');
%     mean8wp_single = nanmean(single_8wp,3,'omitnan');
%     
%     mean3wc_full = nanmean(full_3wc,3,'omitnan');
%     mean3wp_full = nanmean(full_3wp,3,'omitnan');
%     mean8wc_full = nanmean(full_8wc,3,'omitnan');
%     mean8wp_full = nanmean(full_8wp,3,'omitnan');
%  
        %Calculate and plot mean
    mean3wc_single = nanmean(single_3wc,3);
    mean3wp_single = nanmean(single_3wp,3);
    mean8wc_single = nanmean(single_8wc,3);
    mean8wp_single = nanmean(single_8wp,3);
    
    mean3wc_full = nanmean(full_3wc,3);
    mean3wp_full = nanmean(full_3wp,3);
    mean8wc_full = nanmean(full_8wc,3);
    mean8wp_full = nanmean(full_8wp,3);
    
    %heatmap plot
    %below is plotting the mean value for both single and full coh matrix
    
        fig_single = figure; %for saving purpose
        
        tcaxis=[0.3 1]; %this is for colormap scale
        
        figure;
        subplot(2,2,1);
        imagesc(mean3wc_single);
        caxis(tcaxis);
        title([filtertype ' 3 Weeks Control']);
        
        subplot(2,2,2);
        imagesc(mean3wp_single);
        caxis(tcaxis);
        title([filtertype ' 3 Weeks Pilo']);
        
        subplot(2,2,3);
        imagesc(mean8wc_single);
        caxis(tcaxis);
        title([filtertype ' 8 Weeks Control']);
        
        subplot(2,2,4);
        imagesc(mean8wp_single);
        caxis(tcaxis);
        title([filtertype ' 8 Weeks Pilo']);
        
        %cohdir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Coherence\';
        %savefig(fig_single, fullfile(cohdir, [filtertype 'track' track '_single.fig']));
        %print(fig_single, fullfile(cohdir, [filtertype 'track' track '_single.png']), '-r300', '-dpng');

        %To plot full matrix
        fig_full = figure;
        tcaxis=[0.3 1];
        subplot(2,2,1);
        imagesc(mean3wc_full);
        caxis(tcaxis);
        title([filtertype ' 3 Weeks Control (full)']);
        
        subplot(2,2,2);
        imagesc(mean3wp_full);
        caxis(tcaxis);
        title([filtertype ' 3 Weeks Pilo (full)']);
        
        subplot(2,2,3);
        imagesc(mean8wc_full);
        caxis(tcaxis);
        title([filtertype ' 8 Weeks Control (full)']);
        
        subplot(2,2,4);
        imagesc(mean8wp_full);
        caxis(tcaxis);
        title([filtertype ' 8 Weeks Pilo (full)']);
        
        %cohdir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\Coherence\';
        %savefig(fig_full, fullfile(cohdir, [filtertype 'track' track '_full.fig']));
        %print(fig_full, fullfile(cohdir, [filtertype 'track' track '_full.png']), '-r300', '-dpng');

end %end the filter looping here%%%%%%%%


