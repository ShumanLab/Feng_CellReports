%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to generate new aligned index mat based on alined M2MO coh
% Rule: previous aligned mat need to be 3 sec continious bin to be considered as 'aligned' here
% INPUTS: M2MOcoh_1sec
% (dir: L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\M2MO\)

% Susie 5/27/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with M2 and MO



for a = 1:length(animals)
    animal = animals{a};
    exp_dir=get_exp(animal);
    [ana_dir]=get_ana(animal);
    load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
    load([ana_dir '\probe_data\ECHIP512.mat'])

win_size = 2; %3sec
isaligning = 0;

    if group == '3wP' | group == '8wP' 
        load([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix' , 'align_ind_run', 'align_ind');    %, 'align_ind_run', 'align_ind'); %use the ind to find timebin in M2MO

        align_ind_3sec_consec = align_ind;
        align_ind_run_3sec_consec = align_ind_run;
%%%%%%%%%%%%%%%%   This is for align_ind_3sec_consec     
        for i = 1: length(align_ind)
            if isaligning == 0
                counter = 0;
                if align_ind(i) == 1
                    counter = counter + 1;
                    isaligning = 1;
                elseif align_ind(i) == 0
                     isaligning = 0;
                end
           
            elseif isaligning == 1
                if align_ind(i) == 0
                    isaligning = 0;
                    if counter < win_size
                        align_ind_3sec_consec(i-counter:i) = 0;
                    end        

                elseif align_ind(i) == 1
                     counter = counter + 1;
                end
            end
        end

clear isaligning counter 
isaligning = 0;
%%%%%%%%%%%%%%%%   This is for align_ind_run_3sec_consec     
        for i = 1: length(align_ind_run)
            if isaligning == 0
                counter = 0;
                if align_ind_run(i) == 1
                    counter = counter + 1;
                    isaligning = 1;
                elseif align_ind_run(i) == 0
                     isaligning = 0;
                end
           
            elseif isaligning == 1
                if align_ind_run(i) == 0
                    isaligning = 0;
                    if counter < win_size
                        %if counter
                        align_ind_run_3sec_consec(i-counter:i) = 0;
                    end     
                elseif align_ind_run(i) == 1
                     counter = counter + 1;
                end
            end
        end

    save([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix' , 'align_ind_run', 'align_ind', 'align_ind_3sec_consec', 'align_ind_run_3sec_consec'); 
    clear align_ind_run align_ind align_ind_3sec_consec coh_matrix coh_matrix_run aligned_coh_matrix track run_matrix align_ind_run_3sec_consec
        
    end
end
