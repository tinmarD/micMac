function [VI, ALLWIN] = vi_buttondowncb(VI, ALLWIN)
% [VI, ALLWIN] = VI_BUTTONDOWNCB(VI, ALLWIN)
% Called when user clicks on the mouse
%   - Modify the axis focus variable
%   - Handle the cursors if activated

%- Set the ax focus variable
winnb   = find(cat(1,ALLWIN.figh)==gcbf);
if isempty(ALLWIN(winnb).views); return; end;
ALLWIN(winnb).axfocus   = get(gcf,'CurrentAxes');
ALLWIN(winnb).viewfocus = getfocusedviewpos(ALLWIN(winnb));
Win     = ALLWIN(winnb);

%- If left mouse click and temporal or amplitude cursor activated 
if strcmp(get(gcbf,'SelectionType'),'normal') && (VI.cursor.type==2 || VI.cursor.type==3);
    
    if VI.cursor.inc == 0;
        try delete(VI.cursor.hfirstcursor);catch;end;
        currentpoint               = get (gca,'CurrentPoint');
        curx                       = currentpoint(1,1);
        cury                       = currentpoint(1,2);
        
        if Win.visumode == 1 % Stacked mode
            if VI.cursor.type == 2;
                VI.cursor.hfirstcursor(1)  = plot ([curx,curx],ylim,'c');
                VI.cursor.hfirstcursor(2)  = plot ([curx+0.0005*diff(xlim),curx+0.0005*diff(xlim)],ylim,'b');
                VI.cursor.firstcursorval   = curx;
            elseif VI.cursor.type == 3
                VI.cursor.hfirstcursor(1)  = plot (xlim,[cury,cury],'c');
                VI.cursor.hfirstcursor(2)  = plot (xlim,[cury+0.001*diff(ylim),cury+0.001*diff(ylim)],'b');
                VI.cursor.firstcursorval   = cury;
            end            
            
        elseif Win.visumode == 2 % Spaced mode
%             %- Get the View
%             axisnb  = find (Win.axlist==gca);
%             if isempty(axisnb); return; end;
%             viewnb  = rem (axisnb,length(Win.views));
%             viewnb  = fastif(viewnb==0,length(Win.views),viewnb);
            hold on;
            if VI.cursor.type == 2;
                VI.cursor.hfirstcursor(1)  = plot ([curx,curx],ylim,'c');
                VI.cursor.hfirstcursor(2)  = plot ([curx+0.0005*diff(xlim),curx+0.0005*diff(xlim)],ylim,'b');
                VI.cursor.firstcursorval   = curx;
            elseif VI.cursor.type == 3;
                VI.cursor.hfirstcursor(1)  = plot (xlim,[cury,cury],'c');
                VI.cursor.hfirstcursor(2)  = plot (xlim,[cury+0.001*diff(ylim),cury+0.001*diff(ylim)],'b');
                VI.cursor.firstcursorval   = cury;
%                 View = Win.views(viewnb);
%                 if strcmp(View.domain,'tf') && View.params.logscale
%                         pfmin   = View.params.pfmin; pfmax = View.params.pfmax; n_pfreqs = View.params.pfstep;
%                         pfreqs  = logspace(log10(pfmin),log10(pfmax),n_pfreqs);
%                         ind     = round((n_pfreqs-1)/(pfmax-pfmin) * (cury-pfmin) + 1);
%                         VI.cursor.firstcursorval = pfreqs(max(1,min(ind, n_pfreqs)));
%                 end
            end

        end
        VI.cursor.haxis = gca;
        VI.cursor.inc   = VI.cursor.inc+1;
        set (gcbf,'WindowButtonMotionFcn','VI = cursormotioncb(VI,ALLWIN);');
        
    elseif isequal(gca,VI.cursor.haxis);
        VI.cursor.inc=VI.cursor.inc+1;
        if VI.cursor.inc == 2
            drawnow;
            set (gcbf,'WindowButtonMotionFcn','');
            VI.cursor.inc=0;
        end
    end;
end;


end

