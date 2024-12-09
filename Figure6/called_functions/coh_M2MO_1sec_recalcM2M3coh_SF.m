function coh_M2MO_1sec_recalcM2M3coh_SF(animals)

    count3wp= 1;
    count3wc= 1;
    count8wp= 1;
    count8wc= 1;

    for a = 1:length(animals)
        animal = animals{a};
        exp_dir=get_exp(animal);
        [ana_dir]=get_ana(animal);
        load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
        load([ana_dir '\probe_data\ECHIP512.mat'])
    
        if group == '3wP' | group == '8wP' 
%             load([exp_dir '\M2MOcoh_1sec.mat'], 'align_ind_run', 'align_ind'); %use the ind to find timebin in M2MO
%             M2MO_aligned_ind = align_ind;
%             M2MO_aligned_ind_run = align_ind_run;

            load([exp_dir '\M2MOcoh_1sec.mat'], 'align_ind_run_3sec_consec', 'align_ind_3sec_consec'); %use the ind to find timebin in M2MO
            M2MO_aligned_ind = align_ind_3sec_consec;
            M2MO_aligned_ind_run = align_ind_run_3sec_consec;
            clear align_ind_run align_ind align_ind_3sec_consec align_ind_run_3sec_consec

            load([exp_dir '\M2M3coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix') %, 'align_ind_run', 'align_ind'); 
            %M2M3coh_whenalignM2MO = coh_matrix_run(find(M2MO_aligned_ind_run == 1));
           
           % make a new mat that hold trus for both aligned ind and run matrix
           M2MO_aligned_indandrun = M2MO_aligned_ind;
           for i = 1: length(run_matrix)
               if run_matrix(i,1) == 0
                   M2MO_aligned_indandrun(i) = 0;
               end
           end
            M2M3coh_whenalignM2MO = coh_matrix(find(M2MO_aligned_indandrun == 1));

        elseif group == '3wC' | group == '8wC' 
            load([exp_dir '\M2M3coh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'track','run_matrix');  
            M2M3coh_whenalignM2MO = coh_matrix_run;
        end

         coh_ave = nanmean(M2M3coh_whenalignM2MO);
         if group == '3wP'
             coh_ave_3wp(count3wp) = coh_ave;
             coh_ave_3wp_ani{count3wp} = animal;
             count3wp = count3wp + 1;
         elseif group == '8wP'
             coh_ave_8wp(count8wp) = coh_ave;
             coh_ave_8wp_ani{count8wp} = animal;
             count8wp = count8wp + 1;
         elseif group == '3wC'
             coh_ave_3wc(count3wc) = coh_ave;
             coh_ave_3wc_ani{count3wc} = animal;
             count3wc = count3wc + 1;
         elseif group == '8wC'
             coh_ave_8wc(count8wc) = coh_ave;
             coh_ave_8wc_ani{count8wc} = animal;
             count8wc = count8wc + 1;
         end
         disp(['done with shank for animal ' animal]);
        clear coh_matrix coh_matrix_run aligned_coh_matrix track run_matrix

    end
    savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\M2MO\';
    if exist(savepath)==0
        mkdir(savepath);
    end
    save([savepath '\M2M3_coh_whileM2MOColalign_running_3secconsec.mat'],'coh_ave_3wp','coh_ave_8wp', 'coh_ave_3wc', 'coh_ave_8wc','coh_ave_8wc_ani','coh_ave_3wc_ani','coh_ave_8wp_ani','coh_ave_3wp_ani');
    
    clear all

end