function [] = plotviewstacked (VI, ALLWIN, ALLSIG, View, winnb, ctimet, obstimet, chansel, axes_h)
% [] = PLOTVIEWSTACKED (VI, ALLWIN, ALLSIG, View, winnb, ctimet, ...
%                     obstimet, chansel, axes_h)
% 
% Plot the view when visualisation mode is 'stacked'
%
% INPUTS : 
%   - VI, ALLWIN, ALLSIG    : micMac structures
%   - View                  : View structure
%   - winnb                 : window number
%   - ctimet                : window's central time (s)
%   - obstimet              : window's duration (s)
%   - chansel               : vector of selected channels
%   - axes_h                : handle to the axis object

if isempty(chansel); 
    child = allchild(gca);
    delete (child);
    set (gca,'xticklabel',{},'ytick',[]);
    return; 
end;

child = allchild(gca);
delete (child);
visumode_names  = vi_defaultval('visumode_names');
visumodepos     = nonzeros(strcmp(visumode_names,'stacked').*(1:length(visumode_names)));

% Get the signal from the view sigid
Sig     = getsignal (ALLSIG, 'sigid', View.sigid);

nchan   = length(chansel);
% Get dimension of the axes in pixels
winpos      = get(winnb,'Position');
axposn      = get(axes_h,'Position');
axheight    = axposn(4)*winpos(4);
% Calcul the vertical space between signals
spacing   	= axheight/(nchan+1);
spacingvect	= spacing.*(1:nchan);
spacingvect	= spacingvect(:);

tind    = max(1,round(1+Sig.srate*(ctimet-0.5*obstimet))):min(Sig.npnts,round(1+Sig.srate*(ctimet+0.5*obstimet)));
if isempty(tind); return; end;
if length(tind) > vi_graphics('maxtimepointsvisu')
%     decimate_factor = min(2, floor(length(tind) / vi_graphics('maxtimepointsvisu')));
    decimate_factor = max(1, floor(Sig.srate / vi_graphics('vizsrate')));
    tind = tind(1:decimate_factor:end);
end
tvect   = (tind-1)/Sig.srate;
% Modify data to be plot in one axes
data    = Sig.data (chansel,tind);
% If many time points, decimate the signal without low-pass filter, only
% for visualization
data    = data.*(-1+exp(View.gain(visumodepos)));
data    = data - repmat (mean(data,2),1,length(tind));      % Substract mean
data    = data - repmat(spacingvect,1,length(tind));        % Add a spacing between each signal

