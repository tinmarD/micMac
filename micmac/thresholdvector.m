function [xThreshInd, tStart, tEnd] = thresholdvector(x, Fe, minVal, maxVal)
%[xThreshInd, tStart, tEnd] = THRESHOLDVECTOR(x, Fe, minVal, maxVal))
%   Threshold input vecto x. Select data whose amplitude lie between
%   minVal and maxVal. Returns the thresholded signal and the time of the
%   beginning and the end of each thresholded segment.
%
% INPUTS:
%   - x             : data vector 
%   - Fe            : Sampling frequency of x (Hz)
%   - minVal        : Amplitude above this value are selected
%   - maxVal        : Amplitude below this value are selected
%
% OUTPUTS: 
%   - xThreshInd    : Threshold indices vector (binary vector)
%   - tStart        : Vector containing the start of each threshold segment
%                   (in seconds)
%   - tEnd          : Vector containing the end of each threshold segment
%                   (in seconds)
%
% See also pop_threshold

if min(size(x))~=1
    error('Input x must be a vector');
end

if isempty(minVal); minVal=min(x); end;
if isempty(maxVal); maxVal=max(x); end;

xThreshInd      = x>=minVal & x<=maxVal;
xThreshInd      = [0,xThreshInd(2:end-1),0];
indLimit        = xThreshInd - [0,xThreshInd(1:end-1)];
indStart        = find(indLimit==1);
indEnd          = find(indLimit==-1);
tStart          = (indStart-1)/Fe;
tEnd            = (indEnd-1)/Fe;

end

