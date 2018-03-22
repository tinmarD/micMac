function ALLWIN = deleteview(VI, ALLWIN, ALLSIG, viewid)
% ALLWIN = DELETEVIEW(VI, ALLWIN, ALLSIG, viewid)
%   Delete a view from a window. The view is specified by it id.
% 
% INPUTS : 
%   - VI, ALLWIN, ALLSIG
%   - viewid            	: id of the view to delete
% 
% OUTPUTS : 
%   - VI, ALLWIN, ALLSIG
% 


[~,winnb,viewpos,~,sigid,domaincell] = getview (ALLWIN, viewid);

Sig      = getsignal (ALLSIG, 'sigid', sigid);
viewname = [num2str(viewid),' ',Sig.desc,'-',cell2mat(domaincell)];

% Remove the axis handle of the view and clear the axis
if nargin==4
    if ALLWIN(winnb).visumode == 1 % stacked mode
        if ALLWIN(winnb).axlist(viewpos)~=0
            delete(ALLWIN(winnb).axlist(viewpos));
        end
        % Remove the axis handle from the list
        ALLWIN(winnb).axlist(viewpos)    = [];
    elseif ALLWIN(winnb).visumode == 2 % spaced mode
        if ALLWIN(winnb).axlist(viewpos)~=0
            axlistind = viewpos:length(ALLWIN(winnb).views):(length(ALLWIN(winnb).chansel)*length(ALLWIN(winnb).views));
            axlistind(axlistind>vi_defaultval('max_spaced_axis')) = [];
            delete(ALLWIN(winnb).axlist(axlistind));
            % Remove the axis handle from the list
            ALLWIN(winnb).axlist(axlistind)  = [];
        end
    end
end


% If the first view is deleted, change the window chansel
if ismember(1,viewpos)
    % If there was only 1 view, which is going to be deleted
    if size(ALLWIN(winnb).views,2)==1
        ALLWIN(winnb).chansel = 1;
    else
        SigSecond = getsignal (ALLSIG, 'sigid', ALLWIN.views(2).sigid);
        % Do not change chansel if signals are parents, if not check for
        % correspondences
        if ~areparentsig(ALLSIG,sigid,SigSecond.id)
            newchansel = getcorrchannels(VI,ALLWIN,ALLSIG,winnb,2);
            if isempty(newchansel)
                ALLWIN(winnb).chansel = 1;
            else
                ALLWIN(winnb).chansel = newchansel;
            end
        end
    end
end


% Remove the view from the ALLWIN(winnb) struct
ALLWIN(winnb).views(viewpos)     = [];     

% Remove the view from menu
menu_h = findobj(ALLWIN(1).figh,'Label',viewname);
delete (menu_h);


end

