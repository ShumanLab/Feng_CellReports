% note that I'm using align-ind instead of align_ind_run since I am comraring speed

function speed_subsample_M2MO_SF(animals)
subsample_speed_ls = [];
nonsubsample_speed_ls = [];
subsample_speed_run_ls = [];
nonsubsample_speed_run_ls = [];


    for a = 1:length(animals)
        animal = animals{a};
        exp_dir=get_exp(animal);
        [ana_dir]=get_ana(animal);
        load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
        savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\speed\';
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
                speed_mat = run_matrix(:,2);
             
                %%%%%%%%%%%%%%%%%%%%% whole rec
               subsample_speed = speed_mat(find(M2MOalign_ind == 1));
               subsample_speed_ave = mean(subsample_speed);
               nonsubsample_speed = speed_mat(find(M2MOalign_ind == 0));
               nonsubsample_speed_ave = mean(nonsubsample_speed);
    
               subsample_speed_ls = [subsample_speed_ls, subsample_speed_ave];
               nonsubsample_speed_ls = [nonsubsample_speed_ls, nonsubsample_speed_ave];
                
               
               %%%%%%%%%%%%%%%%%%%%% running only
               % create a index list first for run but not subsampled
               nonsubsample_run = [];
               for i = 1: length(run_matrix)
                   if run_matrix(i,1) == 1 && M2MOalign_ind_run(i) == 0
                       nonsubsample_run(i) = 1;
                   end
                end

               %%%
               subsample_speed_run = speed_mat(find(M2MOalign_ind_run == 1));
               subsample_speed_run_ave = mean(subsample_speed_run);
  
               nonsubsample_speed_run = speed_mat(find(nonsubsample_run == 1));
               nonsubsample_speed_run_ave = mean(nonsubsample_speed_run);

               subsample_speed_run_ls = [subsample_speed_run_ls, subsample_speed_run_ave];
               nonsubsample_speed_run_ls = [nonsubsample_speed_run_ls, nonsubsample_speed_run_ave];

                clear M2MOalign_ind align_ind_3sec_consec subsample_speed subsample_speed_ave nonsubsample_speed nonsubsample_speed_ave subsample_speed_run nonsubsample_speed_run
            end
  
        end
        
    end
writematrix(subsample_speed_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\speed\M2MOsubsample_speed_ls.csv' );
writematrix(nonsubsample_speed_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\speed\M2MONONsubsample_speed_ls.csv' );
writematrix(subsample_speed_run_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\speed\M2MOsubsample_speed_run_ls.csv' );
writematrix(nonsubsample_speed_run_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\speed\M2MONONsubsample_speed_run_ls.csv' );

end
