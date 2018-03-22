function [spikeTstart, spikeTend] = spikedetect_mteo(x, Fe)
%[spikeTstart, spikeTend] = SPIKEDETECT_MTEO(x, Fe)
%   Experimental - Use the Teager Energy Operator to enphasize epileptic
%   spikes and then threshold the output to get spike times.
%
% INPUTS:
%   - x                 : Input data vector 
%   - Fe                : Sampling frequency
%
% OUTPUTS:
%   - spikeTstart       : Spike starting time (s)
%   - spikeTend         : Spike ending time (s)


% Value at 2048Hz : 10,15,20 (i.e. 5ms, 7.5ms and 10ms)

% Parameters
kValuesSec      = 1E-3*[5,7.5,10];      % Values for the k-TEO
thresholdVal    = 10;               	% Threshold value for the MTEO signal
mergeTimeMax    = 0.5;               	% Maximal merging time (s)

if min(size(x))~=1
    error('Input x must be a vector');
end

%-- Processing
kValues     = round(kValuesSec*Fe);
xNorm       = x/std(x);
xMTEO       = op_mteo(xNorm,kValues);
%- Threshold
[~, spikeTstart, spikeTend] = thresholdvector(xMTEO,Fe,thresholdVal,[]);
%- Merge close events
[spikeTstart, spikeTend]    = mergeevents_time(spikeTstart,spikeTend,mergeTimeMax);

end

