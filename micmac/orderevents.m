function [VI] = orderevents (VI,h)
% [VI] = ORDEREVENTS (VI,h)
% Order the events on the events panel (pop_seeevents)
%
% INPUTS:
%   - VI
%   - h     : handle of the event panel gui (optional input)
%
% OUTPUTS:
%   - VI
% 
% See also pop_seeevents, updateeventsel, navigateevent

if isempty(VI.eventall); return; end;
if nargin==1; figh=gcbf; else figh=h; end;

%- Update GUI
orderfieldpop1  = findobj (figh,'tag','ordersel1');
orderfieldpop2  = findobj (figh,'tag','ordersel2');
orderfieldpop3  = findobj (figh,'tag','ordersel3');

orderfields1    = get (orderfieldpop1,'string');
orderfields2    = get (orderfieldpop2,'string');
orderfields3    = get (orderfieldpop3,'string');

fieldsel1       = orderfields1{get(orderfieldpop1,'value')};
fieldsel2       = orderfields2{get(orderfieldpop2,'value')};
fieldsel3       = orderfields3{get(orderfieldpop3,'value')};

%- Reset cell array
orderfields2    = orderfields1;
orderfields3    = orderfields1;

if ~isempty(fieldsel1);
    orderfields2(strcmp(orderfields2,fieldsel1)) = '';
    orderfields3(strcmp(orderfields3,fieldsel1)) = '';    
    fieldsel2 = fastif (strcmp(fieldsel2,fieldsel1),'',fieldsel2);
    fieldsel3 = fastif (strcmp(fieldsel3,fieldsel1),'',fieldsel3);
end
if ~isempty(fieldsel2);
    orderfields3(strcmp(orderfields3,fieldsel2)) = '';  
    fieldsel3 = fastif (strcmp(fieldsel3,fieldsel2),'',fieldsel3);
end

set (orderfieldpop2,'string',orderfields2,'value',find(strcmp(orderfields2,fieldsel2)==1));
set (orderfieldpop3,'string',orderfields3,'value',find(strcmp(orderfields3,fieldsel3)==1));
%--


%- Sort the events
VI.eventall = sortevents (VI.eventall,fieldsel1);
switch fieldsel1
    case 'type'
        types = unique({VI.eventall.type});
        for type = types;
            typeind = strcmp({VI.eventall.type},type);
            VI.eventall(typeind) = sortevents (VI.eventall(typeind),fieldsel2);
            switch fieldsel2
                case 'signal'
                    sigdescs = unique({VI.eventall(typeind).sigdesc});
                    for sigdesc = sigdescs
                        sigind = typeind(strcmp({VI.eventall(typeind).sigdesc},sigdesc));
                        VI.eventall(sigind) = sortevents (VI.eventall(sigind),fieldsel3);
                    end 
                    set (orderfieldpop3,'enable','on');
                otherwise
                    set (orderfieldpop3,'enable','off','value',1);
            end
        end
        set (orderfieldpop2,'enable','on');
    case 'signal'
        sigdescs = unique({VI.eventall.sigdesc});
        for sigdesc = sigdescs;
            sigind  = strcmp({VI.eventall.sigdesc},sigdesc);
            VI.eventall(sigind) = sortevents (VI.eventall(sigind),fieldsel2);
            switch fieldsel2
                case 'type'
                    types = unique({VI.eventall(sigind).type});
                    for type = types
                        typeind = sigind(strcmp({VI.eventall(sigind).sigdesc},sigdesc));
                        VI.eventall(typeind) = sortevents (VI.eventall(typeind),fieldsel3);
                    end 
                    set (orderfieldpop3,'enable','on');
                otherwise
                    set (orderfieldpop3,'enable','off','value',1);
            end
        end
        set (orderfieldpop2,'enable','on');
    otherwise
        fieldsel2 = '';
        set (orderfieldpop2,'enable','off','value',1);
        set (orderfieldpop3,'enable','off','value',1);
end

switch fieldsel2
    case 'type'
        types = unique({VI.eventall.type});
        for type = types;
            typeind = strcmp({VI.eventall.type},type);
            VI.eventall(typeind) = sortevents (VI.eventall(typeind),fieldsel2);
        end
    case 'signal'
        sigdescs = unique({VI.eventall.sigdesc});
        for sigdesc = sigdescs;
            sigind  = strcmp({VI.eventall.sigdesc},sigdesc);
            VI.eventall(sigind) = sortevents (VI.eventall(sigind),fieldsel2);
        end
    otherwise
        fieldsel3 = '';
end
        
%- Update VI structure GUI params
VI.guiparam.seeevents.order1 = fieldsel1;
VI.guiparam.seeevents.order2 = fieldsel2;
VI.guiparam.seeevents.order3 = fieldsel3;

if nargin==1
    VI = updateeventsel (VI);
end

end


function eventsorted = sortevents (events,field)
sortvect    = [];
eventsorted = events;
switch field
    case 'type'
        [~,sortvect] = sort({events.type});
%         set (orderfieldpop2,'enable','on');
%         set (orderfieldpop3,'enable','on');
    case 'signal'
        [~,sortvect] = sort({events.sigdesc});  
%         set (orderfieldpop2,'enable','on');
%         set (orderfieldpop3,'enable','on');
    case 'time'
        [~,sortvect] = sort([events.tpos]);   
%         set (orderfieldpop2,'enable','off');
%         set (orderfieldpop3,'enable','off');
    case 'duration'
        [~,sortvect] = sort([events.duration]);
%         set (orderfieldpop2,'enable','off');
%         set (orderfieldpop3,'enable','off');
    case 'channel'
        [~,sortvect] = sort([events.channelind]);   
%         set (orderfieldpop2,'enable','off');
%         set (orderfieldpop3,'enable','off');
    case ''  
%         set (orderfieldpop2,'enable','on');
%         set (orderfieldpop3,'enable','on');
    case 'frequency'
        [~,sortvect] = sort([events.centerfreq]);
end

if ~isempty(sortvect)
    eventsorted = events(sortvect);
end

end
