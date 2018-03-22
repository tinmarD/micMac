function [ALLWIN] = buffernavigparams (VI, ALLWIN, ALLSIG, cmd, winnb)
%[ALLWIN] = BUFFERNAVIGPARAMS (VI, ALLWIN, ALLSIG, cmd, winnb)
% buffernavigparams (VI, ALLWIN, ALLSIG, 'buffer',  winnb)
% buffernavigparams (VI, ALLWIN, ALLSIG, 'cancel',  winnb)
% buffernavigparams (VI, ALLWIN, ALLSIG, 'restore', winnb)
% 
% Used to save, cancel or restore navigation parameters (Window central
% time and duration and channel selection)
% 
% cmd input can be:
%   - 'buffer'  : used to save the current configuration (is called
%   whenever navigation parameters are changed
%   - 'cancel'  : cancel the navigation parameters. Go to the previous
%   parameters (shortcut: Ctrl-Z)
%   - 'restore' : if called after a cancel command, restore the
%   navigations parameters (shortcut: Ctrl-Y)


mid = 1+vi_defaultval('buffer_size');

if nargin==4 || isempty(winnb)
    winnb=find(VI.figh==gcbf);
end

switch cmd
    case 'buffer'
        % Check if the new navigation config is different from the last one saved
        if ALLWIN(winnb).ctimet == ALLWIN(winnb).buf_ctimet(mid) && ALLWIN(winnb).obstimet == ALLWIN(winnb).buf_obstimet(mid) ...
                && isequal(ALLWIN(winnb).buf_chansel{mid},ALLWIN(winnb).chansel)
            return;
        end

        % Shift values in buffer
        ALLWIN(winnb).buf_ctimet   (mid+1:end)    = ALLWIN(winnb).buf_ctimet   (mid:end-1);
        ALLWIN(winnb).buf_obstimet (mid+1:end)    = ALLWIN(winnb).buf_obstimet (mid:end-1);
        ALLWIN(winnb).buf_chansel  (mid+1:end)    = ALLWIN(winnb).buf_chansel  (mid:end-1);

        % Save new navigation config in center position of the buffer
        ALLWIN(winnb).buf_ctimet   (mid)  = ALLWIN(winnb).ctimet;
        ALLWIN(winnb).buf_obstimet (mid)  = ALLWIN(winnb).obstimet;
        ALLWIN(winnb).buf_chansel  {mid}  = ALLWIN(winnb).chansel;
        
        % Reset the cancel counter           
        ALLWIN(winnb).bufcancel = 0;
        
    case 'cancel'
        if ALLWIN(winnb).buf_ctimet (mid+1) ~= 0
            % Shift all to the left
            ALLWIN(winnb).buf_ctimet    (1:end-1) = ALLWIN(winnb).buf_ctimet    (2:end);
            ALLWIN(winnb).buf_obstimet  (1:end-1) = ALLWIN(winnb).buf_obstimet  (2:end);
            ALLWIN(winnb).buf_chansel   (1:end-1) = ALLWIN(winnb).buf_chansel   (2:end);
            ALLWIN(winnb).buf_ctimet    (end)     = 0;
            ALLWIN(winnb).buf_obstimet  (end)     = 0;
            ALLWIN(winnb).buf_chansel   {end}     = [];
            % Assign value to current window 
            ALLWIN(winnb).ctimet    = ALLWIN(winnb).buf_ctimet   (mid);
            ALLWIN(winnb).obstimet  = ALLWIN(winnb).buf_obstimet (mid);
            ALLWIN(winnb).chansel   = ALLWIN(winnb).buf_chansel  {mid};
            % Increment the cancel counter           
            ALLWIN(winnb).bufcancel = min(ALLWIN(winnb).bufcancel+1,vi_defaultval('buffer_size'));
            % Redraw 
            ALLWIN = redrawwin (VI, ALLWIN, ALLSIG, winnb);
        end

    case 'restore'
        if ALLWIN(winnb).buf_ctimet (mid-1) ~= 0 && ALLWIN(winnb).bufcancel>0
            % Shift all to the right
            ALLWIN(winnb).buf_ctimet    (2:end) = ALLWIN(winnb).buf_ctimet    (1:end-1);
            ALLWIN(winnb).buf_obstimet  (2:end) = ALLWIN(winnb).buf_obstimet  (1:end-1);
            ALLWIN(winnb).buf_chansel   (2:end) = ALLWIN(winnb).buf_chansel   (1:end-1);
            ALLWIN(winnb).buf_ctimet    (1)     = 0;
            ALLWIN(winnb).buf_obstimet  (1)     = 0;
            ALLWIN(winnb).buf_chansel   {1}     = [];
            % Assign value to current window 
            ALLWIN(winnb).ctimet    = ALLWIN(winnb).buf_ctimet   (mid);
            ALLWIN(winnb).obstimet  = ALLWIN(winnb).buf_obstimet (mid);
            ALLWIN(winnb).chansel   = ALLWIN(winnb).buf_chansel  {mid};
            % Decrement the cancel counter           
            ALLWIN(winnb).bufcancel = max(ALLWIN(winnb).bufcancel-1,0);
            % Redraw 
            ALLWIN = redrawwin (VI, ALLWIN, ALLSIG, winnb);
        end        
end

end

