function [VI, ALLWIN, ALLSIG] = pop_extractspikes(VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = pop_extractspikes(VI, ALLWIN, ALLSIG)

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG, 'type', 'continuous');
if isempty(SigCont)
    msgbox ('You need to load a signal first');
    return;
end

cb_ampdistrib = [
    'SigCont= getsignal(ALLSIG,''type'',''continuous'');',...
    'sigind = get(findobj(gcbf,''tag'',''sigthreshpopup''),''value'');',...
    '[N,X]  = hist(SigCont(sigind).data(:),100);',...
    'N=100*N./sum(N);',...
    'figure (''DockControls'',''off'',''Name'',''Amplitude Distrubution'',''NumberTitle'',''off'',''tag'',''ampdistrib'');',...
    'bar (X,N,1); axis tight; ylabel(''%'');',...
    'title (regexprep(SigCont(sigind).desc,''_'','' ''));',...
    ];

% cb_sigchanged = [
%     'SigCont= getsignal(ALLSIG,''type'',''continuous'');',...
%     'sigind = get(findobj(gcbf,''tag'',''sigpopup''),''value'');',...
%     'set (findobj(gcbf,''tag'',''editminval''),''string'',',...
%     'floor(min(min(SigCont(sigind).data(SigCont(sigind).eegchannelind,:)))));',...
%     'set (findobj(gcbf,''tag'',''editmaxval''),''string'',',...
%     'ceil(max(max(SigCont(sigind).data(SigCont(sigind).eegchannelind,:)))));',...
%     ];

geometry = {[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Extract Spikes :'},...
    {'Style','popupmenu','String',sigdesc,'tag','sigthreshpopup'},...
    {'Style','text','String','Bandpassed signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','sigbppopup'},...
    {'Style','text','String','Minimum Threshold :'},...
    {'Style','edit','String','','tag','thresholdvalue'},...
    {'Style','text','String','Maximum Threshold :'},...
    {'Style','edit','String',''},...
    {'Style','text','String','Time before (ms) :'},...
    {'Style','edit','String','0.7'},...
    {'Style','text','String','Time after (ms) :'},...
    {'Style','edit','String','1.5'},...
    {},...
    {'Style','text','String','Events name'},...
    {'Style','edit','String','AP'},...
    {},...
    {},{'Style','pushbutton','String','Amplitude Distrubution','Callback',cb_ampdistrib},{},...
    };


results = inputgui (geometry, uilist, 'title', 'Thresholding');

if ~isempty(results)
    sigthreshind= results{1};
    sigbpind    = results{2};
    threshmin   = fastif(isempty(results{3}),min(SigCont(sigthreshind).data(:))-1,str2double(results{3}));
    threshmax   = fastif(isempty(results{4}),max(SigCont(sigthreshind).data(:))+1,str2double(results{4}));
    tpre        = str2double(results{5});
    tpost       = str2double(results{6});
    eventtype   = strtrim(results{7});
    if isnan(threshmin) || isnan(threshmax)
        msgbox ('Threshold values must be numeric','Extract spike error');
        return;
    end
    if threshmin > threshmax
        msgbox ('Threshold min must be inferior to threshold max','Extract spike error');
        return;
    end
    if isnan(tpre) || isnan(tpost)
        msgbox ('Times before and after event must be numeric','Extract spike error');
        return;
    end
    if isempty(eventtype)
        msgbox ('Event name is empty','Extract spike error');
        return;
    end
    Sigthresh   = SigCont(sigthreshind);
    Sigbp       = SigCont(sigbpind);
    
    wpre        = ceil(1+tpre/1000*Sigthresh.srate);
    wpost       = ceil(1+tpost/1000*Sigthresh.srate);
    dispinfo ('Extracting spikes');
    [spikesall, tspikes, channelind] = extractspikes (Sigthresh, Sigbp, threshmin, threshmax, wpre, wpost);
    dispinfo ('');
    
    spikedirname = uigetdir ('','Choose directory to save spikes matrices');
    if ~isempty(spikedirname)
        chanspike = unique(channelind);
        for i=1:length(chanspike)
            spikestruct.spikes  = spikesall(channelind==chanspike(i),:);
            spikestruct.index   = round(1+tspikes(channelind==chanspike(i))*Sigthresh.srate);
            save (fullfile(spikedirname,['spikes_',num2str(chanspike(i)),'.mat']),'spikestruct');
        end       
    end
%     
%     %- Add event
%     for j=1:length(spikesall)
%          VI = addeventt(VI, ALLWIN, ALLSIG, eventtype, tspikes(j)-tpre/1000, (tpost+tpre)/1000, channelind(j), Sigbp.id);
%     end
    
    
    
    
end
    
end

