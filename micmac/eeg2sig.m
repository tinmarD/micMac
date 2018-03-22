function Sig = eeg2sig(EEG,filepath,filename)
% Sig = EEG2SIG (EEG,filepath,filename)
%   Convert a EEG (EEGLAB) structure to a micMac Sig structure
% 
% INPUTS : 
%   - EEG           : EEGLAB EEG structure 
%   - filepath      : File path
%   - filename      : File name
%
% OUTPUTS : 
%   - Sig           : micMac Sig structure
%
% See also sig2eeg

Sig = s_emptysig();
Sig.srate           = EEG.srate;
Sig.type            = 'continuous'
Sig.data            = EEG.data;
Sig.filename        = filename;
Sig.filepath        = filepath;
Sig.nchan           = EEG.nbchan;
Sig.npnts           = EEG.pnts;
Sig.tmax            = EEG.xmax;
Sig.channames       = {EEG.chanlocs.labels};
Sig.channames       = cellfun(@(x)deblank(x),Sig.channames,'UniformOutput',0);
%- Try do detect if EEG channels are specified (with 'EEG ' in their labels)
if isempty(cell2mat(regexp(Sig.channames,'EEG'))) 
    % 'EEG' not found, consider all channels as eeg channels
    Sig.eegchannelind   = 1:Sig.nchan;
    Sig.channamesnoeeg  = Sig.channames;
else
    % 'EEG found'    
    Sig.eegchannelind   = zeros(1,Sig.nchan);
    Sig.channamesnoeeg  = cell(1,Sig.nchan);
    for i=1:Sig.nchan
        if isempty(regexp(Sig.channames{i},'EEG','once'))
            Sig.eegchannelind(i)    = 0;
            Sig.channamesnoeeg{i}   = Sig.channames{i};
        else
            Sig.eegchannelind(i)    = 1;
            start = regexp(Sig.channames{i},'EEG','once');
            Sig.channamesnoeeg{i}   = strtrim(Sig.channames{i}(start+3:end));
        end
    end
end

Sig.eegchannelind = logical(Sig.eegchannelind);
    
end

