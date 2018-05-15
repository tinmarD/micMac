function [VI, ALLWIN, ALLSIG] = pop_artefactdetect_maxabsdiffpsd(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_ARTEFACTDETECT_MAXABSDIFFPSD(VI, ALLWIN, ALLSIG)
%  Artefact detection in micro-electrode recordings
% Ref : Methods for automatic detection of artifacts in microelectrode
% recordings, 2017, Bakstein and al.
% 
% Method : 
%   computes value of the maxDiffPSD feature (maximum absolute difference 
%   from mean spectrum of clean MER signals) and compares it with
%   threshold thr

titre = 'Artefact Detection micro - MaxAbsDiffPSD';

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
    {'Style','popupmenu','String',sigdesc,'tag','allsigs','value',length(SigCont)},...
    {'Style','text','String','Events name :'},...
    {'Style','edit','String','Artefact'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', titre);

if ~isempty(results)
    dispinfo([titre,' ...'],1);
    
    Sig         = SigCont(results{1});
    sigid    	= Sig.id;
    params      = [];
    
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
    x = Sig.data;
    if isempty(chanselpos)
        chanselpos  = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
        %- Remove bad channels
        chanselpos(ismember(chanselpos,Sig.badchannelpos))=[];
    end    
    h_wb = waitbar(0,titre,'color',vi_graphics('waitbarbackcolor'),'visible','off','name','micMac');
    set(get(findobj(h_wb,'type','axes'),'title'),'color',vi_graphics('textcolor')); set(h_wb,'visible','on');

    for i=1:length(chanselpos)
        %- Artefact detection
        val = maxDiffPSD(x(chanselpos(i),:), Sig.srate);
        
% %         
%         [tstarts,tends] 	= artefactdetect_maxabsdiffpsd (x(chanselpos(i),:),params,Sig.srate,meanStd);
%         if ~isempty(tstarts)
%             for j=1:length(tstarts)
%                  VI = addeventt(VI, ALLWIN, ALLSIG, eventType, tstarts(j), tends(j)-tstarts(j), chanselpos(i), sigid);
%             end
%         end
        try waitbar(i/length(chanselpos),h_wb); catch; end;
    end
    try close(h_wb); catch; end;
    
    dispinfo('');    
    [VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG);
    
end


end

