function [chancorr, chancorrinv] = pop_chancorr (VI, ALLSIG, sigpos1, sigpos2)
% [] = pop_chancorr (VI, ALLWIN, ALLSIG, sigpos1, sigpos2)

Sig1 = ALLSIG(sigpos1);
Sig2 = ALLSIG(sigpos2);

chancorr    = VI.chancorr{sigpos1,sigpos2};
chancorrinv = VI.chancorr{sigpos2,sigpos1};
if isempty(chancorr);       chancorr=zeros(Sig1.nchan,2); end;
if isempty(chancorrinv);    chancorrinv=zeros(Sig2.nchan,2); end;

figw = 430; figh = 630;       
h = figure ('visible','off','DockControls','off','units','pixel','position',[200,200,figw,figh],...
            'MenuBar','none','Name','Channel correspondency','NumberTitle','off',...
            'Resize','on','color',vi_graphics('backgroundcolor'),'tag','popchancorr');

setappdata (h,'chancorr', chancorr);
setappdata (h,'chancorrinv', chancorrinv);

uicontrol (h,'style','text','string',Sig1.desc,'units','normalized','position',[0.1,0.91,0.3,0.07],...
    'backgroundcolor',vi_graphics('backgroundcolor'),'foregroundColor',vi_graphics('textcolor'));
uicontrol (h,'style','text','string',Sig2.desc,'units','normalized','position',[0.6,0.91,0.3,0.07],...
    'backgroundcolor',vi_graphics('backgroundcolor'),'foregroundColor',vi_graphics('textcolor'));


channames1 = cellfun(@(x)['<HTML><BODY color=rgb(0,0,0)>',x],Sig1.channames,'UniformOutput',false);
channames2 = cellfun(@(x)['<HTML><BODY color=rgb(0,0,0)>',x],Sig2.channames,'UniformOutput',false);   

%- Color the channels based on the current channel correspondency (if it exists)
[channames1, channames2, nlink] = colorchannels (VI, sigpos1, sigpos2, channames1, channames2);

setappdata (h,'linkinc',nlink+1);

uicontrol (h,'style','listbox','units','normalized','position',[0.02,0.2,0.45,0.7],...
    'string',channames1,'max',1000,'tag','lb1','fontsize',8);
uicontrol (h,'style','listbox','units','normalized','position',[0.55,0.2,0.45,0.7],...
    'string',channames2,'max',1000,'tag','lb2','fontsize',8);

uicontrol (h,'style','pushbutton','string','Link','units','normalized','position',[0.4,0.12,0.2,0.04],...
    'callback',@linkchannels);
uicontrol (h,'style','pushbutton','string','Reset','units','normalized','position',[0.1,0.12,0.2,0.04],...
    'callback',@resetchancorr);
uicontrol (h,'style','pushbutton','string','Unlink','units','normalized','position',[0.7,0.12,0.2,0.04],...
    'callback',@unlinkchannels);


cb_ok = 'set(gcbo, ''userdata'', ''retuninginputui'');';

uicontrol (h,'style','pushbutton','string','Cancel' ,'units','normalized','position',[0.6,0.01,0.15,0.05],...
    'Callback','delete(gcbf)');
uicontrol (h,'style','pushbutton','string','Ok','units','normalized','position',[0.78,0.01,0.15,0.05],...
    'Callback',cb_ok,'tag','ok');

set(h,'visible','on');

waitfor(findobj('parent', h, 'tag', 'ok'), 'userdata');

try findobj(h); % figure still exist ?
catch, return; end;

chancorr    = getappdata (h,'chancorr');
chancorrinv = getappdata (h,'chancorrinv');

delete(h);

end

function [channames1, channames2, nlink] = colorchannels (VI, sigpos1, sigpos2, channames1, channames2)
%- If the channel correspondency exist between sig1 (sigpos1) and sig2
%- (sigpos2), color the correponding channels to visualize the correpondency

nlink    = 0;
chancorr = VI.chancorr{sigpos1,sigpos2};
if isempty(chancorr) || sigpos1==sigpos2
    return;
end

