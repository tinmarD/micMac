function [VI, ALLWIN, ALLSIG] = pop_seteegchannels (VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_SETEEGCHANNELS (VI, ALLWIN, ALLSIG)
%   Popup window to set the eeg channels, the non-selected channels are
%   considered non-eeg, and thus are not taken into account for some
%   operations (e.g. filtering)
%
%   If the raw signals has some child signals with the same number of
%   channels, also set the eeg channels of these signals. (Why the number
%   of channel would be different ?)

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous','israw', 1);
if isempty(SigCont)
    msgbox ('No signal loaded');
    return;
end

cb_chansel = [
    'chanselpos = get(gcbf,''userdata'');',...
    'sigdesc    = get(findobj(gcbf, ''tag'', ''rawsigs''),''String'');',...
    'pos        = get(findobj(gcbf, ''tag'', ''rawsigs''),''Value'');',...
    '[~,sigpos] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    'chanselpos = pop_channelselect(ALLSIG(sigpos),0,0,chanselpos);',...
    'set(findobj(''tag'',''chanseledit''),''String'',[''['',num2str(chanselpos),'']'']);',...
    'set(gcbf,''userdata'',chanselpos);',...
    ];


geometry = {[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','rawsigs'},...
    {'Style','text','String','Channel list (default All) :'},...
    {'Style','edit','String','','tag','chanseledit'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'Set EEG Channels');

if ~isempty(results)
    sigind      = results{1};
    chanselman  = results{2};
    Sig         = ALLSIG(sigind);
    
    %- Channel selection
    if isempty(chanselpos)
        if isempty(chanselman); 
            chanselman=1:Sig.nchan; 
        else
            try
                chanselman = eval(['[',chanselman,']',]);
            catch
                chanselman=1:Sig.nchan;
            end
        end
        chanselman(chanselman<1)=[];
        chanselman(chanselman>Sig.nchan)=[];
        if isempty(chanselman); return; end;
        chanselpos = chanselman;
    end
    
    ALLSIG(sigind) = seteegchannels(Sig, chanselpos);
    
    % Get child signals
    [~, child_sig_ind, ~] = getsigchildren(ALLSIG, sigind);
    child_sig_pos = find(child_sig_ind);
    for child_pos = child_sig_pos
        if ALLSIG(child_pos).nchan == ALLSIG(sigind).nchan
            ALLSIG(child_pos) = seteegchannels(ALLSIG(child_pos), chanselpos);
        end
    end

end
    
end

