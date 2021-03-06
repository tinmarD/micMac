function [VI, ALLWIN, ALLSIG] = pop_importanywaveevents(VI, ALLWIN, ALLSIG)
%[VI, ALLWIN, ALLSIG] = POP_IMPORTANYWAVEEVENTS(VI, ALLWIN, ALLSIG)
%   Import events from Anywave or Delphos - GUI interface

if isempty(ALLSIG)
    msgbox ('You need to load a signal first');
    return;
end

[filename, dirpath] = uigetfile({'*.mrk;*.csv;*.txt'}, 'Select Events File');
if ~ischar(dirpath); return; end;

cb_global_ev = [
    'glob_ev = get(findobj(gcbf,''tag'',''glob_ev_cb''),''Value'');',...
    'if glob_ev; set (findobj(gcbf,''tag'',''channel_pos_ed''), ''enable'', ''off'');',...
    'else; set (findobj(gcbf,''tag'',''channel_pos_ed''), ''enable'', ''on''); end;',...
    ];

[rawSigInd,rawSigDesc] = getrawsignals(ALLSIG);

geometry = {[1,1],[1,1],[1,1],[1,1],[1],[1,1]};

uilist   = {...
    {'Style','text','String','Parent Signal'},...
    {'Style','popupmenu','String',rawSigDesc},...
    {'Style','text','String','Global Events ?'},...
    {'Style','checkbox','value',0,'Callback',cb_global_ev,'tag','glob_ev_cb'},...   
    {'Style','text','String','Num. Header Lines'},...
    {'Style','edit','String','1'},...
    {'Style','text','String','Separator (Tab: 9)'},...
    {'Style','edit','String','9'},...
    {},...
    {'Style','text','String','Overwrite Events'},...
    {'Style','checkbox','value',0},...
    };

results = inputgui (geometry, uilist, 'title', 'Import External Events');

if ~isempty(results)
    sigPos          = results{1};
    parentSig       = ALLSIG(rawSigInd(sigPos));
    globEv          = results{2};
    numHeaderLines  = str2double(results{3});
    sep             = results{4};
    if ~isnan(str2double(sep)) && str2double(sep)==9
        sep = char(9);
    end
    overwrite       = results{5};
    
    VI = importanywaveeventsfromfile(VI, fullfile(dirpath, filename), parentSig, globEv, sep, numHeaderLines, overwrite);
    
    % TODO check doublons, ask for signal, rewrite all the event ids
    VI = updateeventsel (VI, 1);
    [VI, ALLWIN, ALLSIG] = pop_seeevents(VI, ALLWIN, ALLSIG)
    
end


end

