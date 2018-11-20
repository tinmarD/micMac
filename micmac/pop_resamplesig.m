function [VI, ALLWIN, ALLSIG] = pop_resamplesig (VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_RESAMPLESIG (VI, ALLWIN, ALLSIG)
%   Popup window to resample a micMac signal.
%   Uses the EEGLAB pop_resample function.
%   It create a new micMac Signal

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');
if isempty(SigCont)
    msgbox ('No signal loaded');
    return;
end

if length(SigCont) == 1
    srate_first = SigCont.srate;
else
    srate_first = SigCont(1).srate;
end

cb_sigchanged       = [
    'SigCont        = getsignal(ALLSIG,''type'',''continuous'');',...
    'sigind         = get(findobj(gcbf,''tag'',''rawsigs''),''value'');',...
    'srate          = SigCont(sigind).srate;',...
    'sratetext      = findobj(gcbf,''tag'',''currentsrate'');',...
    'set(sratetext,''String'',num2str(srate));',...
    ];

cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;

geometry = {[1,1],[1,1],[1,1],[1],[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','rawsigs','Callback',cb_sigchanged},...
    {'Style','text','String','Sampling Freq. (Hz) :'},...
    {'Style','text','String',num2str(srate_first),'tag','currentsrate'},...
    {'Style','text','String','New Sampling Freq. (Hz) :'},...
    {'Style','edit','String',''},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',0},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'}
};


[results, ~] = inputgui (geometry, uilist, 'title', 'Resample Signal');

if ~isempty(results)
    sigind      = results{1};
    new_srate   = str2double(results{2});
    Sig         = ALLSIG(sigind);
    if new_srate == Sig.srate
        msgbox('New sampling frequency is equal to the current sampling frequency');
        return;
    end
    if isnan(new_srate) || new_srate < 0
        msgbox('Enter a positive numeric value');
        return;
    end
    
    SigResampled = resamplesig(Sig, new_srate);
    
    [VI, ALLWIN, ALLSIG, sigid] = addsignal(VI, ALLWIN, ALLSIG, SigResampled.data, ...
        SigResampled.channames, SigResampled.srate, SigResampled.type, SigResampled.tmin, ...
        SigResampled.tmax, SigResampled.filename, SigResampled.filepath, SigResampled.montage,...
        SigResampled.desc, SigResampled.israw, -1);
    
    % Add a view if asked 
    if results{3}
        [VI, ALLWIN, ALLSIG] = addview (VI, ALLWIN, ALLSIG, results{4},sigid,'t',str2double(results{5}));
    end
end
    

end

