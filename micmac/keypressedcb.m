function [VI,ALLWIN,ALLSIG] = keypressedcb (VI,ALLWIN,ALLSIG)
% [VI,ALLWIN,ALLSIG] = KEYPRESSEDCB (VI,ALLWIN,ALLSIG)
% Called when a key is pressed
% - Handle the different keyboard shortcuts :
%   - Right Arrow   : Move forward in time
%   - Left Arrow    : Move backward in time
%   - s             : Navigate to previous event
%   - f             : Navigate to next event
%   - escape        : Allow to escape from cursor mode
%   ( - tab ) 
%   - Suppr (Del)   : Allow to delete an event if it is on screen
%   - h             : Hide/Display events

winnb = find(VI.figh==gcbf);

switch get(gcbf,'currentkey')
    case 'rightarrow'
        if isempty(ALLWIN(winnb).views) || ~isempty(find(ALLWIN(1).syncctimetwin==winnb,1))
            return; 
        end;
        ALLWIN(winnb).ctimet=ALLWIN(winnb).ctimet+ALLWIN(winnb).obstimet;
        [ALLWIN]    = checktimevariables (VI, ALLWIN, ALLSIG);
        ALLWIN      = redrawwin(VI, ALLWIN, ALLSIG);
        
    case 'leftarrow'
        if isempty(ALLWIN(winnb).views) || ~isempty(find(ALLWIN(1).syncctimetwin==winnb,1))
            return; 
        end;
        ALLWIN(winnb).ctimet=ALLWIN(winnb).ctimet-ALLWIN(winnb).obstimet;
        [ALLWIN]    = checktimevariables (VI, ALLWIN, ALLSIG);
        ALLWIN      = redrawwin(VI, ALLWIN, ALLSIG);
        
    case 's'
        [VI, ALLWIN, ALLSIG] = navigateevent (VI, ALLWIN, ALLSIG, 'previous');
        
    case 'f'
        [VI, ALLWIN, ALLSIG] = navigateevent (VI, ALLWIN, ALLSIG, 'next');

        
    case 'escape'
        [VI, ALLWIN] = setcursor (VI, ALLWIN, ALLSIG, 0);
        
    case 'tab'
        screenSize  = get(0,'ScreenSize');
        posX        = round(0.5*(screenSize(3)-1080));
        posY        = round(0.5*(screenSize(4)-720));
        set(VI.figh(winnb),'Units','pixel','Position',[posX,posY,1080,720])
        
    case 'delete'
        if isempty(ALLWIN(winnb).views) || isempty(VI.eventsel) || VI.eventpos==0
            return;
        else
            %- See if current event is on screen (window)
            selEvent = VI.eventsel(VI.eventpos);
            Win      = ALLWIN(winnb);
            if selEvent.tpos > (Win.ctimet-0.5*Win.obstimet) && selEvent.tpos < Win.ctimet+0.5*Win.obstimet
                %- Ask confirmation
                if strcmp(questdlg('Delete event?'),'Yes')
                    [~,eventind] = getevents(VI,'eventid',selEvent.id);
                    %- Remove event from VI.eventall
                    VI.eventall(eventind) = [];
                    VI.eventpos = median([1,VI.eventpos-1,length(VI.eventall)]);
                    VI      = updateeventsel (VI,1,0);
                    ALLWIN  = redrawwin(VI, ALLWIN, ALLSIG, winnb);
                end
            end
        end
        
    case 'h'
        VI.guiparam.hideevents    = ~VI.guiparam.hideevents;
        if isempty(ALLWIN(winnb).views); return; end;
        ALLWIN = redrawwin(VI,ALLWIN,ALLSIG);
        if VI.guiparam.hideevents
            set(findobj(gcbf,'Label','Hide Events'),'label','Display Events'); 
        else
            set(findobj(gcbf,'Label','Display Events'),'label','Hide Events'); 
        end

            
end


end