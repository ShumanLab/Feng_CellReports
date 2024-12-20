%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script is to re calculate DG-CA1 M32CA1 r  based on alined M2MO coh
% This re-calc is basing on run only and non seiz, 1sec bins
% INPUTS: M2MOcoh_1sec 
% units file
% Susie 5/19/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PART 3 calc for DGCA1 r
animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3'  'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2'  'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals for susie summer ephys experiment; 113-1 no cells on hpc shank; 112-1 113-2 no MOM2
coh_M2MOalign_1sec_DG2CA1_PL_recalc_SF(animals)


%% PART 4 calc for M3/M3 2 CA1 r

animals = { 'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS114-3' 'TS113-1' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS114-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'}; %list of all animals have EC3 EC2 or at least one of them
coh_M2MOalign_1sec_M32CA1_PL_recalc_SF(animals)