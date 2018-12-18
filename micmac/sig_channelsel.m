function [SigOut] = sig_channelsel(SigIn, chanselpos)
%[Sigout] = SIG_CHANNELSEL(Sigin, chanselpos)
%   Select channel from the micMac signal

SigOut = SigIn;
if isequal(chanselpos, logical(chanselpos))
    chanselpos = find(chanselpos);
end
SigOut.channames        = SigIn.channames(chanselpos);
SigOut.channamesnoeeg   = SigIn.channamesnoeeg(chanselpos);
SigOut.eegchannelind    = SigIn.eegchannelind(chanselpos);
% If bad channels are marked but are not in the selected channels, remove
% them :
SigOut.badchannelpos(~ismember(SigOut.badchannelpos,chanselpos)) = [];
SigOut.nchan    = length(chanselpos);
SigOut.nchaneeg = sum(SigOut.eegchannelind);
% Data
SigOut.data     = SigIn.data(chanselpos, :);

end

