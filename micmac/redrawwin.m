function ALLWIN = redrawwin(VI, ALLWIN, ALLSIG, winnb)
% [ALLWIN] = redrawwin (VI, ALLWIN, ALLSIG)
% [ALLWIN] = redrawwin (..., winnb)
% Redraw the window 

if nargin==3
    winnb=find(cat(1,ALLWIN.figh)==gcbf);
end
Win=ALLWIN(winnb);

axFocusNum = [];
if ~isempty(Win.axfocus)
    axFocusNum  = find(Win.axlist==Win.axfocus);
    if Win.visumode==1 && sum(strcmp({Win.views.domain},'t'))==0
        axFocusNum = [];
    end
end

% Delete all the uicontextmenu (If not they will add up) (Used for left-click
% menu)
delete (findobj(ALLWIN(winnb).figh,'type','uicontextmenu'));
 
try
    dispinfo('');
end

if isempty(Win.views)
    set (findobj(ALLWIN(winnb).figh,'Style','edit','tag','obswintedit'),'String','');
    set (findobj(ALLWIN(winnb).figh,'Style','edit','tag','ctimetedit'), 'String','');
    set (findobj(ALLWIN(winnb).figh,'Style','listbox','tag','chansellb'),'String','');
    return; 
end
figure (Win.figh);
figpos = get(Win.figh,'Position');
switch Win.visumode
    
    case 1 % "Stacked Mode" - Plot all view one after the other
        % In this mode, don't plot the time-frequency representations
        stackedviewsind = nonzeros(strcmp({Win.views.domain},'t').*(1:length(Win.views)));
        if sum(stackedviewsind)==0
            ax = [];
        else
            ax = zeros(1,length(sum(stackedviewsind)));
        end
        %- If for ex. there is only a tf view, delete it in the stacked mode
        if isempty(stackedviewsind) && ~isempty(Win.views)
            delete(Win.axlist);
            ALLWIN(winnb).axlist    = [];
            ALLWIN(winnb).axfocus   = [];
        end
        for v=1:length(stackedviewsind)
            if v==1 && isempty(ALLWIN(1).syncchanselwin==winnb); 
                chansel=Win.chansel;
            else
                chansel=getcorrchannels (VI,ALLWIN, ALLSIG, winnb, stackedviewsind(v));
            end
            
            %- remove bad channels from chansel
            Sig     = getsigfromid(ALLSIG, ALLWIN(winnb).views(v).sigid);
            chansel (ismember(chansel,Sig.badchannelpos)) = [];
            
            ax(v)   = subaxis(length(stackedviewsind),1,v,'MarginBottom',70/figpos(4),'MarginTop',10/figpos(4),...
            	'MarginLeft',170/figpos(3),'MarginRight',10/figpos(3),'Spacing',0.04);
            set (ax(v),'uicontextmenu',createaxiscontextmenu(Win,v));
            if strcmp(Sig.type,'continuous')
                plotviewstacked (VI, ALLWIN, ALLSIG, Win.views(stackedviewsind(v)), winnb, Win.ctimet, Win.obstimet, chansel, ax(v));
            elseif strcmp(Sig.type,'eventSig')
                plotviewstacked_eventsig (VI, ALLWIN, ALLSIG, Win.views(stackedviewsind(v)), winnb, Win.ctimet, Win.obstimet, chansel, ax(v));
            elseif strcmp(Sig.type,'epoch')
                plotviewstacked_epoch (VI, ALLWIN, ALLSIG, Win.views(stackedviewsind(v)), winnb, Win.ctimet, Win.obstimet, chansel, ax(v));
            end
            set(allchild(gca),'hittest','off');    
            % Cursor 1
            cb_setfocus = ...
                ['winnb=find(cat(1,ALLWIN.figh)==gcf);',...
                'if ~isempty(winnb); ALLWIN(winnb).axfocus=gca;',...
                'viewind = find (ALLWIN(winnb).axlist==gca);',...
                'gainVal = ALLWIN(winnb).views(viewind).gain(1);',...
                '[~,ampscalestr] = getampscalefromgain(gainVal, 1, []);',...
                'set(findobj(winnb,''tag'',''gainedit''),''String'',ampscalestr);',...
                'end;'];
            if VI.cursor.type == 1
                set (ax(v),'ButtonDownFcn',[cb_setfocus,'VI = cursorcb(VI, ALLWIN);']);
            else
                set (ax(v),'ButtonDownFcn',cb_setfocus);
            end
        end
        
    case 2 % "Spaced Mode"
        %- remove bad channels from chansel
        Sig     = getsigfromid(ALLSIG, ALLWIN(winnb).views(1).sigid);
        chansel = Win.chansel;
        chansel (ismember(chansel,Sig.badchannelpos)) = [];
        nchan   = length(chansel);
        nviews  = length(Win.views);
        %- Check that the maximal number of axis is not exceeded
        if nchan*nviews>vi_defaultval('max_spaced_axis')
            nchan   	= floor(vi_defaultval('max_spaced_axis')/nviews);
            chansel     = chansel(1:nchan);
            dispinfo(['Cannot display more than ',num2str(vi_defaultval('max_spaced_axis')),' axis in spaced mode']);   
        end
        nsubplot= nchan*nviews;
        ax      = zeros(1,nsubplot);

        
        for c=1:nchan
            for v=1:nviews
                Sig_v = getsigfromid(ALLSIG, ALLWIN(winnb).views(v).sigid);
                if v==1 && isempty(ALLWIN(1).syncchanselwin==winnb); 
                    chanselc = chansel(c);
                else
                    chanselc = getcorrchannels (VI,ALLWIN, ALLSIG, winnb, v, chansel(c));
                    if length(chanselc)>1; chanselc=chanselc(1); end;
                end
                
                subplotind = (c-1)*nviews+v;
                spacing = 0.015;
                if v==1;            paddingtop = 0.02;  paddingbottom=0;        end
                if v==nviews;       paddingtop = 0;     paddingbottom=0.02;     end     
                if v>1 && v <nviews;paddingtop = 0;     paddingbottom=0;        end
                
            	ax(subplotind) = subaxis(nsubplot,1,subplotind,'MarginBottom',70/figpos(4),'MarginTop',20/figpos(4),...
                    'MarginLeft',140/figpos(3),'MarginRight',10/figpos(3),'Spacing',spacing,'PaddingTop',paddingtop,...
                    'PaddingBottom',paddingbottom);
                set (ax(subplotind),'uicontextmenu',createaxiscontextmenu(Win,v));
                child = allchild(gca); delete (child);
                if ~isempty(chanselc)
                    if strcmp(Sig_v.type,'continuous')
                        plotviewspaced (VI, ALLSIG, Win, Win.ctimet, Win.obstimet, chanselc, Win.views(v).couleur, v);
                    elseif strcmp(Sig_v.type,'eventSig')
                        plotviewspaced_eventsig (VI, ALLSIG, Win, Win.ctimet, Win.obstimet, chanselc, Win.views(v).couleur, v);
                    end
                end
                set(allchild(ax(subplotind)),'hittest','off');
                
                % Update scale value in Gain panel (in case the window has been resized, it would modified the scale for time view)
                if ~isempty(Win.viewfocus) && Win.viewfocus==v && c==1
                    gain = Win.views(v).gain(2);
                    [~,ampScaleStr] = getampscalefromgain(gain, 2, ax(subplotind));
                    set(findobj(winnb,'tag','gainedit'),'String',ampScaleStr);
                end
                    
                
                % Cursor 1
                cb_setfocus = ...
                    ['winnb=find(cat(1,ALLWIN.figh)==gcf);',...
                    'if ~isempty(winnb); ALLWIN(winnb).axfocus=gca;',...
                    'viewind = find (ALLWIN(winnb).axlist==gca);',...
                    'viewind = rem(viewind,length(ALLWIN(winnb).views));',...
                    'viewind = fastif(viewind==0,length(ALLWIN(winnb).views),viewind);',...
                    'gainVal = ALLWIN(winnb).views(viewind).gain(2);',...
                    '[~,ampscalestr] = getampscalefromgain(gainVal, 2, []);',...
                    'set(findobj(winnb,''tag'',''gainedit''),''String'',ampscalestr);',...
                    'end;'];
                if VI.cursor.type == 1
                    set (ax(subplotind),'ButtonDownFcn',[cb_setfocus,'VI = cursorcb(VI, ALLWIN);']);
                else
                    set (ax(subplotind),'ButtonDownFcn',cb_setfocus);
                end
            end
        end
