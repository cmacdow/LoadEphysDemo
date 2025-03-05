function [st_mat,opts,st_depth] = LoadSpikes(spike_opts_fn,varargin) 
%Camden MacDowell - timeless
%loads spike trains for a recording. 
%@@outputs 
%st_mat: 4x1 cell array (one for each probe) containing matrix of spikes x
%time 
%st_depth: depth of spikes 

% optionional inputs
opts.bindata = 1; 
opts.offset = 15; %number of timepoints start/stop truncated due to deconvolution to match with imaging data... 15 if binned, 30 if not
opts.mua = 0; %0 = only single units. 1 = single + mua. 2 = only mua
opts.depth = []; %range of depths (in mm) to use. keep empty if use the whole probe
opts.depth_type = 'probe'; %either 'probe' for location on probe or vert for vertical
opts = ParseOptionalInputs(opts,varargin);

%%  
spike_opts = load(spike_opts_fn);
spike_opts = spike_opts.opts; 
opts.spike_opts = spike_opts; %save for returning

%if spock
if ~ispc
    spike_opts.nidaq_path = ConvertToBucketPath(spike_opts.nidaq_path);
end

%additional curation
[ap_clusters,mua_clusters] = CreateMasks(spike_opts); 

%parse spikes
st_mat = cell(1,numel(spike_opts.kilosort_chan_map_names));
st_depth = cell(1,numel(spike_opts.kilosort_chan_map_names));
for cur_probe = 1:numel(spike_opts.kilosort_chan_map_names)
    
    %load the ephys data
    spikes = load([spike_opts.nidaq_path,sprintf('AP_Probe%d.mat',cur_probe)]);  %NEEDS TO BE CHANGED TO WHATEVER PATH OF THE DOWNLOADED DATA
    spikes.clust_info.vert_depth = spikes.vert_depth; %add the vertical depth to the structure
    %grab top x mm of spike IDs
    if opts.mua == 1 %include labeleds muas
       spikes.clust_info = ApplyMasks(spikes.clust_info,ap_clusters{cur_probe}+mua_clusters{cur_probe});               
    elseif opts.mua == 0 %only use single units
       spikes.clust_info = ApplyMasks(spikes.clust_info,ap_clusters{cur_probe}); 
    elseif opts.mua == 2 %only return muas
       spikes.clust_info = ApplyMasks(spikes.clust_info,mua_clusters{cur_probe}); 
    else 
        error('unknown mua flag');
    end

    %load specific depths
    if ~isempty(opts.depth)
        IDs = spikes.clust_info.id(spikes.clust_info.vert_depth>opts.depth(1) & spikes.clust_info.vert_depth<opts.depth(2));  
    else
        IDs = spikes.clust_info.id;  
    end
    
    %bin to the framerate of the imaging
    fileID = fopen([spike_opts.nidaq_path,'CameraFrameFrontEdgeTimes.txt'],'r');
    formatSpec = '%f';   
    im_times = fscanf(fileID,formatSpec);

    %bin the spiking activity of each neuron (frame rate here is 30fps)
    st = NaN(numel(IDs),numel(im_times));
    for cur_s = 1:size(st,1)
        temp = spikes.clust_info.spike_times(spikes.clust_info.spike_cluster==IDs(cur_s));
        st(cur_s,:) = [histcounts(temp,im_times),0]; %since k=nedges-1
    end
           
    %temporally bin (bin to 15fps)
    if opts.bindata ==1  
        st = st(:,1:2:end)+st(:,2:2:end);
    end           

    %remove truncation and transpose
    st_mat{cur_probe} = st(:,opts.offset+1:end-opts.offset)';       
    %depth type
    if strcmp(opts.depth_type,'probe') %depth along shank
        st_depth{cur_probe} = spikes.clust_info.depth;
        [st_depth{cur_probe},idx] = sort(st_depth{cur_probe},'descend'); %so to plot from surface you want it DESCENDING
    elseif strcmp(opts.depth_type,'vert') %estimated vertical depth
        st_depth{cur_probe} = spikes.clust_info.vert_depth;
        [st_depth{cur_probe},idx] = sort(st_depth{cur_probe},'ascend'); %so to plot from surface you want it ASCENDING
    else
        error('unknown depth label');
    end
    
    %sort by depth    
    st_mat{cur_probe} = st_mat{cur_probe}(:,idx);
    
end

end %function