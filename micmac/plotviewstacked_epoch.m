function [] = plotviewstacked_epoch (VI, ALLWIN, ALLSIG, View, winnb, ctimet, obstimet, chansel, axes_h)
% [] = PLOTVIEWSTACKED_EPOCH (VI, ALLWIN, ALLSIG, View, winnb, ...
%                               ctimet, obstimet, chansel, axes_h)
%   Equivalent of PLOTVIEWSTACKED for epoched signals.
%
% INPUTS : 
%   - VI, ALLWIN, ALLSIG    : micMac structures
%   - View                  : View structure
%   - winnb                 : window number
%   - ctimet                : window's central time (s)
%   - obstimet              : window's duration (s)
%   - chansel               : vector of selected channels
%   - axes_h                : handle to the axis object
%
% See also : plotviewstacked, plotviewspaced_eventsig

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
tvect   = (tind-1)/Sig.srate;

% Modify data to be plot in one axes
data    = Sig.data (chansel,:);           % Select channels
data    = data.*(-1+exp(View.gain(visumodepos)));
% data    = shiftdim(data,1);  % Shift dimensions from [n_trials, n_chan, n_pnts] to [n_chan, n_pnts, n_trials]
% data_2d = data(:,:);
data_2d = data(:, tind);
data_2d = data_2d - repmat (mean(data_2d,2),1,length(tind));       % Substract mean (For epoch should subtract mean of each epoch or dont do anything)
data_2d = data_2d - repmat(spacingvect,1,size(data_2d,2));         % Add a spacing between each signal

%---- Plot stuff -----
% Plot x-grid (on the background) (horizontal lines)
hold on;
plot([tvect(1),tvect(end)],-[spacingvect,spacingvect]','color',vi_graphics('xgridcolor'));
% Plot eeg data
if ~isequal(View.couleur,'rainbow')
    plot(tvect, data_2d,'color',View.couleur);
else
    electrodePos    = getelectrodepos(Sig);
    electrodePosSel = electrodePos(chansel);
    elPosSelUnique  = unique(electrodePosSel);
    couleurs        = vi_graphics('plotcolors');
    nCouleurs       = size(couleurs,1);
    for i = 1:length(elPosSelUnique)
        colPos  = rem(elPosSelUnique(i),nCouleurs);
        if colPos==0; colPos=nCouleurs; end;
        plot(tvect,data_2d(electrodePosSel==elPosSelUnique(i),:),'color',couleurs(colPos,:));
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