end
%- Keep track of the handles of axis
ALLWIN(winnb).axlist = ax;

Siglead = getsigfromid(ALLSIG,Win.views(1).sigid);

%- Upadte the gui (TODO update the GUI only when a change has occured)
set (findobj(ALLWIN(winnb).figh,'Style','edit','tag','obswintedit'),'String',num2str(sprintf('%.1f',Win.obstimet)));
set (findobj(ALLWIN(winnb).figh,'Style','edit','tag','ctimetedit'), 'String',num2str(sprintf('%.2f',Win.ctimet)));
set (findobj(ALLWIN(winnb).figh,'Style','listbox','tag','chansellb'),'String',Siglead.channamesnoeeg,...
    'value',ALLWIN(winnb).chansel);
if ALLWIN(winnb).visumode==2 && nchan*nviews>vi_defaultval('max_spaced_axis')
    set (findobj(ALLWIN(winnb).figh,'Style','listbox','tag','chansellb'),'String',Siglead.channamesnoeeg,...
        'value',chansel);
end

%- Restore axis focus
if ~isempty(axFocusNum) && axFocusNum<=length(ALLWIN(winnb).axlist)
    ALLWIN(winnb).axfocus = ALLWIN(winnb).axlist(axFocusNum);
end

%- Redraw synchronized windows (if current figure is the main figure)
if winnb==1
    if ~isempty(ALLWIN(1).syncctimetwin)
        ALLWIN(ALLWIN(1).syncctimetwin).ctimet = ALLWIN(1).ctimet;
    end
    if ~isempty(ALLWIN(1).syncobstimetwin)
        ALLWIN (ALLWIN(1).syncobstimetwin).obstimet = ALLWIN(1).obstimet;
    end
    syncwin = unique([ALLWIN(1).syncctimetwin,ALLWIN(1).syncobstimetwin]);
    if isempty(syncwin); return; end;
    for wn = syncwin
        [ALLWIN] = redrawwin(VI, ALLWIN, ALLSIG, wn);
    end
    figure(ALLWIN(1).figh);
