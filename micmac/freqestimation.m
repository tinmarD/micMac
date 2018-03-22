function [VI, ALLWIN, ALLSIG] = freqestimation (VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = freqestimation (VI, ALLWIN, ALLSIG)
% Estimate the central frequency of events based on the power spectral
% density estimate vie Yule-Walker's method
% If the signal is not low-pass filtered filter the event before estimating
% the central frequency.

if isempty(VI.eventall)
    dispinfo ('No events');
    return;
end

if isempty(ALLSIG)
    dispinfo ('No signal loaded');
    return;
end

dispinfo('Frequency Estimation...');
pyulearOrder = vi_defaultval('pyulear_order');
%- For each event
for i=1:length(VI.eventall)
    eventi      = VI.eventall(i);
    %- Skip global events
    if eventi.channelind==-1
        continue;
    end
    SigEvent    = getsignal(ALLSIG, 'sigid', eventi.sigid);
    tind        = max(1,round(1+eventi.tpos*SigEvent.srate)):...
        min(round(1+(eventi.tpos+eventi.duration)*SigEvent.srate),SigEvent.npnts);
    eventData   = SigEvent.data(eventi.channelind,tind);
    %- If signal is not low-pass filtered, filter it before PSD estimation
    if isempty(getcutofffreqfromsigdesc(SigEvent.desc))
        [bFilter,aFilter] = butter(8,2*80/SigEvent.srate,'high');
        eventData = filter(bFilter,aFilter,eventData);
    end
    try
        nfft        = median([256, 2^nextpow2(length(tind)),65536]);
        [pxx,fVect] = pyulear(eventData,pyulearOrder,nfft,SigEvent.srate);    
        [~,maxInd]  = max(pxx);
        VI.eventall(i).centerfreq = round(fVect(maxInd));
    catch 
        VI.eventall(i).centerfreq = NaN
    end
end

[VI] = updateeventsel (VI, 1);

dispinfo('Done');


end

