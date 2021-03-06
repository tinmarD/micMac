function [] = plotviewspaced (VI, ALLSIG, Win, ctimet, obstimet, chansel, couleur, viewind)
% [] = PLOTVIEWSPACED (VI, ALLSIG, Win, ctimet, obstimet, chansel, couleur, viewind)
%
% See also : plotviewspaced_eventsig, plotviewstacked

if ~isscalar(chansel); error('chansel input must be a scalar'); end;

visumode_names  = vi_defaultval('visumode_names');
visumodepos     = find(strcmp(visumode_names,'spaced'));

View    = Win.views(viewind);
nviews  = length(Win.views);

% Get the signal from the view sigid
Sig     = getsignal(ALLSIG, 'sigid', View.sigid);

tind    = max(1,round(1+Sig.srate*(ctimet-0.5*obstimet))):min(Sig.npnts,round(1+Sig.srate*(ctimet+0.5*obstimet)));
if isempty(tind); return; end;
if length(tind) > vi_graphics('maxtimepointsvisu')
    decimate_factor = floor(length(tind) / vi_graphics('maxtimepointsvisu'));
    tind = tind(1:decimate_factor:end);
end
tvect   = (tind-1)/Sig.srate;
data    = Sig.data (chansel,tind);

winpos  = get(Win.figh,'Position');

switch View.domain
    case 't'
        % Plot eeg data
        grid off;
        set (gca,'XTickMode','auto','XTickLabelMode', 'auto','YTickMode','auto','YTickLabelMode', 'auto');
        if isequal(couleur,'rainbow')
            electrodePos    = getelectrodepos(Sig);
            couleurs        = vi_graphics('plotcolors');
            colPos          = rem(electrodePos(chansel),size(couleurs,1));
            if colPos==0; colPos=size(couleurs,1); end;
            couleur         = couleurs(colPos,:);
        end
        plot (tvect,data,'color',couleur); hold on;
        if min(data)*max(data)<0
            plot ([tvect(1),tvect(end)],[0,0],'k'); hold on;
        end
        axis tight; axis on; set(gca, 'Box','Off'); grid on;
                
        % Set the height of the axis given the view's gain
        unityheight = vi_defaultval ('unity_height');
        ylims       = ylim;
        meanval     = ylims(1)+0.5*(diff(ylims));
        gaininv     = 1/(-1+exp(View.gain(visumodepos)));
        ylim ([meanval-0.5*gaininv*unityheight,meanval+0.5*gaininv*unityheight]);
        
        if ~VI.guiparam.hideevents
            %------- EVENTS ------
            % Find events that meet the time criteria
            timeEvents      = getevents (VI, 'tposint', [ctimet-0.5*obstimet, ctimet+0.5*obstimet]);

            % Check duration, if 0 (discrete event) set it to fraction of the time page
            stimPxRatio     = vi_defaultval('stim_duration_ratio')*diff(xlim)/winpos(3);
            for i=1:length(timeEvents)
                if timeEvents(i).duration == 0
                    timeEvents(i).duration = stimPxRatio;
                end
            end

            if ~isempty(timeEvents)
                ylims = ylim;
                %-- Get the selected event
                seleventid = [];
                if ~isempty(VI.eventsel) && ~isempty(VI.eventpos) && VI.eventpos~=0
                    seleventid = VI.eventsel(VI.eventpos).id;
                end

                %------------ OWN EVENTS ----------------------------------------------
                % Find the "own-events" : the event and the view are both linked to the
                % same raw signal
                [~,viewrawparentid] = getsigrawparent (ALLSIG, View.sigid);
                owneventind         = [timeEvents.rawparentid] == viewrawparentid;
                ownEvents           = timeEvents(owneventind);

                % Among these event select the ones that meet the channel criteria
                ownEvents = ownEvents (ismember([ownEvents.channelind],[-1;chansel(:)]));

                if ~isempty(ownEvents)
                    % Plot the own-events    
                    ownevtstart = [ownEvents.tpos];
                    ownevtstart (ownevtstart<ctimet-0.5*obstimet) = ctimet-0.5*obstimet;
                    ownevtend   = [ownEvents.tpos]+[ownEvents.duration];
                    ownevtend   (ownevtend>ctimet+0.5*obstimet)   = ctimet+0.5*obstimet;
                    %- Plot the events
                    plotevents(ownEvents, ownevtstart, ownevtend, 0)

                    seleventind = ismember ([ownEvents.id],seleventid);
                    if sum(seleventind)~=0
                        fill ([ownevtstart(seleventind),ownevtend(seleventind),ownevtend(seleventind),ownevtstart(seleventind)],[ylims(2),ylims(2),ylims(1),ylims(1)],...
                            ownEvents(seleventind).color,'EdgeColor',vi_graphics('eventseledgecolor'),'FaceAlpha',0);
                        %- Display event info (duration and frequency)
                        if VI.guiparam.dispeventinfo
                            curevent        = VI.eventsel(VI.eventpos);
                            if curevent.duration>1
                                eventinfotxt    = sprintf('%s\nDuration: %.2f ms\nFrequency: %.0f Hz',curevent.type,curevent.duration,curevent.centerfreq);
                            else
                                eventinfotxt    = sprintf('%s\nDuration: %d ms\nFrequency: %.0f Hz',curevent.type,round(1000*curevent.duration),curevent.centerfreq);
                            end
                            ylims = ylim;
                            text(curevent.tpos+curevent.duration+0.01*diff(xlim),ylims(1)+0.1*diff(ylim),eventinfotxt,'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');
                        end
                    end
                end
        
            
                %------------ SHADOW EVENTS -------------------------------------------
                % Find the "shadow-events" : the event and the view are not linked to
                % the same raw signal, but channel correspondence exist between these
                % two signals

                shadowEvents    = timeEvents (~owneventind);
                shadoweventind  = zeros (1,length(shadowEvents));

                for i=1:length(shadowEvents)
                    % If no correpondence between signals, continue
                    if isempty(VI.chancorr{shadowEvents(i).rawparentid,viewrawparentid})
                        continue;
                    end
                    % If global event and chancorr exist -> must appear on plot
                    if shadowEvents(i).channelind == -1 && ~isempty(VI.chancorr{shadowEvents(i).rawparentid,viewrawparentid})
                        shadoweventind(i) = 1;
                    elseif ismember(chansel,VI.chancorr{shadowEvents(i).rawparentid,viewrawparentid}(shadowEvents(i).channelind,1))%~=0 
                        shadoweventind(i) = 1;
                    end
                end
                shadowEvents    = shadowEvents(logical(shadoweventind));

                if ~isempty(shadowEvents)
                    % Plot the shadow-events    
                    shdevtstart = [shadowEvents.tpos];
                    shdevtstart (shdevtstart<ctimet-0.5*obstimet) = ctimet-0.5*obstimet;
                    shdevtend   = [shadowEvents.tpos]+[shadowEvents.duration];
                    shdevtend   (shdevtend>ctimet+0.5*obstimet)   = ctimet+0.5*obstimet;
                    %- Plot the events
                    plotevents(shadowEvents, shdevtstart, shdevtend, 1)

                    seleventind = ismember ([shadowEvents.id],seleventid);
                    if sum(seleventind)~=0
                        fill ([shdevtstart(seleventind),shdevtend(seleventind),shdevtend(seleventind),shdevtstart(seleventind)],[ylims(2),ylims(2),ylims(1),ylims(1)],...
                            shadowEvents(seleventind).color,'EdgeColor',vi_graphics('eventseledgecolor'),'FaceAlpha',vi_graphics('eventalphavalshadow'));
                    end
                end
            end
        end

        
    case 'tf'
        % Tukey windowing (to deal with edge effets)
