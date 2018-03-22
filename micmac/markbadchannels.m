function [VI, ALLWIN, ALLSIG] = markbadchannels (VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = markbadchannels (VI, ALLWIN, ALLSIG)

winnb   = find(cat(1,ALLWIN.figh)==gcbf);
if isempty(ALLWIN(winnb).views); return; end;

% Get the signal of interest
sigid           = ALLWIN(winnb).views(1).sigid;
[Sig, sigind]   = getsignal (ALLSIG, sigid);
sigpos          = find(sigind==1);

% Get the indices of the bad channels
channellb   = findobj(ALLWIN(winnb).figh,'Style','listbox','tag','chansellb');

selchannelpos = get (channellb,'Value');
if isempty(selchannelpos)
    dispinfo ('No channel selected');
    return;
end

% Get signal children position
[~,childsigind] = getsigchildren (ALLSIG, sigid);
childsigpos     = find(childsigind==1);

% If all the selected channels are already marked as bad, reset them as good
if sum(ismember(selchannelpos,Sig.badchannelpos)) == length (selchannelpos)
    for pos = [sigpos,childsigpos]
        ALLSIG(pos).badchannelpos (ismember (ALLSIG(pos).badchannelpos,selchannelpos)) = [];
        ALLSIG(pos).channamesnoeeg(selchannelpos) = ...
            cellfun (@(x)[x(1:end-2)], ALLSIG(pos).channamesnoeeg(selchannelpos),'UniformOutput',0);
    end
% Else set them as bad
else
    for pos = [sigpos,childsigpos]
        newbadchannelpos = selchannelpos(~ismember(selchannelpos,ALLSIG(pos).badchannelpos));
        ALLSIG(pos).badchannelpos = [ALLSIG(pos).badchannelpos,newbadchannelpos];
        ALLSIG(pos).channamesnoeeg(newbadchannelpos) = ...
            cellfun (@(x)[x,' *'], ALLSIG(pos).channamesnoeeg(newbadchannelpos),'UniformOutput',0);
    end
end

% Remove bad channels from current selection
ALLWIN(winnb).chansel (ismember (ALLWIN(winnb).chansel, ALLSIG(pos).badchannelpos)) = [];

ALLWIN = redrawwin (VI, ALLWIN, ALLSIG, winnb);

end