couleurs    = vi_graphics('chancorrcolors');
pos         = 1;
nlink       = 1;
couleur     = round(255*couleurs(pos,:));
lastc2corr      = 0;
for c1=1:length(channames1)
    if chancorr(c1,1)~=0
        %- Set the couleur
        if lastc2corr~=0 && lastc2corr~=chancorr(c1,1)
            pos         = rem(pos+1,length(couleurs));
            if pos==0; pos=length(couleurs); end;
            couleur     = round(255*couleurs(pos,:));
            nlink       = nlink+1;
        end
        lastc2corr = chancorr(c1,1);
        %- Modify the channels name color
        channames1{c1} = strrep(channames1{c1},channames1{c1}(23:regexp(channames1{c1},')')-1),...
            sprintf('%d,%d,%d',couleur(1),couleur(2),couleur(3)));
        for c2=chancorr(c1,1):chancorr(c1,2)
            channames2{c2} = strrep(channames2{c2},channames2{c2}(23:regexp(channames2{c2},')')-1),...
                sprintf('%d,%d,%d',couleur(1),couleur(2),couleur(3)));
        end
    end
end


end

function [] = linkchannels(~,~)
%- Get the current selection on both listbox and color the names of the
%- channels to visualize the link. Also modify chancorr and chancorrinv

lb1 = findobj(gcbf,'tag','lb1');
lb2 = findobj(gcbf,'tag','lb2');

channames1  = get(lb1,'string');
channames2  = get(lb2,'string');
sel1        = get(lb1,'value');
sel2        = get(lb2,'value');

%- Update chancorr and chancorrinv
chancorr                = getappdata (gcbf,'chancorr');
chancorrinv             = getappdata (gcbf,'chancorrinv');
chancorr (sel1,:)       = repmat ([sel2(1),sel2(end)],length(sel1),1);
chancorrinv (sel2,:)    = repmat ([sel1(1),sel1(end)],length(sel2),1);
setappdata (gcbf,'chancorr', chancorr);
setappdata (gcbf,'chancorrinv', chancorrinv);

%- Visualize the link - Color the correponding channels
%- Get the right color
couleurs    = vi_graphics('chancorrcolors');
linkinc     = getappdata(gcbf,'linkinc');
pos         = rem(linkinc,length(couleurs));
if pos==0; pos=length(couleurs); end;
couleur     = round(255*couleurs(pos,:));


%- Change the color of selected text
for c=sel1
    channames1{c} = strrep(channames1{c},channames1{c}(23:regexp(channames1{c},')')-1),...
        sprintf('%d,%d,%d',couleur(1),couleur(2),couleur(3)));
end
for c=sel2
    channames2{c} = strrep(channames2{c},channames2{c}(23:regexp(channames2{c},')')-1),...
        sprintf('%d,%d,%d',couleur(1),couleur(2),couleur(3)));
end
set(lb1,'string',channames1);
set(lb2,'string',channames2);

setappdata (gcbf,'linkinc',linkinc+1);

end


function [] = resetchancorr(~,~)

%- Reset parameters
setappdata (gcbf,'linkinc',1);
chancorr     = getappdata (gcbf,'chancorr');
chancorrinv  = getappdata (gcbf,'chancorrinv');
setappdata (gcbf,'chancorr', zeros(size(chancorr)));
setappdata (gcbf,'chancorrinv', zeros(size(chancorrinv)));

lb1 = findobj(gcbf,'tag','lb1');
lb2 = findobj(gcbf,'tag','lb2');
channames1  = get(lb1,'string');
channames2  = get(lb2,'string');
%- Color all channels in black
for c=1:length(channames1)
    channames1{c} = strrep(channames1{c},channames1{c}(23:regexp(channames1{c},')')-1),...
        '0,0,0');
end
for c=1:length(channames2)
    channames2{c} = strrep(channames2{c},channames2{c}(23:regexp(channames2{c},')')-1),...
        '0,0,0');
end
set(lb1,'string',channames1);
set(lb2,'string',channames2);

end


function [] = unlinkchannels(~,~)

lb1 = findobj(gcbf,'tag','lb1');
lb2 = findobj(gcbf,'tag','lb2');
channames1  = get(lb1,'string');
channames2  = get(lb2,'string');
sel1        = get(lb1,'value');
sel2        = get(lb2,'value');

chancorr                = getappdata (gcbf,'chancorr');
chancorrinv             = getappdata (gcbf,'chancorrinv');
chancorr (sel1,:)       = repmat ([0,0],length(sel1),1);
chancorrinv (sel2,:)    = repmat ([0,0],length(sel2),1);
setappdata (gcbf,'chancorr', chancorr);
setappdata (gcbf,'chancorrinv', chancorrinv);


% Change the color of selected text
for c=sel1
    channames1{c} = strrep(channames1{c},channames1{c}(23:regexp(channames1{c},')')-1),...
        '0,0,0');
end
for c=sel2
    channames2{c} = strrep(channames2{c},channames2{c}(23:regexp(channames2{c},')')-1),...
        '0,0,0');
end
set(lb1,'string',channames1);
set(lb2,'string',channames2);

end