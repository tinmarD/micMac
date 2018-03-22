function [] = dispinfo(infostr, wait)
% [] = DISPINFO (infostr, wait)
% Display info on the information panel at the bottom right of the window
% Can also modify the cursor
% 
% INPUTS :
%   - infostr       : string to display
%   - wait          : if 1, set the cursor to 'watch' cursor, if 0, set it
%                     to the normal 'arrow' cursor

if nargin==2 && wait
    set (gcbf,'pointer','watch');
else
    set (gcbf,'pointer','arrow');
end

h_txtinfo   = findobj('parent',gcbf,'tag','textinfo');
set (h_txtinfo,'String',infostr,'Fontsize',8);
drawnow;

end

