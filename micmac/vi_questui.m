function answerPos = vi_questui(textString,figTitle,button1txt, button2txt)
% answerPos = VI_QUESTUI(question,title)
%   Create a popup window with a question with 2 buttons (by default Ok and 
%   Cancel). 
% 
% INPUTS :
%   - textString        : Message to display
%   - figTitle          : Title of the popup window
%   - button1txt        : Text of the first button  (by default: 'Ok')
%   - button2txt        : Text of the second button (by default: 'Cancel')
%
% OUTPUTS :
%   - answerPos         : position of the answer, 1 or 2, or emtpy if the
%                         window is closed


if nargin==2
    button1txt  = 'Ok';
    button2txt  = 'Cancel';
end
if nargin==3
    button2txt  = 'Cancel';
end

figw = 210; figh = 80;       
h = figure ('visible','off','DockControls','off','units','pixel','position',[200,200,figw,figh],...
    'MenuBar','none','Name',figTitle,'NumberTitle','off',...
	'Resize','off','color',vi_graphics('backgroundcolor'),'tag','popchancorr');


%- Question test
uicontrol (h,'style','text','string',textString,'units','normalized','position',[0.1,0.55,0.8,0.3],...
    'fontsize',11,'backgroundcolor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('textcolor'));

%- Button 1 (Ok)
cb_ok = 'set(gcbf, ''userdata'', ''1'');set(gcbo,''userdata'', ''retuninginputui'');';
uicontrol (h,'style','pushbutton','string',button1txt,'units','normalized','position',[0.125,0.15,0.3,0.3],...
    'fontsize',11,'Callback',cb_ok,'tag','ok');%,'backgroundcolor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('textcolor'));

%- Button 2 (Cancel)
cb_cancel = 'set(gcbf, ''userdata'', ''2'');set(findobj(gcbf,''tag'',''ok''),''userdata'',''retuninginputui'');';
uicontrol (h,'style','pushbutton','string',button2txt,'units','normalized','position',[0.575,0.15,0.3,0.3],...
    'fontsize',11,'Callback',cb_cancel,'tag','cancel');%,'backgroundcolor',vi_graphics('backgroundcolor'),'ForegroundColor',vi_graphics('textcolor'));

movegui(h,'center');
set(h,'visible','on');

waitfor(findobj('parent', h, 'tag', 'ok'), 'userdata');

answerPos = [];
try 
    findobj(h); % figure still exist ?
    answerPos = str2double(get(h,'userdata'));
    delete(h);
catch
    if nargin==2; answerPos = 2; end; % answer == 'cancel'
    return; 
end


end

