function [VI, ALLWIN, ALLSIG] = pop_exportdatatoedf (VI, ALLWIN, ALLSIG)
% [VI, ALLWIN, ALLSIG] = POP_EXPORTDATATOEDF (VI, ALLWIN, ALLSIG)
% Popup window to export data to an edf file.
% Allow temporal selection and channel selection. Channel selection can be
% done either manually or through the channel selection popup.
% If manual and graphical channel selection are in conflict, the graphical
% selection is kept.
%
% See also : pop_exportdata

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');
if isempty(SigCont)
    msgbox ('No signal loaded');
    return;
end

datarangedefault    = ['[0,',num2str(round(SigCont(1).tmax)),']'];
cb_sigchanged       = [
    'SigCont        = getsignal(ALLSIG,''type'',''continuous'');',...
    'sigind         = get(findobj(gcbf,''tag'',''rawsigs''),''value'');',...
    'tmax           = SigCont(sigind).tmax;',...
    'datarangesel   = findobj(gcbf,''tag'',''datarangesel'');',...
    'set(datarangesel,''String'',[''[0,'',num2str(round(SigCont(sigind).tmax)),'']'']);',...
    ];

cb_chansel = [
    'chanselpos = get(gcbf,''userdata'');',...
    'sigdesc    = get(findobj(gcbf, ''tag'', ''rawsigs''),''String'');',...
    'pos        = get(findobj(gcbf, ''tag'', ''rawsigs''),''Value'');',...
    '[~,sigpos] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    'chanselpos = pop_channelselect(ALLSIG(sigpos),0,1,chanselpos);',...
    'set(gcbf,''userdata'',chanselpos);',...
    'set(findobj(''tag'',''chanseledit''),''String'',[''['',num2str(chanselpos),'']'']);',...
    ];

geometry = {[1,1],[1,1],[1,1],[1],[1,3,1]};
uilist   = {...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','rawsigs','Callback',cb_sigchanged},...
    {'Style','text','String','Channel list (default All) :'},...
    {'Style','edit','String','','tag','chanseledit'},...
    {'Style','text','String','Data range (default All) :'},...
    {'Style','edit','String',datarangedefault,'tag','datarangesel'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
};

[results,chanselpos] = inputgui (geometry, uilist, 'title', 'Export data (EDF)');

if ~isempty(results)
    sigind      = results{1};
    chanselman  = results{2};
    rangesel    = results{3};
    rangesel    = str2double(regexp(rangesel,'\d+','match'));
    if length(rangesel)>2; rangesel=[rangesel(1),rangesel(end)]; end;
    Sig         = SigCont(sigind);
    if isempty(rangesel); rangesel=[0,Sig.tmax]; end;
    %- Channel selection
    if isempty(chanselpos)
        if isempty(chanselman);
            chanselman=1:Sig.nchan; 
        else
            try
                chanselman = eval(['[',chanselman,']',]);
            catch
                chanselman=1:Sig.nchan;
                warning('Error evaluating channel selection');
            end
        end
        chanselman(chanselman<1)=[];
        chanselman(chanselman>Sig.nchan)=[];
        if isempty(chanselman); return; end;
        chanselpos = chanselman;
    end

    EEG = sig2eeg(Sig);
    EEG = pop_select(EEG,'channel',chanselpos,'time',rangesel);
    
    [filename, pathname] = uiputfile('.edf','Select file location');
    if filename
        pop_writeeeg(EEG,fullfile(pathname,filename),'TYPE','EDF');
    end
        
 
end
    
end
