function [VI, ALLWIN, ALLSIG] = pop_addevent(VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = POP_ADDEVENT(VI, ALLWIN, ALLSIG)
% Used for adding an event from the axis. The user is asked to click on the
% temporal/channel limits of the event to be added. 
% Depending of the view visualisation's domain, interaction can change.
% The event label must be defined before adding an event.

winnb   = find (VI.figh==gcbf);
Win     = ALLWIN(winnb);

% Check that an event type has been defined :
if isempty(VI.guiparam.addevent.type)
    % If not, show the add-event-options gui
    [VI, ALLWIN, ALLSIG] = pop_addeventoptions(VI, ALLWIN, ALLSIG);
    return;
end

xval = zeros(2,1);
yval = zeros(2,1);
[xval(1),yval(1)] = ginput (1);


%- Get the view that was clicked
viewFocusPos    = getfocusedviewpos(Win, gca);
if isempty(viewFocusPos);
    dispinfo('Add event by cliking on the axis');
end
View    = Win.views(viewFocusPos);

%- Check signal's type, signal must be continous
Sig     = getsignal(ALLSIG,'sigid',View.sigid);
if strcmp(Sig.type,'eventSig')
    dispinfo('Add events on continuous signals, not on event signals');
    return;
end

%- Check visualisation domain
if strcmp(View.domain,'t')
    % Time views
    plot([xval(1),xval(1)],ylim,'--','Color',vi_graphics('addeventcolor'));
    if ALLWIN(winnb).visumode==1 && ~strcmp(VI.guiparam.addevent.channel,'global');
        plot(xlim,[yval(1),yval(1)],'--','Color',vi_graphics('addeventcolor'));
    end
    [xval(2),yval(2)] = ginput (1);
elseif strcmp(View.domain,'f')
    % Frequency views
    dispinfo ('Add events on time domain views');
    return;
elseif strcmp(View.domain,'tf')
    % Time-frequency views
    [xval(2),yval(2)] = ginput (1);
end


%- Get event parameters
xval        = sort (xval);
duration    = diff (xval);
tpos        = xval (1);      % Beginning of the event
viewnb      = viewFocusPos;

%- Get channel indices
switch Win.visumode
    
    case 1 % stacked
        yval        = sort(abs(yval));
        if strcmp(VI.guiparam.addevent.channel,'global');
            chanind = -1;
        else
            if viewnb==1
                chansel     = Win.chansel;
                chtick      = sort(get(gca,'ytick')*-1);
                chanind     = chansel(chtick>yval(1)&chtick<yval(2));
            else
                corrchansel = getcorrchannels(VI,ALLWIN, ALLSIG, winnb, viewnb);
                chtick      = sort(get(gca,'ytick')*-1);
                chanind     = corrchansel(chtick>yval(1)&chtick<yval(2));
            end
        end
        if length(chanind)>1
            ALLWIN = redrawwin(VI, ALLWIN, ALLSIG, winnb);
            dispinfo ('You must select only one channel');
            return;
        end
        
    case 2 % spaced
        if strcmp(VI.guiparam.addevent.channel,'global');
            chanind = -1;
        else
            axisnb      = find (Win.axlist==gca);
            chanindlead = Win.chansel(ceil(axisnb/length(Win.views)));
            if viewnb==1
                chanind = chanindlead;
            else
            	chanind = getcorrchannels (VI,ALLWIN, ALLSIG, winnb, viewnb, chanindlead);
                if length(chanind)>1; chanind=chanind(1); end;
            end
        end
end

if isempty(chanind)
    ALLWIN = redrawwin(VI, ALLWIN, ALLSIG, winnb);
    dispinfo ('You must select a channel');
    return;
end

sigid       = Sig.id;
type        = VI.guiparam.addevent.type;

%- Add event
VI = addeventt(VI, ALLWIN, ALLSIG, type, tpos, duration, chanind, sigid);

%- Redraw 
ALLWIN = redrawwin (VI, ALLWIN, ALLSIG, winnb);

end



