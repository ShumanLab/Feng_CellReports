function OUTPUT_subsample_M2M3_idx_SF(animals)
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
            load([exp_dir '\M2M3coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind',  'align_ind_run_3sec_consec', 'align_ind_3sec_consec'); 
            if exist('align_ind_3sec_consec') 
                M2M3align_ind = align_ind_3sec_consec; %align_ind is whole track1 length, with 1 as runing + aligned
                
                
                M2M3align_ind_run = M2M3align_ind; %to find running during these subsampled bins
               for i = 1: length(run_matrix)
                   if run_matrix(i,1) == 0
                       M2M3align_ind_run(i) = 0;
                   end
               end
           
                variable_name_all = ([animal '_M2M3align_ind']);
                filename_all = fullfile(savepath, sprintf('%s.csv', variable_name_all));
                writematrix(M2M3align_ind, filename_all);

                variable_name_run = ([animal '_M2M3align_ind_run']);
                filename_run = fullfile(savepath, sprintf('%s.csv', variable_name_run));
                writematrix(M2M3align_ind_run, filename_run);



                clear M2M3align_ind align_ind_3sec_consec
            end
  
        end
        
    end

end