%         tfWin 	= hamming(length(tind))';
        tfWin 	= tukeywin(length(tind),0.3)'; 
        dataw   = data.*tfWin;
        [SC, pseudofreq, scales, ~] = getwaveletscalogram (dataw, Sig.srate, ...
            View.params.wname, View.params.pfmin, View.params.pfmax, View.params.pfstep, View.params.logscale, View.params.norm, View.params.cyclemin, View.params.cyclemax);
        if View.params.logscale
            imagesc(tvect, pseudofreq, SC, 'HitTest','off', 'YData', pseudofreq);  
        else
            imagesc(SC,'XData',tvect,'HitTest','off');  
        end        
        axis('xy','tight');
        ylims   = ylim;
        offset  = 0.5*diff(ylim)/length(scales);  
        yticks  = linspace(offset+ylims(1),offset+ylims(2),10);
        if View.params.logscale
            n_pfreqs = View.params.pfstep;
            ind = floor((n_pfreqs-1)/(View.params.pfmax - View.params.pfmin)*(yticks - View.params.pfmin) + 1);
            ind(ind>n_pfreqs) = n_pfreqs;
            ind(ind<=0) = 1;
            ytick_label = round(pseudofreq(ind));
        else
            ytick_label = round(linspace(pseudofreq(1),pseudofreq(end),10));
        end
        % Overlay horizontal lines
        set (gca,'ygrid','on','xgrid','on','XColor',vi_graphics('tf_grid_color'),'YColor',vi_graphics('tf_grid_color'));
        set (gca,'YTick',linspace(offset+ylims(1),offset+ylims(2),10),'YTickLabel',ytick_label); 
    case 'ph'
