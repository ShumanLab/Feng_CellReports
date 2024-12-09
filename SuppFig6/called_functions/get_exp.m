function [exp_dir] = get_exp(animal)

if strcmp(animal, 'TS116-2') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS116-2\201121\Recording\';   
elseif strcmp(animal, 'TS116-3') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS116-3\201113\Recording\';
elseif strcmp(animal, 'TS117-0') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS117-0\201119\Recording\'; 
elseif strcmp(animal, 'TS118-0') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS118-0\201231\Recording\'; 
elseif strcmp(animal, 'TS115-2') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS115-2\201128\Recording\'; 
elseif strcmp(animal, 'TS111-1') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS111-1\201204\Recording\';
elseif strcmp(animal, 'TS118-4') == 1
    exp_dir = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS118-4\201216\Recording\';
elseif strcmp(animal, 'TS88-3')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS88-3\210110\Recording\';
elseif strcmp(animal, 'TS90-0')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS90-0\210116\Recording\';
elseif strcmp(animal, 'TS89-1')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS89-1\210119\Recording\';
elseif strcmp(animal, 'TS112-0')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS112-0\210121\Recording\';
elseif strcmp(animal, 'TS114-0')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS114-0\210124\Recording\';
elseif strcmp(animal, 'TS114-1')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS114-1\210128\Recording\';
elseif strcmp(animal, 'TS111-2')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS111-2\210201\Recording\';
elseif strcmp(animal, 'TS116-0')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS116-0\210206\Recording\';
elseif strcmp(animal, 'TS118-3')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS118-3\210212\Recording\';
elseif strcmp(animal, 'TS86-1')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS86-1\211010\Recording\';
elseif strcmp(animal, 'TS110-0')==1
   exp_dir='F:\Susie\SummerEphysHPCEC\AnalysisOutput\TS110-0\211012\Recording\';
elseif strcmp(animal, 'TS114-3')==1
   exp_dir='F:\Susie\SummerEphysHPCEC\AnalysisOutput\TS114-3\211012\Recording\';
elseif strcmp(animal, 'TS113-1')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS113-1\211012\Recording\';
elseif strcmp(animal, 'TS117-4')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS117-4\211012\Recording\';
elseif strcmp(animal, 'TS118-2')==1
   exp_dir='L:\Susie\SummerEphysHPCEC\AnalysisOutput\TS118-2\211012\Recording\';
elseif strcmp(animal, 'TS89-3')==1
   exp_dir='F:\Susie\SummerEphysHPCEC\AnalysisOutput\TS89-3\211012\Recording\';
elseif strcmp(animal, 'TS91-1')==1
   exp_dir='F:\Susie\SummerEphysHPCEC\AnalysisOutput\TS91-1\211012\Recording\'; 
elseif strcmp(animal, 'TS110-3')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS110-3\220130\Recording\'; 
elseif strcmp(animal, 'TS112-1')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS112-1\220130\Recording\';   
elseif strcmp(animal, 'TS114-2')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS114-2\220130\Recording\';   
elseif strcmp(animal, 'TS113-3')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS113-3\220130\Recording\';
elseif strcmp(animal, 'TS113-2')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS113-2\220130\Recording\';  
elseif strcmp(animal, 'TS115-1')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS115-1\220130\Recording\'; 
elseif strcmp(animal, 'TS116-1')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS116-1\220130\Recording\'; 
elseif strcmp(animal, 'TS117-1')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS117-1\220130\Recording\'; 
elseif strcmp(animal, 'TS86-2')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS86-2\220130\Recording\'; 
elseif strcmp(animal, 'TS89-2')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS89-2\220130\Recording\'; 
elseif strcmp(animal, 'TS91-2')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS91-2\220130\Recording\'; 
elseif strcmp(animal, 'TS90-2')==1
   exp_dir='K:\Susie\SummerEphysHPCEC\AnalysisOutput\TS90-2\220130\Recording\';    
end
