function [t_start, t_end] = artefactdetect_maxabsdiffpsd(x, fs, thresh)
%  Uses clean PSD spectrum, calculated on a training database in:
%  [1] Bakstein, E., et al. (2017) "Methods for Automatic Detection of Artifacts in
%  Microelectrode Recordings", Journal of Neuroscience Methods

if nargin == 2
    thresh = 0.0085;  % manual threshold from [1] 
end

% First filter the data between 500 and 5000 Hz, as in [1]. 
% If the Nyquist frequency (fs/2), filter between [500, fs/2]
[b, a] = butter(1, 2/fs*[500, 0.499*min(5000, fs/2)], 'bandpass');
x_filt = filtfilt(b, a, x);

nSec = ceil(length(x)/fs);
indsM = false(1,length(x));
for si=1:nSec
    ind = 1+fs*(si-1):min(fs*si, length(x));
    val = maxDiffPSD(x_filt(ind),fs);
    indsM(ind) = val > thresh;
end 


end
