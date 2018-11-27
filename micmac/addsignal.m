function [VI, ALLWIN, ALLSIG, sigid] = addsignal(VI, ALLWIN, ALLSIG, data, channames,...
                    srate, type, tmin, tmax, filename, filepath, montage, desc, israw,...
                    parentId, badchannelpos, badepochpos)
% [VI, ALLWIN, ALLSIG, sigid] = ADDSIGNAL(VI, ALLWIN, ALLSIG, data, channames,...
%       srate, type, tmin, tmax,  filename, filepath, montage, desc, israw,
%       parentId, badchannelpos, badepochpos))
% Add a signal to the ALLSIG structure. 
%
% INPUTS :
%   - VI, ALLWIN, ALLSIG
%   - data                  : Signal data matrix [nSamples*nChannels]
%   - channames             : Cell containing channel names
%   - srate                 : Sampling frequency (Hz)
%   - type                  : Signal type ('continuous' or 'eventsig', or 'epoch')
%   - tmin                  : Minimal time (s)
%   - tmax                  : Maximal time (s)
%   - filename              : Name of the file
%   - filepath              : Path of the file
%   - montage               : Montage of the file ('monopolar' or 'bipolar')
%   - desc                  : Signal description (default: filename)
%   - israw                 : 1 if the signal is raw, 0 otherwise
%   - parentId              : ID of the parent signal (if signal is raw, set to -1)
%   - badchannelpos         : Position of the bad channels 
%   - badepochpos           : Position of the bad epochs (for epoch sig only)
%
% OUPUTS : 
%   - VI, ALLWIN, ALLSIG
%   - sigid                 : ID of the new signal
%
% See also s_newsig

% Check that the desc does not already exists - must be unique
desc = makeuniquesigdesc (ALLSIG, desc);

% Increment signal counter
[VI,sigid]  = incuniquecounter (VI,'signal');

if nargin < 16
    badchannelpos = [];
    badepochpos = [];
elseif nargin < 17
    badepochpos = [];
end
% Add new signal to ALLSIG
Sig = s_newsig (data, channames, srate, type, tmin, tmax, filename, ...
    filepath, montage, desc, israw, parentId, sigid, badchannelpos, badepochpos);
% Save new signal
if isempty(ALLSIG)
    ALLSIG  = Sig;
    sepval  = 'on';
else
    ALLSIG (length(ALLSIG)+1) = Sig;
    sepval  = 'off';
end

% Add it to the list of signals in Signal menu
cb_sigproperty = ['[VI, ALLWIN, ALLSIG] = pop_signalproperties(VI, ALLWIN, ALLSIG);'];
if israw
    sigmenuh    = findobj (VI.figh(1),'Label','Signals');
    topmenuh    = uimenu (sigmenuh, 'Label', desc, 'Separator', sepval);
    uimenu (topmenuh, 'Label', 'raw', 'Callback', cb_sigproperty);
    %- Try the automatic channel correspodency 
    if sum([ALLSIG.israw]) > 1
        VI          = chancorrauto (VI, ALLSIG,Sig);
    end
else
    SIGparent   = getsignal (ALLSIG, 'sigid', parentId);
    sigmenuh    = findobj(VI.figh,'Label',SIGparent.desc);
    uimenu (sigmenuh, 'Label', desc);
end

% Add channel correlation information if raw signal
if israw
    VI.chancorr {length(ALLSIG),length(ALLSIG)} = 1;
end
           
end

