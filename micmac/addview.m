function [VI, ALLWIN, ALLSIG] = addview(VI, ALLWIN, ALLSIG, winnb, sigid, domainstr, viewpos, viewparams, viewgain)
%[VI, ALLWIN, ALLSIG] = ADDVIEW (VI, ALLWIN, ALLSIG, ...
%            winnb, sigid, domainstr, viewpos, viewparams, viewgain)
% Add a View of the signal to the selected window
%
% INPUTS : 
%   - VI, ALLWIN, ALLSIG 
%   - winnb                 : Position of the window in ALLWIN
%   - sigid                 : ID of the signal to appear on the view
%   - domainstr             : Visualisation domain of the view ('t','f','tf')
%   - viewpos               : View position on the window
%   - viewparams            : View parameters
%   - viewgain              : View gain [1,2] vector. Optional.
%
% OUTPUTS:
%   - VI, ALLWIN, ALLSIG
%
% See also s_newview

if ~exist('viewparams','var'); viewparams=[]; end;
if isempty(ALLWIN); error('ALLWIN is empty, Impossible in theory'); end
if length(ALLWIN)<winnb; error(['ALLWIN(',num2str(winnb),') does not exist']); end

[VI,viewid]     = incuniquecounter (VI,'view');
Sig             = getsignal (ALLSIG,'sigid',sigid);
Win             = ALLWIN(winnb);
viewname        = [num2str(viewid),' ',Sig.desc,'-',domainstr];
% if ~isempty(findobj('Label',viewname))
%     dispinfo('You cannot add the same view twice');
%     return;
% end

%- Create the View structure 
if nargin<9
    View        = s_newview (viewid, sigid, domainstr, viewparams);
else
    View        = s_newview (viewid, sigid, domainstr, viewparams, viewgain);
end
% if strcmp(View.domain,'tf')
%     View.couleur = vi_defaultval('colormap');
% end
nwinviews   = length(Win.views);
viewpos     = min(viewpos,nwinviews+1);
%- Add the view in last position
if nwinviews==0
    ALLWIN(winnb).views = View;
else
    ALLWIN(winnb).views(nwinviews+1) = View;
end
%- if viewpos is not in last position, permute the 2 views
if viewpos ~= (nwinviews+1)
    Viewsaved = Win.views(viewpos);
    ALLWIN(winnb).views(viewpos)     = View; 
    ALLWIN(winnb).views(nwinviews+1) = Viewsaved;
end
%- If view is in first position, check that this view signal was parent
%with the previous first view signal
if viewpos==1 && nwinviews
    %- If not parents
    if ~areparentsig(ALLSIG,View.sigid,Viewsaved.sigid)
        %- Get channel correspondence if it exist
        corrChan = getcorrchannels(VI,ALLWIN,ALLSIG,winnb,nwinviews+1);
        %- If not, reset the window channel selection to first channel
        if isempty(corrChan)
            ALLWIN(winnb).chansel = 1;
        end
    end
end


%- Redraw window
ALLWIN = redrawwin(VI,ALLWIN,ALLSIG,winnb);
%- Add it to the list of views
viewsmenuh  = findobj(VI.figh(1),'Label','Views');
sepval      = fastif(length(allchild(viewsmenuh))==1,'on','off');


cb_viewproperty = '[VI, ALLWIN, ALLSIG] = pop_viewproperties(VI, ALLWIN, ALLSIG);';
uimenu (viewsmenuh, 'Label', viewname,'Separator',sepval,'Callback',cb_viewproperty);

end




