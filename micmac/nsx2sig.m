function [ Sig ] = nsx2sig( NSX )
%Sig = NSX2SIG (NSX)
% Convert a NSX (Blackrock) structure to a micMac Sig structure

Sig = s_emptysig();
Sig.srate           = NSX.MetaTags.SamplingFreq;
Sig.data            = NSX.Data;
Sig.filename        = NSX.MetaTags.Filename;
Sig.filepath        = NSX.MetaTags.FilePath;
Sig.nchan           = NSX.MetaTags.ChannelCount;
Sig.npnts           = NSX.MetaTags.DataPoints;
Sig.tmax            = NSX.MetaTags.DataDurationSec;
Sig.channames       = {NSX.ElectrodesInfo.Label};
Sig.channames       = cellfun(@(x)deblank(x),Sig.channames,'UniformOutput',0);
Sig.channamesnoeeg  = Sig.channames;
Sig.eegchannelind   = 1:Sig.nchan;
%- Try do detect if EEG channels are specified (with 'EEG ' in their labels)
if isempty(cell2mat(regexp(Sig.channames,'EEG'))) 
    % 'EEG' not found, consider all channels as eeg channels
    Sig.eegchannelind   = 1:Sig.nchan;
    Sig.channamesnoeeg  = Sig.channames;
else
    % 'EEG found'    
    Sig.eegchannelind   = zeros(1,nchan);
    Sig.channamesnoeeg  = cell(1,nchan);
    for i=1:Sig.nchan
        if isempty(regexp(Sig.channames{i},'EEG','once'))
            Sig.eegchannelind(i)    = 0;
            Sig.channamesnoeeg{i}   = Sig.channames{i};
        else
            Sig.eegchannelind(i)    = 1;
            start = regexp(Sig.channames{i},'EEG','start');
            Sig.channamesnoeeg{i}   = strtrim(Sig.channames{i}(start+3:end));
        end
    end
end


end