end


end


function c = createaxiscontextmenu (Win,axPos)

nViews  = length(Win.views);

c       = uicontextmenu ();
% %- Change view position
% viewposs = 1:nviews;
% if Win.visumode == 1 % stacked
%     viewposs (~strcmp({Win.views.domain},'t')) = [];
% end
% viewposs (viewposs==viewpos) = [];
nTemporalViews  = sum(strcmp({Win.views.domain},'t'));
trueViewPos     = 1:nViews;
if Win.visumode == 1 % stacked
    trueViewPos(~strcmp({Win.views.domain},'t')) = [];
    non_t_view_cumsum = cumsum(~strcmp({Win.views.domain},'t'));
    win_view_pos = axPos + non_t_view_cumsum(axPos);  % Position of the current view in the Win.views list - 08/11/2018
    trueViewPos(axPos)          = [];
    viewposs = 1:nTemporalViews;
    viewposs(viewposs==axPos)   = [];
else
    viewposs = 1:nViews;
    viewposs(viewposs==axPos)         = [];
    trueViewPos(trueViewPos==axPos)   = [];
    win_view_pos = axPos;
end


if ~isempty(viewposs)
    pos_m   = uimenu (c,'Label','Set Position');
    for i=1:length(viewposs)
        uimenu (pos_m,'Label',num2str(viewposs(i)),'Callback',...
            ['[VI ALLWIN ALLSIG] = pop_viewproperties (VI, ALLWIN, ALLSIG, 0, ',num2str(trueViewPos(i)),');']);
    end
