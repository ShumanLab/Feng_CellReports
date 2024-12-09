%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to re calculate DGCA1 M2M3 coh and DG-CA1 M2/M32CA1 r  based on alined M2MO coh
% This re-calc is basing on run only and non seiz
% this is based on 1sec time bins
% INPUTS: M2MOcoh_1sec
% (dir: L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\subsample_ana\new_1sec\M2MO\)

% susie 5/18/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PART1  calc for DGCA1 coh for all animals based on aligned M2MO coh
% below are all animals with M2 and DGCA1
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with M2 and MO
coh_M2MO_1sec_recalcDGCA1coh_SF(animals)

%% PART 2  calc for M2M3 coh for all animals based on aligned M2MO coh
% below are all animals with M2 and DGCA1
animals = {'TS112-0' 'TS114-1'  'TS111-1' 'TS115-2' 'TS116-3' ...
    'TS116-2' 'TS117-0' 'TS118-4'  'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2'  ...
     'TS110-3'  'TS115-1'  ...
    'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals with mec2 and mec3
coh_M2MO_1sec_recalcM2M3coh_SF(animals)