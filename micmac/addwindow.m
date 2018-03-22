function [VI, ALLWIN] = addwindow(VI, ALLWIN, figurehandle)
% [VI, ALLWIN] = ADDWINDOW(VI, ALLWIN, figurehandle)
% Create and add a new window to the ALLWIN structure
%
% INPUTS :
%   - VI, ALLWIN
%   - fingurehandle         : if not empty, handle of the window (?)
%
% OUTPUTS : 
%   - VI, ALLWIN

% nargin==2, create a new fig
if nargin == 2
    figh = micmac_mainfig(0);
    set (figh,'name',['micMac - ',num2str(VI.nwin+1)],'NumberTitle','off','MenuBar','none');
    set (figh,'visible','on');
% nargin==3, assign the already created figure to the global variables
elseif nargin == 3
    figh = figurehandle;
end
% Add information ot the global structure 
VI.nwin = length(ALLWIN)+1;
VI.figh (VI.nwin) = figh;
% Create a win struct with default parameters
Win = s_newwin (figh);
if isempty(ALLWIN)
    ALLWIN = Win;
else
    ALLWIN(VI.nwin) = Win;
end




    
end



