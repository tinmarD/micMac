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

% 
% function VI = chancorrauto (VI, ALLSIG, Sig)
% 
% Sigs(1)     = Sig;
% newsigpos   = length(ALLSIG);
% % rawsigsum   = cumsum([ALLSIG.israw]);
% % newsigpos   = rawsigsum(newsigpos);
% 
% for j=1:length(ALLSIG)-1
%     Sigs(2) = ALLSIG(j);
%     %- If signal is not raw signal, continue to the next one
%     if ~Sigs(2).israw
%         continue;
%     end
%     
%     %- First try to determine the micro Sig and the macro Sig based on the
%     % first electrode name case
%     sigmicronb = [];
%     sigmacronb = [];
%     sig1firstchanname = strtrim(Sigs(1).channames{1});
%     sig1firstelname   = regexp(sig1firstchanname,'[\w '']+','match');
%     sig1firstelname   = strtrim(sig1firstelname{1});
%     sig2firstchanname = strtrim(Sigs(2).channames{1});
%     sig2firstelname   = regexp(sig2firstchanname,'[\w '']+','match');
%     sig2firstelname   = strtrim(sig2firstelname{1});
%     %- Remove 'EEG' if present
%     sig1firstelname   = strtrim(regexprep(sig1firstelname,'EEG',''));
%     sig2firstelname   = strtrim(regexprep(sig2firstelname,'EEG',''));
% 
%     if ~isempty(regexp(sig1firstelname(1),'[a-z]','once'))
%         sigmicronb = 1;
%     else
%         sigmacronb = 1;
%     end
%     if ~isempty(regexp(sig2firstelname(1),'[a-z]','once'))
%         sigmicronb = 2;
%     else
%         sigmacronb = 2;
%     end
% 
%     %- If the signal are not one micro and one Macro
%     if isempty(sigmacronb) || isempty(sigmicronb)
%         %- If the 2 signals have exactly the same channels
%         if isequal(Sigs(1).channames,Sigs(2).channames)
%             chancorr = repmat((1:Sigs(1).nchan)',1,2);
%             VI = addchancorr(VI,newsigpos,j,chancorr,chancorr);
% %             VI.chancorr{newsigpos,j} = chancorr;
% %             VI.chancorr{j,newsigpos} = chancorr;
%             continue;
%         else
%             continue;
%         end
%     end
% 
%     %- If micro and macro signals found
%     micro2macrochancorr = zeros(Sigs(sigmicronb).nchan,2);
%     macro2microchancorr = zeros(Sigs(sigmacronb).nchan,2);
%     %- Get the list of the different micro-electrode names
%     microelnames = regexp(Sigs(sigmicronb).channames,' [a-z]+''?','match');
%     microelnames = strtrim(unique([microelnames{:}]));
%     %- For each micro electrode name find the correspondig macro channels based
%     % on the name
%     for i=1:length(microelnames)
%         macrochancorr = regexpi(Sigs(sigmacronb).channames,[' ',microelnames{i},'\d+'],'match','once');
%         macrochancorr = find(~cellfun(@isempty,macrochancorr));
%         if isempty(macrochancorr); continue; end;
%         macrochancorr = macrochancorr(1);
%         microchancorr = regexp(Sigs(sigmicronb).channames,[' ',microelnames{i},'\d+']);
%         microchancorr = find(~cellfun(@isempty,microchancorr));
%         if isempty(microchancorr); continue; end;
%         micro2macrochancorr (microchancorr,:) = macrochancorr;
%         macro2microchancorr (macrochancorr,:) = [min(microchancorr),max(microchancorr)];
%     end
% 
%     % If the new signal is the micro-electrode one
%     
%     if sigmicronb==1
%         VI = addchancorr(VI,newsigpos,j,micro2macrochancorr,macro2microchancorr);
% %         VI.chancorr{newsigpos,j} = micro2macrochancorr;
% %         VI.chancorr{j,newsigpos} = macro2microchancorr;
%     else
%         VI = addchancorr(VI,newsigpos,j,macro2microchancorr,micro2macrochancorr);
% %         VI.chancorr{newsigpos,j} = macro2microchancorr;
% %         VI.chancorr{j,newsigpos} = micro2macrochancorr;
%     end
%     
% end

