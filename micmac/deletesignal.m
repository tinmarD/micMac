function [VI, ALLWIN, ALLSIG] = deletesignal(VI, ALLWIN, ALLSIG, sigid)
%[VI, ALLWIN, ALLSIG] = DELETESIGNAL (VI, ALLWIN, ALLSIG, sigid)
% Delete a signal, specified by its id. Only raw signal can be deleted. 
% Deleting a signal will delete :
%   the signal
%   all its child signals
%   the views associated with this signal
%   the events associated with this signal
%
% INPUTS : 
%   - VI, ALLWIN, ALLSIG
%   - sigid                 : id of the signal to delete
% 
% OUTPUTS : 
%   - VI, ALLWIN, ALLSIG
% 

%- Get all the postition of signal's children
[childSigs, childpos, childid] = getsigchildren (ALLSIG, sigid);

%- Get all the views that takes on the children or parent signal as input
%- and delete them
for id=[sigid;childid(:)]'
    [~,~,~,viewids] = getview(ALLWIN,'sigid',id);
    if ~isempty(viewids)
        for viewid=viewids
            ALLWIN = deleteview (VI, ALLWIN, ALLSIG, viewid);
        end
    end
end

[~,parentpos,~,~,parentdesc,~,~,israw] = getsignal (ALLSIG,sigid);
delsigpos           = parentpos | childpos;
delsigdesc          = arrayfun(@(x)x.desc,childSigs,'Uniformoutput',false);
delsigdesc{end+1}   = cell2mat(parentdesc);
% Remove the signals from the ALLSIG struct
ALLSIG(delsigpos) = []; 

% Delete the chancorr field of VI structure if the signal is raw
if israw
    VI.chancorr(parentpos,:) = [];
    VI.chancorr(:,parentpos) = [];
end    

for desc=delsigdesc
    % Remove the view from menu
    menu_h = findobj('Label',cell2mat(desc));
    delete (menu_h);
end

% Delete event associated with the signal
[sigEvents,sigEventSel] = getevents(VI,'rawpid',sigid);
if ~isempty(sigEvents)
    saveEvents = strcmp(questdlg('Save signal events ?'),'Yes');
    if saveEvents
        exporteventstofile(VI)
    end
    VI.eventall(sigEventSel) = [];
    VI.eventpos = median([0,length(VI.eventsel)-sum(sigEventSel),VI.eventpos]);
    if isempty(VI.eventpos); VI.eventpos=0; end;
    VI = updateeventsel (VI,1,1);
    [VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG);
end


for winnb=1:length(ALLWIN)
    if ~ismember(ALLWIN(winnb).axfocus,ALLWIN(winnb).axlist)
        ALLWIN(winnb).axfocus=[];
    end
    ALLWIN(winnb).viewfocus = getfocusedviewpos(ALLWIN(winnb));
    % If window is empty, reset the window parameter
    if isempty(ALLWIN(winnb).views)
        ALLWIN(winnb) = s_newwin (ALLWIN.figh);
    end
    [ALLWIN] = redrawwin(VI, ALLWIN, ALLSIG, winnb);
end

end

