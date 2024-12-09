

function subsample_timeratio_M2MO_SF(animals)
subsample_timeratio_ls = [];
subsample_timeratio_run_ls = [];


    for a = 1:length(animals)
        animal = animals{a};
        exp_dir = get_exp(animal);
        [ana_dir]=get_ana(animal);
        load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
        savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\ratio\';
        if exist(savepath)==0
             mkdir(savepath);
        end

        if group == '3wP' | group == '8wP' 
            load([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind',  'align_ind_run_3sec_consec', 'align_ind_3sec_consec'); 
            if exist('align_ind_3sec_consec') 
                M2MOalign_ind = align_ind_3sec_consec; %align_ind is whole track1 length
                
                M2MOalign_ind_run = M2MOalign_ind; %to find running during these subsampled bins
                for i = 1: length(run_matrix)
                   if run_matrix(i,1) == 0
                       M2MOalign_ind_run(i) = 0;
                   end
                end
                subsample_timeratio = length(find(M2MOalign_ind == 1))/length(run_matrix(:,1));
                subsample_timeratio_run = length(find(M2MOalign_ind_run == 1))/length(find(run_matrix(:,1) == 1));

                subsample_timeratio_ls = [subsample_timeratio_ls, subsample_timeratio ];
                subsample_timeratio_run_ls = [subsample_timeratio_run_ls, subsample_timeratio_run];
                clear M2MOalign_ind align_ind_3sec_consec M2MOalign_ind_run  subsample_timeratio subsample_timeratio_run
            end
  
        end
        
    end
writematrix(subsample_timeratio_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\ratio\M2MOsubsample_ratio_ls.csv' );
writematrix(subsample_timeratio_run_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\ratio\M2MOsubsample_ratio_RUN_ls.csv' );


end
