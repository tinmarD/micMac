function [VI, ALLWIN, ALLSIG] = artifactrej_variationthresh(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = ARTIFACTREJ_VARIATIONTHRESH(VI, ALLWIN, ALLSIG)
% Detect events whose amplitude variation is superior to a threshold AND
% events that happen in the first or last second of the signal 
% AND if the absolute value of the amplitude reaches a threshold
% Add "artifact" after the type of events
% Thresholds are defined in the file vi_defaultval.m
%
% Algorithm for each event : 
%   - Take the data from the raw signal
%   - Compute the approximate first-derivative signal (diff function)
%   - If maximum of derivative signal is above threshold, consider it a
%   artifact
%   - Remove also events at the very start or end of the signal (first or
%   last second)
%   - Modify the type of the detected events
%
% Consider only channel specific events

if isempty(VI.eventall)
    dispinfo('No events');
    return;
end

nArtifacts  = 0;
for i=1:length(VI.eventall)
    event_i     = VI.eventall(i);
    %- Consider only channel specific events
    if event_i.channelind == -1; continue; end;
    %- If event already an artefact, continue
    if strcmp(event_i.type,'artifact'); continue; end;
    %- Get event's raw signal
    rawSig      = getsigrawparent(ALLSIG,event_i.sigid);
    Fe          = rawSig.srate;
    %- If event is at the start or the end of the signal, class it as artifact
    if event_i.tpos<1 || (event_i.tpos+event_i.duration+1)>rawSig.tmax
        VI.eventall(i).type     = 'artifact';
        VI.eventall(i).color    = vi_graphics('artifacteventcolor');    
        nArtifacts              = nArtifacts+1;
        continue;
    end    
    %- Check maximum amplitude and slope
    eventInd    = 1+round(event_i.tpos*Fe):1+round((event_i.tpos+event_i.duration)*Fe);
    eventData   = rawSig.data(event_i.channelind,eventInd);
    evDataDiff  = diff(eventData);
    if max(evDataDiff)*Fe>vi_defaultval('art_deriv_thresh') || max(abs(eventData))>vi_defaultval('art_amp_thresh')
        VI.eventall(i).type     = 'artifact';
        VI.eventall(i).color    = vi_graphics('artifacteventcolor');
        nArtifacts              = nArtifacts+1;
    end        
end

[VI] = updateeventsel (VI, 1);
[VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG);
if nArtifacts~=0
    [ALLWIN]        = redrawwin (VI, ALLWIN, ALLSIG);
end
dispinfo([num2str(nArtifacts),' artifacts found']);

end

