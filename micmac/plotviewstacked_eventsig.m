function [] = plotviewstacked_eventsig (VI, ALLWIN, ALLSIG, View, winnb, ctimet, obstimet, chansel, axes_h)
% [] = PLOTVIEWSTACKED_EVENTSIG (VI, ALLWIN, ALLSIG, View, winnb, ...
%                               ctimet, obstimet, chansel, axes_h)
%   Equivalent of PLOTVIEWSTACKED for event signals.
%   Can only be visualized in the time domain. Events are not displayed.
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

gSpace = 0.8;

if isempty(chansel); 
    child = allchild(gca);
    delete (child);
    set (gca,'xticklabel',{},'ytick',[]);
    return; 
end

child = allchild(gca);
delete (child);

% Get the signal from the view sigid
Sig     = getsignal (ALLSIG, 'sigid', View.sigid);

%- Select events that occurs in the current time/channel window
timeCol     = Sig.data(:,1);
chanCol     = Sig.data(:,2);
sigEventSel = Sig.data(timeCol>(ctimet-0.5*obstimet) & timeCol<(ctimet+0.5*obstimet) ...
    & ismember(chanCol,chansel),:);
tvect  = repmat([ctimet-0.5*obstimet,sigEventSel(:,1)',ctimet+0.5*obstimet],2,1);
data   = -[NaN,sigEventSel(:,2)'-gSpace*0.5,NaN;NaN,sigEventSel(:,2)'+gSpace*0.5,NaN];
    
%---- Plot stuff -----
ytick       = -fliplr(min(chansel):max(chansel));
% Plot x-grid (on the background) (horizontal lines)
hold on;
plot([tvect(1),tvect(end)],[ytick;ytick],'color',vi_graphics('xgridcolor'));
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
        colPos          = rem(elPosSelUnique(i),nCouleurs);
        if colPos==0; colPos=nCouleurs; end;
        channelPos_i    = find(electrodePos==elPosSelUnique(i));
        sigEventSel_i   = sigEventSel(ismember(sigEventSel(:,2),channelPos_i),:);
        tvect           = repmat([ctimet-0.5*obstimet,sigEventSel_i(:,1)',ctimet+0.5*obstimet],2,1);
        data            = -[NaN,sigEventSel_i(:,2)'-gSpace*0.5,NaN;NaN,sigEventSel_i(:,2)'+gSpace*0.5,NaN];
        plot(tvect,data,'color',couleurs(colPos,:));
    end
end
axis tight;
axis ([xlim,min(ytick)-0.8,max(ytick+0.8)]);
% Plot y-grid (vertical lines)
xticks = get(gca,'xtick');
plot([xticks;xticks],ylim,'color',vi_graphics('ygridcolor'),'linestyle',':');
% Plot channel names (yticklabels)
set (gca, 'YTick', ytick ,'YTickLabel',Sig.channamesnoeeg(fliplr(chansel)),'YColor',vi_graphics('plotchannelcolor'))
set (gca, 'XColor', vi_graphics('xtickcolor'));
set (gca, 'Color', vi_graphics('plotbackgroundcolor'), 'Fontsize', 8);

%- Display the name (description) of the signal at the top
textinter = get(0,'defaulttextinterpreter');
set (0,'defaulttextinterpreter','none');
set (gca, 'Units', 'pixels');
axespospx = get (gca, 'Position');
text (10,axespospx(4)-10, Sig.desc, 'units','pixels',...
    'fontangle','italic','fontsize',8);
set (0,'defaulttextinterpreter',textinter);

end

