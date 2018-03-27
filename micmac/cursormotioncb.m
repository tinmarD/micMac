function VI = cursormotioncb(VI, ALLWIN)
%VI = CURSORMOTIONCB(VI, ALLWIN)
%   This function is called when user has selected a cursor 2 or 3 and 
%   is moving the mouse after the first click 
%
% See also cursorcb

try delete (VI.cursor.hlastcursor);catch; end;

currentpoint    = get (gca,'CurrentPoint');
curx            = currentpoint(1,1);
cury            = currentpoint(1,2);

try
    axes(VI.cursor.haxis);
catch
    % Could not find the axis - something has changed, remove the motion
    % callback
    set(gcbf,'WindowButtonMotionFcn','');
    VI.cursor.inc = 0;
end

winnb   = find(cat(1,ALLWIN.figh)==gcbf);
Win     = ALLWIN(winnb);
axisnb  = find (Win.axlist==gca);
if isempty(axisnb); return; end;
viewnb  = rem (axisnb,length(Win.views));
viewnb  = fastif(viewnb==0,length(Win.views),viewnb);
View    = ALLWIN(winnb).views(viewnb);
    
%- Temporal cursor (or frequency)
if VI.cursor.type == 2
    diffval         = abs(curx - VI.cursor.firstcursorval);
    if Win.visumode == 2 && strcmp(View.domain, 'f') && View.params.logscale
        VI.cursor.hlastcursor(1) = plot ([curx,curx],ylim,'b');
        VI.cursor.hlastcursor(2) = plot ([curx,curx],ylim,'b');
    else
        VI.cursor.hlastcursor(1) = plot ([curx,curx],ylim,'c');
        VI.cursor.hlastcursor(2) = plot ([curx+0.0005*diff(xlim),curx+0.0005*diff(xlim)],ylim,'b');
    end
    if Win.visumode == 2 && strcmp(View.domain,'f')
        VI.cursor.hlastcursor(3) = text (curx+0.01*diff(xlim),cury,sprintf('%.4f Hz',diffval),...
            'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');        
    else
        VI.cursor.hlastcursor(3) = text (curx+0.01*diff(xlim),cury,sprintf('%.4f s',diffval),...
            'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');
    end
    
%- Amplitude cursor
elseif VI.cursor.type == 3

    switch Win.visumode
    case 1 % Stacked mode
        diffval = abs(cury - VI.cursor.firstcursorval);
        diffval = diffval/(-1+exp(View.gain(1)));
        VI.cursor.hlastcursor(1) = plot (xlim,[cury,cury],'c');
        VI.cursor.hlastcursor(2) = plot (xlim,[cury+0.001*diff(ylim),cury+0.001*diff(ylim)],'b');
        VI.cursor.hlastcursor(3) = text (curx,cury+0.05*diff(ylim),sprintf('%.4f uV',diffval),...
            'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');  
    case 2 % Spaced mode 
        diffval         = abs(cury - VI.cursor.firstcursorval);
        VI.cursor.hlastcursor(1) = plot (xlim,[cury,cury],'c');
        VI.cursor.hlastcursor(2) = plot (xlim,[cury+0.001*diff(ylim),cury+0.001*diff(ylim)],'b');
        switch View.domain
            case 't'
                VI.cursor.hlastcursor(3) = text (curx,cury+0.05*diff(ylim),sprintf('%.4f uV',diffval),...
                    'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');  
            case 'f'
                VI.cursor.hlastcursor(3) = text (curx,cury+0.05*diff(ylim),sprintf('%.4f dB',diffval),...
                    'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');  
            case 'tf'
                if View.params.logscale
                    pfmin       = View.params.pfmin; pfmax = View.params.pfmax; n_pfreqs = View.params.pfstep;
                    pfreqs      = logspace(log10(pfmin),log10(pfmax),n_pfreqs);
                    ind_start   = round((n_pfreqs-1)/(pfmax-pfmin) * (VI.cursor.firstcursorval-pfmin) + 1);
                    ind_end     = round((n_pfreqs-1)/(pfmax-pfmin) * (cury-pfmin) + 1);
                    pfreq_diff  = abs(pfreqs(max(1,min(ind_end, n_pfreqs))) -  pfreqs(max(1,min(ind_start, n_pfreqs))));
                    VI.cursor.hlastcursor(3) = text (curx,cury+0.05*diff(ylim),sprintf('%.4f Hz',pfreq_diff),...
                        'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');  
                else
                    VI.cursor.hlastcursor(3) = text (curx,cury+0.05*diff(ylim),sprintf('%.4f Hz',diffval*View.params.pfstep),...
                        'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');  
                end
        end
    end
end

end

