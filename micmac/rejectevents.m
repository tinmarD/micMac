function [VI, ALLWIN, ALLSIG] = rejectevents(VI, ALLWIN, ALLSIG, sigid, Events, reject_mode, new_sig_mode)
%[VI, ALLWIN, ALLSIG] = REJECTEVENTS(VI, ALLWIN, ALLSIG, sigid, Events, reject_mode, new_sig_mode)
%   From the Signal defined by sigid, and from the Event list Events, 
%   reject the time periods defined by the events. Or if the reject_mode is
%   False, the time periods defined by the events are the only one ketp.
%   A new signal is created if new_sig_mode is True. Otherwise the signal
%   is replaced with the new one. 
%   Events must have a duration
%
%   The new signal gets a new id and a new desc.
%   The new signal is raw (thus has no parent) 

n_events = length(Events);
[Sig_out, sig_pos] = getsignal(ALLSIG, 'sigid', sigid);
event_pnts = cell(1,n_events);
for i = 1:n_events
    event_i = Events(i);
    if event_i.duration > 0 
        t_ev_start_i = (1+round(event_i.tpos*Sig_out.srate));
        event_pnts{i} = t_ev_start_i:t_ev_start_i+round(event_i.duration*Sig_out.srate);
    end
end
event_pnts_all = sort([event_pnts{:}]);
event_pnts_all(event_pnts_all < 1) = [];
event_pnts_all(event_pnts_all > Sig_out.npnts) = [];
if reject_mode
    % If rejection mode, delete the event time points for all channels
    Sig_out.data(:, event_pnts_all) = [];
else
    % Else keep only the signal during the events
    Sig_out.data = Sig_out.data(:, event_pnts_all);
end
% Update the number of points and tmax
Sig_out.npnts   = size(Sig_out.data,2);
Sig_out.tmax    = Sig_out.npnts / Sig_out.srate;
Sig_out.israw   = 1;
Sig_out.parent  = -1;

% If new_sig_mode, add this signal at the end of ALLSIG
if new_sig_mode
    [VI, ALLWIN, ALLSIG] = addsignal(VI, ALLWIN, ALLSIG, Sig_out.data,...
        Sig_out.channames, Sig_out.srate, Sig_out.type, Sig_out.filename,...
        Sig_out.filepath, Sig_out.montage, Sig_out.desc, Sig_out.israw,... 
        Sig_out.parent, Sig_out.badchannelpos);
    % Remove chancorr with every other signal (because time is not
    % synchronized)
    for i_sig = 1:length(ALLSIG)-1
        VI.chancorr{end,i_sig} = [];
        VI.chancorr{i_sig, end} = [];
    end
% Else, update the current signal
else
    error('Not implemmented yet - set new_sig_mode to 1');
end

end

