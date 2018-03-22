function ALLWIN = zoomonsel (VI,ALLWIN,ALLSIG,type)
% ALLWIN = ZOOMONSEL (VI, ALLWIN, ALLSIG, type)
%   Function called when one of the three zoom button is selected. 
%
% INPUTS : 
%   - VI, ALLWIN, ALLSIG
%   - type                  : zoom type, can be 't' for temporal zoom, 'c' for
%                           channel zoom or 't-c' for both
%
% OUTPUTS : 
%   - ALLWIN 

winnb=find(VI.figh==gcbf);
newchansel  = ALLWIN(winnb).chansel;
newctimet   = ALLWIN(winnb).ctimet;
newobstimet = ALLWIN(winnb).obstimet;
info_msg = '';
if isempty(ALLWIN(winnb).views); return; end;

switch type
    case 't'
        [xval,~] = ginput(2);
        xval = sort(xval);
        axisnb  = find  (ALLWIN(winnb).axlist==gca);
        viewnb  = rem(axisnb,length(ALLWIN(winnb).views));
        viewnb  = fastif(viewnb==0,length(ALLWIN(winnb).views),viewnb);
        %- Frequency view, do nothing (?) or zoom on frequency (?)
        if strcmp(ALLWIN(winnb).views(viewnb).domain,'f') 
            dispinfo('Zoom on the time-domain views');
            return;
        end
        newobstimet = diff(xval);
        newctimet   = xval(1)+0.5*newobstimet;   
        
    case 'c'
        [~,yval] = ginput(2);
            yval    = sort(abs(yval));
            ymax    = abs(diff(ylim));
            ystep   = ymax/(length(ALLWIN(winnb).chansel)+1);
            ichanstart  = ceil(yval(1)/ystep);
            ichanstart  = max(1,ichanstart);
            ichanend    = floor(yval(2)/ystep);
            ichanend    = min(ichanend,length(ALLWIN(winnb).chansel));
            newchansel  = ALLWIN(winnb).chansel(ichanstart:ichanend);
            if isempty(newchansel)
                info_msg = 'No channel selected';
                newchansel  = ALLWIN(winnb).chansel;
            else
                set(findobj(gcbf,'tag','chansellb'),'Value',newchansel);
            end
        
    case 't-c'
    	[xval,yval] = ginput(2);
        xval = sort(xval);
        newobstimet = diff(xval);
        newctimet   = xval(1)+0.5*newobstimet;   
            yval    = sort(abs(yval));
            ymax    = abs(diff(ylim));
            ystep   = ymax/(length(ALLWIN(winnb).chansel)+1);
            ichanstart  = ceil(yval(1)/ystep);
            ichanstart  = max(1,ichanstart);
            ichanend    = floor(yval(2)/ystep);
            ichanend    = min(ichanend,length(ALLWIN(winnb).chansel));
            newchansel  = ALLWIN(winnb).chansel(ichanstart:ichanend);
            if isempty(newchansel)
                info_msg    = 'No channel selected';
                newchansel  = ALLWIN(winnb).chansel;
            else
                set(findobj(gcbf,'tag','chansellb'),'Value',newchansel);
            end
end

ALLWIN(winnb).ctimet    = newctimet;
ALLWIN(winnb).obstimet  = newobstimet;
ALLWIN(winnb).chansel   = newchansel;

[ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, winnb);
[ALLWIN] = redrawwin (VI, ALLWIN, ALLSIG, winnb);

if ~isempty(info_msg)
    dispinfo (info_msg);
end

end