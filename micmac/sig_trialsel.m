function [SigOut] = sig_trialsel(SigIn, trialselpos)
%[SigOut] = SIG_TRIALSEL(SigIn)
%   Select trials from a micMac signal of type ''epoch''

if ~strcmpi(SigIn.type, 'epoch')
    error('Input micMac signal must be of type ''epoch''');
else
    SigOut = SigIn;
    epochedData     = reshape(SigIn.data,[SigIn.nchan, SigIn.npnts/SigIn.ntrials, SigIn.ntrials]);
    epochedDataSel  = epochedData(:, :, trialselpos);
    SigOut.ntrials  = size(epochedDataSel, 3);
    SigOut.data     = epochedDataSel(:,:);
    SigOut.npnts    = size(SigOut.data, 2);
    SigOut.tmax     = SigIn.tmax * SigOut.ntrials / SigIn.ntrials;
    % If bad trials are marked but are not in the selected trials, remove
    % them :
    SigOut.badepochpos(~ismember(SigOut.badepochpos,trialselpos)) = [];
end

end

