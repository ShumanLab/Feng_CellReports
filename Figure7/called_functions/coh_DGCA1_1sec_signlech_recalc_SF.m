%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to re calculate M2M3 M2MO coh and  based on alined DGCA1 coh
% This re-calc is basing on run only and non seiz
% this is based on 1sec time bins
% INPUTS: DGCA1coh_1sec
% (dir: L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\DGCA1\)

% Susie 5/18/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PART1  calc for M2MO coh for all animals based on aligned DGCA1 coh
% below are all animals with M2 and DGCA1
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'};
coh_DGCA1_1sec_recalcM2MOcoh_SF(animals)

%% PART 2 calc for M2M3 coh all animals based on aligned DGCA1 coh
animals = {'TS112-0' 'TS114-1'  'TS111-1' 'TS115-2' 'TS116-3' ...
    'TS116-2' 'TS117-0' 'TS118-4'  'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2'  ...
     'TS110-3'  'TS115-1'  ...
    'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with mec2 and mec3
coh_DGCA1_recalcM2M3coh_SF(animals)