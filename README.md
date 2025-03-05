A Simple demo for manuscript: Multiplexed Subspaces Route Neural Activity Across Brain-wide Networks

Corresponds to the data provided at https://doi.org/10.5061/dryad.gxd2547x8 see readme and methods at that link for additional details

Simply run the following to load the spike trains for an example recording and bin spiking activity to match imaging activity (after adjusting paths:see below)

%EphysPath is the path to the downloaded data for Mouse331_06_11_2021 ap_opts file. The AP_Probe files need to be in the same directory 
%@@outputs 
%st_mat: 4x1 cell array (one for each probe) containing matrix of spikes x
%time 
%st_depth: depth of spikes 
[st_mat,~,st_depth] = LoadSpikes(EphysPath);

%NOTE: you'll need to adjust a couple of file path's within the script to match where the data was downloaded. 
