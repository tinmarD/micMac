function [Event] = s_emptyevent ()
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

Event.id            = [];
Event.type          = [];
Event.tpos          = [];
Event.duration      = [];
Event.channelind    = [];
Event.channelname   = [];
Event.sigid         = [];
Event.sigdesc       = [];
Event.rawparentid   = [];
Event.centerfreq    = NaN;
Event.color         = [];

end