function [VI, ALLWIN, ALLSIG] = pop_ripplelab_sll (VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = POP_RIPPLELAB_SLL (VI, ALLWIN, ALLSIG)
% Interfaces the Short Line Length HFO detector implemented RIPPLELAB
% Navarrete M, Alvarado-Rojas C, Le Van Quyen M, Valderrama M (2016) 

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');

if isempty(SigCont)
    dispinfo('No signal loaded');
    return;
end

cb_chansel = [
    'chanselpos = get(gcbf,''userdata'');',...
    'sigdesc    = get(findobj(gcbf, ''tag'', ''allsigs''),''String'');',...
    'pos        = get(findobj(gcbf, ''tag'', ''allsigs''),''Value'');',...
    '[~,sigpos] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    'chanselpos = pop_channelselect(ALLSIG(sigpos),1,1,chanselpos);',...
    'set(gcbf,''userdata'',chanselpos);',...
    ];

geometry = {[1,1],[1,1],1,[1,1],[1,1],1,[1,1],[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Raw Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','allsigs','value',length(SigCont)},...
    {'Style','text','String','Events name :'},...
    {'Style','edit','String','hfo-sll'},...
    {},...
    {'Style','text','String','Low cut-off frequency (Hz) :'},... 
    {'Style','edit','String','80'},...
    {'Style','text','String','High cut-off frequency (Hz)'},... 
    {'Style','edit','String','500'},...
    {},...
    {'Style','text','String','Filter Window (s) :'},... 
    {'Style','edit','String','0.005'},...
    {'Style','text','String','Threshold percentil (%) :'},...
    {'Style','edit','String','97.5'},...
    {'Style','text','String','HFO min Time (s) :' },...
    {'Style','edit','String','0.012'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'RIPPLELAB - Short Line Length Detector');

if ~isempty(results)
    dispinfo('RIPPLELAB - Short Line Length Detector ...',1);
    
    Sig                     = SigCont(results{1});
    sigid                   = Sig.id;
    params.lowFreq          = str2double(results{3});
    params.highFreq         = str2double(results{4});
    params.filterWinSec     = str2double(results{5});
    params.threshPercentil  = str2double(results{6});
    params.hfoMinTimeSec    = str2double(results{7});
    
    eventType       = results{2};
    
    % TODO Check validity of inputs
    
    %- Check input signal is unfiltered
    if ~isempty(getcutofffreqfromsigdesc(Sig.desc))
        answer = questdlg(['Warning: input signal ',Sig.desc,' should be unfiltered. Continue ?']);
        if ~strcmp(answer,'Yes')
            dispinfo('');    
            return;
        end
    end
    
    % Launch detector on each eeg channel
    x = Sig.data;
    if isempty(chanselpos)
        chanselpos  = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
        %- Remove bad channels
        chanselpos(ismember(chanselpos,Sig.badchannelpos))=[];
    end    
    h_wb = waitbar(0,'RIPPLELAB - Short Line Length Detector','color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');

    for i=1:length(chanselpos)
        %- HFO detection
        HFOEvents = ripplelab_findHFOxSLL(x(chanselpos(i),:),params,Sig.srate);
        if ~isempty(HFOEvents)
            tstarts = (HFOEvents(:,1)-1)/Sig.srate;
            tends   = (HFOEvents(:,2)-1)/Sig.srate;
            for j=1:length(tstarts)
                 VI = addeventt(VI, ALLWIN, ALLSIG, eventType, tstarts(j), tends(j)-tstarts(j), chanselpos(i), sigid);
            end
        end
        try waitbar(i/length(chanselpos),h_wb); catch; end;
    end
    try close(h_wb); catch; end;
    
    dispinfo('');    
    [VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG);
    
end

end