
%below is all animal list without control seizing  (110-0, 117-4, 113-3)
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment
%animals = {'TS112-0' }; %list of all animals for susie summer ephys experiment

for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info

    %%%% load DGCA1 data %%%%%
    if isfile([exp_dir '\DGCA1coh_1sec.mat']) 
       % BELOW IS building thereshold using control data
        load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
        if group == '3wP' | group == '8wP'
            load([exp_dir '\DGCA1coh_1sec.mat']);
            animal_subsample_binary_mat_1sbin = nan(length(coh_matrix), 3);
            animal_subsample_binary_mat_1sbin_run = nan(length(coh_matrix), 3);

            if exist('align_ind_3sec_consec') 
                DGCA1align_ind = align_ind_3sec_consec; %align_ind is whole track1 length
                DGCA1align_ind_run = DGCA1align_ind; %to find running during these subsampled bins
                for i = 1: length(run_matrix)
                   if run_matrix(i,1) == 0
                       DGCA1align_ind_run(i) = 0;
                   end
                end
                animal_subsample_binary_mat_1sbin(:,1) = DGCA1align_ind;
                animal_subsample_binary_mat_1sbin_run(:,1) = DGCA1align_ind_run;
            else
                animal_subsample_binary_mat_1sbin(:,1) = nan;
                animal_subsample_binary_mat_1sbin_run(:,1) = nan;
            end
            clear align_ind_3sec_consec
        end
    end

    %%%% load M2MO data %%%

       if isfile([exp_dir '\M2MOcoh_1sec.mat']) 
       % BELOW IS building thereshold using control data
            load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
            if group == '3wP' | group == '8wP'
                load([exp_dir '\M2MOcoh_1sec.mat']);
                if exist('align_ind_3sec_consec') 
                    M2MOalign_ind = align_ind_3sec_consec; %align_ind is whole track1 length
                    M2MOalign_ind_run = M2MOalign_ind; %to find running during these subsampled bins
                    for i = 1: length(run_matrix)
                       if run_matrix(i,1) == 0
                           M2MOalign_ind_run(i) = 0;
                       end
                    end
                    animal_subsample_binary_mat_1sbin(:,2) = M2MOalign_ind;
                    animal_subsample_binary_mat_1sbin_run(:,2) = M2MOalign_ind_run;
                else
                    animal_subsample_binary_mat_1sbin(:,2) = nan;
                    animal_subsample_binary_mat_1sbin_run(:,2) = nan;
                end
                clear align_ind_3sec_consec
            end
       end


    %%%% load M2M3 data %%%
      if isfile([exp_dir '\M2M3coh_1sec.mat']) 
           % BELOW IS building thereshold using control data
            load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
            if group == '3wP' | group == '8wP'
                load([exp_dir '\M2M3coh_1sec.mat']);
   
                if exist('align_ind_3sec_consec') 
                    M2M3align_ind = align_ind_3sec_consec; %align_ind is whole track1 length
                    M2M3align_ind_run = M2M3align_ind; %to find running during these subsampled bins
                    for i = 1: length(run_matrix)
                       if run_matrix(i,1) == 0
                           M2M3align_ind_run(i) = 0;
                       end
                    end
                    animal_subsample_binary_mat_1sbin(:,3) = M2M3align_ind;
                    animal_subsample_binary_mat_1sbin_run(:,3) = M2M3align_ind_run;
                else
                    animal_subsample_binary_mat_1sbin(:,3) = nan;
                    animal_subsample_binary_mat_1sbin_run(:,3) = nan;
                end
                clear align_ind_3sec_consec
            end
      end

   if group == '3wP' | group == '8wP'
        save([exp_dir '\subsample_binary_mat_1sbin.mat'], 'animal_subsample_binary_mat_1sbin', 'run_matrix');
        save([exp_dir '\subsample_binary_mat_1sbin_run.mat'], 'animal_subsample_binary_mat_1sbin_run', 'run_matrix');
 
   end

clear DGCA1align_ind DGCA1align_ind_run align_ind_3sec_consec M2MOalign_ind M2MOalign_ind_run M2M3align_ind M2M3align_ind_run run_matrix
end


%% build the full matrix to hold info for all pilo ani

% row0: animal name; row1:HPC sub%; row2:HPCMEC sub%; row3:MEC sub%; row4:HPCco1MECHPC sub%;
% rou5:HPCco0MEHPC Csub%; roe6:HPCco1MEC sub%; row7:HPCco0MEC sub%;
% row8:HPCco1MECco1MECHPC sub%; row9:HPCco0MECco0MECHPC sub%;
% row10:MECHPCco1MEC sub%; row11:MECHPCco0MEC sub%


