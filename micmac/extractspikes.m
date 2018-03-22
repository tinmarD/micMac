function [spikes, tspikes, channelind] = extractspikes (Sigthresh, Sigbp, threshmin, threshmax, wpre, wpost)
% [spikes, tstart, tend] = EXTRACTSPIKES (Sigthresh, Sigbp, threshmin, ...
%                               threshmax, wpre, wpost)
% Extract times of spikes based on thresholding of Sigthresh between
% threshmin and threshmax. Extract in spikes the data of each spike, wpre
% points before and wpost after the time of spike.
% 
% OUTPUTS -     Spikes : matrix (N*T)
tspikes         = [];
spikes          = [];
channelind      = [];
indspikes       = [];

npnts           = Sigthresh.npnts;
datathreshind   = logical(Sigthresh.data>threshmin & Sigthresh.data<threshmax);
eegchannelpos   = nonzeros((Sigthresh.eegchannelind).*(1:Sigthresh.nchan));

% First get time of spikes
for i=1:Sigthresh.nchaneeg
    eventindi       = datathreshind(eegchannelpos(i),:);
    if sum(eventindi)==0; continue; end;
    eventlimiti     = eventindi - [0,eventindi(1:end-1)];
    eventindstarti  = nonzeros((eventlimiti==1).*(1:Sigthresh.npnts));
    eventindendi    = nonzeros((eventlimiti==-1).*(1:Sigthresh.npnts));
    % Remove the parts at the start or the end of the file
    indkeep         = eventindstarti>(2+wpre) & eventindendi<(npnts-2-wpost);
    eventindstarti  = eventindstarti (indkeep);
    eventindendi    = eventindendi   (indkeep);
    for j=1:length(eventindstarti)
        % Remove the transition to a value superior to threshmax
        if Sigthresh.data(eegchannelpos(i),eventindstarti(j)) == threshmax ||...
                Sigthresh.data(eegchannelpos(i),eventindendi(j)) == threshmax
            continue;
        end
        % Else get the time of maximum amplitude - Does NOT consider
        % multiple maxima
        [~,indspikeij]  = max(Sigthresh.data(eegchannelpos(i),eventindstarti(j):eventindendi(j)));
        indspikes       = [indspikes,eventindstarti(j)+indspikeij];
        channelind      = [channelind,eegchannelpos(i)];       
    end
end
tspikes = (indspikes-1)/Sigbp.srate;

% Get the data of each spike
nspikes     = length(indspikes);
spikes      = zeros (nspikes,wpre+wpost+1);
for k=1:nspikes
    spikes(k,:) =  Sigbp.data (channelind(k), indspikes(k)-wpre:indspikes(k)+wpost);    
end


end