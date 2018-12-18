function [VI, ALLWIN, ALLSIG] = pop_exportepochs (VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_EXPORTEPOCHS (VI, ALLWIN, ALLSIG)
%   Popup window to export epochs signals

[SigEpoch,~,~,~,sigdesc] = getsignal (ALLSIG,'type','epoch');
if isempty(SigEpoch)
    msgbox ('No epoch signal loaded');
    return;
end

trialrangedefault = ['1:',num2str(SigEpoch(1).ntrials)];

cb_chansel = [
    'chanselpos = get(gcbf,''userdata'');',...
    'sigdesc    = get(findobj(gcbf, ''tag'', ''epochsigs''),''String'');',...
    'pos        = get(findobj(gcbf, ''tag'', ''epochsigs''),''Value'');',...
    '[~,sigpos] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    'chanselpos = pop_channelselect(ALLSIG(sigpos),0,1,chanselpos);',...
    'set(gcbf,''userdata'',chanselpos);',...
    'set(findobj(''tag'',''chanseledit''),''String'',[''['',num2str(chanselpos),'']'']);',...
    ];

epoch_formats = {'EEGLAB Epoch (.set)'};
geometry = {[1,1],[1,1],[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','epochsigs'},...
    {'Style','text','String','Epoch format :'},...
    {'Style','popupmenu','String',epoch_formats},...
    {'Style','text','String','Channel list (default All) :'},...
    {'Style','edit','String','','tag','chanseledit'},...
    {'Style','text','String','Trial range (default All) :'},...
    {'Style','edit','String',trialrangedefault,'tag','trialrangesel'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'Export data (EDF)');

if ~isempty(results)
    sigind      = results{1};
    SigSel      = SigEpoch(sigind);
    epochformat = epoch_formats{results{2}};
    chanselman  = results{3};
    %- Channel selection
    if isempty(chanselpos)
        if isempty(chanselman);
            chanselman=1:SigSel.nchan; 
        else
            try
                chanselman = eval(['[',chanselman,']',]);
            catch
                chanselman=1:SigSel.nchan;
                warning('Error evaluating channel selection');
            end
        end
        chanselman(chanselman<1)=[];
        chanselman(chanselman>SigSel.nchan)=[];
        if isempty(chanselman); return; end;
        chanselpos = chanselman;
    end
    try
        trialselpos = eval(results{4});
    catch
        msgbox('Wrong trial selection');
        return;
    end
    SigSel = sig_channelsel(SigSel, chanselpos);
    SigSel = sig_trialsel(SigSel, trialselpos);
    EEG = sig2eeg(SigSel);
    pop_saveset(EEG)

end

end


