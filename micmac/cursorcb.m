function VI = cursorcb(VI, ALLWIN)
% VI = CURSORCB (ALLWIN)
%   This function is called when auser selects a cursor
%
% See also cursormotioncb

winnb   = find(cat(1,ALLWIN.figh)==gcbf);
Win     = ALLWIN(winnb);
    
if VI.cursor.type == 1

    if ~strcmp(get(gcbf,'SelectionType'),'normal')
        return;
    end

    try delete(VI.cursor.hlastcursor);catch;end;
    currentpoint    = (get (gca,'CurrentPoint'));
    curx            = currentpoint(1,1);
    cury            = currentpoint(1,2);
    switch Win.visumode
        case 1 % Stacked mode
        	txt     = sprintf('t:  %.4f s',curx);
        case 2 % Spaced mode 
            axisnb  = find (Win.axlist==gca);
            if isempty(axisnb); return; end;
            viewnb  = rem (axisnb,length(Win.views));
            viewnb  = fastif(viewnb==0,length(Win.views),viewnb);
            View    = ALLWIN(winnb).views(viewnb);
            switch View.domain
                case 't'
                    txt     = sprintf('t:  %.4f s\ny: %.1f uV',curx,cury);
                case 'f'
                    txt     = sprintf('f: %.1f Hz\nG: %.1f dB',curx,cury);
                case 'tf'
                    if View.params.logscale
                    	pfmin   = View.params.pfmin; pfmax = View.params.pfmax; n_pfreqs = View.params.pfstep;
                        pfreqs  = logspace(log10(pfmin),log10(pfmax),n_pfreqs);
                        ind     = round((n_pfreqs-1)/(pfmax-pfmin) * (cury-pfmin) + 1);
                        fval    = pfreqs(max(1,min(ind, n_pfreqs)));
                    else
                        fval    = View.params.pfmin+cury*View.params.pfstep;
                    end
                    txt     = sprintf('t:   %.4f s\nf:   %.1f Hz',curx,fval);
            end
    end
    VI.cursor.hlastcursor     = [];
    VI.cursor.hlastcursor (1) = text (curx-0.0015*diff(xlim),cury,'x');
    VI.cursor.hlastcursor (2) = text (curx+0.01*diff(xlim),cury,txt,'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');


end



