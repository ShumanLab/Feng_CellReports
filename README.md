# Distinct changes to hippocampal and medial entorhinal circuits emerge across the progression of cognitive deficits in epilepsy 
### Yu Feng1, Keziah S. Diego1, Zhe Dong1, Zoé Christenson Wick1, Lucia Page-Harley1, Veronica Page-Harley1, Julia Schnipper1, Sophia I. Lamsifer1, Zachary T. Pennington1, Lauren M. Vetere1, Paul A. Philipsberg1, Ivan Soler1, Albert Jurkowski1, Christin J. Rosado1, Nadia N. Khan1, Denise J. Cai1, Tristan Shuman1 
### *1: Nash Family Department of Neuroscience, Icahn School of Medicine at Mount Sinai*

##Original code developed for the publication

# Data and Analysis
All data and analysis are available here for reproduction and further analysis.  

## Data Access
Data, including all LFP and spike data, is available online on the DANDI Archive (https://dandiarchive.org; dataset #000638).

## Analysis files
All analysis were conducted using MATLAB, Python,and Prism.

Each main folder contains analysis files used for the given figure. 

A brief description of each file is provided below.

## Figures
### Preprocessing
- EphysProcessingPipelineSF_Preprocessing (.m)
- Organized animal experient info in a folder
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Figure 1
- Fig1CDEF_Prism file for NOL behavior (PRISM)

### Figure 2
- Fig2D_example LFP trace plotting code (.m)
- Fig2B_Seizure count prism file (PRISM)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Figure 3
- Fig3AB_HPC coherence and power code (.m)
- Fig3B_Coherence plotting code in Python (.py in folder)
- Fig3CD_Phase locking of DG inhibitory cell to CA1 (mu and r) (.m)
- Fig3E_Firing rate of DG inhibitory cells (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Figure 4
- Fig4ADBE_ Phase locking of MEC2 and MEC3 excitatory cells to HPC theta (mu and r) (.m)
- Fig4CF_Firing rate of MEC2 and MEC3 excitatory cells (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script


### Figure 5
- Fig5A_Plotting code for MEC3 subclusters (.m)
- Fig5A_MEC3 subcluster relative to shank location plotting (.m)
- Fig5BECF_ Phase locking of MEC3 Trough and Peak-locked excitatory cells to HPC theta (mu and r) (.m)
- Fig5DG_ Firing rate of MEC3 Trough and Peak-locked excitatory cells (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script

  
### Figure 6
- Fig6AB_HPC and MEC Coherence code (.m)
- Fig6AB_Coherence plotting code in Python (.py in folder)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Figure 7
- Fig7AB_Coherence subsampling code (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Supp Figure 4
- SuppFig4A_Speed output csv (.CSV)
- SuppFig4A_Speed output Prism file (PRISM)
- SuppFig4BC_Power and coherence code from MATLAB (.m)
- SuppFig4C_Coherence plotting code in Python (.py)

### Supp Figure 5
- SuppFig5A_H_Output coherence and power (.m)
- SuppFig5A-H_organized seizure information during silicon probe recording and during EEG recording (.CSV)
- SuppFig5A-H_Prism plotting (PRISM)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Supp Figure 6
- SuppFig6A-F_IED detection code (.m)
- SuppFig6A-F_prism file of correlation between IED and coherence and power (PRISM)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Supp Figure 7
- SuppFig7AB_HPC and MEC exc and inh clustering plot (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Supp Figure 8
- SuppFig8ABDE_MEC2/3 inhibitory cell phase locking mu and r (.m)
- SuppFig8CF_Firing rate of MEC2/3 inhibitory cells (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Supp Figure 9
- SuppFig9A_example waveform plot for Trough and Peak-locked units (.m)
- SuppFig9BCDEF_firing properties of MEC3 Trough and Peak-locked units  (.m)
- SuppFig9BCDEF_prism file of firing properties of MEC3 Trough and Peak-locked units (PRISM)
- SuppFig9GH_MEC3 subclusters hard-cutoff (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script

### Supp Figure 10
- SuppFig10B_code for the percentage of subsampled bins (.m)
- SuppFig10C_Proportion of subsampled bins during run and run-initiation
- SuppFig10D_python code for the proportion of subsampled bins across the track (.py in folder)
- SuppFig10E_running speed during subsampled bins (.m)
- Called_functions: contains all called functions and scripts within the main MATLAB script
