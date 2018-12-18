function [Sig] = s_newsig(data, channames, srate, type, tmin, tmax, filename, filepath, montage, ...
    desc, israw, parent, id, badchannelpos, badepochpos)
% Sig = S_NEWSIGdata, channames, srate, type, tmin, tmax, filename, filepath, montage, ...
%  desc, israw, parent, id, badchannelpos, badepochpos)
%
% OUTPUTS :
%   - Sig           : Output Signal structure
%
% Sig structure fields :
%       data                : Data matrix [nSamples,nChannels]
%       srate               : Signal sampling rate (Hz)
%   	type                : Signal type (continuous or binary or epoch)
%       channames           : Cell containing channels' names
%       channamesnoeeg      : channel names without 'EEG ' at the beginning 
%       eegchannelind       : vector [1,nChan] equal to 1 if EEG channel, 0 otherwise
%       badchannelpos       : position of the bad channels
%       badepochpos         : position of the bad epochs (for epoch sig)
%       filename            : file name
%       filepath            : file path
%       npnts               : number of samples per channel
%       tmin                : minimal time (in seconds)
%       tmax                : maximal time (in seconds)
%       nchan               : number of channels
%       ntrials             : number of trials (for epoch sig)
%       nchaneeg            : number of eeg channels
%       montage             : montage 
%       israw               : 1 if raw is signal
%       desc                : description of the signal
%       parent              : ID of the parent signal (if signal is raw, set to -1)
%       id                  : ID of the signal (unique identifier)

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
Sig.badepochpos     = badepochpos;

Sig.eegchannelind   = logical(Sig.eegchannelind);
Sig.filename        = filename;
Sig.filepath        = filepath;
Sig.tmin            = tmin;
Sig.tmax            = tmax;
if strcmp(type,'eventSig')
    Sig.npnts           = -1;
    Sig.nchan           = max(data(:,2));  
    Sig.ntrials         = [];
elseif strcmp(type,'continuous')
    Sig.npnts           = size(data,2);
    Sig.nchan           = size(data,1);
    Sig.ntrials         = [];
elseif strcmp(type,'epoch')
    Sig.data            = shiftdim(Sig.data, 1); % For epoch, turn data from 3D to 2D
    Sig.data            = Sig.data(:,:);
    Sig.npnts           = size(data,3)*size(data,1);
%     Sig.npnts           = size(data,3);
    Sig.nchan           = size(data,2);
    Sig.ntrials         = size(data,1);
    Sig.tmax            = (Sig.tmax+abs(Sig.tmin))*Sig.ntrials;
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

