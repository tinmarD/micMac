function [] = plotviewspaced_eventsig (VI, ALLSIG, Win, ctimet, obstimet, chansel, couleur, viewind)
% [] = PLOTVIEWSPACED_EVENTSIG (VI, ALLSIG, Win, ctimet, obstimet, chansel, ...
%                               couleur, viewind)
%   Equivalent of PLOTVIEWSPACED for event signals.
%   Can only be visualized in the time domain. Events are not displayed
%
% See also: plotviewspaced, plotviewstacked_eventsig

gSpace      = 0.8;
lineWidth   = 1;

if ~isscalar(chansel); error('chansel input must be a scalar'); end;

View    = Win.views(viewind);
nviews  = length(Win.views);

% Get the signal from the view sigid
Sig     = getsignal(ALLSIG, 'sigid', View.sigid);

%- Select events that occurs in the current time/channel window
timeCol     = Sig.data(:,1);
chanCol     = Sig.data(:,2);
sigEventSel = Sig.data(timeCol>(ctimet-0.5*obstimet) & timeCol<(ctimet+0.5*obstimet) ...
    & ismember(chanCol,chansel),:);
tvect       = repmat(sigEventSel(:,1)',2,1);
data        = [ones(1,length(tvect))-gSpace*0.5;ones(1,length(tvect))+gSpace*0.5];

% Plot eeg data
grid off;
set (gca,'XTickMode','auto','XTickLabelMode', 'auto','YTickMode','auto','YTickLabelMode', 'auto');

if isequal(couleur,'rainbow')
    electrodePos    = getelectrodepos(Sig);
    couleurs        = vi_graphics('plotcolors');
    colPos          = rem(electrodePos(chansel),size(couleurs,1));
    couleur         = couleurs(colPos,:);
end
plot (tvect,data,'color',couleur,'linewidth',lineWidth); hold on;
axis tight; axis on; set(gca, 'Box','Off'); grid on;
xlim([ctimet-0.5*obstimet,ctimet+0.5*obstimet]);
ylim([0.5,1.5]);

set (gca,'Color',vi_graphics('plotbackgroundcolor'),'XColor',vi_graphics('xtickcolor'),'YColor',vi_graphics('ytickcolor'));

%- Display the name (description) of the view at the top
textinter = get(0,'defaulttextinterpreter');
set (0,'defaulttextinterpreter','none');
set (gca, 'Units', 'pixels');
axespospx = get (gca, 'Position');
couleur   = fastif (strcmp(View.domain,'tf'),[0.85,0.85,0],[0,0,0]);
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