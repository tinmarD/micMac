function [VI, ALLWIN, ALLSIG] = pop_threshold(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_THRESHOLD (VI, ALLWIN, ALLSIG)
% Popup window to threshold signal. Creates event of segments above
% threshold. 2 thresholds, an minimal and and maximal thresholds can be
% selected. Amplitude distribution can be visualized.
%
% See also: thresholdvector

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG, 'type', 'continuous');
if isempty(SigCont)
    msgbox ('You need to load a signal first');
    return;
end

cb_ampdistrib = [
    'SigCont= getsignal(ALLSIG,''type'',''continuous'');',...
    'delete(findobj(''type'',''figure'',''name'',''Amplitude Distrubution''));',...
    'sigind = get(findobj(gcbf,''tag'',''sigpopup''),''value'');',...
    '[N,X]  = hist(SigCont(sigind).data(:),100);',...
    'N=100*N./sum(N);',...
    'figure (''DockControls'',''off'',''Name'',''Amplitude Distrubution'',''NumberTitle'',''off'',''tag'',''ampdistrib'');',...
    'bar (X,N,1); axis tight; ylabel(''%'');',...
    'title (regexprep(SigCont(sigind).desc,''_'','' ''));',...
    ];

cb_sigchanged = [
    'SigCont= getsignal(ALLSIG,''type'',''continuous'');',...
    'sigind = get(findobj(gcbf,''tag'',''sigpopup''),''value'');',...
    'set (findobj(gcbf,''tag'',''editminval''),''string'',',...
    'floor(min(min(SigCont(sigind).data(SigCont(sigind).eegchannelind,:)))));',...
    'set (findobj(gcbf,''tag'',''editmaxval''),''string'',',...
    'ceil(max(max(SigCont(sigind).data(SigCont(sigind).eegchannelind,:)))));',...
    ];

geometry = {[1,1],[1,1],[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Input signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','sigpopup','callback',cb_sigchanged},...
    {'Style','text','String','Minimum Value :'},...
    {'Style','edit','String',floor(min(min(SigCont(1).data(SigCont(1).eegchannelind,:)))),...
    'tag','editminval'},...
    {'Style','text','String','Maximum Value :'},...
    {'Style','edit','String',ceil(max(max(SigCont(1).data(SigCont(1).eegchannelind,:)))),...
    'tag','editmaxval'},...
    {'Style','text','String','Events name :'},...
    {'Style','edit','String','ThreshEvents'},...
    {},...
    {},{'Style','pushbutton','String','Amplitude Distribution','Callback',cb_ampdistrib},{},...
    };


results = inputgui (geometry, uilist, 'title', 'Thresholding');
%- Delete histogram figure, if it exists
delete(findobj('type','figure','name','Amplitude Distribution'));

if ~isempty(results)
    sigInd      = results{1};
    minVal      = fastif(isempty(results{2}),min(SigCont(sigInd).data(:))-1,str2double(results{2}));
    maxVal      = fastif(isempty(results{3}),max(SigCont(sigInd).data(:))+1,str2double(results{3}));
    if isnan(minVal) || isnan(maxVal)
        msgbox ('Threshold values must be numeric','threshold error');
        return;
    end
    if minVal > maxVal
        msgbox ('Threshold min must be inferior to threshold max','threshold error');
        return;
    end
    eventType   = strtrim(results{4});
    if isempty(eventType)
        msgbox ('Event name is empty','threshold error');
        return;
    end
    Sig = SigCont(sigInd);
    
    chanSelPos      = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
    chanSelPos(ismember(chanSelPos,Sig.badchannelpos))=[];
    
    for i=1:length(chanSelPos)
        [~,tStarti,tEndi] = thresholdvector(Sig.data(chanSelPos(i),:),Sig.srate,minVal,maxVal);
        % Add the events
        for j=1:length(tStarti)
             VI = addeventt(VI, ALLWIN, ALLSIG, eventType, tStarti(j), tEndi(j)-tStarti(j), chanSelPos(i), Sig.id);
        end
    end
        
    dispinfo('');    
    [VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG);
    
end
    
end

