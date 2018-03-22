function Event = s_newevent(id, type, tpos, duration, channelind, channelname, sigid, sigdesc, rawparentid)
% Event = S_NEWEVENT(id, type, tpos, duration, channelind, ...
%                    channelname, sigid, sigdesc, rawparentid)
%
% Event Structure Fields : 
%              id:      Event unique ID
%            type:      Event type (string)
%            tpos:      Event start position (s)
%        duration:      Event duration (s)
%      channelind:      Channel associated with the event (position)
%     channelname:      Name of the channel associated with the event
%           sigid:      ID of the signal associated with the event
%         sigdesc:      Descripition of the signal associated with the event
%     rawparentid:      ID of the parent signal
%      centerfreq:      For oscillatory events, main frequency can be estimated
%           color:      Color of the event for visualization


Event.id            = id;
Event.type          = type;
Event.tpos          = tpos;
Event.duration      = duration;
Event.channelind    = channelind;
Event.channelname   = channelname;
Event.sigid         = sigid;
Event.sigdesc       = sigdesc;
Event.rawparentid   = rawparentid;
Event.centerfreq    = NaN;
Event.color         = vi_graphics('eventcolor');

end

