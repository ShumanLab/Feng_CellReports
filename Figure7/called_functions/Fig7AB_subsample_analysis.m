
%% NEW subsampling analysis with 1sec continue coh calc - 5/3/24
coh_DGCA1_1sec_singlech_SF %this is to calc coherence for each sec in the rec with just 1 ref ch
coh_M2MO_1sec_singlech_SF
coh_M2M3_1sec_singlech_SF

runtime_1sec_SF %this is to generate run matrix file 
coh_1sec_checkdef_SF %this is to check if OG deficits still there 

coh_DGCA1_1sec_singlech_align_SF %this is to check if alignment works for DGCA1 + generate aligned index
coh_M2MO_1sec_singlech_align_SF %this is to check if alignment works for M2MO + generate aligned index
coh_M2M3_1sec_singlech_align_SF %this is to check if alignment works for M2M3 + generate aligned index

%%%%%% NOTE below is calc 2sec consec bins, not 3sec anymore, I didn't change varible names for easiness
coh_DGCA1_1sec_alignmat3sec_SF %this is to make align index mat with new rule of 2s consec bins
coh_M2MO_1sec_alignmat3sec_SF %this is to make align index mat with new rule of 2s consec bins
coh_M2M3_1sec_alignmat3sec_SF %this is to make align index mat with new rule of 2s consec bins

%note this is based on 0.5SD creteria
coh_DGCA1_1sec_signlech_recalc_SF %this is to recalc coh for MOM2 M2M3 during DGCA1 aligned time
coh_M2MO_1sec_signlech_recalc_SF %this is to recalc coh for DGCA1 M2M3 during M2MO aligned time
coh_M2M3_1sec_signlech_recalc_SF %this is to recalc coh for DGCA1 M2M3 during M2MO aligned time

%phase locking calc
coh_DGCA1_1sec_signlech_recalc_PL_SF %this is to recalc PL for DG2CA1 and M32CA1 during DGCA1 aligned time
coh_M2MO_1sec_signlech_recalc_PL_SF %this is to recalc PL for DG2CA1 and M32CA1 during M2MO aligned time
coh_M2M3_1sec_signlech_recalc_PL_SF %this is to recalc PL for DG2CA1 and M32CA1 during M2M3 aligned time

%phase locking r and mu output
HPC_DGCA1subsample_PL_prismoutput_SF %this is to orgnize and output r and mu data for different cell types 
MEC_DGCA1subsample_PL_prismoutput_SF %this is to orgnize and output r and mu data for different cell types 
HPC_M2MOsubsample_PL_prismoutput_SF %this is to orgnize and output r and mu data for different cell types 
MEC_M2MOsubsample_PL_prismoutput_SF %this is to orgnize and output r and mu data for different cell types 
HPC_M2M3subsample_PL_prismoutput_SF %this is to orgnize and output r and mu data for different cell types 
MEC_M2M3subsample_PL_prismoutput_SF %this is to orgnize and output r and mu data for different cell types 

% correlate subsample data with behavior
OUTPUT_subsample_idx_SF %this is to out put HPC, MEC. MEC/HPC subsampled time bin index for furthur process in python (loc ana)
speed_subsample_SF % this is to output speed for subsample and non-subsampled times
runinit_subsample_SF % this is to look into relationship between run initiation and subsample
% subsample time porpotion
subsample_timeratio_SF % this is to calc the subsampled time bin's ratio over total time or total run time