end

%- Change color
if strcmp(Win.views(win_view_pos).domain,'t') || strcmp(Win.views(win_view_pos).domain,'f')
    cb_changecolor = ['couleur = uisetcolor();',...
        '[VI ALLWIN ALLSIG] = pop_viewproperties (VI, ALLWIN, ALLSIG, 0, -1, couleur);'];
    cb_rainbowcolor= '[VI ALLWIN ALLSIG] = pop_viewproperties (VI, ALLWIN, ALLSIG, 0, -1, ''rainbow'');';
    color_m = uimenu(c,'Label','Color');
    uimenu (color_m,'Label','Change Color','Callback',cb_changecolor);
    uimenu (color_m,'Label','Rainbow','Callback',cb_rainbowcolor);
elseif strcmp(Win.views(win_view_pos).domain,'tf') || strcmp(Win.views(win_view_pos).domain,'ph')
    %- Colormap
    colormap_m = uimenu (c,'Label','Colormap');
    uimenu(colormap_m,'Label','Viridis','Callback','colormap(''viridis'');VI.guiparam.colormap=''viridis'';');
    uimenu(colormap_m,'Label','Plasma','Callback','colormap(''plasma'');VI.guiparam.colormap=''plasma'';');
    uimenu(colormap_m,'Label','Inferno','Callback','colormap(''inferno'');VI.guiparam.colormap=''inferno'';');
    uimenu(colormap_m,'Label','Fake Parula','Callback','colormap(''fake_parula'');VI.guiparam.colormap=''fake_parula'';');
    uimenu(colormap_m,'Label','Jet','Callback','colormap(''Jet'');VI.guiparam.colormap=''Jet'';')
    uimenu(colormap_m,'Label','HSV','Callback','colormap(''HSV'');VI.guiparam.colormap=''HSV'';');
    uimenu(colormap_m,'Label','Hot','Callback','colormap(''Hot'');VI.guiparam.colormap=''Hot'';');
    uimenu(colormap_m,'Label','Cool','Callback','colormap(''Cool'');VI.guiparam.colormap=''Cool'';');
    uimenu(colormap_m,'Label','Spring','Callback','colormap(''Spring'');VI.guiparam.colormap=''Spring'';');
    uimenu(colormap_m,'Label','Summer','Callback','colormap(''Summer'');VI.guiparam.colormap=''Summer'';');
    uimenu(colormap_m,'Label','Autumn','Callback','colormap(''Autumn'');VI.guiparam.colormap=''Autumn'';');
    uimenu(colormap_m,'Label','Winter','Callback','colormap(''Winter'');VI.guiparam.colormap=''Winter'';');
    uimenu(colormap_m,'Label','Gray','Callback','colormap(''Gray'');VI.guiparam.colormap=''Gray'';');
    uimenu(colormap_m,'Label','Bone','Callback','colormap(''Bone'');VI.guiparam.colormap=''Bone'';');
    uimenu(colormap_m,'Label','Copper','Callback','colormap(''Copper'');VI.guiparam.colormap=''Copper'';');
    uimenu(colormap_m,'Label','Pink','Callback','colormap(''Pink'');VI.guiparam.colormap=''Pink'';');
    %- Normalization
    norm_m  = uimenu(c,'Label','Normalization');
    tfNormMethods   = vi_defaultval('tf_norm_method');
    for i=1:length(tfNormMethods)
        uimenu(norm_m,'Label',tfNormMethods{i},'Callback',['[VI ALLWIN ALLSIG] = pop_viewproperties (VI, ALLWIN, ALLSIG, 0, -1, -1,''',tfNormMethods{i},''');']);
    end
end
%- Delete view
uimenu (c,'Label','Delete View','Callback',...
    '[VI ALLWIN ALLSIG] = pop_viewproperties (VI, ALLWIN, ALLSIG, 1);');

end

