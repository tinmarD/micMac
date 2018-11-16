function [Sig] = s_emptysig()
% [Sig] = s_emptysig()
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

Sig.data            = [];
Sig.srate           = [];
Sig.type            = '';
Sig.channames       = {};
Sig.channamesnoeeg  = {};
Sig.eegchannelind   = [];
Sig.badchannelpos   = [];
Sig.badepochpos     = [];
Sig.filename        = '';
Sig.filepath        = '';
Sig.npnts           = [];
Sig.tmin            = 0;
Sig.tmax            = [];
Sig.nchan           = [];
Sig.ntrials         = [];
Sig.nchaneeg        = [];
Sig.montage         = '';
Sig.israw           = [];
Sig.desc            = '';
Sig.parent          = [];
Sig.id              = [];

end

