function VI = addeventt(VI, ALLWIN, ALLSIG, eventType, tpos, duration, chanind, sigid)
% VI = ADDEVENTT(VI, ALLWIN, ALLSIG, type, tpos, ...
%                               duration, chanind, sigid)
% Add an event to the event list (stocked in VI structure). Update the
% event selection.
% 
% INPUTS : 
%   - VI, ALLWIN, ALLSIG 
%   - eventType             : Event description
%   - tpos                  : Event start position (s)
%   - duration              : Event duration (s)
%   - chanind               : Event channel (equal to -1 if event on all
%                             channels
%   - sigid                 : ID of the signal associated with the event
%
% OUTPUTS : 
%   - VI
%
% See also  s_newevent

[Sig,sigsel] = getsignal(ALLSIG,sigid);
if isempty(sigsel); error(['No signal has an id equal to ',num2str(sigid)]); end;

%- Create the new event structure
[~, rawparentid] = getsigrawparent (ALLSIG, sigid);

if chanind == -1; channame='all'; else channame=Sig.channames{chanind}; end;

[VI,eventid]    = incuniquecounter (VI,'event'); 
Event           = s_newevent (eventid, eventType, tpos, duration, chanind, channame, ...
                    sigid, Sig.desc, rawparentid);

if (tpos+duration)>Sig.tmax
    warning('Event latency out of temporal limits');
end

%- Add the event to VI event all
if isempty(VI.eventall)
    VI.eventall=Event;
else
    VI.eventall(end+1)=Event;
end

[VI] = updateeventsel (VI, 1);

% %- Add the event to the corresponding signal
% if isempty(ALLSIG(sigsel).events)
%     ALLSIG(sigsel).events = Event;
% else
%     ALLSIG(sigsel).events(end+1) = Event; 
% end


end

