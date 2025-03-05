function [ap_clusters,mua_clusters] = CreateMasks(opts,unit_flag,mua_flag)
%Camden MacDowell - timeless
%Creates a mask structure to parse noise, mua, units, and quality

if nargin <1
    [opts_fn,~] = GrabFiles('ap_opts.mat'); %load opts file
    opts = load(opts_fn{1},'opts');
    opts = opts.opts; 
end

if nargin <2
    unit_flag = true; %true = keep borderline units, def=true; keep the 'bad' with the units as these were biased towards being good during manual scoring
end

if nargin <3
    mua_flag = false; %false = exclude borderline muas, def=false; because 'bad' because these were biased towards being bad during manual scoring
end

% disp(opts.nidaq_path)

%if spock
if ~ispc
    opts.nidaq_path = ConvertToBucketPath(opts.nidaq_path);
end

% disp(opts.nidaq_path)

%preallocate
N = numel(str2num(opts.prb));
ap_clusters = cell(1,N);
mua_clusters = cell(1,N);

for cur_probe = 1:N %probe loop
    %load spike info
    spikes = load([opts.nidaq_path,sprintf('AP_Probe%d.mat',cur_probe)]); 
    spikes = spikes.clust_info; 
    
    %parse cluster quality  
    if isfield(spikes,'q')
        good = arrayfun(@(x) strcmp(spikes.q(x),'g'),1:size(spikes.q,1),'UniformOutput',1); %NOTE: if only good is used, then all blank are bad
        bad = arrayfun(@(x) strcmp(spikes.q(x),'b'),1:size(spikes.q,1),'UniformOutput',1);
        blank = arrayfun(@(x) strcmp(spikes.q(x),' '),1:size(spikes.q,1),'UniformOutput',1);%can be either good or bad depending on scoring. 
        if sum(bad)~=0 %bad are labelled so consider blanks to be good
            good = good+blank==1;
        end %otherwise consider blanks to be bad
        quality = good; %binary of good vs bad.         
    else
        warning('no manual quality scoring'); 
        quality = ones(1,size(qual_info.id,1)); 
    end
    
    %unit vs mua (vs noise)
    unit = arrayfun(@(x) strcmp(spikes.group(x),'g'),1:size(spikes.group,1),'UniformOutput',1); %NOTE: if only good is used, then all blank are bad
    mua = arrayfun(@(x) strcmp(spikes.group(x),'m'),1:size(spikes.group,1),'UniformOutput',1);    
    
    %create masks for clusters
    ap_clusters{cur_probe} = false(1,numel(unit)); %all false
    ap_clusters{cur_probe}(unit) = true;
    if unit_flag~=1 %remove 'bad' units
       ap_clusters{cur_probe}(quality==0) = false;  
    end
    
    mua_clusters{cur_probe} = false(1,numel(unit)); %all false
    mua_clusters{cur_probe}(mua) = true;
    if mua_flag~=1 %remove 'bad' units
       mua_clusters{cur_probe}(quality==0) = false;  
    end

       
end %probe loop    


end
%end function
    