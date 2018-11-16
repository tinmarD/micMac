function [VI, ALLWIN, ALLSIG] = pop_event2sigevent    (VI, ALLWIN, ALLSIG, eventPanelCall)
%
%   INCOMPLETE 
%
%[VI, ALLWIN, ALLSIG] = POP_EVENT2SIGEVENT (VI, ALLWIN, ALLSIG)
%   Convert events to a signal event.

if nargin==3
    eventPanelCall = 0;
end

titre = 'Event to event signal conversion';
if ~eventPanelCall
    return;
    
    
    
else
    %- Get signal sel
    eventSel    = VI.eventsel;
    eventSigId 	= unique([eventSel.sigid]);
    %- Get raw parent of each signal associated with the events
    parentSig   = getsigrawparent(ALLSIG,eventSigId);
    if length(unique([parentSig.id]))>1
        msgbox('Event must have one unique parent signal',titre);
        return;
    end
    nEvents                 = length(eventSel);
    parentSig               = parentSig(1);
    eventSigData            = zeros(nEvents,2);
    eventSigData(:,1)       = [eventSel.tpos];
    eventSigData(:,2)       = [eventSel.channelind];
    %- Add some events to be able to visualize all channels (even if no
    %events are on these channels)
    eventSigData(end+1,:)  	= [NaN,1];
    eventSigData(end+2,:)   = [NaN,parentSig.nchan];
    %- Signal name, combine parent sig desc and event type(s)
    eventSelType        = unique({eventSel.type});
    eventSelType        = cellfun(@(x)[x,'_'],eventSelType,'uniformOutput',0);
    eventSelType{end}   = eventSelType{end}(1:end-1);
    sigdesc             = [parentSig.desc,'_',[eventSelType{:}]];
end


windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;
cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

geometry = {[1,3],1,[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Name :'},...
    {'Style','edit','String',sigdesc},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',1},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'}};

results = inputgui (geometry, uilist, 'title', titre);

if ~isempty(results)
    sigdesc = results{1};
    %- Add signal
    [VI, ALLWIN, ALLSIG, sigid ]= addsignal(VI, ALLWIN, ALLSIG, ...
        eventSigData, parentSig.channames, -1, 'eventSig', Sig.tmin, Sig.tmax, parentSig.filename, parentSig.filepath, ...
        'undefined', sigdesc, 1, -1, [], []);
    %- Add view if asked
    if results{end-2}
        [VI, ALLWIN, ALLSIG]    = addview (VI, ALLWIN, ALLSIG, results{end-1},sigid,'t',str2double(results{end}));
    end
end


end

