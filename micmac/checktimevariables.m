function [ALLWIN] = checktimevariables (VI, ALLWIN, ALLSIG, winnb)
% [ALLWIN] = CHECKTIMEVARIABLES (VI, ALLWIN, ALLSIG, winnb)
% Check the validity of the Window struct time variables :
% ctimet and obstimet
% If not valid, correct them. 
% After validation, add the navigation parameters to the buffer.
% Is called each time a time variable is modified
%
% See also:  buffernavigparams

if nargin==3 || isempty(winnb)
    winnb=find(VI.figh==gcbf);
end;
if isempty(ALLWIN(winnb).views); return; end;
Sig = getsignal (ALLSIG, 'sigid', ALLWIN(winnb).views(1).sigid);

ALLWIN(winnb).obstimet = median ([vi_defaultval('obstimet_min'),...
            ALLWIN(winnb).obstimet,...
            min(Sig.tmax,vi_defaultval('obstimet_max'))]);
                    
ALLWIN(winnb).ctimet   = median ([ALLWIN(winnb).obstimet/2,...
            ALLWIN(winnb).ctimet,...
            Sig.tmax-ALLWIN(winnb).obstimet/2]);                            

ALLWIN = buffernavigparams (VI, ALLWIN, ALLSIG, 'buffer', winnb);

                            
end

