function [chanselPos] = pop_channelselect(Sig,onlyEeg,removeBadChannels,chanselPos)
%[chansel] = POP_CHANNELSELECT (Sig,onlyEEG,removeBadChannels,chanselPos)
% Popup window to select channels
%
% INPUTS :
%   - Sig                   : Signal structure
%   - onlyEeg               : If 1, display only the eeg channels
%   - removeBadChannels     : If 1, remove the bad channels
%   - chanselPos            : Vector of previously selected channels
%
% OUTPUT : 
%   - chanselPos            : Selected channel positions

%- Get starting channels position 
if onlyEeg
    chanallpos = find(Sig.eegchannelind==1);
else
    chanallpos = 1:Sig.nchan;
end
if removeBadChannels
    chanallpos(ismember(chanallpos,Sig.badchannelpos)) = [];
end


figw = 430; figh = 630;       
h = figure ('visible','off','DockControls','off','units','pixel','position',[200,200,figw,figh],...
            'MenuBar','none','Name','Channel Selection','NumberTitle','off',...
            'Resize','on','color',vi_graphics('backgroundcolor'),'tag','popchancorr');

setappdata (h,'chansel', []);

uicontrol (h,'style','text','string',Sig.desc,'units','normalized','position',[0.3,0.93,0.4,0.05],...
    'backgroundcolor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('signalnamecolor'));

channames = cellfun(@(x)['<HTML><BODY color=rgb(0,0,0)>',x],Sig.channames(chanallpos),'UniformOutput',false);

if ~isempty(chanselPos)
    channamesel = cellfun(@(x)['<HTML><BODY color=rgb(0,0,0)>',x],Sig.channames(chanselPos),'UniformOutput',false);
    selInd      = ismember(channames,channamesel);
    channames(selInd) = cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(203,75,22)>'),channames(selInd),'UniformOutput',0);
else
    channamesel = '';
end

%- Listboxes and labels
uicontrol (h,'style','listbox','units','normalized','position',[0.02,0.2,0.45,0.7],'string',channames,'max',1000,'tag','lbAll','fontsize',8);
uicontrol (h,'style','listbox','units','normalized','position',[0.55,0.2,0.45,0.7],'string',channamesel,'max',1000,'tag','lbSel','fontsize',8);
uicontrol (h,'style','text','units','normalized','position',[0.02,0.91,0.45,0.02],'string','All channels','fontsize',8,'backgroundcolor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('textcolor'));
uicontrol (h,'style','text','units','normalized','position',[0.55,0.91,0.45,0.02],'string','Selected channels','fontsize',8,'backgroundcolor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('textcolor'));

%- Selection buttons
uicontrol (h,'style','pushbutton','string','All','units','normalized','position',[0.06,0.12,0.15,0.04],'callback',@selectall);
uicontrol (h,'style','pushbutton','string','Select','units','normalized','position',[0.27,0.12,0.2,0.04],'callback',@select);
uicontrol (h,'style','pushbutton','string','Remove','units','normalized','position',[0.53,0.12,0.2,0.04],'callback',@remove);
uicontrol (h,'style','pushbutton','string','Reset','units','normalized','position',[0.79,0.12,0.15,0.04],'callback',@reset);

cb_ok = 'set(gcbo, ''userdata'', ''retuninginputui'');';
uicontrol (h,'style','pushbutton','string','Cancel' ,'units','normalized','position',[0.6,0.01,0.15,0.05],...
    'Callback','delete(gcbf)');
uicontrol (h,'style','pushbutton','string','Ok','units','normalized','position',[0.78,0.01,0.15,0.05],...
    'Callback',cb_ok,'tag','ok');


set(h,'visible','on');

waitfor(findobj('parent', h, 'tag', 'ok'), 'userdata');
try findobj(h); % figure still exist ?
catch, return; end;

channamesel = get (findobj(h,'tag','lbSel'),'string');
%- delete HTML formatting
if ~isempty(channamesel)
    channamesel = cellfun(@(x)regexprep(x,'<.+>',''),channamesel,'UniformOutput',0);
    chanselPos  = find(ismember(Sig.channames,channamesel)==1);
else
    chanselPos  = [];
end

delete(h);

end


function [] = select(~,~)
lbAll           = findobj(gcbf,'tag','lbAll');
lbSel           = findobj(gcbf,'tag','lbSel');

channamesAll    = get(lbAll,'string');
channamesSel    = get(lbSel,'string');
sel             = get(lbAll,'value');

[channamesSel]  = union(channamesSel,channamesAll(sel),'stable');
channamesSel(ismember(channamesSel,'')) = [];
allTemp         = cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(0,0,0)>'),channamesAll,'UniformOutput',0);
channamesSel    = allTemp(ismember(allTemp,channamesSel)); % To get the correct order


%- Color the selected channel in the left panel
channamesAll(sel)   = ...
    cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(203,75,22)>'),channamesAll(sel),'UniformOutput',0);
channamesSel        = ...
    cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(0,0,0)>'),channamesSel,'UniformOutput',0);

channamesSel    = unique(channamesSel,'stable');
set(lbAll,'string',channamesAll);
set(lbSel,'value',1);
set(lbSel,'string',channamesSel);

end

function [] = remove(~,~)
lbSel           = findobj(gcbf,'tag','lbSel');
lbAll           = findobj(gcbf,'tag','lbAll');

channamesSel    = get(lbSel,'string');
channamesAll    = get(lbAll,'string');
if isempty(channamesSel); return; end;
removeSel      	= get(lbSel,'value');

%- Color the selected channel in the left panel
allTemp         = cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(0,0,0)>'),channamesAll,'UniformOutput',0);
sel             = ismember(allTemp,channamesSel(removeSel));
channamesAll(sel) = ...
    cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(0,0,0)>'),channamesAll(sel),'UniformOutput',0);


channamesSel    = setdiff(channamesSel,channamesSel(removeSel),'stable');

set(lbAll,'string',channamesAll);
set(lbSel,'value',1);
set(lbSel,'string',channamesSel);
%- Update chancorr and chancorrinv
% chansel      	= getappdata (gcbf,'chansel');

end


function [] = selectall(~,~)
%- Set chansel to chanall
lbAll           = findobj(gcbf,'tag','lbAll');
lbSel           = findobj(gcbf,'tag','lbSel');
channamesAll    = get(lbAll,'string');
channamesSel    = channamesAll;

%- Color the selected channel in the left panel
channamesAll    = ...
    cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(203,75,22)>'),channamesAll,'UniformOutput',0);
channamesSel    = ...
    cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(0,0,0)>'),channamesSel,'UniformOutput',0);

set(lbSel,'string',channamesSel);
set(lbAll,'string',channamesAll);

end

function [] = reset(~,~)
%- Set chansel to empty vector
lbSel           = findobj(gcbf,'tag','lbSel');
set(lbSel,'string','');

%- Uncolor all chanenls
lbAll           = findobj(gcbf,'tag','lbAll');
channamesAll    = get(lbAll,'string');
channamesAll    = ...
    cellfun(@(x)regexprep(x,'rgb(.+)>','rgb(0,0,0)>'),channamesAll,'UniformOutput',0);
set(lbAll,'string',channamesAll);
end



