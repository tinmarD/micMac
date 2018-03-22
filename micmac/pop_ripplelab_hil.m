function [VI, ALLWIN, ALLSIG] = pop_ripplelab_hil (VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = POP_RIPPLELAB_HIL (VI, ALLWIN, ALLSIG)
% Interfaces the hilbert HFO detector implemented in RIPPLELAB
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

geometry = {[1,1],[1,1],1,[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Filtered Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','allsigs','value',length(SigCont)},...
    {'Style','text','String','Events name :'},...
    {'Style','edit','String','hfo-Hil'},...
    {},...
    {'Style','text','String','Threshold (SD) :'},... 
    {'Style','edit','String','5'},...
    {'Style','text','String','HFO min Time (s)  :'},...
    {'Style','edit','String','0.010'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'RIPPLELAB - Hilbert Detector');

if ~isempty(results)
    dispinfo('RIPPLELAB - Hilbert Detector ...',1);
    
    Sig                     = SigCont(results{1});
    sigid                   = Sig.id;
    params.threshold        = str2double(results{3});
    params.hfoMinTimSec     = str2double(results{4});
    
    eventType       = results{2};
    
    % TODO Check validity of inputs
    
    %- Check input signal is low-pass filtered
    if isempty(getcutofffreqfromsigdesc(Sig.desc))
        answer = questdlg(['Warning: input signal ',Sig.desc,' should be filtered ',...
            'to remove at least low frequencies. Continue ?']);
        if ~strcmp(answer,'Yes')
            dispinfo('',0);
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

    h_wb = waitbar(0,'RIPPLELAB - Hilbert Detector','color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');
    
    for i=1:length(chanselpos)
        %- HFO detection
        HFOEvents = ripplelab_findHFOxHIL(x(chanselpos(i),:),params,Sig.srate);
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