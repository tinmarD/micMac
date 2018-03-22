function [VI, counterid] = incuniquecounter(VI,countername)
% Increment the counter ID variable and return the incremented value

switch countername
    case 'signal'
        VI.sigid    = VI.sigid+1;
        counterid   = VI.sigid;
    case 'view'
        VI.viewid   = VI.viewid+1;
        counterid   = VI.viewid;
    case 'event'
        VI.eventid  = VI.eventid+1;
        counterid   = VI.eventid;
    otherwise
        error(['Undefined counter name: ',countername]);
end

end

