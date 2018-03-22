function [VI, ALLWIN, ALLSIG] = pop_spikedetect_mteo (VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_SPIKEDETECT_MTEO (VI, ALLWIN, ALLSIG)
% Interfaces the MTEO Epileptic spike detector
%
% See also spikedetect_mteo

titre = 'Epileptic Spike Detection - MTEO';

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG, 'type', 'continuous');
if isempty(SigCont)
    msgbox ('You need to load a signal first');
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

geometry = {[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Raw Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','allsigs','value',1},...
    {'Style','text','String','Events name :'},...
    {'Style','edit','String','spike-MTEO'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', titre);

if ~isempty(results)
    dispinfo([titre,' ...'],1);
    
    Sig         = SigCont(results{1});
    sigid    	= Sig.id;    
    eventType 	= results{2};
    
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
    if isempty(chanselpos)
        chanselpos  = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
        %- Remove bad channels
        chanselpos(ismember(chanselpos,Sig.badchannelpos))=[];
    end    
    h_wb = waitbar(0,titre,'color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');
    
    for i=1:length(chanselpos)
        %- Epileptic spike detection
        [tstarts,tends] 	= spikedetect_mteo (Sig.data(chanselpos(i),:),Sig.srate);
        if ~isempty(tstarts)
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

