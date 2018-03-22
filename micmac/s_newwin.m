function [Win] = s_newwin (figh, views, visible, visumode, ctimet, obstimet, chansel)
% WIN = s_newwin (figh, allview, visible, visumode, ctimet, obstimet, chansel)
%
% Structure fields:
%  - figh               : Handle to the figure 
%  - axlist             : List of the handle to every axes of the window
%  - axfocus            : Handle of axes which has focus
%  - viewfocus          : Number of the view which has focus
%  - views              : Array of View structure contained in this window
%  - visible            : ???
%  - visumode           : Visualization mode - 1: stacked or 2: spaced
%  - ctimet             : Central time of the window (in sec)
%  - obstimet           : Length of the time window (in sec)
%  - chansel            : Position of the selected channels 
%  - synctimetwin       : If multilples windows, activate the time synchronisation
%  - syncobstimetwin    : If multilples windows, activate the window's duration synchronisation
%  - syncchanselwin     : If multilples windows, activate the channel synchronisation
%  - buf_ctimet         : Buffer for central time
%  - buf_obstimet       : Buffer for window's duration
%  - buf_chansel        : Buffer for channel selection
%  - bufcancel          : ???


Win.figh            = figh;
Win.axlist          = [];
Win.axfocus         = [];
Win.viewfocus       = [];
if nargin==1
    Win.views   = [];
    Win.visible = 1;
    Win.visumode= 1;
    Win.ctimet  = 0.3; % in sec
    Win.obstimet= 0.6;
    Win.chansel = 1;
else
    Win.view    = views;
    Win.visible = visible;
    Win.visumode= visumode;
    Win.ctimet  = ctimet; % in sec
    Win.obstimet= obstimet;
    Win.chansel = chansel;
end
Win.syncctimetwin   = [];
Win.syncobstimetwin = [];
Win.syncchanselwin  = [];

% Buffers for time and channel parameters
Win.buf_ctimet      = zeros (1,1+2*vi_defaultval('buffer_size'));
Win.buf_obstimet    = zeros (1,1+2*vi_defaultval('buffer_size'));
Win.buf_chansel     = cell  (1,1+2*vi_defaultval('buffer_size'));
% Cancelation value
Win.bufcancel       = 0;

end

