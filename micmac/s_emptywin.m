function [Win] = s_emptywin ()
% [Win] = S_EMPTYWIN ()
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

Win.figh            = [];
Win.axlist          = [];
Win.axfocus         = [];
Win.viewfocus       = []; 
Win.views           = [];
Win.visible         = [];
Win.visumode        = [];
Win.ctimet          = []; % in sec
Win.obstimet        = [];
Win.chansel         = [];
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