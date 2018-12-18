function [Sig] = opentrc2sig(filename, filepath)
%[Sig] = TRC2SIG(trc_header, trc_data)
%   Detailed explanation goes here

trc_header  = read_micromed_trc(fullfile(filepath,filename));
trc_data    = read_micromed_trc(fullfile(filepath,filename),1,trc_header.Num_Samples);

Sig = s_emptysig();
Sig.srate           = trc_header.Rate_Min;
Sig.data            = trc_data;
Sig.filename        = filename;
Sig.filepath        = filepath;
Sig.nchan           = trc_header.Num_Chan;
Sig.npnts           = trc_header.Num_Samples;
Sig.tmax            = (trc_header.Num_Samples-1) / trc_header.Rate_Min;
Sig.channames       = {trc_header.elec.Name};
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

