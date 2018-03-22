function [Sig] = s_newsig(data, channames, srate, type, filename, filepath, montage, ...
    desc, israw, parent, id, badchannelpos)
% Sig = S_NEWSIG( data, channames, srate, type, filename, 
% filepath, montage, desc, israw, parent, id, badchannels)
% INPUTS : 
%   - data          : Data matrix [nSamples,nChannels]
%   - channames     : Cell containing channels' names
%   - srate         : Sampling rate in Hertz
%   - type          : Signal type ('continuous' or 'eventsig')
%   - filename      : Name of the file
%   - filepath      : Path of the file
%   - montage       : Montage of the file ('monopolar' or 'bipolar')
%   - desc          : Signal description (default: filename)
%   - israw         : 1 if the signal is raw, 0 otherwise
%   - parent        : ID of the parent signal (if signal is raw, set to -1)
%   - id            : ID of the signal (unique identifier)
%   - badchannelpos : Position of the bad channels 
%
% OUTPUTS :
%   - Sig           : Output Signal structure
%
% Signal Structure fields:
%       data
%       srate
%   	type                : Signal type (continuous or binary)
%       channames
%       channamesnoeeg      : channel names without 'EEG ' at the beginning 
%       eegchannelind       : vector [1,nChan] equal to 1 if EEG channel, 0 otherwise
%       badchannelpos
%       filename
%       filepath
%       npnts               : number of samples per channel
%       tmax                : maximal time (in seconds)
%       nchan               : number of channels
%       nchaneeg            : number of eeg channels
%       montage
%       israw
%       desc
%       parent
%       id

% TODO : Check inputs


Sig.data            = double(data);         % matrix : time*channel
Sig.srate           = srate;
Sig.type            = type;
Sig.channames       = channames;
Sig.channamesnoeeg  = cell(1,length(channames));
Sig.eegchannelind   = ones(1,length(channames));
for i=1:length(channames);
    eegpos                  = regexpi(channames{i},'EEG','end');
    if isempty(eegpos)
        Sig.channamesnoeeg{i}   = channames{i};
        Sig.eegchannelind(i)    = 0;
    else
        Sig.channamesnoeeg{i}   = strtrim(channames{i}(eegpos+1:end));
    end
end
if sum(Sig.eegchannelind)==0; Sig.eegchannelind = ones(1,length(channames)); end;
% If bad channels
if nargin == 12
    Sig.badchannelpos = badchannelpos;
    Sig.channamesnoeeg(badchannelpos) = ...
        cellfun(@(x)[x,' *'],Sig.channamesnoeeg(badchannelpos),'UniformOutput',0);
else
    Sig.badchannelpos   = [];
end

Sig.eegchannelind   = logical(Sig.eegchannelind);
Sig.filename        = filename;
Sig.filepath        = filepath;
if strcmp(type,'eventSig')
    Sig.npnts           = -1;
    Sig.tmax            = max(data(:,1));
    Sig.nchan           = max(data(:,2));  
elseif strcmp(type,'continuous')
    Sig.npnts           = size(data,2);
    Sig.tmax            = (Sig.npnts-1)/Sig.srate;
    Sig.nchan           = size(data,1);
else
    error(['Wrong signal type: ',type]);
end
Sig.nchaneeg        = sum(Sig.eegchannelind);
Sig.montage         = montage;
Sig.israw           = israw;
Sig.desc            = desc;
Sig.parent          = parent;
Sig.id              = id;


end

