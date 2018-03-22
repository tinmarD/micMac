function ALLWIN = settimesync(VI, ALLWIN, ALLSIG, winnb, paramname, value)
% ALLWIN = SETTIMESYNC(VI, ALLWIN, ALLSIG, winnb, paramname, value)
% Set the synchronization on or off between one window and the main window
% 
% INPUTS: 
%   - VI, ALLWIN, ALLSIG  	: micMac structure
%   - winnb                	: Number of the window to synchronize with
%                                 the main window
%   - paramname           	: Can be either 'obstimet' or 'ctimet'
%                             'obstimet' will syncrhonize the window
%                             duration. 'ctimet' will syncrhonize the
%                             central time of the window
%   - value                 : 1 or 0 (on or off)
%
% OUTPUT:
%   - ALLWIN


switch paramname
    case 'obstimet'
        obswint_p   = findobj('parent',gcbf,'tag','obswintp');
        zoom_p      = findobj('parent',gcbf,'tag','zoomp');
        if value
            ALLWIN(1).syncobstimetwin(end+1) = winnb;
            set (findall (obswint_p,'-property','enable'), 'enable', 'off');
            set (findall (zoom_p,'string','t'), 'enable', 'off');
            set (findall (zoom_p,'string','t-c'), 'enable', 'off');
            ALLWIN(winnb).obstimet = ALLWIN(1).obstimet;
            ALLWIN = redrawwin (VI, ALLWIN, ALLSIG, winnb);
        else
            ALLWIN(1).syncobstimetwin (ALLWIN(1).syncobstimetwin==winnb) = [];
            set (findall (obswint_p,'-property','enable'), 'enable', 'on');
            if isempty(find(ALLWIN(1).syncctimetwin,winnb))
                set (findall (zoom_p,'-property','enable'), 'enable', 'on');
            end
        end
        
    case 'ctimet'
        mit_p   = findobj('parent',gcbf,'tag','mitp');
        zoom_p      = findobj('parent',gcbf,'tag','zoomp');
        if value
            ALLWIN(1).syncctimetwin(end+1) = winnb;
            set (findall (mit_p,'-property','enable'), 'enable', 'off');
            set (findall (zoom_p,'string','t'), 'enable', 'off');
            set (findall (zoom_p,'string','t-c'), 'enable', 'off');
            ALLWIN(winnb).ctimet = ALLWIN(1).ctimet;
            ALLWIN = redrawwin (VI, ALLWIN, ALLSIG, winnb);
        else
            ALLWIN(1).syncctimetwin (ALLWIN(1).syncctimetwin==winnb) = [];
            set (findall (mit_p,'-property','enable'), 'enable', 'on');
            if isempty(find(ALLWIN(1).syncobstimetwin,winnb))
                set (findall (zoom_p,'-property','enable'), 'enable', 'on');
            end
        end
        
end

[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, winnb);

end
