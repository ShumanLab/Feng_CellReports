function OUTPUT_subsample_DGCA1_idx_SF(animals)
    for a = 1:length(animals)
        animal = animals{a};
        exp_dir=get_exp(animal);
        [ana_dir]=get_ana(animal);
        load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
        savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\OUTPUT_subsample_ind\';
        if exist(savepath)==0
             mkdir(savepath);
        end

        if group == '3wP' | group == '8wP' 
            load([exp_dir '\DGCA1coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind',  'align_ind_run_3sec_consec', 'align_ind_3sec_consec'); 
            if exist('align_ind_3sec_consec') 
                DGCA1align_ind = align_ind_3sec_consec; %align_ind is whole track1 length
                
                DGCA1align_ind_run = DGCA1align_ind; %to find running during these subsampled bins
               for i = 1: length(run_matrix)
                   if run_matrix(i,1) == 0
                       DGCA1align_ind_run(i) = 0;
                   end
               end
           
                variable_name_all = ([animal '_DGCA1align_ind']);
                filename_all = fullfile(savepath, sprintf('%s.csv', variable_name_all));
                writematrix(DGCA1align_ind, filename_all);

                variable_name_run = ([animal '_DGCA1align_ind_run']);
                filename_run = fullfile(savepath, sprintf('%s.csv', variable_name_run));
                writematrix(DGCA1align_ind_run, filename_run);


                clear DGCA1align_ind align_ind_3sec_consec
            end
  
        end
        
    end

end