%---- Plot stuff -----
% Plot x-grid (on the background) (horizontal lines)
hold on;
plot([tvect(1),tvect(end)],-[spacingvect,spacingvect]','color',vi_graphics('xgridcolor'));
% Plot eeg data
if ~isequal(View.couleur,'rainbow')
    plot(tvect,data,'color',View.couleur);
else
    electrodePos    = getelectrodepos(Sig);
    electrodePosSel = electrodePos(chansel);
    elPosSelUnique  = unique(electrodePosSel);
    couleurs        = vi_graphics('plotcolors');
    nCouleurs       = size(couleurs,1);
    for i = 1:length(elPosSelUnique)
        colPos  = rem(elPosSelUnique(i),nCouleurs);
        if colPos==0; colPos=nCouleurs; end;
        plot(tvect,data(electrodePosSel==elPosSelUnique(i),:),'color',couleurs(colPos,:));
    end
end
axis tight;
axis ([xlim,-spacingvect(end)-spacing,-spacingvect(1)+spacing]);
% Plot y-grid (vertical lines)
xticks = get(gca,'xtick');
plot([xticks;xticks],ylim,'color',vi_graphics('ygridcolor'),'linestyle',':');
% Plot channel names (yticklabels)
set (gca, 'YTick', -flipdim(spacingvect,1),'YTickLabel',Sig.channamesnoeeg(fliplr(chansel)),'YColor',vi_graphics('plotchannelcolor'))
set (gca, 'XColor', vi_graphics('xtickcolor'));
set (gca, 'Color', vi_graphics('plotbackgroundcolor'), 'Fontsize', 8);

%- Display amplitude scale
xlims       = xlim; 
ylims       = ylim;
ampscalex   = xlims(1)+0.01*diff(xlims);
ampscaley   = ylims(1)+0.01*diff(ylims);
scaleamp    = 400;
scaleampg   = scaleamp*(-1+exp(View.gain(visumodepos)));
while scaleampg>0.2*diff(ylims) || scaleampg>0.8*spacing
	scaleamp    = 0.5*scaleamp;
    scaleampg   = scaleamp*(-1+exp(View.gain(visumodepos)));
end
plot ([ampscalex,ampscalex],[ampscaley,ampscaley+scaleampg],...
    'color',vi_graphics('scaleampcolor'),'Linewidth',2);
text (xlims(1)+0.015*diff(xlims),ampscaley+0.5*(scaleampg),[num2str(scaleamp),' uV']);



%- Display the name (description) of the signal at the top
textinter = get(0,'defaulttextinterpreter');
set (0,'defaulttextinterpreter','none');
set (gca, 'Units', 'pixels');
axespospx = get (gca, 'Position');
text (10,axespospx(4)-10, Sig.desc, 'units','pixels',...
    'fontangle','italic','fontsize',8);
set (0,'defaulttextinterpreter',textinter);

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
        % Get the selected event
        seleventid = [];
        if ~isempty(VI.eventsel) && ~isempty(VI.eventpos) && VI.eventpos~=0
            seleventid = VI.eventsel(VI.eventpos).id;
        end

        %------------ OWN EVENTS ----------------------------------------------
        % Find the "own-events" : the event and the view are both linked to the
        % same raw signal
        [~,viewrawparentid]     = getsigrawparent (ALLSIG, View.sigid);
        [~,viewrawparentpos]    = getsignal(ALLSIG,viewrawparentid);
        viewrawparentpos        = find(viewrawparentpos,1);
        owneventind             = [timeEvents.rawparentid] == viewrawparentid;
        ownEvents               = timeEvents (owneventind);
        % Among these event select the ones that meet the channel criteria
        ownEvents = ownEvents (ismember([ownEvents.channelind],[-1;chansel(:)]));

        % Separate the global own vents and channel specific own events
        ownEvents_g = ownEvents ([ownEvents.channelind]==-1);
        ownEvents_c = ownEvents ([ownEvents.channelind]~=-1);

        % Plot the GLOBAL own-events    
        if ~isempty(ownEvents_g)
            ownevg_tstart   = [ownEvents_g.tpos];
            ownevg_tstart (ownevg_tstart<ctimet-0.5*obstimet) = ctimet-0.5*obstimet;
            ownevg_tend     = [ownEvents_g.tpos]+[ownEvents_g.duration];
            ownevg_tend   (ownevg_tend>ctimet+0.5*obstimet)   = ctimet+0.5*obstimet;
            %- Plot the events
            plotglobalevents(ownEvents_g, ownevg_tstart, ownevg_tend)

            seleventind = ismember ([ownEvents_g.id],seleventid);
            if sum(seleventind)~=0
                fill ([ownevg_tstart(seleventind),ownevg_tend(seleventind),ownevg_tend(seleventind),ownevg_tstart(seleventind)],[ylims(2),ylims(2),ylims(1),ylims(1)],...
                    ownEvents_g(seleventind).color,'EdgeColor',vi_graphics('eventseledgecolor'),'FaceAlpha',0);
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

        % Plot the CHANNEL SPECIFIC own-events
        if ~isempty(ownEvents_c)
            ownevc_tstart   = [ownEvents_c.tpos];
            ownevc_tstart   = ownevc_tstart(:); % NEW
            ownevc_tstart (ownevc_tstart<ctimet-0.5*obstimet) = ctimet-0.5*obstimet;
            ownevc_tend     = [ownEvents_c.tpos]+[ownEvents_c.duration];
            ownevc_tend     = ownevc_tend(:);   % NEW
            ownevc_tend   (ownevc_tend>ctimet+0.5*obstimet)   = ctimet+0.5*obstimet;
            ownevc_cind     = [ownEvents_c.channelind];

            spacingev       = 0.6*spacing;
            [~,ypos]        = ismember(ownevc_cind,chansel);
            ymed            = spacingvect(ypos);

            %- Plot the events
            plotchannelevents(ownEvents_c, ownevc_tstart, ownevc_tend, ymed, spacingev)

            seleventind = ismember ([ownEvents_c.id],seleventid);
            if sum(seleventind)~=0
                fill ([ownevc_tstart(seleventind),ownevc_tend(seleventind),ownevc_tend(seleventind),ownevc_tstart(seleventind)],...
                    -[ymed(seleventind)+spacingev,ymed(seleventind)+spacingev,ymed(seleventind)-spacingev,ymed(seleventind)-spacingev],...
                    ownEvents_c(seleventind).color,'EdgeColor',vi_graphics('eventseledgecolor'),'FaceAlpha',0);
                %- Display event info (duration and frequency)
                if VI.guiparam.dispeventinfo
                    curevent        = VI.eventsel(VI.eventpos);
                    if curevent.duration>1
                        eventinfotxt    = sprintf('%s\nDuration: %.2f ms\nFrequency: %.0f Hz',curevent.type,curevent.duration,curevent.centerfreq);
                    else
                        eventinfotxt    = sprintf('%s\nDuration: %d ms\nFrequency: %.0f Hz',curevent.type,round(1000*curevent.duration),curevent.centerfreq);
                    end
                    ylims = ylim;
                    text(curevent.tpos+curevent.duration+0.01*diff(xlim),-ymed(seleventind)-spacingev,eventinfotxt,'Fontsize',8,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left');
                end
            end
        end


        %------------ SHADOW EVENTS -------------------------------------------
        % Find the "shadow-events" : the event and the view are not linked to
        % the same raw signal, but channel correspondence exist between these
        % two signals
        spacingev       = 0.6*spacing;
        shadowEvents    = timeEvents (~owneventind);
        for i=1:length(shadowEvents)
            % If global event, and channel correspondence exist 
            shadowev_rawparentpos = find([ALLSIG.id] == shadowEvents(i).rawparentid);
            if shadowEvents(i).channelind == -1 && ~isempty(VI.chancorr{shadowev_rawparentpos, viewrawparentpos})
                shdevg_tstarti  = [shadowEvents(i).tpos];
                shdevg_tstarti (shdevg_tstarti<ctimet-0.5*obstimet) = ctimet-0.5*obstimet;
                shdevg_tendi    = [shadowEvents(i).tpos]+[shadowEvents(i).duration];
                shdevg_tendi   (shdevg_tendi>ctimet+0.5*obstimet)   = ctimet+0.5*obstimet;

                edgecolor       = fastif (seleventid==shadowEvents(i).id, vi_graphics('eventseledgecolor'),'None');

                fill ([shdevg_tstarti(:),shdevg_tendi(:),shdevg_tendi(:),shdevg_tstarti(:)],[ylims(2),ylims(2),ylims(1),ylims(1)],...
                    shadowEvents(i).color,'EdgeColor',edgecolor,'FaceAlpha',vi_graphics('eventalphavalshadow'));

            else
                viewrawparentpos    = find([ALLSIG.id]==viewrawparentid);
                if isempty(shadowev_rawparentpos) || isempty(viewrawparentpos)
                    continue;
                elseif isempty(VI.chancorr{shadowev_rawparentpos,viewrawparentpos})
                    continue;
                end
                chancorri = VI.chancorr{shadowev_rawparentpos,viewrawparentpos}(shadowEvents(i).channelind,:); 
                % If shadow event, there are some corresponding channels
                if chancorri(1)~=0      
                    if ismember(chansel,chancorri(1):chancorri(2))==0; continue; end;
                    shdevc_tstarti  = [shadowEvents(i).tpos];
                    shdevc_tstarti (shdevc_tstarti<ctimet-0.5*obstimet) = ctimet-0.5*obstimet;
                    shdevc_tendi    = [shadowEvents(i).tpos]+[shadowEvents(i).duration];
                    shdevc_tendi   (shdevc_tendi>ctimet+0.5*obstimet)   = ctimet+0.5*obstimet;

                    yall                = spacingvect(ismember(chansel,chancorri(1):chancorri(2)));
                    ystart              = yall(1)-spacingev;
                    yend                = yall(end)+spacingev;

                    edgecolor           = fastif (seleventid==shadowEvents(i).id, vi_graphics('eventseledgecolor'),'None');

                    fill ([shdevc_tstarti(:),shdevc_tendi(:),shdevc_tendi(:),shdevc_tstarti(:)],-[ystart,ystart,yend,yend],...
                        shadowEvents(i).color,'EdgeColor',edgecolor,'FaceAlpha',vi_graphics('eventalphavalshadow'));
                end
            end
        end
    end
end


%- Color
% set(gca,'color',vi_graphics('axisbackcolor'),'YColor',vi_graphics('channeltextcolor'),'XColor',vi_graphics('plotxcolor'));
end


function [] = plotglobalevents(events, eventStarts, eventEnds)
    eventColors         = reshape([events.color],3,length(events))';
    eventUniqueColors   = unique(eventColors,'rows');
    nColors             = size(eventUniqueColors,1);
    ylims               = ylim;
    for evCol=1:nColors
        evColi      = eventUniqueColors(evCol,:);
        eventSelCol = ismember(eventColors,evColi,'rows');
        fill ([eventStarts(eventSelCol)',eventEnds(eventSelCol)',eventEnds(eventSelCol)',eventStarts(eventSelCol)']',[ylims(2),ylims(2),ylims(1),ylims(1)],...
            evColi,'EdgeColor','None','FaceAlpha',vi_graphics('eventalphaval'));
    end
end

function [] = plotchannelevents(events, eventStarts, eventEnds, ymed, spacingev)
    ymed = ymed(:);
    eventColors         = reshape([events.color],3,length(events))';
    eventUniqueColors   = unique(eventColors,'rows');
    nColors             = size(eventUniqueColors,1);
    for evCol=1:nColors
        evColi      = eventUniqueColors(evCol,:);
        eventSelCol = ismember(eventColors,evColi,'rows');
        fill ([eventStarts(eventSelCol),eventEnds(eventSelCol),eventEnds(eventSelCol),eventStarts(eventSelCol)]',...
            -[ymed(eventSelCol)+spacingev,ymed(eventSelCol)+spacingev,ymed(eventSelCol)-spacingev,ymed(eventSelCol)-spacingev]',...
            evColi,'EdgeColor','None','FaceAlpha',vi_graphics('eventalphaval'));
    end
end

