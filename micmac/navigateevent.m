function [VI, ALLWIN, ALLSIG] = navigateevent (VI, ALLWIN, ALLSIG, eventcmd, eventnb)
% [VI, ALLWIN, ALLSIG] = NAVIGATEEVENT (VI, ALLWIN,ALLSIG)
% [...] = NAVIGATEEVENT (..., 'next')          : moves to next event
%         NAVIGATEEVENT (..., 'previous')      : moves to previous event
%         NAVIGATEEVENT (..., 'goto', eventnb) : moves to event specified
%                                                   by event nb
%
% See also pop_seeevents, orderevents, updateeventsel



if isempty(VI.eventall); return; end;
if isempty(VI.eventsel); VI.eventsel=VI.eventall; end;

%- Update the event position
if nargin==3 % Call from the seeevents panel
    switch gcbo
        case findobj (gcbf,'tag','previouseventpb')
            if isempty(VI.eventpos); VI.eventpos=1;
            else VI.eventpos = median ([1,VI.eventpos-1,length(VI.eventsel)]);
            end
        case findobj (gcbf,'tag','nexteventpb')
            if isempty(VI.eventpos); VI.eventpos=1;
            else VI.eventpos = median ([1,VI.eventpos+1,length(VI.eventsel)]);
            end
        case findobj (gcbf,'tag','navigedit')
            neweventpos = str2double(get(findobj(gcbf,'tag','navigedit'),'string'));
            if isnan(neweventpos); return; end;
            VI.eventpos = median ([1,neweventpos,length(VI.eventsel)]);
    end
elseif nargin==4 % External call
    if strcmp(eventcmd,'previous')
        if isempty(VI.eventpos); VI.eventpos=1;
        else VI.eventpos = median ([1,VI.eventpos-1,length(VI.eventsel)]);
        end    
    elseif strcmp(eventcmd,'next')
        if isempty(VI.eventpos); VI.eventpos=1;
        else VI.eventpos = median ([1,VI.eventpos+1,length(VI.eventsel)]);
        end            
    end
elseif nargin==5
    if strcmp(eventcmd,'goto') && isnumeric(eventnb);
        VI.eventpos = median ([1,eventnb,length(VI.eventsel)]);
    end
end

Event = VI.eventsel(VI.eventpos);


for i=1:length(ALLWIN)

    if isempty(ALLWIN(i).views); continue; end;

    %- Compare the rawpid of the event with the one of the leading
    %- signal in the window
    [~,winrawpid] = getsigrawparent (ALLSIG,ALLWIN(i).views(1).sigid);

    %- If event and first view share the same raw parent id
    if Event.rawparentid == winrawpid
        chansel  = fastif(Event.channelind==-1,ALLWIN(i).chansel,Event.channelind);
    %- If event signal is different from the first view sigid
    else
        % If the event is defined on all channels, don't change the
        % channel selection
        if Event.channelind == -1
            chansel  = ALLWIN(i).chansel;
        % Else, look if channel correspondance exist between the two
        % raw signals
        else        
            try
                chancorr = VI.chancorr {find([ALLSIG.id]==Event.rawparentid),find([ALLSIG.id]==winrawpid)};
            catch
                dispinfo ('Signal missing for this event ?');
                warning  ('Signal missing for this event ?');
                continue;
            end
            if ~isempty(chancorr)
                chansel  = chancorr(Event.channelind,1):chancorr(Event.channelind,2);
                if sum(chansel)==0;
                    dispinfo('Event not defined for top view');
                    continue; 
                end;
            else
                dispinfo('Event not defined for top view');
                continue;
            end
        end
    end

    if Event.channelind==-1
        ALLWIN(i).chansel   = chansel;
    else
        nchanvisu = length(ALLWIN(i).chansel);
        switch ALLWIN(i).visumode
            % If stacked visu mode and the event channel is already
            % on screen don't change the selection, else change the
            % selection but keep the same number of channels 
            case 1  %"stacked"
                if ~ismember(chansel, ALLWIN(i).chansel)
                       chansel   = chansel-floor(nchanvisu/2):...
                                   chansel+ceil(nchanvisu/2)-1;
                       if chansel(1)<1
                           chansel = chansel-chansel(1)+1;
                       end
                       Sig = getsignal (ALLSIG, ALLWIN(i).views(1).sigid);
                       if chansel(end)>Sig.nchan
                           chansel = chansel-(chansel(end)-Sig.nchan);
                       end
                       chansel = chansel (1:nchanvisu);
                       ALLWIN(i).chansel   = chansel;
                end
            % If spaced mode, change the channel selection to the Event
            % channel 
            case 2  %"spaced"
                if ~ismember(chansel, ALLWIN(i).chansel)
                       if nchanvisu>1
                           chansel   = chansel-floor(nchanvisu/2):...
                                        chansel+ceil(nchanvisu/2)-1;
                           if chansel(1)<1
                               chansel = chansel-chansel(1)+1;
                           end
                           Sig = getsignal (ALLSIG, ALLWIN(i).views(1).sigid);
                           if chansel(end)>Sig.nchan
                               chansel = chansel-(chansel(end)-Sig.nchan);
                           end
                       end
                       chansel = chansel (1:nchanvisu);
                       ALLWIN(i).chansel   = chansel;
                end
        end
    end

    Sig = getsignal(ALLSIG, 'sigid', Event.sigid);
    if strcmp(Sig.type,'epoch')
        epoch_duration = Sig.npnts/Sig.ntrials/Sig.srate;
        epoch_tpre = abs(Sig.tmin);
        ALLWIN(i).ctimet = Event.tpos-epoch_tpre+epoch_duration/2;        
    else
        ALLWIN(i).ctimet    = Event.tpos+0.5*Event.duration;
    end
    ALLWIN  = checktimevariables (VI, ALLWIN, ALLSIG, i);
    ALLWIN  = redrawwin(VI,ALLWIN,ALLSIG,i);
end

for i=1:length(ALLWIN)
    if VI.eventpos==1
        dispinfo('First event');
    elseif VI.eventpos==length(VI.eventsel)
        dispinfo('Last event');
    end
end

if nargin==3
    set (findobj(gcbf,'tag','navigedit'), 'string', num2str(VI.eventpos));
else
    eventwin = findobj('tag','eventwindow');
    if ~isempty(eventwin)
        set (findobj(eventwin,'tag','navigedit'), 'string', num2str(VI.eventpos));
    end
end
    
end