%         tfWin 	= tukeywin(length(tind),0.3)'; 
%         dataw   = data.*tfWin;
        dataw = data;
        [~,pseudofreq,~,phaseMap] = getwaveletscalogram (dataw, Sig.srate, ...
            View.params.wname, View.params.pfmin, View.params.pfmax, View.params.pfstep, View.params.logscale, 'None', View.params.cyclemin, View.params.cyclemax, 1);
        if View.params.logscale
            imagesc(tvect, pseudofreq, phaseMap, 'HitTest','off', 'YData', pseudofreq);  
        else
            imagesc(phaseMap,'XData',tvect,'HitTest','off');  
        end        
        axis('xy','tight');
        ylims   = ylim;
        offset  = 0.5*diff(ylim)/length(pseudofreq);  
        yticks  = linspace(offset+ylims(1),offset+ylims(2),10);
        if View.params.logscale
            n_pfreqs = View.params.pfstep;
            ind = floor((n_pfreqs-1)/(View.params.pfmax - View.params.pfmin)*(yticks - View.params.pfmin) + 1);
            ind(ind>n_pfreqs) = n_pfreqs;
            ind(ind<=0) = 1;
            ytick_label = round(pseudofreq(ind));
        else
            ytick_label = round(linspace(pseudofreq(1),pseudofreq(end),10));
        end
        % Overlay horizontal lines
        set (gca,'ygrid','on','xgrid','on','XColor',vi_graphics('tf_grid_color'),'YColor',vi_graphics('tf_grid_color'));
        set (gca,'YTick',linspace(offset+ylims(1),offset+ylims(2),10),'YTickLabel',ytick_label); 
    case 'f'
        nfft        = View.params.nfft;
        fvect       = linspace (0,Sig.srate/2,1+nfft/2);
        fminind     = round(1+nfft/Sig.srate*View.params.fmin);
        fmaxind     = round(1+nfft/Sig.srate*View.params.fmax);
        switch View.params.method
            case 'Periodogram'
                pxx         = periodogram(data,hanning(length(tind)),nfft);
            case 'Welch'
                window      = hanning(round(length(tind)/3));
                noverlap    = round(length(window)/2);
                pxx         = pwelch(data,window,noverlap,nfft);
            case 'Yule-Walker'
                pxx         = pyulear (data,vi_defaultval('pyulear_order'),nfft);
        end
        pxx = 10*log10(pxx);
        if View.params.logscale
            set(gca,'xscale','log')
            semilogx(fvect(fminind:fmaxind),pxx(fminind:fmaxind),'color',couleur);
        else
            set(gca,'xscale','linear')
            plot(fvect(fminind:fmaxind),pxx(fminind:fmaxind),'color',couleur);
        end
        axis tight;  axis on; set(gca, 'Box','Off'); grid on;
        xlims = xlim; ylims = ylim;
        if View.params.logscale
            f_log = log10(fvect(fminind:fmaxind));
            xmid  = 10.^((f_log(end) + f_log(1))/2.25);
            text(xmid,ylims(2)-0.04*diff(ylims),'Power Spectrum');
        else
            text(xlims(1)+0.45*diff(xlims),ylims(2)-0.04*diff(ylims),'Power Spectrum');
        end                  
end
set (gca,'Color',vi_graphics('plotbackgroundcolor'),'XColor',vi_graphics('xtickcolor'),'YColor',vi_graphics('ytickcolor'));

%- Display the name (description) of the view at the top
textinter = get(0,'defaulttextinterpreter');
set (0,'defaulttextinterpreter','none');
set (gca, 'Units', 'pixels');
axespospx = get (gca, 'Position');
if ismember(View.domain,{'t','f'}); couleur=[0,0,0];
elseif strcmp(View.domain,'tf');    couleur=[0.85,0.85,0];
elseif strcmp(View.domain,'ph');    couleur=[0.9,0.9,0.9];
end
text (10,axespospx(4)-8, [Sig.desc,'-',View.domain], 'units','pixels',...
    'fontangle','italic','fontsize',8,'Color',couleur);
set (0,'defaulttextinterpreter',textinter);

if viewind == 1
    title (Sig.channames{chansel},'fontsize',8,'color',vi_graphics('plotchannelcolor'));
end
if viewind ~= nviews
    % If the next view is share the same domain with the current one,
    % delete the xticklabels
    if strcmp(View.domain,Win.views(viewind+1).domain)
        set (gca, 'XTickLabel', []);
    end
end

set (gca, 'Fontsize', 8);
end




function [] = plotevents(events, eventStarts, eventEnds, shadowevent)
    eventColors         = reshape([events.color],3,length(events))';
    eventUniqueColors   = unique(eventColors,'rows');
    nColors             = size(eventUniqueColors,1);
    ylims               = ylim;
    for evCol=1:nColors
        evColi      = eventUniqueColors(evCol,:);
        eventSelCol = ismember(eventColors,evColi,'rows');
        if shadowevent
            fill ([eventStarts(eventSelCol)',eventEnds(eventSelCol)',eventEnds(eventSelCol)',eventStarts(eventSelCol)']',[ylims(2),ylims(2),ylims(1),ylims(1)],...
                evColi,'EdgeColor','None','FaceAlpha',vi_graphics('eventalphavalshadow'));
        else
            fill ([eventStarts(eventSelCol)',eventEnds(eventSelCol)',eventEnds(eventSelCol)',eventStarts(eventSelCol)']',[ylims(2),ylims(2),ylims(1),ylims(1)],...
                evColi,'EdgeColor','None','FaceAlpha',vi_graphics('eventalphaval'));
        end
    end
end