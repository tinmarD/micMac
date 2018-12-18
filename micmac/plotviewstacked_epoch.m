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
% Plot channel names (yticklabels)
set (gca, 'YTick', -flipdim(spacingvect,1),'YTickLabel',Sig.channamesnoeeg(fliplr(chansel)),'YColor',vi_graphics('plotchannelcolor'))
set (gca, 'XColor', vi_graphics('xtickcolor'));
set (gca, 'Color', vi_graphics('plotbackgroundcolor'), 'Fontsize', 8);


% Epoch-specific
% Plot one horizontal bar per epoch at the bottom of the graph 
ylims       = ylim;
axis_min = ylims(1);
first_ytick = min(get(gca,'ytick'));
epoch_duration = Sig.npnts/Sig.ntrials/Sig.srate;
epoch_start_num = max(1,floor(tvect(1) / epoch_duration));
epoch_end_num = min(Sig.ntrials,ceil(tvect(end) / epoch_duration));
y_epoch = axis_min+0.1*(first_ytick-axis_min);
y_epoch_height = 0.1*(first_ytick-axis_min);
y_offsets = [0,y_epoch_height];
Events_epoch = getevents(VI, 'sigdesc', Sig.desc);
t_start = zeros(1,epoch_end_num-epoch_start_num);
t_end = zeros(1,epoch_end_num-epoch_start_num);
t_zero = zeros(1,epoch_end_num-epoch_start_num);
epoch_time_pre = abs(Sig.tmin);
for i = epoch_start_num:epoch_end_num
    t_start(i) = max(tvect(1),(i-1)*epoch_duration);
    t_end(i) = min(tvect(end),i*epoch_duration);
    if t_end(i)<t_start(i); continue; end;
    y_start = y_epoch+y_offsets(1+mod(i,2));
    y_end = y_epoch+y_offsets(1+mod(i,2))+y_epoch_height;
    fill([t_start(i),t_end(i),t_end(i),t_start(i)],[y_start,y_start,y_end,y_end],'c');
    if (t_end(i)-t_start(i)) > 0.5*epoch_duration
        text(t_start(i)+0.4*(t_end(i)-t_start(i)),y_start+0.5*(y_end-y_start),Events_epoch(i).type);
    end
    t_zero(i) = t_start(i)+epoch_time_pre;
end

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

% Grid - if multiples epoch are visible, display one vertical line at the
% start and end and 0 time of each epoch
if obstimet > 3*epoch_duration
    set(gca, 'xtick', unique([t_end,t_start]));
    plot([t_zero;t_zero],ylim,'color','c','linestyle',':');
else
    set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
end
xticks = get(gca,'xtick');
plot([xticks;xticks],ylim,'color',vi_graphics('ygridcolor'),'linestyle',':');


%- Display the name (description) of the signal at the top
textinter = get(0,'defaulttextinterpreter');
set (0,'defaulttextinterpreter','none');
set (gca, 'Units', 'pixels');
axespospx = get (gca, 'Position');
text (10,axespospx(4)-10, Sig.desc, 'units','pixels',...
    'fontangle','italic','fontsize',8);
set (0,'defaulttextinterpreter',textinter);


