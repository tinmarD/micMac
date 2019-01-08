function [VI, ALLWIN, ALLSIG] = pop_kteooperator(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_KTEOOPERATOR(VI, ALLWIN, ALLSIG)
%   Popup for applying the k-Teager Energy Operator to "filter" the signal.
%   The Teager Energy Operator (or Teager-Kaiser Energy Operator) is a non
%   linear operator, powerful for extracting certain type of signal (IEDs for
%   instance).
%
% See also op_kteo, pop_mteooperator

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
    {'Style','popupmenu','String',sigdesc,'tag','sigs'},...
    {'Style','text','String','k parameter :'},...
    {'Style','edit','String','2'},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
    };


results = inputgui (geometry, uilist, 'title', 'k-TEO (Teager Energy Operator)');

if ~isempty(results)
    sigind      = results{1};
    kvalue      = str2double(results{2});
    Sig         = SigCont(sigind);
    
    %- Check the kvalue 
    if isnan(kvalue) || rem(kvalue,1)~=0 || kvalue<0
        msgbox ('The k parameter must be a positive integer');
        return;
    end
    
    dispinfo ('k-TEO Operator');
    % Calcul k-TEO signals
    kteodata    = op_kteo (Sig.data,kvalue);
    % For the non eeg channels, copy the original data
    kteodata (~Sig.eegchannelind,:) = Sig.data(~Sig.eegchannelind,:);
    dispinfo ('');
    sigdesc     = [Sig.desc,'-',num2str(kvalue),'TEO'];
    sigdesc     = makeuniquesigdesc (ALLSIG, sigdesc);
    
    % Add the signal
    [VI, ALLWIN, ALLSIG, sigid] = addsignal (VI, ALLWIN, ALLSIG, kteodata, Sig.channames, ...
        Sig.srate, 'continuous', Sig.tmin, Sig.tmax, Sig.filename, Sig.filepath, Sig.montage, ...
        sigdesc, 0, Sig.id, Sig.badchannelpos, Sig.badepochpos);
    
    % Add a view if asked 
    if results{3}
        [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, results{4},sigid,'t',str2double(results{5}));
    end
    
end
    
end

