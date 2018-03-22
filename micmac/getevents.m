function [Events, eventsel, etype, sigdesc, channame, chanind, tpos, duration, rawpid, eventid] = getevents(VI, varargin)
% [Events, eventsel, etype, sigdesc, channame,...
%       chanind, tpos, duration, rawpid] = getevents (VI, varargin)
% To get all events : [...] = getevents (VI)
% To select events  : [...] = getevents (VI, type, sigdesc, channame, tinterval)
%        Or         : [...] = getevents (VI,'sigdesc','micro_f>200Hz','channame','EEG TB1-TB2')


Events      = [];
eventsel    = [];
etype       = {};
sigdesc     = {};
channame    = {};
chanind     = [];
tpos        = [];
duration    = [];
rawpid      = [];
eventid     = [];

nevents  = length(VI.eventall);
if nevents==0; return; end;

etype     = {VI.eventall.type};
sigdesc   = {VI.eventall.sigdesc};
channame  = {VI.eventall.channelname};
chanind   = [VI.eventall.channelind];
tpos      = [VI.eventall.tpos];
duration  = [VI.eventall.duration];
rawpid    = [VI.eventall.rawparentid];
eventid   = [VI.eventall.id];

p = inputParser;
addOptional (p, 'type',     []);
addOptional (p, 'sigdesc',  []);
addOptional (p, 'channame', []);
addOptional (p, 'chanind',  [],     @isnumeric);
addOptional (p, 'tpos',     [],     @isnumeric);
addOptional (p, 'tposint',  [],     @isnumeric);
addOptional (p, 'duration', [],     @isnumeric);
addOptional (p, 'rawpid',   [],     @isnumeric);
addOptional (p, 'eventid',  [],     @isnumeric);

parse (p,varargin{:});

eventsel = ones(1,nevents);
%-char
if ~isempty(p.Results.type)
    eventsel = eventsel & ismember(etype,p.Results.type);
end
if ~isempty(p.Results.sigdesc)
    eventsel = eventsel & ismember(sigdesc,p.Results.sigdesc);
end
if ~isempty(p.Results.channame)
    eventsel = eventsel & ismember(channame,p.Results.channame);
end
%-numeric
if ~isempty(p.Results.chanind)
    eventsel = eventsel & ismember(chanind,p.Results.chanind);
end
if ~isempty(p.Results.tpos)
    eventsel = eventsel & ismember(tpos,p.Results.tpos);
end
if ~isempty(p.Results.tposint)
    eventsel = eventsel & (tpos>p.Results.tposint(1)-duration & tpos<p.Results.tposint(2));
end
if ~isempty(p.Results.duration)
    eventsel = eventsel & ismember(duration,p.Results.duration);
end
if ~isempty(p.Results.rawpid)
    eventsel = eventsel & ismember(rawpid,p.Results.rawpid);
end
if ~isempty(p.Results.eventid)
    eventsel = eventsel & ismember(eventid,p.Results.eventid);
end

eventsel    = logical       (eventsel);
Events      = VI.eventall   (eventsel);
etype       = etype         (eventsel);
sigdesc     = sigdesc       (eventsel);
channame 	= channame      (eventsel);
chanind     = chanind       (eventsel);
tpos        = tpos          (eventsel);
duration 	= duration      (eventsel);
rawpid      = rawpid        (eventsel);
eventid     = eventid       (eventsel);

end
