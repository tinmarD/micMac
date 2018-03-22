function [VI, ALLWIN, ALLSIG] = pop_ripplelab_ste (VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = POP_RIPPLELAB_STE (VI, ALLWIN, ALLSIG)
% Interfaces the Short Time Energy HFO detector implemented in RIPPLELAB
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

geometry = {[1,1],[1,1],1,[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Filtered Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','allsigs','value',length(SigCont)},...
    {'Style','text','String','Events name :'},...
    {'Style','edit','String','hfo-ste'},...
    {},...
    {'Style','text','String','RMS Window Time (s) :'},... 
    {'Style','edit','String','0.003'},...
    {'Style','text','String','RMS Threshold (SD) :'},...
    {'Style','edit','String','5'},...
    {'Style','text','String','HFO min Time (s) :' },...
    {'Style','edit','String','0.006'},...
    {'Style','text','String','Min gap Time (s) :'},...
    {'Style','edit','String','0.01'},...
    {'Style','text','String','Min nb of Peaks :'},...
    {'Style','edit','String','6'},...
    {'Style','text','String','Peak Threshold (SD) :'},...
    {'Style','edit','String','3'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'RIPPLELAB - Short Time Energy Detector');

if ~isempty(results)
    dispinfo('RIPPLELAB - Short Time Energy Detector ...',1);
    
    Sig                     = SigCont(results{1});
    sigid                   = Sig.id;
    params.rmsWinTimeSec    = str2double(results{3});
    params.rmsThreshSD      = str2double(results{4});
    params.hfoMinTimeSec    = str2double(results{5});
    params.minGapTimeSec    = str2double(results{6});
    params.minNumPeaks      = str2double(results{7});
    params.peakThreshSD     = str2double(results{8});
    params.epochTime        = [0, Sig.tmax];
    
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

    h_wb = waitbar(0,'RIPPLELAB - Short Time Energy Detector','color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');

    if isempty(chanselpos)
        chanselpos  = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
        %- Remove bad channels
        chanselpos(ismember(chanselpos,Sig.badchannelpos))=[];
    end  
    for i=1:length(chanselpos)
        %- HFO detection
        HFOEvents = ripplelab_findHFOxSTE(x(chanselpos(i),:),params,Sig.srate);
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