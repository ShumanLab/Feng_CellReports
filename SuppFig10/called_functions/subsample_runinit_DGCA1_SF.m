
function subsample_runinit_DGCA1_SF(animals)

subY_runinitY_ls = [];
subY_runinitN_runY_ls = [];
subN_runinitN_ls = [];
subN_runinitY_ls = [];
    for a = 1:length(animals)
        animal = animals{a};
        exp_dir = get_exp(animal);
        [ana_dir]=get_ana(animal);
        load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
        savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\runinit\';
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
                %make run_init matrix
                runinit_matrix = []; %nan(length(run_matrix(:,1)));
                for i = 1: length(run_matrix)
                    if i == 1
                        runinit_matrix(i) = 0;
                    elseif run_matrix(i,1)-run_matrix(i-1,1) == 1
                        runinit_matrix(i) = 1;
                    else
                        runinit_matrix(i) = 0;
                    end 
                end
          
          % below are only RUN peroid based

                subY_runinitY_loc = (DGCA1align_ind_run == 1) & (runinit_matrix == 1); %find sub + runinit
                subY_runinitY = length(find(subY_runinitY_loc == 1))/length(find(runinit_matrix == 1));

                subY_runinitN_runY_loc = (DGCA1align_ind_run == 1) & (run_matrix(:,1)' == 1) & (runinit_matrix == 0); %find sub + run + non runinit
                runinitN_runY_loc = (run_matrix(:,1)' == 1) & (runinit_matrix == 0); %find run + non runinit
                subY_runinitN_runY = length(find(subY_runinitN_runY_loc == 1))/length(find(runinitN_runY_loc == 1));
                
                subY_runinitY_ls = [subY_runinitY_ls, subY_runinitY];
                subY_runinitN_runY_ls = [subY_runinitN_runY_ls, subY_runinitN_runY];
        
 %%% below is just to checkthe 4 propability and make sure these are independant events
%                 subY_runinitY_loc = (DGCA1align_ind_run == 1) & (runinit_matrix == 1); %find sub + runinit
%                 subY_runinitY = length(find(subY_runinitY_loc == 1))/length(find(run_matrix(:,1)' == 1));
% 
%                 subY_runinitN_loc = (DGCA1align_ind_run == 1) & (run_matrix(:,1)' == 1) & (runinit_matrix == 0); %find sub + run + non runinit
%                 subY_runinitN_runY = length(find(subY_runinitN_loc == 1))/length(find(run_matrix(:,1)' == 1));
% 
%                 subN_runinitN_loc = (DGCA1align_ind_run == 0) & (run_matrix(:,1)' == 1) & (runinit_matrix == 0); %find sub + run + non runinit
%                 subN_runinitN_runY = length(find(subN_runinitN_loc == 1))/length(find(run_matrix(:,1)' == 1));
% 
%                 subN_runinitY_loc = (DGCA1align_ind_run == 0) & (runinit_matrix == 1); %find sub + run + non runinit
%                 subN_runinitY_runY = length(find(subN_runinitY_loc == 1))/length(find(run_matrix(:,1)' == 1));
%                 
%                 subY_runinitY_ls = [subY_runinitY_ls, subY_runinitY];
%                 subY_runinitN_runY_ls = [subY_runinitN_runY_ls, subY_runinitN_runY];
%                 subN_runinitN_ls = [subN_runinitN_ls, subN_runinitN_runY];
%                 subN_runinitY_ls = [subN_runinitY_ls, subN_runinitY_runY];
               
                clear DGCA1align_ind align_ind_3sec_consec DGCA1align_ind_run run_matrix runinit_matrix subY_runinitN_runY_loc subY_runinitY_loc subY_runinitY runinitN_runY_loc subY_runinitN_runY
            end
  
        end


        
    end
writematrix(subY_runinitY_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\runinit\DGCA1subY_runinitY2runinitY_ls.csv' );
writematrix(subY_runinitN_runY_ls,'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\runinit\DGCA1subY_runinitN_runY2runinitN_runY_ls.csv' );

%%% below is just to checkthe 4 propability and make sure these are independant events
% subY_runinitY_ls_ave = mean(subY_runinitY_ls);
% subY_runinitN_runY_ls_ave = mean(subY_runinitN_runY_ls);
% subN_runinitN_ls_ave = mean(subN_runinitN_ls);
% subN_runinitY_ls_ave = mean(subN_runinitY_ls);

end