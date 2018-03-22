function [Sig] = addeventsig (eventData, filename, filepath, channames)
%
%   INCOMPLETE
% 
%[Sig] = addeventsig (eventData, channames)
%   Create a micMac signal structure from an event list eventData.
%   This function is used to create event signals. Event signal allows to
%   visualize events in another and faster way. In this case the data
%   matrix is a 2 columns matrix.
%   The first colum must correspond to the time of the events (in s). 
%   The second colum must be the channel number.
%   Signal type is 'eventsig' (in opposition with 'continuous')
%   For event signals, sampling rate ('srate') is not defined, as well as 
%   'nPnts' and 'montage' fields.
%
% INPUTS : 
%  - eventData      : 2D matrix [nEvents,2]
%
% OUTPUTS : 
%  - Sig            : micMac signal structure
%

Sig = [];
%- Detect the number of 'channels' (or different event types)
nChan       = int16(max(eventData(:,2)));
%- If channames input is not given, name the channels with number {'channel
%1','channel 2', ...}
if nargin<4
    channames   = cell(1,nChan);
    for i=1:nChan; channames{i} = ['channel ',num2str(i)]; end;
end

data = eventData;
Sig = s_newsig(data,channames,-1,'eventSig',filename,filepath,'',



end

