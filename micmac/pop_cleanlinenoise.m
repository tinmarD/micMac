function [VI, ALLWIN, ALLSIG] = pop_cleanlinenoise(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_CLEANLINENOISE (VI, ALLWIN, ALLSIG)
%   Interface the VisLab Prep pipeline for cleaning line noise
% 
%   See Bigdely-Shamlo, Nima et al. “The PREP Pipeline: Standardized Preprocessing 
%   for Large-Scale EEG Analysis.” Frontiers in Neuroinformatics 9 (2015): 
%   16. PMC. Web. 30 Nov. 2016.

titre = 'PREP Pipeline - CleanLineNoise';

[SigCont,~,~,~,sigdesc] = getsignal (ALLSIG,'type','continuous');
if isempty(SigCont)
    msgbox ('You need to load a signal first');
    return;
end

windowsnb   = cell(1,VI.nwin);
position    = length(ALLWIN(end).views)+1;
for w=1:VI.nwin; windowsnb{w}=w; end;

cb_chansel = [
    'chanselpos = get(gcbf,''userdata'');',...
    'sigdesc    = get(findobj(gcbf, ''tag'', ''allsigs''),''String'');',...
    'pos        = get(findobj(gcbf, ''tag'', ''allsigs''),''Value'');',...
    '[~,sigpos] = getsigfromdesc (ALLSIG, sigdesc{pos});',...
    'chanselpos = pop_channelselect(ALLSIG(sigpos),1,1,chanselpos);',...
    'set(gcbf,''userdata'',chanselpos);',...
    ];

cb_winchanged = [
    'winstr = get(findobj(gcbf,''tag'',''winsel''),''String'');',...
    'winsel = winstr{get(findobj(gcbf,''tag'',''winsel''),''Value'')};',...
    'newpossel = (length(ALLWIN(str2double(winsel)).views)+1);',...                    
    'set(findobj(gcbf,''tag'',''possel''),''String'',num2str(newpossel));'];

geometry = {[1,1],[1,1],[1],[1,3,1],1,[1,1],[1,1,1,1]};
uilist   = {...
    {'Style','text','String','Raw signal :'},...
    {'Style','popupmenu','String',sigdesc,'tag','allsigs'},...
    {'Style','text','String','Frequencies to remove :'},...
    {'Style','edit','String',num2str(vi_defaultval('line_freq')),'tag','freqsedit'},...
    {},...
    {},{'Style','pushbutton','String','Channel Selection','Callback',cb_chansel},{},...
    {},...
    {'Style','text','String','Add view'},...
    {'Style','checkbox','Value',1},...
    {'Style','text','String','Window'},...
    {'Style','popupmenu','String',windowsnb,'Value',length(windowsnb),'tag','winsel','Callback',cb_winchanged},...
    {'Style','text','String','Position'},...
    {'Style','edit','String',num2str(position),'tag','possel'},...
    };

[results,chanselpos] = inputgui (geometry, uilist, 'title', titre);

if ~isempty(results)
    %- Check parameters
    sigind          = results{1};
    freqToRemove    = results{2};
    Sig             = SigCont(sigind);
    try
        freqToRemove    = eval(['[',freqToRemove,']']);
    catch
        msgbox(['Cannot determine the frequencies to be removed : ',freqToRemove],titre);
        return;
    end
    if isempty(freqToRemove); freqToRemove = vi_defaultval('line_freq'); end;
    if ~isnumeric(freqToRemove) || min(freqToRemove)<0 || max(freqToRemove)>(0.5*Sig.srate)
        msgbox(['Frequencies must range between 0 and Nyquist frequency (',...
            num2str(0.5*Sig.srate),' Hz)'],titre);
        return;
    end
    
    x = Sig.data;
    if isempty(chanselpos)
        chanselpos  = nonzeros(Sig.eegchannelind.*(1:Sig.nchan));
        %- Remove bad channels
        chanselpos(ismember(chanselpos,Sig.badchannelpos))=[];
    end        
    
    lineNoiseIn.Fs                  = Sig.srate;
    lineNoiseIn.lineFrequencies     = freqToRemove(:)';
    lineNoiseIn.lineNoiseChannels   = chanselpos(:)';
    %- Call PREP cleanLineNoise
    dispinfo([titre,' ...'],1);
    SigClean = prep_cleanLineNoise(Sig,lineNoiseIn,titre);
    
    % Add the cleaned sig
    [VI, ALLWIN, ALLSIG, sigid] = addsignal (VI, ALLWIN, ALLSIG, SigClean.data, Sig.channames, ...
        Sig.srate, 'continuous', Sig.filename, Sig.filepath, Sig.montage, ...
        [Sig.desc,'_clean'], 1, Sig.id, Sig.badchannelpos);
    
    % Add a view if asked, keep the same gain as the temporal view with signal Sig (if found)
    if results{end-2}
        sigView                     = getview(ALLWIN,'sigid',ALLSIG(sigind).id,'domain','t');
        if ~isempty(sigView); 
            viewGain = sigView(1).gain;
            [VI, ALLWIN, ALLSIG]    = addview (VI, ALLWIN, ALLSIG, results{end-1},sigid,'t',str2double(results{end}),[],viewGain);
        else
            [VI, ALLWIN, ALLSIG]    = addview (VI, ALLWIN, ALLSIG, results{end-1},sigid,'t',str2double(results{end}));
        end
    end
    dispinfo('');

end


end