counter = 0;
animal_ind = {};
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    if group == '3wP' | group == '8wP'
        counter = counter + 1;
        animal_ind{counter} = animal; 
    end
end

coh_sub_perc_full_mat = array2table(NaN(11, counter),'VariableNames', animal_ind ); %see above description of the col info of this matrix
coh_sub_perc_full_mat_run = array2table(NaN(11, counter),'VariableNames', animal_ind ); %see above description of the col info of this matrix

% build the full matrix for all animals
idx = 1;
idx_run = 1;
for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    if group == '3wP' | group == '8wP'
        %%%%%%%% all %%%%%%%%%%%%
        load([exp_dir '\subsample_binary_mat_1sbin.mat']);

        %%%%%%%%%%%%%%%%%%%%%%%
        %calc row1 HPC sub%
        if ~isnan(animal_subsample_binary_mat_1sbin(:,1))
            coh_sub_perc_full_mat(1,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1) == 1) / length(animal_subsample_binary_mat_1sbin));
        end
        %calc row2 MEC-HPC sub%
        if ~isnan(animal_subsample_binary_mat_1sbin(:,2))
            coh_sub_perc_full_mat(2,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,2) == 1) / length(animal_subsample_binary_mat_1sbin));
        end 
        %calc row3 MEC sub%
        if ~isnan(animal_subsample_binary_mat_1sbin(:,3))
            coh_sub_perc_full_mat(3,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,3) == 1) / length(animal_subsample_binary_mat_1sbin));
        end

    
        if ~isnan(animal_subsample_binary_mat_1sbin(:,1)) 
            if ~isnan(animal_subsample_binary_mat_1sbin(:,2))
                %calc row4 HPCco1MEC-HPC sub%
                coh_sub_perc_full_mat(4,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1)==1 & animal_subsample_binary_mat_1sbin(:,2)==1) / length(animal_subsample_binary_mat_1sbin));
                %calc row5 HPCco0MEC-HPC sub%
                coh_sub_perc_full_mat(5,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1)==0 & animal_subsample_binary_mat_1sbin(:,2)==0) / length(animal_subsample_binary_mat_1sbin));
            end
        end
    
        if ~isnan(animal_subsample_binary_mat_1sbin(:,1)) 
            if ~isnan(animal_subsample_binary_mat_1sbin(:,3))
                %calc row6 HPCco1MEC sub%
                coh_sub_perc_full_mat(6,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1)==1 & animal_subsample_binary_mat_1sbin(:,3)==1) / length(animal_subsample_binary_mat_1sbin));
                %calc row7 HPCco0MEC sub%
                coh_sub_perc_full_mat(7,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1)==0 & animal_subsample_binary_mat_1sbin(:,3)==0) / length(animal_subsample_binary_mat_1sbin));
            end
        end

        if ~isnan(animal_subsample_binary_mat_1sbin(:,1)) 
            if ~isnan(animal_subsample_binary_mat_1sbin(:,2)) 
                if ~isnan(animal_subsample_binary_mat_1sbin(:,3))
                    %calc row8 HPCco1MECco1MECHPC sub%
                    coh_sub_perc_full_mat(8,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1)==1 & animal_subsample_binary_mat_1sbin(:,2)==1 & animal_subsample_binary_mat_1sbin(:,3)==1) / length(animal_subsample_binary_mat_1sbin));
                    %calc row9 HPCco0MECco0MECHPC sub%
                    coh_sub_perc_full_mat(9,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,1)==0 & animal_subsample_binary_mat_1sbin(:,2)==0 & animal_subsample_binary_mat_1sbin(:,2)==0) / length(animal_subsample_binary_mat_1sbin));
                end
            end     
        end

        if ~isnan(animal_subsample_binary_mat_1sbin(:,2)) 
            if ~isnan(animal_subsample_binary_mat_1sbin(:,3))
                %calc row10 MECHPCco1MEC sub%
                coh_sub_perc_full_mat(10,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,2)==1 & animal_subsample_binary_mat_1sbin(:,3)==1) / length(animal_subsample_binary_mat_1sbin));
                %calc row11 MECHPCco0MEC sub%
                coh_sub_perc_full_mat(11,idx) = num2cell(sum(animal_subsample_binary_mat_1sbin(:,2)==0 & animal_subsample_binary_mat_1sbin(:,3)==0) / length(animal_subsample_binary_mat_1sbin));
            end
        end
        idx = idx + 1;
        clear animal_subsample_binary_mat_1sbin


        %%%%%%%%%%%%% run only %%%%%%%%%%%
        load([exp_dir '\subsample_binary_mat_1sbin_run.mat']);
         %calc row1 HPC sub%
        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,1))
            coh_sub_perc_full_mat_run(1,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1) == 1) / length(find(run_matrix(:,1) == 1)));
        end
        %calc row2 MEC sub%
        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,2))
            coh_sub_perc_full_mat_run(2,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,2) == 1) / length(find(run_matrix(:,1) == 1)));
        end 
        %calc row3 MEC-HPC sub%
        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,3))
            coh_sub_perc_full_mat_run(3,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,3) == 1) /length(find(run_matrix(:,1) == 1)));
        end

    
        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,1)) 
            if ~isnan(animal_subsample_binary_mat_1sbin_run(:,2))
                %calc row4 HPCco1MEC sub%
                coh_sub_perc_full_mat_run(4,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1)==1 & animal_subsample_binary_mat_1sbin_run(:,2)==1) / length(find(run_matrix(:,1) == 1)));
                %calc row5 HPCco0MEC sub%
                coh_sub_perc_full_mat_run(5,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1)==0 & animal_subsample_binary_mat_1sbin_run(:,2)==0) / length(find(run_matrix(:,1) == 1)));
            end
        end
    
        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,1)) 
            if ~isnan(animal_subsample_binary_mat_1sbin_run(:,3))
                %calc row6 HPCco1MECHPC sub%
                coh_sub_perc_full_mat_run(6,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1)==1 & animal_subsample_binary_mat_1sbin_run(:,3)==1) / length(find(run_matrix(:,1) == 1)));
                %calc row7 HPCco0MECHPC sub%
                coh_sub_perc_full_mat_run(7,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1)==0 & animal_subsample_binary_mat_1sbin_run(:,3)==0) / length(find(run_matrix(:,1) == 1)));
            end
        end

        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,1)) 
            if ~isnan(animal_subsample_binary_mat_1sbin_run(:,2)) 
                if ~isnan(animal_subsample_binary_mat_1sbin_run(:,3))
                    %calc row8 HPCco1MECco1MECHPC sub%
                    coh_sub_perc_full_mat_run(8,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1)==1 & animal_subsample_binary_mat_1sbin_run(:,2)==1 & animal_subsample_binary_mat_1sbin_run(:,3)==1) / length(find(run_matrix(:,1) == 1)));
                    %calc row9 HPCco0MECco0MECHPC sub%
                    coh_sub_perc_full_mat_run(9,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,1)==0 & animal_subsample_binary_mat_1sbin_run(:,2)==0 & animal_subsample_binary_mat_1sbin_run(:,2)==0) / length(find(run_matrix(:,1) == 1)));
                end
            end     
        end

        if ~isnan(animal_subsample_binary_mat_1sbin_run(:,2)) 
            if ~isnan(animal_subsample_binary_mat_1sbin_run(:,3))
                %calc row10 MECHPCco1MEC sub%
                coh_sub_perc_full_mat_run(10,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,2)==1 & animal_subsample_binary_mat_1sbin_run(:,3)==1) / length(find(run_matrix(:,1) == 1)));
                %calc row11 MECHPCco0MEC sub%
                coh_sub_perc_full_mat_run(11,idx_run) = num2cell(sum(animal_subsample_binary_mat_1sbin_run(:,2)==0 & animal_subsample_binary_mat_1sbin_run(:,3)==0) / length(find(run_matrix(:,1) == 1)));
            end
        end
        idx_run = idx_run + 1;
        clear animal_subsample_binary_mat_1sbin_run
        %%%%%%%%%%%%%%%%%%%%%%%
       

    end
end

%% saving data in csv file 
savepath='L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\ratio\';
if exist(savepath)==0
     mkdir(savepath);
end
writetable(coh_sub_perc_full_mat, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\ratio\subsample_ratio_full_mat.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 
writetable(coh_sub_perc_full_mat_run, 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\0.5SD\ratio\subsample_ratio_full_mat_RUN.csv','Delimiter',',') %first col: name; second col: pval for kuipertest/Mann-Whitney test; third col: pval for ktest (for centralization). forth col: Wwtest (for equal means) 

