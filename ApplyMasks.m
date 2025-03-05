function clust_info = ApplyMasks(clust_info,mask)
%Camden MacDowell - timeless
%takes input structure clust_info and grabs units
clust_info.id = clust_info.id(mask==1,:);
clust_info.Amplitude = clust_info.Amplitude(mask==1,:);
clust_info.ContamPct = clust_info.ContamPct(mask==1,:);
clust_info.KSLabel = clust_info.KSLabel(mask==1,:);
clust_info.amp = clust_info.amp(mask==1,:);
clust_info.ch = clust_info.ch(mask==1,:);
clust_info.depth = clust_info.depth(mask==1,:);
clust_info.fr = clust_info.fr(mask==1,:);
clust_info.group = clust_info.group(mask==1,:);
clust_info.n_spikes = clust_info.n_spikes(mask==1,:);
clust_info.q = clust_info.q(mask==1,:);
clust_info.sh = clust_info.sh(mask==1,:);
if isfield(clust_info,'vert_depth')
    clust_info.vert_depth = clust_info.vert_depth(mask==1,:);
end

end %function end