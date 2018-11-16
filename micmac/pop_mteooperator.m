function [VI, ALLWIN, ALLSIG] = pop_mteooperator(VI, ALLWIN, ALLSIG)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG, 'type', 'continuous');
if isempty(SigCont)
    msgbox ('You need to load a signal first');
    return;
end

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;

cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

geometry = {[1,1],[1,1],[1],[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Input signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','sigs','value',1},...
    {'Style','text','String','k parameter :'},...
    {'Style','edit','String','2 5 9'},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
    };


results = inputgui (geometry, uilist, 'title', 'MTEO (Multiresolution Teager Energy Operator)');

if ~isempty(results)
    sigind      = results{1};
    kvaluesstr  = strtrim(results{2});
    Sig         = SigCont(sigind);
    
    %- Get the kvalues 
    if kvaluesstr(1)~='[';   kvaluesstr=['[',kvaluesstr]; end;
    if kvaluesstr(end)~=']'; kvaluesstr=[kvaluesstr,']']; end;
    kvalues = eval(kvaluesstr);
    if isempty(kvalues)
        msgbox ('The k values must be positive integers');
        return;
    end
    
    dispinfo ('MTEO Operator...');
    % Calcul the MTEO signal
    mteodata    = op_mteo (Sig.data,kvalues);
    % For the non eeg channels, copy the original data
    mteodata (~Sig.eegchannelind,:) = Sig.data(~Sig.eegchannelind,:);
    dispinfo ('');
    sigdesc     = [Sig.desc,'-','MTEO'];
    sigdesc     = makeuniquesigdesc (ALLSIG, sigdesc);
    
    % Add the signal
    [VI, ALLWIN, ALLSIG, sigid] = addsignal (VI, ALLWIN, ALLSIG, mteodata, Sig.channames, ...
        Sig.srate, 'continuous', Sig.tmin, Sig.tmax,Sig.filename, Sig.filepath, Sig.montage, ...
        sigdesc, 0, Sig.id, Sig.badchannelpos, Sig.badepochpos);
    
    % Add a view if asked 
    if results{3}
        [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, results{4},sigid,'t',str2double(results{5}));
    end
    
end
    
end

