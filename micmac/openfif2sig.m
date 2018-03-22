function [ Sig ] = openfif2sig(filepath, filename)
%Sig = OPENFIF2SIG(filepath, filename)
% Reads an input FIF file (Elekta/Neuromag format, used by FieldTrip and 
% the MNE python package). Return a micMac Sig structure.

% Get informations about the file 
raw = fiff_setup_read_raw(fullfile(filepath, filename));

% Read all the data
[data, times] = fiff_read_raw_segment(raw,raw.first_samp,raw.last_samp);

Sig = s_emptysig();
Sig.srate           = raw.info.sfreq;
Sig.data            = 1E6*data;
Sig.filename        = filename;
Sig.filepath        = filepath;
Sig.nchan           = raw.info.nchan;
Sig.npnts           = size(data,2);
Sig.tmax            = times(end);
Sig.channames       = raw.info.ch_names;
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
    Sig.eegchannelind   = zeros(1,Sig.nchan);
    Sig.channamesnoeeg  = cell(1,Sig.nchan);
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

