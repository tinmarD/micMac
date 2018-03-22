function [Sig_out] = seteegchannels(Sig_in, eeg_channel_pos)
%[Sig_out] = SETEEGCHANNELS(Sig_in)
%   Modify the channel names of the EEG channels, whose position is given
%   by eeg_channel_pos. Add 'EEG ' in front of the EEG channel names, if
%   not already present. For non-EEG channels, remove 'EEG ' if present.
%   Also update the eegchannelind field based on eeg_channel_pos and
%   nchaneeg.

Sig_out = Sig_in;
Sig_out.eegchannelind = logical(zeros(1, Sig_out.nchan));
Sig_out.eegchannelind(eeg_channel_pos) = 1;
Sig_out.nchaneeg = sum(Sig_out.eegchannelind);
% Iterate over all channels 
for i = 1:Sig_out.nchan
    channame_i = Sig_out.channames{i};
    % If channel is EEG, add 'EEG ' in front of the channel name
    if Sig_out.eegchannelind(i)
        if ~strcmp(channame_i(1:4), 'EEG ')
            channame_i = ['EEG ',channame_i];
        end
    % If channel is not EEG
    else
        if strcmp(channame_i(1:4), 'EEG ')
            channame_i = channame_i(5:end);
        end        
    end
    Sig_out.channames{i} = channame_i;
end

end

